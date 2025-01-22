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

#### Create local CA and certs using [mkcert](https://github.com/FiloSottile/mkcert)
```
brew install mkcert nss
```

#### Install the CA
```
mkcert -install

Created a new local CA 💥
Sudo password:
The local CA is now installed in the system trust store! ⚡️
The local CA is now installed in the Firefox trust store (requires browser restart)! 🦊
````
#### Create cert associated with a domain

```
mkcert registry.harbor.com "*.harbor.com"

Created a new certificate valid for the following names 📜
 - "registry.harbor.com"
 - "*.harbor.com"

Reminder: X.509 wildcards only go one level deep, so this won't match a.b.harbor.com ℹ️

The certificate is at "./registry.harbor.com+1.pem" and the key at "./registry.harbor.com+1-key.pem" ✅

It will expire on 21 April 2027 🗓
```

#### Create secret to store the certs in the desired namespace
```
k -n harbor create secret tls harbor-ingress-tls-cert --key ./registry.harbor.com+1-key.pem --cert ./registry.harbor.com+1.pem 
```

#### Install the charts
```
$ helm install harbor . -f values.yaml -n harbor --create-namespace
```

#### For 'NodePort' based harbor
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

#### For 'Ingress' based harbor  

Use `className: "traefik"` in the `values.yaml` file.  
OR If the service does not come up with an external-IP associated with Ingress,  
Use k9s to edit the ingress resource and change the classname to traefik,
set the externalIP manually under:
```
status:
  loadBalancer:
    ingress:
    - ip: 172.20.0.2
```

Then login to the webUI on the following URL:  
[http://localhost:8888](http://localhost:8888/)  
u: `admin`  
p: `Harbor12345`  

To login to the harbor registry:  
```
docker login https://registry.harbor.com
Username: admin
Password: 
Login Succeeded
```

To **"push"** an image to the local registry:
```
# Check if you have the image locally available first:
# This local image availability is because you might have previously pulled
# from DockerHUB or built an image locally

$ docker images


# Now tag that local image with the tag you want to use with harbot registry:

$ docker tag gitea/gitea:nightly registry.harbor.com/k8s/gitea/gitea:v0.0.1 


Once tagged, verify that tag :

$ docker images
REPOSITORY                                    TAG                                                                          IMAGE ID       CREATED         SIZE
gitea/gitea                                   nightly                                                                      eeefd5307798   4 days ago      177MB
registry.harbor.com/k8s/gitea/gitea           v0.0.1                                                                       eeefd5307798   4 days ago      177MB


You can see 2 versions/tags of the same image.
Now you can push the newly tagged image to the harbor registry:

$ docker push registry.harbor.com/k8s/gitea/gitea:v0.0.1
The push refers to repository [registry.harbor.com/k8s/gitea/gitea]
1d7a4b1b7071: Pushed 
fb9cf4ab91ae: Pushed 
932012a5d12b: Pushed 
9cdaf52b59bf: Pushed 
fae8ee7a16a3: Pushed 
272112bb80ae: Pushed 
a0904247e36a: Pushed 
v0.0.1: digest: sha256:3e30f6e40fa17bb2902fe448791226f4d6a3b606905909bbd4818566b54ce2a6 size: 1785
```

Sign the images:
```
# Cosign is used to sign the images that will be maintained by harbor
# Generate the keypair 

$ cosign generate-key-pair
Enter password for private key: 
Enter password for private key again: 
Private key written to cosign.key
Public key written to cosign.pub


# Now sign the image, accepting all the warnings (password: Hit ENTER)

$ cosign sign -key cosign.key registry.harbor.com/k8s/gitea/gitea:v0.0.1
WARNING: the -key flag is deprecated and will be removed in a future release. Please use the --key flag instead.
Enter password for private key: 
WARNING: Image reference registry.harbor.com/k8s/gitea/gitea:v0.0.1 uses a tag, not a digest, to identify the image to sign.
    This can lead you to sign a different image than the intended one. Please use a
    digest (example.com/ubuntu@sha256:abc123...) rather than tag
    (example.com/ubuntu:latest) for the input to cosign. The ability to refer to
    images by tag will be removed in a future release.

WARNING: "registry.harbor.com/k8s/gitea/gitea" appears to be a private repository, please confirm uploading to the transparency log at "https://rekor.sigstore.dev"
Are you sure you would like to continue? [y/N] y

	The sigstore service, hosted by sigstore a Series of LF Projects, LLC, is provided pursuant to the Hosted Project Tools Terms of Use, available at https://lfprojects.org/policies/hosted-project-tools-terms-of-use/.
	Note that if your submission includes personal data associated with this signed artifact, it will be part of an immutable record.
	This may include the email address associated with the account with which you authenticate your contractual Agreement.
	This information will be used for signing this artifact and will be stored in public transparency logs and cannot be removed later, and is subject to the Immutable Record notice at https://lfprojects.org/policies/hosted-project-tools-immutable-records/.

By typing 'y', you attest that (1) you are not submitting the personal data of any other person; and (2) you understand and agree to the statement and the Agreement terms at the URLs listed above.
Are you sure you would like to continue? [y/N] y
tlog entry created with index: 164349321
Pushing signature to: registry.harbor.com/k8s/gitea/gitea

```

#### Example of NGINX image being pushed to harbor:
```
$ docker tag nginx:latest registry.harbor.com/k8s/nginx:v0.1
$ docker push registry.harbor.com/k8s/nginx:v0.1
$ cosign sign -key cosign.key registry.harbor.com/k8s/nginx:v0.1
```

#### Docker pull example
```
# Since there are pull rules set on HIGH rated vulnerabilities found in harbor images

$ docker pull registry.harbor.com/k8s/nginx:v0.1
Error response from daemon: unknown: current image with 153 vulnerabilities cannot be pulled due to configured policy in 'Prevent images with vulnerability severity of "Medium" or higher from running.' To continue with pull, please contact your project administrator to exempt matched vulnerabilities through configuring the CVE allowlist.

# If there's an image with no HIGH rated CVE's:

$ docker pull registry.harbor.com/k8s/gitea/gitea:v0.0.1
v0.0.1: Pulling from k8s/gitea/gitea
Digest: sha256:3e30f6e40fa17bb2902fe448791226f4d6a3b606905909bbd4818566b54ce2a6
Status: Downloaded newer image for registry.harbor.com/k8s/gitea/gitea:v0.0.1
registry.harbor.com/k8s/gitea/gitea:v0.0.1
```

###### Side Notes :  
If you make multiple updates to the values.yml which involve updates to the harbor_admin_password,
OR ingress/TLS, then these changes will go down in the associated PVC's.  
This somehow messes up the login workflow and users can no more login.  
To solve this, delete all the associated PVC's including:  
```
[PersistentVolumeClaim] harbor-jobservice
[PersistentVolumeClaim] harbor-registry
[PersistentVolumeClaim] database-data-harbor-database-0
[PersistentVolumeClaim] data-harbor-trivy-0
[PersistentVolumeClaim] data-harbor-redis-0
```

To uninstall harbor:  
`$ helm uninstall harbor --namespace harbor`  

To upgrade harbor if making any changes to `values.yaml`  
`$ helm upgrade harbor . -f values.yaml -n harbor`