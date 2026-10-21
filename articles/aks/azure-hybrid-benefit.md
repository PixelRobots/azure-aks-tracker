---
layout: Conceptual
title: Use Azure Hybrid Benefit - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-hybrid-benefit
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
description: Learn how to save costs for Windows workloads by using existing Windows Server licenses on Azure Kubernetes Service.
ms.topic: concept-article
ms.date: 2024-02-09T00:00:00.0000000Z
ms.author: viniap
author: vrapolinario
locale: en-us
document_id: baacf26b-eb09-5d6e-a6ed-771a1273b5d4
document_version_independent_id: 72f0b04b-3c22-9690-5ba2-242b387c66f2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-hybrid-benefit.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/azure-hybrid-benefit
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-hybrid-benefit.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 3d8b92e2-915e-e46e-069c-f620dbcb7d84
---

# Use Azure Hybrid Benefit - Azure Kubernetes Service | Microsoft Learn

Azure Hybrid Benefit is a program that enables you to significantly reduce the costs of running workloads in the cloud. With Azure Hybrid Benefit for Azure Kubernetes Service (AKS), you can maximize the value of your on-premises licenses and modernize your applications at no extra cost. Azure Hybrid Benefit enables you to use your on-premises licenses that also have either active Software Assurance (SA) or a qualifying subscription to get Windows virtual machines (VMs) on Azure at a reduced cost.

For more information on qualifications for Azure Hybrid Benefit, what is included with it, how to stay compliant, and more, check out [Azure Hybrid Benefit for Windows Server](/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing).

Note

Azure Hybrid Benefit for Azure Kubernetes Service follows the same licensing guidance as Azure Hybrid Benefit for Windows Server VMs on Azure.

## Enable Azure Hybrid Benefit for Azure Kubernetes Service

Azure Hybrid Benefit for Azure Kubernetes Service can be enabled at cluster creation or on an existing AKS cluster. You can enable and disable Azure Hybrid Benefit using either the Azure CLI or Azure PowerShell. In the following examples, be sure to replace the variable definitions with values matching your own cluster.

To create a new AKS cluster with Azure Hybrid Benefit enabled:

# [Azure CLI](#tab/azure-cli)
```azurecli
PASSWORD='' # replace with your own password value
RG_NAME='myResourceGroup'
CLUSTER='myAKSCluster'

az aks create \
    --resource-group $RG_NAME \
    --name $CLUSTER \
    --load-balancer-sku Standard \
    --network-plugin azure \
    --windows-admin-username azure \
    --windows-admin-password $PASSWORD \
    --enable-ahub \
    --generate-ssh-keys
```

# [Azure PowerShell](#tab/azure-powershell)
```powershell
$password= ConvertTo-SecureString -AsPlainText "" -Force # replace with your own password value
$rg_name = "myResourceGroup"
$cluster = "myAKSCluster"

New-AzAksCluster -ResourceGroupName $rg_name -Name $cluster -WindowsProfileAdminUserName azureuser -WindowsProfileAdminUserPassword $cred -NetworkPlugin azure -NodeVmSetType VirtualMachineScaleSets --EnableAHUB
```

---

To enable Azure Hybrid Benefit on an existing AKS cluster:

# [Azure CLI](#tab/azure-cli)
```azurecli
RG_NAME='myResourceGroup'
CLUSTER='myAKSCluster'

az aks update --resource-group $RG_NAME --name $CLUSTER--enable-ahub
```

# [Azure PowerShell](#tab/azure-powershell)
```powershell
$rg_name = "myResourceGroup"
$cluster = "myAKSCluster"

Get-AzAksCluster -ResourceGroupName $rg_name -Name $cluster | Set-AzAksCluster -EnableAHUB
```

---

## Disable Azure Hybrid Benefit for Azure Kubernetes Service

To disable Azure Hybrid Benefit for an AKS cluster:

# [Azure CLI](#tab/azure-cli)
```azurecli
RG_NAME='myResourceGroup'
CLUSTER='myAKSCluster'

az aks update --resource-group $RG_NAME --name $CLUSTER --disable-ahub
```

# [Azure PowerShell](#tab/azure-powershell)
It's currently not possible to disable Azure Hybrid Benefit for AKS using Azure PowerShell.

---