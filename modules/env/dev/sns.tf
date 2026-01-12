resource "aws_sns_topic" "glue_notifications" {
  name = "capstone-glue-notifications-${random_id.suffix.hex}"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.glue_notifications.arn
  protocol  = "email"
  endpoint  = "deelenv@gmail.com"
}
