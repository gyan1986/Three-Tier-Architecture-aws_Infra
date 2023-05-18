#! /bin/bash
sudo yum update -y
sudo yum install mysql -y
sudo amazon-linux-extras install php7.2 -y
sudo yum install -y httpd
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo systemctl start httpd.service
#sudo systemctl enable httpd.service
#sudo chown ec2-user /var/www/html
#sudo echo "Hello world from $(hostname -f)" > /var/www/html/index.html
sudo cp -r wordpress/* /var/www/html/
sudo systemctl restart httpd.service
sudo chmod o+w /var/www/html
mysql -h ${rds_endpoint} -u admin -p${rds_password} -e "CREATE DATABASE wordpress;"