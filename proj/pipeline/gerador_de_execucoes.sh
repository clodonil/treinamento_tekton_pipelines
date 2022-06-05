#!/bin/bash

numero_de_execucoes=1

for x in $(seq 0 $numero_de_execucoes); do
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
