#!/bin/bash

# Criar como pacote a task src/task-exemplo1.yaml


tkn bundle push index.docker.io/clodonil/task-exemplo1:v1 -f ../task-exemplo1.yaml
tkn bundle push index.docker.io/clodonil/task-exemplo1:latest -f ../task-exemplo1.yaml

tkn bundle push index.docker.io/clodonil/task-exemplo2:v1 -f ../task-exemplo2.yaml
tkn bundle push index.docker.io/clodonil/task-exemplo2:latest -f ../task-exemplo2.yaml

