k3d cluster create cilium-demo \
  --servers 1 \
  --agents 1 \
  --api-port=6443 \
  --k3s-arg '--disable=servicelb@server:0' \
  --k3s-arg '--disable=metrics-server@server:0' \
  --port 8080:80@loadbalancer \
  --wait

  --k3s-arg '--disable=traefik@server:0' \
  --k3s-arg '--disable=traefik@agent:0' \
  --k3s-arg "--disable-network-policy@server:0" \
  --k3s-arg "--disable-network-policy@agent:0" \
  --k3s-arg "--flannel-backend=none@server:0" \
  --k3s-arg "--flannel-backend=none@agent:0" \



# Cilium Gateway API

Make sure the following CRD's are present

```
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/experimental-install.yaml

kubectl get crd \
  gatewayclasses.gateway.networking.k8s.io \
  gateways.gateway.networking.k8s.io \
  httproutes.gateway.networking.k8s.io \
  referencegrants.gateway.networking.k8s.io \
  tlsroutes.gateway.networking.k8s.io
```

Cilium is installed using:
```
cilium install --version v1.17.1 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set gatewayAPI.enabled=true 

cilium status --wait

cilium config view | grep -w "enable-gateway-api"

kubectl get GatewayClass
NAME     CONTROLLER                     ACCEPTED   AGE
cilium   io.cilium/gateway-controller   True       3m7s
```

## HTTP Path Match

Deploy the [Bookinfo Application](https://istio.io/v1.12/docs/examples/bookinfo/)

```
cd HTTP\ Path\ Match

root@server:~# kubectl apply -f /opt/bookinfo.yml
service/details created
serviceaccount/bookinfo-details created
deployment.apps/details-v1 created
service/ratings created
serviceaccount/bookinfo-ratings created
deployment.apps/ratings-v1 created
service/reviews created
serviceaccount/bookinfo-reviews created
deployment.apps/reviews-v1 created
deployment.apps/reviews-v2 created
deployment.apps/reviews-v3 created
service/productpage created
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created
root@server:~# kubectl get pods
NAME                              READY   STATUS              RESTARTS   AGE
details-v1-67894999b5-rdg5k       0/1     ContainerCreating   0          2s
productpage-v1-7bd5bd857c-ksqg4   0/1     ContainerCreating   0          2s
ratings-v1-676ff5568f-f4lc9       0/1     ContainerCreating   0          2s
reviews-v1-f5b4b64f-zwn9v         0/1     ContainerCreating   0          2s
reviews-v2-74b7dd9f45-njd9s       0/1     ContainerCreating   0          2s
reviews-v3-65d744df5c-cmss6       0/1     ContainerCreating   0          2s
root@server:~# kubectl get svc
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.96.24.85     <none>        9080/TCP   6s
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP    7m16s
productpage   ClusterIP   10.96.47.122    <none>        9080/TCP   6s
ratings       ClusterIP   10.96.71.249    <none>        9080/TCP   6s
reviews       ClusterIP   10.96.181.159   <none>        9080/TCP   6s

kubectl apply -f basic-http.yaml

kubectl get svc

kubectl get gateway

GATEWAY=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY
```
Http Path matching:
```
curl --fail -s http://$GATEWAY/details/1 | jq
```
Http Header Matching
```
curl -v -H 'magic: foo' "http://$GATEWAY?great=example"
```

## HTTPS Gateway

Create certificates for bookinfo and hipsterinfo applications
```
mkcert '*.cilium.rocks'
Created a new local CA 💥
Note: the local CA is not installed in the system trust store.
Run "mkcert -install" for certificates to be trusted automatically ⚠️

Created a new certificate valid for the following names 📜
 - "*.cilium.rocks"

Reminder: X.509 wildcards only go one level deep, so this won't match a.b.cilium.rocks ℹ️

The certificate is at "./_wildcard.cilium.rocks.pem" and the key at "./_wildcard.cilium.rocks-key.pem" ✅

It will expire on 28 June 2027 🗓
```
Create k8s TLS secret
```
kubectl create secret tls demo-cert \
  --key=_wildcard.cilium.rocks-key.pem \
  --cert=_wildcard.cilium.rocks.pem
```
Deploy the Gateway
```
kubectl apply -f basic-https.yaml
gateway.gateway.networking.k8s.io/tls-gateway created
httproute.gateway.networking.k8s.io/https-app-route-1 created
httproute.gateway.networking.k8s.io/https-app-route-2 created

kubectl get gateway tls-gateway

GATEWAY=$(kubectl get gateway tls-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY

mkcert -install

curl -s \
  --resolve bookinfo.cilium.rocks:443:${GATEWAY} \
  https://bookinfo.cilium.rocks/details/1 | jq

```


## TLS Route

TLS Passthrough with Gateway API

```
cd TLS\ Route

kubectl create configmap nginx-configmap --from-file=nginx.conf=./nginx.conf

kubectl apply -f tls-service.yaml

kubectl get svc,deployment my-nginx

kubectl apply -f tls-gateway.yaml -f tls-route.yaml

kubectl get gateway cilium-tls-gateway

GATEWAY=$(kubectl get gateway cilium-tls-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY

kubectl get tlsroutes.gateway.networking.k8s.io -o json | jq '.items[0].status.parents[0]'

curl -v \
  --resolve "nginx.cilium.rocks:443:$GATEWAY" \
  "https://nginx.cilium.rocks:443"
```  

## Traffic Splitting

HTTP Load Balancing with Gateway API

```
cd Traffic\ Splitting

kubectl apply -f echo-servers.yaml

kubectl get pods

kubectl get svc

kubectl apply -f load-balancing-http-route.yaml
```

#### Even Traffic Splitting 

GATEWAY=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY

curl --fail -s http://$GATEWAY/echo

for _ in {1..500}; do
  curl -s -k "http://$GATEWAY/echo" >> curlresponses.txt;
done

#### 99/1 Traffic Splitting

kubectl edit httproute load-balancing-route

Replace the weights from 50 for both echo-1 and echo-2 to 99 for echo-1 and 1 for echo-2.

for _ in {1..500}; do
  curl -s -k "http://$GATEWAY/echo" >> curlresponses991.txt;
done

grep -o "Hostname: echo-." curlresponses991.txt | sort | uniq -c