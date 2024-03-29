# Em Desenvolvimento: Previsão 18/07/2022


Desenvolvimento das pipelines
================

## Objetivo

Ao final deste modulo você será capaz de:
* Entenda como estruturar uma pipeline no Tekton
* Entenda como criar pipelines parametrizável
* Entenda como criar pipeline com workspaces
* Entenda como criar e controlar o fluxo da pipeline


## Setup

```
git clone https://github.com/clodonil/treinamento_tekton_pipelines.git
export TREINAMENTO_HOME="$(pwd)/treinamento_tekton_pipelines"
cd $TREINAMENTO_HOME
```

![projeto](img/image14.png)

## Configurações

$ kubectl edit configmap feature-flags -n tekton-pipelines
Procure disable-affinity-assistant. Altere seu valor para true.

```
kubectl apply -f $TREINAMENTO_HOME/proj/Configs/feature-flags.yaml
```

## Volumes

```bash
kubectl apply -f $TREINAMENTO_HOME/proj/pv-workspaces.yaml
```

## Criandos as Tasks

```bash
kubectl apply -f $TREINAMENTO_HOME/proj/tasks/Source/task-source.yaml
kubectl apply -f $TREINAMENTO_HOME/proj/tasks/Build/task-build.yaml
kubectl apply -f $TREINAMENTO_HOME/proj/tasks/QA/task-qa.yaml
kubectl apply -f $TREINAMENTO_HOME/proj/tasks/Security/task-security.yaml
kubectl apply -f $TREINAMENTO_HOME/proj/tasks/Tests/task-tests.yaml
kubectl apply -f $TREINAMENTO_HOME/proj/tasks/Deploy/task-deploy.yaml
kubectl apply -f $TREINAMENTO_HOME/proj/tasks/Deploy/sa.yaml

kubectl apply -f $TREINAMENTO_HOME/proj/tasks/Finally/secret.yaml
kubectl apply -f $TREINAMENTO_HOME/proj/tasks/Finally/task-finally.yaml
```



```bash
kubectl apply -f $TREINAMENTO_HOME/proj/tasks/Source/taskrun-sharedlibrary.yaml
```

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/send-to-webhook-discord/0.1/send-to-webhook-discord.yaml
```

```bash
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

``` Pipeline
kubectl apply -f $TREINAMENTO_HOME/proj/pipeline/microservice-api.yaml
```

