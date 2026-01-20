from __future__ import annotations

import os
from datetime import datetime

from airflow.sdk import dag
from airflow.providers.docker.operators.docker import DockerOperator
from docker.types import Mount

DOCKER_IMAGE = os.getenv("DBT_DOCKER_IMAGE", "")
PROJECT_DIR = "/app/reviews_pipeline_orchestration"


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
    dag_id="capstone_dbt_debug_only",
    description="dbt debug only.",
    schedule=None,
    start_date=datetime(2024, 1, 1),
    catchup=False,
    default_args=default_args,
    tags=["dbt", "capstone", "debug"],
)
def capstone_dbt_debug_only():
    dbt_debug = make_dbt_task(
        task_id="dbt_debug",
        dbt_cmd="dbt debug --project-dir /app/reviews_pipeline_orchestration --profiles-dir /root/.dbt",
    )

    dbt_debug

dag = capstone_dbt_debug_only()