# Loki
[Loki](https://grafana.com/docs/loki/) is a set of components that can be composed into a fully featured logging stack.

---
## Apply it to your cluster
 
#### Kustomizations
```yaml
# note: loki uses the namespace of the kube-prometheus-stack, so this is optional
apiVersion: kustomize.toolkit.fluxcd.io/v1
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
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: loki-stack
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  dependsOn:
    - name: kube-prometheus-stack-namespace
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/loki-stack"
  prune: true
  wait: true
```
