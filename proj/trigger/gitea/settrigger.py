#!/usr/bin/env python
import os
import requests
gitea_user = "user1"
gitea_pwd = "redepp"
webhookURL = "http://el-gitea-webhook.default.svc:8080"
repo = 'app1'
giteaURL = "http://" + gitea_user + ":" + gitea_pwd + '@localhost:30005'
# configure webhook on tekton-tutorial-greeter
data_webhook = '{"type": "gogs", "config": { "url": "' + webhookURL + '", "content_type": "json"}, "events": ["push"], "active": true}'
headers = {'Content-Type': 'application/json'}
print(giteaURL + "/api/v1/repos/" + gitea_user + "/app1/hooks")
url = f"{giteaURL}/api/v1/repos/{gitea_user}/{repo}/hooks"
resp = requests.post(url = url, headers = headers, data = data_webhook)
if resp.status_code != 200 and resp.status_code != 201:
  print("Error configuring the webhook (status code: {})".format(resp.status_code))
  print(resp.content)
else:
  print("Configured webhook: " + webhookURL)