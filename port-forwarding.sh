#server 192.168.0.150
systemctl start httpd
firewall-cmd --add-service=http --permanent
firewall-cmd --reload
#server 192.168.0.160
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --zone=public --add-forward-port=port=10010:proto=tcp:toport=80:toaddr=192.168.0.150 --permanent
firewall-cmd --reload