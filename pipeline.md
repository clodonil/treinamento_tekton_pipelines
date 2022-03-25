Criando Pipelines
================
## Objetivo

Ao final deste modulo você será capaz de:
* Entenda como estruturar uma pipeline no Tekton
* Entenda como criar pipelines parametrizável 


## Conceito

No Tekton, uma pipeline é uma coleção de task organizada por ordem específica de execução como parte da entrega de software. As tasks podem ser executadas em paralelo ou sequencial.


### Pipeline e PipelineRun
Enquanto as `Pipeline` define um `template` com o fluxo definido da pipeline, o `PipelineRun` é uma execução de uma `Pipeline`. O histórico de execução e os logs estão registrados no `PipelineRun` para rastreabilidade.

![template](img/image16.png)


A estrutura básica de criação da `Pipeline` é simples. 

No campo `tasks` são definidos os nome da que será apresentado na pipeline e o `taskref` é o apontamento para uma `Tasks` existente.

Segue um exemplo bem simples.

![template](img/image15.png)

É importante sempre desenvolver `Pipeline` parametrizável para atender multiplas linguagens e situações.

## Entradas

Como entrada de informação na `Pipeline`, podemos utilizar `parameters` ou `workspaces`.

E durante o desenvolvimento da `Pipeline` temos que definir os parâmetros de entrada. Esse parâmetros podem ser utilizadas de vários formas, como executar ou não uma `Tasks` ou como passagem de parâmentro para uma `Tasks`.

### Parameters

Como entrada de informação vamos começar pelo parâmetro. No exemplo abaixo, temos o primeiro bloco que definir o parâmetro de entrada da pipeline. Portanto ao executar a pipeline é obrigarório a sua declaração.

Esse parâmetro pode ser utilizado como entrada em uma `Tasks` conforme o exemplo do segundo bloco de código.

![template](img/image17.png)

No arquivo [src/pipeline/pipeline-exemplo1.yaml](./src/pipeline/pipeline-exemplo1.yaml), temos um exemplo funcional da pipeline e como receber o parâmetro e passar para a `Tasks`.

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
    - name: exemplo2
      params:
        - name: buildImage
          value: $(params.IMAGE)
        - name: build-args
          value: 
             - "$(params.command)"
      taskRef:
        name:   task-exemplo2
```
Para esse exemplo funcionar, é necessário criar as tasks [src/task-exemplo1.yaml](./src/task-exemplo1.yaml) e [src/task-exemplo2.yaml](./src/task-exemplo2.yaml).

```bash
kubectl apply -f src/task-exemplo1.yaml
kubectl apply -f src/task-exemplo2.yaml
kubectl apply -f src/pipeline-exemplo1.yaml
```
E para executar a pipeline, podemos utilizar o comando `tkn`:

```bash
 tkn pipeline  start pipeline-exemplo1 -p IMAGE='centos' -p command='ls','-l /'
```
Execução da pipeline.

![template](img/image18.png)

### Workspaces



## Runafter

A configuração de `Runafter` permite criar fluxo de execução em ordem específica na pipeline. Com ele você que uma `Task` só pode ser executada após outra ter finalizado.

No exemplo abaixo, temos uma a task2 e task3 sendo executado após a execução da task1 e a task4 vai começar a execução após a finalização da task 2 e 3.

![fluxo](img/image19.png)

Um exemplo de código que realiza essa implementação (src/pipeline/pipeline-exemplo2.yaml)[.src/pipeline/pipeline-exemplo2.yaml].

```yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: pipeline-exemplo1
spec:
  tasks:
    - name: task1
      taskRef:
        name: task1

    - name: task2
      taskRef:
        name: task2
      runAfter:
         - task1    

    - name: task3
      taskRef:
        name: task3
      runAfter:
         - task1    

    - name: task4
      taskRef:
        name: task4
      runAfter:
         - task2
         - task3  
```

Para executar esse exemplo:

```bash
kubectl apply -f src/task-exemplo3.yaml
kubectl apply -f src/pipeline/pipeline-exemplo2.yaml
```

## From

Se Taskvocê Pipelineprecisar usar a saída de um anterior como entrada, use o parâmetro Task opcional para especificar uma lista de que deve ser executado antes de que requer suas saídas como entrada. Quando seu destino é executado, apenas a versão desejada produzida pelo último nesta lista é usada. O desta saída de saída deve corresponder ao da entrada especificada no que o ingere.fromTasksTaskTaskPipelineResourceTasknamePipelineResourcenamePipelineResourceTask

No exemplo abaixo, o deploy-app Taskingere a saída do build-app Tasknamed my-imagecomo sua entrada. Portanto, o build-app Taskserá executado antes do deploy-app Taskindependentemente da ordem em que eles Tasksforem declarados no Pipeline.

![fluxo](img/image20.png)
## Timeout
## Retry
## Volumes
## Custom Tasks
## Finally

