---
layout: Conceptual
title: Azure Kubernetes Service (AKS) external or internal ingresses for Istio service mesh add-on - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-deploy-ingress
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
description: Deploy external or internal ingresses for Istio service mesh add-on for Azure Kubernetes Service
ms.topic: how-to
author: nshankar13
ms.date: 2023-08-07T00:00:00.0000000Z
ms.author: nshankar
locale: en-us
document_id: 9d68ede6-cee3-51ae-b2b6-0ce109617a54
document_version_independent_id: 5ec11fc8-1c0e-f4e5-ce24-f57603c99c4a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-deploy-ingress.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/istio-deploy-ingress
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-deploy-ingress.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: d9b87302-feda-8637-bb19-d9c7f20a346b
---

# Azure Kubernetes Service (AKS) external or internal ingresses for Istio service mesh add-on - Azure Kubernetes Service | Microsoft Learn

This article shows you how to deploy external or internal ingresses for the Istio service mesh add-on for Azure Kubernetes Service (AKS) cluster.

Note

When you perform a [minor revision upgrade](istio-upgrade#minor-revision-upgrades-with-ingress-and-egress-gateways) of the Istio add-on, another deployment for the external / internal gateways will be created for the new control plane revision.

## Prerequisites

This guide assumes you followed the [documentation](istio-deploy-addon) to enable the Istio add-on on an AKS cluster, deploy a sample application, and set environment variables.

## Enable external ingress gateway

Note

To schedule the ingress gateway pods onto specific nodes, use the `azureservicemesh/istio.replica.preferred` node label or [AKS system nodes](/en-us/azure/aks/use-system-pools). The pods have node affinities with a weighted preference of `100` for nodes labeled `azureservicemesh/istio.replica.preferred: true` and a weighted preference of `50` for AKS system nodes (labeled `kubernetes.azure.com/mode: system`). This configuration means that if the `azureservicemesh/istio.replica.preferred: true` label isn't found or such nodes are unschedulable, pods are instead scheduled on AKS system nodes.

For revisions earlier than `asm-1-30`, these weights are reversed: `100` for AKS system nodes and `50` for `azureservicemesh/istio.replica.preferred: true` nodes.

Use `az aks mesh enable-ingress-gateway` to enable an externally accessible Istio ingress on your AKS cluster:

```azurecli
az aks mesh enable-ingress-gateway --resource-group $RESOURCE_GROUP --name $CLUSTER --ingress-gateway-type external
```

Use `kubectl get svc` to check the service mapped to the ingress gateway:

```bash
kubectl get svc aks-istio-ingressgateway-external -n aks-istio-ingress
```

Observe from the output that the external IP address of the service is a publicly accessible one:

```
NAME                                TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                                      AGE
aks-istio-ingressgateway-external   LoadBalancer   10.0.10.249   <EXTERNAL_IP>   15021:30705/TCP,80:32444/TCP,443:31728/TCP   4m21s
```

Applications aren't accessible from outside the cluster by default after enabling the ingress gateway. To make an application accessible, map the sample deployment's ingress to the Istio ingress gateway using the following manifest:

```bash
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: bookinfo-gateway-external
spec:
  selector:
    istio: aks-istio-ingressgateway-external
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: bookinfo-vs-external
spec:
  hosts:
  - "*"
  gateways:
  - bookinfo-gateway-external
  http:
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage
        port:
          number: 9080
EOF
```

Note

The selector used in the Gateway object points to `istio: aks-istio-ingressgateway-external`, which can be found as label on the service mapped to the external ingress that was enabled earlier.

Set environment variables for external ingress host and ports:

```bash
export INGRESS_HOST_EXTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT_EXTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-external -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL_EXTERNAL=$INGRESS_HOST_EXTERNAL:$INGRESS_PORT_EXTERNAL
```

Retrieve the external address of the sample application:

```bash
echo "http://$GATEWAY_URL_EXTERNAL/productpage"
```

Navigate to the URL from the output of the previous command and confirm that the sample application's product page is displayed. Alternatively, you can also use `curl` to confirm the sample application is accessible. For example:

```bash
curl -s "http://${GATEWAY_URL_EXTERNAL}/productpage" | grep -o "<title>.*</title>"
```

Confirm that the sample application's product page is accessible. The expected output is:

```html
<title>Simple Bookstore App</title>
```

## Enable internal ingress gateway

Use `az aks mesh enable-ingress-gateway` to enable an internal Istio ingress on your AKS cluster:

```azurecli
az aks mesh enable-ingress-gateway --resource-group $RESOURCE_GROUP --name $CLUSTER --ingress-gateway-type internal
```

Use `kubectl get svc` to check the service mapped to the ingress gateway:

```bash
kubectl get svc aks-istio-ingressgateway-internal -n aks-istio-ingress
```

Observe from the output that the external IP address of the service isn't a publicly accessible one and is instead only locally accessible:

```
NAME                                TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                                      AGE
aks-istio-ingressgateway-internal   LoadBalancer   10.0.182.240  <IP>      15021:30764/TCP,80:32186/TCP,443:31713/TCP   87s
```

After enabling the ingress gateway, applications need to be exposed through the gateway, and routing rules need to be configured accordingly. Use the following manifest to map the sample deployment's ingress to the Istio ingress gateway:

```bash
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: bookinfo-internal-gateway
spec:
  selector:
    istio: aks-istio-ingressgateway-internal
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: bookinfo-vs-internal
spec:
  hosts:
  - "*"
  gateways:
  - bookinfo-internal-gateway
  http:
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage
        port:
          number: 9080
EOF
```

Note

The selector used in the Gateway object points to `istio: aks-istio-ingressgateway-internal`, which can be found as label on the service mapped to the internal ingress that was enabled earlier.

Set environment variables for internal ingress host and ports:

```bash
export INGRESS_HOST_INTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-internal -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT_INTERNAL=$(kubectl -n aks-istio-ingress get service aks-istio-ingressgateway-internal -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export GATEWAY_URL_INTERNAL=$INGRESS_HOST_INTERNAL:$INGRESS_PORT_INTERNAL
```

Retrieve the address of the sample application:

```bash
echo "http://$GATEWAY_URL_INTERNAL/productpage"
```

Navigate to the URL from the output of the previous command and confirm that the sample application's product page is **NOT** displayed. Alternatively, you can also use `curl` to confirm the sample application is **NOT** accessible. For example:

```bash
curl -s "http://${GATEWAY_URL_INTERNAL}/productpage" | grep -o "<title>.*</title>"
```

Use `kubectl exec` to confirm application is accessible from inside the cluster's virtual network:

```bash
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS  "http://$GATEWAY_URL_INTERNAL/productpage"  | grep -o "<title>.*</title>"
```

Confirm that the sample application's product page is accessible. The expected output is:

```html
<title>Simple Bookstore App</title>
```

## Ingress gateway customizations

### Annotations

#### Service annotations

The following annotations can be added to the Kubernetes service for the external and internal ingress gateways. See the [document on configuring public load balancers](configure-load-balancer-standard#customize-the-load-balancer-using-kubernetes-annotations) for more information about these annotations.

- `external-dns.alpha.kubernetes.io/hostname`: for specifying the domain for resource's DNS records. For more information, see [external-dns](https://kubernetes-sigs.github.io/external-dns/latest/docs/annotations/annotations/#external-dnsalphakubernetesiohostname).
- `service.beta.kubernetes.io/azure-allowed-ip-ranges`: for specifying a list of allowed IP ranges separated by commas.
- `service.beta.kubernetes.io/azure-allowed-service-tags`: for specifying which [service tags](/en-us/azure/virtual-network/service-tags-overview) the ingress gateway can receive requests from.
- `service.beta.kubernetes.io/azure-disable-load-balancer-floating-ip`: set to `true` to disable floating IP address in load balancer rule.
- `service.beta.kubernetes.io/azure-load-balancer-internal-subnet`: name of subnet to bind internal ingress gateway to. This subnet must exist in the same virtual network as the mesh.
- `service.beta.kubernetes.io/azure-load-balancer-ipv4`: for configuring a static IPv4 address.
- `service.beta.kubernetes.io/azure-load-balancer-disable-tcp-reset`: for controlling whether Azure Load Balancer enables TCP Reset.
- `service.beta.kubernetes.io/azure-load-balancer-resource-group`: for specifying the resource group of a public IP in a different resource group from the cluster.
- `service.beta.kubernetes.io/azure-load-balancer-tcp-idle-timeout`: for configuring the TCP idle timeout in minutes for connections through the Azure Load Balancer.
- `service.beta.kubernetes.io/azure-pip-ip-tags`: for specifying a list of IpTags separated by commas.
- `service.beta.kubernetes.io/azure-pip-name`: for specifying the name of a public IP address.
- `service.beta.kubernetes.io/azure-shared-securityrule`: for exposing the ingress gateway through an [augmented security rule](/en-us/azure/virtual-network/network-security-groups-overview#augmented-security-rules).

The add-on supports the following health probe annotations for ports `80` and `443`:

- `service.beta.kubernetes.io/port_{port}_no_lb_rule`
- `service.beta.kubernetes.io/port_{port}_no_probe_rule`
- `service.beta.kubernetes.io/port_{port}_health-probe_protocol`
- `service.beta.kubernetes.io/port_{port}_health-probe_port`
- `service.beta.kubernetes.io/port_{port}_health-probe_interval`
- `service.beta.kubernetes.io/port_{port}_health-probe_num-of-probe`
- `service.beta.kubernetes.io/port_{port}_health-probe_request-path`

#### Deployment annotations

The following annotations can be added to the Kubernetes deployment for the external and internal ingress gateways:

- Under `spec.template.metadata.annotations`: `proxy.istio.io/config`. Use this annotation to configure settings such as `gatewayTopology.numTrustedProxies`. `ProxyConfig` annotations added to the ingress gateway pod or other workloads in the mesh override the `ProxyConfig` values set in the default MeshConfig and the [shared MeshConfig](istio-meshconfig).

### External traffic policy

The add-on supports customization of `.spec.externalTrafficPolicy` in the Kubernetes service for the ingress gateway. Setting `.spec.externalTrafficPolicy` to `Local` preserves the client source IP at the Istio ingress gateway and avoids a second hop in the traffic path to the backend ingress gateway pods.

```bash
kubectl patch service aks-istio-ingressgateway-external -n aks-istio-ingress --type merge --patch '{"spec": {"externalTrafficPolicy": "Local"}}'
```

Note

Modifying the `.spec.externalTrafficPolicy` to `Local` risks potentially imbalanced traffic spreading. Before applying this change, it is recommended to read the [Kubernetes docs](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) to understand the tradeoffs between the different `externalTrafficPolicy` settings.

## Delete resources

If you want to clean up the Istio external or internal ingress gateways, but leave the mesh enabled on the cluster, run the following command:

```azurecli
az aks mesh disable-ingress-gateway --ingress-gateway-type <external/internal> --resource-group ${RESOURCE_GROUP} --name ${CLUSTER}
```

If you want to clean up the Istio service mesh and the ingresses (leaving behind the cluster), run the following command:

```azurecli
az aks mesh disable --resource-group ${RESOURCE_GROUP} --name ${CLUSTER}
```

If you want to clean up all the resources created from the Istio how-to guidance documents, run the following command:

```azurecli
az group delete --name ${RESOURCE_GROUP} --yes --no-wait
```