#!/bin/bash

# Comprobando si AWS CLI está configurado correctamente
aws sts get-caller-identity >> /dev/null
if [ $? -eq 0 ]; then
  echo "Credenciales AWS configuradas correctamente. Procediendo con la creación del cluster."

  # Verificando si eksctl está instalado
  if ! command -v eksctl &> /dev/null; then
    echo "eksctl no está instalado. Instalando..."

    # Descargando e instalando eksctl
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v0.114.0/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
    if [ $? -eq 0 ]; then
      sudo mv /tmp/eksctl /usr/local/bin/eksctl
      sudo chmod +x /usr/local/bin/eksctl
      echo "eksctl instalado correctamente."
    else
      echo "Error al instalar eksctl."
      exit 1
    fi
  else
    echo "eksctl ya está instalado."
  fi

  # Verificando si el clúster existe
  CLUSTER_NAME="eks-mundos-e"
  CLUSTER_EXISTS=$(eksctl get clusters --region us-east-1 --name "$CLUSTER_NAME" --output json)

  # Si el clúster existe, eliminamos el clúster antes de crear uno nuevo
  if [ ! -z "$CLUSTER_EXISTS" ]; then
    echo "El clúster '$CLUSTER_NAME' ya existe. Eliminándolo primero..."
    
    # Eliminando la pila de CloudFormation asociada al clúster si existe
    aws cloudformation delete-stack --stack-name "eksctl-eks-mundos-e-cluster" --region us-east-1

    # Esperar hasta que la pila sea eliminada
    echo "Esperando a que la pila de CloudFormation se elimine..."
    aws cloudformation wait stack-delete-complete --stack-name "eksctl-eks-mundos-e-cluster" --region us-east-1

    # Verificando que la pila se haya eliminado correctamente
    if [ $? -eq 0 ]; then
      echo "El clúster '$CLUSTER_NAME' ha sido eliminado correctamente."
    else
      echo "Error al eliminar el clúster '$CLUSTER_NAME'."
      exit 1
    fi
  else
    echo "No se encontró el clúster '$CLUSTER_NAME'. Procediendo con la creación."
  fi

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
  --version 1.26

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
