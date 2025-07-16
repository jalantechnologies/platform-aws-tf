# 📊 CloudWatch Monitoring for EKS Worker Nodes

This module sets up **CloudWatch alarms** and **SNS notifications** to monitor **CPU** and **Memory utilization** for all EKS worker node Auto Scaling Groups (ASGs).

---

## 🔧 What This Does

1. **Detects all EKS worker node groups** using the tag `eks:cluster-name`.
2. **Creates a CloudWatch alarm** per ASG:
   - Triggers when **CPU or Memory usage** exceeds 90% for 10 minutes (2 evaluation periods of 5 minutes).
3. **Sends an alert via email** using AWS SNS (Simple Notification Service).

---

## 📁 Files and Resources

### `data "aws_autoscaling_groups"`

Fetches all Auto Scaling Groups (ASGs) tagged with the EKS cluster name.

### `resource "aws_sns_topic" "alerts"`

Creates a single SNS topic for alert notifications.

### `resource "aws_sns_topic_subscription" "email"`

Subscribes an email address (provided via `var.sns_alert_email`) to the SNS topic.

> 🔧 To configure your email, set the `sns_alert_email` variable in your workspace or CLI.

### `resource "aws_cloudwatch_metric_alarm" "cpu_high"`

Monitors **CPU utilization** across all EKS ASGs.  
Triggers if the average CPU usage goes above **90%** for **2 consecutive 5-minute intervals**.

### `resource "aws_cloudwatch_metric_alarm" "memory_high"`

Monitors **memory usage** using metrics pushed by the **CloudWatch Agent**.  
Also triggers if average memory usage exceeds **90%** for **10 minutes**.

---

## 📖 Parameter Explanations

| Key                  | Description                                                                                      |
|----------------------|--------------------------------------------------------------------------------------------------|
| `comparison_operator`| Defines how to compare the metric to the threshold. E.g., `GreaterThanThreshold`.                |
| `evaluation_periods` | Number of periods the metric must be breaching before triggering the alarm.                     |
| `period`             | Duration (in seconds) of each period. Set to 300 (5 minutes).                                    |
| `statistic`          | Aggregation type over the period. `"Average"` is used here.                                      |
| `threshold`          | The threshold (90%) at which the alarm triggers.                                                 |
| `namespace`          | Metric namespace. `AWS/EC2` for built-in metrics, `CWAgent` for memory metrics from CloudWatch Agent. |
| `dimensions`         | Filters metrics to specific Auto Scaling Groups (ASG).                                           |

---

## 📌 Notes

- The `memory_high` alarm requires the **CloudWatch Agent** to be installed and configured on EKS nodes to push custom metrics like memory usage.
- You must **confirm the SNS subscription via email** after applying the Terraform plan.
- This setup improves visibility into potential EKS performance issues, enabling proactive resolution before outages occur.

---

## 🔗 Helpful AWS Documentation

- [📘 CloudWatch Alarms Overview](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html)
- [📘 Metric Math and Statistics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html)
- [📘 CloudWatch Namespaces and Metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)
- [📘 Using the CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
- [📘 SNS Email Subscriptions](https://docs.aws.amazon.com/sns/latest/dg/sns-email-notifications.html)
