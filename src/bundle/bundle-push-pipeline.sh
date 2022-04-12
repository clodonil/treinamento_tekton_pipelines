#!/bin/bash

# Criar como pacote a task src/task-exemplo1.yaml


tkn bundle push index.docker.io/clodonil/pipeline-exemplo1:v1 -f pipeline-exemplo1-v1.yaml
tkn bundle push index.docker.io/clodonil/pipeline-exemplo1:v2 -f pipeline-exemplo1-v2.yaml
tkn bundle push index.docker.io/clodonil/pipeline-exemplo1:latest -f pipeline-exemplo1-latest.yaml