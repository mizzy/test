resource "aws_cloudwatch_log_group" "coffee_chat" {
  name              = "/aws/lambda/${aws_lambda_function.coffee_chat.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "coffee_chat" {
  name               = "coffee-chat"
  assume_role_policy = data.aws_iam_policy_document.coffee_chat_assume_role.json
}

data "aws_iam_policy_document" "coffee_chat_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "coffee_chat_logging" {
  name = "coffee-chat-logging"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "coffee_chat_logging" {
  role       = aws_iam_role.coffee_chat.id
  policy_arn = aws_iam_policy.coffee_chat_logging.arn
}

data "archive_file" "coffee_chat" {
  type        = "zip"
  source_dir  = "lambda/function"
  output_path = "lambda/upload/coffee_chat.zip"
}

resource "aws_lambda_function" "coffee_chat" {
  function_name    = "coffee-chat"
  filename         = data.archive_file.coffee_chat.output_path
  role             = aws_iam_role.coffee_chat.arn
  source_code_hash = data.archive_file.coffee_chat.output_base64sha256
  handler          = "coffee_chat.lambda_handler"
  runtime          = "python3.8"
}

locals {
  schedules = {
    "13-55-Wed-JST" = "55 4 ? * WED *"
    "14-25-Wed-JST" = "25 5 ? * WED *"
    "10-55-Fri-JST" = "55 1 ? * FRI *"
    "11-25-Fri-JST" = "25 2 ? * FRI *"
  }
}

resource "aws_cloudwatch_event_rule" "coffee_chat" {
  for_each            = local.schedules
  name                = "coffee-chat-${each.key}"
  schedule_expression = "cron(${each.value})"
}

resource "aws_cloudwatch_event_target" "coffee_chat" {
  for_each = local.schedules
  rule     = aws_cloudwatch_event_rule.coffee_chat[each.key].name
  arn      = aws_lambda_function.coffee_chat.arn
}

resource "aws_lambda_permission" "coffee_chat" {
  for_each      = local.schedules
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.coffee_chat.function_name
  source_arn    = aws_cloudwatch_event_rule.coffee_chat[each.key].arn
  principal     = "events.amazonaws.com"
}
