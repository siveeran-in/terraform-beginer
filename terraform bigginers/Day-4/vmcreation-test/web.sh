#!/bin/sh
echo "Installing and setting up Apache Web Server.."
sudo apt-get update -y
sudo apt-get install apache2 -y
echo "<html><body><b>Welcome to Apache Web Server setup by Terraform!</b></body></html>" > /var/www/html/index.html
systemctl restart apache2
systemctl enable apache2
echo "Completed"