### Steps to deploy gitea locally

The following steps build a gitea environment which auto-enables gitea-actions (similar to github actions) alongwith act-runners (a.k.a git runnners) running as pods in the same k8s-cluster+namespace using the dynamically generated runner token to auto-register the runners to the git repos [1].

The more the number of runners, the faster the actions are processed. This though - comes at the compute resource cost to have the runner idle waiting on some actions to execute.

- Verify that you are logged into the k3s context
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

- Create local self-signed certs that you wish to use with gitea ingress:
```
$ mkcert gitea.local.com "*.local.com"

Created a new certificate valid for the following names 📜
 - "gitea.local.com"
 - "*.local.com"

Reminder: X.509 wildcards only go one level deep, so this won't match a.b.local.com ℹ️

The certificate is at "./gitea.local.com+1.pem" and the key at "./gitea.local.com+1-key.pem" ✅

It will expire on 26 April 2027 🗓
```

- Create a **gitea** namespace and use the cert+key to create the certificate secret (Make sure you are in the right working directory where the certs were generated in the above step):

```
$ k create ns gitea
namespace/gitea created

$ k -n gitea create secret tls gitea-ingress-tls-cert --key gitea.local.com+1-key.pem --cert gitea.local.com+1.
pem 
secret/gitea-ingress-tls-cert created
```


- Install Gitea using helm chart

`helm install gitea . -f values.yaml -n gitea --create-namespace`

- Use `k9s` to monitor resources in `gitea` namespace

- Make sure you update the `/etc/hosts` file with the address of the ingress.

- Login to the webUI using username/password from the helm values.yaml

###### Use Gitea Actions:

In order to use actions with hosted gitea runners, you need to manually have node installed inside the runner  
containers.

You can do that by either logging into the container manaully (using k9s shell):
```
gitea-act-runner-0:/data# apk add --no-cache nodejs
fetch https://dl-cdn.alpinelinux.org/alpine/v3.20/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.20/community/x86_64/APKINDEX.tar.gz
(1/7) Installing libgcc (13.2.1_git20240309-r0)
(2/7) Installing libstdc++ (13.2.1_git20240309-r0)
(3/7) Installing ada-libs (2.7.8-r0)
(4/7) Installing libbase64 (0.5.2-r0)
(5/7) Installing icu-data-en (74.2-r0)
Executing icu-data-en-74.2-r0.post-install
*
* If you need ICU with non-English locales and legacy charset support, install
* package icu-data-full.
*
(6/7) Installing icu-libs (74.2-r0)
(7/7) Installing nodejs (20.15.1-r0)
Executing busybox-1.36.1-r29.trigger
OK: 74 MiB in 39 packages
gitea-act-runner-0:/data# which node
/usr/bin/node
gitea-act-runner-0:/data# node -v
v20.15.1
```
OR adding a step like below in the gitea workflow:
```
      - name: install node
        run: apk add --no-cache nodejs
```
Then test the Actions using the example available [at this location](https://docs.gitea.com/usage/actions/quickstart#use-actions).

###### References:
1. https://gitea.com/gitea/helm-chart/pulls/666
2. [Fix for node package inside gitea runner container](https://forum.gitea.com/t/gitea-actions-cannot-find-node-in-path/7544/5)