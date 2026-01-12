data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_publish_sns" {
  name               = "capstone-lambda-sns-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_publish_sns.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_sns_publish" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.glue_notifications.arn]
  }
}

resource "aws_iam_role_policy" "lambda_sns_publish" {
  name   = "capstone-lambda-sns-publish"
  role   = aws_iam_role.lambda_publish_sns.id
  policy = data.aws_iam_policy_document.lambda_sns_publish.json
}

resource "aws_lambda_function" "publish_sns" {
  function_name = "capstone-publish-sns-${random_id.suffix.hex}"
  role          = aws_iam_role.lambda_publish_sns.arn
  runtime       = "python3.11"
  handler       = "publish_sns.handler"
  filename      = "${path.module}/../../../lambda/publish_sns.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../lambda/publish_sns.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.glue_notifications.arn
    }
  }
}
