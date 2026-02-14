resource "aws_launch_template" "monitoring_server_lt" {
  name_prefix   = "monitoring-server-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_monitoring
  
  iam_instance_profile {
    name = "ec2-ssm-profile"
  }

  vpc_security_group_ids = [
    var.private_ec2_sg_id
  ]

user_data = base64encode(<<EOF
#!/bin/bash
set -eux
exec > /var/log/bootstrap.log 2>&1

echo "[BOOT] Waiting for network"
for i in {1..30}; do
  ping -c1 8.8.8.8 && break
  sleep 10
done

echo "[SYSTEM] Update packages"
apt-get update -y
apt-get upgrade -y
apt-get install -y curl ca-certificates

echo "[SSM] Install & start SSM Agent"
if command -v snap >/dev/null 2>&1; then
  snap install amazon-ssm-agent --classic || true
fi

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent
EOF
)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "monitoring-server"
      Role    = var.role
      Project = var.project
    }
  }
}
