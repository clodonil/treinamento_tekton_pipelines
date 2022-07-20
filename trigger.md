# Em Desenvolvimento: Previsão 18/07/2022

```bash
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
```

```bash
kubectl get pods --namespace tekton-pipelines 
NAME                                                READY   STATUS    RESTARTS   AGE
tekton-dashboard-57cf45447c-fmcgw                   1/1     Running   0          3h33m
tekton-pipelines-controller-5cfb9b8cfc-ppg4r        1/1     Running   0          3h33m
tekton-pipelines-webhook-6c9d4d5798-4jfl8           1/1     Running   0          3h33m
tekton-triggers-controller-668df9f855-vpgjc         1/1     Running   0          46s
tekton-triggers-core-interceptors-55d8cfbd6-dq775   1/1     Running   0          44s
tekton-triggers-webhook-55574b569b-nscvl            1/1     Running   0          46s
```

# Instalando o gita

```bash
kubectl create namespace tools
kubectl -n tools apply -f $WORKSHOP_HOME/proj/trigger/gitea/
```

```bash
kubectl get pods -n tools
NAME                     READY   STATUS    RESTARTS   AGE
gitea-8554476b8b-mm6gc   1/1     Running   0          27s
```
http://localhost:30005/

![trigger](img/image40.png)

![trigger](img/image42.png)

## Criar os repositórios e WebHook

```bash
export USER='XXXX'
export PASS='XXXX'
export GIT='http://172.18.211.138:30005'
python3 $WORKSHOP_HOME/proj/trigger/gitea/gitea_cli.py -n -r sharedlibrary -u $USER -p $PASS
python3 $WORKSHOP_HOME/proj/trigger/gitea/gitea_cli.py -w -r sharedlibrary -u $USER -p $PASS

python3 $WORKSHOP_HOME/proj/trigger/gitea/gitea_cli.py -n -r app1-python -u $USER -p $PASS
python3 $WORKSHOP_HOME/proj/trigger/gitea/gitea_cli.py -w -r app1-python -u $USER -p $PASS
```

```bash
cd $WORKSHOP_HOME/src/sharedlibrary
git init
git add *
git commit -m "first commit"
git remote add origin $GIT/user1/sharedlibrary.git
git push -u origin master
```


# Inicializando o repositório de código

## Criando o trigger

# Create ServiceAccount, Roles and Role Bindings

Precisamos consultar objetos do Kubernetes, criar Triggers e finalmente implantar o Knative Service como parte dos exercícios deste capítulo. Vamos criar uma conta de serviço do Kubernetes e adicionar as funções/permissões necessárias:



# EventListener

# Trigger-Bindings
```yaml
{
  "ref": "refs/heads/master",
  "before": "a4bfa24015149e24d501b6f99229d49ab121f629",
  "after": "a4bfa24015149e24d501b6f99229d49ab121f629",
  "compare_url": "",
  "commits": [
    {
      "id": "a4bfa24015149e24d501b6f99229d49ab121f629",
      "message": "first commit\n",
      "url": "http://localhost:3000/user1/app1/commit/a4bfa24015149e24d501b6f99229d49ab121f629",
      "author": {
        "name": "Clodonil Trigo",
        "email": "clodonil@nisled.org",
        "username": ""
      },
      "committer": {
        "name": "Clodonil Trigo",
        "email": "clodonil@nisled.org",
        "username": ""
      },
      "verification": null,
      "timestamp": "0001-01-01T00:00:00Z",
      "added": null,
      "removed": null,
      "modified": null
    }
  ],
  "head_commit": {
    "id": "a4bfa24015149e24d501b6f99229d49ab121f629",
    "message": "first commit\n",
    "url": "http://localhost:3000/user1/app1/commit/a4bfa24015149e24d501b6f99229d49ab121f629",
    "author": {
      "name": "Clodonil Trigo",
      "email": "clodonil@nisled.org",
      "username": ""
    },
    "committer": {
      "name": "Clodonil Trigo",
      "email": "clodonil@nisled.org",
      "username": ""
    },
    "verification": null,
    "timestamp": "0001-01-01T00:00:00Z",
    "added": null,
    "removed": null,
    "modified": null
  },
  "repository": {
    "id": 1,
    "owner": {"id":1,"login":"user1","full_name":"","email":"user1@localhost","avatar_url":"http://localhost:3000/user/avatar/user1/-1","language":"","is_admin":false,"last_login":"0001-01-01T00:00:00Z","created":"2022-06-21T00:43:25Z","restricted":false,"active":false,"prohibit_login":false,"location":"","website":"","description":"","visibility":"public","followers_count":0,"following_count":0,"starred_repos_count":0,"username":"user1"},
    "name": "app1",
    "full_name": "user1/app1",
    "description": "",
    "empty": false,
    "private": false,
    "fork": false,
    "template": false,
    "parent": null,
    "mirror": false,
    "size": 20,
    "html_url": "http://localhost:3000/user1/app1",
    "ssh_url": "git@localhost:user1/app1.git",
    "clone_url": "http://localhost:3000/user1/app1.git",
    "original_url": "",
    "website": "",
    "stars_count": 0,
    "forks_count": 0,
    "watchers_count": 1,
    "open_issues_count": 0,
    "open_pr_counter": 0,
    "release_counter": 0,
    "default_branch": "master",
    "archived": false,
    "created_at": "2022-06-21T00:44:00Z",
    "updated_at": "2022-06-21T00:46:14Z",
    "permissions": {
      "admin": false,
      "push": false,
      "pull": false
    },
    "has_issues": true,
    "internal_tracker": {
      "enable_time_tracker": true,
      "allow_only_contributors_to_track_time": true,
      "enable_issue_dependencies": true
    },
    "has_wiki": true,
    "has_pull_requests": true,
    "has_projects": true,
    "ignore_whitespace_conflicts": false,
    "allow_merge_commits": true,
    "allow_rebase": true,
    "allow_rebase_explicit": true,
    "allow_squash_merge": true,
    "default_merge_style": "merge",
    "avatar_url": "",
    "internal": false,
    "mirror_interval": ""
  },
  "pusher": {"id":1,"login":"user1","full_name":"","email":"user1@localhost","avatar_url":"http://localhost:3000/user/avatar/user1/-1","language":"","is_admin":false,"last_login":"0001-01-01T00:00:00Z","created":"2022-06-21T00:43:25Z","restricted":false,"active":false,"prohibit_login":false,"location":"","website":"","description":"","visibility":"public","followers_count":0,"following_count":0,"starred_repos_count":0,"username":"user1"},
  "sender": {"id":1,"login":"user1","full_name":"","email":"user1@localhost","avatar_url":"http://localhost:3000/user/avatar/user1/-1","language":"","is_admin":false,"last_login":"0001-01-01T00:00:00Z","created":"2022-06-21T00:43:25Z","restricted":false,"active":false,"prohibit_login":false,"location":"","website":"","description":"","visibility":"public","followers_count":0,"following_count":0,"starred_repos_count":0,"username":"user1"}
}
```
# Verificando se o 
 kubectl get pods,svc -leventlistener=gitea-webhook
NAME                                    READY   STATUS    RESTARTS   AGE
pod/el-gitea-webhook-67988887b8-mfzjt   1/1     Running   0          37s

NAME                       TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)             AGE
service/el-gitea-webhook   ClusterIP   10.96.67.26   <none>        8080/TCP,9000/TCP   11m



curl -X POST \
  http://localhost:8080 \
  -H 'Content-Type: application/json' \
  -d '{ "commit_sha": "22ac84e04fd2bd9dce8529c9109d5bfd61678b29" }'

http://el-gita-webhook.default.svc:8080/

curl -X POST \
  http://el-gita-webhook.default.svc:8080 \
  -H 'Content-Type: application/json' \
  -d '{ "commit_sha": "22ac84e04fd2bd9dce8529c9109d5bfd61678b29" }'

tekton-pipelines-controller.tekton-pipelines.svc:9090

tkn tb  list
NAME                   AGE
gitea-triggerbinding   1 minute ago


kubectl get pods,svc -leventlistener=gitea-webhook



kubectl port-forward service/el-gitea-webhook 8080