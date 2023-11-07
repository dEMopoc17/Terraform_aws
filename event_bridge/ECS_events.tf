terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# CloudWatch logs group for ECS events
resource "aws_cloudwatch_log_group" "ecs_events" {
  name = "/ecs/events"
}

# AWS EventBridge rule
resource "aws_cloudwatch_event_rule" "ecs_events" {
  name        = "ecs-events"
  description = "Capture all ECS events"

  event_pattern = jsonencode({
    "source" : ["aws.ecs"],
    "detail" : {
      "clusterArn" : ["arn:aws:ecs:us-east-1:123456798098:cluster/cluster-name"]
    }
  })
}

# AWS EventBridge target
resource "aws_cloudwatch_event_target" "logs" {
  rule      = aws_cloudwatch_event_rule.ecs_events.name
  target_id = "send-to-cloudwatch"
  arn       = aws_cloudwatch_log_group.ecs_events.arn
}

# CloudWatch logs error filter metric
resource "aws_cloudwatch_log_metric_filter" "ecs_errors" {
  name           = "ECS Errors"
  pattern        = "{ $.detail.group = \"*\" && $.detail.stopCode = \"TaskFailedToStart\" }"
  log_group_name = aws_cloudwatch_log_group.ecs_events.name

  metric_transformation {
    name          = "ECSErrors"
    namespace     = "ECSEvents"
    value         = "1"
    unit          = "Count"
    dimensions = {
      group = "$.detail.group"
    }
  }
}

# AWS CloudWatch metric alarm
resource "aws_cloudwatch_metric_alarm" "service_crashes" {
  alarm_name          = "ECS service is stopped with error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ECSErrors"
  namespace           = "ECSEvents"
  period              = "300"
  statistic           = "SampleCount"
  threshold           = "1"
  alarm_description   = "crashes occured"
  alarm_actions       = [aws_sns_topic.monitoring.arn]
  ok_actions          = [aws_sns_topic.monitoring.arn]
  treat_missing_data  = "breaching"

  dimensions = {
    group = "service:our-ecs-service"
  }
}

# AWS SNS topic
resource "aws_sns_topic" "monitoring" {
  name                                = "monitoring"
  lambda_success_feedback_role_arn    = aws_iam_role.sns_delivery_status.arn
  lambda_failure_feedback_role_arn    = aws_iam_role.sns_delivery_status.arn
  lambda_success_feedback_sample_rate = 100

  tags = {
    environment = acc
  }
}