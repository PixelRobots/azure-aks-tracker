---
layout: Conceptual
title: Deploy and manage applications from Microsoft Marketplace on Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/deploy-marketplace
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2026-03-24T00:00:00.0000000Z
ms.custom: references-regions, devx-track-azurecli
ms.topic: how-to
description: Learn how to discover Kubernetes applications in Microsoft Marketplace and deploy them on your Arc-enabled Kubernetes clusters.
locale: en-us
document_id: ab5394bf-9519-02cb-75de-64ad24149211
document_version_independent_id: 8ce2a171-c89b-4c0c-6b8f-c92d5b8a59d8
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/deploy-marketplace.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-arc/kubernetes/deploy-marketplace
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/deploy-marketplace.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 346958b4-4331-4a62-a800-5574940aa163
---

# Deploy and manage applications from Microsoft Marketplace on Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn

[Microsoft Marketplace](/en-us/marketplace/marketplace-overview) is an online store that contains thousands of IT software applications and services built by industry-leading technology companies. In Microsoft Marketplace, you can find, try, buy, and deploy the software and services you need to build new solutions and manage your cloud infrastructure. The catalog includes solutions for different industries and technical areas, free trials, and consulting services from Microsoft partners.

Included among these solutions are Kubernetes application-based container offers. These offers contain applications that run on Azure Arc-enabled Kubernetes clusters, represented as [cluster extensions](conceptual-extensions). When you deploy an offer from Microsoft Marketplace, you create a new instance of the extension on your Arc-enabled Kubernetes cluster.

In this article, you learn how to:

- Discover applications that support Azure Arc-enabled Kubernetes clusters.
- Purchase an application.
- Deploy the application on your cluster.
- Monitor usage and billing information.

You can use the Azure CLI or the Azure portal to perform these tasks.

## Prerequisites

- An existing Azure Arc-enabled Kubernetes connected cluster, with at least one node of operating system and architecture type `linux/amd64`.
    - If you don't have a connected cluster yet, see our [quickstart](quickstart-connect-cluster).
    - [Upgrade your agents](agent-upgrade#manually-upgrade-agents) to the latest version.
- If using Azure CLI to review, deploy, and manage Microsoft Marketplace applications:
    - The latest version of [Azure CLI](/en-us/cli/azure/install-azure-cli).
    - The latest version of the `k8s-extension` Azure CLI extension. Install the extension by running `az extension add --name k8s-extension`. If the `k8s-extension` extension is already installed, update it to the latest version by running `az extension update --name k8s-extension`.

Note

This feature is currently supported only in the following regions:

- East US, East US2, EastUS2 EUAP, West US, West US2, Central US, West Central US, South Central US, West Europe, North Europe, Canada Central, South East Asia, Australia East, Central India, Japan East, Korea Central, UK South, UK West, Germany West Central, France Central, East Asia, West US3, Norway East, South African North, North Central US, Australia South East, Switzerland North, Japan West, South India

## Discover Kubernetes applications that support Azure Arc-enabled clusters

# [Azure portal](#tab/azure-portal)
To discover Kubernetes applications in Microsoft Marketplace from within the Azure portal:

1. In the Azure portal, search for **Marketplace**. In the results, under **Services**, select **Marketplace**.
2. Search by name or keyword, or browse all offers. To find Kubernetes application offers, select **Infrastructure Services** from the **Categories** section in the left menu. Then scroll down until you see the **Containers & Kubernetes Apps** category.

    Important

    The **Containers & Kubernetes Apps** category includes both Kubernetes apps and standalone container images. Select only **Kubernetes Apps** offers when following these steps. Container images have a different deployment process and generally can't be deployed on Azure Arc-enabled Kubernetes clusters.
3. Several Kubernetes application offers appear on the page. To view all Kubernetes application offers, select **See more**.

    ![Screenshot showing the See more link for the Containers category in Microsoft Marketplace.](media/deploy-marketplace/marketplace-see-more.png)
4. Alternatively, search for a specific `publisherId` to view that publisher's Kubernetes applications in Microsoft Marketplace. For details about how to find publisher IDs, see the Azure CLI tab for this article.

When you find an application that you want to deploy, move on to the next section.

# [Azure CLI](#tab/azure-cli)
Use Azure CLI to get a list of extensions, including Microsoft Marketplace applications, that you can deploy on Azure Arc-enabled connected clusters. Run this command, providing the name of your connected cluster and the resource group where the cluster is located.

```azurecli
az k8s-extension extension-types list-by-cluster --cluster-type connectedClusters --cluster-name <clusterName> --resource-group <resourceGroupName>
```

The command returns a list of extension types that you can deploy on the connected clusters, similar to the example shown here.

```json
"id": "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Kubernetes/connectedClusters/{clustername}/providers/Microsoft.KubernetesConfiguration/extensiontypes/contoso",
"name": "contoso",
"type": "Microsoft.KubernetesConfiguration/extensionTypes",
"properties": {
    "extensionType": "contoso",
    "description": "Contoso extension",
    "isSystemExtension": false,
    "publisher": "contoso",
    "isManagedIdentityRequired": false,
    "supportedClusterTypes": [
        "managedclusters",
        "connectedclusters"
    ],
    "supportedScopes": {
        "defaultScope": "namespace",
        "clusterScopeSettings": {
            "allowMultipleInstances": false,
            "defaultReleaseNamespace": null
        }
    },
    "planInfo": {
        "offerId": "contosoOffer",
        "planId": "contosoPlan",
        "publisherId": "contoso"
    }
}
```

When you find an application that you want to deploy, note the following values from the response: `planId`, `publisherId`, `offerID`, and `extensionType`. You need these values to accept the application's terms and to deploy the application.

---

## Deploy a Kubernetes application

# [Azure portal](#tab/azure-portal)
After you identify an offer you want to deploy, select it and follow these steps:

1. In the **Plans + Pricing** tab, review the options. If there are multiple plans available, find the one that meets your needs. Review the terms on the page to make sure they're acceptable, then select one of the **Create** options.

    ![Screenshot of the Plans + Pricing page for a Kubernetes offer in Microsoft Marketplace.](media/deploy-marketplace/marketplace-plans-pricing.png)
2. Select the subscription, resource group, and Arc-enabled cluster to which you want to deploy the application, along with any other required information.
3. Complete all pages of the deployment wizard to specify all configuration options that the application requires. These options vary depending on the offer.
4. When you're finished, select **Review + create**. Review the terms and make sure you agree, then select **Create** to deploy the offer.

# [Azure CLI](#tab/azure-cli)
#### Accept terms and agreements

Before you can deploy a Kubernetes application, you need to accept its terms and agreements. Be sure to read these terms carefully so that you understand costs and any other requirements.

To view the details of the terms, run the following command, providing the values for `offerID`, `planId`, and `publisherId`:

```azurecli
az vm image terms show --offer <offerID> --plan <planId> --publisher <publisherId>
```

To accept the terms, run the following command, using the same values for `offerID`, `planId`, and `publisherId`.

```azurecli
az vm image terms accept --offer <offerID> --plan <planId> --publisher <publisherId>
```

Note

Although this command is for VMs, it also works for terms related to containers, including Arc-enabled Kubernetes clusters. For more information about this command, see the [az vm image terms](/en-us/cli/azure/vm/image/terms) reference.

#### Deploy the application

To deploy the application (extension) through Azure CLI, follow the steps outlined in [Deploy and manage Azure Arc-enabled Kubernetes cluster extensions](extensions), including the `planId`, `publisherId`, `offerID`, and `extensionType` of the application you want to deploy. To find these values, see the Discover Kubernetes applications section. An example command might look like this:

```azurecli
az k8s-extension create --name <offerID> --extension-type <extensionType> --cluster-name <clusterName> --resource-group <resourceGroupName> --cluster-type connectedClusters --plan-name <planId> --plan-product <offerID> --plan-publisher <publisherId>  
```

---

## Verify the deployment

Deploying an offer from Microsoft Marketplace creates a new extension instance on your Arc-enabled Kubernetes cluster. You can verify that the deployment was successful by confirming that the extension is running successfully.

# [Azure portal](#tab/azure-portal)
Go to the cluster where you installed the extension. In the service menu, under **Settings**, select **Extensions**.

Find the application you just deployed and check the value for **Status**. When the deployment finishes successfully, the **Status** is **Succeeded**.

![Screenshot showing the status of deployed extensions in the Azure portal.](media/deploy-marketplace/extension-status.png)

If the deployment is still in progress, the status is **Creating**; wait a few minutes and then check again.

If the status is **Failed**, see [Troubleshoot the failed deployment of a Kubernetes application offer](/en-us/troubleshoot/azure/azure-kubernetes/troubleshoot-failed-kubernetes-deployment-offer).

# [Azure CLI](#tab/azure-cli)
Verify the deployment by using the following command to list the extensions that are already running or being deployed on your cluster:

```azurecli
az k8s-extension list --cluster-name <clusterName> --resource-group <resourceGroupName> --cluster-type connectedClusters
```

Find the application you just deployed and check the value for `provisioningState`. When the deployment finishes successfully, `provisioningState` is `Succeeded`. If the deployment is still in progress, `provisioningState` is `Creating`; wait a few minutes and then check again.

If `provisioningState` is `Failed`, see [Troubleshoot the failed deployment of a Kubernetes application offer](/en-us/troubleshoot/azure/azure-kubernetes/troubleshoot-failed-kubernetes-deployment-offer).

To view the extension instance from the cluster, run the following command:

```azurecli
az k8s-extension show --name <extension-name> --cluster-name <clusterName> --resource-group <resourceGroupName> --cluster-type connectedClusters
```

---

## Monitor billing and usage information

You can monitor billing and usage information for a deployed extension in the Azure portal.

1. In the Azure portal, go to your cluster's resource group.
2. In the service menu, under **Cost Management**, select **Cost analysis**. Under **Product**, you can see a cost breakdown for the plan that you selected.

## Remove an application

You can delete a purchased plan for a Kubernetes offer by deleting the extension instance on the cluster.

# [Azure portal](#tab/azure-portal)
To delete the extension instance in the Azure portal, go to the cluster where you installed the extension. In the service menu, under **Settings**, select **Extensions**. Select the application you want to remove, and then select **Uninstall**.

# [Azure CLI](#tab/azure-cli)
To delete an extension from a cluster, use the following command:

```azurecli
az k8s-extension delete --name <extension-name> --cluster-name <clusterName> --resource-group <resourceGroupName> --cluster-type connectedClusters
```

---

## Troubleshooting

For help resolving problems, see [Troubleshoot the failed deployment of a Kubernetes application offer](/en-us/troubleshoot/azure/azure-kubernetes/troubleshoot-failed-kubernetes-deployment-offer).