# flux-k8s-stack
A catalog of Kubernetes tools for your Flux2 GitOps setup

---
## Getting started
Set up a [GitRepository](https://fluxcd.io/docs/components/source/gitrepositories/) source, which you can use for your Kustomizations to apply the manifests found in the catalog:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: flux-k8s-stack
  namespace: flux-system
spec:
  interval: 5m0s
  url: https://github.com/kharf/flux-k8s-stack
  ref:
    branch: main # TODO: SemVer
```
You're ready to browse the [catalog](#catalog).

---
## catalog

- [cert-manager](./catalog/cert-manager) - Cert-manager adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates
- [contour](./catalog/contour) - Contour is an open source Kubernetes ingress controller providing the control plane for the Envoy edge and service proxy
- [emissary-ingress](./catalog/emissary-ingress) - Emissary-Ingress is an open-source Kubernetes-native API Gateway + Layer 7 load balancer + Kubernetes Ingress built on Envoy Proxy
- [kube-prometheus-stack](./catalog/kube-prometheus-stack) - Kube-Prometheus-Stack is a collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator
- [prometheus-stackdriver-exporter](/catalog/prometheus-stackdriver-exporter) - Prometheus-Stackdriver-Exporter is a proxy that requests Stackdriver API for the metric's time-series everytime prometheus scrapes it.
- [linkerd2](./catalog/linkerd2) - Linkerd is a service mesh for Kubernetes. It makes running services easier and safer by giving you runtime debugging, observability, reliability, and security—all without requiring any changes to your code
- [loki-stack](./catalog/loki-stack) - Loki is a set of components that can be composed into a fully featured logging stack
- [keda](./catalog/keda) - Keda is a Kubernetes based Event Driven Autoscaler. With KEDA, you can drive the scaling of any container in Kubernetes based on the number of events needing to be processed
- [kyverno](./catalog/kyverno) - Kyverno is a policy engine designed for Kubernetes.
- [ingress-nginx](./catalog/ingress-nginx) - Ingress-Nginx is an Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.
