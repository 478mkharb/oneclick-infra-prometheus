output "monitoring_instance_id" {
  description = "Instance ID of monitoring EC2"
  value       = aws_instance.monitoring.id
}
