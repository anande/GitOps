## Locally on Laptop using docker
```
docker run -it -p 9090:9090 prom/prometheus

docker run -it -p 3000:3000 grafana/grafana
```

## Using HELM

- Add prometheus repo:  
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
```

## Note 

By default this chart installs additional, dependent charts:

- prometheus-community/kube-state-metrics
- prometheus-community/prometheus-node-exporter
- grafana/grafana

## Install

```
helm install prometheus kube-prometheus-stack/ -f kube-prometheus-stack/values.yaml -n prometheus --create-namespace
NAME: prometheus
LAST DEPLOYED: Mon Feb  3 23:04:55 2025
NAMESPACE: prometheus
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace prometheus get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

### To use a specific Grafana version  

Check the **APPLICATION VERSION** and helm **CHART VERSION** from [Artifacthub](https://artifacthub.io/packages/helm/grafana/grafana)  


Modify `observability/prometheus/kube-prometheus-stack/charts/grafana/values.yaml` :  
- `appVersion: 11.4.0`  
- `version: 8.8.5`  

Also under `observability/prometheus/kube-prometheus-stack/Chart.yaml`:  

```
### Modify
...
- condition: grafana.enabled
  name: grafana
  repository: https://grafana.github.io/helm-charts
  version: 8.8.*
...
```

#### Before upgrading, Perform a dry-run using  
```
helm upgrade prometheus . -f values.yaml --dry-run > test-upgrade.txt

bat test-upgrade.txt
```

## Reference

- [Kube-Prometheus-Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Kodekloud Prometheus](https://www.youtube.com/watch?v=6xmWr7p5TE0)