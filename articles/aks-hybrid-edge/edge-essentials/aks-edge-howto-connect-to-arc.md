---
layout: Conceptual
title: Arc-connected AKS Edge Essentials | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-connect-to-arc
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Connect your AKS Edge Essentials clusters to Arc
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-how-to, edge-essentials
locale: en-us
document_id: dfb94b86-5356-8a6a-eea1-b8f888716970
document_version_independent_id: 9d84aa64-7adc-b285-f30d-627ad69c0cc9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-connect-to-arc.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-connect-to-arc
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-connect-to-arc.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 752a2455-8722-17ae-50aa-df3c1c0bc449
---

# Arc-connected AKS Edge Essentials | Microsoft Learn

This article describes how to connect your AKS Edge Essentials cluster to [Azure Arc](/en-us/azure/azure-arc/kubernetes/overview) so that you can monitor the health of your cluster on the Azure portal. If your cluster is connected to a proxy, you can use the scripts provided in the GitHub repo to connect your cluster to Arc [as described here](aks-edge-howto-more-configs).

Important

Starting with the AKS Edge Essentials 1.10.868.0 release, the `Arc` section of the config file is required. The Azure Arc connection occurs automatically after you run `New-AksEdgeDeployment` to deploy an AKS Edge Essentials cluster.

## Prerequisites

- Before connecting to Arc, infrastructure administrators who are the owner or contributor role of the subscription will have to:
    1. Enable all required resource providers in the Azure subscription, such as **Microsoft.HybridCompute**, **Microsoft.GuestConfiguration**, **Microsoft.HybridConnectivity**, **Microsoft.Kubernetes**, **Microsoft.ExtendedLocation**, and **Microsoft.KubernetesConfiguration**.
    2. Create and verify a resource group for AKS Edge Essentials Azure resources.
- To connect to Arc, Kubernetes operators need a [**Kubernetes Cluster - Azure Arc Onboarding**](/en-us/azure/role-based-access-control/built-in-roles/containers#kubernetes-cluster---azure-arc-onboarding) role for the identity at the resource group level. To disconnect from Arc, operators need an [**Azure Kubernetes Service Arc Contributor Role**](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-arc-contributor-role) role for the identity at the resource group level. To check your access level, navigate to your subscription on the Azure portal, select **Access control (IAM)** on the left-hand side, and then select **View my access**. See [the Azure documentation](/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal) for more information about managing resource groups. Infrastructure administrators with owner or contributor roles can also perform actions to connect or disconnect from Arc.
- In addition to these prerequisites, make sure you meet all [network requirements for Azure Arc-enabled Kubernetes](/en-us/azure/azure-arc/kubernetes/network-requirements).

Note

You need the **Contributor** role to be able to delete the resources within the resource group. Commands to disconnect from Arc will fail without this role assignment.

## Step 1: configure your machine

### Install dependencies

Run the following commands in an elevated PowerShell window to install the dependencies in PowerShell:

```powershell
Install-Module Az.Resources -Repository PSGallery -Force -AllowClobber -ErrorAction Stop  
Install-Module Az.Accounts -Repository PSGallery -Force -AllowClobber -ErrorAction Stop 
Install-Module Az.ConnectedKubernetes -Repository PSGallery -Force -AllowClobber -ErrorAction Stop  
```

## Step 2: configure your Azure environment

Provide details of your Azure subscription in the [**aksedge-config.json**](https://github.com/Azure/AKS-Edge/blob/main/tools/aksedge-config.json) file under the `Arc` section as described in the following table. To successfully connect to Azure using Azure Arc-enabled kubernetes, you need a service principal with the built-in `Microsoft.Kubernetes connected cluster role` in order to access resources on Azure. If you already have the service principal ID and password, you can update all the fields in the **aksedge-config.json** file. If you need to create a service principal, you can [follow the steps here](/en-us/azure/aks/hybrid/system-requirements?tabs=allow-table#optional-create-a-new-service-principal).

Important

Client secrets are a form of password. Proper management is critical to the security of your environment.

- When you create the client secret, set a very short expiration time, based on the registration timing and scope for your deployment.
- Be sure to protect the client secret value and the configuration file from general access.
- Consider that if a cluster's configuration file is backed up while it has the client secret stored, the client secret is available to anyone with access to the backup.
- Once you register a cluster, remove the client secret from the configuration file for that cluster.
- Once you register all clusters in scope for your task, you should rotate the client secret and/or delete the service principal from your Microsoft Entra ID environment.

| Attribute | Value type | Description |
| --- | --- | --- |
| `ClusterName` | string | The name of your cluster. The default value is `hostname_cluster`. |
| `Location` | string | The location of your resource group. Choose the location closest to your deployment. |
| `SubscriptionId` | GUID | Your subscription ID. In the Azure portal, select the subscription you're using and copy/paste the subscription ID string into the JSON. |
| `TenantId` | GUID | Your tenant ID. In the Azure portal, search **Microsoft Entra ID**, which should take you to the **Default Directory** page. From here, you can copy/paste the tenant ID string into the JSON. |
| `ResourceGroupName` | string | The name of the Azure resource group to host your Azure resources for AKS Edge Essentials. You can use an existing resource group, or if you add a new name, the system creates one for you. |
| `ClientId` | GUID | Provide the application ID of the Azure service principal to use as credentials. AKS Edge Essentials uses this service principal to connect your cluster to Arc. You can use the **App Registrations** page in the Microsoft Entra resource page on the Azure portal to list and manage the service principals in a tenant. Be aware that the service principal requires the **Kubernetes Cluster - Azure Arc Onboarding** role at either the subscription or resource group level. For more information, see [Microsoft Entra identity requirements for service principals](/en-us/azure/azure-arc/kubernetes/system-requirements#microsoft-entra-identity-requirements). |
| `ClientSecret` | string | The password for the service principal. |

Note

You only need to perform this configuration once per Azure subscription. You don't need to repeat the procedure for each Kubernetes cluster.

## Step 3: connect your cluster to Arc

Run `Connect-AksEdgeArc` to install and connect the existing cluster to Arc-enabled Kubernetes:

```powershell
# Connect Arc-enabled kubernetes
Connect-AksEdgeArc -JsonConfigFilePath .\aksedge-config.json
```

Note

This step can take up to 10 minutes and PowerShell might become stuck on **Establishing Azure Connected Kubernetes for `your cluster name`**. PowerShell outputs `True` and returns to the prompt when the process is complete.

[![Screenshot showing PowerShell prompt while connecting to Arc.](../media/aks-edge/aks-edge-ps-arc-connection.png)](../media/aks-edge/aks-edge-ps-arc-connection.png#lightbox)

## Step 4: view AKS Edge Essentials resources in Azure

1. Once the process is complete, you can view your cluster in the Azure portal if you navigate to your resource group:

    [![Screenshot showing the cluster in the Azure portal.](../media/aks-edge/cluster-in-az-portal.png)](../media/aks-edge/cluster-in-az-portal.png#lightbox)
2. On the left panel, select the **Namespaces** option, under **Kubernetes resources (preview)**:

    [![Kubernetes resources preview.](../media/aks-edge/kubernetes-resources-preview.png)](../media/aks-edge/kubernetes-resources-preview.png#lightbox)
3. To view your Kubernetes resources, you need a bearer token.

    [![Screenshot showing the bearer token required page.](../media/aks-edge/bearer-token-required.png)](../media/aks-edge/bearer-token-required.png#lightbox)
4. You can also run `Get-AksEdgeManagedServiceToken` to retrieve your service token.

    [![Screenshot showing where to paste token in portal.](../media/aks-edge/bearer-token-in-portal.png)](../media/aks-edge/bearer-token-in-portal.png#lightbox)
5. Now you can view resources on your cluster. The **Workloads** option shows the pods running in your cluster.

    ```powershell
    kubectl get pods --all-namespaces
    ```

    [![Screenshot showing all pods in Arc.](../media/aks-edge/all-pods-in-arc.png)](../media/aks-edge/all-pods-in-arc.png#lightbox)

## Disconnect from Arc

Run `Disconnect-AksEdgeArc` to disconnect from the Arc-enabled Kubernetes.

```powershell
# Disconnect Arc-enabled kubernetes
Disconnect-AksEdgeArc -JsonConfigFilePath .\aksedge-config.json
```