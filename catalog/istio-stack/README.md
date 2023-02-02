# istio-stack

This stack made it easier to setup a service mesh with [istio](https://istio.io/latest/).  
It provides the setup for [istio-operator](https://github.com/stevehipwell/helm-charts/tree/master/charts/istio-operator) with sensible defaults
and also provides optional configurations for destination rules and service entries.  
Furthermore [Kiali](https://kiali.io/) with a preconfigured [Kiali-operator](https://github.com/kiali/helm-charts/tree/master/kiali-operator)
can be setup as well for configuring, visualizing, validating and troubleshooting your service mesh.

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

### Sidecar injection

Istio sidecar can be injected [automatically](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#automatic-sidecar-injection)
or [manually](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#manual-sidecar-injection)
or [via a custom injection template](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#customizing-injection).

### Kiali

To use Kiali, you have to apply the following configuration (and the GitRepository source):

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: kiali
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  sourceRef:
    kind: GitRepository
    name: gitops-infrastructure-catalog
  path: "./catalog/istio-stack/kiali"
  dependsOn:
    # istio controlplane is a hard depenedency
    - name: istio-controlplane
      namespace: flux-system
    # The prometheus-operator is required for visualization
    - name: prometheus-operator
      namespace: flux-system
  prune: true
  wait: true
  healthChecks:
    - kind: Deployment
      name: kiali
      namespace: istio-system
```

The Kiali UI can be accessed via a port-forward on port 20001:

```sh
kubectl port-forward services/kiali --namespace istio-system 20001
```
