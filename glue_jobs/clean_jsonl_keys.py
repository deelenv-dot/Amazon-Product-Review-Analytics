import gzip
import json
import os
import re
import sys
import tempfile

from awsglue.utils import getResolvedOptions
import boto3


def normalize_key(key):
    key = key.strip().lower()
    key = re.sub(r"[^a-z0-9]+", "_", key)
    key = re.sub(r"_+", "_", key)
    key = key.strip("_")
    return key or "field"


def normalize_object(obj):
    if isinstance(obj, dict):
        seen = {}
        out = {}
        for k, v in obj.items():
            base = normalize_key(str(k))
            if base in seen:
                seen[base] += 1
                key = f"{base}__dup_{seen[base]}"
            else:
                seen[base] = 0
                key = base
            out[key] = normalize_object(v)
        return out
    if isinstance(obj, list):
        return [normalize_object(x) for x in obj]
    return obj


def main():
    args = getResolvedOptions(sys.argv, ["source_bucket", "source_key", "target_key"])
    source_bucket = args["source_bucket"]
    source_key = args["source_key"]
    target_key = args["target_key"]

    s3 = boto3.client("s3")

    with tempfile.TemporaryDirectory() as tmpdir:
        src_path = os.path.join(tmpdir, os.path.basename(source_key))
        dst_path = os.path.join(tmpdir, f"cleaned-{os.path.basename(source_key)}")

        s3.download_file(source_bucket, source_key, src_path)

        with gzip.open(src_path, "rt", encoding="utf-8") as src, gzip.open(
            dst_path, "wt", encoding="utf-8"
        ) as dst:
            for line in src:
                line = line.strip()
                if not line:
                    continue
                obj = json.loads(line)
                cleaned = normalize_object(obj)
                dst.write(json.dumps(cleaned, ensure_ascii=True) + "\n")

        s3.upload_file(dst_path, source_bucket, target_key)


if __name__ == "__main__":
    main()
