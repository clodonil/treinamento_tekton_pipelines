#!/usr/bin/env sh
ls -l
docker build -t appbuid .
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy:0.20.2 appbuid:latest
