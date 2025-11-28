Add the nginx-ingress helm repo and download the chart, make changes only if required, else you should be good to go

```
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

$ helm search repo ingress-nginx

$ helm pull --untar ingress-nginx/ingress-nginx

$ cd ingress-nginx 

$ helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

```

It will install the controller in the ingress-nginx namespace.

### Local Testing

Let's create a simple web server and the associated service:
```
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo
```
Then create an ingress resource. The following example uses a host that maps to localhost:
```
kubectl create ingress demo-localhost --class=nginx \
  --rule="demo.localdev.me/*=demo:80"
```
Now, forward a local port to the ingress controller:
```
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
```

At this point, you can access your deployment using curl ;
```
curl --resolve demo.localdev.me:8080:127.0.0.1 http://demo.localdev.me:8080
```
You should see a HTML response containing text like "It works!".
