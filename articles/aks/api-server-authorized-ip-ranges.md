---
layout: Conceptual
title: API Server Authorized IP Ranges in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges
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
description: Learn how to secure access to the API server in Azure Kubernetes Service (AKS) using authorized IP address ranges to limit access to specific IP addresses and CIDRs.
ms.topic: how-to
ms.custom: devx-track-azurecli, devx-track-azurepowershell, copilot-scenario-highlight
ms.date: 2026-08-03T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ms.subservice: aks-security
zone_pivot_groups: api-server-authorized-ip-ranges
locale: en-us
document_id: 2c779000-968d-e1c6-f402-5b367a9b09ab
document_version_independent_id: b3124556-4672-d2aa-aab1-64d2cd3ac354
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/api-server-authorized-ip-ranges.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/api-server-authorized-ip-ranges
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/api-server-authorized-ip-ranges.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 3d064f14-73fe-30db-0f94-839851ea794d
---

# API Server Authorized IP Ranges in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to use API server authorized IP address ranges to limit which IP addresses and CIDRs can access control plane endpoints for your Azure Kubernetes Service (AKS) workloads.

## Prerequisites

- Azure CLI version 2.0.76 or later. To check your version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The latest version of Azure PowerShell. For installation instructions, see [Install Azure PowerShell](/en-us/powershell/azure/install-azure-powershell).
- To learn what IP addresses to include when integrating your AKS cluster with Azure DevOps, see [Allowed IP addresses and domain URLs](/en-us/azure/devops/organizations/security/allow-list-ip-url).

Tip

In the Azure portal, use Azure Copilot to change the IP addresses that can access your cluster. For more information, see [Work with AKS clusters efficiently using Azure Copilot](/en-us/azure/copilot/work-aks-clusters#enable-ip-address-authorization).

## Limitations and considerations

- AKS supports this feature only with the Standard SKU load balancer. AKS no longer supports the Basic SKU load balancer. If you have an existing cluster that uses the Basic SKU, [migrate to the Standard SKU](upgrade-basic-load-balancer-on-aks). The migration requires downtime and has additional prerequisites.
- You can't use this feature with [private clusters](private-clusters).
- For clusters that use [Node public IPs](use-node-public-ips), each node pool with public IPs must use public IP prefixes. Add those prefixes as authorized ranges. You can't use an IPv6-only node public IP prefix, because Azure assigns the node's IPv4 address automatically and you can't add it as an authorized range.
- You can specify up to 200 authorized IP ranges. To go beyond this limit, consider using [API Server VNet Integration](api-server-vnet-integration), which supports up to 2,000 authorized IP ranges.

## Overview of API server authorized IP ranges

The Kubernetes API server exposes the underlying Kubernetes APIs. Management tools such as `kubectl` and the Kubernetes dashboard interact with the cluster through this API server. AKS provides a single-tenant control plane with a dedicated API server and assigns the server a public IP address by default. You can control access by using Kubernetes role-based access control (Kubernetes RBAC) or Azure RBAC.

To secure the otherwise publicly accessible AKS control plane API server, enable authorized IP ranges. Authorized IP ranges allow only defined IP address ranges to communicate with the API server. The API server blocks requests from IP addresses that aren't included in the authorized ranges. The rules can take up to two minutes to propagate. Wait up to two minutes before testing the connection.

## Recommended IP ranges to allow

We recommend including the following IP address ranges in your API server authorized IP ranges configuration:

- The cluster egress IP address (firewall, NAT gateway, or other address, depending on your [outbound type](egress-outboundtype)).
- The IP address ranges for networks that you use to administer the cluster.

## Create an AKS cluster with API server authorized IP ranges enabled

Note

When you enable API server authorized IP ranges during cluster creation, AKS adds the API server public IP and the outbound public IP of the [Standard SKU load balancer](load-balancer-standard) to the list of authorized IP ranges by default, in addition to any ranges you specify.

**Special case - `0.0.0.0/32`**: The `0.0.0.0/32` placeholder tells AKS to allow only the outbound public IP of the Standard SKU load balancer to access the API server. The placeholder has the following behaviors:

| Behavior | Description |
| --- | --- |
| Extra client IP ranges | Disables the default behavior of allowing extra client IP ranges. |
| API server access | Restricts API server access to only the cluster's own outbound IP. |
| Self-management | Lets the cluster self-manage while blocking external access. |

To create a cluster with API server authorized IP ranges enabled, provide a list of authorized public IP address ranges. For a CIDR range, use the network address, which is the first IP address in the range. For example, to allow the range `137.117.106.88` to `137.117.106.95`, specify `137.117.106.88/29`.

::: zone pivot="azure-cli"

Use the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--api-server-authorized-ip-ranges` parameter to create an AKS cluster with API server authorized IP ranges enabled. The following example creates a cluster named *myAKSCluster* in the resource group named *myResourceGroup* and allows the IP address range `73.140.245.0/24` to access the API server:

```azurecli
az aks create --resource-group myResourceGroup --name myAKSCluster --vm-set-type VirtualMachineScaleSets --load-balancer-sku standard --api-server-authorized-ip-ranges 73.140.245.0/24 --generate-ssh-keys
```

::: zone-end

::: zone pivot="azure-powershell"

Use the [`New-AzAksCluster`](/en-us/powershell/module/az.aks/new-azakscluster) cmdlet with the `-ApiServerAccessAuthorizedIpRange` parameter to create an AKS cluster with API server authorized IP ranges enabled. The following example creates a cluster named *myAKSCluster* in the resource group named *myResourceGroup* and allows the IP address range `73.140.245.0/24` to access the API server:

```azurepowershell
New-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -NodeVmSetType VirtualMachineScaleSets -LoadBalancerSku Standard -ApiServerAccessAuthorizedIpRange '73.140.245.0/24' -GenerateSshKey
```

::: zone-end

::: zone pivot="azure-portal"

1. From the [Azure portal home page](https://portal.azure.com/#home), select **Create a resource** &gt; **Containers** &gt; **Azure Kubernetes Service (AKS)**.
2. Configure the cluster settings as needed.
3. In the **Networking** section under **Public access**, select **Set authorized IP ranges**.
4. For **Specify IP ranges**, enter the IP address ranges you want to authorize to access the API server.
5. Configure the rest of the cluster settings as needed.
6. When you're ready, select **Review + create** &gt; **Create** to create the cluster.

::: zone-end

::: zone pivot="azure-cli"

## Specify outbound IPs for a Standard SKU load balancer using Azure CLI

When you create a cluster with API server authorized IP ranges enabled, you can also specify its outbound IP addresses or prefixes by using the `--load-balancer-outbound-ips` or `--load-balancer-outbound-ip-prefixes` parameters. AKS allows these IP addresses in addition to the IP addresses in the `--api-server-authorized-ip-ranges` parameter.

Use the `--load-balancer-outbound-ips` parameter to create an AKS cluster with API server authorized IP ranges enabled and specify the outbound IP addresses for the Standard SKU load balancer. The following example creates a cluster named *myAKSCluster* in the resource group named *myResourceGroup*, allows `73.140.245.0/24` to access the API server, and specifies two outbound IP addresses for the Standard SKU load balancer. Replace `<public-ip-id-1>` and `<public-ip-id-2>` with the resource IDs of your public IP addresses.

```azurecli
az aks create --resource-group myResourceGroup --name myAKSCluster --vm-set-type VirtualMachineScaleSets --load-balancer-sku standard --api-server-authorized-ip-ranges 73.140.245.0/24 --load-balancer-outbound-ips <public-ip-id-1>,<public-ip-id-2> --generate-ssh-keys
```

::: zone-end

## Allow only the outbound public IP of the Standard SKU load balancer

::: zone pivot="azure-cli"

Use the `--api-server-authorized-ip-ranges` parameter to create an AKS cluster that allows only the outbound public IP of the Standard SKU load balancer to access the API server. The following example creates a cluster named *myAKSCluster* in the resource group named *myResourceGroup*:

```azurecli
az aks create --resource-group myResourceGroup --name myAKSCluster --vm-set-type VirtualMachineScaleSets --load-balancer-sku standard --api-server-authorized-ip-ranges 0.0.0.0/32 --generate-ssh-keys
```

::: zone-end

::: zone pivot="azure-powershell"

Use the `-ApiServerAccessAuthorizedIpRange` parameter to create an AKS cluster that allows only the outbound public IP of the Standard SKU load balancer to access the API server. The following example creates a cluster named *myAKSCluster* in the resource group named *myResourceGroup*:

```azurepowershell
New-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -NodeVmSetType VirtualMachineScaleSets -LoadBalancerSku Standard -ApiServerAccessAuthorizedIpRange '0.0.0.0/32' -GenerateSshKey
```

::: zone-end

::: zone pivot="azure-portal"

1. From the [Azure portal home page](https://portal.azure.com/#home), select **Create a resource** &gt; **Containers** &gt; **Azure Kubernetes Service (AKS)**.
2. Configure the cluster settings as needed.
3. In the **Networking** section under **Public access**, select **Set authorized IP ranges**.
4. For **Specify IP ranges**, enter `0.0.0.0/32`. This setting allows only the outbound public IP of the Standard SKU load balancer.
5. Configure the rest of the cluster settings as needed.
6. When you're ready, select **Review + create** &gt; **Create** to create the cluster.

::: zone-end

## Update the API server authorized IP ranges on an existing cluster

::: zone pivot="azure-cli"

Use the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--api-server-authorized-ip-ranges` parameter to update a cluster's API server authorized IP ranges. The following example sets the authorized range to `73.140.245.0/24` for the cluster named *myAKSCluster* in the resource group named *myResourceGroup*:

```azurecli
az aks update --resource-group myResourceGroup --name myAKSCluster --api-server-authorized-ip-ranges 73.140.245.0/24
```

## Allow multiple IP address ranges using Azure CLI

To allow multiple IP address ranges, separate them with commas.

Use the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--api-server-authorized-ip-ranges` parameter to authorize multiple IP address ranges. The following example updates the cluster named *myAKSCluster* in the resource group named *myResourceGroup*:

```azurecli
az aks update --resource-group myResourceGroup --name myAKSCluster --api-server-authorized-ip-ranges 73.140.245.0/24,193.168.1.0/24,194.168.1.0/24
```

::: zone-end

::: zone pivot="azure-powershell"

Use the [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) cmdlet with the `-ApiServerAccessAuthorizedIpRange` parameter to update a cluster's API server authorized IP ranges. The following example sets the authorized range to `73.140.245.0/24` for the cluster named *myAKSCluster* in the resource group named *myResourceGroup*:

```azurepowershell
Set-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -ApiServerAccessAuthorizedIpRange '73.140.245.0/24'
```

::: zone-end

::: zone pivot="azure-portal"

1. Navigate to the Azure portal and select the AKS cluster you want to update.
2. From the service menu, under **Settings**, select **Networking**.
3. Under **Resource settings**, select **Manage**.
4. On the **Authorized IP ranges** page, update the **Authorized IP ranges** as needed.
5. When you're done, select **Save**.

::: zone-end

## Disable API server authorized IP ranges on an existing cluster

::: zone pivot="azure-cli"

To disable API server authorized IP ranges, use the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command and specify an empty range `""` for the `--api-server-authorized-ip-ranges` parameter.

```azurecli
az aks update --resource-group myResourceGroup --name myAKSCluster --api-server-authorized-ip-ranges ""
```

::: zone-end

::: zone pivot="azure-powershell"

To disable API server authorized IP ranges, use the [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) cmdlet and specify an empty range `''` for the `-ApiServerAccessAuthorizedIpRange` parameter.

```azurepowershell
Set-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -ApiServerAccessAuthorizedIpRange ''
```

::: zone-end

::: zone pivot="azure-portal"

1. Navigate to the Azure portal and select the AKS cluster you want to update.
2. From the service menu, under **Settings**, select **Networking**.
3. Under **Resource settings**, select **Manage**.
4. On the **Authorized IP ranges** page, deselect the **Set authorized IP ranges** checkbox.
5. Select **Save**.

::: zone-end

## Find existing API server authorized IP ranges

::: zone pivot="azure-cli"

To find existing API server authorized IP ranges, use the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command with the `--query` parameter set to `apiServerAccessProfile.authorizedIpRanges`.

```azurecli
az aks show --resource-group myResourceGroup --name myAKSCluster --query apiServerAccessProfile.authorizedIpRanges
```

Example output:

```output
[
    "73.140.245.0/24"
]
```

::: zone-end

::: zone pivot="azure-powershell"

To find existing API server authorized IP ranges, use the [`Get-AzAksCluster`](/en-us/powershell/module/az.aks/get-azakscluster) cmdlet.

```azurepowershell
Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster | Select-Object -ExpandProperty ApiServerAccessProfile
```

Example output:

```output
AuthorizedIPRanges: {73.140.245.0/24}
...
```

::: zone-end

::: zone pivot="azure-portal"

1. Navigate to the Azure portal and select your AKS cluster.
2. From the service menu, under **Settings**, select **Networking**.

    The **Resource settings** section on the **Networking** page displays the currently configured authorized IP ranges.

    ![Screenshot showing authorized IP ranges under Resource settings in the Azure portal.](media/api-server-authorized-ip-ranges/azure-portal-existing-ranges.png)

::: zone-end

## Access the API server from your development machine, tooling, or automation

To access the API server from a development machine, tool, or automation system, add its public IP address to the cluster's authorized IP ranges.

Alternatively, configure a jumpbox with the necessary tooling in a separate subnet in the firewall's virtual network, and add the firewall IP addresses to the authorized ranges. If the AKS cluster subnet uses forced tunneling through the firewall, you can instead place that jumpbox in the AKS cluster subnet.

Note

The following example preserves the existing authorized range and adds another IP address. If you omit an existing IP address, the command replaces it with the new range.

::: zone pivot="azure-cli"

1. Run the following command to retrieve your IP address and set it as an environment variable:

    ```bash
    # Retrieve your IP address
    CURRENT_IP=$(dig +short "myip.opendns.com" "@resolver1.opendns.com")
    ```
2. Use the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--api-server-authorized-ip-ranges` parameter to add your IP address to the authorized ranges. The following example adds your current IP address to the existing ranges on the cluster named *myAKSCluster* in the resource group named *myResourceGroup*:

    ```azurecli
    az aks update --resource-group myResourceGroup --name myAKSCluster --api-server-authorized-ip-ranges $CURRENT_IP/32,73.140.245.0/24
    ```

::: zone-end

::: zone pivot="azure-powershell"

1. Run the following command to retrieve your IP address and set it as an environment variable:

    ```azurepowershell
    # Retrieve your IP address
    $CURRENT_IP = (Invoke-RestMethod -Uri 'https://ipinfo.io/json').ip
    ```
2. Use the [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) cmdlet with the `-ApiServerAccessAuthorizedIpRange` parameter to add your IP address to the authorized ranges. The following example adds your current IP address to the existing ranges on the cluster named *myAKSCluster* in the resource group named *myResourceGroup*:

    ```azurepowershell
    Set-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -ApiServerAccessAuthorizedIpRange "$CURRENT_IP/32", '73.140.245.0/24'
    ```

::: zone-end

For another way to identify your IP address, see [Find your IP address](https://support.microsoft.com/help/4026518/windows-10-find-your-ip-address) or search for *what is my IP address?* in a web browser.