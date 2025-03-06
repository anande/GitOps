#### Cluster Setup

Configure your k3d cluster at startup like below:

```
k3d cluster create dumptest \
--k3s-arg '--disable=servicelb@server:0' \
--k3s-arg '--disable=metrics-server@server:0' \
--k3s-arg '--disable=traefik@server:0'
```

#### Install envoy-gw using helm chart :
```
helm install eg oci://docker.io/envoyproxy/gateway-helm --version v0.0.0-latest -n envoy-gateway-system --create-namespace
```

Make sure gatewayAPI CRD's are installed and configured :
```
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml

k apply -f envoy-gw-class.yaml

k apply -f envoy-gw.yaml

k apply -f envoy-http-route.yaml
```

By default Envoy-Gateway relies on the Clusters LoadBalancerController to assign it an ExternalIP since its a LoadBalancer type service running in its own namespace. The LoadBalancer can be anything (MetalLB/Traefik etc.) There's no need for ingressController presence in the cluster.

K3d ships with Klipper as the LoadbalancerController which controls the serviceLB and Traefik as the ingressController. You can disable these both while working with MetalLB + K3D.

![](eg_resources/EnvoyGW.png)

Install test App:
```
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/httpbin/httpbin.yaml
```

Check the externalIP/Address in the following output and update /etc/hosts with the relavant hostname:IP combo.

`k get gateway`

Now try accessing the hostname in the browser.

#### NOTE: Make sure that the hostname/IP are the same in the HTTPRoute definition and the /etc/hosts file.

## Client IP Logging 

To enable **client IP logging** using the `X-Forwarded-For` header in **Envoy Gateway** via Helm, follow these steps:

### **Step 1: Configure Access Logs for `X-Forwarded-For`**

Envoy Gateway supports access logging customization, which allows you to log the `X-Forwarded-For` header (client IP). Update the `EnvoyProxy` resource to include the desired log format.

1. Create or update an `EnvoyProxy` YAML configuration file (`envoyproxy-client-ip.yaml`) to enable access logging with `X-Forwarded-For`. Here's an example:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: client-ip-logging
  namespace: envoy-gateway-system
spec:
  telemetry:
    accessLog:
      settings:
        - format:
            type: Text
            text: |
              [%START_TIME%] "%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%" %RESPONSE_CODE% %RESPONSE_FLAGS% %BYTES_RECEIVED% %BYTES_SENT% %DURATION% "%REQ(X-FORWARDED-FOR)%" "%REQ(USER-AGENT)%" "%REQ(X-REQUEST-ID)%" "%REQ(:AUTHORITY)%" "%UPSTREAM_HOST%"
          sinks:
            - type: OpenTelemetry
              openTelemetry:
                host: otel-collector.monitoring.svc.cluster.local
                port: 4317
```

This configuration ensures that the `X-Forwarded-For` header is included in the access logs.

2. Apply the configuration:
   ```bash
   kubectl apply -f envoyproxy-client-ip.yaml
   ```

---

### **Step 2: Verify Access Logs**

Once the configuration is applied, you can verify the logs to ensure that client IPs are being logged correctly.

1. If you're using OpenTelemetry (as per the example), verify logs in your observability stack (e.g., Loki, Elasticsearch, etc.). For example, if using Loki:
   ```bash
   curl -s "http://$LOKI_IP:3100/loki/api/v1/query_range" --data-urlencode "query={job=\"otel_envoy_accesslog\"}" | jq '.data.result.values'
   ```

2. If you're not using OpenTelemetry, you can configure a different sink e.g. [file-based logging](eg_resources/eg-proxy-file-sink.yaml) and check logs directly.

### **Optional Step: Enable Trusted Hops for Accurate Client IPs**

If your Envoy Gateway is behind another proxy (e.g., a load balancer), you need to configure trusted hops to ensure accurate client IP logging from the `X-Forwarded-For` header.

1. Add the `xff_num_trusted_hops` parameter in your Helm values or directly in the configuration:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: client-ip-trusted-hops
  namespace: envoy-gateway-system
spec:
  telemetry:
    accessLog:
      settings:
        - format:
            type: Text
            text: |
              [%START_TIME%] "%REQ(:METHOD)% %REQ(X-FORWARDED-FOR)%" %RESPONSE_CODE% %RESPONSE_FLAGS%
          sinks:
            - type: OpenTelemetry
              openTelemetry:
                host: otel-collector.monitoring.svc.cluster.local
                port: 4317
    proxyConfig:
      xff_num_trusted_hops: 1 # Adjust based on your proxy setup.
```

2. Apply this configuration as before.

### Summary

By enabling access logging and including `%REQ(X-FORWARDED-FOR)%` in the log format, you can effectively log client IP addresses in Envoy Gateway. Use trusted hops (`xff_num_trusted_hops`) if your setup involves intermediate proxies or load balancers. Validate logs using tools like Loki or other observability platforms.

#### Citations:  
[1] https://tetrate.io/blog/proxy-observability-scenarios-with-envoy-gateway/  
[2] https://gateway.envoyproxy.io/docs/tasks/observability/proxy-accesslog/  
[3] https://layer5.io/blog/service-mesh/debug-envoy-proxy  
[4] https://gateway.envoyproxy.io/latest/install/install-helm/  
[5] https://docs.solo.io/gloo-gateway/2.4.x/observability/dataplane/ingress-gateway/access-logs/  
[6] https://github.com/envoyproxy/gateway/releases  
[7] https://newreleases.io/project/artifacthub/helm/envoy-gateway/gateway-helm/release/1.2.0  
[8] https://stackoverflow.com/questions/tagged/envoyproxy  

---
Answer from Perplexity: https://www.perplexity.ai/search/docker-desktop-kubernetes-fail-0T1nZkpiRu6jtmvwTZ0tyQ?utm_source=copy_output