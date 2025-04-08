To configure two services in different namespaces within the same k3d cluster to use Traefik as an Ingress controller, while ensuring they have different external IPs, follow these steps:

## Overview

Traefik typically uses a LoadBalancer service type, which may assign the same external IP to multiple services if they share the same Ingress class and configuration. To achieve distinct external IPs for different services, you can utilize MetalLB in conjunction with Traefik to manage multiple external IPs.

## Step-by-Step Guide

### Step 1: Install MetalLB

1. **Install MetalLB**:
   First, you need to install MetalLB in your k3d cluster. You can do this by applying the MetalLB manifest:

   ```bash
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/manifests/namespace.yaml
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/manifests/metallb.yaml
   ```

2. **Configure MetalLB**:
   Create a ConfigMap for MetalLB to define the IP address pool it can use. Replace `<IP_RANGE>` with a range of IPs you want to allocate (e.g., `192.168.1.200-192.168.1.250`).

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     namespace: metallb-system
     name: config
   data:
     config: |
       layer2:
         addresses:
           - <IP_RANGE>
   ```

   Apply this configuration:
   ```bash
   kubectl apply -f your-configmap.yaml
   ```

### Step 2: Configure Traefik with Multiple Services

1. **Create Ingress Resources**:
   Create separate Ingress resources for each service in their respective namespaces, specifying different hostnames.

   Example for Service 1 (`service1.yaml`):
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: service1-ingress
     namespace: namespace1
     annotations:
       kubernetes.io/ingress.class: "traefik"
   spec:
     rules:
       - host: service1.local
         http:
           paths:
             - path: /
               pathType: Prefix
               backend:
                 service:
                   name: service1
                   port:
                     number: 80
     tls:
       - hosts:
           - service1.local
         secretName: service1-tls-secret  # Ensure you have created this TLS secret if needed.
   ```

   Example for Service 2 (`service2.yaml`):
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: service2-ingress
     namespace: namespace2
     annotations:
       kubernetes.io/ingress.class: "traefik"
   spec:
     rules:
       - host: service2.local
         http:
           paths:
             - path: /
               pathType: Prefix
               backend:
                 service:
                   name: service2
                   port:
                     number: 80
     tls:
       - hosts:
           - service2.local
         secretName: service2-tls-secret  # Ensure you have created this TLS secret if needed.
   ```

### Step 3: Assign External IPs

To assign different external IPs to each Ingress resource, modify the Traefik service to use specific external IPs.

1. **Edit Traefik Service**:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: traefik-service
  namespace: kube-system  # Adjust based on your setup.
spec:
  type: LoadBalancer
  selector:
    app: traefik  # Ensure this matches your Traefik deployment.
  ports:
    - port: 80
      targetPort: 80
    - port: 443
      targetPort: 443
  externalIPs:
    - <EXTERNAL_IP_FOR_SERVICE_1>
    - <EXTERNAL_IP_FOR_SERVICE_2>
```

### Step 4: Update `/etc/hosts`

To access your services via their hostnames, add entries to your `/etc/hosts` file:

```
<EXTERNAL_IP_FOR_SERVICE_1> service1.local
<EXTERNAL_IP_FOR_SERVICE_2> service2.local
```

### Step 5: Verify Configuration

Check that both services are accessible via their respective hostnames and that they respond correctly.

```bash
kubectl get ingress --all-namespaces
```

This setup allows you to use Traefik with multiple services in different namespaces while ensuring they have distinct external IPs by leveraging MetalLB's capabilities within your k3d cluster.

Citations:
[1] https://community.traefik.io/t/using-multiple-traefik-load-balancer-services-with-different-ips/19654
[2] https://community.traefik.io/t/accessing-the-cluster-with-ingressroute/1809
[3] https://stackoverflow.com/questions/68547804/how-to-expose-two-apps-services-over-unique-ports-with-k3d
[4] https://community.traefik.io/t/usage-of-publishedservice-in-externalip-setup/9971
[5] https://forums.rancher.com/t/running-k3s-with-traefik-on-a-second-entwork-interface/39163
[6] https://k3d.io/v5.1.0/usage/exposing_services/
[7] https://github.com/k3d-io/k3d/issues/960
[8] https://docs.rancherdesktop.io/how-to-guides/traefik-ingress-example/