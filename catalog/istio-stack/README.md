# istio-stack

[//]: # (todo: update this readme)
This stack is made up of 3 components:

- the [istio-operator](https://github.com/stevehipwell/helm-charts/tree/master/charts/istio-operator) itself, in the root of this directory
- the config folder, with preconfigured service monitors and exporters
- an optional [Kiali](https://kiali.io/) folder, with a preconfigured [Kiali-operator](https://github.com/kiali/helm-charts/tree/master/kiali-operator) deployment in view-only mode, have a look at the [configuration](./istio-stack/kiali)

## Usage

### Setup

To use this stack you have to apply 2 configurations (and the GitRepository source):

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: istio-stack-namespace
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/istio-stack/namespace"
  prune: true
  wait: true
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: istio-system
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  dependsOn:
    - name: istio-stack-namespace
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/istio-stack/base"
  prune: true
  wait: true
```

### Configuration

The catalog also provides default configuration. This configuration is optional, and can be omitted but is recommended.  
To use the configuration, apply this Kustomization via GitOps

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: istio-config
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/istio-stack/config"
  dependsOn:
    # Please make sure the apps namespace is created
    - name: apps-config
      namespace: flux-system
    # This dependency is required to make sure the operator is deployed before the config is applied
    - name: istio-controlplane
      namespace: flux-system
  prune: true
  wait: true
```

The configuration targets the `apps` namespace, so make sure that it's created before using the provided configuration.
Or alternatively you can copy and customize the rules in your own GitOps repository's config folder.
