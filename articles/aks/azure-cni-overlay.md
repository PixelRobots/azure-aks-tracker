---
layout: Conceptual
title: Configure Azure CNI Overlay Networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to configure Azure CNI Overlay networking in Azure Kubernetes Service (AKS), including setup, dual-stack networking, and example workload deployment.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.custom: references_regions, devx-track-azurecli
ms.date: 2026-07-31T00:00:00.0000000Z
zone_pivot_groups: azure-cni-overlay-create-cluster
locale: en-us
document_id: df8d7302-18d2-ecb0-a639-2829a015dd69
document_version_independent_id: 44bc2266-a637-8f3a-d9fb-b28868dbbcf3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-cni-overlay.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,bash
toc_rel: toc.json
asset_id: aks/azure-cni-overlay
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-cni-overlay.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: d462c513-b514-f302-487a-e7564894d796
---

# Configure Azure CNI Overlay Networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article explains the setup process, dual-stack networking configuration, and an example workload deployment for Azure CNI Overlay in Azure Kubernetes Service (AKS) clusters. For an overview of Azure CNI Overlay networking, see [Overview of Azure CNI Overlay networking in Azure Kubernetes Service (AKS)](concepts-network-azure-cni-overlay).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Prerequisites

- An Azure subscription. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Azure CLI version 2.48.0 or later. To install or upgrade the Azure CLI, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- An existing Azure resource group. If you need to create one, see [Create resource groups](/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli#create-resource-groups).
- If you bring your own virtual network, review the [virtual network prerequisites](concepts-network-cni-overview#aks-cni-networking-prerequisites).

::: zone pivot="aks-cni-overlay-cluster-dual-stack"

For dual-stack networking, use a [supported Kubernetes version in AKS](/en-us/azure/aks/supported-kubernetes-versions) that's available in your region.

::: zone-end

::: zone pivot="aks-cni-overlay-cluster"

## Key parameters for Azure CNI Overlay AKS clusters

The following table describes the key parameters for configuring Azure CNI Overlay networking in AKS clusters:

| Parameter | Description |
| --- | --- |
| `--network-plugin` | Set to `azure` to use Azure Container Networking Interface (CNI) networking. |
| `--network-plugin-mode` | Set to `overlay` to enable Azure CNI Overlay networking. This setting applies only when `--network-plugin=azure`. |
| `--pod-cidr` | Specify a custom pod Classless Inter-Domain Routing (CIDR) block for the cluster. The default is `10.244.0.0/16`. |

The default behavior for network plugins depends on whether you explicitly set `--network-plugin`:

- If you don't specify `--network-plugin`, AKS defaults to Azure CNI Overlay.
- If you specify `--network-plugin=azure` and omit `--network-plugin-mode`, AKS intentionally uses virtual network (node subnet) mode for backward compatibility.

## Create an Azure CNI Overlay AKS cluster

Create an Azure CNI Overlay AKS cluster by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with `--network-plugin=azure` and `--network-plugin-mode=overlay`. If you don't specify a value for `--pod-cidr`, AKS assigns the default value of `10.244.0.0/16`.

```azurecli
az aks create \
  --name $CLUSTER_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $REGION \
  --network-plugin azure \
  --network-plugin-mode overlay \
  --pod-cidr 192.168.0.0/16 \
  --generate-ssh-keys
```

## Add a new node pool to a dedicated subnet

Add a node pool to a different subnet within the same virtual network to control virtual machine (VM) node IP addresses for network traffic to virtual network or peered virtual network resources.

Add a new node pool to the cluster by using the [`az aks nodepool add`](/en-us/cli/azure/aks#az_aks_nodepool_add) command and specify the subnet resource ID with the `--vnet-subnet-id` parameter. For example:

```azurecli
az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $NODE_POOL_NAME \
  --node-count 1 \
  --mode system \
  --vnet-subnet-id $SUBNET_RESOURCE_ID
```

::: zone-end

::: zone pivot="aks-cni-overlay-cluster-dual-stack"

## About Azure CNI Overlay AKS clusters with dual-stack networking

You can deploy your Azure CNI Overlay AKS clusters in a dual-stack mode with an Azure virtual network. In this configuration, nodes receive both an IPv4 and IPv6 address from the Azure virtual network subnet. Pods receive an IPv4 and IPv6 address from a different address space to the Azure virtual network subnet of the nodes. Network address translation (NAT) is then configured so that the pods can reach resources on the Azure virtual network. The source IP address of the traffic is NAT'd to the VM node's primary IP address of the same family (*IPv4 to IPv4* and *IPv6 to IPv6*).

Note

You can also deploy dual-stack networking clusters by using Azure CNI Powered by Cilium. For more information, see [Dual-stack networking with Azure CNI Powered by Cilium](azure-cni-powered-by-cilium#dual-stack-networking-with-azure-cni-powered-by-cilium).

## Dual-stack networking limitations

The following features aren't supported with dual-stack networking:

- [Azure network policies](use-network-policies)
- [Calico network policies](use-network-policies)
- Standard NAT Gateway, which supports only IPv4. For dual-stack egress, use StandardV2 NAT Gateway. The AKS-managed `managedNATGatewayV2` outbound type is in preview. Before using StandardV2, review its [known limitations and regional availability](/en-us/azure/nat-gateway/nat-sku#known-limitations) and [known issues](/en-us/azure/nat-gateway/nat-sku#known-issues). For configuration guidance, see [Create a managed or user-assigned NAT gateway for your AKS cluster](nat-gateway).
- [Virtual nodes add-on](virtual-nodes)

## Key parameters for dual-stack networking

The following table describes the key parameters for configuring dual-stack networking in Azure CNI Overlay AKS clusters:

| Parameter | Description |
| --- | --- |
| `--ip-families` | Takes a comma-separated list of IP families to enable on the cluster. Only `ipv4` and `ipv4,ipv6` are supported. |
| `--pod-cidrs` | Takes a comma-separated list of Classless Inter-Domain Routing (CIDR) notation IP ranges to assign pod IPs from. The count and order of ranges in this list must match the value provided to `--ip-families`. If you don't supply any values, the parameter uses the default value of `10.244.0.0/16,fd12:3456:789a::/64`. |
| `--service-cidrs` | Takes a comma-separated list of CIDR notation IP ranges to assign service IPs from. The count and order of ranges in this list must match the value provided to `--ip-families`. If you don't supply any values, the parameter uses the default value of `10.0.0.0/16,fd12:3456:789a:1::/108`. The IPv6 subnet assigned to `--service-cidrs` can be no larger than `/108`. |

## Create a dual-stack Azure CNI Overlay AKS cluster (Linux)

1. Create an Azure resource group for the cluster by using the [`az group create`](/en-us/cli/azure/group#az-group-create) command:

    ```azurecli
    az group create --location $REGION --name $RESOURCE_GROUP
    ```
2. Create a dual-stack AKS cluster by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--ip-families` parameter set to `ipv4,ipv6`:

    ```azurecli
    az aks create \
      --location $REGION \
      --resource-group $RESOURCE_GROUP \
      --name $CLUSTER_NAME \
      --network-plugin azure \
      --network-plugin-mode overlay \
      --ip-families ipv4,ipv6 \
      --generate-ssh-keys
    ```

## Create a dual-stack Azure CNI Overlay AKS cluster (Windows)

1. Create a cluster with Azure CNI Overlay by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command:

    ```azurecli
    az aks create \
      --name $CLUSTER_NAME \
      --resource-group $RESOURCE_GROUP \
      --location $REGION \
      --network-plugin azure \
      --network-plugin-mode overlay \
      --ip-families ipv4,ipv6 \
      --generate-ssh-keys
    ```
2. Add a Windows node pool to the cluster by using the [`az aks nodepool add`](/en-us/cli/azure/aks#az_aks_nodepool_add) command:

    ```azurecli
    az aks nodepool add \
      --resource-group $RESOURCE_GROUP \
      --cluster-name $CLUSTER_NAME \
      --os-type Windows \
      --name $WINDOWS_NODE_POOL_NAME \
      --node-count 2
    ```

## Deploy an example workload to the Azure CNI Overlay AKS cluster

Deploy dual-stack AKS CNI Overlay clusters with IPv4/IPv6 addresses on virtual machine nodes. This example deploys an NGINX web server and exposes it by using a `LoadBalancer` service with both IPv4 and IPv6 addresses.

Before you expose the workload, ensure an NGINX deployment is running in your cluster. If you don't already have one, create the deployment and wait for it to be ready by using the following commands:

```bash
kubectl create deployment nginx --image=nginx
kubectl rollout status deployment/nginx
```

Note

We recommend using the application routing add-on for ingress in AKS clusters. However, for demonstration purposes, this example deploys an NGINX web server without the application routing add-on. For more information about the add-on, see [Managed NGINX ingress with the application routing add-on](app-routing).

### Expose the workload by using a `LoadBalancer` service

Expose the NGINX deployment by using either `kubectl` commands or YAML manifests.

This section assumes an NGINX deployment named `nginx` is running in your cluster. To verify the deployment exists and is ready, run `kubectl get deployment nginx` and confirm the **READY** column shows all desired replicas as ready.

Important

There are currently *two limitations* that pertain to IPv6 services in AKS:

- Azure Load Balancer sends health probes to IPv6 destinations from a link-local address. In *Azure Linux node pools*, you can't route this traffic to a pod, so traffic flowing to IPv6 services deployed with `externalTrafficPolicy: Cluster` fails.
- You must deploy IPv6 services with `externalTrafficPolicy: Local`, which causes `kube-proxy` to respond to the probe on the node.

# [kubectl deployment](#tab/kubectl)
1. Expose the NGINX deployment by using the `kubectl expose deployment nginx` command. The first command creates an IPv4 `LoadBalancer` service. The second command creates an IPv6 `LoadBalancer` service and uses the `--overrides` JSON to set `ipFamilies` to `IPv6` and the required `externalTrafficPolicy` to `Local`:

    ```bash
    kubectl expose deployment nginx --name=nginx-ipv4 --port=80 --type=LoadBalancer
    kubectl expose deployment nginx --name=nginx-ipv6 --port=80 --type=LoadBalancer --overrides='{"spec":{"externalTrafficPolicy":"Local","ipFamilies":["IPv6"]}}'
    ```

    Your output should show the exposed services. For example:

    ```output
    service/nginx-ipv4 exposed
    service/nginx-ipv6 exposed
    ```
2. After the deployment is exposed and the `LoadBalancer` services are fully provisioned, get the IP addresses of the services by using the `kubectl get services` command:

    ```bash
    kubectl get services
    ```

    Your output should show the services with their assigned IP addresses. For example:

    ```output
    NAME         TYPE           CLUSTER-IP               EXTERNAL-IP         PORT(S)        AGE
    nginx-ipv4   LoadBalancer   10.0.88.78               20.46.24.24         80:30652/TCP   97s
    nginx-ipv6   LoadBalancer   fd12:3456:789a:1::981a   2603:1030:8:5::2d   80:32002/TCP   63s
    ```
3. Get the service IP by using the `kubectl get services` command and set it to an environment variable:

    The command uses the JSONPath expression `{.status.loadBalancer.ingress[0].ip}` to extract the external IP address from the first entry in the service's load balancer ingress field and stores it in the `SERVICE_IP` variable.

    ```bash
    SERVICE_IP=$(kubectl get services nginx-ipv6 -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    ```
4. Verify functionality by using a `curl` request from an IPv6-capable host. (*Azure Cloud Shell isn't IPv6 capable*.)

    ```bash
    curl -s "http://[${SERVICE_IP}]" | head -n5
    ```

    Your output should show the HTML for the NGINX welcome page. For example:

    ```html
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    ```

# [YAML deployment](#tab/yaml)
1. Expose the NGINX deployment by using a YAML manifest. The following example creates two `LoadBalancer` services: one for IPv4 and one for IPv6. The IPv6 service is deployed with `externalTrafficPolicy: Local`, which causes `kube-proxy` to respond to the probe on the node.

    ```yml
    ---
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        app: nginx
      name: nginx-ipv4
    spec:
      externalTrafficPolicy: Cluster
      ports:
        - port: 80
          protocol: TCP
          targetPort: 80
      selector:
        app: nginx
      type: LoadBalancer
    ---
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        app: nginx
      name: nginx-ipv6
    spec:
      externalTrafficPolicy: Local # Deploying the IPv6 service with `externalTrafficPolicy: Local`, which causes `kube-proxy` to respond to the probe on the node
      ipFamilies:
        - IPv6
      ports:
        - port: 80
          protocol: TCP
          targetPort: 80
      selector:
        app: nginx
      type: LoadBalancer
    ```
2. After the deployment is exposed and the `LoadBalancer` services are fully provisioned, get the IP addresses of the services by using the `kubectl get services` command:

    ```bash
    kubectl get services
    ```

    Your output should show the services with their assigned IP addresses. For example:

    ```output
    NAME         TYPE           CLUSTER-IP               EXTERNAL-IP         PORT(S)        AGE
    nginx-ipv4   LoadBalancer   10.0.88.78               20.46.24.24         80:30652/TCP   97s
    nginx-ipv6   LoadBalancer   fd12:3456:789a:1::981a   2603:1030:8:5::2d   80:32002/TCP   63s
    ```

---

::: zone-end