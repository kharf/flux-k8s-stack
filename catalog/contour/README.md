# Contour
[Contour](https://projectcontour.io/) is an open source Kubernetes ingress controller providing the control plane for the Envoy edge and service proxy

---
## Apply it to your cluster

#### Kustomizations
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: contour-namespace
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/contour/namespace"
  prune: true
  wait: true
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: contour
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  dependsOn:
    - name: contour-namespace
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/contour"
  prune: true
  wait: true
```
