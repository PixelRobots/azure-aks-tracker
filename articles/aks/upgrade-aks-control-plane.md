---
layout: Conceptual
title: Upgrade the Azure Kubernetes Service (AKS) Cluster Control Plane - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-control-plane
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
description: Learn how to upgrade the control plane of an Azure Kubernetes Service (AKS) cluster to get the latest Kubernetes version features and security updates.
ms.topic: how-to
ms.subservice: aks-upgrade
ms.date: 2026-07-30T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: ce9b139b-df27-2ce3-ccf0-c95ad77477b1
document_version_independent_id: b14d93ea-41bb-04bb-96a8-967c112da6f9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-aks-control-plane.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/upgrade-aks-control-plane
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-aks-control-plane.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 7b74e94b-0a22-2680-171d-0993effe4fdc
---

# Upgrade the Azure Kubernetes Service (AKS) Cluster Control Plane - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) clusters consist of two main components: the **control plane managed by Azure** and the **node pools where your workloads run**. This article focuses on upgrading the control plane independently, which allows you to adopt new Kubernetes versions for API server features while separately managing node pool upgrades.

## Before you begin

- If you're using the Azure CLI, this article requires Azure CLI version 2.34.1 or later. Use the `az --version` command to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- If you're using Azure PowerShell, this article requires Azure PowerShell version 5.9.0 or later. Use the `Get-InstalledModule -Name Az` cmdlet to find the version. If you need to install or upgrade, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps).
- To perform upgrade operations, you need the [Azure Kubernetes Service Contributor Role](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-contributor-role) or equivalent permissions.
- Beta APIs are disabled by default when you upgrade to Kubernetes version 1.30 and 1.27 LTS versions.

Warning

Ensure you have sufficient compute quota before upgrading. If quota is low, the upgrade might fail. For more information, see [increase quotas](/en-us/azure/azure-portal/supportability/regional-quota-requests).

## Overview of AKS upgrade types

The following table outlines three types of AKS upgrades, highlighting their scope and use cases:

| Upgrade type | Scope | Use case |
| --- | --- | --- |
| Control plane only | API server, etcd, controller manager, scheduler | Test new Kubernetes APIs before upgrading workloads |
| Full cluster | Control plane and all node pools | Standard upgrade to keep cluster up to date |
| [Node pool only](upgrade-aks-node-pools-rolling) | Specific node pools | Staged rollout after control plane upgrade |

Tip

Upgrading the control plane first allows you to validate Kubernetes API compatibility before affecting running workloads. For node pool upgrade strategies, see [Configure rolling upgrades](upgrade-aks-node-pools-rolling).

## Kubernetes version upgrade rules

When you upgrade a supported non-LTS AKS cluster, you can't skip Kubernetes minor versions. You must perform all upgrades sequentially by minor version number. For example, upgrades between *1.28.x* -&gt; *1.29.x* or *1.29.x* -&gt; *1.30.x* are allowed. *1.28.x* -&gt; *1.30.x* isn't allowed.

An LTS cluster can skip minor versions when moving to a higher LTS version offered by AKS, provided the upgrade satisfies version-skew requirements and validation checks. For more information, see [Can I skip multiple AKS versions during a cluster upgrade?](/en-us/azure/aks/supported-kubernetes-versions#can-i-skip-multiple-aks-versions-during-a-cluster-upgrade).

Starting with Kubernetes 1.28, the control plane can be up to three minor versions ahead of node pools. For example, if your control plane is at *1.35.x*, your node pools can be at *1.32.x*, *1.33.x*, *1.34.x*, or *1.35.x*. For current constraints, see the [AKS version skew policy](/en-us/azure/aks/supported-kubernetes-versions#what-is-the-allowed-difference-in-versions-between-the-control-plane-and-node-pools).

## Check for available AKS upgrades

Tip

To stay up to date with the latest AKS releases and updates, see the [AKS release tracker](release-tracker).

# [Azure CLI](#tab/azure-cli)
Check for available Kubernetes releases for your AKS cluster using the [`az aks get-upgrades`](/en-us/cli/azure/aks#az-aks-get-upgrades) command.

```azurecli
az aks get-upgrades --resource-group <resource-group-name> --name <cluster-name> --output table
```

The following example output shows the current version as *1.28.9* and lists the available versions under `upgrades`:

```output
Name     ResourceGroup          MasterVersion    Upgrades
-------  ---------------        ---------------  --------------
default  <resource-group-name>  1.28.9           1.29.2, 1.29.4
```

# [Azure PowerShell](#tab/azure-powershell)
List the Kubernetes versions available in your region using the [`Get-AzAksVersion`](/en-us/powershell/module/az.aks/get-azaksversion) cmdlet.

```azurepowershell
Get-AzAksVersion -Location <your-region> | Where-Object { $_.OrchestratorVersion }
```

The output lists the Kubernetes versions available in the specified region under `OrchestratorVersion`. To identify potential upgrade targets, compare versions newer than your cluster's current version with the Kubernetes version upgrade rules, because the cmdlet doesn't validate the upgrade path for a specific cluster.

# [Azure portal](#tab/azure-portal)
1. Sign in to the [Azure portal](https://portal.azure.com) and navigate to your AKS cluster resource.
2. Under **Settings**, select **Upgrades**.
3. For **Kubernetes version**, select **Upgrade version** to see available upgrades.

The Azure portal highlights deprecated APIs between your current version and available target versions.

---

## Upgrade the AKS control plane only

Important

You can't perform a control-plane-only upgrade when [cluster autoupgrade](auto-upgrade-cluster#control-plane-upgrade-constraints) is enabled. Cluster autoupgrade always upgrades the control plane and all node pools together.

# [Azure CLI](#tab/azure-cli)
1. Upgrade the control plane using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command with the `--control-plane-only` flag. The following example upgrades the control plane to Kubernetes version *1.29.4*:

    ```azurecli
    az aks upgrade \
        --resource-group <resource-group-name> \
        --name <cluster-name> \
        --kubernetes-version 1.29.4 \
        --control-plane-only
    ```
2. Confirm the control plane upgrade was successful using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show --resource-group <resource-group-name> --name <cluster-name> --output table
    ```

    The following example output shows the control plane now runs *1.29.4*:

    ```output
    Name            Location    ResourceGroup          KubernetesVersion    ProvisioningState    Fqdn
    ------------    ----------  ---------------        -------------------  -------------------  ------------------------------------------------
    <cluster-name>  eastus      <resource-group-name>  1.29.4               Succeeded            <cluster-name>-dns-123abcd4.hcp.eastus.azmk8s.io
    ```
3. Verify the node pool versions remain unchanged using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command.

    ```azurecli
    az aks nodepool list --resource-group <resource-group-name> --cluster-name <cluster-name> --query "[].{Name:name,Version:orchestratorVersion}" --output table
    ```

    In the output, the node pools should still show the previous Kubernetes version.

# [Azure PowerShell](#tab/azure-powershell)
1. Upgrade the control plane using the [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) cmdlet with the `-ControlPlaneOnly` parameter. The following example upgrades the control plane to Kubernetes version *1.29.4*:

    ```azurepowershell
    Set-AzAksCluster -ResourceGroupName <resource-group-name> -Name <cluster-name> -KubernetesVersion 1.29.4 -ControlPlaneOnly
    ```
2. Confirm the upgrade was successful using the [`Get-AzAksCluster`](/en-us/powershell/module/az.aks/get-azakscluster) cmdlet.

    ```azurepowershell
    Get-AzAksCluster -ResourceGroupName <resource-group-name> -Name <cluster-name> |
     Format-Table -Property Name, Location, KubernetesVersion, ProvisioningState
    ```

# [Azure portal](#tab/azure-portal)
1. Sign in to the [Azure portal](https://portal.azure.com) and navigate to your AKS cluster resource.
2. Under **Settings**, select **Upgrades**.
3. Select **Upgrade version** &gt; **Control plane only**.
4. Select the desired Kubernetes version &gt; **Save**.

---

## Upgrade the full AKS cluster

Note

During a full cluster upgrade, AKS upgrades the control plane first, then upgrades each node pool sequentially. For more control over node pool upgrades, see [Configure rolling upgrades](upgrade-aks-node-pools-rolling).

# [Azure CLI](#tab/azure-cli)
Upgrade the full cluster (control plane and all node pools) using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command. The following example upgrades the cluster to Kubernetes version *1.29.4*:

```azurecli
az aks upgrade \
    --resource-group <resource-group-name> \
    --name <cluster-name> \
    --kubernetes-version 1.29.4
```

# [Azure PowerShell](#tab/azure-powershell)
Upgrade the full cluster (control plane and all node pools) using the [`Set-AzAksCluster`](/en-us/powershell/module/az.aks/set-azakscluster) cmdlet. The following example upgrades the cluster to Kubernetes version *1.29.4*:

```azurepowershell
Set-AzAksCluster -ResourceGroupName <resource-group-name> -Name <cluster-name> -KubernetesVersion 1.29.4
```

# [Azure portal](#tab/azure-portal)
1. Sign in to the [Azure portal](https://portal.azure.com) and navigate to your AKS cluster resource.
2. Under **Settings**, select **Upgrades**.
3. Select **Upgrade version** &gt; **Control plane and all node pools**.
4. Select the desired Kubernetes version &gt; **Save**.

---

## AKS control plane upgrade frequently asked questions (FAQ)

### Does a control-plane-only upgrade also upgrade node pools?

No. A control-plane-only upgrade doesn't change node pools. [Cluster autoupgrade](auto-upgrade-cluster#control-plane-upgrade-constraints) works differently: it doesn't support control-plane-only upgrades and upgrades the control plane and all node pools together.

### Can I upgrade node pools before the control plane?

No. The control plane version must always be equal to or greater than any node pool version. You must upgrade the control plane first.

### How long does a control plane upgrade take?

Upgrade duration varies based on the cluster state and Azure conditions. Monitor `provisioningState` using [`az aks show`](/en-us/cli/azure/aks#az-aks-show) or [`Get-AzAksCluster`](/en-us/powershell/module/az.aks/get-azakscluster). The upgrade is complete when the provisioning state is `Succeeded`.

## Resolve control plane upgrade issues

### No upgrades available

For an unsupported cluster, use `az aks get-upgrades` to check whether AKS offers an eligible supported target. If a target is available, perform a full-cluster upgrade. Control-plane-only upgrades aren't supported for this recovery path.

If no target is available, your cluster might already be on the latest supported version. If the cluster is running an unsupported version, create a new cluster with a supported version and migrate your workloads.

### Upgrade failed due to deprecated APIs

Before upgrading, check for deprecated APIs using tools like [kube-no-trouble (kubent)](https://github.com/doitintl/kube-no-trouble):

```bash
kubent
```

The command scans resources accessible through the current kubeconfig context for deprecated Kubernetes API versions. The output groups findings by Kubernetes version and identifies each affected resource by `KIND`, `NAMESPACE`, `NAME`, and `API_VERSION`. Update the source manifest for every listed resource to use a supported API version before upgrading.