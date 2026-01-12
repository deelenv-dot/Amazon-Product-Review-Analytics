import sys
import os
import urllib.request

from awsglue.utils import getResolvedOptions
import boto3


def download_to_file(url, dest_path):
    with urllib.request.urlopen(url) as resp, open(dest_path, "wb") as out:
        while True:
            chunk = resp.read(1024 * 1024)
            if not chunk:
                break
            out.write(chunk)


def main():
    args = getResolvedOptions(sys.argv, ["source_url", "s3_bucket", "s3_key"])
    source_url = args["source_url"]
    s3_bucket = args["s3_bucket"]
    s3_key = args["s3_key"]

    file_name = os.path.basename(s3_key)
    local_path = f"/tmp/{file_name}"

    download_to_file(source_url, local_path)

    s3 = boto3.client("s3")
    s3.upload_file(local_path, s3_bucket, s3_key)


if __name__ == "__main__":
    main()
