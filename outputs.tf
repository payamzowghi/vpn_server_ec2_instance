#server_public_ip
output "server_public_ip" {
  value = "${aws_eip.vpn.public_ip}"
}

#server_private_ip
output "server_private_ip" {
  value = "${aws_instance.server.private_ip}"
}

#server_subnet
output "server_subnet" {
  value = "${var.cidr_subnet}"
}


