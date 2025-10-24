# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-alerts"

  tags = {
    Name = "${var.cluster_name}-alerts"
  }
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Alarms for CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_alert" {
  alarm_name          = "${var.cluster_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "600"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "CPU is running high on K8 workers"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.production.resources[0].autoscaling_groups[0].name
  }

  tags = {
    Name = "${var.cluster_name}-cpu-alert"
  }
}

# CloudWatch Alarms for Memory utilization (requires CloudWatch agent)
resource "aws_cloudwatch_metric_alarm" "memory_alert" {
  alarm_name          = "${var.cluster_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "600"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "Memory Utilization is running high on K8 workers"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.production.resources[0].autoscaling_groups[0].name
  }

  tags = {
    Name = "${var.cluster_name}-memory-alert"
  }
}

# CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

  tags = {
    Name = "${var.cluster_name}-logs"
  }
}
