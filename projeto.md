# Proposta do Projeto 

## Objetivo
Ao final desse módulo você deve ter o ambiente preparado e com o `tekton` instalado juntamente com as ferramentas.

## Pipeline de deploy API


![projeto](img/image14.png)

A pipeline deve ter as seguintes caracteristicas:

* Mesmo Template para linguagem (runtime) diferentes 
* SharedLibrary exterminalizado para fácil manutenção
* Controle de versão dos templates
* Possibilidade de build/testes customizado
* Possibilidade de Deploy customizado

## Stages Customizados

A pipeline deve ter os comandos padrões de build, tests e deploy. Entretanto caso o desenvolver desejar ele pode sobrescrever esses comandos, através da criação de um arquivo simples no seu repositório:

|stages| Repositório App |SharedLibrary|
|-------|------|-------------|
|`build` | pipeline/build.sh |/CI/`runtime`/build/build.sh|
| `unittest` |pipeline/unittest.sh | /CI/`runtime`/tests/unittest.sh |
| `performace` | pipeline/tests/performance/performance.sh  | TESTS/performance/performance.sh  |
| `integration`| pipeline/tests/integration/integration.sh  | TESTS/integration/integration.sh |
| `deploy`|pipeline/deploy.sh | /CD/deploy.sh |



## Urls das APIs

* [Python]()
* [Node]()
* [Goland]()
* [Maven]()
