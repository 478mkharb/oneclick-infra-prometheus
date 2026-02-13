output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "private_ec2_sg_id" {
  value = aws_security_group.private_ec2_sg.id
}
