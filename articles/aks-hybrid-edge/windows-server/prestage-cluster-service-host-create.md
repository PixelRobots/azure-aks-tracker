---
layout: Conceptual
title: Deploy an Azure Kubernetes Service host with pre-staged cluster service objects and DNS records using PowerShell | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/prestage-cluster-service-host-create
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
description: Learn how to set up an AKS host if you pre-staged cluster service objects and DNS records.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server
locale: en-us
document_id: dcea7d90-978f-6ff7-f168-394629dfc576
document_version_independent_id: 88bb82e9-58cb-87cd-4f5a-854927e201f0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/prestage-cluster-service-host-create.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/prestage-cluster-service-host-create
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/prestage-cluster-service-host-create.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: db57c54e-642a-6867-1993-d7de33fa142c
---

# Deploy an Azure Kubernetes Service host with pre-staged cluster service objects and DNS records using PowerShell | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This how-to guide describes how to use PowerShell to configure your AKS host deployment if you pre-staged cluster service objects and DNS records in AKS on Windows Server.

## Before you begin

- Make sure you satisfy all the prerequisites in [system requirements](system-requirements).
- Download and install the [AksHci PowerShell module](kubernetes-walkthrough-powershell#install-the-akshci-powershell-module).

## Step 1: Prepare your Active Directory and DNS server for deployment

If you can't enable dynamic DNS updates in your DNS environment to allow AKS on Windows Server to register the cloud agent generic cluster name in Active Directory and the DNS system for discovery, you must pre-create the respective records in Active Directory and DNS.

Create a generic cluster service in Active Directory with the name `ca-cloudagent` (or a name of your choice that doesn't exceed 32 characters). Also, create an associated DNS record that points to the FQDN of the generic cluster service with the provided `cloudservicecidr` address. For more information about the steps in this process, see the [failover clustering documentation](/en-us/windows-server/failover-clustering/prestage-cluster-adds).

The AKS deployment attempts to locate the specified `clusterRoleName` in Active Directory before proceeding with the deployment.

Note

Once AKS is deployed, this information cannot be changed.

## Step 2: Prepare your machines for deployment

Run checks on every physical node to see if all the requirements are satisfied to install AKS. Open PowerShell as an administrator and run the following [Initialize-AksHciNode](/en-us/azure/aks/aksarc/reference/ps/initialize-akshcinode) command:

```powershell
Initialize-AksHciNode
```

## Step 3: Create a virtual network

To create a virtual network for the nodes in your deployment to use, create an environment variable with the `New-AksHciNetworkSetting` PowerShell command. This variable is used later to configure a deployment that uses static IP. If you want to configure your AKS deployment with DHCP, see [New-AksHciNetworkSetting](/en-us/azure/aks/aksarc/reference/ps/new-akshcinetworksetting) for examples. You can also review some [networking node concepts](concepts-node-networking).

```powershell
# static IP
$vnet = New-AksHciNetworkSetting -name mgmt-vnet -vSwitchName "extSwitch" -k8sNodeIpPoolStart "172.16.10.1" -k8sNodeIpPoolEnd "172.16.10.255" -vipPoolStart "172.16.255.0" -vipPoolEnd "172.16.255.254" -ipAddressPrefix "172.16.0.0/16" -gateway "172.16.0.1" -dnsServers "172.16.0.1"
```

Note

You must customize the values shown in this example command for your environment.

## Step 4: Configure your deployment with the pre-staged cluster service objects and DNS records

Set the configuration settings for the AKS host using the [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig) command. You must specify the `workingDir`, `cloudServiceCidr`, `cloudConfigLocation`, and `clusterRoleName` parameters. If you want to reset your configuration details, run the command again with new parameters.

Configure your deployment with the following command:

```powershell
Set-AksHciConfig -workingDir c:\ClusterStorage\Volume1\workingDir -cloudConfigLocation c:\clusterstorage\volume1\Config -vnet $vnet -cloudservicecidr "172.16.10.10/16" -clusterRoleName "ca-cloudagent"
```

Note

Customize the values shown in this example command for your environment.

## Step 5: Sign in to Azure and configure registration settings

Run the following [Set-AksHciRegistration](/en-us/azure/aks/aksarc/reference/ps/set-akshciregistration) PowerShell command with your subscription and resource group name to sign into Azure. You must have an Azure subscription, and an existing Azure resource group in the East US, Southeast Asia, or West Europe Azure regions to proceed:

```powershell
Set-AksHciRegistration -subscriptionId "<subscriptionId>" -resourceGroupName "<resourceGroupName>"
```

## Step 6: Start a new deployment

After you configure your deployment, you must start it. Starting the deployment installs the AKS agents/services and the AKS host. To begin the deployment, run the following command:

```powershell
Install-AksHci
```

Warning

During installation of your AKS host, a **Kubernetes - Azure Arc** resource type is created in the resource group that's set during registration. Do not delete this resource, as it represents your Azure Kubernetes Service host. You can identify the resource by checking its distribution field for the `aks_management` value. Deleting this resource results in an out-of-policy deployment.