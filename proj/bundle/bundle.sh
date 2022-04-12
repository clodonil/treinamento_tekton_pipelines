#!/bin/bash

# Arquivo para armazenamento
file=$1

# nome do artefato
name=$2

# Nome da pipeline
template=$3

tkn bundle push index.docker.io/clodonil/$template-$name:v1 -f $file