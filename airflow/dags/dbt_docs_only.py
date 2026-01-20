from __future__ import annotations

import os
from datetime import datetime

from airflow.sdk import dag
from airflow.providers.docker.operators.docker import DockerOperator
from docker.types import Mount

DOCKER_IMAGE = os.getenv("DBT_DOCKER_IMAGE", "deelenv/amazon-reviews-dbt:latest")
PROJECT_DIR = "/app/reviews_pipeline_orchestration"
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
    dag_id="capstone_dbt_docs",
    description="Generate dbt docs only.",
    schedule=None,
    start_date=datetime(2024, 1, 1),
    catchup=False,
    default_args=default_args,
    tags=["dbt", "capstone", "docs"],
)
def capstone_dbt_docs():
    dbt_docs = make_dbt_task(
        task_id="dbt_docs",
        dbt_cmd="dbt docs generate --project-dir /app/reviews_pipeline_orchestration --profiles-dir /root/.dbt --target-path /dbt_docs",
        mounts=[Mount(source=DBT_DOCS_DIR, target="/dbt_docs", type="bind")] if DBT_DOCS_DIR else [],
    )

    dbt_docs


dag = capstone_dbt_docs()
