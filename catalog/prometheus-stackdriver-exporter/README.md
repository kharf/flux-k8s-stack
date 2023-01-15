# Prometheus-Stackdriver-Exporter
[Prometheus-Stackdriver-Exporter](https://github.com/prometheus-community/stackdriver_exporter) is a proxy that requests Stackdriver API for the metric's time-series everytime prometheus scrapes it.

---
## Apply it to your cluster
 
#### Kustomizations
```yaml
# note: prometheus-stackdriver-exporter uses the namespace of the kube-prometheus-stack, so this is optional
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: kube-prometheus-stack-namespace
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/kube-prometheus-stack/namespace"
  prune: true
  wait: true
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: prometheus-stackdriver-exporter
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  dependsOn:
    - name: kube-prometheus-stack-namespace
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/prometheus-stackdriver-exporter"
  prune: true
  wait: true
```
