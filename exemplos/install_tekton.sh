#!/bin/bash

cluster_name="tekton"
logs="tekton.log"

cluster_exist=$(kind get clusters | grep $cluster_name)

if [ ! -z "$cluster_exist" ]; then
  echo "Cluster $cluster_name já existe, deleta (y/n)?"
  read resp
  if [ $resp = 'y' ]; then
     echo "Deletando o kubernetes"
     kind delete cluster --config  -q
  fi
fi   

echo "Instalando o kubernetes"
kind create cluster --config tekton-cluster.conf -q
#kubectl cluster-info --context kind-$cluster_name 

echo "Instalando o Tekton"
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml 2>&1 > $logs
kubectl apply --filename https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml 2>&1 >> $logs
sleep 5
#kubectl apply -f metrics.yaml 2>&1 > $logs

echo -n "Iniciando o TekTon"
x=0
while [ $x != 3 ]
do
    x=$(kubectl -n tekton-pipelines get pods --field-selector=status.phase=Running -o jsonpath='{.items[*].status.phase}' | wc -w)
    sleep 10
    echo -n "."
done 

echo "Done."

kubectl -n tekton-pipelines delete service tekton-dashboard 2>&1 > $logs
kubectl -n tekton-pipelines create service nodeport tekton-dashboard --tcp=9097:9097 --node-port=30000 2>&1 > $logs

echo "Dashboard: http://localhost:30000"
echo "Metrics: http://localhost:30001/metrics"
echo "$cluster_name Configurado."
