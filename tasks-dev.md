Criando Tasks
================
## Objetivo

Ao final deste modulo você será capaz de:
* Entenda o que é uma Task
* Entenda como clonar um projeto git e compilação usando o Task
* Entenda como funciona os Workspaces
* Crie uma task de build 
* Como executar uma Tasks

## Criando a tasks do Projeto

Para o desenvolvimento do nosso projeto vamos precisar criar 6 `Tasks`:

* `Source`: Essa Task vai ter apenas um `Step`, que é o `git-clone`, que basicamente vai fazer o clone do projeto do github e enviar para o workspace.
* `CI-QA` : Essa Task vai ter 2 `steps` que são o teste unitário e o `sonarqube`
* `CI-Security`: Essa Task vai ter 2 `steps`, sendo um para verificação da segurança do código e da segurança do container.
* `CI-Build`: Essa Task vai ter 3 `steps`, sendo um para build do código, outro para empacotamento e o último para publicação da imagem no dockerhub.
* `Tests`: Essa Task vai ter 2 `steps`, sendo um para validação a performance da aplicação e outro para realizar o teste de integração.
* `Deploy`: Essa Task vai ter apenas um `steps` para realização do deploy simples do container no cluster kubernetes.

![task](img/image6.png)`


### Ferramentas

* [SonarCloud](https://sonarcloud.io/): Sonar para analise de qualidade. 
* [horusec](https://horusec.io/site/): Ferramanta de SAST para verificação de segurança do código fonte.
* [trivy](https://www.aquasec.com/products/trivy/): Ferramenta de segurança de container.
* [k6](https://k6.io/): Ferramenta de teste de performance.
* [Karate](https://github.com/karatelabs/karate): Ferramenta de teste de integração de API
