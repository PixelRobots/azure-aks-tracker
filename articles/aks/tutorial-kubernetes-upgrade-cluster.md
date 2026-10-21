---
layout: Conceptual
title: Kubernetes on Azure tutorial - Upgrade an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-upgrade-cluster
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
description: In this Azure Kubernetes Service (AKS) tutorial, you learn how to upgrade an existing AKS cluster to the latest available Kubernetes version.
ms.topic: tutorial
ms.date: 2026-09-04T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-upgrade
ms.custom: mvc, devx-track-azurepowershell
ai-usage: ai-assisted
zone_pivot_groups: azure-portal-cli-powershell
locale: en-us
document_id: 7f5e2097-66eb-b4d0-48cb-c102c4298585
document_version_independent_id: 880bbe66-a4ed-7d58-aadc-64b12523d290
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/tutorial-kubernetes-upgrade-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/tutorial-kubernetes-upgrade-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/tutorial-kubernetes-upgrade-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: b9a75438-e113-f042-29e2-54c9f8fa54e7
---

# Kubernetes on Azure tutorial - Upgrade an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

As part of the application and cluster lifecycle, you might want to upgrade to the latest available version of Kubernetes. You can upgrade your Azure Kubernetes Service (AKS) cluster using the Azure CLI, Azure PowerShell, or the Azure portal.

In this tutorial, you upgrade an AKS cluster. You learn how to:

- Identify current and available Kubernetes versions.
- Upgrade your Kubernetes nodes.
- Validate a successful upgrade.

## Before you begin

In previous tutorials, you packaged an application into a container image and uploaded the container image to Azure Container Registry (ACR). You also created an AKS cluster and deployed an application to it. If you haven't completed these steps and want to follow along, start with [Tutorial 1 - Prepare application for AKS](tutorial-kubernetes-prepare-app).

::: zone pivot="azure-cli"

If using Azure CLI, this tutorial requires Azure CLI version 2.34.1 or later. Run [`az --version`](/en-us/cli/azure/reference-index#az-version) to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

::: zone-end

::: zone pivot="azure-powershell"

If using Azure PowerShell, this tutorial requires Azure PowerShell version 5.9.0 or later. Run [`Get-InstalledModule -Name Az`](/en-us/powershell/module/powershellget/get-installedmodule) to find the version. If you need to install or upgrade, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps).

::: zone-end

To upgrade an AKS cluster, you need the [Azure Kubernetes Service Contributor role](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-contributor-role) or equivalent permissions.

Before you upgrade, review the [AKS release notes](https://github.com/Azure/AKS/releases) for breaking changes and deprecated APIs. Also validate your workload's Pod Disruption Budgets (PDBs), available compute quota, and subnet IP capacity for surge nodes. For more information, see [Upgrade options and recommendations for AKS clusters](upgrade-options).

::: zone pivot="azure-cli"

## Get available cluster versions using the Azure CLI

Before you upgrade, check which Kubernetes releases are available for your cluster by using the [`az aks get-upgrades`](/en-us/cli/azure/aks#az-aks-get-upgrades) command.

```azurecli
az aks get-upgrades --resource-group myResourceGroup --name myAKSCluster
```

The following example output shows a cluster's current version and lists newer versions under `upgrades`:

```output
  {
    "agentPoolProfiles": null,
    "controlPlaneProfile": {
      "kubernetesVersion": "1.33.7",
      ...
      "upgrades": [
        {
          "isPreview": null,
          "kubernetesVersion": "1.34.10"
        },
        {
          "isPreview": null,
          "kubernetesVersion": "1.34.9"
        }
      ]
    },
    ...
  }
```

::: zone-end

::: zone pivot="azure-powershell"

## Get available cluster versions using Azure PowerShell

1. Before you upgrade, check your cluster's current Kubernetes version and region by using the [`Get-AzAksCluster`](/en-us/powershell/module/az.aks/get-azakscluster) cmdlet.

    ```azurepowershell
    Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster |
      Select-Object -Property Name, CurrentKubernetesVersion, Location
    ```

    The following example output shows the cluster's current version and location:

    ```output
    Name              CurrentKubernetesVersion      Location
    ----              ------------------------      --------
    myAKSCluster      1.33.7                        westus2
    ```
2. List the Kubernetes releases available in the region where your cluster resides by using the [`Get-AzAksVersion`](/en-us/powershell/module/az.aks/get-azaksversion) cmdlet.

    ```azurepowershell
    Get-AzAksVersion -Location westus2 | Where-Object OrchestratorVersion
    ```

    The following example output shows the regional versions under `OrchestratorVersion`:

    ```output
    Default     IsPreview     OrchestratorType     OrchestratorVersion
    -------     ---------     ----------------     -------------------
                              Kubernetes               1.34.10
                              Kubernetes               1.34.9
    True                      Kubernetes               1.33.7
    ...
    ```

    To identify potential upgrade targets, compare versions newer than your cluster's current version with the [Kubernetes version upgrade rules](upgrade-aks-control-plane#kubernetes-version-upgrade-rules). This cmdlet lists regional availability and doesn't validate the upgrade path for a specific cluster.

::: zone-end

::: zone pivot="azure-portal"

## Get available cluster versions by using the Azure portal

1. Sign in to the [Azure portal](https://portal.azure.com).
2. Navigate to your AKS cluster resource.
3. From the service menu, under **Settings**, select **Upgrades**.
4. By **Kubernetes version**, select **Upgrade version**.

    ![Screenshot of the Upgrade version option in the Azure portal.](media/tutorial-kubernetes-upgrade-cluster/upgrade-version.png)
5. On the **Upgrade Kubernetes version** page, select the **Kubernetes Version** dropdown to view available Kubernetes versions for upgrade.

    ![Screenshot of the Upgrade version screen with available upgrade versions.](media/tutorial-kubernetes-upgrade-cluster/available-versions.png)

If no upgrades are available, your cluster might already be on the latest available version or the cluster version might be outside the support window. If the version is unsupported and AKS doesn't offer a recovery upgrade, create a new cluster with a supported Kubernetes version and migrate your workloads. For more information, see [AKS support policies for Kubernetes versions](supported-kubernetes-versions).

::: zone-end

## AKS cluster upgrade process

AKS nodes are carefully cordoned and drained to minimize any potential disruptions to running applications. During this process, AKS performs the following steps:

- Adds a new buffer node (or as many nodes as configured in [max surge](upgrade-aks-cluster#customize-node-surge-upgrade)) to the cluster that runs the specified Kubernetes version.
- [Cordons and drains](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) one of the old nodes to minimize disruption to running applications. If you're using max surge, it [cordons and drains](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) as many nodes at the same time as the number of buffer nodes specified.
- When the old node is fully drained, it's reimaged to receive the new version and becomes the buffer node for the following node to be upgraded.
- This process repeats until all nodes in the cluster have been upgraded.
- At the end of the process, the last buffer node is deleted, maintaining the existing agent node count and zone balance.

Note

If no patch is specified, the cluster automatically upgrades to the specified minor version's latest GA patch. For example, setting `--kubernetes-version` to `1.28` results in the cluster upgrading to `1.28.9`.

For more information, see [Supported Kubernetes minor version upgrades in AKS](supported-kubernetes-versions#alias-minor-version-in-aks).

You can either manually upgrade your cluster or configure automatic cluster upgrades. **Configure automatic cluster upgrades to help keep your cluster on a supported version of Kubernetes**.

::: zone pivot="azure-cli"

## Manually upgrade cluster using the Azure CLI

Upgrade your cluster by using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command. This example upgrades the cluster to version 1.34.10:

```azurecli
az aks upgrade \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --kubernetes-version 1.34.10
```

Note

Supported non-LTS clusters must upgrade sequentially by minor version. For example, to upgrade from *1.33.x* to *1.35.x*, first upgrade to *1.34.x*. An LTS cluster can skip minor versions when moving to a higher LTS version offered by AKS if the upgrade satisfies version-skew requirements and validation checks. For more information, see [Kubernetes version upgrade rules](upgrade-aks-control-plane#kubernetes-version-upgrade-rules).

The following example output shows the result of upgrading. The `kubernetesVersion` value now matches the version specified in the example command:

```output
{
  ...
  "agentPoolProfiles": [
    {
      ...
      "count": 3,
      "currentOrchestratorVersion": "1.34.10",
      "maxPods": 110,
      "name": "nodepool1",
      "nodeImageVersion": "AKSUbuntu-2204gen2containerd-202608.26.0",
      "orchestratorVersion": "1.34.10",
      "osType": "Linux",
      "upgradeSettings": {
        "drainTimeoutInMinutes": null,
        "maxSurge": "10%",
        "nodeSoakDurationInMinutes": null,
        "undrainableNodeBehavior": null
      },
      "vmSize": "Standard_DS2_v2",
      ...
    }
  ],
  ...
  "currentKubernetesVersion": "1.34.10",
  "dnsPrefix": "myAKSClust-myResourceGroup-12ab34",
  "enableRbac": false,
  "fqdn": "myaksclust-myresourcegroup-12ab34-cd56e7fg.hcp.westus2.azmk8s.io",
  "id": "/subscriptions/<Subscription ID>/resourcegroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/myAKSCluster",
  "kubernetesVersion": "1.34.10",
  "location": "westus2",
  "name": "myAKSCluster",
  "type": "Microsoft.ContainerService/ManagedClusters"
  ...
}
```

::: zone-end

::: zone pivot="azure-powershell"

## Manually upgrade cluster using Azure PowerShell

Upgrade your cluster by using the [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) cmdlet. This example upgrades the cluster to version 1.34.10:

```azurepowershell
Set-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -KubernetesVersion 1.34.10
```

Note

Supported non-LTS clusters must upgrade sequentially by minor version. For example, to upgrade from *1.33.x* to *1.35.x*, first upgrade to *1.34.x*. An LTS cluster can skip minor versions when moving to a higher LTS version offered by AKS if the upgrade satisfies version-skew requirements and validation checks. For more information, see [Kubernetes version upgrade rules](upgrade-aks-control-plane#kubernetes-version-upgrade-rules).

The following example output shows the result of upgrading. The `KubernetesVersion` value now matches the version specified in the example cmdlet:

```output
...
ProvisioningState        : Succeeded
MaxAgentPools            : 100
KubernetesVersion        : 1.34.10
CurrentKubernetesVersion : 1.34.10
...
ResourceGroupName        : myResourceGroup
Name                     : myAKSCluster
Type                     : Microsoft.ContainerService/ManagedClusters
Location                 : westus2
Tags                     :
```

::: zone-end

::: zone pivot="azure-portal"

## Manually upgrade cluster using the Azure portal

1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, under **Settings**, select **Upgrades**.
3. By **Kubernetes version**, select **Upgrade version**.

    ![Screenshot of the Upgrade version option in the Azure portal.](media/tutorial-kubernetes-upgrade-cluster/upgrade-version.png)
4. On the **Upgrade Kubernetes version** page, select the **Kubernetes Version** dropdown to view available Kubernetes versions for upgrade.

    ![Screenshot of the Upgrade version screen with available upgrade versions.](media/tutorial-kubernetes-upgrade-cluster/available-versions.png)
5. Select the Kubernetes version you want to upgrade to, and then select **Save**.

Upgrade duration depends on factors such as the number of nodes, surge settings, workload disruption constraints, drain timeout, and node soak duration. The default drain timeout is 30 minutes per node and can be configured from five minutes to 24 hours. Node soak duration can add zero to 30 minutes per node. For more information, see [Customize node pool surge and unavailable settings](upgrade-aks-node-pools-rolling#configure-rolling-upgrade-settings).

::: zone-end

::: zone pivot="azure-cli"

## Configure automatic cluster upgrades using the Azure CLI

::: zone-end

::: zone pivot="azure-powershell"

## Configure automatic cluster upgrades using Azure PowerShell

::: zone-end

::: zone pivot="azure-portal"

## Configure automatic cluster upgrades by using the Azure portal

::: zone-end

AKS Automatic clusters use the `stable` channel, and you don't need to configure a channel. For AKS Standard clusters, select a channel based on your version policy. The `stable` and `rapid` channels advance Kubernetes minor versions and help keep the cluster within the supported version window. The `patch` channel only installs patches for the current minor version and doesn't advance the cluster to a newer minor version.

::: zone pivot="azure-cli"

On an AKS Standard cluster, set the autoupgrade channel by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. The following example uses the `stable` channel:

```azurecli
az aks update --resource-group myResourceGroup --name myAKSCluster --auto-upgrade-channel stable
```

::: zone-end

::: zone pivot="azure-powershell"

On an AKS Standard cluster, set the autoupgrade channel by using the [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) cmdlet. The following example uses the `Stable` channel:

```azurepowershell
Set-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -AutoUpgradeChannel Stable
```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, under **Settings**, select **Upgrades**.
3. By **Kubernetes version**, select **Upgrade version**.

    ![Screenshot of the Upgrade version option in the Azure portal.](media/tutorial-kubernetes-upgrade-cluster/upgrade-version.png)
4. For an AKS Standard cluster, on the **Upgrade Kubernetes version** page, select the **Automatic upgrade** dropdown, select **Enabled with stable**, and then select **Save**.

    ![Screenshot of the Upgrade Kubernetes version page showing the automatic upgrade channel options.](media/tutorial-kubernetes-upgrade-cluster/enable-patch.png)

::: zone-end

For more information, see [Automatically upgrade an Azure Kubernetes Service (AKS) cluster](auto-upgrade-cluster).

## Upgrading node images

AKS regularly provides new node images. Linux node images are updated weekly, and Windows node images are updated monthly. We recommend upgrading your node images frequently to use the latest AKS features and security updates. For more information, see [Upgrade node images in Azure Kubernetes Service (AKS)](node-image-upgrade). To configure automatic node image upgrades, see [Automatically upgrade Azure Kubernetes Service (AKS) cluster node operating system images](auto-upgrade-node-image).

## View upgrade events

Note

When you upgrade your cluster, the following Kubernetes events might occur on the nodes:

- **Surge**: Create a surge node.
- **Drain**: Evict pods from the node. AKS allows 30 minutes to drain a node by default. You can configure the drain timeout from five minutes to 24 hours.
- **Update**: Update of a node has succeeded or failed.
- **Delete**: Delete a surge node.

Use the [`kubectl get`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_get/) command with a field selector to view AKS upgrader events in the default namespace.

```bash
kubectl get events --field-selector source=upgrader
```

The following example output shows some of the preceding events listed during an upgrade:

```output
LAST SEEN   TYPE      REASON    OBJECT                                   MESSAGE
...
5m          Normal    Drain     node/aks-nodepool1-12345678-vmss000000   Draining node: aks-nodepool1-12345678-vmss000000
5m          Normal    Upgrade   node/aks-nodepool1-12345678-vmss000000   Deleting node aks-nodepool1-12345678-vmss000000 from API server
4m          Normal    Upgrade   node/aks-nodepool1-12345678-vmss000000   Successfully reimaged node: aks-nodepool1-12345678-vmss000000
4m          Normal    Upgrade   node/aks-nodepool1-12345678-vmss000000   Successfully upgraded node: aks-nodepool1-12345678-vmss000000
4m          Normal    Drain     node/aks-nodepool1-12345678-vmss000000   Draining node: aks-nodepool1-12345678-vmss000000
...
```

::: zone pivot="azure-cli"

## Validate an upgrade by using the Azure CLI

Confirm the upgrade was successful by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

```azurecli
az aks show --resource-group myResourceGroup --name myAKSCluster --output table
```

The following example output shows that the AKS cluster runs the target Kubernetes version:

```output
Name          Location    ResourceGroup    KubernetesVersion    CurrentKubernetesVersion  ProvisioningState    Fqdn
------------  ----------  ---------------  -------------------  ------------------------  -------------------  ----------------------------------------------------------------
myAKSCluster  westus2      myResourceGroup  1.34.10              1.34.10                   Succeeded            myaksclust-myresourcegroup-12ab34-cd56e7fg.hcp.westus2.azmk8s.io
```

::: zone-end

::: zone pivot="azure-powershell"

## Validate an upgrade by using Azure PowerShell

Confirm the upgrade was successful by using the [`Get-AzAksCluster`](/en-us/powershell/module/az.aks/get-azakscluster) cmdlet.

```azurepowershell
Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster |
  Select-Object -Property Name, Location, KubernetesVersion, ProvisioningState
```

The following example output shows that the AKS cluster runs the target Kubernetes version:

```output
Name             Location     KubernetesVersion     ProvisioningState
----             --------     -----------------     -----------------
myAKSCluster     westus2       1.34.10               Succeeded
```

::: zone-end

::: zone pivot="azure-portal"

## Validate an upgrade using the Azure portal

1. In the Azure portal, navigate to your AKS cluster resource.
2. On the **Overview** page, under **Essentials**, check the **Kubernetes version** to confirm the upgrade was successful.

::: zone-end

::: zone pivot="azure-cli"

## Delete the cluster using the Azure CLI

::: zone-end

::: zone pivot="azure-powershell"

## Delete the cluster using Azure PowerShell

::: zone-end

::: zone pivot="azure-portal"

## Delete the cluster by using the Azure portal

::: zone-end

As this tutorial is the last part of the series, you might want to delete your AKS cluster to avoid incurring Azure charges.

::: zone pivot="azure-cli"

Remove the resource group, container service, and all related resources by using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

```azurecli
az group delete --name myResourceGroup --yes --no-wait
```

::: zone-end

::: zone pivot="azure-powershell"

Remove the resource group, container service, and all related resources by using the [`Remove-AzResourceGroup`](/en-us/powershell/module/az.resources/remove-azresourcegroup) cmdlet.

```azurepowershell
Remove-AzResourceGroup -Name myResourceGroup
```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your AKS cluster resource.
2. On the **Overview** page, select **Delete**.
3. On the **Delete cluster confirmation** page, select **Delete**.

::: zone-end

Note

When you delete the cluster, the Microsoft Entra service principal used by the AKS cluster isn't removed. For steps on how to remove the service principal, see [AKS service principal considerations and deletion](kubernetes-service-principal#considerations-when-using-a-service-principal). If you used a managed identity, the identity is managed by the platform and doesn't require that you provision or rotate any secrets.