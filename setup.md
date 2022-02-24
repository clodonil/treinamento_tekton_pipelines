# Setup 

## Conteúdo:
> 1. Pré-requisitos
> 2. Kubernetes
> 3. Criando o cluster
> 4. Instalação do Tekton
> 5. Instalação de tools

## 1. Pré-requisito

Para realização desse workshop é necessário que você tenha um computador com `docker` instalado e de preferência com o sistema operacional `Linux`. Se precisar de ajuda para instalar o `docker` utilize essa [documentação](https://docs.docker.com/desktop/).  
Para validar se esta tudo certo com a sua instalação do `docker` execute o seguinte comando:

```bash
docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```
## 2. Kubernetes

O `tekton` é executado no cluster `kubernetes`. Portanto vamos precisamos instânciar um cluster para o workshop e podemos fazer isso de várias formas. Nesse workshop vamos utilizar o [kind](https://kind.sigs.k8s.io/).

Para utilizar o `kind` é bastante simples. 

Esses comandos instala o `kind` no linux.

```linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

Além do `kind` vamos precisar do `kubectl` para manipular o cluster.

Esses comandos instala o `kubectl` no linux.

```linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

### 3. Criando o cluster
### 4. Instalação do Tekton
### 5. Instalação de tools
