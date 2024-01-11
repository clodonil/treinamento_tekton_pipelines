# Proposta do Projeto 

## Objetivo

Apresentar a proposta de desenvolvimento da pipeline utilizando a tecnologia `TekTon`.

## Pipeline de deploy API

A proposta é criar uma pipeline utilizando `TekTon` para publicação de APIs que tenha  `Segurança`, `Qualidade` e `Governança`.

A pipeline deve ter as seguintes caracteristicas:

* Desenvolvimento em Template `yaml`; 
* SharedLibrary com comandos externalizado para fácil manutenção;
* Controle de versão dos templates;
* Possibilidade de build/testes e deploy customizado

A pipeline deve ter as seguites tasks, conforme desenho abaixo:

* **Source:** Utilizado para realizar o clone do repositório de código;
* **CI:** Utilizado para realização do build, teste unitário e validação de segurança
* **Tests:** Realização dos testes de performance e integração
* **Deploy:** Realização do deploy no kubernetes

![projeto](img/image14.png)


## Stages Customizados

A pipeline deve ter os comandos padrões de `build`, `tests` e `deploy`. Entretanto caso o desenvolvedor desejar, ele pode sobrescrever esses comandos, através de um arquivo simples no seu repositório.

Abaixo temos os arquivos que o usuário deve colocar no repositório da aplicação para sobrescrever o padrão da pipeline definido na sharedlibary.


|stages| Repositório App |[SharedLibrary](https://github.com/clodonil/tekton-sharedlibrary)|
|-------|------|-------------|
|`build` | pipeline/build.sh |[/CI/`runtime`/build/build.sh](https://github.com/clodonil/tekton-sharedlibrary/blob/main/CI/python/build/build.sh)|
| `unittest` |pipeline/unittest.sh | [/CI/`runtime`/tests/unittest.sh](https://github.com/clodonil/tekton-sharedlibrary/blob/main/CI/python/build/build.sh) |
| `performace` | pipeline/tests/performance/performance.sh  | [TESTS/performance/performance.sh](https://github.com/clodonil/tekton-sharedlibrary/blob/main/TESTS/performance/performance.sh)  |
| `integration`| pipeline/tests/integration/integration.sh  | [TESTS/integration/integration.sh](https://github.com/clodonil/tekton-sharedlibrary/blob/main/TESTS/integration/integration.sh) |
| `deploy`|pipeline/deploy.sh | [/CD/deploy.sh](https://github.com/clodonil/tekton-sharedlibrary/blob/main/CD/deploy.sh) |

O repositório com os comandos padrões de execução estão aqui: [SharedLibrary](https://github.com/clodonil/tekton-sharedlibrary)

## APIs

Segue o link das aplicações que serão utilizadas para build durante o desenvolvimento da pipeline.São aplicações simples de API.

* [Hello World - Python](https://github.com/clodonil/Hello-World-Python)
* [Hello World - Node](https://github.com/clodonil/Hello-World-Node)
* [Hello World - Goland](https://github.com/clodonil/Hello-World-Goland)
* [Hello World - Maven](https://github.com/clodonil/Hello-World-Maven)

