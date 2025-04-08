[Kustomize Part 2 Session Recording](https://raxglobal.sharepoint.com/:v:/r/sites/OpenStackPrivateCloudandKubernetesShiftOperations/Brown%20Bags/Kustomize%20Part-2.mp4?csf=1&web=1&e=uozJAQ&nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJTdHJlYW1XZWJBcHAiLCJyZWZlcnJhbFZpZXciOiJTaGFyZURpYWxvZy1MaW5rIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXcifX0%3D)

# HELM Post Render to apply changes via kustomize  

### Dry Run helm

```
cd Gitops/helm-part-1

helm install webapp1 webapp1/ --values webapp1/values.yaml --dry-run |less

OR 

helm template webapp webapp1/ --values webapp1/values.yaml |less
```

### Dry Run Kustomize  

```
kubectl apply -k . --dry-run=client
configmap/base-index-html-config-v1 created (dry run)
service/base-web-app1-v1 created (dry run)
deployment.apps/base-web-app1-v1 created (dry run)

OR 

kustomize build . |less
```

### Render HELM manifests into a directory  

```
helm template webapp webapp1/ \
--values webapp1/values.yaml \
--namespace default \
--output-dir ../kustomize-part-2/rendered-base

wrote ../kustomize-part-2/rendered-base/webapp1/templates/cm.yaml
wrote ../kustomize-part-2/rendered-base/webapp1/templates/svc.yaml
wrote ../kustomize-part-2/rendered-base/webapp1/templates/app.yaml
```

### For rendering overlay manifests  

```
helm template webapp webapp1/ \
--values webapp1/values.yaml \
-f webapp1/values-dev.yaml \
--namespace dev \
--create-namespace \
--output-dir ../kustomize-part-2/rendered-dev

wrote ../kustomize-part-2/rendered-dev/webapp1/templates/cm.yaml
wrote ../kustomize-part-2/rendered-dev/webapp1/templates/svc.yaml
wrote ../kustomize-part-2/rendered-dev/webapp1/templates/app.yaml
```

### Run the post-renderer script  
```
chmod +x kustomize-post-renderer.sh

./kustomize-post-renderer.sh
```

### Run helm install with post-render  
```
helm install webapp1 ../helm-part-1/webapp1/ --post-renderer ./kustomize-post-renderer.sh
NAME: webapp1
LAST DEPLOYED: Tue Apr  8 11:59:35 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
App Deployed!

You can access this app by running below command :

kubectl port-forward svc/mywebapp 8282:80 -n default

And then in your browser goto : http://localhost:8282
```

## Test creating post render in dev namespace  
```
kubectl create ns dev

kubens dev

helm install webapp1-dev ../helm-part-1/webapp1/ --post-renderer ./kustomize-post-renderer-dev.sh
NAME: webapp1-dev
LAST DEPLOYED: Tue Apr  8 12:07:59 2025
NAMESPACE: dev
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
App Deployed!

You can access this app by running below command :

kubectl port-forward svc/mywebapp 8282:80 -n dev

And then in your browser goto : http://localhost:8282
```

### Upgrade existing dev namespace chart applying a kustomize patch  
```
helm upgrade webapp1-dev ../helm-part-1/webapp1/ --post-renderer ./kustomize-post-renderer-dev.sh --namespace dev
Release "webapp1-dev" has been upgraded. Happy Helming!
NAME: webapp1-dev
LAST DEPLOYED: Tue Apr  8 12:21:30 2025
NAMESPACE: dev
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
App Deployed!

You can access this app by running below command :

kubectl port-forward svc/mywebapp 8282:80 -n dev

And then in your browser goto : http://localhost:8282
```

### TODO for you:

When I run post-render args like below, it should work:
```
helm template webapp1-dev ../helm-part-1/webapp1/ --post-renderer ./kustomize-post-renderer-dev.sh --namespace dev --create-namespace --post-renderer-args "--env dev" --output-dir rendered-dev
wrote rendered-dev/webapp1/templates/cm.yaml
wrote rendered-dev/webapp1/templates/svc.yaml
wrote rendered-dev/webapp1/templates/app.yaml
```
Hint: Check commented 'case' in `kustomize-post-renderer-dev.sh`