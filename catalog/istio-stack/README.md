# istio-stack

This stack is made up of 3 components:

- the [istio-operator](https://github.com/stevehipwell/helm-charts/tree/master/charts/istio-operator) itself, in the root of this directory
- the config folder, with preconfigured service monitors and exporters
- an optional [Kiali](https://kiali.io/) folder, with a preconfigured [Kiali-operator](https://github.com/kiali/helm-charts/tree/master/kiali-operator) deployment in view-only mode, have a look at the [configuration](./istio-stack/kiali)

## Usage

To use this stack you have to apply 2 configurations (and the GitRepository source):

First the istio-operator itself:

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: istio-controlplane
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./istio-stack
  prune: true
  dependsOn:
    # The prometheus-operator dependency is required for the istio-operator
    - name: prometheus-operator
      namespace: flux-system
  sourceRef:
    kind: GitRepository
    name: gitops-infrastructure-catalog
  timeout: 10m
  healthChecks:
    - kind: Deployment
      name: istio-ingressgateway
      namespace: istio-system
    - kind: Deployment
      name: istio-egressgateway
      namespace: istio-system
```

Second, the configuration for the operator resides in the config folder. This configuration is optional, and can be omitted but is recommended. Please make sure the app's namespace is created before using the provided configuration or copy and customize the rules in your own GitOps repository's config folder.

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: istio-config
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./istio-stack/config
  dependsOn:
    # Please make sure the apps namespace is created
    - name: apps-config
      namespace: flux-system
    # This dependency is required to make sure the operator is deployed before the config is applied
    - name: istio-controlplane
      namespace: flux-system
  prune: true
  sourceRef:
    kind: GitRepository
    name: gitops-infrastructure-catalog
  timeout: 10m
```
