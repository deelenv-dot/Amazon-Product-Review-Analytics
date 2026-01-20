# dbt Project: reviews_pipeline_orchestration

## Layers
- **sources**: External tables from Snowflake
- **staging** (`CAPSTONE_AMAZON_STG`): parsed fields from raw VARIANT
- **marts** (`CAPSTONE_AMAZON_MART`): aggregated analytics tables

## Models
- `stg_reviews` — review fields
- `stg_meta` — metadata fields
- `mart_avg_rating_by_store_year` — avg rating + count by store/year, verified purchases only

## Run
```bash
dbt debug
dbt run -s staging
dbt run -s marts
```

## Notes
- `on-run-start` refreshes external tables.
- Custom `generate_schema_name` macro prevents schema concatenation.

## dbt lineage graph
![dbt lineage](../../assets/dbt_lineage_graph.png)
