#!/bin/bash/
s3_bucket="s3://upgrad-crj"
myname=chetan
timestamp=$(date '+%d%m%Y-%H%M%S')
sudo apt update -y

#Bellow code checks the apache2 install or not, if it is not installed then it will install this.
pkgs='apache2'
if ! dpkg -s $pkgs >/dev/null 2>&1; then
	sudo apt-get install $pkgs-y
fi

#Below Service Checks the apache2 is enable or not
apache2_check="$(systemctl status apache2.service | grep Active | awk {'print $3'})"
if [ "${apache2_check}" = "(dead)" ]; then
	systemctl enable apache2.service
fi

#Below script will check that apache2 is running or not, if not it will atart
ServiceStatus="$(systemctl is-active apache2.service)"
if [ " ${ServiceStatus}" != "active" ]; then
	systemctl start apache2.service
fi


#Code will generate the tar file and move to s3 Bucket 
cd /var/log/apache2 && tar -cvf /tmp/$myname-httpd-logs-$timestamp.tar *.log
aws s3 cp /tmp/ $s3_bucket --recursive --exclude "*" --include "*.tar"

