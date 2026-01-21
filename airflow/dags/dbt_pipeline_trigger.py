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


default_args = {
    "owner": "analytics",
    "retries": 0,
}


@dag(
    dag_id="capstone_dbt",
    description="Run dbt pipeline.",
    schedule=None,
    start_date=datetime(2024, 1, 1),
    catchup=False,
    default_args=default_args,
    tags=["dbt", "amazon-reviews", "trigger"],
)
def capstone_dbt():
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

    dbt_debug >> dbt_deps >> dbt_run >> dbt_test >> dbt_docs


dag = capstone_dbt()
