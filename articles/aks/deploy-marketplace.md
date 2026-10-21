---
layout: Conceptual
title: Deploy a Kubernetes application from Azure Marketplace - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/deploy-marketplace
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
description: Learn how to deploy Kubernetes applications from Azure Marketplace on an Azure Kubernetes Service (AKS) cluster.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.date: 2024-10-15T00:00:00.0000000Z
ms.subservice: aks-developer
ms.custom: ignite-fall-2022, references_regions
locale: en-us
document_id: 12c4e198-cf88-a5b9-ca18-8a087e79e644
document_version_independent_id: 9e255de6-773d-bb4f-9739-2ad76995eead
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/deploy-marketplace.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/deploy-marketplace
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/deploy-marketplace.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5e44decf-e201-4396-9baa-d26b1372789f
- https://authoring-docs-microsoft.poolparty.biz/devrel/970f20f1-2f12-4aa9-9c95-c00fe1f5e722
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/66922d0c-a09e-47eb-8764-2aa2d787014d
- https://authoring-docs-microsoft.poolparty.biz/devrel/432c4950-b799-4ed5-93d5-b9b2934edf7d
platformId: 6f6a188a-efce-050b-c35a-02f651cadf79
---

# Deploy a Kubernetes application from Azure Marketplace - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to deploy and manage a Kubernetes application from Azure Marketplace.

[Azure Marketplace](/en-us/marketplace/azure-marketplace-overview) is an online store that contains thousands of IT software applications and services built by industry-leading technology companies. In Azure Marketplace, you can find, try, buy, and deploy the software and services that you need to build new solutions and manage your cloud infrastructure. The catalog includes solutions for different industries and technical areas, free trials, and consulting services from Microsoft partners.

## Limitations

- This feature is currently supported only in the following regions:
    - Australia East, Australia Southeast, Brazil South, Canada Central, Canada East, Central India, Central US, East Asia, East US, East US 2, East US 2 EAUP, France Central, France South, Germany North, Germany West Central, Japan East, Japan West, Jio India West, Korea Central, Korea South, North Central Us, North Europe, Norway East, Norway West, South Africa North, South Central US, South India, Southeast Asia, Sweden Central, Switzerland North, UAE North, UK South, UK West, West Central US, West Europe, West US, West US 2, West US 3
- You can't deploy Kubernetes application-based container offers on AKS for Azure Stack HCI or AKS Edge Essentials.

## Select and deploy a Kubernetes application

### From an AKS cluster

1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, under **Settings**, select **Extensions + applications** &gt; **Add**.
3. You can search for an offer or publisher directly by name, or you can browse all offers. To view Kubernetes application offers, select **Containers** under **Categories**.
4. After you decide on an application, select the offer. The following example uses the **TrilioVault for Kubernetes - BYOL** offer.
5. Select **Plans + Pricing** to ensure the terms are acceptable, and then select **Create**.

    [![Screenshot of the offer purchasing page in the Azure portal, showing plan and pricing information.](media/deploy-marketplace/plans-pricing.png)](media/deploy-marketplace/plans-pricing.png#lightbox)
6. Follow each page in the application creation process, filling in information for your resource group, your cluster, and any configuration options that the application requires. You can decide to deploy on a new AKS cluster or use an existing cluster.
7. Once you've filled in all the required information, select **Review + create** &gt; **Create**.

    It might take a few minutes for the application to deploy. You can monitor the deployment status from the **Extensions + applications** page.

### Search in the Azure portal

1. From the Azure portal home page, search for and select **Marketplace**.
2. You can search for an offer or publisher directly by name, or you can browse all offers. To find Kubernetes application offers, on the left side under **Categories** select **Containers**.
3. After you decide on an application, select the offer. The following example uses the **TrilioVault for Kubernetes - BYOL** offer.
4. Select **Plans + Pricing** to ensure the terms are acceptable, and then select **Create**.

    [![Screenshot of the offer purchasing page in the Azure portal, showing plan and pricing information.](media/deploy-marketplace/plans-pricing.png)](media/deploy-marketplace/plans-pricing.png#lightbox)
5. Follow each page in the application creation process, filling in information for your resource group, your cluster, and any configuration options that the application requires. You can decide to deploy on a new AKS cluster or use an existing cluster.
6. Once you've filled in all the required information, select **Review + create** &gt; **Create**.

    It might take a few minutes for the application to deploy. You can monitor the deployment status from the **Extensions + applications** page.

## Verify the deployment

# [Azure portal](#tab/azure-portal)
1. Navigate to the cluster where you recently installed the application.
2. From the service menu, under **Settings**, select **Extensions + applications**.
3. Verify that the extension is listed and the *Provisioning State* shows **Succeeded**.

# [Azure CLI](#tab/azure-cli)
1. Connect to your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
    ```
2. List the installed extensions on the cluster using the [`az k8s-extension list`](/en-us/cli/azure/k8s-extension#az-k8s-extension-list) command.

    ```azurecli
    az k8s-extension list --cluster-name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --cluster-type managedClusters
    ```
3. Verify that the extension is listed and the *Provisioning State* shows **Succeeded**.

---

## Manage the offer lifecycle

For lifecycle management, a Kubernetes offer is represented as a cluster extension for AKS. For more information, see [Cluster extensions for AKS](cluster-extensions). Purchasing an offer from Azure Marketplace creates a new instance of the extension on your AKS cluster.

1. In the Azure portal, navigate to the cluster where you recently installed the application.
2. From the service menu, under **Settings**, select **Extensions + applications**.
3. Select an extension name to navigate to a properties view where you're able to disable autoupgrades, check the provisioning state, delete the extension instance, or modify configuration settings as needed.

## Monitor billing and usage information

1. In the Azure portal, navigate to your cluster's resource group.
2. From the service menu, under **Cost Management**, select **Cost analysis**. Under **Product**, you can see a cost breakdown for the plan that you selected.

## Remove an offer

You can delete a purchased plan for an Azure container offer by deleting the extension instance on the cluster.

# [Azure portal](#tab/azure-portal)
1. Navigate to the cluster where you recently installed the application.
2. From the service menu, under **Settings**, select **Extensions + applications**.
3. Select an application, then select **Uninstall**.

# [Azure CLI](#tab/azure-cli)
- Uninstall the extension on your AKS cluster using the [`az k8s-extension delete`](/en-us/cli/azure/k8s-extension#az-k8s-extension-delete) command.

    ```azurecli
    az k8s-extension delete --name $EXTENSION_NAME --cluster-name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --cluster-type managedClusters
    ```

---

## Troubleshooting

If you experience issues, see the [troubleshooting checklist for failed deployments of a Kubernetes offer](/en-us/troubleshoot/azure/azure-kubernetes/troubleshoot-failed-kubernetes-deployment-offer).