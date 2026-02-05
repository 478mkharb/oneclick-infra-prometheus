output "k3s_server_private_ip" {
  value = aws_instance.k3s_server.private_ip
}

output "k3s_token" {
  value     = file("/var/lib/rancher/k3s/server/node-token")
  sensitive = true
}
