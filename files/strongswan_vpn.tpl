#!/bin/bash

#variables
declare server_internal_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
declare server_public_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)


#install strongswan vpn
sudo apt-get install strongswan -y

#edit /etc/ipsec.conf
sudo truncate /etc/ipsec.conf --size=0

sudo cat <<EOT >> /etc/ipsec.conf
config setup
  strictcrlpolicy=no
  charondebug=all
conn %default
  ikelifetime=60m
  keylife=20m
  rekeymargin=3m
  keyingtries=1
  keyexchange=ikev2
conn ${connection_name}
  authby=secret
  auto=start
  type=tunnel
  left=$${server_internal_ip}
  leftid=$${server_public_ip}
  leftsubnet=${server_subnet}
  leftauth=psk
  right=${client_public_ip}
  rightsubnet=${client_subnet}
  rightauth=psk
  ike=aes128-sha1-modp1024
  esp=aes128-sha1-modp1024
EOT

#edit /etc/ipsec.secrets
sudo truncate /etc/ipsec.secrets --size=0

sudo cat <<EOT >> /etc/ipsec.secrets
$${server_public_ip} : PSK "${pre_sharekey}"
${client_public_ip} : PSK "${pre_sharekey}"
EOT

#enable ipv4 forwarding on your instance
sudo sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf

#start and restart ipsec
sudo ipsec start
sudo ipsec restart
