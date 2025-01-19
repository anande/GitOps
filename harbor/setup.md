### Grab the helm charts
```
$ helm repo add harbor https://helm.goharbor.io
"harbor" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "gitea-charts" chart repository
...Successfully got an update from the "harbor" chart repository
...Successfully got an update from the "crossplane-stable" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈

$ helm fetch harbor/harbor --untar
```

Monitor the status of the helm deployed resources using `k9s`.  
Once all the resources are seen running/healthy, perform a port-forward of the  
`harbor` NodePort service to one of the local ports.

```
kubectl port-forward svc/harbor -n harbor 8888:80
Forwarding from 127.0.0.1:8888 -> 8080
Forwarding from [::1]:8888 -> 8080
```

Then login to the webUI on the following URL:  
[http://localhost:8888](http://localhost:8888/)  
u: `admin`  
p: `Harbor12345`
