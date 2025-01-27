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