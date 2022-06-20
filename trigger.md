kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml

kubectl get pods --namespace tekton-pipelines 
NAME                                                READY   STATUS    RESTARTS   AGE
tekton-dashboard-57cf45447c-fmcgw                   1/1     Running   0          3h33m
tekton-pipelines-controller-5cfb9b8cfc-ppg4r        1/1     Running   0          3h33m
tekton-pipelines-webhook-6c9d4d5798-4jfl8           1/1     Running   0          3h33m
tekton-triggers-controller-668df9f855-vpgjc         1/1     Running   0          46s
tekton-triggers-core-interceptors-55d8cfbd6-dq775   1/1     Running   0          44s
tekton-triggers-webhook-55574b569b-nscvl            1/1     Running   0          46s



curl -X POST \
  http://localhost:8080 \
  -H 'Content-Type: application/json' \
  -d '{ "commit_sha": "22ac84e04fd2bd9dce8529c9109d5bfd61678b29" }'



tkn tb  list
NAME                   AGE
gitea-triggerbinding   1 minute ago


kubectl get pods,svc -leventlistener=gitea-webhook



kubectl port-forward service/el-gitea-webhook 8080