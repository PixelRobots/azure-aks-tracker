---
layout: Conceptual
title: Use Azure Dedicated Hosts in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-azure-dedicated-hosts
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
description: Learn how to create an Azure Dedicated Hosts Group and associate it with Azure Kubernetes Service (AKS)
ms.topic: how-to
ms.subservice: aks-nodes
ms.custom: devx-track-azurecli
ms.date: 2023-03-10T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: dace6d0e-0e0a-85d7-27e4-9556c21f884a
document_version_independent_id: b034becb-b8db-3ceb-9a34-a34cdd38c19b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-azure-dedicated-hosts.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-azure-dedicated-hosts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-azure-dedicated-hosts.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/a48df08f-c196-4114-998c-7d0528e51d7a
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7853f9c-f51c-437c-a7f2-85bda0416f2e
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c437f998-d01a-cf4a-ccda-9366ded85b67
---

# Use Azure Dedicated Hosts in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Azure Dedicated Host is a service that provides physical servers - able to host one or more virtual machines - dedicated to one Azure subscription. Dedicated hosts are the same physical servers used in our data centers, provided as a resource. You can provision dedicated hosts within a region, availability zone, and fault domain. Then, you can place VMs directly into your provisioned hosts, in whatever configuration best meets your needs.

Using Azure Dedicated Hosts for nodes with your AKS cluster has the following benefits:

- Hardware isolation at the physical server level. No other VMs will be placed on your hosts. Dedicated hosts are deployed in the same data centers and share the same network and underlying storage infrastructure as other, non-isolated hosts.
- Control over maintenance events initiated by the Azure platform. While most maintenance events have little to no impact on your virtual machines, there are some sensitive workloads where each second of pause can have an impact. With dedicated hosts, you can opt in to a maintenance window to reduce the impact to your service.

## Before you begin

- An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Before you start, ensure that your version of the Azure CLI is 2.39.0 or later. If it's an earlier version, [install the latest version](/en-us/cli/azure/install-azure-cli).

## Limitations

The following limitations apply when you integrate Azure Dedicated Host with Azure Kubernetes Service:

- Accelerated Networking
- An existing agent pool can't be converted from non-ADH to ADH or ADH to non-ADH.
- It isn't supported to update agent pool from host group A to host group B.
- Using ADH across subscriptions.

## Planning for ADH Capacity on AKS

Not all host SKUs are available in all regions, and availability zones. You can list host availability, and any offer restrictions before you start provisioning dedicated hosts.

```azurecli
az vm list-skus --location eastus --resource-type hostGroups/hosts  -o table
```

Note

First, when using host group, the nodepool fault domain count is always the same as the host group fault domain count. In order to use cluster auto-scaling to work with ADH and AKS, please make sure your host group fault domain count and capacity is enough. Secondly, only change fault domain count from the default of 1 to any other number if you know what they are doing as a misconfiguration could lead to a unscalable configuration.

[Determine how many hosts you would need based on the expected VM Utilization](/en-us/azure/virtual-machines/dedicated-host-general-purpose-skus).

Evaluate [host utilization](/en-us/azure/virtual-machines/dedicated-hosts-how-to#check-the-status-of-the-host) to determine the number of allocatable VMs by size before you deploy.

```azurecli
az vm host get-instance-view --resource-group myDHResourceGroup --host-group MyHostGroup --name MyHost
```

## Add a Dedicated Host Group to an AKS cluster

A host group is a resource that represents a collection of dedicated hosts. You create a host group in a region and an availability zone, and add hosts to it. When planning for high availability, there are more options. You can use one or both of the following options with your dedicated hosts:

- Span across multiple availability zones. In this case, you're required to have a host group in each of the zones you wish to use.
- Span across multiple fault domains, which are mapped to physical racks.

In either case, you need to provide the fault domain count for your host group. If you don't want to span fault domains in your group, use a fault domain count of 1.

You can also decide to use both availability zones and fault domains.

## Create a Host Group

Now create a dedicated host in the host group. In addition to a name for the host, you're required to provide the SKU for the host. Host SKU captures the supported VM series and the hardware generation for your dedicated host.

For more information about the host SKUs and pricing, see [Azure Dedicated Host pricing](https://azure.microsoft.com/pricing/details/virtual-machines/dedicated-host/).

Use az vm host create to create a host. If you set a fault domain count for your host group, you'll be asked to specify the fault domain for your host.

In this example, we'll use [az vm host group create](/en-us/cli/azure/vm/host/group#az-vm-host-group-create) to create a host group using both availability zones and fault domains.

```azurecli
az vm host group create \
--name myHostGroup \
--resource-group myDHResourceGroup \
--zone 1 \
--platform-fault-domain-count 1 \
--automatic-placement true
```

## Create a Dedicated Host

Now create a dedicated host in the host group. In addition to a name for the host, you're required to provide the SKU for the host. Host SKU captures the supported VM series and the hardware generation for your dedicated host.

If you set a fault domain count for your host group, you'll need to specify the fault domain for your host.

```azurecli
az vm host create \
--host-group myHostGroup \
--name myHost \
--sku DSv3-Type1 \
--platform-fault-domain 1 \
--resource-group myDHResourceGroup
```

## Use a user-assigned Identity

Important

A user-assigned Identity with "contributor" role on the Resource Group of the Host Group is required.

First, create a Managed Identity

```azurecli
az identity create --resource-group <Resource Group> --name <Managed Identity name>
```

Assign Managed Identity

```azurecli
az role assignment create --assignee <id> --role "Contributor" --scope <Resource id>
```

## Create an AKS cluster using the Host Group

Create an AKS cluster, and add the Host Group you just configured.

```azurecli
az aks create \
    --resource-group MyResourceGroup \
    --name MyManagedCluster \
    --location eastus \
    --nodepool-name agentpool1 \
    --node-count 1 \
    --host-group-id <id> \
    --node-vm-size Standard_D2s_v3 \
    --assign-identity <id> \
    --generate-ssh-keys
```

## Add a Dedicated Host Node Pool to an existing AKS cluster

Add a Host Group to an already existing AKS cluster.

```azurecli
az aks nodepool add --cluster-name MyManagedCluster --name agentpool3 --resource-group MyResourceGroup --node-count 1 --host-group-id <id> --node-vm-size Standard_D2s_v3
```

## Remove a Dedicated Host Node Pool from an AKS cluster

```azurecli
az aks nodepool delete --cluster-name MyManagedCluster --name agentpool3 --resource-group MyResourceGroup
```