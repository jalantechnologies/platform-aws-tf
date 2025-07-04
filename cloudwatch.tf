data "aws_autoscaling_groups" "eks_nodegroups" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [module.eks.cluster_name]
  }
}

resource "aws_sns_topic" "alerts" {
  name = "${module.eks.cluster_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "your-alert-email@example.com" # <-- CHANGE THIS to your email
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each            = toset(data.aws_autoscaling_groups.eks_nodegroups.names)
  alarm_name          = "${each.key}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "CPU is running high on EKS worker nodes"
  dimensions = {
    AutoScalingGroupName = each.key
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  for_each            = toset(data.aws_autoscaling_groups.eks_nodegroups.names)
  alarm_name          = "${each.key}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Memory utilization is running high on EKS worker nodes"
  dimensions = {
    AutoScalingGroupName = each.key
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

