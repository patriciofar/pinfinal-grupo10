#!/bin/bash

# Comprobando si AWS CLI está configurado correctamente
aws sts get-caller-identity >> /dev/null
if [ $? -eq 0 ]; then
  echo "Credenciales AWS configuradas correctamente. Procediendo con la creación del cluster."

  # Verificando si eksctl está instalado
  command -v eksctl >/dev/null 2>&1 || { echo >&2 "eksctl no está instalado. Instalando..."; exit 1; }

  # Creación del cluster en EKS
  eksctl create cluster \
    --name eks-mundos-e \
    --region us-east-1 \
    --nodes 3 \
    --node-type t3.small \
    --with-oidc \
    --ssh-access \
    --ssh-public-key pin-grupo10 \
    --managed \
    --full-ecr-access \
    --zones us-east-1a,us-east-1b,us-east-1c

  if [ $? -eq 0 ]; then
    echo "Cluster creado exitosamente con eksctl."
  else
    echo "Error: La creación del cluster falló al ejecutar eksctl."
  fi
else
  echo "No se encuentran credenciales de AWS configuradas. Por favor, ejecuta 'aws configure' para configurar las credenciales adecuadas."
  echo "El setup del cluster ha fallado."
  exit 1
fi
