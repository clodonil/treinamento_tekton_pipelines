Observability
================
## Objetivo

Ao final deste módulo você será capaz de:
* Criar métricas das pipelines
* Criar métricas de tasks
* Externalizar os logs 

# Habilitando Métricas no Tekton

Para habilitar as métricas no Tekton é necessário alterar o `configmap`. O Tekton permite externalizar as métricas para o `stackdrier`ou `prometheus`. 

Nesse módulo vamos externalizar as métricas no tekton no formato do  `prometheus`. E para isso vamos instalar o `prometheus` e também o `grafana` para visualizar as métricas. 

![template](img/image32.png)

O configmap [config-observability](./proj/Configs/config-observability.yaml) trás como métricas padrão os seguintes valores:


```yaml
    metrics.taskrun.level: "task"
    metrics.taskrun.duration-type: "histogram"
    metrics.pipelinerun.level: "pipeline"
    metrics.pipelinerun.duration-type: "histogram"
```

|Configuração |	Valor | Descrição|
|------------|--------|----------|
|metrics.taskrun.level |	taskrun|	Level of metrics is taskrun|
|metrics.taskrun.level |	task	|Level of metrics is task and taskrun label isn’t present in the metrics|
|metrics.taskrun.level |	namespace|	Level of metrics is namespace, and task and taskrun label isn’t present in the metrics|
|metrics.pipelinerun.level |	pipelinerun	|Level of metrics is pipelinerun
|metrics.pipelinerun.level |	pipeline	|Level of metrics is pipeline and pipelinerun label isn’t present in the metrics
|metrics.pipelinerun.level |	namespace	|Level of metrics is namespace, pipeline and pipelinerun label isn’t present in the metrics
|metrics.taskrun.duration-type|	histogram|	tekton_pipelines_controller_pipelinerun_taskrun_duration_seconds and tekton_pipelines_controller_taskrun_duration_seconds is of type histogram
metrics.taskrun.duration-type	lastvalue	tekton_pipelines_controller_pipelinerun_taskrun_duration_seconds and tekton_pipelines_controller_taskrun_duration_seconds is of type gauge
|metrics.pipelinerun.duration-type|	histogram|	tekton_pipelines_controller_pipelinerun_duration_seconds is of type histogram|
|metrics.pipelinerun.duration-type|	histogram|	tekton_pipelines_controller_pipelinerun_duration_seconds is of type gauge or lastvalue|


Segue o confimap que estamos utilizando nesse módulo.
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-observability
  namespace: tekton-pipelines
  labels:
    app.kubernetes.io/instance: default
    app.kubernetes.io/part-of: tekton-pipelines
data:
    # suporta Stackdriver e prometheus
    metrics.backend-destination: prometheus

    #metrics.stackdriver-project-id: "<your stackdriver project id>"

    metrics.allow-stackdriver-custom-metrics: "false"
    metrics.taskrun.level: "task"
    metrics.taskrun.duration-type: "histogram"
    metrics.pipelinerun.level: "pipeline"
    metrics.pipelinerun.duration-type: "histogram"
```
Para aplicar a configuração no `tekton`:

```bash
kubectl apply -f proj/Configs/config-observability.yaml
```
Para visualizar a externalização das métricas, vamos expor a porta `9090` do `tekton`.

```bash
kubectl port-forward -n tekton-pipelines svc/tekton-pipelines-controller 9090
```
As métricas podem ser acessadas pela url: `http://localhost:9090/metrics`

# Instalação do Prometheus

Agora que `Tekton` externalizou as métricas, vamos precisar instalar o `prometheus` para armazenamento das métricas.

Na configuração do `prometheus` precisamos apontar para o service (`tekton-pipelines-controller.tekton-pipelines.svc:9090`) das métricas do `Tekton`.

O arquivo (prometheus-configmap)[./proj/prometheus/prometheus-configmap.yaml] 

```yaml
    global:
      scrape_interval: 5s
      evaluation_interval: 5s
    rule_files:
      - /etc/prometheus/prometheus.rules
    alerting:
      alertmanagers:
      - scheme: http
        static_configs:
        - targets:
          - "tekton-pipelines-controller.tekton-pipelines.svc:9090"
    scrape_configs:
      - job_name: 'media_search'
        scrape_interval: 10s
        static_configs: 
          - targets: ['tekton-pipelines-controller.tekton-pipelines.svc:9090']          
```

Vamos executar o `prometheus` no namespace `observability` e para isso vamos precisar criar a namespace primeiro.
Em seguida vamos realizar o deploy do `prometheus` aplicando os seguintes arquivos:

* [prometheus-deployment.yaml](): Deploy do `prometheus` com as configuração da imagem e recursos utilizado 
* [prometheus-services.yaml](): Configuração do service para expor o `prometheus`
* [prometheus-configmap.yaml](): Configuração do `prometheus` com o confimap.


Para aplicar a configuração no `prometheus`: 

```bash
kubectl create namespace observability
kubectl -n observability apply -f proj/Metrics/prometeus/
```

O prometheus pode ser acessado pela URL: `http://localhost:30004/`

![template](img/image31.png)

Tipos de métricas:

| Métrica  |Descrição   |
|----------|------------|
|tekton_go_*       |            |
|tekton_running_{taskruns ou pipelineruns}_count          |            |
|tekton_pipelinerun_count         |            |
|tekton_taskrun_count         |            |
|tekton_{taskrun ou pipelinrun}_duration_seconds_count         |            |
|tekton_{taskrun ou pipelinrun}_duration_seconds_sum         |            |

## Gerando Execuções de Pipelines e Tasks

Agora que temos o `prometheus` configurado, vamos executar algumas pipelines para gerar dados e métricas.

Para isso, temos o script [gerador_de_execucoes](./proj/pipeline/gerador_de_execucoes.sh).  Altere para suas necessidades.

```bash
proj/pipeline/gerador_de_execucoes.sh
```


## Grafana

Para visualizar as métricas vamos utilizar o `grafana`. Na configuração é necessário definir o `datasource` que é o `prometheus` e os dasboard que contém os gráficos.  

Para a configuração do datasource vamos utilizar o configmap [grafana-datasource-config.yaml](./proj/Metrics/Grafana/grafana-datasource-config.yaml) e nele apontar para o service do `prometheus`, conforme abaixo.

```yaml
    {
        "apiVersion": 1,
        "datasources": [
            {
               "access":"proxy",
                "editable": true,
                "name": "prometheus",
                "orgId": 1,
                "type": "prometheus",
                "url": "http://prometheus.observability.svc:9090",
                "version": 1
            }
        ]
    }
```
Para implementar o `grafana` vamos aplicar os seguintes arquivo:

* [deployment.yaml](./proj/Metrics/Grafana/deployment.yaml): Arquivo de Deploy que define a imagem do grafana e também as configurações de recursos.
* [services.yaml](./proj/Metrics/Grafana/services.yaml): Configuração do service para expor o `Grafana`
* [grafana-datasource-config.yaml](./proj/Metrics/Grafana/grafana-datasource-config.yaml): Configuração do datasource apontando para o `prometheus`.
* [grafana-dashboards.yaml](./proj/Metrics/Grafana/grafana-dashboards.yaml): Criação do folder do dashboard
* [dashboard-microservice-configmap.yaml](./proj/Metrics/Grafana/dashboard-microservice-configmap.yaml): Criação das métricas das pipelines
* [dashboard-tekton-configmap.yaml](./proj/Metrics/Grafana/dashboard-tekton-configmap.yaml): Criação do dashboard do operator do tekton

Para aplicar a configuração do `grafana`: 

``` 
kubectl -n observability apply -f proj/Metrics/Grafana/
```

O grafana pode ser acessado pela URL: `http://localhost:30003/`

![template](img/image33.png)

As métricas criadas:


## Executando os Logs
O Tekton armazena os logs de execução das TaskRuns e PipelineRuns dentro do `Pod` que contém os contêineres que executam o Steps seu TaskRun ou PipelineRun. 

Você pode obter logs de execução usando um dos seguintes métodos:

* Logs (https://tekton.dev/docs/pipelines/logs/)

```bash
kubectl apply -f https://download.elastic.co/downloads/eck/1.3.1/all-in-one.yaml
kubectl -n elastic-system apply -f monitoring-es-kb.yaml
kubectl -n elastic-system apply -f monitoring-filebeat-metricbeat.yaml
`` 


User: elastic
password:
echo $(kubectl get secret -n elastic-system elasticsearch-monitoring-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode)

kubectl port-forward -n elastic-system svc/kibana-monitoring-kb-http 5601

https://localhost:5601/app/observability/overview
