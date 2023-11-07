  resource "aws_cloudwatch_metric_alarm" "Ec2_CPU_Utilization" {
  alarm_name                = "Ec2_CPU_Utilization-{var.instance_id}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = var.threshold
  alarm_description         = "This metric monitors ec2 cpu utilization"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.sns.arn]
  ok_actions          = [aws_sns_topic.sns.arn]
  insufficient_data_actions = [

  ]
}

