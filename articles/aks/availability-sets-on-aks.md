---
layout: Conceptual
title: Availability Sets Deprecation in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/availability-sets-on-aks
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
description: Learn about the deprecation of Availability Sets and how to migrate from Availability Sets to Virtual Machines node pools in Azure Kubernetes Service (AKS).
ms.topic: overview
ms.date: 2026-03-30T00:00:00.0000000Z
ms.author: wilsondarko
author: wdarko1
locale: en-us
document_id: f5717fcb-04f4-f5ca-3152-ab4e29c714dc
document_version_independent_id: cd91f138-9358-55c1-173d-6f46aeca7ab4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/availability-sets-on-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/availability-sets-on-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/availability-sets-on-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
platformId: 4c6a01b4-87ad-772f-9d94-b6b760ad2d94
---

# Availability Sets Deprecation in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn

This article details how Azure Kubernetes Service (AKS) is phasing out support for Virtual Machine Availability Sets (VMAS) in favor of Virtual Machines (VMs). We recommend using [Virtual Machine node pools](virtual-machines-node-pools) for AKS-optimized VMs.

Virtual Machine node pools:

- Allow VM instances to be centrally managed, configured, and updated.
- Allow an increase or decrease of the number of virtual machine instances in response to demand or a defined schedule.
- Allow single node-level controls and same-family mixing of different sized nodes, which increases flexibility and improves consistency.

Important

Starting on **September 30, 2025**, Azure Kubernetes Service (AKS) no longer supports Availability Sets. Clusters with Availability Sets after this date are considered out of support. Migrate all workloads to [Virtual Machines node pools](/en-us/azure/aks/virtual-machines-node-pools) before this date to ensure ongoing support and take advantage of enhanced management features. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5021). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Availability Sets overview

Availability sets are logical groupings of virtual machines (VM) that reduce the chance of correlated failures bringing down related VMs at the same time. Availability sets place VMs in different fault domains for better reliability.

### Phase out of Availability Sets

As of 2019, we're no longer adding other features to Availability Sets in AKS. Any features introduced since 2019, such as AKS Backup, aren't supported in Availability Sets.

## Migrate from Availability Sets to Virtual Machines node pools

There's now a way to use a script to migrate your AKS cluster from using Availability Sets to Virtual Machines node pools. This script also automatically upgrades the Basic-tier load balancers in your cluster to Standard-tier.

Important

This process also migrates your Basic IP to a Standard IP, while keeping the inbound IP addresses associated with the load balancer the same. During this process, a new public IP is created and associated to the Standard Load Balancer outbound rules to serve cluster egress traffic.

For more information and an FAQ about the upgrade from Basic Load Balancer to Standard Load Balancer, see [Upgrade from Basic Load Balancer on Azure Kubernetes Service](upgrade-basic-load-balancer-on-aks).

### Before You Begin

**Requirements**

- The minimum Kubernetes version for this script is 1.27. If you need to upgrade your AKS cluster, see [upgrade an AKS cluster](upgrade-aks-cluster#upgrade-an-aks-cluster).
- You need the version 2.76.0 [Azure CLI installed](/en-us/cli/azure/install-azure-cli).
- If the cluster is running Key Management Service with private key vault, Key Management Service must be [disabled](/en-us/azure/aks/use-kms-etcd-encryption#turn-off-kms) during the entire migration.
- If the cluster is using any `ValidatingAdmissionWebhooks` or `MutatingAdmissionWebhooks`, these webhooks must be disabled before the migration. Control plane default webhooks shouldn't be disabled. For example `aks-node-mutating-webhook`, `webhook-admission-controller`, and `aks-node-validating-webhook`.

**Preparing for Migration**

- Create a migration plan for planned downtime.
- Once the migration is started, roll back isn't allowed.

### Run Migration Script for Availability Set Migration

In the following commands, replace `<myResourceGroup>` and `<myAKSCluster>` with your resource group name and AKS cluster name.

1. The following command initiates a script to migrate a cluster from using Availability Sets to Virtual Machines node pools using the `az aks update` command, and setting `--migrate-vmas-to-vms`. This script also upgrades the Basic Load Balancer and Basic IP to Standard Load Balancer and Standard IP, if applicable.

    ```azurecli
    az aks update \
      --name <myAKSCluster> \
      --resource-group <myResourceGroup> \
      --migrate-vmas-to-vms \
    ```
2. Verify that the migration was successful using the `az aks show` command. The command's output shows the cluster details.

    ```azurecli
    az aks show \
      --name <myAKSCluster> \
      --resource-group <myResourceGroup>
    ```

    A successful migration can be verified when the cluster details using the `az aks show` command include a `type` set to `VirtualMachines`, and `loadbalancerSku` set to `Standard`.

    ```azurecli
      "type": "VirtualMachines"
      "loadBalancerSku": "standard",
    ```
3. Verify that all pods and services are running successfully using the `kubectl get pods` and `kubectl get svc` commands:

    ```azurecli
    kubectl get svc -A \
    kubectl get pods -A
    ```
4. You can confirm the new IP addresses associated with outbound rules by listing the outbound IP addresses. This step is done by confirming the Resource IDs for the IP addresses, then listing the IP addresses.

    Use the following command to get the Resource ID for the outbound IP addresses:

    ```azurecli
    # Get the outbound IP Resource ID
    az aks show \
      --resource-group <myResourceGroup> \
      --name <myAKSCluster> \
      --query networkProfile.loadBalancerProfile.effectiveOutboundIPs[].id
    ```

    Use the following command to get each IP address for the Resource ID and replace `<IPResourceID>` with the Resource ID from the previous command:

    ```azurecli
    # get the new IP for each IP Resource ID
    az network public-ip show --ids <IPResourceID> --query ipAddress -o tsv
    ```

### Related content

- [More information on Virtual Machine node pools](virtual-machines-node-pools)
- [Upgrade from Basic Load Balancer on Azure Kubernetes Service](upgrade-basic-load-balancer-on-aks)