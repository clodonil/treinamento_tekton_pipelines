Docker hub
User winterfoxoutlook
PWD testetektonpipeline!

kubectl create secret docker-registry dockerhub \
  --docker-server=$DOCKER_REGISTRY_SERVER \
  --docker-username=$DOCKER_USER \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL

  export DOCKER_REGISTRY_SERVER=hub.docker.com

  export DOCKER_USER=winterfoxoutlook

  export DOCKER_PASSWORD=testetektonpipeline!

  export DOCKER_EMAIL=winterfoxit@outlook.com

  kubectl create secret docker-registry dockerhub --docker-server=$DOCKER_REGISTRY_SERVER --docker-username=$DOCKER_USER --docker-password=$DOCKER_PASSWORD --docker-email=$DOCKER_EMAIL