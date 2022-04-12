#!/bin/bash

# Criar como pacote a task src/task-exemplo1.yaml


tkn bundle push index.docker.io/clodonil/task-exemplo1:v2 -f task-exemplo1-v2.yaml
tkn bundle push index.docker.io/clodonil/task-exemplo1:latest -f task-exemplo1-v2.yaml

tkn bundle push index.docker.io/clodonil/task-exemplo2:v2 -f task-exemplo2-v2.yaml
tkn bundle push index.docker.io/clodonil/task-exemplo2:latest -f task-exemplo2-v2.yaml

