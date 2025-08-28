# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# Kinesis Stream
resource "aws_kinesis_stream" "chat_stream" {
  name             = "${var.app_name}-${var.environment}"
  shard_count      = 1
  retention_period = 24

  tags = {
    Name        = "${var.app_name}-${var.environment}"
    Environment = var.environment
    Application = var.app_name
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-lambda-role-${var.environment}"
    Environment = var.environment
    Application = var.app_name
  }
}

# IAM Policy for Lambda
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.app_name}-lambda-policy-${var.environment}"
  description = "Policy for Lambda to access Kinesis and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.app_name}-processor-${var.environment}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:ListShards",
          "kinesis:ListStreams"
        ]
        Resource = aws_kinesis_stream.chat_stream.arn
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-lambda-policy-${var.environment}"
    Environment = var.environment
    Application = var.app_name
  }
}

# Attach Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "kinesis_processor" {
  filename         = "lambda_function.zip"
  function_name    = "${var.app_name}-processor-${var.environment}"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  source_code_hash = filebase64sha256("lambda_function.zip")
  runtime         = "nodejs18.x"
  timeout         = 60

  environment {
    variables = {
      KINESIS_STREAM_NAME = aws_kinesis_stream.chat_stream.name
      ENVIRONMENT        = var.environment
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
  ]

  tags = {
    Name        = "${var.app_name}-processor-${var.environment}"
    Environment = var.environment
    Application = var.app_name
  }
}

# Event Source Mapping (Kinesis to Lambda)
resource "aws_lambda_event_source_mapping" "kinesis_lambda_mapping" {
  event_source_arn  = aws_kinesis_stream.chat_stream.arn
  function_name     = aws_lambda_function.kinesis_processor.arn
  starting_position = "LATEST"
  batch_size        = 10

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

# Outputs
resource "aws_cloudwatch_log_group" "kinesis_log_group" {
  name              = "/aws/kinesis/${var.app_name}-${var.environment}"
  retention_in_days = 14
  tags = {
    Name        = "KinesisLogGroup-${var.app_name}-${var.environment}"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.app_name}-processor-${var.environment}"
  retention_in_days = 14

  tags = {
    Name        = "LambdaLogGroup-${var.app_name}-${var.environment}"
    Environment = var.environment
    Application = var.app_name
  }
}

output "kinesis_stream_name" {
  description = "Name of the Kinesis stream"
  value       = aws_kinesis_stream.chat_stream.name
}

output "kinesis_stream_arn" {
  description = "ARN of the Kinesis stream"
  value       = aws_kinesis_stream.chat_stream.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.kinesis_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.kinesis_processor.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}
