---
layout: Conceptual
title: Connect an Azure Kubernetes Service cluster to Azure Arc in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/connect-to-arc
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
description: Connect an Azure Kubernetes Service (AKS) cluster to Kubernetes.
author: davidsmatlak
ms.topic: how-to
ms.custom: windows-server - devx-track-azurepowershell
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
locale: en-us
document_id: 4d3c6b7f-b88f-855c-861d-d9b321fef8ef
document_version_independent_id: a138757f-6c4e-0c9a-25d8-43428bb1d6d2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/connect-to-arc.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/connect-to-arc
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/connect-to-arc.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: f89ba80a-72f0-aaee-b05d-fb52ae18f63d
---

# Connect an Azure Kubernetes Service cluster to Azure Arc in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

When an Azure Kubernetes Service (AKS) cluster is attached to Azure Arc, it gets an Azure Resource Manager representation. Clusters are attached to standard Azure subscriptions, are located in a resource group, and can receive tags just like any other Azure resource. Also the Kubernetes representation allows you to extend the following capabilities onto your Kubernetes cluster:

- Management services: configurations (GitOps), Azure Monitor for containers, Azure Policy (Gatekeeper).
- Data services: SQL Managed Instance, PostgreSQL Hyperscale.
- Application services: App Service, Functions, Event Grid, Logic Apps, API Management.

To connect a Kubernetes cluster to Azure, the cluster administrator must deploy agents. These agents run in a Kubernetes namespace named **azure-arc** and are standard Kubernetes deployments. The agents are responsible for connectivity to Azure, collecting Azure Arc logs and metrics, and enabling the previously mentioned scenarios on the cluster.

AKS supports industry-standard SSL to secure data in transit. Also, data is stored encrypted at rest in an Azure Cosmos DB database to ensure data confidentiality.

The following steps describe how to connect AKS clusters to Azure Arc in AKS on Windows Server. You can skip these steps if you already connected your Kubernetes cluster to Azure Arc using Windows Admin Center.

## Before you begin

Verify that you have the following requirements:

- An [AKS cluster](kubernetes-walkthrough-powershell) with at least one Linux worker node that's up and running.
- Install the [AksHci PowerShell module](kubernetes-walkthrough-powershell#install-the-akshci-powershell-module).
- The following access level on your Azure subscription:
    - A user account with the built-in **Owner** role. You can check your access level by navigating to your subscription, selecting "Access control (IAM)" on the left hand side of the Azure portal, and then clicking on **View my access**.
    - A service principal with the built-in **[Owner](/en-us/azure/role-based-access-control/built-in-roles#owner)** role.
- Run the commands in this article in a PowerShell administrative window.
- Ensure that you meet the [network requirements of AKS](/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster?tabs=azure-cli#meet-network-requirements).

## Step 1: Sign in to Azure

To sign in to Azure, run the [Connect-AzAccount](/en-us/powershell/module/az.accounts/connect-azaccount) PowerShell command:

```powershell
Connect-AzAccount $tenantId
```

If you want to switch to a different subscription, run the [Set-AzContext](/en-us/powershell/module/az.accounts/set-azcontext) PowerShell command:

```powershell
Set-AzContext -Subscription $subscriptionId
```

## Step 2: Register the two providers for AKS

You can skip this step if you already registered the two providers for AKS on your subscription. Registration is an asynchronous process and needs to occur once per subscription. Registration can take approximately 10 minutes:

```powershell
Register-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
Register-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration
Register-AzResourceProvider -ProviderNamespace Microsoft.ExtendedLocation
```

You can check that you're registered with the following commands:

```powershell
Get-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
Get-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration
Get-AzResourceProvider -ProviderNamespace Microsoft.ExtendedLocation
```

## Step 3: Connect to Azure Arc using the Aks-Hci PowerShell module

Connect your AKS cluster to Kubernetes using the [Enable-AksHciArcConnection](/en-us/azure/aks/aksarc/reference/ps/enable-akshciarcconnection) PowerShell command. This step deploys Azure Arc agents for Kubernetes into the `azure-arc` namespace:

```powershell
Enable-AksHciArcConnection -name $clusterName
```

## Connect your AKS cluster to Azure Arc using a service principal

If you don't have access to a subscription on which you're an Owner, you can connect your AKS cluster to Azure Arc using a *service principal*.

The first command prompts for service principal credentials and stores them in the `$Credential` variable. When prompted, enter your application ID for the username and then use the service principal secret as the password. Make sure you get these values from your subscription admin. The second command connects your cluster to Azure Arc using the service principal credentials stored in the `$Credential` variable:

```powershell
$Credential = Get-Credential
Enable-AksHciArcConnection -name $clusterName -subscriptionId $subscriptionId -resourceGroup $resourceGroup -credential $Credential -tenantId $tenantId -location $location
```

Make sure the service principal used in this command has the Owner role assigned to it and that it has scope over the subscription ID used in the command. For more information about service principals, see [Create a service principal with Azure PowerShell](/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-5.9.0&amp;preserve-view=true#create-a-service-principal).

## Connect your AKS cluster to Azure Arc and enable custom locations

If you want to enable custom locations on your cluster along with Azure Arc, run the following command to get the object ID of the custom location application, and then connect to Azure Arc using a service principal:

```powershell
$objectID = (Get-AzADServicePrincipal -ApplicationId "00001111-aaaa-2222-bbbb-3333cccc4444").Id
Enable-AksHciArcConnection -name $clusterName -subscriptionId $subscriptionId -resourceGroup $resourceGroup -credential $Credential -tenantId $tenantId -location -customLocationsOid $objectID
```

## Verify the connected cluster

You can view your Kubernetes cluster resource on the [Azure portal](https://portal.azure.com/). Once you open the portal in your browser, navigate to the resource group and the AKS resource that's based on the resource name and resource group name inputs used in the [enable-akshciarcconnection](/en-us/azure/aks/aksarc/reference/ps/enable-akshciarcconnection) PowerShell command.

Note

After you connect the cluster, it can take a maximum of approximately five to ten minutes for the cluster metadata (cluster version, agent version, number of nodes) to surface on the overview page of the AKS resource in the Azure portal.

## Azure Arc agents for Kubernetes

AKS deploys a few operators into the `azure-arc` namespace. You can view these deployments and pods with `kubectl`, as shown in the following example:

```console
kubectl -n azure-arc get deployments,pods
```

AKS consists of a few agents (operators) that run in your cluster deployed to the `azure-arc` namespace. For more information about these agents, [see this overview](/en-us/azure/azure-arc/kubernetes/conceptual-agent-overview).

## Disconnect your AKS cluster from Azure Arc

If you want to disconnect your cluster from AKS, run the [Disable-AksHciArcConnection](/en-us/azure/aks/aksarc/reference/ps/disable-akshciarcconnection) PowerShell command. Make sure you sign in to Azure before running the command:

```powershell
Disable-AksHciArcConnection -Name $clusterName
```