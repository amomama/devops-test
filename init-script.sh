#!/bin/bash
sudo amazon-linux-extras install -y nginx1
sudo systemctl start nginx.service
echo $(hostname -I) > /usr/share/nginx/html/index.html