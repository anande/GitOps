###### Download the helm chart 
```
 helm repo add minio https://charts.min.io/
 helm repo update
 helm pull --untar minio/minio --version 5.4.0
```

 ###### Modify the values.yaml as required
```
helm install minio -n minio --create-namespace -f values.yaml minio/minio
NAME: minio
LAST DEPLOYED: Mon Jan 20 17:52:04 2025
NAMESPACE: minio
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
MinIO can be accessed via port 9000 on the following DNS name from within your cluster:
minio.minio.cluster.local

To access MinIO from localhost, run the below commands:

  1. export POD_NAME=$(kubectl get pods --namespace minio -l "release=minio" -o jsonpath="{.items[0].metadata.name}")

  2. kubectl port-forward $POD_NAME 9000 --namespace minio

Read more about port forwarding here: http://kubernetes.io/docs/user-guide/kubectl/kubectl_port-forward/

You can now access MinIO server on http://localhost:9000. Follow the below steps to connect to MinIO server with mc client:

  1. Download the MinIO mc client - https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart

  2. export MC_HOST_minio-local=http://$(kubectl get secret --namespace minio minio -o jsonpath="{.data.rootUser}" | base64 --decode):$(kubectl get secret --namespace minio minio -o jsonpath="{.data.rootPassword}" | base64 --decode)@localhost:9000

  3. mc ls minio-local
```

###### Do portwarding to localport

`kubectl port-forward svc/minio -n minio 9001:9001`

###### Access the webUI
http://localhost:9001/browser
u: `minioadmin`
p: `minioadmin`