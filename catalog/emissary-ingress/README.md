# Emissary-Ingress
[Emissary-Ingress](https://www.getambassador.io/products/api-gateway/) is an open-source Kubernetes-native API Gateway + Layer 7 load balancer + Kubernetes Ingress built on Envoy Proxy

---
## Apply it to your cluster

### Basic setup
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: emissary-ingress-namespace
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/emissary-ingress/namespace"
  prune: true
  wait: true
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: emissary-ingress
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  dependsOn:
    - name: emissary-ingress-namespace
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/emissary-ingress/base"
  prune: true
  wait: true
```

### Emissary-Ingress with GKE
This will deploy emissary-ingress with a NodePort service and a GCP BackendConfig as described [here](https://www.getambassador.io/docs/emissary/latest/topics/running/ambassador-with-gke/#5-configure-backendconfig-for-health-checks).

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: emissary-ingress-namespace
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/emissary-ingress/namespace"
  prune: true
  wait: true
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: emissary-ingress
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  dependsOn:
    - name: emissary-ingress-namespace
  sourceRef:
    kind: GitRepository
    name: flux-k8s-stack
  path: "./catalog/emissary-ingress/gke"
  prune: true
  wait: true
---
```

Then you can set up a Kustomization to configure an [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/), a [Listener](https://www.getambassador.io/docs/emissary/latest/topics/running/listener/) and some [Hosts](https://www.getambassador.io/docs/emissary/latest/topics/running/host-crd/).
In the following example we set up an Ingress with a global static ip, cert-manager and letsencrypt.
Ingress, Listener and Hosts manifests are expected to be in ./infrastructure/dev/ingress/config (you can change the structure as you prefer):

#### Kustomization
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: emissary-ingress-config
  namespace: flux-system
spec:
  interval: 10m
  retryInterval: 1m0s
  dependsOn:
    - name: emissary-ingress
    - name: cert-manager
  sourceRef:
    kind: GitRepository
    name: flux-system
  decryption:
    provider: sops
    secretRef:
      name: sops-age
  path: "./infrastructure/dev/ingress/config"
  prune: true
  wait: true
```

#### Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: ingress
  annotations:
    kubernetes.io/ingress.global-static-ip-name: "ingress"
    cert-manager.io/cluster-issuer: letsencrypt
    cert-manager.io/issue-temporary-certificate: "true"
    acme.cert-manager.io/http01-edit-in-place: "true"
    networking.gke.io/v1beta1.FrontendConfig: "https-redirect"
spec:
  tls:
    - secretName: ingress-cert
      hosts:
        - <your-host> # e.g dev.example.com
  defaultBackend:
    service:
      name: emissary-ingress
      port:
        number: 8080
---
apiVersion: networking.gke.io/v1beta1
kind: FrontendConfig
metadata:
  name: https-redirect
  namespace: ingress
spec:
  redirectToHttps:
    enabled: true
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
  namespace: ingress
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: <your-email>
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt
    # Enable the HTTP-01 challenge provider
    solvers:
      - selector:
          dnsZones:
            - <your-dns-zone>
        http01:
          ingress:
            class: nginx
---
apiVersion: getambassador.io/v3alpha1
kind: Mapping
metadata:
  name: acme-challenge-mapping
  namespace: ingress
spec:
  hostname: "*"
  prefix: /.well-known/acme-challenge/
  rewrite: ""
  service: acme-challenge-service
---
apiVersion: v1
kind: Service
metadata:
  name: acme-challenge-service
  namespace: ingress
spec:
  ports:
    - port: 80
      targetPort: 8089
  selector:
    acme.cert-manager.io/http01-solver: "true"
```

#### Communications (Listener and Hosts)
```yaml
apiVersion: getambassador.io/v3alpha1
kind: Listener
metadata:
  name: http-listener
  namespace: ingress
spec:
  port: 8080
  protocol: HTTP
  securityModel: XFP
  l7Depth: 1
  hostBinding:
    namespace:
      from: SELF
---
apiVersion: getambassador.io/v3alpha1
kind: Host
metadata:
  name: your-hosts
  namespace: ingress
spec:
  hostname: <your-host>
  requestPolicy:
    insecure:
      action: Reject
```
