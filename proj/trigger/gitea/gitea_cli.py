#!/usr/bin/env python
import os
import requests
import argparse

parser = argparse.ArgumentParser(description="Just an example",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("-w", "--webhook", action="store_true", help="criar um novo webhook")
parser.add_argument("-n", "--novo", action="store_true", help="cria um novo repositorio")
parser.add_argument("-r","--repositorio", help="Nome do repositorio")
parser.add_argument("-u","--user", help="Destination location")
parser.add_argument("-p","--password", help="Destination location")
args = parser.parse_args()
config = vars(args)


gitea_user = config['user']
gitea_pwd = config['password']
repo = config['repositorio']
gitea_ip = '172.18.211.138'
gitea_port = '30005'
webhookURL = "http://el-gitea-webhook.tools.svc:8080"

giteaURL = f"http://{gitea_user}:{gitea_pwd}@{gitea_ip}:{gitea_port}"
headers = {'Content-Type': 'application/json'}


def create_webhook(repo):
    # configure webhook on tekton-tutorial-greeter
    data_webhook = '{"type": "gogs", "config": { "url": "' + webhookURL + '", "content_type": "json"}, "events": ["push"], "active": true}'
    url = f"{giteaURL}/api/v1/repos/{gitea_user}/{repo}/hooks"
    resp = requests.post(url = url, headers = headers, data = data_webhook)
    if resp.status_code != 200 and resp.status_code != 201:
      print("Error configuring the webhook (status code: {})".format(resp.status_code))
      print(resp.content)
    else:
      print("Repositorio criado: " + repo)

def create_repo(name):
    repo_name = '{"name":"'+ name + '" }"'
    url = f"{giteaURL}/api/v1/user/repos/"
    resp = requests.post(url = url, headers = headers, data = repo_name)
    if resp.status_code != 200 and resp.status_code != 201:
      print("Problema para criar o repositorio (status code: {})".format(resp.status_code))
      print(resp.content)
    else:
      print("Configured webhook: " + webhookURL)

if __name__ == "__main__":
 if config['novo']:
   create_repo(repo)
 elif config['webhook']:
   create_webhook(repo)  

