Criando Tasks
================
## Objetivo

Ao final desse módulo você deve ter criados todos as tasks necessárias para o desenvolvimento da pipeline.

## Criando a tasks do Projeto

Para o desenvolvimento do nosso projeto vamos precisar criar 6 `Tasks`:

* `Source`: Essa Task vai ter um `Step`, que basicamente vai fazer o clone do projeto do git;
* `CI-QA` : Essa Task vai ter 2 `steps`:
    * `TestUnit` : Executa o teste unitário;
    * `Sonar`: Executa a cobertura de qualidade do código;
* `CI-Security`: Essa Task vai ter 2 `steps`:
    * `Horusec`: Ferramenta de Sast para verificar a segurança do código;
    * `Trivy`: Ferramenta para analisar a segurança do container;
* `CI-Build`: Essa Task vai ter 3 `steps`:
    * `Build`: Realiza o build da aplicação.
    * `Package`: Faz o empacotamento da aplicação em uma imagem docker, gerando o artefato final;
    * `Publish`: Pública a imagem no dockerhub;
* `Tests`: Essa Task vai ter 2 `steps`:
    * `Performance`: Teste de performance da aplicação utilizando o `K6`.
    * `Integration`: Teste de API com o Karate
* `Deploy`: Essa Task vai ter apenas um `steps` para realização do deploy simples do container no cluster kubernetes.

![task](img/image6.png)`


### Ferramentas

* [SonarCloud](https://sonarcloud.io/): Sonar para analise de qualidade. 
* [horusec](https://horusec.io/site/): Ferramanta de SAST para verificação de segurança do código fonte.
* [trivy](https://www.aquasec.com/products/trivy/): Ferramenta de segurança de container.
* [k6](https://k6.io/): Ferramenta de teste de performance.
* [Karate](https://github.com/karatelabs/karate): Ferramenta de teste de integração de API
