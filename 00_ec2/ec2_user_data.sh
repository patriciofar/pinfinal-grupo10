#!/bin/bash

echo "Installing AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
aws --version
echo "AWS CLI installed successfully"

echo "Installing kubectl"
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.26.2/2023-03-17/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
kubectl version --client

echo "Installing eksctl"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
if [ $? -ne 0 ]; then
  echo "Failed to download eksctl"
  exit 1
fi
sudo mv /tmp/eksctl /usr/local/bin
if [ $? -ne 0 ]; then
  echo "Failed to move eksctl to /usr/local/bin"
  exit 1
fi
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
eksctl version

# Instalación de Docker en Ubuntu
echo "Installing Docker"
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Añadir el usuario al grupo docker para que pueda usar Docker sin sudo
sudo usermod -aG docker ubuntu
newgrp docker

# Descargar e instalar Docker Compose
echo "Installing Docker Compose"
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose

echo "Installing Helm"
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version

# Instalación de Terraform en Ubuntu
echo "Installing Terraform"
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common
sudo wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg
sudo apt-get update
sudo apt-get install -y terraform

echo "Instalación completada"
