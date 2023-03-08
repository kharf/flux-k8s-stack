# istio-stack

This stack made it easier to setup a service mesh with [istio](https://istio.io/latest/).  
It provides the setup for [istio-operator](https://github.com/stevehipwell/helm-charts/tree/master/charts/istio-operator) with sensible defaults
and also provides optional configurations for destination rules and service entries.  
Furthermore [Kiali](https://kiali.io/) with a preconfigured [Kiali-operator](https://github.com/kiali/helm-charts/tree/master/kiali-operator)
can be setup as well for configuring, visualizing, validating and troubleshooting your service mesh.

## Usage

### Basic setup

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

### Setup with GKE

This will set up the base istio and additionally add some common destination rules and service entries for your application(s).

**Note**: The rules and entries are targeting the namespace `apps`. So make sure to adjust the namespace via patch if needed.


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
  path: "./catalog/istio-stack/gke"
  prune: true
  wait: true
```

### Sidecar injection

Istio sidecar can be injected [automatically](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#automatic-sidecar-injection)
or [manually](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#manual-sidecar-injection)
or [via a custom injection template](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#customizing-injection).

### Setup mutual TLS

To setup [Istio mutual TLS](https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/) between your apps,
a destination rule like below needs to be defined.

**Note**: Depend on your cluster setup, the `apps` name in the `metadata` and `host` needs to be adjusted accordingly.

```yaml
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: istio-mtls
  namespace: apps
spec:
  host: "*.apps.svc.cluster.local"
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
```

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
    name: flux-k8s-stack
  path: "./catalog/istio-stack/kiali"
  dependsOn:
    # istio system is a hard dependency
    - name: istio-system
    # The prometheus-operator is required for visualization
    - name: kube-prometheus-stack
  prune: true
  wait: true
  healthChecks:
    - kind: Deployment
      name: kiali
      namespace: istio-system
```

Make sure to set up `grafana` and `prometheus` via [kube-prometheus-stack](./../kube-prometheus-stack/README.md)
before hand in your cluster for Kiali's visualization to work correctly.

The Kiali UI can be accessed via a port-forward on port 20001:

```sh
kubectl port-forward services/kiali --namespace istio-system 20001
```
