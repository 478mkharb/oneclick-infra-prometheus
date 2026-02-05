resource "aws_launch_template" "monitoring_lt" {
  name_prefix   = "lt-${var.project}-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_monitoring

  iam_instance_profile {
    name = "ec2-ssm-profile"
  }

  vpc_security_group_ids = [
    aws_security_group.private_ec2_sg.id
  ]

  user_data = base64encode(<<EOF
#!/bin/bash
set -eux

exec > /var/log/user-data.log 2>&1

echo "Starting bootstrap"

apt-get update -y

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

echo "Bootstrap complete"
EOF
)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "monitoring-instance"
      Role    = var.role
      Project = var.project
    }
  }
}
