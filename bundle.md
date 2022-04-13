
Criando TasksVersionando os templates com Bundles
================
## Objetivo

Ao final deste modulo você será capaz de:
* Entenda o que é uma Task
* Entenda como clonar um projeto git e compilação usando o Task
* Entenda como funciona os Workspaces
* Crie uma task de build 
* Como executar uma Tasks

## Conceito

Tekton Bundle é um artefato OCI (`Open Container Initiative`) que contém recursos `Tekton`. Basicamente podemos armazenar `Tasks` e `Pipelines`no formato `yaml` e armazenalas em registry como dockerhub.

No modelo de `Bundle`, podemos referenciar nas `Taskrun` ou `PipelineRun` os artefatos armazenados no registry e os mesmos são abaixos e executados em memória sem a necessidade de armazenamento local.

![template](img/image28.png)

O `PipelineRun` executará às `Task` sem registrá-lo no cluster, permitindo que várias versões do mesmo nome `Task` sejam executadas de uma só vez.

O Task ou o Pipeline referido não precisa estar presente ao se referir a ele, caberia ao controlador a responsabilidade de obter a definição e utilizá-la na memória.

Como eles não estão presentes no cluster, não há risco de substituir um Taskarquivo Run. Ele simplifica um cenário de pipeline como código em que não precisaríamos nos preocupar com uma atualização Task ou Pipeline definição de PR para substituir a versão do branch principal.

É mais fácil gerenciar e raciocinar sobre a versão da tarefa. Sem essa proposta, o usuário precisa incluir versões no nome Task/Pipeline se quiser ter um conceito de versão.


# Configuração

O Tekton Bundle está atualmente na versão `alpha` e precisamos habilitar. E para isso altere o configmap `feature-flags` com o recurso `enable-tekton-oci-bundles` para  `true'.

```bash
kubectl edit configmap feature-flags -n tekton-pipelines

apiVersion: v1
data:
  enable-tekton-oci-bundles: "true"
...
```

# Criando Bundle de exemplo

Antes de criarmos as `Bundle` das pipelines, vamos criar alguns exemplos para ajudar no entendimento do funcionamento dos `Bundle`.

Para esse exemplo vamos usar o versionamento de 2 `Tasks`. Nesse caso vamos utilizar o  [src/bundle/task-exemplo1-v1.yaml](.src/bundle/task-exemplo1-v1.yaml) e o [src/bundle/task-exemplo1-v2.yaml](.src/bundle/task-exemplo1-v2.yaml).

Abaixo temos o arquivo `task-exemplo1-v1.yaml` e a versão 2, muda apenas o texto.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: task-exemplo1
spec:
  steps:
    - name: step1
      image: ubuntu      
      script: |
        #!/usr/bin/env bash
        echo "Execunto Step1 - Versao 1"
        date
        echo "Finalizado"
```

Da mesma forma temos a [src/bundle/task-exemplo2-v1.yaml](.src/bundle/task-exemplo2-v1.yaml) e a versão 2 [src/bundle/task-exemplo2-v2.yaml](.src/bundle/task-exemplo2-v2.yaml).

Abaixo temos o arquivo `task-exemplo2-v1.yaml` e a versão 2, muda apenas o texto.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: task-exemplo2
spec:
  steps:
    - name: step1
      image: ubuntu      
      script: |
        #!/usr/bin/env bash
        echo "Execunto Step1 - Versao 1"
        date
        echo "Finalizado"
```

Agora que temos as `tasks` criadas, podemos subir para o registry utilizando o tkn.

> Não é necessário aplicar as `Tasks` no kubernetes para enviar para os registry.

A sintaxe do tkn para o bundle é:

> tkn bundle push <registry>/<artefato> -f <arquivo.yaml>



```bash
./bundle-exemplo1.sh
Creating Tekton Bundle:
        - Added Task: task-exemplo1 to image

Pushed Tekton Bundle to index.docker.io/clodonil/task-exemplo1@sha256:d65ab1d53cc856926b742b0c8738bc8cfdf3be83de410936edc451c0b09ecd7c
Creating Tekton Bundle:
        - Added Task: task-exemplo1 to image

Pushed Tekton Bundle to index.docker.io/clodonil/task-exemplo1@sha256:d65ab1d53cc856926b742b0c8738bc8cfdf3be83de410936edc451c0b09ecd7c
Creating Tekton Bundle:
        - Added Task: task-exemplo2 to image

Pushed Tekton Bundle to index.docker.io/clodonil/task-exemplo2@sha256:44c0c3c73c5082452d956d3d069681f73cdd9669274ed4deea804fad0567b118
Creating Tekton Bundle:
        - Added Task: task-exemplo2 to image

Pushed Tekton Bundle to index.docker.io/clodonil/task-exemplo2@sha256:44c0c3c73c5082452d956d3d069681f73cdd9669274ed4deea804fad0567b118
```

![template](img/image24.png)


```yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: bundle-task
spec:
  taskRef:
    name: task1
    bundle: index.docker.io/clodonil/task-exemplo1:latest
```

Para executar a task:

```bash
 kubectl apply -f taskrun-bundle-exemplo1.yaml
```


```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pipeline-exemplo1
spec:
  params:
    - name: IMAGE
      description: Nome da imagem
    - name: command
      description: comando para execução
      type: array
  tasks:
    - name: exemplo1
      taskRef:
        name:   task-exemplo1
        bundle: index.docker.io/clodonil/task-exemplo1:latest
    - name: exemplo2
      params:
        - name: buildImage
          value: $(params.IMAGE)
        - name: build-args
          value: 
             - "$(params.command)"
      taskRef:
        name:   task-exemplo2
        bundle: index.docker.io/clodonil/task-exemplo2:latest
```
```bash
kubectl apply -f src/bundle/pipeline-exemplo1.yaml
```
E para executar a pipeline, podemos utilizar o comando `tkn`:

```bash
tkn pipeline start pipeline-exemplo1 -p IMAGE='centos' -p command='ls','-l /' --showlog
```

Subindo a versão 2:

```bash
 ./bundle-push-v2.sh
Creating Tekton Bundle:
        - Added Task: task-exemplo1 to image

Pushed Tekton Bundle to index.docker.io/clodonil/task-exemplo1@sha256:4e0c7866a4c0faf0424f46e1064eda34293030971ad4ce78b6972648ccab6fff
Creating Tekton Bundle:
        - Added Task: task-exemplo1 to image

Pushed Tekton Bundle to index.docker.io/clodonil/task-exemplo1@sha256:4e0c7866a4c0faf0424f46e1064eda34293030971ad4ce78b6972648ccab6fff
Creating Tekton Bundle:
        - Added Task: task-exemplo2 to image

Pushed Tekton Bundle to index.docker.io/clodonil/task-exemplo2@sha256:540f1bbda4c384a3ced27479c993ea021e471b865600aee956d7110de173d4da
Creating Tekton Bundle:
        - Added Task: task-exemplo2 to image

Pushed Tekton Bundle to index.docker.io/clodonil/task-exemplo2@sha256:540f1bbda4c384a3ced27479c993ea021e471b865600aee956d7110de173d4da
```

![template](img/image25.png)


Para executar a task:

```bash
kubectl delete -f taskrun-bundle-exemplo1.yaml
kubectl apply -f taskrun-bundle-exemplo1.yaml
```

![template](img/image26.png)


![template](img/image27.png)
