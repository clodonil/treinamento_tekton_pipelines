Criando Tasks
================
## Objetivo

Ao final deste modulo você será capaz de:
* Entender o que é uma Task
* Entender como clonar um projeto git e compilação usando o Task
* Entender como funciona os Workspaces
* Criar uma task de build 
* Executar uma Tasks

## Clone do projeto

Para execução desse módulo, é necessário clonar o repositório do treinamento e configurar a variável de ambiente, caso ainda não tenha feito.

```bash
git clone https://github.com/clodonil/treinamento_tekton_pipelines.git
export TREINAMENTO_HOME="$(pwd)/treinamento_tekton_pipelines"
cd $TREINAMENTO_HOME
```

## Conteúdo:
> 1. Conceito
>   1.1. Task e TaskRun
> 2. Tasks e Step
> 3. Parâmetros
> 4. StepTemplate
> 5. Timeout
> 6. Volumes
> 7. Workspaces
> 8. Sidecars
> 9. Results
> 10. onError

## 1. Conceito 

A `Task` é uma coleção de `Steps` que são organizados em ordem de execução como parte de pipeline de `integração continua`. A `Task` é executado da mesma forma que um pod no cluster do Kubernetes, onde cada `Step` se torna um contêiner em execução do pod.

![dashboard](img/image2.png)

Os `Steps` são executados sequencialmente conforme foram criados e cada um deles pode conter uma imagem de pod diferente. Basicamente um `step` deve receber uma entrada, processar algo especifico e gerar um saída.

### 1.1. Task e TaskRun
Enquanto as `Task` define um `template` de execução de tarefas e passos, o `TaskRun` é uma execução de uma `Tasks`. O histórico de execução e os logs estão registrados no `TaskRun` para rastreabilidade.

![taskrun](img/image5.png)

Dessa forma uma `Task` pode ser generica suficiente para executar a mesma tarefa para diferentes linguagens com regras de execução e históricos de execução individualizada para cada `TaskRun`.


## 2. Tasks e Step

Agora que já sabemos o que é `Task`, `Taskrun` e `Steps`, vamos executar o nossa primeira `Task`.
Como primeiro exemplo, vamos criar um `Task` com o nome `task-exemplo1` que contém 3 `Steps`. Nesse exemplo, a `Task` não recebe nenhum parâmetro de entrada e não gera nenhum saída. Ela basicamente executa os comandos definidos dentro do campo `script`.

Vamos começar pelo arquivo [task-exemplo1.yaml](src/task-exemplo1.yaml), conforme abaixo.

Os campos que você deve observar dentro do steps:

* name: Nome do steps
* image: Imagem que será executada o steps
* script: Comandos de execução

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

A criação da `Task` no kubernetes, segue o mesmo padrão da aplicação de qualquer manifesto no cluster.

Conforme realizado abaixo

```bash
kubectl apply -f $TREINAMENTO_HOME/src/task-exemplo1.yaml
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
tkn task start task-exemplo1 --showlog
TaskRun started: task-exemplo1-run-dhcxj

In order to track the TaskRun progress run:
tkn taskrun logs task-exemplo1-run-dhcxj -f -n default
```

A criação do manifesto `yaml` permite você trabalhar nativamente com o `kubernetes`, sem a necessidade de instalação de outras ferramentas como o `tkn`.

Exemplo do manifesto do `taskrun` no arquivo arquivo [taskrun-exemplo1.yaml](src/taskrun-exemplo1.yaml) .

```yaml:src/taskrun-exemplo1.yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: taskrun-exemplo1
spec:
  taskRef:
     name: task-exemplo1
```

E para executar utilize o comando do `kubectl`:

```bash
kubectl apply -f $TREINAMENTO_HOME/src/taskrun-exemplo1.yaml
taskrun.tekton.dev/taskrun-exemplo1 created
```
Pode consultar a execução utilizando o dashboard ou via `tkn`:

```bash
tkn taskrun list
NAME               STARTED        DURATION     STATUS
taskrun-exemplo1   1 minute ago   27 seconds   Succeeded
```

### 3.  Parâmetros
Para uma `Task`, pode ser especificado parâmetros de entradas, que são utilizados como flags de compilação ou para mudar o comportamento da `Task` conforme o seu valor.

Os nomes dos parâmetros devem ser criados seguindo as regra:

* Deve conter apenas caracteres alfanuméricos, hifens (-), sublinhados (_) e pontos (.).
* Deve começar com uma letra ou um sublinhado (_).

Além do nome, deve ser definido o `type` do parâmetro que pode ser:
* `array` : Uma lista de argumentos é passado para a `Tasks`;
* `string`: Apenas um argumento é passado para a `Tasks`.

Abaixo temos uma `Tasks` que recebe como entrada 2 parâmetros que são o `build-args` que é um `array` e o `buildImage` que é do tipo `string`.
A ideia é criar uma `Tasks` que funciona como template para passagem de parâmetro para definir a imagem e os comandos que devem ser executados.

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

Aplique essa `Tasks` utilizando o comando do `kubectl`.

```bash
kubectl apply -f $TREINAMENTO_HOME/src/task-exemplo2.yaml
```

Com o template da `Task`criado, vamos criar as `Tasksrun` para executar ações diferentes com a mesma `Tasks`.

Na primeira execução, vamos criar a `TaskRun` de forma declarativa e definir como parâmetro os seguintes valores:

* build-args: ('ls -l /')
* buildImage: centos

Vamos usar a imagem docker do `centos` e executar o comando `ls` dentro do container.


```yaml:src/taskrun-exemplo2.yaml
apiVersion: tekton.dev/v1beta1
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
Pode aplicar o `Taskrun` e acompanhar a execução do modelo declarivo e acompanhar a execução.

```bash
kubectl apply -f $TREINAMENTO_HOME/src/taskrun-exemplo2.yaml
```

Na segunda execução, vamos criar a `Taskrun` pelo CLI (tkn) e passar os seguintes valores como parâmetros.

* build-args: -c import sys; print("Ola Mundo"); print(sys.version)
* buildImage: python


```bash
tkn task  start task-exemplo2 -p buildImage='python' -p build-args='-c','import sys; print("Ola Mundo"); print(sys.version)'  --showlog
```

Nessa execução, estamos utilizando uma imagem python para mostrar o  "Ola Mundo" e mostrar a versão. Acompanhe as execuções no dashboard do Tekton para verificar o resultado.

Dessa forma vimos na prática como passar parâmetros para uma `Tasks`.

## 4. StepTemplate
Um recurso muito interessante na `Tasks` para evitar repetição de código é o `StepTemplate`. Dessa forma podemos declarar as funções padrões para todos os `Steps`, evitando assim ficar repetindo código.

Por exemplo, podemos declarar a imagem padrão dos `Steps` e também os recursos de cpu e memória, conforme especificado no arquivo [task-exemplo4.yaml](src/task-exemplo4.yaml) mostrado abaixo.

```yaml:src/task-exemplo4.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: task-exemplo4
spec:
  stepTemplate:
    image: ubuntu  
    securityContext:
      runAsNonRoot: false
      runAsUser: 1001     
    resources:
        requests:
          memory: 128Mi
          cpu: 250m
        limits:
          memory: 512Mi
          cpu: 300m
  steps:
    - name: step1
      script: |
        #!/usr/bin/env bash
        echo "Execunto Step1"
        cat /etc/os-release
        echo "Finalizado"
    - name: step2
      image: centos
      script: |
        #!/usr/bin/env bash
        echo "Execunto o Step2"
        cat /etc/os-release
        echo "Finalizado"
```

Nesse exemplo, todos os `Steps` que não definir uma imagem base, vai utilizar a imagem do `ubuntu`, a mesma coisa para memória e cpu.

vamos criar a task:

```bash
kubectl apply -f $TREINAMENTO_HOME/src/task-exemplo4.yaml
```

Agora vamos criar a taskRun e aguardar a execução com o `tkn`:

```bash
 tkn task start task-exemplo4 --showlog
 ```

## 5. Timeout

Outra configuração importantes para serem utilizadas  na `Tasks` é o `timeout`. Com essa configuração você define o tempo máximo da execução de um `Step`.

Exemplo:
```yaml
  steps:
    - name: build
      timeout: 1h
      image: centos  
      script: |
        #!/usr/bin/env bash
        echo "Execunto o build"
        sleep 120
        cat /etc/os-release
        echo "Finalizado"
```        

 
## 6. Volumes
Para uma `Task` pode ser definido um ou mais `volumes` para manipulação de dados entre os `Steps`.

Podemos usar `volumes` para o seguinte propósito:

* Montar um kubernetes `Secret` dentro da Task e Steps;
* Crie um volume `emptyDir` para armazenar cache de dados para multi `Steps`;
* Monte um Kubernetes `ConfigMap`;
* Montar um volume do kubenetes para persistir dados das Tasks e Steps

No exemplo do arquivo [task-exemplo5.yaml](src/task-exemplo5.yaml), abaixo, é criado na `Tasks` com o volume `emptyDir` para compartilhar dados entre o step1 e o step2. Esse volume vai existir apenas durante a execução do Task.

No primeiro step é criado um arquivo com o conteúdo do site do google e no step2 é listado o conteúdo do arquivo, comprovando a troca dos arquivos utilizando o volume.

O parâmetro `volumeMounts` que define o nome do volume o ponto de montagem. 

```yaml:src/task-exemplo5.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: task-exemplo5
spec:
  steps:
    - name: step1
      image: centos
      script: |
        #!/usr/bin/env bash
        curl https://www.google.com > /var/my-volume/site1.txt
      volumeMounts:
        - name: my-volume
          mountPath: /var/my-volume
    - name: step2
      image: ubuntu
      script: |
        #!/usr/bin/env bash
        cat /etc/my-volume/site1.txt
        ls -l /etc/my-volume  
      volumeMounts:
        - name: my-volume
          mountPath: /etc/my-volume
  volumes:
    - name: my-volume
      emptyDir: {}
```
Para criar a task:

```bash
kubectl apply -f $TREINAMENTO_HOME/src/task-exemplo5.yaml
```
E para executar vamos utilizar o tkn:

```bash
tkn task start task-exemplo5 --showlog
```

## 7. Workspaces
Workspaces permitem especificar um ou mais `volumes` nas Task necessários durante a execução.

Os parâmetros para especificar um Workspace são:

* `name`: Esse campo é requirido, é o nome da Workspace;
* `description`: Descrição do uso da workspace
* `readOnly`: Um campo `boolean` que define que o Workspace vai ser apenas para leitura (não permite gravar). Por padrão é falso.
* `optional`: Um campo `boolean` que indica que a Taskrun pode omitir a declaração da workspace. Por padrão é falso.
* `mountPath`: É o path a onde o workspace vai estar localizado no disco. Se um path não foi atribuido o padrão é/workspace/<name>.

Como exemplo da utilização do Workspace, vamos criar um volume do tipo `PersistentVolumeClaim` com o tamanho de 1Gi. 

Aplique a configuração do arquivo [pv-exemplo8.yaml](src/pv-exemplo8.yaml) para criar o volume.

```yaml:src/pv-exemplo8.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Criando o volume:

```bash
kubectl apply -f $TREINAMENTO_HOME/src/pv-exemplo8.yaml
```

Com o volume criado, vamos criar a `Tasks`, que basicamente tem a função de criar arquivos dentro do Workspace.

O arquivo [task-exemplo8.yaml](src/task-exemplo8.yaml) abaixo, apresenta a entrada do workspace com o nome `myworkspace` e o ponto de montagem nos steps no caminho `/dados`.

Tasks basicamente cria um arquivo com o timestemp no diretório. Toda vez que executar a taskrun vai ser criado um novo arquivo, comprovando que os mesmo estão sendo persitidos no volume.

```yaml:src/task-exemplo8.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: task-exemplo8
spec:
  workspaces:
    - name: myworkspace
      optional: true
      description: The folder where we write the message to
      mountPath: /dados
  steps:
    - name: step1
      image: ubuntu
      script: |
        #!/usr/bin/env bash
        touch /dados/file-$(date "+%Y.%m.%d-%H.%M.%S")
        echo "Finalizado"
    - name: step2
      image: ubuntu
      script: |
        #!/usr/bin/env bash
        ls -l /dados
        echo "Finalizado"

```

Para executar a `tasks` é necessário passar o nome do workspace e o volume.

Vamos criar a Tasks:
```bash
kubectl apply -f $TREINAMENTO_HOME/src/task-exemplo8.yaml
```
Agora vamos executar o taskrun passando como parâmetro o workspace.

```bash
tkn task start task-exemplo8  -w name=myworkspace,claimName=mypvc --showlog
```
Execute várias vezes esse comando e veja o número de arquivos criados.

## 8. Sidecars
Em uma `Task` é possível especificar o campo de `sidecars`, que basicamente instância um container ao lado dos `steps` que pode fornecer funções auxiliares.

Você pode utilizar o `sidecars` para:
* Utilizar Docker in Docker;
* Executar um servidor de API simulando que seu aplicativo pode acessar durante o testes;

O `Sidecars` é iniciado antes dos `Steps` e excluidos após a conclusão da execução das tasks.

Como exemplo, vamos executar uma image de um servidor web (ex: nginx) no `sidecars`, simulando aplicação, e no `Step` vamos executar o k6 para teste de performance.

O arquivo [task-exemplo6.yaml](src/task-exemplo6.yaml) abaixo temos o exemplo do sidecars sendo executado na tasks.

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: task-exemplo6
spec:
  params:
     - name: image
       type: string
  steps:
    - name: test-carga
      image: loadimpact/k6
      script: |
        cat <<EOF >>test.js
        import http from 'k6/http';
        import { sleep } from 'k6';
        export default function () {
            http.get('http://localhost');
            sleep(1);
        }
        EOF
        k6 run test.js 
  sidecars:
    - image: $(params.image)
      name: server
```

Vamos criar a task:

```bash
kubectl apply -f $TREINAMENTO_HOME/src/task-exemplo6.yaml
```
Agora vamos executar a taskrun:

```bash
tkn task start task-exemplo6 -p image=nginx --showlog
```

## 9. Results

Uma `Task` é capaz de emitir resultados em formato de `string` que podem ser visualizados pelos usuários e passados ​​para outras tarefas em uma pipeline.
Ao ser declarado um `result`, o path do arquivo é criado automaticamente.
É importante observar que o `Tekton` não realiza nenhum processamento no conteúdo dos `results`, eles são emitidos literalmente de sua `Task`, incluindo quaisquer caracteres de espaço em branco à esquerda ou à direita.

Para exemplificar o uso do `results` vamos utilizar o mesmo exemplo utilizado no `sidecars` e vamos exportar o resultado do report do k6.

O arquivo [task-exemplo7.yaml](src/task-exemplo7.yaml) abaixo temos o exemplo do `result`.


```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: task-exemplo7
spec:
  params:
     - name: image
       type: string
  results:
     - name: k6-report
       description: Resultado do teste de performance
  steps:
    - name: test-carga
      image: loadimpact/k6
      script: |
        cat <<EOF >>test.js
        import http from 'k6/http';
        import { sleep } from 'k6';
        export default function () {
            http.get('http://localhost');
            sleep(1);
        }
        EOF
        k6 run --out json=test.json --summary-trend-stats="min,avg,med,p(99),p(99.9),max,count" --summary-time-unit=ms test.js 
        grep 'Point' test.json | head -n 1| tee $(results.k6-report.path)

  sidecars:
    - image: $(params.image)
      name: server
```

Vamos criar a tasks:

```bash
kubectl apply -f $TREINAMENTO_HOME/src/task-exemplo7.yaml
```

Agora vamos executar a taskrun:

```bash
tkn task start task-exemplo7 -p image=nginx --showlog
```
Você pode ver o `result` via dasboard.

![dashboard](img/image49.png)

Também é possível ver o `result` via tkn:

```bash
tkn taskrun describe -L
```

## 10. onError

Uma `Task` pode finalizar com sucesso ou com falha. No fluxo de uma pipeline, uma `Tasks` com falha determina a paralização de toda a pipeline. Para casos especificos, podemos configurar o `onError` para determinar que mesmo com falha a `Tasks` deve ser finaliaza com sucesso para continuar a execução da pipeline.

`Onerror` define o que acontece com o `Step`em caso de falha. Por padrão em caso de falha a execução é parada e os `Steps`seguintes não são executados. 

Para mudar esse comportamento podemos usar o `onerror`:

 > *  `onError: continue` : Em caso de falha, a execução continua e para saber o status da execução é necessário consultar o exit code.
 > *  `onerror: stopAndFail` : Em caso de falha, a execução dos `Steps` seguintes  é interrompida (padrão).


Segue o exemplo de configuração do `onError` no arquivo [task-exemplo11.yaml](/src/task-exemplo11.yaml):

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: task-exemplo11
spec:
  steps:
    - name: step1
      onError: continue
      image: ubuntu      
      script: |
        #!/usr/bin/env bash
        echo "Execunto Step1"
        echo "Finalizado"
```
Vamos criar a task:

```bash
kubectl apply -f $TREINAMENTO_HOME/src/task-exemplo11.yaml
```

Agora podemos executar a taskrun:

```bash
tkn task start task-exemplo11 --showlog
```

No Dashboard é possível verificar o status da execução da tasks:

![onError](img/image23.png)

Através da variável `$(steps.step-<step-name>.exitCode.path)` é possível obter o código de erro dos steps anteriores. Essa informação é importante para tomada de decisão no step atual.

No exemplo [task-exemplo12.yaml](/src/task-exemplo11.yaml), temos uma situação que o step2 mostra o resultado do step de acordo com variável `$(steps.step-<step-name>.exitCode.path)`. Para o exemplo ficar mais interessante, estamos passando como parâmetro o status code do step1. Assim podemos simular o sucesso (status code = 0) e a falha (status code = 1).

Segue o código do [task-exemplo12.yaml](/src/task-exemplo11.yaml).

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: task-exemplo12
spec:
  params:
     - name: step1_status_code
       type: string
  steps:
    - name: step1
      onError: continue
      image: ubuntu      
      script: |
        #!/usr/bin/env bash
        echo "Execunto Step1"
        echo "Finalizado"
        exit $(params.step1_status_code)
    - name: step2
      image: ubuntu      
      script: |
        #!/usr/bin/env bash
        echo "Execunto Step2"
        step1="Finalizou com sucesso"
        result_step1=`cat $(steps.step-step1.exitCode.path)`
        if [ ${result_step1} -ne 0 ]; then step1="Finalizou com falha"; fi
        echo "O step 1 finalizou com $step1"
        echo "Finalizado"        
```

Vamos criar a task:

```bash
kubectl apply -f $TREINAMENTO_HOME/src/task-exemplo12.yaml
```
Primeiramente vamos executar a task passando o `status code` do step1 como sucesso (0).

```bash
 tkn task start task-exemplo12 -p step1_status_code=0 --showlog
```
Como resultado da execução:

```bash
TaskRun started: task-exemplo12-run-rhqtq
Waiting for logs to be available...
[step1] Execunto Step1
[step1] Finalizado

[step2] Execunto Step2
[step2] O step 1 finalizou com Finalizou com sucesso
[step2] Finalizado
```
O step2 consultou o `status code` do step1 e afirmou que o mesmo finalizou com sucesso.

Agora vamos simular uma falha no step1.

```bash
 tkn task start task-exemplo12 -p step1_status_code=1 --showlog
```

Como resultado da execução:

```bash
TaskRun started: task-exemplo12-run-k4lfk
Waiting for logs to be available...
[step1] Execunto Step1
[step1] Finalizado

[step2] Execunto Step2
[step2] O step 1 finalizou com Finalizou com falha
[step2] Finalizado
```
Agora o step2 consultou o resultado do `status code` do step1 e afirmou que o mesmo finalizou com falha.
