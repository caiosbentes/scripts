echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list
apt update
apt install python-certbot-apache -t stretch-backports
sed -i 's/server/server2/g' /etc/apache2/sites-available/example.com.conf
pache2ctl configtest
systemctl reload apache2
sudo certbot --apache -d example.com -d www.example.com
