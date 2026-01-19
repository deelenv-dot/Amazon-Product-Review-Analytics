# Glue Jobs

Scripts:
- `download_from_url.py` — downloads dataset files to S3 if not present.
- `clean_jsonl_keys.py` — normalizes metadata JSON keys and dedupes.
- `flatten_jsonl_to_parquet.py` — Spark job to write Parquet.

Flow:
1) Download reviews + meta
2) Clean meta
3) Flatten reviews + meta to `flattened/`
