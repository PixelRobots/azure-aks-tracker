---
layout: Conceptual
title: Azure Kubernetes Service (AKS) cost analysis - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/cost-analysis
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
description: Learn how to use cost analysis to surface granular cost allocation data for your Azure Kubernetes Service (AKS) cluster.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-monitoring
ms.topic: how-to
ms.custom: quarterly
ms.date: 2026-07-29T00:00:00.0000000Z
locale: en-us
document_id: 5430b7ac-e79d-6270-ff11-5815460ec016
document_version_independent_id: 51555159-2b0c-85a4-9524-090f4f4553cd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/cost-analysis.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/cost-analysis
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/cost-analysis.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: af3b4b37-7d4b-f678-16f0-89c3b38d2f6e
---

# Azure Kubernetes Service (AKS) cost analysis - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to enable cost analysis on Azure Kubernetes Service (AKS) to view detailed cost data for cluster resources.

## AKS cost analysis overview

AKS clusters rely on Azure resources, such as virtual machines (VMs), virtual disks, load balancers, and public IP addresses. Multiple applications can use these resources. The resource consumption patterns often differ for each application, so their contribution toward the total cluster resource cost might also vary. Some applications might have footprints across multiple clusters, which can pose a challenge when performing cost attribution and cost management.

When you enable cost analysis on your AKS cluster, you can view detailed cost allocation scoped to Kubernetes constructs, such as clusters and namespaces, and Azure Compute, Network, and Storage resources. The add-on is built on top of [OpenCost](https://www.opencost.io/), an open-source Cloud Native Computing Foundation Incubating project for usage data collection. Usage data is reconciled with your Azure invoice data to provide a comprehensive view of your AKS cluster costs directly in the Azure portal.

For more information on Microsoft Cost Management, see [Start analyzing costs in Azure](/en-us/azure/cost-management-billing/costs/quick-acm-cost-analysis).

After enabling the cost analysis add-on and allowing up to 24 hours for data to be collected, you can use the information in [Understand AKS usage and costs](understand-aks-costs) to help you understand your data.

## Prerequisites

- Your cluster must use the `Standard` or `Premium` tier, not the `Free` tier.
- To view cost analysis information, you must have one of the following roles on the subscription hosting the cluster: `Owner`, `Contributor`, `Reader`, `Cost Management Contributor`, or `Cost Management Reader`.
- [Managed identity](use-managed-identity) configured on your cluster.
- The [Azure Disk Container Storage Interface (CSI) driver](csi-storage-drivers) enabled on your cluster.
- If using the Azure CLI, you need version `2.61.0` or later installed.
- Once you enable cost analysis, you can't downgrade your cluster to the `Free` tier without first disabling cost analysis.
- Access to the Azure API including Azure Resource Manager (ARM) API. For a list of fully qualified domain names (FQDNs) required, see [AKS Cost Analysis required FQDN](outbound-rules-control-egress#aks-cost-analysis-add-on).

## Limitations

- Kubernetes cost views are only available for the *Enterprise Agreement* and *Microsoft Customer Agreement* Microsoft Azure offer types. For more information, see [Supported Microsoft Azure offers](/en-us/azure/cost-management-billing/costs/understand-cost-mgt-data#supported-microsoft-azure-offers).
- Currently, virtual nodes aren't supported.
- The add-on isn't available in the `usnateast`, `usnatwest`, `usseceast`, or `ussecwest` regions. For more information, see [AKS cost analysis add-on issues and troubleshooting](/en-us/troubleshoot/azure/azure-kubernetes/aks-cost-analysis-add-on-issues#cause-3-the-add-on-is-unavailable-in-your-region).
- The AKS cost analysis add-on supports about 7,000 containers per cluster, based on the current 4-GB memory limit and subject to change.

## Enable cost analysis on your AKS cluster

You can enable the cost analysis with the `--enable-cost-analysis` flag during one of the following operations:

- Creating a `Standard` or `Premium` tier AKS cluster.
- Updating an existing `Standard` or `Premium` tier AKS cluster.
- Upgrading a `Free` cluster to `Standard` or `Premium`.
- Upgrading a `Standard` cluster to `Premium`.
- Downgrading a `Premium` cluster to `Standard` tier.

### Enable cost analysis on a new cluster

Enable cost analysis on a new cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-cost-analysis` flag. The following example creates a new AKS cluster in the `Standard` tier with cost analysis enabled:

```text
export RANDOM_SUFFIX=$(openssl rand -hex 3)
export RESOURCE_GROUP="AKSCostRG$RANDOM_SUFFIX"
export CLUSTER_NAME="AKSCostCluster$RANDOM_SUFFIX"
export LOCATION="WestUS2"
az group create --resource-group $RESOURCE_GROUP --location $LOCATION
az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --location $LOCATION --enable-managed-identity --generate-ssh-keys --tier standard --enable-cost-analysis
```

Results:

```JSON
{
    "id": "/subscriptions/xxxxx/resourceGroups/AKSCostRGxxxx/providers/Microsoft.ContainerService/managedClusters/AKSCostClusterxxxx",
    "location": "WestUS2",
    "name": "AKSCostClusterxxxx",
    "properties": {
        "provisioningState": "Succeeded"
    },
    "tags": null,
    "type": "Microsoft.ContainerService/managedClusters"
}
```

### Enable cost analysis on an existing cluster

Enable cost analysis on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-cost-analysis` flag. The following example updates an existing AKS cluster in the `Standard` tier to enable cost analysis. Replace `$RESOURCE_GROUP` and `$CLUSTER_NAME` with your resource group and cluster names, or set them as environment variables.

```azurecli
az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --enable-cost-analysis
```

Results:

```JSON
{
    "id": "/subscriptions/xxxxx/resourceGroups/AKSCostRGxxxx/providers/Microsoft.ContainerService/managedClusters/AKSCostClusterxxxx",
    "name": "AKSCostClusterxxxx",
    "properties": {
        "provisioningState": "Succeeded"
    }
}
```

Note

An agent is deployed to the cluster when you enable the add-on. The agent consumes a small amount of CPU and Memory resources.

Warning

The AKS cost analysis add-on Memory usage is dependent on the number of containers deployed. You can roughly approximate Memory consumption using *200 MB + 0.5 MB per container*. The current Memory limit is set to *4 GB*, which supports approximately *7,000 containers per cluster*. These estimates are subject to change.

Note

Enabling the cost analysis also creates a [managed identity](/en-us/entra/identity/managed-identities-azure-resources/overview) named `cost-analysis-identity` with read access to the cluster's node resource group, and assigns it to the node pools in the cluster. This is used to collect the ARM identifiers of cluster assets for reporting.

Since the node pool already has a managed identity, any commands on the node that use managed identities need to [specify the identity to use](/en-us/entra/identity/managed-identities-azure-resources/managed-identities-faq#what-identity-will-imds-default-to-if-i-dont-specify-the-identity-in-the-request) instead of relying on the node pool's managed identity.

For example, `az login --identity --resource-id <resource ID of identity>`.

## Disable cost analysis on your AKS cluster

Disable cost analysis using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-cost-analysis` flag.

```text
az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --disable-cost-analysis
```

Results:

```JSON
{
    "id": "/subscriptions/xxxxx/resourceGroups/AKSCostRGxxxx/providers/Microsoft.ContainerService/managedClusters/AKSCostClusterxxxx",
    "name": "AKSCostClusterxxxx",
    "properties": {
        "provisioningState": "Succeeded"
    }
}
```

Note

If you want to downgrade your cluster from the `Standard` or `Premium` tier to the `Free` tier while cost analysis is enabled, you must first disable cost analysis.

## View the cost data

You can view cost allocation data in the Azure portal.

In the Azure portal, go to the Azure subscription that hosts your AKS cluster. Under Cost Management, select **Cost analysis**. In the **View** list, select the list drop-down item and then select **Kubernetes clusters**.

For more information, see [View AKS costs in Microsoft Cost Management](/en-us/azure/cost-management-billing/costs/view-kubernetes-costs).

### Cost definitions

In the Kubernetes namespaces and assets views, you might see any of the following charges:

| Charge type | Description |
| --- | --- |
| Idle charges | The cost of available resource capacity that isn't used by any workloads. |
| Service charges | The charges associated with the service, like Uptime SLA, Microsoft Defender for Containers, etc. |
| System charges | The cost of capacity reserved by AKS on each node to run system processes required by the cluster, including the kubelet and container runtime. [Learn more](node-resource-reservations#resource-reservations). |
| Unallocated charges | The cost of resources that couldn't be allocated to namespaces. |

Note

Typically, the system finalizes and makes cost and usage data available within 8 to 24 hours.

## Troubleshooting

If you're experiencing issues, such as the `cost-agent` pod getting `OOMKilled` or stuck in a `Pending` state, see [Troubleshoot AKS cost analysis add-on issues](/en-us/troubleshoot/azure/azure-kubernetes/aks-cost-analysis-add-on-issues).