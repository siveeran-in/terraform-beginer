#!/bin/sh
echo "Installing and setting up NGINX Web Server.."
apt-get update -y
apt-get install nginx -y
systemctl restart nginx
systemctl enable nginx
echo "Completed"