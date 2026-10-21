---
layout: Conceptual
title: Configure Static Egress Gateway in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-static-egress-gateway
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
description: Learn how to configure Static Egress Gateway in Azure Kubernetes Service (AKS) to manage egress traffic from a constant IP address.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2026-08-06T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 182c02a4-964d-4660-0fa8-8038ff775576
document_version_independent_id: ce99cf01-a630-c540-0f8b-a112d36b75e1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-static-egress-gateway.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/configure-static-egress-gateway
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-static-egress-gateway.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9de51e54-8a1c-147b-3124-85a1df1aff99
---

# Configure Static Egress Gateway in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Static Egress Gateway in Azure Kubernetes Service (AKS) routes pod egress traffic through a dedicated gateway node pool with fixed source IP addresses. This article shows you how to enable the feature, configure a gateway, route pod traffic, and monitor or remove the configuration.

## Limitations and considerations

- Static Egress Gateway isn't supported in clusters with [Azure CNI Pod Subnet](concepts-network-azure-cni-pod-subnet).
- Static Egress Gateway supports IPv4-only clusters and isn't supported in dual-stack clusters.
- Kubernetes network policies don't apply to traffic that annotated pods route through the gateway node pool. Other cluster traffic isn't affected.
- Use the gateway node pool only for egress traffic, not for general-purpose workloads.
- Windows node pools can't be used as gateway node pools.
- You can't annotate `hostNetwork` pods to use the gateway node pool.
- Pods can only use a gateway node pool if they are in the same namespace as the `StaticGatewayConfiguration` resource.

## Prerequisites

- Azure CLI version 2.75.0 or later. Run `az version` to find your installed version. If you need to install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).

## Create or update an AKS cluster with Static Egress Gateway

Before you can create and manage gateway node pools, you must enable the Static Egress Gateway feature for your AKS cluster. You can do this when creating a new cluster or by updating an existing cluster using [`az aks update`](/en-us/cli/azure/aks#az-aks-update).

```azurecli
az aks create --name <cluster-name> --resource-group <resource-group> --enable-static-egress-gateway
```

To enable Static Egress Gateway on an existing cluster, run the following command:

```azurecli
az aks update --name <cluster-name> --resource-group <resource-group> --enable-static-egress-gateway
```

## Create a gateway node pool

After enabling the feature, create a dedicated gateway node pool. This node pool handles the egress traffic through the specified public IP prefix. The `--gateway-prefix-size` is the size of the public IP prefix to be applied to the gateway node pool nodes. The allowed range is `28`-`31`.

| Prefix size | Available IP addresses | Maximum gateway nodes |
| --- | --- | --- |
| `/28` | 16 | 16 |
| `/29` | 8 | 8 |
| `/30` | 4 | 4 |
| `/31` | 2 | 2 |

```azurecli
az aks nodepool add --cluster-name <cluster-name> \
    --name <nodepool-name> \
    --resource-group <resource-group> \
    --mode gateway \
    --node-count <number-of-nodes> \
    --gateway-prefix-size <prefix-size>
```

Note

- The number of nodes must fit within the capacity allowed by the selected prefix size. For example, a /30 prefix supports up to 4 nodes, and at least 2 nodes are required for high availability. You can manually scale the node pool within the prefix capacity, but cluster autoscaler isn't supported.
- You can define the SKU of the VM to use in your gateway node pool with the `--vm-size` parameter. You should understand your specific needs and plan accordingly to ensure the right performance and cost balance.

## Scale the gateway node pool

Manually scale the gateway node pool within the capacity of its public IP prefix. Gateway node pools don't support cluster autoscaler.

```azurecli
az aks nodepool scale --cluster-name <cluster-name> \
  --name <nodepool-name> \
  --resource-group <resource-group> \
  --node-count <desired-node-count>
```

## Create a StaticGatewayConfiguration resource

Define the gateway configuration by creating a `StaticGatewayConfiguration` custom resource. This configuration specifies which node pool and public IP prefix to use.

| Field | Required | Description |
| --- | --- | --- |
| `gatewayNodepoolName` | Yes | Name of the gateway node pool that handles egress traffic. |
| `excludeCidrs` | No | Destination CIDRs that bypass the gateway and use the pod's primary network interface. |
| `publicIpPrefixId` | No | Resource ID of an existing public IP prefix. If omitted, the controller creates a prefix. |

```yaml
apiVersion: egressgateway.kubernetes.azure.com/v1alpha1
kind: StaticGatewayConfiguration
metadata:
  name: <gateway-config-name>
  namespace: <namespace>
spec:
  gatewayNodepoolName: <nodepool-name>
  excludeCidrs:  # Optional
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 169.254.169.254/32
  publicIpPrefixId: /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/publicIPPrefixes/<prefix-name> # Optional
```

Save the manifest as `static-gateway-configuration.yaml`, and then apply it:

```bash
kubectl apply -f static-gateway-configuration.yaml
```

Wait for the controller to populate `.status.egressIpPrefix` before you create or restart annotated workloads. Run the following command until it returns the assigned prefix:

```bash
kubectl get staticgatewayconfiguration <gateway-config-name> \
    --namespace <namespace> \
    --output jsonpath='{.status.egressIpPrefix}'
```

Tip

If you omit `publicIpPrefixId`, the controller creates a public IP prefix. Run `kubectl describe StaticGatewayConfiguration <gateway-config-name> --namespace <namespace>` and check `Egress Ip Prefix` in the status. To use an existing prefix, specify its resource ID in `publicIpPrefixId` and grant the AKS cluster identity the Network Contributor role.

## Configure Static Egress Gateway with private IP addresses

Important

Static private IP support is in preview and requires clusters running Kubernetes version 1.34 or later.

If you need to keep egress traffic on private addresses, create a gateway node pool that uses the `VirtualMachines` VM set type. Node public IPs are disabled by default. The `StaticGatewayConfiguration` resource in the following steps separately disables public IP provisioning for egress.

```azurecli
az aks nodepool add --cluster-name <cluster-name> \
  --name <nodepool-name> \
  --resource-group <resource-group> \
  --mode gateway \
  --node-count <number-of-nodes> \
  --vm-set-type VirtualMachines \
  --gateway-prefix-size <prefix-size>
```

Tip

Specify `--vnet-subnet-id` to allocate the gateway nodes' private IP addresses from a custom subnet. A separate subnet can improve network isolation and IP address planning.

Important

Private IP mode doesn't create an outbound route. Before you annotate workloads, configure a route from the gateway node pool subnet to the intended destination by using a user-defined route with Azure Firewall or another network virtual appliance, or by using ExpressRoute. For more information, see [Customize cluster egress with outbound types in AKS](egress-outboundtype). Specifying `--vnet-subnet-id` alone doesn't provide outbound connectivity.

Set `provisionPublicIps: false` to disable public IP provisioning and keep the private IPs allocated to the gateway nodes for the lifetime of the `StaticGatewayConfiguration`. The `gatewayNodepoolName` value must match the gateway node pool that you created with `--vm-set-type VirtualMachines`.

```yaml
apiVersion: egressgateway.kubernetes.azure.com/v1alpha1
kind: StaticGatewayConfiguration
metadata:
  name: <gateway-config-name>
  namespace: <namespace>
spec:
  gatewayNodepoolName: <nodepool-name>
  provisionPublicIps: false
```

Save the manifest as `static-gateway-configuration.yaml`, and then apply it:

```bash
kubectl apply -f static-gateway-configuration.yaml
```

Before you create or restart annotated workloads, run the following command until `.status.egressIpPrefix` contains the assigned private IP addresses:

```bash
kubectl get staticgatewayconfiguration <gateway-config-name> \
  --namespace <namespace> \
  --output jsonpath='{.status.egressIpPrefix}'
```

When you run `kubectl describe StaticGatewayConfiguration <gateway-config-name> -n <namespace>`, the `egressIpPrefix` field shows a comma-separated list of those static private IPs. You continue to use the same APIs and manifests for the rest of the workflow, including the `StaticGatewayConfiguration` resource and the pod annotations.

## Annotate pods to use the gateway configuration

To route traffic from specific pods through the gateway node pool, add the `kubernetes.azure.com/static-gateway-configuration` annotation to the pod template. Set the annotation value to the `metadata.name` of a `StaticGatewayConfiguration` resource in the same namespace.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <deployment-name>
  namespace: <namespace>
spec:
  template:
    metadata:
      annotations:
        kubernetes.azure.com/static-gateway-configuration: <gateway-config-name>
```

Note

The CNI plugin on each node configures new pods to route traffic through the selected gateway node pool.

The CNI plugin configures the gateway when a pod is created. If you didn't replace existing pods when you added the annotation, restart the workload. For example, restart a deployment by using the following command:

```bash
kubectl rollout restart deployment <deployment-name> --namespace <namespace>
```

## Monitor Static Egress Gateway configurations

To monitor a configuration, retrieve the complete `StaticGatewayConfiguration` resource:

```bash
kubectl get staticgatewayconfiguration <gateway-config-name> \
  --namespace <namespace> \
  --output yaml
```

In the `status` section, verify the following fields:

- `egressIpPrefix` contains the assigned public IP prefix or private IP addresses.
- `gatewayServerProfile.ip` and `gatewayServerProfile.port` identify the gateway endpoint.
- `gatewayServerProfile.publicKey` contains the public key for the WireGuard configuration, which defines the encrypted tunnel between pods and the gateway node pool.

## Delete a gateway node pool

Before you delete a gateway node pool, remove the gateway annotation from pod templates and replace the existing pods, or delete the workloads that use it. Then, delete every `StaticGatewayConfiguration` that references the node pool. The command waits for the controller's cleanup finalizers to complete before it returns:

```bash
kubectl delete staticgatewayconfiguration <gateway-config-name> \
  --namespace <namespace> \
  --wait=true \
  --timeout=5m
```

After you delete all configurations that reference the node pool, delete the gateway node pool:

```azurecli
az aks nodepool delete --cluster-name <cluster-name> \
  --name <nodepool-name> \
  --resource-group <resource-group>
```

## Disable the Static Egress Gateway feature

If you no longer need Static Egress Gateway, disable the feature and uninstall the operator:

1. Delete every `StaticGatewayConfiguration` and wait for its cleanup to finish.
2. Delete each gateway node pool.

    ```azurecli
    az aks nodepool delete --cluster-name <cluster-name> \
      --name <nodepool-name> \
      --resource-group <resource-group>
    ```
3. Disable Static Egress Gateway.

    ```azurecli
    az aks update --name <cluster-name> --resource-group <resource-group> --disable-static-egress-gateway
    ```