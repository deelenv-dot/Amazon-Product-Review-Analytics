import json
import os

import boto3


def handler(event, context):
    topic_arn = os.environ.get("SNS_TOPIC_ARN")
    if not topic_arn:
        raise RuntimeError("SNS_TOPIC_ARN is not set")

    sns = boto3.client("sns")
    status = event.get("status", "UNKNOWN")
    subject = f"Capstone Glue Pipeline: {status}"
    message = json.dumps(event, indent=2, sort_keys=True)
    sns.publish(TopicArn=topic_arn, Subject=subject, Message=message)

    return {"status": "sent", "topic_arn": topic_arn}
