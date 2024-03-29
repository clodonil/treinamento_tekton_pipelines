Triggers
================
## Objetivo

Ao final deste modulo você será capaz de:
* Entender como as triggers no tekton funcionam;
* Como criar uma trigger baseado em evento do repositório;

## Clone do projeto

Para execução desse módulo, é necessário clonar o repositório do treinamento e configurar a variável de ambiente, caso ainda não tenha feito.

```bash
git clone https://github.com/clodonil/treinamento_tekton_pipelines.git
export TREINAMENTO_HOME="$(pwd)/treinamento_tekton_pipelines"
cd $TREINAMENTO_HOME
```

## Pré-Requisito

Para realizar a criação das triggers é necessário ter as pipelines criadas, portanto realize o módulo [5.1. Desenvolvimento das pipelines](pipeline-dev.md).

## Conteúdo:
> 1. Trigger<br/>
>  1.1 EventListener<br/>
>  1.1.1 Interceptor<br/>
>  1.2 Trigger-Bindings<br/>
>  1.3 Trigger-Template<br/>
> 2. Instalação do trigger
> 3. Instalando o gitea
> 4. Criar os repositórios e WebHook
> 5. Inicializando o repositório<br/> 
>  5.1 SharedLibrary<br/>
>  5.2 Aplicação (app1-python)<br/>
> 6. Criando conta de serviço
> 7. Evento
> 8. Criando trigger para a SharedLibrary<br/>
>  8.1 EventListener para SharedLibrary<br/>
>  8.2 Binding para SharedLibrary<br/>
>  8.3 Template para SharedLibrary<br/>
>  8.4 Criação do webhook e testando<br/>
> 9. Pipeline de aplicação (microservice)<br/>
>  9.1 EventListener para pipeline de aplicação<br/>
>  9.2 Binding para pipeline de aplicação<br/>
>  9.3 Template para pipeline de aplicação<br/>
>  9.4 Criação do webhook e testando<br/>



## 1.Trigger

As Triggers são componentes do Tekton que permite detectar e extrair informações de eventos de uma variedade de fontes, tais como `repositório git`, `Docker Registry` e `PubSub`. E com essas informações, executar `TasksRun` e `PipelineRun`.

Os Tekton Triggers também podem passar informações extraídas de eventos diretamente para `TaskRuns` e `PipelineRuns`.

A criação da trigger no tekton, envolve a criação dos seguintes componentes:

* EventListener
* Trigger-Bindings
* Trigger-Template

Vamos ver cada um com mais detalhes.

### 1.1 EventListener
O componente de `EventListener` escuta eventos em uma porta especificada através de um `Pod` em execução. Também é no `EventListener` que são especificada os arquivos de `TriggerBinding` e `TriggerTemplate` que são acionados quandos um evento é detectado.

Quando um evento é detectado, antes de passar para os processos de `TriggerBinding` e `TriggerTemplate` é possível passar pelo `Interceptor` que pode realizar filtros e manipulações no evento.

#### 1.1.1 Interceptor
O `Interceptor` é um processador de eventos que fica dentro do `EventListener`.  O `EventListener` recebe o eventos completo e antes de enviar para o `binding` é possível executar filtragem do evento, verificação (usando um segredo), transformação, defina e teste condições de trigger e outros processamentos úteis. 

Depois que os dados do evento passam por um `interceptor`, eles vão para o `TriggerBinding` e `TriggerTemplate`.

### 1.2 Trigger-Bindings
O `Trigger-Binding` especifica os campos do evento dos quais você deseja extrair dados. Esses dados entram no `TriggerTemplate` como parâmetros dos valores extraídos. 

Você pode então usar os campos preenchidos no `TriggerTemplate` para preencher campos no arquivo associado `TaskRun` ou `PipelineRun`.

### 1.3 Trigger-Template
O `TriggerTemplate` recebe os parâmetros do `Trigger-Binding` para inicializar os recursos de `TaskRun` ou `PipelineRun`. 

Ele expõe parâmetros que você pode usar em qualquer lugar dentro do modelo do seu recurso.

Abaixo um modelo da estrutura da triggers.

![trigger](img/image44.png)


## 2. Instalação do trigger

Agora que sabemos o que são as triggers e os seus componentes, vamos instalar os componentes. E para isso execute os seguintes comandos:

```bash
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
```
Aguarde até todos os serviços estarem em `running`, conforme abaixo.

```bash
kubectl get pods --namespace tekton-pipelines 
NAME                                                READY   STATUS    RESTARTS   AGE
tekton-dashboard-57cf45447c-fmcgw                   1/1     Running   0          3h33m
tekton-pipelines-controller-5cfb9b8cfc-ppg4r        1/1     Running   0          3h33m
tekton-pipelines-webhook-6c9d4d5798-4jfl8           1/1     Running   0          3h33m
tekton-triggers-controller-668df9f855-vpgjc         1/1     Running   0          46s
tekton-triggers-core-interceptors-55d8cfbd6-dq775   1/1     Running   0          44s
tekton-triggers-webhook-55574b569b-nscvl            1/1     Running   0          46s
```

## 3. Instalando o gitea

Nesse módulo vamos utilizar os eventos de origem como sendo um repositório do git. E para isso vamos utilizar o `gitea` que um repositório leve com as funcionalidades que precisamos.

Entretanto, todos os conceitos e funcionamento funcionam para qualquer outro repositório de git.

Vamos instalar o `gitea` dentro do `namespace` tools, e para isso é necessário criar, conforme o comando abaixo.  

Os arquivo para instalar o `gitea` no kubernetes são:

* [deployment.yaml](./proj/trigger/gitea/deployment.yaml): Utilizado para definir a imagem do `gitea` e os parâmetros de inicialização;
* [service.yaml](./proj/trigger/gitea/service.yaml): Utilizado para criar o service do `gitea`

O comando de `kubectl` abaixo aplica os 2 arquivos que estão no diretório do `gitea`.

```bash
kubectl create namespace tools
kubectl -n tools apply -f $TREINAMENTO_HOME/proj/trigger/gitea/
```

Aguarde até o serviço ficar no status de `running`.

```bash
kubectl get pods -n tools
NAME                     READY   STATUS    RESTARTS   AGE
gitea-8554476b8b-mm6gc   1/1     Running   0          27s
```

Agora você pode acessar o `gitea` na url: http://localhost:30005/.

Ao acessar o `gitea` pela primeira vez, é necessário configurar. Abaixo temos as principais configurações que são:

* **Dominio do servicoe SSH:** Nesse campo é necessário especificar o endereço IP da interface de rede. Não utilize o `localhost`.
* **Url base do gitea:** Nesse campo é necessário informar a URL de acesso. É basicamente composto do endereço IP da interface de rede e a porta 30005 definido no `kind`.
* **Dados do administrador:** Nome e senha do usuário administrador do gitea

![trigger](img/image40.png)

Se estiver utilizando o `Linux`, para saber qual é o número IP da interface de rede, utilize o comando `ip address show`.

![trigger](img/image42.png)

## 4. Criar os repositórios e WebHook

Crie as variáveis de ambiente com o usuário e senha criado no `gitea` e o endereço de acesso.

```bash
export USER='XXXX'
export PASS='XXXX'
export GIT='http://xxx.xxx.xxx.xxx:30005'
```
Agora podemos criar os repositórios de código no `gitea` que será utilizado para armezanar os código da aplicação e da sharedlibrary do projetos. Nesses repositórios serão configurados as triggers e qualquer alteração no código as pipelines associadas será inicializada automaticamente.

> A criação dos repositórios podem ser realizados pela `interface web`, entretanto criamos o `script` abaixo para facilitar a utilização.   

Segue os parâmetros utilizados no `gitea_cli.py`:
* `-n`: Cria um novo repositório
* `-r`: Especifica o nome do repositório
* `-u`: Usuário utilizado para fazer o login no `gitea`
* `-p`: Senha do usuário do `gitea`

```bash
python3 $TREINAMENTO_HOME/proj/trigger/gitea/gitea_cli.py -n -r sharedlibrary -u $USER -p $PASS
python3 $TREINAMENTO_HOME/proj/trigger/gitea/gitea_cli.py -n -r app1-python -u $USER -p $PASS
```
Confirme no `gitea` se os repositórios foram de fato criados corretamente, conforme a imagem abaixo.

![trigger](img/image48.png)


## 5. Inicializando o repositório 

Com o respositórios criados, vamos popular com códigos de exemplos para serem utilizadas na pipelines do `tekton`.

  ### 5.1 SharedLibrary

No repositório da `SharedLibrary` no `gitea` vamos armazenar os scripts de execução dos `steps` da pipeline. No diretório [src/sharedlibrary](src/sharedlibrary/) tem um exemplo de scripts e vamos utilizar eles para popular o repositório.

```bash
cd $TREINAMENTO_HOME/src/sharedlibrary
git init
git add *
git commit -m "first commit"
git remote add origin $GIT/user1/sharedlibrary.git
git push -u origin master
```

### 5.2 Aplicação (app1-python)

No repositório da aplicação `app1-python` no `gitea` vamos armazenar uma aplicação de exemplo em python para execução na pipeline.

```bash
cd $TREINAMENTO_HOME/src/app1-python
git init
git add *
git commit -m "first commit"
git remote add origin $GIT/user1/app1-python.git
git push -u origin master
```

## 6. Criando conta de serviço

Precisamos criar uma conta de serviço no Kubernetes para atribuir as permissões necessárias para a triggers conseguirem acessar os objetos da pipelines.

O arquivo [rbac.yaml](proj/trigger/rbac.yaml) contém o manifesto com as permissões definidas.

```bash
kubectl apply -f $TREINAMENTO_HOME/proj/trigger/rbac.yaml
```

## 7. Evento

O repositório de origem envia um evento no formato de `json` para o `tekton`. Abaixo temos um exemplo de evento que pode ser gerado. 

O trigger pode utilizar todos os campos do evento para tomada de decisão ou como parâmetros da pipeline e também durante o `EventListener` pode ser manipulado esse evento adicionando novos campos que serão utilizados no binding.

```json
{
  "ref": "refs/heads/master",
  "before": "a4bfa24015149e24d501b6f99229d49ab121f629",
  "after": "a4bfa24015149e24d501b6f99229d49ab121f629",
  "compare_url": "",
  "commits": [
    {
      "id": "a4bfa24015149e24d501b6f99229d49ab121f629",
      "message": "first commit\n",
      "url": "http://localhost:3000/user1/app1/commit/a4bfa24015149e24d501b6f99229d49ab121f629",
      "author": {
        "name": "Clodonil Trigo",
        "email": "clodonil@nisled.org",
        "username": ""
      },
      "committer": {
        "name": "Clodonil Trigo",
        "email": "clodonil@nisled.org",
        "username": ""
      },
      "verification": null,
      "timestamp": "0001-01-01T00:00:00Z",
      "added": null,
      "removed": null,
      "modified": null
    }
  ],
  "head_commit": {
    "id": "a4bfa24015149e24d501b6f99229d49ab121f629",
    "message": "first commit\n",
    "url": "http://localhost:3000/user1/app1/commit/a4bfa24015149e24d501b6f99229d49ab121f629",
    "author": {
      "name": "Clodonil Trigo",
      "email": "clodonil@nisled.org",
      "username": ""
    },
    "committer": {
      "name": "Clodonil Trigo",
      "email": "clodonil@nisled.org",
      "username": ""
    },
    "verification": null,
    "timestamp": "0001-01-01T00:00:00Z",
    "added": null,
    "removed": null,
    "modified": null
  },
  "repository": {
    "id": 1,
    "owner": {"id":1,"login":"user1","full_name":"","email":"user1@localhost","avatar_url":"http://localhost:3000/user/avatar/user1/-1","language":"","is_admin":false,"last_login":"0001-01-01T00:00:00Z","created":"2022-06-21T00:43:25Z","restricted":false,"active":false,"prohibit_login":false,"location":"","website":"","description":"","visibility":"public","followers_count":0,"following_count":0,"starred_repos_count":0,"username":"user1"},
    "name": "app1",
    "full_name": "user1/app1",
    "description": "",
    "empty": false,
    "private": false,
    "fork": false,
    "template": false,
    "parent": null,
    "mirror": false,
    "size": 20,
    "html_url": "http://localhost:3000/user1/app1",
    "ssh_url": "git@localhost:user1/app1.git",
    "clone_url": "http://localhost:3000/user1/app1.git",
    "original_url": "",
    "website": "",
    "stars_count": 0,
    "forks_count": 0,
    "watchers_count": 1,
    "open_issues_count": 0,
    "open_pr_counter": 0,
    "release_counter": 0,
    "default_branch": "master",
    "archived": false,
    "created_at": "2022-06-21T00:44:00Z",
    "updated_at": "2022-06-21T00:46:14Z",
    "permissions": {
      "admin": false,
      "push": false,
      "pull": false
    },
    "has_issues": true,
    "internal_tracker": {
      "enable_time_tracker": true,
      "allow_only_contributors_to_track_time": true,
      "enable_issue_dependencies": true
    },
    "has_wiki": true,
    "has_pull_requests": true,
    "has_projects": true,
    "ignore_whitespace_conflicts": false,
    "allow_merge_commits": true,
    "allow_rebase": true,
    "allow_rebase_explicit": true,
    "allow_squash_merge": true,
    "default_merge_style": "merge",
    "avatar_url": "",
    "internal": false,
    "mirror_interval": ""
  },
  "pusher": {"id":1,"login":"user1","full_name":"","email":"user1@localhost","avatar_url":"http://localhost:3000/user/avatar/user1/-1","language":"","is_admin":false,"last_login":"0001-01-01T00:00:00Z","created":"2022-06-21T00:43:25Z","restricted":false,"active":false,"prohibit_login":false,"location":"","website":"","description":"","visibility":"public","followers_count":0,"following_count":0,"starred_repos_count":0,"username":"user1"},
  "sender": {"id":1,"login":"user1","full_name":"","email":"user1@localhost","avatar_url":"http://localhost:3000/user/avatar/user1/-1","language":"","is_admin":false,"last_login":"0001-01-01T00:00:00Z","created":"2022-06-21T00:43:25Z","restricted":false,"active":false,"prohibit_login":false,"location":"","website":"","description":"","visibility":"public","followers_count":0,"following_count":0,"starred_repos_count":0,"username":"user1"}
}
```

## 8. Criando trigger para a SharedLibrary

Primeiramente vamos criar a trigger para o repositório `sharedlibrary`. Assim toda vez que tiver alteração no repositório a `TaskRun` vai ser inicializada e atualizar o `workspace` da volume da `SharedLibrary` utilizada pelas pipelines. 


### 8.1 EventListener para SharedLibrary

O primeiro componente que vamos criar é o `EventListener` que vai ouvir e receber os eventos de triggers. O `EventListener` cria um `pod` para essa finalidade.

O `EventListener` pode conter o `Interceptor` para manipular o [evento](#evento) recebido. Nesse caso da `SharedLibrary` não vamos utilizar.

No arquivo [EventListener](proj/trigger/sharedlibrary/EventListener.yaml) os pontos importantes são:

* **bindings:** Define o componente do triggerbinding, que define os parâmetros utilizados do evento
* **template:** Define o componente do template que inicializa a pipeline 

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: tekton-webhook-sharedlibrary
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: tekton-webhook-sharedlibrary
      bindings:
        - ref: tekton-triggerbinding-sharedlibrary
      template:
        ref: tekton-triggertemplate-sharedlibrary
```

Vamos aplicar o arquivo EventListener:

```bash
kubectl apply -f $TREINAMENTO_HOME/proj/trigger/sharedlibrary/EventListener.yaml
```

Agora vamos aguardar o `pod` do `EventListerner` subir. Também foi criado um service para expor o `EventListener` para o mundo externo (**el-tekton-webhook-sharedlibrary**). 

```bash
kubectl get pods,svc
NAME                                                   READY   STATUS    RESTARTS   AGE
pod/el-tekton-webhook-sharedlibrary-7c57fcf9f8-779hr   1/1     Running   0          13s

NAME                                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
service/el-tekton-webhook-sharedlibrary   ClusterIP   10.96.25.243   <none>        8080/TCP,9000/TCP   13s
```
Você pode confirmar a criação do eventlisterner utilizando o `tkn`:

```bash
tkn el list
NAME                           AGE              URL
AVAILABLE
tekton-webhook-sharedlibrary   43 minutes ago   http://el-tekton-webhook-sharedlibrary.default.svc.cluster.local:8080   True
```

### 8.2 Binding para SharedLibrary
 
O componente `Binding` da trigger define quais os campos do [evento](#evento) que serão utilizadas como variável para a pipeline.

No caso da SharedLibrary vamos utilizar os parâmetro `revision` e o `repository` e o value define como obter esses valores no [evento](#evento), conforme definido abaixo.

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: tekton-triggerbinding-sharedlibrary
spec:
  params:
    - name: revision
      value: $(body.repository.default_branch)
    - name: repository
      value: $(body.repository.clone_url)
```

Vamos aplicar o arquivo [trigger-bindings.yaml](proj/trigger/sharedlibrary/trigger-bindings.yaml):

```bash
kubectl apply -f $TREINAMENTO_HOME/proj/trigger/sharedlibrary/trigger-bindings.yaml
```

Você pode confirmar a criação do binding utilizando o `tkn`:

```bash
tkn tb list
NAME                                  AGE
tekton-triggerbinding-sharedlibrary   9 minutes ago
```


### 8.3 Template para SharedLibrary

O componte `template` utiliza os parêmtros definidos no `binding` e inicializa a `TaskRun` com os valores definidos.

Podemos dividir o arquivo de `template` em três partes:

A primeira é a entrada dos parâmetros:
```
  params:
    - name: revision
      description: The git revision
      default: master
    - name: repository
      description: The git repository url
```
A segunda parte é o resource template que vai ser inicializada, nesse caso vamos inicializar uma task com o nome `source`.  No campo `genereteName` é definido o prefixo do nome da `Task`. 

```
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: TaskRun
      metadata:
        generateName: 'sharedlibrary-'
        labels:
          tekton.dev/task: 'source'
```
A terceira e última parte, define os parâmetros que serão utilizadas para inicializar a `task`. Os `values` utilizados deve ser definidos no campo `params` da primeira parte.

```
        taskRef:
          name: source
        params:
          - name: revision
            value: '$(tt.params.revision)'
          - name: url
            value: '$(tt.params.repository)'
        workspaces:
          - name: output
            persistentVolumeClaim:
               claimName: sharedlibrary
```

O arquivo [trigger-template.yaml](proj/trigger/sharedlibrary/trigger-template.yaml) completo com todas as partes.

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerTemplate
metadata:
  name: tekton-triggertemplate-sharedlibrary
spec:
  params:
    - name: revision
      description: The git revision
      default: master
    - name: repository
      description: The git repository url
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: TaskRun
      metadata:
        generateName: 'sharedlibrary-'
        labels:
          tekton.dev/task: 'source'
      spec:
        serviceAccountName: tekton-triggers-sa
        taskRef:
          name: source
        params:
          - name: revision
            value: '$(tt.params.revision)'
          - name: url
            value: '$(tt.params.repository)'
        workspaces:
          - name: output
            persistentVolumeClaim:
               claimName: sharedlibrary
```

Vamos aplicar:


```bash
kubectl apply -f $TREINAMENTO_HOME/proj/trigger/sharedlibrary/trigger-template.yaml
```
Você pode confirmar a criação do binding utilizando o `tkn`:

```bash
tkn tt list
NAME                                   AGE
tekton-triggertemplate-sharedlibrary   10 minutes ago
```

### 8.4 Criação do webhook e testando
 Agora que temos as trigger criadas, vamos cadastrar o service da trigger no webhook do `gitea`, assim todo evento do repositório vai inicializar a pipeline.

 Para consultar o service, execute o seguinte comando.

 ```bash
kubectl get svc
NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
el-tekton-webhook-sharedlibrary   ClusterIP   10.96.190.254   <none>        8080/TCP,9000/TCP   29m
```
Você pode cadastrar o webhook pelo console web do `gitea` ou pode utilizar o script abaixo para fazer isso.

Segue os parâmetros utilizados no `gitea_cli.py`:
* `-w`: Define o service do trigger para o webhook, nesse caso é o **el-tekton-webhook-sharedlibrary**
* `-r`: Especifica o nome do repositório
* `-u`: Usuário utilizado para fazer o login no `gitea`
* `-p`: Senha do usuário do `gitea`

```bash
python3 $TREINAMENTO_HOME/proj/trigger/gitea/gitea_cli.py -w el-tekton-webhook-sharedlibrary -r sharedlibrary -u $USER -p $PASS
```
Consulte a interface web do `gitea` para confirmar que o webhook foi configurado corretamente, conforme abaixo.

![trigger](img/image45.png)

Para validar a configuração, você pode utilizar o campo de teste do webhook ou realizar qualquer `commit` no repositório da sharedlibrary.

É possível acompanhar o log do `pod` `EvenListener` para consultar algum tipo de erro:

```bash
kubectl logs el-tekton-webhook-sharedlibrary-7c57fcf9f8-kst82
```
 E também pode consultar se a `TaskRun` foi criada e executada. Você pode fazer isso pela inteface web conforme a imagem abaixo.

![trigger](img/image43.png)

E também é possível ser feito utilizando o comando `tkn`, conforme abaixo:

```
tkn tr list
NAME                  STARTED         DURATION     STATUS
sharedlibrary-q47nj   3 minutes ago   26 seconds   Succeeded
```

## 9. Pipeline de aplicação (microservice)

Agora que temos a trigger da `sharedlibrary` configurado com sucesso, vamos realizar a configuração da trigger da pipeline de aplicação. É a pipeline que de fato entrega o código.


### 9.1 EventListener para pipeline de aplicação

Muitos dos conceitos do `EventListener` já foram passadas na configuração anterior, o que muda que nesta configuração vamos utilizar o `interceptors` para adicionar novos campo no [evento](#evento) recebido.

Alguns `interceptors` pré-configurados podem ser utilizados como `github`, `bitbucket` e `gitlab`. Consulte a [documentação](https://tekton.dev/docs/triggers/interceptors/) para mais detalhes.

Em nosso caso, vamos utilizar a linguagem de definição [CEL](https://github.com/google/cel-spec/blob/master/doc/langdef.md) para manipular os eventos. Pode consultar a [documentação](https://tekton.dev/docs/triggers/cel_expressions/) do Tekton Interceptors para verificar todas as opções possível.

Antes de mostrar o funcionando do `interceptors` vamos explicar o motivo que vamos utilizar. A pipeline tem como entrada o `runtime` para saber qual linguagem de programação vai ser utilizada. 
E para isso definimos como nome do repositório a seguinte sintaxe, `[appname]-[runtime]`, por isso temos o nome do repositório com `app1-python`.
O `interceptors` vai criar dentro do [evento](#evento) 2 novos campos, sendo o `runtime`e o `appname`.

A expressão para fazer isso é:

* runtime: `body.repository.name.split('-')[1]`    
* appname: `body.repository.name.split('-')[0]`    

No arquivo [EventListeer](proj/trigger/pipeline-microservice/EventListener.yaml) temos o arquivo completo:

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: tekton-webhook-microservice
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: tekton-webhook-microservice
      interceptors:
        - ref:
            name: cel
          params:
          - name: "overlays"
            value:
            - key: runtime
              expression: "body.repository.name.split('-')[1]"    
            - key: appname
              expression: "body.repository.name.split('-')[0]"    
      bindings:
        - ref: tekton-triggerbinding-microservice
      template:
        ref: tekton-triggertemplate-microservice 
```

Vamos aplicar o arquivo EventListener:

```bash
kubectl apply -f $TREINAMENTO_HOME/proj/trigger/pipeline-microservice/EventListener.yaml
```

Agora vamos aguardar o `pod` do `EventListerner` subir. Também foi criado um service para expor o `EventListener` para o mundo externo (**pod/el-tekton-webhook-microservice**). 


```bash
kubectl get pods,svc
NAME                                                   READY   STATUS      RESTARTS   AGE
pod/el-tekton-webhook-microservice-67bf667f45-ntqh8    1/1     Running     0          113s
pod/el-tekton-webhook-sharedlibrary-7c57fcf9f8-kst82   1/1     Running     0          85m

NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/el-tekton-webhook-microservice    ClusterIP   10.96.122.3     <none>        8080/TCP,9000/TCP   113s
service/el-tekton-webhook-sharedlibrary   ClusterIP   10.96.190.254   <none>        8080/TCP,9000/TCP   85m
```

Você pode confirmar a criação do eventlisterner utilizando o `tkn`:

```bash
tkn el list
NAME                           AGE             URL                                                                     AVAILABLE
tekton-webhook-microservice    3 minutes ago   http://el-tekton-webhook-microservice.default.svc.cluster.local:8080    True
tekton-webhook-sharedlibrary   1 hour ago      http://el-tekton-webhook-sharedlibrary.default.svc.cluster.local:8080   True
```

### 9.2 Binding para pipeline de aplicação
 
O componente `Binding` da trigger define quais os campos do [evento](#evento) que serão utilizadas como variável para a pipeline. Lembrando que agora no arquivo de evento tem também os campos do `interceptors`.

Conforme o arquivo [binding](proj/trigger/pipeline-microservice/trigger-bindings.yaml).

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: tekton-triggerbinding-microservice
spec:
  params:
    - name: revision
      value: $(body.repository.default_branch)
    - name: repository
      value: $(body.repository.clone_url)
    - name: runtime
      value: $(extensions.runtime)
    - name: appname
      value: $(extensions.appname)
```

Vamos aplicar o arquivo de binding:

```bash
kubectl apply -f $TREINAMENTO_HOME/proj/trigger/pipeline-microservice/trigger-bindings.yaml
```

Você pode confirmar a criação do binding utilizando o `tkn`:

```bash
tkn tb list
NAME                                  AGE
tekton-triggerbinding-microservice    3 seconds ago
tekton-triggerbinding-sharedlibrary   1 hour ago
```

### 9.3 Template para pipeline de aplicação

O arquivo de `template` é similar o anteriormente, com as 3 partes, sendo variável de entrada e o recurso a ser inicializado e os parâmetros de entrada na pipeline.

Nesse caso não vamos inicializar uma `pipelineRun`. Um ponto importante é alterar o parâmetro de entreda registry.

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerTemplate
metadata:
  name: tekton-triggertemplate-microservice
spec:
  params:
    - name: revision
      description: The git revision
      default: master
    - name: repository
      description: The git repository url
    - name: runtime
      description: Runtime of app
    - name: appname
      description: Aplication name
    - name: version
      description: vesion of application
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: microservice-api-$(tt.params.appname)-$(tt.params.runtime)
        labels:
          tekton.dev/pipeline: microservice-api
      spec:
        serviceAccountName: tekton-triggers-sa
        pipelineRef:
          name: microservice-api
        params:
          - name: revision
            value: '$(tt.params.revision)'
          - name: url
            value: '$(tt.params.repository)'
          - name: runtime
            value: '$(tt.params.runtime)'
          - name: appname
            value: '$(tt.params.appname)'
          - name: registry
            value: clodonil  
        workspaces:
          - name: sharedlibrary
            persistentVolumeClaim:
               claimName: sharedlibrary
          - name: source
            persistentVolumeClaim:
               claimName: app-source
```

Vamos aplicar o arquivo de template:

```bash
kubectl apply -f $TREINAMENTO_HOME/proj/trigger/pipeline-microservice/trigger-template.yaml
```

Você pode confirmar a criação do binding utilizando o `tkn`:

```bash
tkn tt list
NAME                                   AGE
tekton-triggertemplate-microservice    7 seconds ago
tekton-triggertemplate-sharedlibrary   1 hour ago
```


### 9.4 Criação do webhook e testando

 Agora que temos as trigger criadas, vamos cadastrar o service da trigger no webhook do `gitea`, assim todo evento do repositório vai inicializar a pipeline.

 Para consultar o service, execute o seguinte comando.

 ```bash
kubectl get svc
NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
el-tekton-webhook-microservice    ClusterIP   10.96.122.3     <none>        8080/TCP,9000/TCP   33m
el-tekton-webhook-sharedlibrary   ClusterIP   10.96.190.254   <none>        8080/TCP,9000/TCP   117m
```
Você pode cadastrar o webhook pelo console web do `gitea` ou pode utilizar o script abaixo para fazer isso.

Segue os parâmetros utilizados no `gitea_cli.py`:
* `-w`: Define o service do trigger para o webhook, nesse caso é o **el-tekton-webhook-microservice**
* `-r`: Especifica o nome do repositório
* `-u`: Usuário utilizado para fazer o login no `gitea`
* `-p`: Senha do usuário do `gitea`

```bash
python3 $TREINAMENTO_HOME/proj/trigger/gitea/gitea_cli.py -w el-tekton-webhook-microservice -r app1-python -u $USER -p $PASS
```
Consulte a interface web do `gitea` para confirmar que o webhook foi configurado corretamente, conforme abaixo.

![trigger](img/image46.png)

Para validar a configuração, você pode utilizar o campo de teste do webhook ou realizar qualquer `commit` no repositório da `app1-python`.


![trigger](img/image47.png)


É possível acompanhar o log do `pod` `EvenListener` para consultar algum tipo de erro:

```bash
kubectl logs el-tekton-webhook-microservice-67bf667f45-ntqh8
```
 E também pode consultar se a `PipelineRun` foi criada e executada. Você pode fazer isso pela inteface web conforme a imagem abaixo.

![trigger](img/image43.png)

E também é possível ser feito utilizando o comando `tkn`, conforme abaixo:

```
tkn pr list
NAME                                STARTED         DURATION   STATUS
microservice-api-app1-pythonnpxzh   2 minutes ago   ---        Running
```
Assim temos as pipelines sendo inicializadas através de eventos do repositórios.