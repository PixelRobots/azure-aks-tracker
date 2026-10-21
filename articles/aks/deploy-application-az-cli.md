---
layout: Conceptual
title: Deploy an Azure Kubernetes application programmatically by using Azure CLI - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/deploy-application-az-cli
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
description: Learn how to deploy an Azure Kubernetes application programmatically by using Azure CLI.
author: schaffererin
ms.author: schaffererin
ms.topic: concept-article
ms.custom: devx-track-azurecli
ms.subservice: aks-developer
ms.date: 2024-10-30T00:00:00.0000000Z
locale: en-us
document_id: 32f2430c-4cb5-ddd6-5376-a2d3b9b57e54
document_version_independent_id: 52fe26af-ce27-8f76-9341-9fe13ef95798
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/deploy-application-az-cli.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/deploy-application-az-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/deploy-application-az-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/970f20f1-2f12-4aa9-9c95-c00fe1f5e722
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/432c4950-b799-4ed5-93d5-b9b2934edf7d
platformId: 7a749b26-7390-556e-cc89-fef6ac81ccc8
---

# Deploy an Azure Kubernetes application programmatically by using Azure CLI - Azure Kubernetes Service | Microsoft Learn

To deploy a Kubernetes application programmatically through Azure CLI, you select the Kubernetes application and settings, accept legal terms and conditions, and finally deploy the application through CLI commands.

## Select Kubernetes application

First, you need to select the Kubernetes application that you want to deploy in the Azure portal. You'll also need to copy some of the details for later use.

1. In the Azure portal, go to the [Marketplace page](https://portal.azure.com/#view/Microsoft_Azure_Marketplace/MarketplaceOffersBlade/selectedMenuItemId/home/fromContext/AKS).
2. Select your Kubernetes application.
3. Select the required plan.
4. Select the **Create** button.
5. Fill out all the application (extension) details.
6. In the **Review + Create** tab, select **Download a template for automation**. If all the validations are passed, you'll see the ARM template in the editor.
7. Examine the ARM template:

    1. In the variables section, copy the `plan-name,``plan-publisher,``plan-offerID,` and `clusterExtensionTypeName` values for later use.

        ```json
          "variables": {
                "plan-name": "DONOTMODIFY",
                "plan-publisher": "DONOTMODIFY",
                "plan-offerID": "DONOTMODIFY",
                "releaseTrain": "DONOTMODIFY",
                "clusterExtensionTypeName": "DONOTMODIFY"
            },
        ```
    2. In the resource `Microsoft.KubernetesConfiguration/extensions` section, copy the `configurationSettings` section for later use.

    ```json
    {
                "type": "Microsoft.KubernetesConfiguration/extensions",
                "apiVersion": "2022-11-01",
                "name": "[parameters('extensionResourceName')]",          
                "properties": {
                    "extensionType": "[variables('clusterExtensionTypeName')]",
                    "autoUpgradeMinorVersion": true,
                    "releaseTrain": "[variables('releaseTrain')]",
                    "configurationSettings": {
                        "title": "[parameters('app-title')]",
                        "value1": "[parameters('app-value1')]",
                        "value2": "[parameters('app-value2')]"
                    },
    ```

    Note

    If there are no configuration settings in the ARM template, refer to the application-related documentation in Azure Marketplace or on the partner's website.

## Accept terms and agreements

Before you can deploy a Kubernetes application, you need to accept its terms and agreements. To do so, run the following command, using the values you copied for `plan-publisher`, `plan-offerID`, and `plan-name`.

```azurecli
az vm image terms accept --offer <plan-offerID> --plan <plan-name> --publisher <plan-publisher>
```

Note

Although this command is for VMs, it also works for containers. For more information, see the [`az cm image terms` reference](/en-us/cli/azure/vm/image/terms).

## Deploy the application

To deploy the application (extension) through Azure CLI, follow the steps outlined in [Deploy and manage cluster extensions by using Azure CLI](deploy-extensions-az-cli).