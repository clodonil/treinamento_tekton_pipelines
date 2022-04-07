tkn pipeline start microservice-api  \
    --prefix-name='microservice-api.python-helloworld' \
    --param revision='master' \
    --param url=https://github.com/clodonil/apphello.git \
    --param runtime='python' \
    --param appname='python-helloworld'\
    --param registry='clodonil' \
    --workspace name=source,claimName=app-source \
    --workspace name=sharedlibrary,claimName=sharedlibrary \
    --showlog