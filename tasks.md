Criando Tasks
================
## Objetivo

Ao final deste modulo você será capaz de:
* Entenda o que é uma Task
* Entenda como clonar um projeto git e compilação usando o Task
* Entenda como funciona os Workspaces
* Crie uma task de build 
* Como executar uma Tasks


## Conceito

A `Task` é uma coleção de `Steps` que são organizados em ordem de execução como parte de pipeline de `integração continua`. A `Task` é executado da mesma forma que um pod no cluster do Kubernetes, onde cada `Step` se torna um contêiner em execução do pod.

![dashboard](img/image2.png)

Os `Steps` são executados sequencialmente conforme foram criados e cada um deles pode conter uma imagem de pod diferente. Basicamente um `step` deve receber uma entrada processar algo especifico e gerar um saída.

### Task e TaskRun
Enquanto as `Task` define um `template` de execução de tarefas e passos, o `TaskRun` é uma execução de uma `Tasks`. O histórico de execução e os logs estão registrados no `TaskRun` para rastreabilidade.

![taskrun](img/image5.png)

Dessa forma uma `Task` pode ser generica suficiente para executar a mesma tarefa para diferentes linguagens com regras de execução e históricos de execução individualizada para cada `TaskRun`.


## Tasks e Step

Agora que já sabemos o que é `Task`, `Taskrun` e `Steps`, vamos executar o nossa primeira `Task`.
Como primeiro exemplo, vamos criar um `Task` com o nome `task-exemplo1` que contém 3 `Steps`. Nesse exemplo, a `Task` não recebe nenhum parâmetro de entrada e não gera nenhum saída.


```yaml:src/task-exemplo1.yaml
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
        echo "Execunto Step1"
        date
        echo "Finalizado"
    - name: step2
      image: ubuntu      
      script: |
        #!/usr/bin/env bash
        echo "Execunto o Step2"
        echo "Preenchendo o arquivo1" > arquivo1.txt
        ls
        echo "Finalizado"
    - name: step3
      image: ubuntu      
      script: |
        #!/usr/bin/env bash
        echo "Execunto o Step3"
        uname -a
        echo "Finalizado"
```

A criação da `Task` no kubernetes, segue o mesmo padrão de aplicação de qualquer manifesto no cluster.

Conforme realizado abaixo

```bash
kubectl apply -f task-exemplo1.yaml
```
Você pode visualziar a `Task` criada de 2 formas diferentes. 

* Utilizando o comando `tkn`:
```bash
tkn task list
NAME            DESCRIPTION   AGE
task-exemplo1                 6 seconds ago 
```
* Utilizando o dashboard.

![dashboard](img/image4.png)

Para executar uma `Task` precisamos da criação do manifesto chamado `TaskRun`. O manifesto pode ser criado atráves de um arquivo `yaml` ou criado dinamicamente através do dashboard ou utilizando o cli `tkn`.

```bash
tkn task start task-exemplo1
TaskRun started: task-exemplo1-run-dhcxj

In order to track the TaskRun progress run:
tkn taskrun logs task-exemplo1-run-dhcxj -f -n default
```

A criação do manifesto `yaml` permite você trabalhar nativamente com o `kubernetes`, sem a necessidade de instalação de outras ferramentas como o `tkn`.

Exemplo do manifesto do `taskrun`.

```yaml:src/taskrun-exemplo1.yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: taskrun-exemplo1
spec:
  taskRef:
     name: task-exemplo1
```

E para executar utilize o comando do `kubectl`:

```bash
kubectl apply -f taskrun-exemplo1.yaml
taskrun.tekton.dev/taskrun-exemplo1 created
```

## Entradas


### Parâmetros
Para uma `Task`, pode ser especificado parâmetros de entradas, que são utilizados como flags de compilação ou para mudar o comportamento da `Task` conforme o seu valor.

Os nomes dos parâmetros devem ser criados seguindo a seguinte regra:

* Deve conter apenas caracteres alfanuméricos, hifens (-), sublinhados (_) e pontos (.).
* Deve começar com uma letra ou um sublinhado (_).

Além do nome deve ser definido o `type`, que pode ser um `array` ou uma `string`.

```yaml:src/task-exemplo2.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: task-exemplo2-params
spec:
  params:
    - name: build-args
      type: array
      description: Build argumentos
    - name: buildImage
      type: string
      description: imagem para build
      default: ubuntu
  steps:
    - name: step1
      image: $(params.buildImage)
      args: ["$(params.build-args[*])"]
```      

```yaml:src/taskrun-exemplo2.yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: taskrun-exemplo2
spec:
  params:
    - name: build-args
      value:
        - 'ls'
        - '- l /'
    - name: buildImage
      value: centos
  taskRef:
     name: task-exemplo2
```

```bash
 tkn task  start task-exemplo2 -p buildImage='python' -p build-args='-c','import sys; print("Ola Mundo"); print(sys.version)'
```

## Configurações

### StepTemplate

### Timeout

### Onerror

### Sidecars

### Volumes

### Input e Output

### Workspaces

## Criando a tasks do Projeto