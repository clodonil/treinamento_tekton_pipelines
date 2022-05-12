#!/bin/bash
numero_de_execucoes=2

microservices=('app1' 'app2' 'app3' 'app4' 'app5') 


for app in ${microservices[@]}; do
  echo $app
for i in $(seq 1 $numero_de_execucoes)
do
echo $i
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
done
