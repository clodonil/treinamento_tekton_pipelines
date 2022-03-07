Introdução ao Tekton
==================

## Visão Geral

> O Tekton é um poderoso framework de código aberto nativo do Kubernetes avançado e flexível para criar pipelines de integração e entrega contínuas (CI/CD). Como ele, é possível criar, testar e implantar em vários provedores de nuvem ou sistemas locais abstraindo os detalhes por trás da implementação. (google)

Como uma estrutura nativa do Kubernetes, o Tekton ajuda a modernizar a entrega contínua, fornecendo especificações do setor para pipelines, fluxos de trabalho e outros elementos essenciais, tornando a implementação em vários provedores de cloud ou ambientes híbridos mais rápida e fácil.


## Componentes do Tekton

Construir pipelines de CI/CD é um empreendimento de longo alcance, então a Tekton fornece ferramentas para cada etapa do caminho. Aqui estão os principais componentes que você obtém com o Tekton:

* **`Pipeline`**: Pipeline define um conjunto de recursos personalizados do Kubernetes que atuam como blocos de construção que você usa para montar seus pipelines de CI/CD.

* **`Triggers`:** Triggers é um recurso personalizado do Kubernetes que permite criar pipelines com base em informações extraídas de cargas úteis de eventos. Por exemplo, você pode acionar a instanciação e a execução de um pipeline sempre que uma solicitação de mesclagem for aberta em um repositório Git.

* **`CLI`:** A CLI fornece uma interface de linha de comando chamada tkn que permite interagir com o Tekton a partir do seu terminal.

* **`Dashboard`:** Dashboard é uma interface gráfica baseada na web para pipelines Tekton que exibe informações sobre a execução de seus pipelines.

**`Catálogo`:** O catálogo é um repositório de blocos de construção Tekton de alta qualidade e contribuídos pela comunidade (tarefas, pipelines e assim por diante) prontos para uso em seus próprios pipelines.

* **`Hub`: Hub é uma interface gráfica baseada na web para acessar o catálogo Tekton.

* **`Operator`:** Operator é um padrão Kubernetes Operator que permite instalar, atualizar, atualizar e remover projetos Tekton em um cluster Kubernetes.

* **`Chains`:** Chains é um controlador Kubernetes Custom Resource Definition (CRD) que permite gerenciar a segurança da cadeia de suprimentos no Tekton. Atualmente é um trabalho em andamento.

* **`Results`:** Os resultados visam ajudar os usuários a agrupar logicamente o histórico de carga de trabalho de CI/CD e separar o armazenamento de resultados de longo prazo do controlador de pipeline.


An open-source framework for createing reusable CI/CD systems

Started off as Knative Build Project

Runs on Kubernetes

Uses CRDs to extend Kubernetes

GitOps: The new cloud native Operating Model

1. The entire system is described declaratively
2. The canonical desired system state is versioned in git
3.Approved changes are automatically applied to the system (commit/PT/MT etc)
4. Software agents to ensure correctness and alert on divergence

## Projeto de Pipelines

* Template para multilinguagem
* Com suporte de SharedLibrary
* Cache de build
