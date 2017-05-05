#AWS region
variable "region" {
  description = "AWS region"
}

#name of vpc
variable "name" {
  description = "Name of the VPC"
  default     = "vpc_172.16.0.0/16"
}

#cidr for vpc
variable "cidr" {
  description = "CIDR of the VPC"
  default     = "172.16.0.0/16"
}

#cidr for subnet 
variable "cidr_subnet" {
  description = "CIDR of the Subnet"
  default     = "172.16.4.0/24"
}

#DNS_hostname
variable "enable_dns_hostnames" {
  description = "true if you want to use private DNS within the VPC"
  default     = true
}

#enable DNS
variable "enable_dns_support" {
  description = "true if you want to use private DNS within the VPC"
  default     = true
}

#client local network
variable "client_subnet" {
  description = "subnet of client local network"
}

#pair-key
variable "key_name" {
  description = "AWS_key_pair"
  default     = "wordpress_key"
}

#instance type
variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

#client_public_ip
variable "client_public_ip" {
  description = "client_public_ip"
}

#pre_sharekey
variable "pre_sharekey" {
  description = "pre_sharekey"
}

#connection name
variable "connection_name" {
  description = "server_connection_name"
  default     = "vpn_server"
}
