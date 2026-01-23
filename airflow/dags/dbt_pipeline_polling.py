from __future__ import annotations

import os
from datetime import datetime

import boto3
from airflow.sdk import Variable
from airflow.providers.standard.sensors.python import PythonSensor

from airflow.sdk import dag
from airflow.providers.docker.operators.docker import DockerOperator
from docker.types import Mount

DOCKER_IMAGE = os.getenv("DBT_DOCKER_IMAGE", "")
PROJECT_DIR = "/app/reviews_pipeline_orchestration"
STATE_MACHINE_ARN = os.getenv("STATE_MACHINE_ARN", "")
AWS_REGION = os.getenv("AWS_REGION", "")
DBT_DOCS_DIR = os.getenv("DBT_DOCS_DIR", "")


# Helper to standardize dbt task execution inside the Docker image.
def make_dbt_task(task_id: str, dbt_cmd: str, mounts: list[Mount] | None = None) -> DockerOperator:
    return DockerOperator(
        task_id=task_id,
        image=DOCKER_IMAGE,
        command=f"bash -c 'cd {PROJECT_DIR} && {dbt_cmd}'",
        auto_remove="success",
        mount_tmp_dir=False,
        docker_url="unix://var/run/docker.sock",
        api_version="auto",
        network_mode="bridge",
        mounts=mounts or [],
        environment={
            "SNOWFLAKE_PRIVATE_KEY": os.getenv("SNOWFLAKE_PRIVATE_KEY", ""),
        },
    )


# Track the most recent successful execution to avoid reruns in later polls.
def latest_execution_succeeded() -> bool:
    if not STATE_MACHINE_ARN:
        raise ValueError("STATE_MACHINE_ARN is not set")

    if not AWS_REGION:
        raise ValueError("AWS_REGION is not set")

    sfn = boto3.client("stepfunctions", region_name=AWS_REGION)
    executions = sfn.list_executions(
        stateMachineArn=STATE_MACHINE_ARN,
        maxResults=1,
    ).get("executions", [])

    if not executions:
        return False

    exec_arn = executions[0]["executionArn"]
    last_exec_arn = Variable.get("capstone_latest_execution_arn", default="")
    if exec_arn == last_exec_arn:
        return False
    status = sfn.describe_execution(executionArn=exec_arn)["status"]

    if status in {"FAILED", "TIMED_OUT", "ABORTED"}:
        raise RuntimeError(f"Latest execution failed with status: {status}")

    if status == "SUCCEEDED":
        Variable.set("capstone_latest_execution_arn", exec_arn)
        return True

    return False


default_args = {
    "owner": "analytics",
    "retries": 0,
}


@dag(
    dag_id="capstone_dbt_polling",
    description="Poll Step Functions and run dbt after success.",
    schedule="*/60 * * * *",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    default_args=default_args,
    tags=["dbt", "amazon-reviews", "polling"],
)
def capstone_dbt_polling():
    wait_for_success = PythonSensor(
        task_id="wait_for_state_machine_success",
        python_callable=latest_execution_succeeded,
        poke_interval=60 * 5,
        timeout=60 * 55,
        mode="reschedule",
    )

    dbt_debug = make_dbt_task(
        task_id="dbt_debug",
        dbt_cmd="dbt debug --project-dir /app/reviews_pipeline_orchestration --profiles-dir /root/.dbt",
    )

    dbt_deps = make_dbt_task(
        task_id="dbt_deps",
        dbt_cmd="dbt deps --project-dir /app/reviews_pipeline_orchestration --profiles-dir /root/.dbt",
    )

    dbt_run = make_dbt_task(
        task_id="dbt_run",
        dbt_cmd="dbt run --project-dir /app/reviews_pipeline_orchestration --profiles-dir /root/.dbt",
    )

    dbt_test = make_dbt_task(
        task_id="dbt_test",
        dbt_cmd="dbt test --project-dir /app/reviews_pipeline_orchestration --profiles-dir /root/.dbt",
    )

    dbt_docs = make_dbt_task(
        task_id="dbt_docs",
        dbt_cmd="dbt docs generate --project-dir /app/reviews_pipeline_orchestration --profiles-dir /root/.dbt --target-path /dbt_docs",
        mounts=[Mount(source=DBT_DOCS_DIR, target="/dbt_docs", type="bind")] if DBT_DOCS_DIR else [],
    )

    wait_for_success >> dbt_debug >> dbt_deps >> dbt_run >> dbt_test >> dbt_docs


dag = capstone_dbt_polling()
