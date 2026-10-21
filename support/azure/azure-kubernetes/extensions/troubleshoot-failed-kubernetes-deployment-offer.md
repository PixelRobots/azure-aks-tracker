---
layout: Conceptual
title: Troubleshoot Kubernetes application offer deployment failures - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-failed-kubernetes-deployment-offer
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Troubleshoot failed deployment of a Kubernetes application offer in Azure Marketplace, identify common errors, and apply fixes quickly. Start resolving issues now.
ms.date: 2025-04-22T00:00:00.0000000Z
ms.reviewer: chiragpa, atchub, v-leedennis, mnasser
editor: v-jsitser
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: e26a9a6a-64d5-9cc8-b462-df7179906e20
document_version_independent_id: e26a9a6a-64d5-9cc8-b462-df7179906e20
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-failed-kubernetes-deployment-offer.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-failed-kubernetes-deployment-offer
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-failed-kubernetes-deployment-offer.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e9a1351b-859f-692c-df3f-c1cd7fa63fe5
---

# Troubleshoot Kubernetes application offer deployment failures - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot a failed deployment of a Kubernetes application offer that was accepted on the Microsoft Azure Marketplace. When you initiate the purchase of a Kubernetes offer, Azure deploys an Azure Resource Manager template (ARM template) that tries to install the required resources to fulfill the offer. However, the ARM template deployment might fail for various reasons.

## Troubleshooting checklist

### Examine the deployment operation logs

To determine the cause of the deployment failure, you have to examine the [deployment operation logs](/en-us/azure/azure-resource-manager/templates/deployment-history#deployment-operations-and-error-message). If you're still viewing the **Your deployment failed** page in the Azure portal, begin at step 5 of the following procedure. If, instead, you exited the Azure portal or navigated to another portal page, follow all these steps:

1. In the [Azure portal](https://portal.azure.com), search for and select **Resource groups**.
2. In the list of resource groups, select the name of the resource group in which you tried to deploy the Kubernetes application.
3. On the **Overview** page of your resource group, locate the **Essentials** section, and then select the hyperlinked text that appears next to the **Deployments** field. This text displays the success rate of your resource group's resource deployment history (for example, **4 failed, 30 succeeded**).
4. In the list of attempted deployments for your resource group, select the **Deployment name** value of the deployment that failed, based on the following corresponding fields:

    - **Last modified** (a time stamp)
    - **Duration**
    - **Status** (shows **Failed** instead of **Succeeded**)
5. In the **Deployment details** list on the deployment page, locate the **Resource** for which the **Status** field has a value of **Conflict**. Select the **Operation details** link for that resource.

    [![Screenshot of the 'Your deployment failed' page and the list of deployment details for a failed Kubernetes resource deployment.](media/troubleshoot-failed-kubernetes-deployment-offer/deployment-details.png)](media/troubleshoot-failed-kubernetes-deployment-offer/deployment-details.png#lightbox)
6. In the **Operation details** pane, locate the **Status** property (shows a value of **Conflict**), and examine the **Status message** box below the property.

    [![Screenshot of the 'Operation details' pane on the 'Your deployment failed' page for a failed Kubernetes resource deployment.](media/troubleshoot-failed-kubernetes-deployment-offer/operation-details.png)](media/troubleshoot-failed-kubernetes-deployment-offer/operation-details.png#lightbox)

    The JSON code within the status message shows a `status` property of `Failed`. It also shows an `error` property that contains the child properties of `code` (an error code name, such as "ExtensionOperationFailed") and `message` (an error message description, such as "The extension operation failed with the following error: Failed to resolve the extension version from the given values."). The JSON code resembles the following text:

    ```json
    {
        "status": "Failed",
        "error": {
            "code": "ExtensionOperationFailed",
            "message": "The extension operation failed with the following error: Failed to resolve the extension version from the given values."
        }
    }
    ```

The following sections discuss the cause and solution for some common failure scenarios.

## Cause 1: the application didn't install on the selected AKS cluster

If the Kubernetes application didn't install on the selected Azure Kubernetes Service (AKS) cluster, you receive an error message that resembles the following text:

> 
> Request failed to https://management.azure.com/subscriptions/&lt;subscription-guid&gt;/resourceGroups/resourceGroup/providers/Microsoft.ContainerService/managedclusters/aks-cluster/extensionaddons/default?api-version=2021-03-01. Error code: Forbidden. Reason: Forbidden.
> 
> 
> ```json
> {  
>   "error": {  
>     "code": "AuthorizationFailed",  
>     "message": "The client '<client-guid>' with object id '<client-guid>' does not have authorization to perform action 'Microsoft.ContainerService/managedclusters/extensionaddons/read' over scope '/subscriptions/<subscription-guid>/resourceGroups/resourceGroup/providers/Microsoft.ContainerService/managedclusters/aks-cluster/extensionaddons/default' or the scope is invalid. If access was recently granted, please refresh your credentials."  
>   }  
> } 
> ```

### Solution 1a: register the Microsoft.KubernetesConfiguration resource provider

Register the Microsoft.KubernetesConfiguration resource provider. In this case, the installation failed because the Microsoft.KubernetesConfiguration resource provider is required for you to deploy the Kubernetes application. For registration instructions, see the "[Register resource providers](/en-us/azure/aks/deploy-marketplace#register-resource-providers)" section in the *Deploy a container offer from Azure Marketplace* article.

### Solution 1b: maintain the health of the AKS cluster

In general, you should [check the health of the AKS cluster](/en-us/azure/architecture/operator-guides/aks/aks-triage-cluster-health) to prevent other issues from occurring during the installation period. To make sure that the cluster is healthy, resolve issues that are identified on the cluster.

### Solution 1c: examine the Azure Monitor activity log

What if the cluster is healthy, but the installation still fails? In that case, examine the [Azure Monitor activity log](/en-us/azure/azure-monitor/essentials/activity-log) within the AKS cluster to find the cause of the failure at that stage of the installation.

## Cause 2: the subscription has resource constraints

Because your Azure subscription has resource constraints, you experience a failure that produces an error message that's similar to the following text:

> 
> The 'unknown' payment instrument(s) is not supported for offer with OfferId: '&lt;offer-name&gt;', PlanId '&lt;subscription-plan-name&gt;'.

### Solution 2: make sure your subscription meets the necessary billing configuration

Verify the subscription's billing configuration to make sure that it meets the resource requirements of the Kubernetes application. For more information, see [Purchase validation checks](/en-us/marketplace/azure-purchasing-invoicing#purchase-validation-checks).

## Cause 3: the offer wasn't available in your region

You receive an error message that states that the offer can't be sold in a certain geographical region. The error message might resemble the following text:

> 
> The Offer: '&lt;offer-name&gt;' cannot be purchased by subscription: '&lt;subscription-guid&gt;' as it is not to be sold in market: '&lt;two-letter-region-code'.

### Solution 3: recheck whether and where the offer is still available

Verify that the offer is still available, and double-check the regions that the offer applies to.

## Cause 4: an internal server error occurred

The Kubernetes application didn't install because an extension resource didn't install. This failure generates the following error message:

> 
> Extension failed to deploy with Internal server error

### Solution 4: delete and reinstall the extension

First, delete the extension resource that's a part of the offer purchase. Then, reinstall the extension.

## Cause 5: the Helm chart didn't install

Errors in the Helm chart generate the following error message:

> 
> Failed to install chart from path [] for release

### Solution 5: recheck the entries that you made in the ARM template

Make sure that the values and selections that you entered on the Azure portal for the ARM template deployment are acceptable in the Kubernetes application.

## Cause 6: you haven't accepted the legal terms on the subscription for this plan

Before the subscription can be used, you need to accept the legal terms of the image. Otherwise, you get the following error message:

> 
> You have not accepted the legal terms on this subscription: '&lt;subscription-guid&gt;' for this plan. Before the subscription can be used, you need to accept the legal terms of the image.

### Solution 6: accept the legal terms

# [Portal](#tab/azure-portal)
You can deploy through the [Azure portal](https://portal.azure.com). The Azure portal provides a UI experience for reading and accepting the legal terms.

# [CLI](#tab/CLI)
You can use the Azure CLI commands that are described in the [Azure CLI legal terms](/en-us/cli/azure/vm/image/terms). Although the commands are for VMs, the commands also work for containers.

# [PowerShell](#tab/PowerShell)
To accept the legal terms through PowerShell, run the cmdlets that are described in the [PowerShell legal terms](/en-us/powershell/module/az.marketplaceordering).

---