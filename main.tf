#Use AWS as provider
provider "aws" {
  region = "${var.region}"
}

#aws_vpc resource
resource "aws_vpc" "vpc_vpn" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags {
    Name = "${var.name}"
  }
}

#private subnet
resource "aws_subnet" "subnet_vpn" {
  vpc_id     = "${aws_vpc.vpc_vpn.id}"
  cidr_block = "${var.cidr_subnet}"

  tags {
    Name = "public_subnet"
  }
}

#The aws_internet_gateway resource 
resource "aws_internet_gateway" "ig_vpn" {
  vpc_id = "${aws_vpc.vpc_vpn.id}"

  tags {
    Name = "igw"
  }
}

#The aws_route_public_subnet
resource "aws_route_table" "rt_public_subnet" {
  vpc_id = "${aws_vpc.vpc_vpn.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig_vpn.id}"
  }

  route {
    cidr_block = "${var.client_subnet}"
    instance_id = "${aws_instance.server.id}"
  }
  
  depends_on = ["aws_instance.server"]
  tags {
    Name = "rt_public_subnet"
  }
}

#The aws_route_table_association_private_subnet
resource "aws_route_table_association" "rt_association_private_subnet" {
  subnet_id      = "${aws_subnet.subnet_vpn.id}"
  route_table_id = "${aws_route_table.rt_public_subnet.id}"
}

resource "aws_eip" "vpn" {
  instance = "${aws_instance.server.id}"
  vpc      = true
}

#security group_for server open stronswan port 
resource "aws_security_group" "server" {
  vpc_id      = "${aws_vpc.vpc_vpn.id}"
  description = "security-group-server"

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1 
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "sg_server"
  }
}

data "template_file" "vpn" {
  template = "${file("files/strongswan_vpn.tpl")}"

  vars {
    connection_name    = "${var.connection_name}"
    server_subnet      = "${var.cidr_subnet}"
    client_public_ip   = "${var.client_public_ip}"
    client_subnet      = "${var.client_subnet}"
    pre_sharekey       = "${var.pre_sharekey}"
  }
}

resource "aws_instance" "server" {
  ami                    = "ami-a58d0dc5"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.subnet_vpn.id}"
  vpc_security_group_ids = ["${aws_security_group.server.id}"]
  user_data              = "${data.template_file.vpn.rendered}"
  source_dest_check      = false

  tags {
    Name = "server"
  }
}
