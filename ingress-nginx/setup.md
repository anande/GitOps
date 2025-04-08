```
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

$ helm search repo ingress-nginx

$ helm pull --untar ingress-nginx/ingress-nginx

$ cd ingress-nginx 

$ helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace


```