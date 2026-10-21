---
layout: Conceptual
title: Use Windows node pools | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/howto-enable-windows-node-pools
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
description: Learn how to enable the Windows node pool feature in AKS on Azure Local.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.lastreviewed: 2025-09-24T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: f0620947-4d75-8810-5bbc-9202383c004b
document_version_independent_id: 73eab87d-141e-0a51-c32a-51e803c55d0e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/howto-enable-windows-node-pools.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/howto-enable-windows-node-pools
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/howto-enable-windows-node-pools.md
platformId: 7b473ea2-0460-b908-38e6-4bd0715afbd7
---

# Use Windows node pools | Microsoft Learn

&gt; Applies to: AKS on Azure Local release 2509 or later.

Virtual hard disks (VHDs) serve as the base operating system images for the Kubernetes nodes within your AKS cluster. Starting with Azure Local version 2509, only the Azure Linux VHDs are downloaded by default on the Azure Local instance. The Azure Linux VHDs are used to create the default Linux node pool on the AKS cluster. For Windows-based workloads, AKS supports Windows Server 2019 and Windows Server 2022 images that you can use to create corresponding Windows node pools; however, these VHDs are not available by default and must be downloaded before you can create your Windows-based node pools. Having the Windows node pool feature disabled by default ensures that the Windows-based OS images are not downloaded unnecessarily, and helps to save bandwidth and storage space.

Important

With the Windows node pool feature disabled by default in Azure Local release 2509 and later, if you have a Windows node pool and you attempt to issue commands like `aksarc upgrade`, `aksarc update`, `aksarc nodepool update`, or `aksarc nodepool add`, they fail with an error message stating that "The Windows node pool feature is disabled." You are then explicitly asked to enable this feature before you proceed with these operations.

## Prerequisites

Before you begin creating Windows node pools, make sure you have the following prerequisites in place:

- **Azure Local deployed**. This article applies only if you deployed Azure Local release 2509 or later. Windows VHDs are disabled by default starting in release 2509. If you are on an earlier release, you can proceed to [create a Windows node pool](howto-create-windows-node-pools).
- **Azure RBAC permissions to update Azure Local configuration**. Make sure you have the following roles. For more information, see [required permissions for deployment](/en-us/azure/azure-local/deploy/deployment-arc-register-server-permissions?tabs=powershell#assign-required-permissions-for-deployment):
    - Azure Local Administrator
    - Reader
- **Custom Location**. Name of the custom location. The custom location is configured during the Azure Local deployment. If you're in the Azure portal, go to the **Overview** page of the Azure Local system resource. In the **Essentials** section, you should see the custom location name for your cluster.
- **Azure resource group**. The Azure resource group in which Azure Local is deployed.
- Access to at least one node on the Azure Local instance, either directly or via remote PowerShell.

### gMSA authentication isn't supported for Windows node pools on Azure Local 23H2 and 24H2

[Group Managed Service Account (gMSA)](/en-us/windows-server/identity/ad-ds/manage/group-managed-service-accounts/group-managed-service-accounts/group-managed-service-accounts-overview) authentication for Windows node pools isn't supported on AKS on Azure Local 23H2 and 24H2 or Windows node pools that require gMSA-based authentication for Active Directory access.

The gMSA components are preinstalled on Windows node pools, but the configuration path to set up gMSA authentication isn't available through CLI commands, APIs, or other management tools. Customers who follow standard Kubernetes documentation for Windows containers and create a credential spec receive anonymous sign-in failures because the required `HostAccountConfig` configuration isn't supported.

For example, after deploying a Windows container workload that requires gMSA-based authentication (Kerberos or NTLM), pods fail to authenticate against Active Directory. Applications receive `NT AUTHORITY\ANONYMOUS LOGON` errors for all Kerberos and NTLM authentication calls from the container.

An option to resolve this limitation is to move workloads to a platform that supports gMSA for Windows nodes, like Azure Kubernetes Service (AKS). For more information, see how to [enable gMSA for Windows Server nodes on an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/use-group-managed-service-accounts).

## Enable the Windows node pool feature on AKS clusters

To enable the Windows node pool feature on your AKS cluster, use the **Support.AksArc** PowerShell module. This module provides tools for diagnostics and remediation in AKS environments. By running its commands, you can activate the Windows node pool feature and initiate the download of the required Windows VHDs, making it possible to create Windows-based node pools.

### Step 1: Connect to an Azure Local node

Follow these steps on your client machine to connect to one of the Azure Local nodes.

1. Run PowerShell as administrator on the client that you're using to connect to your system.
2. Open a remote PowerShell session to a machine on your Azure Local instance. Run the following command and provide the credentials of your machine when prompted:

    ```powershell
    $cred = Get-Credential
    Enter-PSSession -ComputerName "<Computer IP>" -Credential $cred 
    ```

    Note

    Sign in using your deployment user account credentials. This is the account you created when preparing [Active Directory](/en-us/azure/azure-local/deploy/deployment-prep-active-directory), and used to deploy Azure Local.

Expand this section to see an example output.

The following is example output:

    ```output
    cmdlet Get-Credential at command pipeline position 1
    Supply values for the following parameters:
    Credential
    ```

    ```powershell
    Enter-PSSession -ComputerName "100.100.100.10" -Credential $cred
    ```

    ```output
    [100.100.100.10]: PS C:\Users\Administrator\Documents>
    ```

### Step 2: Enable the Windows node pool feature on your cluster

In the remote PowerShell session, sign in to Azure, to the subscription where the Azure Local instance resides:

```azurecli
az login --use-device-code --tenant <Azure tenant ID>
az account set -s <subscription ID>
```

Install the **Support.AksArc** module using the following command:

```powershell
Install-Module -Name Support.AksArc
Import-Module Support.AksArc -Force
```

You can then run the following command to enable the Windows node pool feature and download the Windows-related VHDs:

```powershell
Invoke-SupportAksArcRemediation_EnableWindowsNodepool -Verbose
```

This enables the Windows node pool feature and begins the download of the Windows VHDs. This can take some time, depending on the network bandwidth available on your Azure Local instance.

### Step 3: Check if the Windows VHDs are ready

Run the following command to check if the Windows VHDs are downloaded and ready for use:

```azurecli
$customlocationName = <The custom location name for Azure Local>
$resourceGroup = <The Azure resource group in which Azure Local is deployed>

az aksarc get-versions --resource-group $resourceGroup --custom-location $customlocationName
```

For the Kubernetes version you intend to use, find the right Windows SKU by looking for `osType=Windows` and the `osSKU` fields and ensure that the `ready` state is **true**.

```output
...
         "1.29.4": { 
            "readiness": [ 
              { 
                "errorMessage": null, 
                "osSku": "CBLMariner", 
                "osType": "Linux", 
                "ready": true 
              }, 
              { 
                "errorMessage": null, 
                "osSku": "Windows2019", 
                "osType": "Windows", 
                "ready": true 
              }, 
              { 
                "errorMessage": null, 
                "osSku": "Windows2022", 
                "osType": "Windows", 
                "ready": true 
              } 
            ], 
            "upgrades": null 
          } 
...
```

Once the VHDs show `ready` as **true**, you can proceed to [create a Windows node pool](howto-create-windows-node-pools), and deploy your Windows-based workloads.

## Disable the Windows node pool feature on AKS clusters

If you no longer need to use Windows node pools on your AKS cluster, you can disable the Windows node pool feature. Disabling this feature removes the Windows VHDs from your Azure Local instance, and prevents any further operations on Windows node pools. If you have existing Windows node pools, you must delete them before you can disable this feature.

### Step 1: Delete existing Windows node pools

If you intend to disable the Windows node pool feature on your cluster, it's recommended that you delete any Windows node pool that you already have. You can delete your Windows node pools either from the Azure portal or using the CLI, as follows:

```azurecli
az aksarc nodepool delete --name "<nodepool-name>" --cluster-name "<cluster-name>" --resource-group $resourceGroup 
```

### Step 2: Disable the Windows node pool feature on your cluster

To disable the Windows node pool feature, you must access an Azure Local node. First, Connect to the Azure Local node.

In the remote PowerShell session, sign in to Azure, to the subscription where the Azure Local instance resides.

```azurecli
az login --use-device-code --tenant <Azure tenant ID>
az account set -s <subscription ID>
```

Install the **Support.AksArc** module using the following command:

```powershell
Install-Module -Name Support.AksArc
Import-Module Support.AksArc -Force
```

You can then run the following command to disable the Windows node pool feature and delete the Windows-related VHDs from your Azure Local instance.

```powershell
Invoke-SupportAksArcRemediation_DisableWindowsNodepool -Verbose
```

This command disables the Windows node pool feature and deletes the existing Windows VHDs.

### Step 3: Verify that the Windows VHDs are no longer available

Next, check if the Windows node pools were disabled by running the following command. You can see that the `errorMessage` parameter shows that the Windows node pool feature is disabled and the `ready` parameter shows as **false**, for each of the Kubernetes versions:

```azurecli
az aksarc get-versions --resource-group $resourceGroup --custom-location $customlocationName
```

```output
...
     - patchVersion: 1.29.4 
          readiness: 
          - osSku: CBLMariner 
            osType: Linux 
            ready: true 
          - errorMessage: Windows nodepool feature is disabled 
            isDisabled: true 
            osSku: Windows2019 
            osType: Windows 
            ready: false 
          - errorMessage: Windows nodepool feature is disabled 
            isDisabled: true 
            osSku: Windows2022 
            osType: Windows 
            ready: false 
....
```

You can verify if Windows VHDs were removed from the Azure Local storage paths. Deletion can take a while, so wait about 30 minutes before checking. You must check all the storage paths, because Windows VHDs are assigned to storage paths in round-robin fashion, based on available storage capacity.