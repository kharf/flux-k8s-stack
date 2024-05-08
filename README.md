# flux-k8s-stack
A catalog of Kubernetes tools for your Flux2 GitOps setup

---
## Getting started
Set up a [GitRepository](https://fluxcd.io/docs/components/source/gitrepositories/) source, which you can use for your Kustomizations to apply the manifests found in the catalog:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: flux-k8s-stack
  namespace: flux-system
spec:
  interval: 5m0s
  url: https://github.com/kharf/flux-k8s-stack
  ref:
    tag: v23.10.0
```

Recommendation: Use [Renovatebot](https://docs.renovatebot.com/modules/manager/flux/#gitrepository-support) to configure automatic updates for this catalog.

You're ready to browse the [Catalog](#Catalog).

---
## Compatibility
We keep track of compatibility between this catalog and flux2. Other versions might work too as long as there are no breaking changes.
| flux-k8s-stack version | flux2 version |
| ---------------------- | ------------- |
| >= v9                  | v2.0.0        |
| <= v8                  | v0.41.2       |

---
## Catalog
| tool                                                                       | test status                  | description                                                                                                                                        |
| ------------------------------------------------------                     | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| [cert-manager](./catalog/cert-manager)                                     | [![cert-manager-test](https://github.com/kharf/flux-k8s-stack/actions/workflows/cert-manager-test.yaml/badge.svg)](https://github.com/kharf/flux-k8s-stack/actions/workflows/cert-manager-test.yaml)   | Cert-manager adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates. |
| [emissary-ingress](./catalog/emissary-ingress)                             | [![emissary-ingress-test](https://github.com/kharf/flux-k8s-stack/actions/workflows/emissary-ingress-test.yaml/badge.svg)](https://github.com/kharf/flux-k8s-stack/actions/workflows/emissary-ingress-test.yaml) | Emissary-Ingress is an open-source Kubernetes-native API Gateway + Layer 7 load balancer + Kubernetes Ingress built on Envoy Proxy. |
| [kube-prometheus-stack](./catalog/kube-prometheus-stack)                   | [![kube-prometheus-stack-test](https://github.com/kharf/flux-k8s-stack/actions/workflows/kube-prometheus-stack-test.yaml/badge.svg)](https://github.com/kharf/flux-k8s-stack/actions/workflows/kube-prometheus-stack-test.yaml) | Kube-Prometheus-Stack is a collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator. |
| [prometheus-stackdriver-exporter](/catalog/prometheus-stackdriver-exporter)| ---                                                                                                                                                                               | Prometheus-Stackdriver-Exporter is a proxy that requests Stackdriver API for the metric's time-series everytime prometheus scrapes it. |
| [linkerd2](./catalog/linkerd2)                                             | [![linkerd2-test](https://github.com/kharf/flux-k8s-stack/actions/workflows/linkerd2-test.yaml/badge.svg)](https://github.com/kharf/flux-k8s-stack/actions/workflows/linkerd2-test.yaml) | Linkerd is a service mesh for Kubernetes. It makes running services easier and safer by giving you runtime debugging, observability, reliability, and security—all without requiring any changes to your code. |
| [loki-stack](./catalog/loki-stack)                                         | [![loki-stack-test](https://github.com/kharf/flux-k8s-stack/actions/workflows/loki-stack-test.yaml/badge.svg)](https://github.com/kharf/flux-k8s-stack/actions/workflows/loki-stack-test.yaml) | Loki is a set of components that can be composed into a fully featured logging stack. |
| [keda](./catalog/keda)                                                     | [![keda-test](https://github.com/kharf/flux-k8s-stack/actions/workflows/keda-test.yaml/badge.svg)](https://github.com/kharf/flux-k8s-stack/actions/workflows/keda-test.yaml) | Keda is a Kubernetes based Event Driven Autoscaler. With KEDA, you can drive the scaling of any container in Kubernetes based on the number of events needing to be processed. |
| [kyverno](./catalog/kyverno)                                               | [![kyverno-test](https://github.com/kharf/flux-k8s-stack/actions/workflows/kyverno-test.yaml/badge.svg)](https://github.com/kharf/flux-k8s-stack/actions/workflows/kyverno-test.yaml) | Kyverno is a policy engine designed for Kubernetes. |
| [ingress-nginx](./catalog/ingress-nginx)                                   | [![ingress-nginx-test](https://github.com/kharf/flux-k8s-stack/actions/workflows/ingress-nginx-test.yaml/badge.svg)](https://github.com/kharf/flux-k8s-stack/actions/workflows/ingress-nginx-test.yaml) | Ingress-Nginx is an Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer. |
| [istio-stack](./catalog/istio-stack)                                       | [![istio-stack-test](https://github.com/kharf/flux-k8s-stack/actions/workflows/istio-stack-test.yaml/badge.svg)](https://github.com/kharf/flux-k8s-stack/actions/workflows/istio-stack-test.yaml) | Istio is a service mesh for Kubernetes. It provides secure service-to-service communication, automatic load balancing, fine-grained control of traffic behavior and more. |

