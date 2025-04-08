###### Add the ceph rool helm repo  
`helm repo add rook-release https://charts.rook.io/release`

###### Download the ceph charts for  

- rook operator :  
`helm pull --untar rook-release/rook-ceph`  
- rook cluster :  
`helm pull --untar rook-release/rook-ceph-cluster`  

References:  
1. [Helm Ceph Cluster](https://rook.io/docs/rook/v1.8/helm.html)
2. [Nare P's single node ceph rook cluster](https://www.youtube.com/watch?v=HpKOO3XvWvk)

## Using Ceph rook Manifests

Create a directory on system where you are running K3D:
`mkdir -p /var/lib/rook`

Create the K3D cluster and bind mount this to all nodes:
```
k3d cluster create ceph-rook-prod \
--agents 1 \
--port 8080:80@loadbalancer \
--volume /var/lib/rook:/var/lib/rook@all
```

Clone the rook repo:
```
git clone --single-branch --branch v1.13.1 https://github.com/rook/rook.git
cd rook/deploy/examples
```

Apply operator:
```
kubectl create -f common.yaml
kubectl create -f crds.yaml
kubectl create -f operator.yaml
```

Configure a Cluster with hostPath that will use `/var/lib/rook` for Storage
```
kubectl apply -f cluster.yaml
```
