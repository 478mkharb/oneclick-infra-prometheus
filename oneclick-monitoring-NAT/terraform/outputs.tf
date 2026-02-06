output "k3s_server_private_ip" {
  value = aws_instance.k3s_server.private_ip
}

output "worker_instance_ids" {
  value = aws_instance.k3s_worker[*].id
}
