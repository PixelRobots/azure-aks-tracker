---
layout: Conceptual
title: Deploy an Azure Kubernetes application by using an ARM template - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/deploy-application-template
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
description: Learn how to deploy an Azure Kubernetes application by using an ARM template.
author: schaffererin
ms.author: schaffererin
ms.topic: concept-article
ms.custom: devx-track-arm-template
ms.subservice: aks-developer
ms.date: 2023-05-15T00:00:00.0000000Z
locale: en-us
document_id: d225c69f-6709-9dad-3519-c8ba2a933d75
document_version_independent_id: cc004b85-b44a-be93-392f-cb3f49a51c1a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/deploy-application-template.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/deploy-application-template
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/deploy-application-template.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d0f42e1d-dfdc-6fd0-bba5-84abccd1f8d3
---

# Deploy an Azure Kubernetes application by using an ARM template - Azure Kubernetes Service | Microsoft Learn

To deploy a Kubernetes application programmatically through Azure CLI, you select the Kubernetes application and settings, generate an ARM template, accept legal terms and conditions, and finally deploy the ARM template.

## Select Kubernetes application

First, you need to select the Kubernetes application that you want to deploy in the Azure portal.

1. In the Azure portal, go to the [Marketplace page](https://portal.azure.com/#view/Microsoft_Azure_Marketplace/MarketplaceOffersBlade/selectedMenuItemId/home/fromContext/AKS).
2. Select your Kubernetes application.
3. Select the required plan.
4. Select the **Usage Information + Support** tab. Copy the values for `publisherID`, `productID`, and `planID`. You'll need these values later.

    ![Screenshot showing the Usage Information + Support tab for a Kubernetes application.](media/deploy-application-template/usage-information.png)

## Generate ARM template

Continue on to generate the ARM template for your deployment.

1. Select the **Create** button.
2. Fill out all the application (extension) details.
3. At the bottom of the **Review + Create** tab, select **Download a template for automation**.

    ![Screenshot showing the option to download a template for a Kubernetes application.](media/deploy-application-template/download-template.png)

    If all the validations are passed, you'll see the ARM template in the editor.

    ![Screenshot showing an ARM template for a Kubernetes application.](media/deploy-application-template/download-arm-template.png)
4. Download the ARM template and save it to a file on your computer.

## Accept terms and agreements

Before you can deploy a Kubernetes application, you need to accept its terms and agreements. To do so, use [Azure CLI](/en-us/cli/azure/vm/image/terms) or [Azure PowerShell](/en-us/powershell/module/az.marketplaceordering/). Be sure to use the values you copied for `plan-publisher`, `plan-offerID`, and `plan-name` in your command.

```azurecli
az vm image terms accept --offer <Product ID> --plan <Plan ID> --publisher <Publisher ID>
```

Note

Although this Azure CLI command is for VMs, it also works for containers. For more information, see the [`az cm image terms` reference](/en-us/cli/azure/vm/image/terms).

```azurepowershell
## Get-AzMarketplaceTerms -Publisher <Publisher ID> -Product <Product ID> -Name <Plan ID>
```

## Deploy ARM template

Once you've accepted the terms, you can deploy your ARM template. For instructions, see [Tutorial: Create and deploy your first ARM template](/en-us/azure/azure-resource-manager/templates/template-tutorial-create-first-template).