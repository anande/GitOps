### Steps to deploy gitea locally

The following steps build a gitea environment which auto-enables gitea-actions (similar to github actions) alongwith act-runners (a.k.a git runnners) running as pods in the same k8s-cluster+namespace using the dynamically runner token to auto-register the runners to the git repos [1].

The more the number of runners, they faster the actions are processed. This though - comes at the compute resource cost to have the runner idle waiting on some actions to execute.

- Verify that you are logged into the gitea-namespace/context
```
kubectl config get-contexts
CURRENT   NAME             CLUSTER          AUTHINFO              NAMESPACE
          argocd-cluster                                          
          docker-desktop   docker-desktop   docker-desktop        
*         k3d-gitea-new    k3d-gitea-new    admin@k3d-gitea-new  

(If not using the gitea-context - switch to it)

k config use-context k3d-gitea-new
Switched to context "k3d-gitea-new".
```

- Install Gitea using helm chart

`helm install gitea . -f values.yaml -n gitea --create-namespace`

- Use `k9s` to monitor resources in `gitea` namespace

- Login to the webUI using username/password from the helm values.yaml

###### References:
1. https://gitea.com/gitea/helm-chart/pulls/666
2. 