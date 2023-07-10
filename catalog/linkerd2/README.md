# Linkerd2
[Linkerd](https://linkerd.io/) is a service mesh for Kubernetes. It makes running services easier and safer by giving you runtime debugging, observability, reliability, and security—all without requiring any changes to your code

---
## Apply it to your cluster

### Prerequisites
This setup requires you to have trust-anchor and webhook-issuer root certificates stored as k8s secret as described [here](https://linkerd.io/2.11/tasks/automatically-rotating-control-plane-tls-credentials/#issuing-certificates-and-writing-them-to-a-secret) and [here](https://linkerd.io/2.11/tasks/automatically-rotating-control-plane-tls-credentials/#issuing-certificates-and-writing-them-to-a-secret).
[SOPS](https://github.com/mozilla/sops) or [SealedSecrets](https://github.com/bitnami-labs/sealed-secrets) are recommended to store secrets the "GitOps way".

#### Kustomizations
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: linkerd-namespace
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/linkerd2/namespace"
  prune: true
  wait: true
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: linkerd
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  dependsOn:
    - name: linkerd-namespace
    - name: cert-manager
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/linkerd2"
  prune: true
  wait: true
```
