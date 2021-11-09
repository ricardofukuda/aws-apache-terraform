#!/bin/sh
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd