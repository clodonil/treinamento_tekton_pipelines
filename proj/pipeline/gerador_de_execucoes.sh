#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: Número de execuções não definida"
  echo "Exemplo:"
  echo "proj/pipeline/gerador_de_execucoes.sh 3"
  exit -1
fi  
numero_de_execucoes=$1

for x in $(seq 1 $numero_de_execucoes); do
  app="app$x"
  echo $app
      tkn pipeline start microservice-api  \
          --prefix-name="microservice-api.$app" \
          --param revision='master' \
          --param url=https://github.com/clodonil/apphello.git \
          --param runtime='python' \
          --param appname='python-helloworld'\
          --param registry='clodonil' \
          --workspace name=source,claimName=app-source \
          --workspace name=sharedlibrary,claimName=sharedlibrary 
done
