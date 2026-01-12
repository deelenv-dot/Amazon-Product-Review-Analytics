import sys

from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext


def main():
    args = getResolvedOptions(sys.argv, ["source_s3_path", "target_s3_path"])
    source_s3_path = args["source_s3_path"]
    target_s3_path = args["target_s3_path"]

    sc = SparkContext.getOrCreate()
    glue_context = GlueContext(sc)
    spark = glue_context.spark_session

    df = spark.read.json(source_s3_path)
    df.write.mode("overwrite").parquet(target_s3_path)


if __name__ == "__main__":
    main()
