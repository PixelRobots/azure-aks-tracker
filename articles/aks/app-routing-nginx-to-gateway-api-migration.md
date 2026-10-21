---
layout: Conceptual
title: Migrate from application routing Ingress-Nginx to the application routing Gateway API implementation on AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/app-routing-nginx-to-gateway-api-migration
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Step-by-step guide to migrate ingress traffic from the application routing add-on with ingress-nginx to the application routing Gateway API (Istio) implementation on Azure Kubernetes Service with zero downtime.
ms.subservice: aks-networking
ms.custom: devx-track-azurecli
author: KingOliver
ms.topic: how-to
ms.date: 2026-10-21T00:00:00.0000000Z
ms.author: kingoliver
locale: en-us
document_id: 9be89d6e-347c-4e69-479a-d85b8afad691
document_version_independent_id: eace780a-a474-0596-8afd-ebc4ecf575af
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/app-routing-nginx-to-gateway-api-migration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/app-routing-nginx-to-gateway-api-migration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/app-routing-nginx-to-gateway-api-migration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: 74b22fcf-d86f-937e-1437-477349327c96
---

# Migrate from application routing Ingress-Nginx to the application routing Gateway API implementation on AKS - Azure Kubernetes Service | Microsoft Learn

This article describes how to migrate workloads from the [application routing add-on with ingress-nginx](app-routing) to the [application routing Gateway API implementation](app-routing-gateway-api), which serves traffic through the Kubernetes [Gateway API](https://gateway-api.sigs.k8s.io/). The two data planes can run side-by-side on the same AKS cluster, which lets you perform a zero-downtime cutover by shifting client traffic with DNS instead of an in-place swap.

## Why migrate

Caution

The [Kubernetes SIG Network](https://github.com/kubernetes/community/blob/master/sig-network/README.md) and the Security Response Committee [announced the retirement](https://www.kubernetes.dev/blog/2025/11/12/ingress-nginx-retirement/) of the [Ingress NGINX project](https://github.com/kubernetes/ingress-nginx/), with maintenance that ended in March 2026. Microsoft will provide official support for critical security patches for application routing add-on NGINX Ingress resources through **November 2026**.

AKS aligns with upstream Kubernetes and uses **[Gateway API](https://gateway-api.sigs.k8s.io) as the long-term standard for ingress and L7 traffic management**. Migrate before support ends in November 2026, based on your requirements:

- **Application routing add-on users** and **OSS NGINX users**: Migrate to the [application routing Gateway API implementation](/en-us/azure/aks/app-routing-gateway-api) for a Gateway API-based ingress traffic management experience, or to [Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview), which supports both Ingress API and Gateway API.
- **Service mesh or advanced ingress requirements**: Consider [Gateway API ingress with the Istio service mesh add-on](/en-us/azure/aks/istio-gateway-api). You can use it for ingress without injecting sidecars into your workloads. If you need request header and body size limits, Lua scripts, or rate limiting, review the [Gateway API limitations and alternatives](/en-us/azure/aks/app-routing-gateway-api#limitations).

Microsoft-supported security patches for the ingress-nginx-based application routing add-on end in November 2026. The supported successor on AKS is the application routing Gateway API implementation, which deploys a lightweight, Istio control plane that only reconciles Gateway API resources belonging to the `approuting-istio``GatewayClass`, with no support for Istio CRDs or data-plane sidecar injection.

## How the migration works

The ingress-nginx add-on and the Gateway API implementation deployments/services each get their own Azure Load Balancer frontend IP. Clients keep hitting the ingress-nginx IP until the hostname they resolve points to the Gateway API proxy.

There's no in-place flag that swaps the ingress-nginx load balancer IP for the Gateway API one. The strategy is to run both data planes in parallel, validate the new path, then move clients to the new IP. If an upstream system (Azure Front Door origin, Traffic Manager endpoint, firewall allow list) pins the existing ingress-nginx IP, update that upstream configuration to the new Gateway IP rather than trying to reassign the existing IP—AKS deletes its managed public IPs when their owning Service is removed even if you mark them `Static`, so you can't perform an in-place IP swap safely.

## Key differences

| Aspect | ingress-nginx add-on | Gateway API (Istio) implementation |
| --- | --- | --- |
| API | `networking.k8s.io/v1``Ingress` | `gateway.networking.k8s.io/v1``Gateway` and `HTTPRoute` |
| Az CLI Enable flag | `--enable-app-routing` | `--enable-app-routing-istio` (use with `--enable-gateway-api`; the Managed Gateway API add-on is required for support) |
| Class name | `webapprouting.kubernetes.azure.com` | `approuting-istio` |
| Data plane Service | `nginx` in `app-routing-system` | `<gateway-name>-approuting-istio` in the `Gateway`'s namespace |
| Azure DNS / Key Vault TLS wiring | Built in | [Configure Azure DNS and TLS with the Application Routing Gateway API implementation](app-routing-gateway-api-dns-tls) |

## Prerequisites

- Azure CLI 2.86.0 or later.
- If the cluster has the [Istio service mesh add-on](istio-about) enabled, disable it and remove the leftover `networking.istio.io` CRDs and the `istio``GatewayClass` before you start. The application routing Gateway API control plane fails to start while those CRDs are present. See [Limitations](app-routing-gateway-api#limitations) for the cleanup command.

Set environment variables that the rest of this article uses:

```bash
export RG=<resource-group>
export CLUSTER=<cluster-name>
```

## Step 1: Inventory current ingress

The application routing add-on can run more than one ingress-nginx controller. Each `NginxIngressController` has its own ingress class and its own load balancer IP. Inventory all of them, not just the default controller. Include any upstream references such as Azure Front Door origins, Traffic Manager endpoints, and firewall allow lists.

List the add-on controllers and their ingress classes. The default controller uses the class `webapprouting.kubernetes.azure.com`.

```bash
kubectl get nginxingresscontrollers -o custom-columns=NAME:.metadata.name,CLASS:.spec.ingressClassName
```

List every `Ingress`. Migrate the ones whose `CLASS` matches a class from the previous output. `HOSTS` shows the hostnames to update in DNS, and `ADDRESS` shows the controller's load balancer IP.

```bash
kubectl get ingress -A
```

Later steps refer to the IP of the controller you're migrating as `INGRESS_NGINX_IP`. Set it from the `ADDRESS` column:

```bash
INGRESS_NGINX_IP=<address-from-the-previous-output>
```

If you have more than one controller, repeat steps 3 through 7 for each controller's IP and hostnames.

## Step 2: Enable the Gateway API implementation

Enable the Managed Gateway API CRDs and the application routing Gateway API implementation. Ingress-nginx continues serving traffic.

```azurecli
az aks update --resource-group $RG --name $CLUSTER --enable-gateway-api
az aks update --resource-group $RG --name $CLUSTER --enable-app-routing-istio
```

Verify the control plane and `GatewayClass` are ready:

```bash
kubectl -n aks-istio-system rollout status deploy/istiod --timeout=5m
kubectl get gatewayclass approuting-istio
```

## Step 3: Lower the DNS TTL

Note

Skip this step if your clients reach the cluster by IP rather than DNS. The cutover in step 7 is a DNS change, so a low TTL is only relevant when DNS is in the path.

For each hostname that resolves to `INGRESS_NGINX_IP`, lower the record TTL to 60 seconds (or the smallest value your provider allows). Wait for the previous TTL window to fully expire before you continue. If the previous TTL was one hour, wait at least one hour. If you skip this step, cached resolvers continue sending clients to ingress-nginx after you delete the `Ingress`.

## Step 4: Translate each Ingress to Gateway and HTTPRoute

For each `Ingress`, create a matching `Gateway` and `HTTPRoute`. For per-field translation guidance—including how to convert path matches, redirects, rewrites, and header manipulation—follow the [Kubernetes Gateway API migration guide](https://gateway-api.sigs.k8s.io/guides/getting-started/migrating-from-ingress/). To bulk-translate existing manifests instead of writing them by hand, consider [`ingress2gateway`](https://github.com/kubernetes-sigs/ingress2gateway), a Kubernetes SIG Network tool that reads `Ingress` resources (including `ingress-nginx` annotations) and emits equivalent Gateway API resources—treat its output as a starting point and review before applying.

By default, `ingress2gateway` reads only `Ingress` resources with the class `nginx`, so it skips `Ingress` resources on application routing classes unless you pass the class. Pass `--providers=ingress-nginx --ingress-nginx-ingress-class=<class>` with a class from step 1, and run the tool once per class.

The following example converts an ingress-nginx `Ingress` for host `httpbin.contoso.com` with path prefix `/get` and backend `httpbin:8000`. For reference, the source `Ingress`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: httpbin
  namespace: demo
spec:
  ingressClassName: webapprouting.kubernetes.azure.com
  rules:
  - host: httpbin.contoso.com
    http:
      paths:
      - path: /get
        pathType: Prefix
        backend:
          service:
            name: httpbin
            port:
              number: 8000
```

The equivalent `Gateway` and `HTTPRoute`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: httpbin-gateway
  namespace: demo
spec:
  gatewayClassName: approuting-istio
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: httpbin
  namespace: demo
spec:
  parentRefs:
  - name: httpbin-gateway
  hostnames: ["httpbin.contoso.com"]
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /get
    backendRefs:
    - name: httpbin
      port: 8000
```

Wait for the `Gateway` to program and capture its public IP:

```bash
kubectl wait --for=condition=Programmed -n demo \
  gateways.gateway.networking.k8s.io/httpbin-gateway --timeout=5m
GW_IP=$(kubectl get gateway -n demo httpbin-gateway -o jsonpath='{.status.addresses[0].value}')
```

## Step 5: Provision TLS on the Gateway

If the original `Ingress` terminated HTTPS, configure TLS on the new `Gateway` before you change DNS. Follow [Configure Azure DNS and TLS with the application routing Gateway API implementation](app-routing-gateway-api-dns-tls) to have the Application Routing operator sync the certificate from Azure Key Vault and set the listener `certificateRefs` for you. If you need full control over the certificate sync, follow [Secure application routing Gateway API ingress traffic](app-routing-gateway-api-tls) to configure the Secrets Store CSI driver manually.

## Step 6: Validate the Gateway before flipping client traffic

Probe both data planes by pinning DNS resolution with `curl --resolve`. Both should return `200` continuously while you run the probe in a loop for several minutes.

Important

Don't cut over until you fully exercise the Gateway IP. The DNS flip in step 7 is the point at which real client traffic lands on the new data plane—anything broken on the Gateway side becomes a customer-visible outage at that moment. Defects that are easy to find by hitting `GW_IP` directly are much harder to triage once production traffic is mixed in.

```bash
# New Gateway path
curl -sS -o /dev/null -w '%{http_code}\n' \
  --resolve "httpbin.contoso.com:80:${GW_IP}" \
  http://httpbin.contoso.com/get

# Old ingress-nginx path (should still work)
curl -sS -o /dev/null -w '%{http_code}\n' \
  --resolve "httpbin.contoso.com:80:${INGRESS_NGINX_IP}" \
  http://httpbin.contoso.com/get
```

If you added a TLS listener in step 5, also probe HTTPS by switching the port to `443` and the scheme to `https://`.

At minimum, verify the following items against `GW_IP` (using `--resolve` or a `Host` header) before you flip DNS:

- **Every hostname and route** that the original `Ingress` served, not just one happy-path URL. Routes that share a host but differ in path prefix, header match, or method must each be hit.
- **HTTPS end-to-end** with the production certificate served by the `Gateway`. Verify the certificate chain and SAN list match what clients expect; don't rely on `--insecure`.
- **Application behavior**, not just HTTP status codes. Submit POST bodies, exercise authentication, and confirm long-running responses (streaming, WebSockets, gRPC) work end-to-end if your workload uses them.
- **Sustained load** for at least several minutes from a probe loop, watching for intermittent 5xx responses, latency regressions, or `Gateway`/`HTTPRoute` status conditions flapping.
- **Upstream integrations** in a nonproduction configuration where possible—for example, point a staging Front Door origin or Traffic Manager endpoint at `GW_IP` and verify health probes pass.

Only proceed to step 7 once every preceding check passes consistently. If anything fails, fix it on the Gateway side while ingress-nginx is still serving real clients—you have unlimited rollback room until DNS changes.

## Step 7: Cut over

1. Update the DNS A record for the hostname to point to `GW_IP`. Because you already lowered the TTL in step 3, drain happens within minutes.
2. If any upstream system pins the ingress-nginx IP—for example, an Azure Front Door origin, a Traffic Manager endpoint, or a customer firewall allow list—update it to `GW_IP` at the same time. Don't try to reassign the existing IP to the Gateway: the cluster's cloud provider creates and manages the ingress-nginx Service's public IP, and deletes it when the Service is removed even if you set it to `Static`.
3. Watch traffic drop on ingress-nginx. Scrape the `ingress-nginx` request-rate metrics (see [Monitor the ingress-nginx controller metrics with Prometheus](app-routing-nginx-prometheus)) until requests reach zero.
4. Keep the DNS TTL low for a few hours of observation, then raise it back to your normal value.

## Step 8: Clean up

After traffic is stable on the Gateway API path, stop the add-on from reconciling a default `NginxIngressController` on the cluster, then delete every existing `NginxIngressController` custom resource. The `az aks approuting update --nginx None` command in this step stops the controller from reconciling new resources, but the `nginx` Deployment and Service it created earlier remain on the cluster until you remove the owning `NginxIngressController`.

Update the cluster so the application routing add-on no longer manages a default ingress-nginx controller:

```azurecli
az aks approuting update --resource-group $RG --name $CLUSTER --nginx None
```

Then delete the remaining `NginxIngressController` resources:

```bash
kubectl delete nginxingresscontrollers.approuting.kubernetes.azure.com --all
```

Raise the DNS TTL back to its normal value once you verify steady state.

## Roll back

Both data planes can coexist, so rollback is symmetric at any point *before* you disable the ingress-nginx add-on. This procedure leaves the original `Ingress` resources in place throughout the cutover, so a rollback only has to revert DNS:

1. If you removed the `Ingress` resources after cutover, recreate them.
2. Flip DNS back to `INGRESS_NGINX_IP` and wait for the TTL window to drain.
3. Optionally disable the Gateway API implementation:

    ```azurecli
    az aks update --resource-group $RG --name $CLUSTER --disable-app-routing-istio
    ```

After you run `kubectl delete nginxingresscontrollers.approuting.kubernetes.azure.com`, the ingress-nginx controller is gone. Rolling back from that point requires re-enabling the add-on Default `NginxIngressController` and recreating any `Ingress` resources you removed. Validate the chosen path before you disable ingress-nginx.