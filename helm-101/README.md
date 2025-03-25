
# Create the helmchart
```
helm create demo-app
```

# Follow along 
- Delete any files that were created in the template folder by above cmd.
- If you have previously created templates/manifests for service, deployment, configmap etc.  
Use those and copy-paste them in the `templates/` folder.
- Now browse each templates and check if you can templatize any values (in values.yaml)
  - These values could be repeatedly used names such as selectors, service/deployment names
  - OR They can be values which you want to propogate in your templatest while making sure you dont to make any manual mistakes. Ex: image names, configmap data etc.
- For every value you templatize, you have to make sure that value is not present in any of the templates/hard-coded (as it defeats the purpose and might cause incosistencies).


# Install the first one
```
# Make sure you are in the desired namespace

helm install mywebapp-release demo-app/ --values demo-app/values.yaml -n default

# This assumes that your values.yaml file is blank and uses direct values from your templates when the values were not even templatized.

helm install basic demo-app/

# If you then start templatizing some values and update the values.yaml, you can consider upgrading the current app and passing the values file to it

helm upgrade basic demo-app/ --values demo-app/values.yaml

OR 

# If you already have create the values.yaml file with the correct values and wish to deploy for the first time:

helm install basic demo-app/ --values demo-app/values.yaml
```

# Upgrade after templating
```
helm upgrade basic demo-app/ --values demo-app/values.yaml -n default
```

# Create dev/prod
```
k create namespace dev

k create namespace prod

helm install dev-env demo-app/ --values demo-app/values.yaml -f demo-app/values-dev.yaml -n dev

helm install prod-env demo-app/ --values demo-app/values.yaml -f demo-app/values-prod.yaml -n prod

helm ls --all-namespaces
```

# Create a helm package to push it to your git repo
```
# One level up the directory where you have your values.yaml file:

helm package demo-app/
Successfully packaged chart and saved it to: helm testing/demo-app-0.1.0.tgz

helm repo add --username gitea_admin --password password GPGtest https://gitea.local.com/api/packages/gitea_admin/helm
"GPGtest" has been added to your repositories

# Check if the repo has been added:
helm repo ls

# Update the helm repo
helm repo update

# Install the cm-push plugin:
helm plugin install https://github.com/chartmuseum/helm-push.git

# Make sure you are in the right directory, Push the .tgz package to the repo
helm cm-push demo-app-0.1.0.tgz GPGtest
Pushing demo-app-0.1.0.tgz to GPGtest...
Done.
```
- To search for all the versions in your helm package repo
  ```
  helm search repo helm-demo --versions
  NAME             	CHART VERSION	APP VERSION	DESCRIPTION                
  helm-demo/demo-app	0.1.1        	0.1.1      	A Helm chart for Kubernetes
  helm-demo/demo-app	0.1.0        	0.1.0      	A Helm chart for Kubernetes
  ```

- If you would like to use/work with one of these HELM charts, you can:
  ```
  mkdir test; cd test
  
  helm pull --untar helm-demo/demo-app --version v0.1.1

  tree demo-app/
  demo-app/
  ├── Chart.yaml
  ├── templates
  │   ├── NOTES.txt
  │   ├── app.yaml
  │   ├── cm.yaml
  │   ├── svc.yaml
  │   └── tests
  │       └── test-connection.yaml
  ├── values-dev.yaml
  ├── values-prod.yaml
  └── values.yaml

  2 directories, 9 files
  ```

## NOTES
- By having multiple `values-xxx.yaml` in your chart, you can acheive the kustomize effect on managing your k8s resources.
- Every `values.yaml` acts as your base and every `values-xxx.yaml` file acts like an Overlay.
- Once you upload the helm chart tar-ball to your repo, you wont immediately see it under the **Packages** section.
  - You will have to go to the package settings, where you will see the helm repo.
  - Then in the helm repo settings, you can link your parent git/code repo to it.
  - Now when you go under the **Packages** section, you can see your helm repo there.

## References
1. [Helm CheatSheet](https://helm.sh/docs/intro/cheatsheet/)
2. [Helm package upload](https://docs.gitea.com/usage/packages/helm)
3. [Helm Chart creation walkthrough](https://youtu.be/spCdNeNCuFU?si=wgT8B5pD7M4YJfAP)