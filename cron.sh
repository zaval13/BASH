#!/bin/bash

if [ ! -f /etc/cron.d/script1 ]; then
echo "*/15 * * * * root /root/script1.sh" > /etc/cron.d/script1
fi

sudo grep -o "httpd" /var/log/messages >> /root/output1.txt
