Versionando os templates com Bundles
================
## Objetivo

Ao final deste modulo você será capaz de:
* Entenda o que é bundle
* Como versionar Tasks e Pipelines
* Executando Bundle 
* Criando pipelines com Task Bundle 
* Versionando Pipelines



## Gerando Execuções de Pipelines e Tasks


# Habilitando Métricas no Tekton

![template](img/image32.png)

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
Para aplicar a configuração:

```bash
kubectl apply -f proj/Configs/config-observability.yaml
```

```bash
kubectl port-forward -n tekton-pipelines svc/tekton-pipelines-controller 9090
```
As métricas podem ser acessadas pela url: `http://localhost:9090/metrics`


# Instalação do Prometheus

Configuração do Prometheus

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



## Grafana

Configuração do datasourc:

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

```bash
kubectl -n observability apply -f proj/Metrics/Grafana/
```

O prometheus pode ser acessado pela URL: `http://localhost:30003/`

![template](img/image33.png)

## Executando os Logs
O Tekton armazena os logs de execução das TaskRuns e PipelineRuns dentro do `Pod` que contém os contêineres que executam o Steps seu TaskRun ou PipelineRun. 

Você pode obter logs de execução usando um dos seguintes métodos:

* Logs (https://tekton.dev/docs/pipelines/logs/)
https://github.com/mgreau/tekton-pipelines-elastic-o11y


# Deploy Elasticsearch and Kibana
kubectl apply -n elastic-system -f https://raw.githubusercontent.com/mgreau/tekton-pipelines-elastic-tutorials/master/config/eck/monitoring-es-kb.yaml

# Deploy Metricbeat and Filebeat
kubectl apply -n elastic-system -f https://raw.githubusercontent.com/mgreau/tekton-pipelines-elastic-tutorials/master/config/eck/monitoring-filebeat-metricbeat.yaml




