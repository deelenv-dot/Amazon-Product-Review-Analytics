# Capstone Project — Amazon Product Review Analytics

End-to-end pipeline that ingests Amazon Reviews + Metadata, flattens to Parquet, lands in S3, exposes Snowflake external tables, transforms with dbt, and orchestrates with Airflow.

## Pipeline overview
- **Ingest**: Glue Python Shell downloads JSONL.GZ from public URLs to S3 `raw/`.
- **Clean meta**: Glue Python Shell normalizes metadata keys and removes duplicates.
- **Flatten**: Glue Spark job writes Parquet to `flattened/`.
- **Orchestrate**: Step Functions runs download → clean meta → flatten.
- **Warehouse**: Snowflake external tables point to Parquet in S3.
- **Transform**: dbt staging + marts, scheduled by Airflow.

## Terraform quickstart
1) Bootstrap remote state (once):
```bash
cd bootstrap
terraform init
terraform plan
terraform apply -auto-approve
```
Update `modules/env/dev/backend.tf` with outputs.

2) Local env:
```bash
cp .env.example .env
set -a
source .env
set +a
```

3) Apply infra:
```bash
cd modules/env/dev
terraform init
terraform plan
terraform apply
```

## GitHub Actions (alternative to local Terraform)
Use the workflows to provision and destroy infra in CI.

Workflows:
- `terraform-bootstrap.yml` — creates S3/DynamoDB backend
- `terraform.yml` — plans/applies the main stack
- `terraform-destroy.yml` — destroys the stack (requires `DESTROY` confirmation)

Required GitHub Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`
- `SNOWFLAKE_PRIVATE_KEY`
- `SNOWFLAKE_ROLE`
- `SNOWFLAKE_WAREHOUSE`
- `SNOWFLAKE_IAM_USER_ARN` (after first apply)
- `SNOWFLAKE_EXTERNAL_ID` (after first apply)

Note: run the bootstrap workflow first. Then run the main workflow twice to set the Snowflake integration trust policy (see two-pass apply above).

## Required TF vars
Set in `.env` (or shell) to avoid prompts:
- `TF_VAR_reviews_url`
- `TF_VAR_meta_url`
- `TF_VAR_sns_email`
- Snowflake key-pair vars and storage integration outputs

## Snowflake S3 integration (two-pass apply)
1) `terraform apply`
2) Read outputs:
   - `snowflake_integration_iam_user_arn`
   - `snowflake_integration_external_id`
3) Export and re-apply:
```bash
export TF_VAR_snowflake_iam_user_arn="..."
export TF_VAR_snowflake_external_id="..."
terraform apply
```

## Structure
- `glue_jobs/` Glue scripts
- `lambda/` SNS publishing Lambda
- `stepfunctions/` State machine
- `dbt/` dbt project + Docker image
- `airflow/` Airflow stack + DAGs
- `docs/` diagrams, screenshots, notes

## Notes
- External tables are raw JSON (VARIANT). dbt stages parse fields and build marts.
- dbt runs `ALTER EXTERNAL TABLE ... REFRESH` at start via macro.
