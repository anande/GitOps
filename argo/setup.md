#### Instructions to setup ArgoCD locally on laptop

```
(For MacOS)
brew install kubectl

brew install k3d

k3d version

k3d cluster create argocd-cluster --config cluster-config.yaml
INFO[0000] Using config file cluster-config.yaml (k3d.io/v1alpha2#simple) 
WARN[0000] Default config apiVersion is 'k3d.io/v1alpha5', but you're using 'k3d.io/v1alpha2': consider migrating. 
INFO[0000] Prep: Network                                
INFO[0000] Created network 'k3d-argocd-cluster'         
INFO[0000] Created image volume k3d-argocd-cluster-images 
INFO[0000] Starting new tools node...                   
INFO[0000] Starting node 'k3d-argocd-cluster-tools'     
INFO[0001] Creating node 'k3d-argocd-cluster-server-0'  
INFO[0001] Creating node 'k3d-argocd-cluster-agent-0'   
INFO[0002] Creating node 'k3d-argocd-cluster-agent-1'   
INFO[0002] Creating LoadBalancer 'k3d-argocd-cluster-serverlb' 
INFO[0002] Using the k3d-tools node to gather environment information 
INFO[0003] Starting new tools node...                   
INFO[0003] Starting node 'k3d-argocd-cluster-tools'     
INFO[0004] Starting cluster 'argocd-cluster'            
INFO[0004] Starting servers...                          
INFO[0005] Starting node 'k3d-argocd-cluster-server-0'  
INFO[0012] Starting agents...                           
INFO[0012] Starting node 'k3d-argocd-cluster-agent-1'   
INFO[0013] Starting node 'k3d-argocd-cluster-agent-0'   
INFO[0018] Starting helpers...                          
INFO[0018] Starting node 'k3d-argocd-cluster-serverlb'  
INFO[0025] Injecting records for hostAliases (incl. host.k3d.internal) and for 5 network members into CoreDNS configmap... 
INFO[0027] Cluster 'argocd-cluster' created successfully! 
INFO[0027] You can now use it like this:                
kubectl cluster-info

kubectl cluster-info
Kubernetes control plane is running at https://0.0.0.0:58171
CoreDNS is running at https://0.0.0.0:58171/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://0.0.0.0:58171/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

kubectl get no 
NAME                          STATUS   ROLES                  AGE   VERSION
k3d-argocd-cluster-agent-0    Ready    <none>                 39s   v1.30.4+k3s1
k3d-argocd-cluster-agent-1    Ready    <none>                 39s   v1.30.4+k3s1
k3d-argocd-cluster-server-0   Ready    control-plane,master   45s   v1.30.4+k3s1

k create ns argocd
k get ns
```

#### For kubernetes manifest based ARGO install 
```
k apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/heads/master/manifests/install.yaml

k get deploy -n argocd
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
argocd-applicationset-controller   1/1     1            1           100s
argocd-dex-server                  1/1     1            1           100s
argocd-notifications-controller    1/1     1            1           100s
argocd-redis                       1/1     1            1           99s
argocd-repo-server                 1/1     1            1           99s
argocd-server                      1/1     1            1           99s

 k get svc -n argocd
NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
argocd-applicationset-controller          ClusterIP   10.43.6.115     <none>        7000/TCP,8080/TCP            2m46s
argocd-dex-server                         ClusterIP   10.43.63.102    <none>        5556/TCP,5557/TCP,5558/TCP   2m46s
argocd-metrics                            ClusterIP   10.43.68.134    <none>        8082/TCP                     2m46s
argocd-notifications-controller-metrics   ClusterIP   10.43.154.59    <none>        9001/TCP                     2m46s
argocd-redis                              ClusterIP   10.43.214.146   <none>        6379/TCP                     2m46s
argocd-repo-server                        ClusterIP   10.43.140.28    <none>        8081/TCP,8084/TCP            2m46s
argocd-server                             ClusterIP   10.43.146.207   <none>        80/TCP,443/TCP               2m46s
argocd-server-metrics                     ClusterIP   10.43.157.173   <none>        8083/TCP                     2m46s

k get statefulset -n argocd
```

#### For HELM based ARGO install  

```
$ helm repo add argo https://argoproj.github.io/argo-helm
"argo" has been added to your repositories

$ helm repo update

$ helm search repo argocd

$ helm pull --untar argo/argo-cd
```

#### For managing ARGO locally  
```
brew install argocd

argocd version
argocd: v2.13.3+a25c8a0
  BuildDate: 2025-01-03T20:00:35Z
  GitCommit: a25c8a0eef7830be0c2c9074c92dbea8ff23a962
  GitTreeState: clean
  GoVersion: go1.23.4
  Compiler: gc
  Platform: darwin/amd64
FATA[0000] Argo CD server address unspecified   

argocd version --client
argocd: v2.13.3+a25c8a0
  BuildDate: 2025-01-03T20:00:35Z
  GitCommit: a25c8a0eef7830be0c2c9074c92dbea8ff23a962
  GitTreeState: clean
  GoVersion: go1.23.4
  Compiler: gc
  Platform: darwin/amd64

k get all -n argocd  
```
#### Expose argocd-server service as NodePort

`k patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'`

#### Arogcd-apiserver access using port-forwarding

```
kubectl port-forward svc/argocd-server -n argocd 8080:443

Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
```
This will allow you to access the ArgoCD dashboard using :
http://localhost:8080

The username|password can be fetched using :

```
k -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
JXDiZZSVJ5YszJjO
```
### Changing the argocd admin password
```
$ argocd login localhost:8080
WARNING: server certificate had error: tls: failed to verify certificate: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
Username: admin
Password: 
'admin:login' logged in successfully
Context 'localhost:8080' updated

$ argocd account update-password
*** Enter password of currently logged in user (admin): 
*** Enter new password for user admin: 
*** Confirm new password for user admin: 
Password updated
Context 'localhost:8080' updated
```

#### NOTE:
`If you are adding a gitea instance running inside another k3d cluster, but running on the same underlying baremetal node(laptop), you can add the repo using the link like: http://k3d-gitea-cluster-server-0:31002/gitea_admin/testing.git`

### From CLI:
```
## repoURL should be created like:
## <service_name>.<service_namespace>.svc.cluster.local:<gitea_port>

# argocd repo add http://gitea-http.gitea.svc.cluster.local:3000/gitea_admin/testing.git --type git --name git_act_runner
Repository 'http://gitea-http.gitea.svc.cluster.local:3000/gitea_admin/testing.git' added
```