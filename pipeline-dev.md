Desenvolvimento das pipelines
================

## Objetivo

Ao final deste modulo você será capaz de:
* Entenda como estruturar uma pipeline no Tekton
* Entenda como criar pipelines parametrizável
* Entenda como criar pipeline com workspaces
* Entenda como criar e controlar o fluxo da pipeline


![projeto](img/image14.png)



```bash
kubectl apply -f proj/tasks/Source/task-source.yaml
kubectl apply -f proj/tasks/Build/task-build.yaml
kubectl apply -f proj/tasks/QA/task-qa.yaml
kubectl apply -f proj/tasks/Security/task-security.yaml
kubectl apply -f proj/tasks/Tests/task-tests.yaml
kubectl apply -f proj/tasks/Deploy/task-deploy.yaml
kubectl apply -f proj/tasks/Deploy/sa.yaml
kubectl apply -f proj/pv-workspaces.yaml
kubectl apply -f proj/tasks/Finally/secret.yaml
kubectl apply -f proj/tasks/Finally/task-finally.yaml
kubectl apply -f proj/pipeline/microservice-api.yaml
```

```
kubectl apply -f proj/tasks/Source/taskrun-sharedlibrary.yaml
```

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/send-to-webhook-discord/0.1/send-to-webhook-discord.yaml
```
```
kubectl apply -f proj/tasks/Source/taskrun-sharedlibrary.yaml
```
```
kubectl create secret generic sonar --from-literal=SONAR_TOKEN=$TOKEN
```
```
kubectl create secret docker-registry myregistrykey \
  --docker-server=$DOCKER_REGISTRY_SERVER \
  --docker-username=$DOCKER_USER \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL
kubectl patch serviceaccount default -p '{"secrets": [{"name": "myregistrykey"}]}'
```


$ kubectl edit configmap feature-flags -n tekton-pipelines
Procure disable-affinity-assistant. Altere seu valor para true.