resource "aws_network_interface_attachment" "k3s_server_attach" {
  instance_id          = aws_instance.k3s_server.id
  network_interface_id = aws_network_interface.k3s_server_eni.id
  device_index         = 0
}
