#!/bin/bash

# Variables
CLUSTER_NAME=mundoes-cluster-G6
AWS_REGION=us-east-2

# Set AWS credentials 
aws sts get-caller-identity >> /dev/null
if [ $? -eq 0 ]
then
  echo "Credenciales testeadas, proceder con la creacion de cluster."

  # Creación del cluster en EKS
  eksctl create cluster \
    --name "$CLUSTER_NAME" \
    --region us-east-1 \
    --nodes 3 \
    --node-type t3.small \
    --with-oidc \
    --ssh-access \
    --ssh-public-key pin-grupo10 \
    --managed \
    --full-ecr-access \
    --zones us-east-1a,us-east-1b,us-east-1c \
    --version 1.22

  if [ $? -eq 0 ]; then
    echo "Cluster creado exitosamente con eksctl."
  else
    echo "Error: La creación del cluster falló al ejecutar eksctl"
    exit 1
  fi
else
  echo "No se encuentran credenciales de AWS configuradas. Por favor, ejecuta 'aws configure' para configurar las credenciales adecuadas"
  echo "El setup del cluster ha fallado."
  exit 1
fi
