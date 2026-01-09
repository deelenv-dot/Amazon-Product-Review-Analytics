# Capstone Project 2 — Amazon Product Review Analytics (Terraform Skeleton)

This repo mirrors the weekly-project structure and is ready for Terraform CI/CD. It currently provisions:
- S3 bucket (unique name)
- Snowflake database + schema
- Sample object upload to S3 (placeholder file)

## 1) Bootstrap remote state
```bash
cd bootstrap
terraform init
terraform plan
terraform apply -auto-approve
```

Record the `bucket_name` and `dynamodb_table` outputs, then update:
`modules/env/dev/backend.tf`.

## 2) GitHub Secrets
Add these secrets in GitHub:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION
- SNOWFLAKE_ACCOUNT
- SNOWFLAKE_USER
- SNOWFLAKE_PRIVATE_KEY
- SNOWFLAKE_ROLE
- SNOWFLAKE_WAREHOUSE

## 3) Run Terraform locally (dev)
```bash
cd modules/env/dev
terraform init
terraform plan
terraform apply
```

## Local credentials (best practice)
Do not hardcode secrets in code. Use environment variables locally and GitHub Secrets in CI.

Option A: export variables in your shell
```bash
export TF_VAR_snowflake_account="..."
export TF_VAR_snowflake_user="..."
export TF_VAR_snowflake_private_key="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
export TF_VAR_snowflake_role="ACCOUNTADMIN"
export TF_VAR_snowflake_warehouse="..."
```

Option B: use a local `.env` file (not committed)
```bash
cp .env.example .env
set -a
source .env
set +a
```

Note: if you store the private key in `.env` or GitHub Secrets, it must be a single line with `\n` line breaks.
You can convert it with:
```bash
cat snowflake_rsa_key.pem | sed ':a;N;$!ba;s/\n/\\n/g'
```

## Structure (placeholders)
- `glue_jobs/` placeholder for Glue scripts
- `lambda/` placeholder for Lambda code
- `stepfunctions/` placeholder for state machine definitions
- `dbt/` placeholder for dbt project
- `airflow/` placeholder for DAGs/compose
- `.github/workflows/` CI workflows
- `docs/` architecture and setup notes
