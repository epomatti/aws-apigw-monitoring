terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.20.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  aws_account = data.aws_caller_identity.current.account_id
  aws_region  = data.aws_region.current.name
}

resource "aws_api_gateway_rest_api" "main" {
  name        = "httpbin"
  description = "API Gateway REST logging and monitoring"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "get" {
  path_part   = "get"
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.get.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.get.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://httpbin.org/get"
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  depends_on = [aws_api_gateway_integration.integration]
}

resource "aws_cloudwatch_log_group" "access_logs" {
  name              = "/apigateway/accesslogs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "execution_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.main.id}/default"
  retention_in_days = 7
}

resource "aws_api_gateway_method_settings" "execution_logs" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.default.stage_name
  method_path = "*/*"

  settings {
    logging_level      = var.execution_logs_logging_level
    data_trace_enabled = var.execution_logs_data_trace_enabled
    metrics_enabled    = var.execution_logs_metrics_enabled
  }
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "default"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access_logs.arn
    format          = file("accessLogFormat.json")
  }

  lifecycle {
    ignore_changes = [deployment_id]
  }

  depends_on = [
    aws_cloudwatch_log_group.execution_logs,
    aws_api_gateway_account.ApiGatewayAccountSetting
  ]
}

resource "aws_api_gateway_account" "ApiGatewayAccountSetting" {
  cloudwatch_role_arn = aws_iam_role.APIGatewayCloudWatchRole.arn
  depends_on          = [aws_iam_role_policy_attachment.APIGatewayCloudWatchRole]
}

resource "aws_iam_role" "APIGatewayCloudWatchRole" {
  name = "TerraformAPIGatewayPushToCloudWatchLogs"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "apigateway.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "APIGatewayCloudWatchRole" {
  role       = aws_iam_role.APIGatewayCloudWatchRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
