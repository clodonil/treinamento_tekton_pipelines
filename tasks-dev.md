Desenvolvendo as Tasks
================
## Objetivo

Ao final deste modulo você será capaz de:
* Ter criado as tasks necessárias da pipeline;
* Ter validado cada tasks e seus passos;
* Ter utilizado a sharedlibrary;

## Criando a tasks do Projeto

Para o desenvolvimento do nosso projeto vamos precisar criar **6** `Tasks`:

![task](img/image6.png)

* `Source`: Essa Task vai ter um `Step`, que basicamente vai fazer o clone do projeto do git;
* `Quality` : Essa Task vai ter 2 `steps`:
    * `TestUnit` : Executa o teste unitario;
    * `Sonar`: Executa a cobertura de qualidade do código;
* `Security`: Essa Task vai ter 2 `steps`:
    * `Horusec`: Ferramenta de Sast para verificar a segurança do código;
    * `Trivy`: Ferramenta para analisar a segurança do container;
* `Build`: Essa Task vai ter 3 `steps`:
    * `Build`: Realiza o build da aplicação.
    * `Package`: Faz o empacotamento da aplicação em uma imagem docker, gerando o artefato final;
    * `Publish`: Pública a imagem no dockerhub;
* `Tests`: Essa Task vai ter 2 `steps`:
    * `Performance`: Teste de performance da aplicação utilizando o `K6`.
    * `Integration`: Teste de API com o Karate
* `Deploy`: Essa Task vai ter apenas um `steps` para realização do deploy simples do container no cluster kubernetes.




## Ferramentas

Nas Tasks vamos utilizar as seguintes ferramentas:

* [SonarCloud](https://sonarcloud.io/): Sonar para analise de qualidade. 
* [horusec](https://horusec.io/site/): Ferramanta de SAST para verificação de segurança do código fonte.
* [trivy](https://www.aquasec.com/products/trivy/): Ferramenta de segurança de container.
* [k6](https://k6.io/): Ferramenta de teste de performance.
* [Karate](https://github.com/karatelabs/karate): Ferramenta de teste de integração de API


## Workspace

Para desenvolvimento da pipeline vamos precisar de **2** `workspace`:

![workspace](img/image7.png)`

* app-source: Nesse workspace vai armazenar o código fonte durante a execução;
* sharedlibrary: Nesse workspace vai conter os comandos necessários para execução das tasks;

Os manifesto dos volumes foram criados no arquivo [proj/pv-workspaces.yaml](proj/pv-workspaces.yaml).

```bash:proj/pv-workspaces.yaml
kubectl apply -f pv-workspaces.yaml
persistentvolumeclaim/app-source created
persistentvolumeclaim/sharedlibrary created
```

## Tasks
O nosso próximo passo vamos criar as `Tasks` necessario para o desenvolvimento da pipeline.

### Criando a Tasks `Source`

A Task `Source` vai ser responsável por realizar o clone do projeto do git. Podemos criar essa Task manualmente, entretanto o Tekton disponibiliza o [Tekton-Hub](https://hub.tekton.dev/) que já possui um catalago de Tasks disponibilizada pela comunidade.

E para realisar o clone do projeto, vamos utilizar a Task [git-clone](https://hub.tekton.dev/tekton/task/git-clone) disponibilizado no Tekton-Hub.

Para instalar essa Task, podemos utilizar o CLI:

```
tkn hub install task git-clone
```
Ou podemos utilizar o `kubectl` passando o endereço do git-clone.

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.5/git-clone.yaml
```

Ambos tem o mesmo resultado.

Com  Task instalada, vamos criar a `Taskrun` para realizar o clone do repositório do projeto. 

```yaml:proj/Source/taskrun-source.yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: taskrun-source
spec:
  workspaces:
    - name: output
      persistentVolumeClaim:
         claimName: app-source
  params:
    - name: revision
      value: master
    - name: url
      value: 'https://github.com/clodonil/apphello'
  taskRef:
     name: git-clone
```
Podemos acompanhar a execução da Taskrun no dashboard do Tekton ou via CLi (tkn).

![sourcerun](img/image8.png)`


#### SharedLibary

A SharedLibary é um repositório que contém os comandos que são executados na pipelines, tornando a solução de pipeline com mais segurança e governança.

A cada alteração no repositório da sharedlibrary no git, é necessário atualizar o `workspace` para a pipelines obter os novos comandos. Para esse controle, o ideal é ter um pipeline apenas para gerenciar a sharedlibrary.

Para esse projeto, vamos criar apenas uma `TaskRun` para atualizar o `workspace`.


```yaml:proj/tasks/Source/task-sharedlibrary.yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  name: taskrun-sharedlibrary
spec:
  workspaces:
    - name: output
      persistentVolumeClaim:
         claimName: sharedlibrary
  params:
    - name: revision
      value: main
    - name: url
      value: 'https://github.com/clodonil/tekton-sharedlibrary'
  taskRef:
     name: git-clone
```

Para fazer o download/atualização da `sharedlibrary` para o workspace precisamos executar a Taskrun. Esse processo deve ser feito toda vez que tiver alteração na `sharedlibrary`.

```bash
kubectl apply -f task-sharedlibrary.yaml
```

### Criando a Tasks `Quality`

A próxima Task que vamos criar é a `quality`, que está relacionada a qualidade do código.

A Task em como entrada:
* `runtime`: Parâmetro que contém a tecnologia utilizada na aplicação
* `appname`: Parâmetro que contém o nome da aplicação
* `source`: Workspace que contém o código fonte da aplicação
* `sharedlibrary`: Workspace que contém os comandos para serem executados na pipeline.

Teremos **2** `steps`:
   * `TestUnit` : Executa o teste unitário;
   * `Sonar`: Executa a cobertura de qualidade do código;

![build](img/image11.png)

Agora que entendemos a estrutura das Tasks de qualidade, vamos entender como podemos desenvolver.

Primeiramente vamos definir as entradas, conforme o diagrama, seguindo o padrão do `yaml`. 

> Importante, na definição do workspace da sharedlibrary, o mesmo deve ser disponibilizao apenas como leitura (readonly), por questão de segurança da pipeline.

```python
params:
  - name: appname
    description: Nome da Imagem
  - name: runtime
    description: Runtime da aplicacao           
workspaces:
  - name: sharedlibrary
    description: Pasta com os comandos de execucao da pipeline
    readOnly: true                
  - name: source
    description: Pasta com os fontes da aplicacao
```
Antes de criar os `steps`, vamos criar o Steptemplate. Isso é importante para não ficar duplicando linha de código no arquivo e caso seja necessário alterar, podemos fazer isso em um único local.
O template define o diretório de trabalho (`workingdir`), como sendo o diretório do código fonte, e também um volume que vai ser montando em todas os `steps` no diretório /coverage.
Esse volume é do tipo `emptyDir` e vai ser utilizado para a tasks de testunit enviar o reporte de cobertura para o step do sonar.

```python
stepTemplate:
  workingDir: /workspace/source
  volumeMounts:
    - name: coverage
      mountPath: /coverage
volumes:
  - name: coverage
    emptyDir: {}    
```
Agora vamos definir os `steps`. 

O primeiro step é o teste unitário. A imagem utilizada no step é definida no parâmetro `runtime`. Esse step pode ser customizado pelo desenvolver.

```bash
[ -f "pipeline/unittest.sh" ] && sh pipeline/unittest.sh || sh $(workspaces.sharedlibrary.path)/CI$runtime/tests/unittest.sh 
```
Essa linha verifica se o arquivo `pipeline/unittest.sh` existe no repositório e executa. Caso contrato executa o script que esta no sharedlibrary.  

```python
- name: unit-testing
  image: $(params.runtime)
  script: |
    runtime=$(params.runtime)               
    [ -f "pipeline/unittest.sh" ] && sh pipeline/unittest.sh || sh $(workspaces.sharedlibrary.path)/CI$runtime/tests/unittest.sh 
```
O segundo step é o sonar para analise de qualidade do código. Para isso vamos utilizar o site [SonarCloud](https://sonarcloud.io/).

É necessário criar uma conta no site e um projeto 

```python   
    - name: sonar
      env:
        - name: SONAR_TOKEN
          valueFrom:
            secretKeyRef:
              name: sonar
              key: SONAR_TOKEN
      image: ubuntu
      script: |
        sh $(workspaces.sharedlibrary.path)/CI/$(params.runtime)/sonar/sonar.sh
```

Crie um secret para armazenar o Token criado no site [SonarCloud](https://sonarcloud.io/).

```bash
kubectl create secret generic sonar --from-literal=SONAR_TOKEN=$TOKEN
```    

[Link do Task de QA](proj/tasks/QA/task-qa.yaml)

### Criando a Tasks `Security`

 Essa Task vai ter 2 `steps`:





![build](img/image10.png)


```yaml
workspaces:
  - name: sharedlibrary
    description: Pasta com os comandos de execucao da pipeline
    readOnly: true                
  - name: source
    description: Pasta com os fontes da aplicacao
```

```yaml
stepTemplate:
  workingDir: /workspace/source
  image: docker
  volumeMounts:
    - name: dind-socket
      mountPath: /var/run/
```
* [horusec](https://horusec.io/site/): Ferramanta de SAST para verificação de segurança do código fonte.

> docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/src/horusec horuszup/horusec-cli:latest horusec start -p /src/horusec -P $(pwd)

```yaml
steps:
  - name: horusec
    script: |      
         sh $(workspaces.sharedlibrary.path)/CI/common/sast/sast.sh
```

* [trivy](https://www.aquasec.com/products/trivy/): Ferramenta de segurança de container.

> docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy:0.20.2 appbuid:latest


```yaml
- name: trivy
  script: |
       sh $(workspaces.sharedlibrary.path)/CI/common/container-security/trivy.sh
```

```yaml
sidecars:
  - image: docker:18.05-dind
    name: server
    securityContext:
      privileged: true
```


### Criando a Tasks `Build`

 Essa Task vai ter 3 `steps`:
    * `Build`: Realiza o build da aplicação.
    * `Package`: Faz o empacotamento da aplicação em uma imagem docker, gerando o artefato final;
    * `Publish`: Pública a imagem no dockerhub;



![build](img/image9.png)

```bash
kubectl create secret docker-registry dockerhub \
  --docker-server=$DOCKER_REGISTRY_SERVER \
  --docker-username=$DOCKER_USER \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL
  ```

```bash
kubectl patch serviceaccount default -p '{"secrets": [{"name": "dockerhub"}]}'
```

### Criando a Tasks `Tests`
 Essa Task vai ter 2 `steps`:
    * `Performance`: Teste de performance da aplicação utilizando o `K6`.
    * `Integration`: Teste de API com o Karate

* [k6](https://k6.io/): Ferramenta de teste de performance.
* [Karate](https://github.com/karatelabs/karate): Ferramenta de teste de integração de API


![build](img/image12.png)

### Criando a Tasks `Deploy`
 Essa Task vai ter apenas um `steps` para realização do deploy simples do container no cluster kubernetes.

![build](img/image13.png)