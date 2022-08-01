#!/bin/bash
set -x 
echo "Executando Sonar"
appname=$1

#apt-get update 
#apt-get install -y curl unzip

#export SONAR_SCANNER_VERSION=4.7.0.2747
#export SONAR_SCANNER_HOME=$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux
#curl --create-dirs -sSLo $HOME/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip
#unzip -o $HOME/.sonar/sonar-scanner.zip -d $HOME/.sonar/
#export PATH=$SONAR_SCANNER_HOME/bin:$PATH
#export SONAR_SCANNER_OPTS="-server"

#sonar-scanner \
#  -Dsonar.organization=microservice-api \
#  -Dsonar.projectKey=$appname \
#  -Dsonar.sources=. \
#  -Dsonar.host.url=https://sonarcloud.io \
#  -Dsonar.language=python \
#  -Dsonar.sourceEncoding=UTF-8 \
#  -Dsonar.dynamicAnalysis=reuseReports \
#  -Dsonar.core.codeCoveragePlugin=cobertura \
#  -Dsonar.python.coverage.reportPaths=/coverage/coverage.xml 
