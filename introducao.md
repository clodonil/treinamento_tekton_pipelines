Introdução ao Tekton
==================

## Visão Geral

> O Tekton é um poderoso framework de código aberto nativo do Kubernetes, avançado e flexível para criar pipelines de integração e entrega contínuas (CI/CD). Como ele, é possível criar, testar e implantar em vários provedores de nuvem ou sistemas locais abstraindo os detalhes por trás da implementação. (google)

Tekton faz parte da [CD Foundation](https://cd.foundation/) , é um projeto da [Linux Foundation](https://cd.foundation/).

## Benificios de utilizar o Tekton

O `Tekton` oferece os seguintes benefícios para desenvolvimento de pipelines de CI/CD.

* Customizable. Tekton entities are fully customizable, allowing for a high degree of flexibility. Platform engineers can define a highly detailed catalog of building blocks for developers to use in a wide variety of scenarios.

* Reusable. Tekton entities are fully portable, so once defined, anyone within the organization can use a given pipeline and reuse its building blocks. This allows developers to quickly build complex pipelines without “reinventing the wheel.”

* Expandable. Tekton Catalog is a community-driven repository of Tekton building blocks. You can quickly create new and expand existing pipelines using pre-made components from the Tekton Catalog.

* Standardized. Tekton installs and runs as an extension on your Kubernetes cluster and uses the well-established Kubernetes resource model. Tekton workloads execute inside Kubernetes containers.

* Scalable. To increase your workload capacity, you can simply add nodes to your cluster. Tekton scales with your cluster without the need to redefine your resource allocations or any other modifications to your pipelines.

## Componentes do Tekton

Construir pipelines de CI/CD é um empreendimento de longo alcance, então a Tekton fornece ferramentas para cada etapa do caminho. Aqui estão os principais componentes que você obtém com o Tekton:

* **`Pipeline`**: Pipeline define um conjunto de recursos personalizados do Kubernetes que atuam como blocos de construção que você usa para montar seus pipelines de CI/CD.

* **`Triggers`:** Triggers é um recurso personalizado do Kubernetes que permite criar pipelines com base em informações extraídas de cargas úteis de eventos. Por exemplo, você pode acionar a instanciação e a execução de um pipeline sempre que uma solicitação de mesclagem for aberta em um repositório Git.

* **`CLI`:** A CLI fornece uma interface de linha de comando chamada tkn que permite interagir com o Tekton a partir do seu terminal.

* **`Dashboard`:** Dashboard é uma interface gráfica baseada na web para pipelines Tekton que exibe informações sobre a execução de seus pipelines.

* **`Catálogo`:** O catálogo é um repositório de blocos de construção Tekton de alta qualidade e contribuídos pela comunidade (tarefas, pipelines e assim por diante) prontos para uso em seus próprios pipelines.

* **`Hub`: Hub é uma interface gráfica baseada na web para acessar o catálogo Tekton.

* **`Operator`:** Operator é um padrão Kubernetes Operator que permite instalar, atualizar, atualizar e remover projetos Tekton em um cluster Kubernetes.



# Terminologias

![conceitos](https://tekton.dev/docs/concepts/concept-tasks-pipelines.png)

* **`Step`:** A step is the most basic entity in a CI/CD workflow, such as running some unit tests for a Python web app or compiling a Java program. Tekton performs each step with a provided container image.

* **`Task`:** A task is a collection of steps in a specific order. Tekton runs a task in the form of a Kubernetes pod, where each step becomes a running container in the pod.

* **`Pipelines`:**spinn A pipeline is a collection of tasks in a specific order. Tekton collects all tasks, connects them in a directed acyclic graph (DAG), and executes the graph in sequence. In other words, it creates a number of Kubernetes pods and ensures that each pod completes running successfully as desired.
An open-source framework for createing reusable CI/CD systems


![run](https://tekton.dev/docs/concepts/concept-runs.png)

* **`PipelineRun`:** A PipelineRun, as its name implies, is a specific execution of a pipeline.

* **`TaskRun`:** A TaskRun is a specific execution of a task. TaskRuns are also available when you choose to run a task outside a pipeline, with which you may view the specifics of each step execution in a task.
