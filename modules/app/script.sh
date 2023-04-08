#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2
mkdir -p /var/www/html/
echo "<h1>hello message from host ${host}</h1>" > /var/www/html/index.html