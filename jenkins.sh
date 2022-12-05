#!/bin/bash

sudo yum update -y
sudo yum install yum-utils -y

sudo yum install docker -y
sudo usermod -aG docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo chkconfig docker on
sudo service docker start

sudo yum install git -y


sudo git clone https://github.com/bootcampimpacta/Jenkins.git /usr/tmp/

cd /usr/tmp/

docker build -t jenkins-server-image .
docker run -d -p 80:8080 --name jenkins-pod jenkins-server-image

senha_inicial=$(sudo docker exec -ti jenkins-pod cat /var/jenkins_home/secrets/initialAdminPassword)

echo "Senha inicial para configurar Jenkins: $senha_inicial"

$senha_inicial