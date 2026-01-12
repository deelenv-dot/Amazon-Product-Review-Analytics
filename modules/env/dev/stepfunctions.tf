resource "aws_sfn_state_machine" "glue_pipeline" {
  name     = "capstone-glue-pipeline-${random_id.suffix.hex}"
  role_arn = aws_iam_role.stepfunctions.arn

  definition = jsonencode({
    Comment = "Download and flatten Amazon review datasets"
    StartAt = "DownloadReviews"
    States = {
      DownloadReviews = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = aws_glue_job.download_reviews.name
        }
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath  = "$.error"
            Next        = "NotifyFailure"
          }
        ]
        Next = "DownloadMeta"
      }
      DownloadMeta = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = aws_glue_job.download_meta.name
        }
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath  = "$.error"
            Next        = "NotifyFailure"
          }
        ]
        Next = "FlattenReviews"
      }
      FlattenReviews = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = aws_glue_job.flatten_reviews.name
        }
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath  = "$.error"
            Next        = "NotifyFailure"
          }
        ]
        Next = "FlattenMeta"
      }
      FlattenMeta = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = aws_glue_job.flatten_meta.name
        }
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath  = "$.error"
            Next        = "NotifyFailure"
          }
        ]
        Next = "NotifySuccess"
      }
      NotifySuccess = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.publish_sns.arn
          Payload = {
            status        = "SUCCEEDED"
            message       = "Glue pipeline completed"
            execution_id  = "$$.Execution.Id"
            execution_name = "$$.Execution.Name"
            state_machine = "$$.StateMachine.Name"
            jobs = [
              aws_glue_job.download_reviews.name,
              aws_glue_job.download_meta.name,
              aws_glue_job.flatten_reviews.name,
              aws_glue_job.flatten_meta.name
            ]
          }
        }
        End = true
      }
      NotifyFailure = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.publish_sns.arn
          Payload = {
            status        = "FAILED"
            message       = "Glue pipeline failed"
            execution_id  = "$$.Execution.Id"
            execution_name = "$$.Execution.Name"
            state_machine = "$$.StateMachine.Name"
            error         = "$.error"
            jobs = [
              aws_glue_job.download_reviews.name,
              aws_glue_job.download_meta.name,
              aws_glue_job.flatten_reviews.name,
              aws_glue_job.flatten_meta.name
            ]
          }
        }
        End = true
      }
    }
  })
}
