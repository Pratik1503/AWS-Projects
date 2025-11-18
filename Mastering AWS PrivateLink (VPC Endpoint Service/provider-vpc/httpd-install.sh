#!/bin/bash

# Update system packages
sudo yum update -y

# Install Apache HTTP server
sudo yum install -y httpd

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Add demo HTML content
echo "demo for AWS private link / service provider ec2" | sudo tee /var/www/html/index.html

# Set correct permissions
sudo chmod 755 /var/www/html/index.html

echo "Apache installed and demo content deployed."
