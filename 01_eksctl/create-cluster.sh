#!/bin/bash

# Set AWS credentials 
aws sts get-caller-identity >> /dev/null
if [ $? -eq 0 ]
then
  echo "Credenciales testeadas, proceder con la creacion de cluster."

  # Creacion de cluster
  eksctl create cluster\
  --name eks-mundos-e\
  --region us-east-1\
  --nodes 3\
  --node-type t3.small \
  --with-oidc\
  --ssh-access\
  --ssh-public-key pin-grupo10\
  --managed\
  --full-ecr-access\
  --zones us-east-2a,us-east-2b,us-east-2c

  if [ $? -eq 0 ]
  then
    echo "Cluster Setup Completo con eksctl ."
  else
    echo "Cluster Setup Falló mientras se ejecuto eksctl."
  fi
else
  echo "Please run aws configure & set right credentials."
  echo "Cluster setup failed."
fi
