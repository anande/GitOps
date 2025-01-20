
```
$ helm repo add jetstack https://charts.jetstack.io --force-update
"jetstack" has been added to your repositories
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "harbor" chart repository
...Successfully got an update from the "gitea-charts" chart repository
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "minio" chart repository
...Successfully got an update from the "crossplane-stable" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈

$ helm pull --untar jetstack/cert-manager  

$ helm install cert-manager bitnami/cert-manager --namespace cert-manager --set installCRDs=true --create-namespace
NAME: cert-manager
LAST DEPLOYED: Mon Jan 20 22:57:36 2025
NAMESPACE: cert-manager
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: cert-manager
CHART VERSION: 1.4.3
APP VERSION: 1.16.3

Did you know there are enterprise versions of the Bitnami catalog? For enhanced secure software supply chain features, unlimited pulls from Docker, LTS support, or application customization, see Bitnami Premium or Tanzu Application Catalog. See https://www.arrow.com/globalecs/na/vendors/bitnami for more information.

** Please be patient while the chart is being deployed **

In order to begin using certificates, you will need to set up Issuer or ClustersIssuer resources.

https://cert-manager.io/docs/configuration/

To configure a new ingress to automatically provision certificates, you will find some information in the following link:

https://cert-manager.io/docs/usage/ingress/

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - cainjector.resources
  - controller.resources
  - webhook.resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
```
