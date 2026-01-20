# dbt Docker Image

This folder builds a dbt Docker image that bundles the project and reads Snowflake credentials from environment variables.

## Build
```bash
cd dbt
docker build -t deelenv/amazon-reviews-dbt:latest .
```

## Test
```bash
docker run --rm -it \
  -e SNOWFLAKE_PRIVATE_KEY="$(../scripts/encode_private_key.sh ../snowflake_rsa_key.pem)" \
  deelenv/amazon-reviews-dbt:latest \
  dbt debug --project-dir /app/reviews_pipeline_orchestration --profiles-dir /root/.dbt
```

## Push
```bash
docker push deelenv/amazon-reviews-dbt:latest
```

## Notes
- `profiles.yml` inside the image uses `SNOWFLAKE_PRIVATE_KEY`.
- Do not bake keys into the image.
