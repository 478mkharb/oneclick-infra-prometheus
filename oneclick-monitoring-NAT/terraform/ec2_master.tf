resource "aws_instance" "k3s_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = aws_subnet.private_a.id

  vpc_security_group_ids = [
    aws_security_group.private_ec2_sg.id
  ]

  iam_instance_profile = "ec2-ssm-profile"

  tags = {
    Name = "k3s-server"
  }
}
