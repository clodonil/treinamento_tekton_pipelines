Introdução ao Tekton
==================

## Visão Geral

> O Tekton é um poderoso framework de código aberto nativo do Kubernetes, avançado e flexível para criar pipelines de integração e entrega contínuas (CI/CD). Como ele, é possível criar, testar e implantar em vários provedores de nuvem ou sistemas locais abstraindo os detalhes por trás da implementação. (google)

Tekton faz parte da [CD Foundation](https://cd.foundation/) , é um projeto da [Linux Foundation](https://cd.foundation/).

## Benificios de utilizar o Tekton

O `Tekton` oferece os seguintes benefícios para desenvolvimento de pipelines de CI/CD.

* **`Customizável``:** Tekton possuie recursos totalmente personalizáveis, permitindo um alto grau de flexibilidade. O time de DevOps podem definir um catálogo altamente detalhado de soluções para os desenvolvedores usarem em uma ampla variedade de cenários.

* **`Reutilizável`:** Os recursos criados pelo Tekton são totalmente portáteis, portanto, uma vez definidas, qualquer pessoa dentro da empresa pode usar um determinado pipeline e reutilizar parte da pipeline. Isso permite que os desenvolvedores construam rapidamente pipelines complexos sem “reinventar a roda”.

* **`Expansível`:** O Tekton possue um respositório de catalago mantido pela comunidade. Você pode criar rapidamente novos pipelines e expandir os existentes usando componentes pré-fabricados do catalago.

* **`Padronizado`:** O Tekton é instalado e executado como uma extensão (operator) em seu cluster Kubernetes e usa o modelo de recursos do Kubernetes bem estabelecido. Os workload do Tekton são executadas dentro de contêineres do Kubernetes.

* **`Escalável`:**.Para aumentar sua capacidade de carga de trabalho, você pode simplesmente adicionar nós ao cluster. O Tekton é dimensionado com seu cluster sem a necessidade de redefinir suas alocações de recursos ou quaisquer outras modificações em seus pipelines.

## Componentes do Tekton

Constuir pipeline de CI/CD com segurança, qualidade, governança e que gere escala de desenvolvimento, não é uma tarefa simples. Para tornar esse caminho mais tranquilo, a Tekton disponibiliza um conjunto de componetes.

Aqui estão os principais componentes que você obtém com o Tekton:

* **[`Pipeline`](https://github.com/tektoncd/pipeline/blob/main/docs/README.md)**: Pipeline define um conjunto de recursos personalizados do Kubernetes que atuam como tasks que você usa para montar seus pipelines de CI/CD.

* **[`Triggers`](https://github.com/tektoncd/triggers/blob/main/README.md):** Triggers é um recurso personalizado do Kubernetes que permite instanciar pipelines com base em eventos. Por exemplo, você pode executar uma pipeline sempre que um PR seja aprovado em um repositório Git.

* **[`CLI`](https://github.com/tektoncd/cli/blob/main/README.md):** A CLI fornece uma interface de linha de comando chamada `tkn` que permite interagir com o Tekton a partir do seu terminal.

* **[`Dashboard`](https://github.com/tektoncd/dashboard/blob/main/README.md):** Dashboard é uma interface gráfica baseada na web que exibe informações sobre a execução.

* **[`Catálogo`](https://github.com/tektoncd/catalog/blob/v1beta1/README.md):** O catálogo é um repositório de Tasks de alta qualidade e mantido pela comunidade .

* **[`Hub`](https://github.com/tektoncd/hub/blob/main/README.md):** Hub é uma interface gráfica baseada na web para acessar o catálogo Tekton.

* **[`Operator`](https://github.com/tektoncd/operator/blob/main/README.md):** Operator é um padrão Kubernetes que permite instalar, atualizar e remover projetos Tekton em um cluster Kubernetes.



# Terminologias

![conceitos](https://tekton.dev/docs/concepts/concept-tasks-pipelines.png)

* **`Step`:** A step is the most basic entity in a CI/CD workflow, such as running some unit tests for a Python web app or compiling a Java program. Tekton performs each step with a provided container image.

* **`Task`:** A task is a collection of steps in a specific order. Tekton runs a task in the form of a Kubernetes pod, where each step becomes a running container in the pod.

* **`Pipelines`:**spinn A pipeline is a collection of tasks in a specific order. Tekton collects all tasks, connects them in a directed acyclic graph (DAG), and executes the graph in sequence. In other words, it creates a number of Kubernetes pods and ensures that each pod completes running successfully as desired.
An open-source framework for createing reusable CI/CD systems


![run](https://tekton.dev/docs/concepts/concept-runs.png)

* **`PipelineRun`:** A PipelineRun, as its name implies, is a specific execution of a pipeline.

* **`TaskRun`:** A TaskRun is a specific execution of a task. TaskRuns are also available when you choose to run a task outside a pipeline, with which you may view the specifics of each step execution in a task.
