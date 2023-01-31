# kiali-operator

This is the configuration for the Kiali-operator. It is optional, can be omitted but is recommended.

It does have a hard dependency on the istio-stack as it is creating the following components:

- Kiali Operator
- Kiali Instance/Deployment

The Kiali UI can be accessed via a port-forward on port 20001:

```sh
kubectl port-forward svc/kiali -n istio-system 20001
```

## Usage

To use this stack you have to apply the following configuration (and the GitRepository source):

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: kiali
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./istio-stack/kiali
  prune: true
  dependsOn:
    # istio controlplane is a hard depenedency
    - name: istio-controlplane
      namespace: flux-system
    # The prometheus-operator is required for visualization
    - name: prometheus-operator
      namespace: flux-system
  sourceRef:
    kind: GitRepository
    name: gitops-infrastructure-catalog
  timeout: 10m
  healthChecks:
    - kind: Deployment
      name: kiali
      namespace: istio-system
```
