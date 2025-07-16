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
  endpoint  = var.sns_alert_email
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each            = toset(data.aws_autoscaling_groups.eks_nodegroups.names)   
  alarm_name          = "${each.key}-cpu-high"                                      # Unique name for the alarm per ASG
  comparison_operator = "GreaterThanThreshold"                                      # Trigger alarm if CPU > threshold
  evaluation_periods  = 2                                                           # Must breach threshold for 2 periods
  metric_name         = "CPUUtilization"                                            # Built-in EC2 CPU metric
  namespace           = "AWS/EC2"                                                   # Namespace for EC2 metrics
  period              = 300                                                         # Evaluation period in seconds (5 mins)
  statistic           = "Average"                                                   # Aggregation method over the period
  threshold           = 90                                                          # Trigger if average CPU > 90%
  alarm_description   = "CPU is running high on EKS worker nodes"
  dimensions = {
    AutoScalingGroupName = each.key                                                 # Filter metric by ASG name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]                                        # Send notification to SNS
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  for_each            = toset(data.aws_autoscaling_groups.eks_nodegroups.names)
  alarm_name          = "${each.key}-memory-high"                                   # Unique name for the memory alarm
  comparison_operator = "GreaterThanThreshold"                                      # Trigger alarm if memory > threshold
  evaluation_periods  = 2                                                           # Must breach for 2 consecutive periods
  metric_name         = "mem_used_percent"                                          # Metric from CloudWatch Agent
  namespace           = "CWAgent"                                                   # Namespace for custom CWAgent metrics
  period              = 300                                                         # Evaluation period in seconds (5 mins)
  statistic           = "Average"                                                   # Aggregation method
  threshold           = 90                                                          # Trigger if average memory > 90%
  alarm_description   = "Memory utilization is running high on EKS worker nodes"
  dimensions = {
    AutoScalingGroupName = each.key                                                 # Filter metric by ASG name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]                                        # Send notification to SNS
}
