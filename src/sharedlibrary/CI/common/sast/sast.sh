#!/usr/bin/env sh
ls -l
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/src/horusec horuszup/horusec-cli:latest horusec start -p /src/horusec -P $(pwd)

