---
layout: Conceptual
title: Azure Kubernetes Service (AKS) egress gateway for Istio service mesh add-on - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-deploy-egress
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
description: Deploy egress gateways for Istio service mesh add-on for Azure Kubernetes Service
ms.topic: how-to
author: nshankar
ms.date: 2025-04-25T00:00:00.0000000Z
ms.author: nshankar
locale: en-us
document_id: 1538f300-3352-5df2-af61-30fa1c12e149
document_version_independent_id: 9deaa9f0-2841-e4ea-5d59-663eb59f2241
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-deploy-egress.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/istio-deploy-egress
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-deploy-egress.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1ca43864-c34c-5330-c7dd-12aff0587f40
---

# Azure Kubernetes Service (AKS) egress gateway for Istio service mesh add-on - Azure Kubernetes Service | Microsoft Learn

This article shows you how to deploy egress gateways for the Istio service mesh add-on for Azure Kubernetes Service (AKS) cluster.

## Overview

The Istio egress gateway can serve as a centralized point to monitor and restrict outbound traffic from applications in the mesh. With the Istio add-on, you can deploy multiple egress gateways across different namespaces, allowing you to set up an egress gateway topology of your choice: egress gateways per-cluster, per-namespace, per-workload, etc. While AKS manages the provisioning and lifecycle of the Istio add-on egress gateways, you must create Istio custom resources to route traffic from applications in the mesh through the egress gateway and apply policies and telemetry collection.

The Istio add-on egress gateway also builds on top of and requires the [Static Egress Gateway](configure-static-egress-gateway) feature, which assigns a fixed source IP address prefix to the Istio egress Pods. You can use this predicable egress IP range for firewall rules and other outbound traffic filtering mechanisms. By using Istio egress gateway on top of Static Egress Gateway, you can apply Istio L7, identity-based policies, and IP-based restrictions for defense-in-depth egress traffic control. Additionally, directing outbound traffic through the Istio egress gateway allows multiple workloads to route traffic via the Static Egress Gateway node pools without modifying those application pods/deployments directly.

## Limitations and requirements

- You can enable a maximum of `500` Istio add-on egress gateways per cluster.
- Istio add-on egress gateway names must be unique per namespace.
- Istio add-on egress gateway names must be between `1-53` characters, must only consist of lowercase alphanumerical characters, '-' and '.,' and must start and end with an alphanumerical character. Names should also be a valid Domain Name System (DNS) name. The regex used for name validation is `^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$`.
- Using the [Kubernetes Gateway API](istio-gateway-api) for egress traffic management with the Istio add-on is only supported for the [manual deployment model](https://istio.io/latest/docs/tasks/traffic-management/ingress/gateway-api/#manual-deployment).
- Because Static Egress Gateway is currently not supported on [Azure CNI Pod Subnet clusters](concepts-network-azure-cni-pod-subnet), the Istio add-on egress gateway isn't supported on Pod Subnet clusters either.

## Prerequisites

### Enable Istio add-on

This guide assumes you followed the [documentation](istio-deploy-addon) to enable the Istio add-on on an AKS cluster.

### Update Azure CLI version

You must use `azure-cli` version `2.80.0` or higher. Run `az --version` to find your `azure-cli` version, and run `az upgrade` to upgrade.

### Enable and configure Static Egress Gateway

Follow the instructions in the [Static Egress Gateway documentation](configure-static-egress-gateway) to enable Static Egress Gateway on your cluster, create a node pool of mode `gateway`, and create a `StaticGatewayConfiguration` resource.

## Enable an Istio egress gateway

Note

The Istio add-on egress gateway pods don't get scheduled onto the `gateway` node pool. The `gateway` node pool exists for IP-based routing of static egress traffic, and doesn't host workloads, including the gateway. If you need to schedule the egress gateway pods onto specific nodes, use the `azureservicemesh/istio.replica.preferred` node label or [AKS system nodes](/en-us/azure/aks/use-system-pools). The pods have node affinities with a weighted preference of `100` for nodes labeled `azureservicemesh/istio.replica.preferred: true` and a weighted preference of `50` for AKS system nodes (labeled `kubernetes.azure.com/mode: system`). This configuration means that if the `azureservicemesh/istio.replica.preferred: true` label isn't found or such nodes are unschedulable, pods are instead scheduled on AKS system nodes.

For revisions earlier than `asm-1-30`, these weights are reversed: `100` for AKS system nodes and `50` for `azureservicemesh/istio.replica.preferred: true` nodes.

Use `az aks mesh enable-egress-gateway` to enable an Istio egress gateway on your AKS cluster. You must specify a name for the Istio egress gateway and the name of the `StaticGatewayConfiguration` that you created in the prerequisites step. You can also specify a namespace to deploy the Istio egress gateway in, which must be the same namespace that the `StaticGatewayConfiguration` was created in. If you don't specify a namespace, the egress gateway gets provisioned in the `aks-istio-egress` namespace.

As a best-practice, you should wait until the `StaticGatewayConfiguration` is assigned an `egressIpPrefix` before enabling the Istio egress gateway using that gateway configuration.

```azurecli
az aks mesh enable-egress-gateway --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --istio-egressgateway-name $ISTIO_EGRESS_NAME --istio-egressgateway-namespace $ISTIO_EGRESS_NAMESPACE --gateway-configuration-name $ISTIO_SGC_NAME
```

Verify that the service gets created for the egress gateway.

```bash
kubectl get svc $ISTIO_EGRESS_NAME -n $ISTIO_EGRESS_NAMESPACE
```

You should see a `ClusterIP` service for the egress gateway:

```
NAME              TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                    AGE
asm-egress-test   ClusterIP   10.0.128.17   <none>        15021/TCP,80/TCP,443/TCP   6d4h
```

You can also verify that a deployment gets created for the Istio egress gateway and that the egress gateway pods have the `kubernetes.azure.com/static-gateway-configuration` annotation set to the `gatewayConfigurationName`.

```bash
ASM_REVISION=$(az aks show -g $RESOURCE_GROUP -n $CLUSTER_NAME | jq '.serviceMeshProfile.istio.revisions[0]' | sed 's/"//g')

kubectl get deployment $ISTIO_EGRESS_NAME-$ASM_REVISION -n $ISTIO_EGRESS_NAMESPACE -o jsonpath={.spec.template.metadata.annotations."kubernetes\.azure\.com\/static-gateway-configuration"}
```

You can run the `az aks mesh enable-egress-gateway` command again to create another Istio egress gateway.

Note

When you perform a [minor revision upgrade](istio-upgrade#minor-revision-upgrades-with-ingress-and-egress-gateways) of the Istio add-on, another deployment for each egress gateway gets created for the new control plane revision.

## Route traffic through the Istio egress gateway

### Set `outboundTrafficPolicy.mode`

By default, the Istio `outboundTrafficPolicy.mode` is set to `ALLOW_ANY`, meaning that Envoy passes through requests for unknown services. As a security best-practice, you should set the Istio `outboundTrafficPolicy.mode` to `REGISTRY_ONLY` so that the Istio proxy blocks requests to services that weren't added to Istio's Service Registry. You can add hosts outside of the cluster to Istio's service registry with a `ServiceEntry`.

You can configure the `outboundTrafficPolicy.mode` on a mesh-wide level using the Istio add-on [shared MeshConfig](istio-meshconfig), or use the [Sidecar Custom Resource](https://istio.io/latest/docs/reference/config/networking/sidecar/#OutboundTrafficPolicy) to target specific namespaces or workloads.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: istio-shared-configmap-asm-1-27
  namespace: aks-istio-system
data:
  mesh: |-
    outboundTrafficPolicy:
      mode: REGISTRY_ONLY
```

### Deploy sample application

In this example, we deploy the `curl` application in the same namespace as the Istio add-on egress gateway. Remember to label the `ISTIO_EGRESS_NAMESPACE` with the `istio.io/rev` label so that the deployed application pod gets injected with a sidecar:

```bash
kubectl label namespace $ISTIO_EGRESS_NAMESPACE istio.io/rev=$ASM_REVISION
```

Then, deploy the sample application:

```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.27/samples/curl/curl.yaml -n $ISTIO_EGRESS_NAMESPACE
```

You should see the `curl` pod running with an injected sidecar container:

```
NAME                                       READY   STATUS    RESTARTS   AGE
curl-5b549b49b8-bcgts                      2/2     Running   0          13s
```

Try sending a request from `curl` directly to `edition.cnn.com`:

```bash
SOURCE_POD=$(kubectl get pod -n $ISTIO_EGRESS_NAMESPACE -l app=curl -o jsonpath={.items..metadata.name})

kubectl exec -n $ISTIO_EGRESS_NAMESPACE "$SOURCE_POD" -c curl -- curl -sSL -o /dev/null -D - http://edition.cnn.com/politics
```

If you set `outboundTrafficPolicy.mode` to `REGISTRY_ONLY`, then the `curl` request should fail because you didn't create a `ServiceEntry` for `edition.cnn.com`. If `outboundTrafficPolicy.mode` is `ALLOW_ANY`, then the request should succeed.

To actually route requests to `edition.cnn.com` from the `curl` pod to the Istio add-on egress gateway, you need to create a `ServiceEntry` and configure other Istio custom resources. Follow instructions one of the subsequent sections to configure an HTTP Egress Gateway, HTTPS Egress Gateway, or an Egress Gateway that originates a Transport Layer Security (TLS) connection.

Before starting any of the following scenarios, set these environment variables:

```bash
ISTIO_EGRESS_DEPLOYMENT=$ISTIO_EGRESS_NAME-$ASM_REVISION
EGRESS_GTW_SELECTOR=$(kubectl get deployment $ISTIO_EGRESS_DEPLOYMENT -n $ISTIO_EGRESS_NAMESPACE -o jsonpath={.metadata.labels.istio})
```

You can also [enable Envoy access logging](https://istio.io/latest/docs/tasks/observability/logs/access-log/) either through the [MeshConfig](istio-meshconfig) or [Telemetry API](istio-telemetry). Once you have access logging enabled, you can verify that traffic is flowing through the egress gateway by inspecting the `istio-proxy` container logs:

```bash
kubectl logs -l istio=$EGRESS_GTW_SELECTOR -n $ISTIO_EGRESS_NAMESPACE
```

### Configure an HTTP Istio egress gateway

1. Create a `ServiceEntry` for `edition.cnn.com`:

```bash
kubectl apply -n $ISTIO_EGRESS_NAMESPACE -f - <<EOF
apiVersion: networking.istio.io/v1
kind: ServiceEntry
metadata:
  name: cnn
spec:
  hosts:
  - edition.cnn.com
  ports:
  - number: 80
    name: http-port
    protocol: HTTP
  - number: 443
    name: https
    protocol: HTTPS
  resolution: DNS
EOF
```

1. Create the `Gateway`, `VirtualService`, and `DestinationRule` to route HTTP traffic from the `curl` application to `edition.cnn.com` through the egress gateway. Be sure to set the gateway selector and service Fully Qualified Domain Name (FQDN) accordingly based on the `istio` label selector in the egress gateway deployment.

```bash
kubectl apply -n $ISTIO_EGRESS_NAMESPACE -f - <<EOF
apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: istio-egressgateway
spec:
  selector:
    istio: $EGRESS_GTW_SELECTOR
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - edition.cnn.com
---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: egressgateway-for-cnn
spec:
  host: $ISTIO_EGRESS_NAME.$ISTIO_EGRESS_NAMESPACE.svc.cluster.local
  subsets:
  - name: cnn
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: direct-cnn-through-egress-gateway
spec:
  hosts:
  - edition.cnn.com
  gateways:
  - istio-egressgateway
  - mesh
  http:
  - match:
    - gateways:
      - mesh
      port: 80
    route:
    - destination:
        host: $ISTIO_EGRESS_NAME.$ISTIO_EGRESS_NAMESPACE.svc.cluster.local
        subset: cnn
        port:
          number: 80
      weight: 100
  - match:
    - gateways:
      - istio-egressgateway
      port: 80
    route:
    - destination:
        host: edition.cnn.com
        port:
          number: 80
      weight: 100
EOF
```

1. Try sending an HTTP request from the `curl` pod to `edition.cnn.com`:

```bash
kubectl exec -n $ISTIO_EGRESS_NAMESPACE "$SOURCE_POD" -c curl -- curl -sSL -o /dev/null -D - http://edition.cnn.com/politics
```

You should see an `HTTP/2 200` response.

1. Clean up resources

```bash
kubectl delete serviceentry cnn -n $ISTIO_EGRESS_NAMESPACE
kubectl delete gateway istio-egressgateway -n $ISTIO_EGRESS_NAMESPACE
kubectl delete virtualservice direct-cnn-through-egress-gateway -n $ISTIO_EGRESS_NAMESPACE
kubectl delete destinationrule egressgateway-for-cnn -n $ISTIO_EGRESS_NAMESPACE
```

### Configure an HTTPS Istio egress gateway

1. Create an HTTPS `ServiceEntry` for `edition.cnn.com`:

```bash
kubectl apply -n $ISTIO_EGRESS_NAMESPACE -f - <<EOF
apiVersion: networking.istio.io/v1
kind: ServiceEntry
metadata:
  name: cnn
spec:
  hosts:
  - edition.cnn.com
  ports:
  - number: 443
    name: tls
    protocol: TLS
  resolution: DNS
EOF
```

1. Create the `Gateway`, `VirtualService`, and `DestinationRule` to route HTTP traffic from the `curl` application to `edition.cnn.com` through the egress gateway. Be sure to set the gateway selector and service FQDN accordingly based on the `istio` label selector in the egress gateway deployment.

```bash
kubectl apply -n $ISTIO_EGRESS_NAMESPACE -f - <<EOF
apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: istio-egressgateway
spec:
  selector:
    istio: $EGRESS_GTW_SELECTOR
  servers:
  - port:
      number: 443
      name: tls
      protocol: TLS
    hosts:
    - edition.cnn.com
    tls:
      mode: PASSTHROUGH
---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: egressgateway-for-cnn
spec:
  host: $ISTIO_EGRESS_NAME.$ISTIO_EGRESS_NAMESPACE.svc.cluster.local
  subsets:
  - name: cnn
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: direct-cnn-through-egress-gateway
spec:
  hosts:
  - edition.cnn.com
  gateways:
  - mesh
  - istio-egressgateway
  tls:
  - match:
    - gateways:
      - mesh
      port: 443
      sniHosts:
      - edition.cnn.com
    route:
    - destination:
        host: $ISTIO_EGRESS_NAME.$ISTIO_EGRESS_NAMESPACE.svc.cluster.local
        subset: cnn
        port:
          number: 443
  - match:
    - gateways:
      - istio-egressgateway
      port: 443
      sniHosts:
      - edition.cnn.com
    route:
    - destination:
        host: edition.cnn.com
        port:
          number: 443
      weight: 100
EOF
```

1. Try sending an HTTPS request from `curl` to `edition.cnn.com`:

```bash
kubectl exec "$SOURCE_POD" -n $ISTIO_EGRESS_NAMESPACE -c curl -- curl -sSL -o /dev/null -D - https://edition.cnn.com/politics
```

You should see an `HTTP/2 200` response.

1. Clean up resources

```bash
kubectl delete serviceentry cnn -n $ISTIO_EGRESS_NAMESPACE
kubectl delete gateway istio-egressgateway -n $ISTIO_EGRESS_NAMESPACE
kubectl delete virtualservice direct-cnn-through-egress-gateway -n $ISTIO_EGRESS_NAMESPACE
kubectl delete destinationrule egressgateway-for-cnn -n $ISTIO_EGRESS_NAMESPACE
```

### Configure an Istio egress gateway to perform TLS Origination

1. Create a `ServiceEntry` for `edition.cnn.com`:

```bash
kubectl apply -n $ISTIO_EGRESS_NAMESPACE -f - <<EOF
apiVersion: networking.istio.io/v1
kind: ServiceEntry
metadata:
  name: cnn
spec:
  hosts:
  - edition.cnn.com
  ports:
  - number: 80
    name: http
    protocol: HTTP
  - number: 443
    name: https
    protocol: HTTPS
  resolution: DNS
EOF
```

1. Create the `Gateway`, `VirtualService`, and `DestinationRule` to route HTTP traffic from the `curl` application to `edition.cnn.com` through the egress gateway, and to perform TLS origination at the egress gateway. Be sure to set the gateway selector and service FQDN accordingly based on the `istio` label selector in the egress gateway deployment.

```bash
kubectl apply -n $ISTIO_EGRESS_NAMESPACE -f - <<EOF
apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: istio-egressgateway
spec:
  selector:
    istio: $EGRESS_GTW_SELECTOR
  servers:
  - port:
      number: 80
      name: https-port-for-tls-origination
      protocol: HTTPS
    hosts:
    - edition.cnn.com
    tls:
      mode: ISTIO_MUTUAL
---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: egressgateway-for-cnn
spec:
  host: $ISTIO_EGRESS_NAME.$ISTIO_EGRESS_NAMESPACE.svc.cluster.local
  subsets:
  - name: cnn
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
      portLevelSettings:
      - port:
          number: 80
        tls:
          mode: ISTIO_MUTUAL
          sni: edition.cnn.com
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: direct-cnn-through-egress-gateway
spec:
  hosts:
  - edition.cnn.com
  gateways:
  - istio-egressgateway
  - mesh
  http:
  - match:
    - gateways:
      - mesh
      port: 80
    route:
    - destination:
        host: $ISTIO_EGRESS_NAME.$ISTIO_EGRESS_NAMESPACE.svc.cluster.local
        subset: cnn
        port:
          number: 80
      weight: 100
  - match:
    - gateways:
      - istio-egressgateway
      port: 80
    route:
    - destination:
        host: edition.cnn.com
        port:
          number: 443
      weight: 100
---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: originate-tls-for-edition-cnn-com
spec:
  host: edition.cnn.com
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
    portLevelSettings:
    - port:
        number: 443
      tls:
        mode: SIMPLE # initiates HTTPS for connections to edition.cnn.com
EOF
```

1. Try sending a request form `curl` to `edition.cnn.com` with the egress gateway performing TLS origination;

```bash
kubectl exec "${SOURCE_POD}" -n $ISTIO_EGRESS_NAMESPACE -c curl -- curl -sSL -o /dev/null -D - http://edition.cnn.com/politics
```

You should see a `200` status response.

1. Clean up resources

```bash
kubectl delete serviceentry cnn -n $ISTIO_EGRESS_NAMESPACE
kubectl delete gateway istio-egressgateway -n $ISTIO_EGRESS_NAMESPACE
kubectl delete virtualservice direct-cnn-through-egress-gateway -n $ISTIO_EGRESS_NAMESPACE
kubectl delete destinationrule originate-tls-for-edition-cnn-com -n $ISTIO_EGRESS_NAMESPACE
kubectl delete destinationrule egressgateway-for-cnn -n $ISTIO_EGRESS_NAMESPACE
```

## Disable the Istio egress gateway

Run the `az aks mesh disable-egress-gateway` command to disable the Istio add-on egress gateway that you created:

```azurecli
az aks mesh disable-egress-gateway --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --istio-egressgateway-name $ISTIO_EGRESS_NAME --istio-egressgateway-namespace $ISTIO_EGRESS_NAMESPACE
```

Once you disable the Istio egress gateway, you should be able to delete the `StaticGatewayConfiguration`, namespace, and `gateway` node pool that the egress gateway was using if no other Istio egress gateway is using them.