
#### Install gcloud via homebrew (on MacOS)
```
brew install --cask google-cloud-sdk

gcloud init

gcloud components install gke-gcloud-auth-plugin
```

#### Create a k8s cluster 
```
gcloud container clusters create argocd --num-nodes=3 --zone=us-central1-a
```

#### Update kube-config
```
gcloud container clusters get-credentials argocd --zone=us-central1-a
```

#### Rename kube context from complex gke default name to a more simpler name
```
kubectl config rename-context gke_dumptest-452406_us-central1-a_argocd gke-argocd
Context "gke_dumptest-452406_us-central1-a_argocd" renamed to "gke-argocd".
```