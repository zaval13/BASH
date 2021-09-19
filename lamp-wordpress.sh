#!/bin/bash

#install LAMP + wordpress

#install httpd
yum install httpd -y
systemctl start httpd
systemctl enable httpd


#install php
yum update -y
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum install yum-utils -y
yum-config-manager --enable remi-php56
yum install php php-opcache php-xml php-mcrypt php-cli php-gd  php-devel php-curl php-mysql php-intl php-mbstring php-ldap php-zip php-fileinfo -y

#install mariadb
yum install mariadb-server mariadb -y
systemctl start mariadb
systemctl enable mariadb

#auto mysql_secure_installation
yum install expect -y
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root:\"
send \"$MYSQL\r\"
expect \"Would you like to setup VALIDATE PASSWORD plugin?\"
send \"n\r\"
expect \"Change the password for root ?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"

#setup wordpress db
PASS=$2
USER=$1
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE wordpress;
CREATE USER '$USER'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON wordpress.* TO '$USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo "MySQL user created."
systemctl restart httpd
systemctl restart mariadb

#install wordpress
sudo yum install -y wget unzip
sudo wget -P /opt http://wordpress.org/latest.zip
sudo unzip -q /opt/latest.zip -d /var/www/html/
sudo chown -R apache:apache /var/www/html/wordpress/
sudo chmod -R 755 /var/www/html/wordpress/
sudo mkdir -p /var/www/html/wordpress/wp-content/uploads
sudo chown -R :apache /var/www/html/wordpress/wp-content/uploads
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

#setup wp-config
sed -i 's/database_name_here/wordpress/' /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$1/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$2/" /var/www/html/wordpress/wp-config.php

#firewall rule
firewall-cmd --add-service=http --permanent
firewall-cmd --reload

echo "Link to finish wordpress installation: http://<ip>/wordpress/wp-admin/install.php"
