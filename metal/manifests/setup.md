#### Install using k8s manifest

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
```
- Check the name of the docket network assigned to your k3d cluster using :  
```
docker network ls
```
- Inspect your docker network to find out the Subnet/CIDR :  
```
docker network inspect k3d-ingress-test --format='{{json .IPAM.Config}}'
```
- Enter the details and Check the range of usable IP-addresses :  
https://visualsubnetcalc.com

- Exclude the nodes "InternalIP" from this and define the Pool :  
```
spec:
  addresses:
  - 172.18.0.120-172.18.0.130
```
- Then apply the manifests:
```
k apply -f svc.yaml          ## This has the svc+deployment definition
k apply -f first-pool.yaml
k apply -f l2adv.yaml 

```
- Check if your service (currently set to type=LoadBalancer) gets an IP and test with curl:
```
curl 172.18.0.121
welcome to my web app!
```
- Now that IP based service connectivity works, Lets add ingress for DNS name based,  
Edit the `svc.yaml` and remove the `type: LoadBalancer` spec. This will convert the  
active service to `type: ClusterIP` which can be confimed.

- Apply the ingress manifest by setting `ingress.class: "traefik"` since k3d by  
default uses traefik.

- Check if your Ingress resource is created and its got the IP from the right subnet.
- Add the hostname `host: web-app-1.home-k8s.lab` to your laptops `/etc/hosts` file:
```
echo "172.18.0.120 web-app-1.home-k8s.lab" >> /etc/hosts
```
- Now check curl can pull using the hostname :  
```
curl web-app-1.home-k8s.lab
welcome to my web app!
```
