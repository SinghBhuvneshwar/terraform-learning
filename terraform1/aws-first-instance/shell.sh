#!/bin/bash
sudo apt-get update
sudo apt install -y nginx 
sudo systemctl enable --now nginx
sudo echo "this is server create with the help of terraform" > /var/www/html/index.nginx-debian.html
sudo systemctl restart nginx