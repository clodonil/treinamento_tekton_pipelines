#!/bin/bash
set -x
#apt-get update
#apt-get install -y apt-transport-https ca-certificates curl
#curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
#apt-get update
#apt-get install -y kubectl
cp /workspace/sharedlibrary/CD/deploy.yaml .
APPIMAGE=$1
APPNAME=$2

sed -i -e "s;__image__;$APPIMAGE;g" deploy.yaml
sed -i -e "s;__app__;$APPNAME;g" deploy.yaml
cat deploy.yaml
kubectl apply -f deploy.yaml 
