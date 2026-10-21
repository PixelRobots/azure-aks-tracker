---
layout: Conceptual
title: Use a static IP with a load balancer in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/static-ip
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
description: Learn how to create and use a static IP address with the Azure Kubernetes Service (AKS) load balancer.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.custom: devx-track-azurecli
ms.topic: how-to
ms.date: 2026-09-09T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 638f8201-ceeb-f294-d532-ed278ffa2a8f
document_version_independent_id: 5ff3783d-6008-4673-1307-58bedae20da5
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/static-ip.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/static-ip
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/static-ip.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4c28c3ab-e9ef-5514-4309-a8c105b021de
---

# Use a static IP with a load balancer in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

When you create a load balancer resource in an Azure Kubernetes Service (AKS) cluster, the public IP address assigned to it is only valid for the lifespan of that resource. If you delete the Kubernetes service, the associated load balancer and IP address are also deleted. If you want to assign a specific IP address or retain an IP address for redeployed Kubernetes services, you can create and use a static public IP address.

This article shows you how to create a static public IP address and assign it to your Kubernetes service.

## Before you begin

- You need the Azure CLI version 2.0.59 or later installed and configured. Run [`az --version`](/en-us/cli/azure/reference-index#az-version) to find the version. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- This article covers using a *Standard* SKU IP with a *Standard* SKU load balancer. For more information, see [IP address types and allocation methods in Azure](/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku).

## Create an AKS cluster

1. Create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name myNetworkResourceGroup --location eastus
    ```
2. Create an AKS cluster by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

    ```azurecli
    az aks create --name myAKSCluster --resource-group myNetworkResourceGroup --generate-ssh-keys
    ```

## Create a static IP address

1. Get the name of the node resource group using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and query for the `nodeResourceGroup` property.

    ```azurecli
    az aks show --name myAKSCluster --resource-group myNetworkResourceGroup --query nodeResourceGroup -o tsv
    ```
2. Create a static public IP address in the node resource group by using the [`az network public-ip create`](/en-us/cli/azure/network/public-ip#az-network-public-ip-create) command.

    ```azurecli
    az network public-ip create \
        --resource-group <node resource group name> \
        --name myAKSPublicIP \
        --sku Standard \
        --allocation-method static
    ```

    Important

    AKS no longer supports Basic Load Balancer. If your cluster uses a Basic Load Balancer, [upgrade to Standard Load Balancer](upgrade-basic-load-balancer-on-aks) before you configure a static public IP address.
3. Get the static public IP address by using the [`az network public-ip show`](/en-us/cli/azure/network/public-ip#az-network-public-ip-show) command. Specify the name of the node resource group and the public IP address you created, and query for the `ipAddress`.

    ```azurecli
    az network public-ip show --resource-group <node resource group name> --name myAKSPublicIP --query ipAddress --output tsv
    ```

## Create a Kubernetes service with the static IP address

1. Create a file named `load-balancer-service.yaml` and copy in the contents of the following YAML file. Provide the public IP resource name (`myAKSPublicIP`) that you created in the Create a static IP address section and the node resource group name.

    The AKS control plane identity has Contributor permissions on the node resource group by default, so the public IP you create in this article doesn't require another role assignment. If you use an inbound or outbound public IP in a different resource group, grant the control plane identity the required permissions on that resource group. For more information, see [Managed identities in AKS](managed-identity-overview#control-plane-managed-identity-role-assignments).

    Important

    The `loadBalancerIP` property in a Kubernetes service manifest is deprecated following [upstream Kubernetes](https://github.com/kubernetes/kubernetes/pull/107235). Existing services continue working without modification, but use service annotations instead.

    | Annotation | Purpose |
    | --- | --- |
    | `service.beta.kubernetes.io/azure-pip-name` | Specify the public IP resource name. |
    | `service.beta.kubernetes.io/azure-load-balancer-ipv4` | Specify an IPv4 address. |
    | `service.beta.kubernetes.io/azure-load-balancer-ipv6` | Specify an IPv6 address. |

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      annotations:
        service.beta.kubernetes.io/azure-load-balancer-resource-group: <node resource group name>
        service.beta.kubernetes.io/azure-pip-name: myAKSPublicIP
      name: azure-load-balancer
    spec:
      type: LoadBalancer
      ports:
      - port: 80
      selector:
        app: azure-load-balancer
    ```

    Note

    Adding the `service.beta.kubernetes.io/azure-pip-name` annotation ensures the most efficient LoadBalancer creation and is highly recommended to avoid potential throttling.
2. Set a public-facing DNS label to the service using the `service.beta.kubernetes.io/azure-dns-label-name` service annotation. This publishes a fully qualified domain name (FQDN) for your service using Azure's public DNS servers and top-level domain. The annotation value must be unique within the Azure location, so we recommend you use a sufficiently qualified label. Azure automatically appends a default suffix in the location you selected, such as `<location>.cloudapp.azure.com`, to the name you provide, creating the FQDN.

    Note

    If you want to publish the service on your own domain, see [Azure DNS](https://azure.microsoft.com/services/dns/) and the [external-dns](https://github.com/kubernetes-sigs/external-dns) project.

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      annotations:
        service.beta.kubernetes.io/azure-load-balancer-resource-group: <node resource group name>
        service.beta.kubernetes.io/azure-pip-name: myAKSPublicIP
        service.beta.kubernetes.io/azure-dns-label-name: <unique-service-label>
      name: azure-load-balancer
    spec:
      type: LoadBalancer
      ports:
      - port: 80
      selector:
        app: azure-load-balancer
    ```
3. Before you create the service, ensure your cluster has a workload with pods that use the `app: azure-load-balancer` label. The service manifest selects pods with this label but doesn't create a deployment.
4. Create the service by using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f load-balancer-service.yaml
    ```
5. Verify that the service selects at least one running, ready pod.

    ```bash
    kubectl get pods -l app=azure-load-balancer
    ```
6. To see the DNS label for your load balancer, use the [`kubectl describe`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command.

    ```bash
    kubectl describe service azure-load-balancer
    ```

    The DNS label will be listed under the `Annotations`, as shown in the following condensed example output:

    ```output
    Name:                    azure-load-balancer
    Namespace:               default
    Labels:                  <none>
    Annotations:             service.beta.kubernetes.io/azure-dns-label-name: <unique-service-label>
    ```

## Troubleshoot

This section assumes you completed the Create a static IP address, attempted the steps in Create a Kubernetes service with the static IP address, and have a running AKS cluster. To retrieve the node resource group name, use `az aks show --name myAKSCluster --resource-group myNetworkResourceGroup --query nodeResourceGroup -o tsv`.

If the public IP resource named in the `service.beta.kubernetes.io/azure-pip-name` annotation doesn't exist in the resource group specified by `service.beta.kubernetes.io/azure-load-balancer-resource-group`, or the AKS control plane identity can't access that resource group, the load balancer service creation fails. To troubleshoot, review the service annotations and creation events by using the [`kubectl describe`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command. Provide the name of the service specified in the YAML manifest, as shown in the following example:

```bash
kubectl describe service azure-load-balancer
```

The output shows you information about the Kubernetes service resource. The following example output shows a `Warning` in the `Events`: "`user supplied IP address was not found`." In this scenario, ensure the `azure-pip-name` annotation matches the name of the static public IP resource and the `azure-load-balancer-resource-group` annotation matches the resource group that contains it.

```output
Name:                     azure-load-balancer
Namespace:                default
Labels:                   <none>
Annotations:              service.beta.kubernetes.io/azure-load-balancer-resource-group: <node resource group name>
                          service.beta.kubernetes.io/azure-pip-name: myAKSPublicIP
Selector:                 app=azure-load-balancer
Type:                     LoadBalancer
IP:                       10.0.18.125
IP:                       40.121.183.52
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  32582/TCP
Endpoints:                <pod-ip>:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type     Reason                      Age               From                Message
  ----     ------                      ----              ----                -------
  Normal   CreatingLoadBalancer        7s (x2 over 22s)  service-controller  Creating load balancer
  Warning  CreatingLoadBalancerFailed  6s (x2 over 12s)  service-controller  Error creating load balancer (will retry): Failed to create load balancer for service default/azure-load-balancer: user supplied IP Address 40.121.183.52 was not found
```