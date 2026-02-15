resource "aws_ssm_parameter" "alb_dns" {
  name  = "/monitoring/alb_dns"
  type  = "String"
  value = aws_lb.monitoring.dns_name

  tags = {
    Project = var.project
  }
}
