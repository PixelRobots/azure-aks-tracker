---
layout: Conceptual
title: Use PowerShell to set up Kubernetes on Windows Server clusters | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/kubernetes-walkthrough-powershell
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
description: Learn how to set up an AKS host and create Kubernetes clusters using Windows PowerShell.
author: davidsmatlak
ms.topic: quickstart
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-05-02T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server - mode-api - kr2b-contr-experiment - devx-track-azurepowershell
locale: en-us
document_id: 0ec43449-e2f7-a5eb-cf53-f14c9334bb58
document_version_independent_id: 42dddddc-52c1-4ddf-7944-f2255a396fbf
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/kubernetes-walkthrough-powershell.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/kubernetes-walkthrough-powershell
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/kubernetes-walkthrough-powershell.md
platformId: 7320ea7f-0af8-e853-772b-bfef603d23be
---

# Use PowerShell to set up Kubernetes on Windows Server clusters | Microsoft Learn

> 
> Applies to: Windows Server Datacenter

This quickstart guides you through setting up an Azure Kubernetes Service (AKS) host. You create Kubernetes clusters on Windows Server using PowerShell. To use Windows Admin Center instead, see [Set up with Windows Admin Center](setup).

Note

- If you pre-staged cluster service objects and DNS records, see [Deploy an AKS host with prestaged cluster service objects and DNS records using PowerShell](prestage-cluster-service-host-create).
- If you have a proxy server, see [Set up an AKS host and deploy a workload cluster using PowerShell and a proxy server](set-proxy-settings).

## Before you begin

- Make sure you satisfy all the prerequisites in [system requirements](system-requirements).
- Use an Azure account to register your AKS host for billing. For more information, see [Azure requirements](system-requirements#azure-requirements).

## Install the AksHci PowerShell module

Follow these steps on all nodes in your Windows Server cluster:

Note

If you are using remote PowerShell, you must use CredSSP.

1. Close all open PowerShell windows, open a new PowerShell session as administrator, and run the following command on all nodes in your Windows Server cluster:

    ```powershell
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name PowershellGet -Force -Confirm:$false
    ```

    You must close all existing PowerShell windows again to ensure that loaded modules are refreshed. Don't continue to the next step until you close all open PowerShell windows.
2. Install the **AksHci** PowerShell module by running the following command on all nodes in your Windows Server cluster:

    ```powershell
    Install-Module -Name AksHci -Repository PSGallery -Force -AcceptLicense
    ```

    You must close all existing PowerShell windows again to ensure that loaded modules are refreshed. Don't continue to the next step until you close all open PowerShell windows.

You can use a [helper script to delete old AKS-HCI PowerShell modules](https://github.com/Azure/aksArc/issues/130), to avoid any PowerShell version-related issues in your AKS deployment.

### Validate your installation

```powershell
Get-Command -Module AksHci
```

For the complete list of **AksHci** PowerShell commands, see [AksHci PowerShell](/en-us/azure/aks/aksarc/reference/ps/index).

## Register the resource provider to your subscription

Before the registration process, enable the appropriate resource provider in Azure for the AKS registration. To do so, run the following PowerShell commands:

To sign in to Azure, run the [Connect-AzAccount](/en-us/powershell/module/az.accounts/connect-azaccount) PowerShell command:

```powershell
Connect-AzAccount
```

If you want to switch to a different subscription, run the [Set-AzContext](/en-us/powershell/module/az.accounts/set-azcontext?view=azps-5.9.0&amp;preserve-view=true) PowerShell command:

```powershell
Set-AzContext -Subscription "xxxx-xxxx-xxxx-xxxx"
```

Run the following commands to register your Azure subscription to Azure Arc-enabled Kubernetes resource providers. This registration process can take up to 10 minutes, but it only needs to be performed once on a specific subscription:

```powershell
Register-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
Register-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration
Register-AzResourceProvider -ProviderNamespace Microsoft.ExtendedLocation
```

To validate the registration process, run the following PowerShell commands:

```powershell
Get-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
Get-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration
Get-AzResourceProvider -ProviderNamespace Microsoft.ExtendedLocation
```

## Step 1: prepare your machine(s) for deployment

Run checks on every physical node to see if all the requirements to install AKS are satisfied. Open PowerShell as an administrator and run the following [Initialize-AksHciNode](/en-us/azure/aks/aksarc/reference/ps/initialize-akshcinode) command on all nodes in your Windows Server cluster:

```powershell
Initialize-AksHciNode
```

## Step 2: create a virtual network

Run the following commands on any one node in your Windows Server cluster.

To get the names of your available switches, run the following command. Make sure the `SwitchType` of your VM switch is **External**:

```powershell
Get-VMSwitch
```

Sample output:

```output
Name        SwitchType     NetAdapterInterfaceDescription
----        ----------     ------------------------------
extSwitch   External       Mellanox ConnectX-3 Pro Ethernet Adapter
```

To create a virtual network for the nodes in your deployment to use, create an environment variable with the [New-AksHciNetworkSetting](/en-us/azure/aks/aksarc/reference/ps/new-akshcinetworksetting) PowerShell command. This virtual network is used later to configure a deployment that uses static IP. If you want to configure your AKS deployment with DHCP, see [New-AksHciNetworkSetting](/en-us/azure/aks/aksarc/reference/ps/new-akshcinetworksetting) for examples. You can also review some [networking node concepts](concepts-node-networking).

```powershell
# static IP
$vnet = New-AksHciNetworkSetting -name myvnet -vSwitchName "extSwitch" -k8sNodeIpPoolStart "172.16.10.1" -k8sNodeIpPoolEnd "172.16.10.255" -vipPoolStart "172.16.255.0" -vipPoolEnd "172.16.255.254" -ipAddressPrefix "172.16.0.0/16" -gateway "172.16.0.1" -dnsServers "172.16.0.1" -vlanId 9
```

Note

You must customize the values shown in this example command for your environment.

## Step 3: configure your deployment

Run the following commands on any node in your Windows Server cluster.

To create the configuration settings for the AKS host, use the [Set-AksHciConfig](/en-us/azure/aks/aksarc/reference/ps/set-akshciconfig) command. You must specify the `imageDir`, `workingDir`, and `cloudConfigLocation` parameters. If you want to reset your configuration details, run the command again with new parameters.

Configure your deployment with the following command:

```powershell
$csvPath = 'C:\clusterstorage\volume01' # Specify your preferred CSV path
Set-AksHciConfig -imageDir $csvPath\Images -workingDir $csvPath\ImageStore -cloudConfigLocation $csvPath\Config -vnet $vnet
```

Note

You must customize the values shown in this example command for your environment, but you can't change the VM name on the host or on the Kubernetes cluster.

## Step 4: sign in to Azure and configure registration settings

### Option 1: use your Microsoft Entra account if you have "Owner" permissions

Run the following [Set-AksHciRegistration](/en-us/azure-stack/aks-hci/reference/ps/set-akshciregistration) PowerShell command with your subscription and resource group name to sign in to Azure. You must have an Azure subscription, and an existing Azure resource group in the Australia East, East US, Southeast Asia, or West Europe Azure regions:

```powershell
Set-AksHciRegistration -subscriptionId "<subscriptionId>" -resourceGroupName "<resourceGroupName>"
```

### Option 2: use an Azure service principal

If you don't have access to a subscription on which you're an **Owner**, you can register your AKS host to Azure for billing using a service principal. For more information about how to use a service principal, see [register AKS on Windows Server using a service principal](/en-us/azure/aks/aksarc/reference/ps/set-akshciregistration#register-aks-hybrid-using-a-service-principal).

## Step 5: start a new deployment

Run the following command on any node in your Windows Server cluster.

After you configure your deployment, you must start it in order to install the AKS agents and services, and the AKS host. To begin deployment, run the following command:

Tip

To see additional status details during installation, set `$VerbosePreference = "Continue"` before proceeding.

```powershell
Install-AksHci
```

Warning

During installation of your AKS host, a **Kubernetes - Azure Arc** resource type is created in the resource group that's set during registration. Do not delete this resource, as it represents your AKS host. You can identify the resource by checking its distribution field for a value of `aks_management`. If you delete this resource, it results in an out-of-policy deployment.

## Step 6: create a Kubernetes cluster

After you install your AKS host, you can deploy a Kubernetes cluster. Open PowerShell as an administrator and run the following [New-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/new-akshcicluster) command. This example command creates a new Kubernetes cluster with one Linux node pool named `linuxnodepool` with a node count of 1.

For more information about node pools, see [Use node pools in AKS](/en-us/azure/aks/aksarc/use-node-pools).

```powershell
New-AksHciCluster -name mycluster -nodePoolName linuxnodepool -nodeCount 1 -osType Linux
```

### Check your deployed clusters

To get a list of your deployed Kubernetes clusters, run the following [Get-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/get-akshcicluster) PowerShell command:

```powershell
Get-AksHciCluster
```

```output
ProvisioningState     : provisioned
KubernetesVersion     : v1.20.7
NodePools             : linuxnodepool
WindowsNodeCount      : 0
LinuxNodeCount        : 0
ControlPlaneNodeCount : 1
Name                  : mycluster
```

To get a list of the node pools in the cluster, run the following [Get-AksHciNodePool](/en-us/azure/aks/aksarc/reference/ps/get-akshcinodepool) PowerShell command:

```powershell
Get-AksHciNodePool -clusterName mycluster
```

```output
ClusterName  : mycluster
NodePoolName : linuxnodepool
Version      : v1.20.7
OsType       : Linux
NodeCount    : 1
VmSize       : Standard_K8S3_v1
Phase        : Deployed
```

## Step 7: connect your cluster to Arc-enabled Kubernetes

Connect your cluster to Arc-enabled Kubernetes by running the [Enable-AksHciArcConnection](/en-us/azure/aks/aksarc/reference/ps/enable-akshciarcconnection) command. The following example connects your Kubernetes cluster to Arc using the subscription and resource group details you passed in the `Set-AksHciRegistration` command:

```powershell
Connect-AzAccount
Enable-AksHciArcConnection -name mycluster
```

Note

If you encounter issues or error messages during the installation process, see [Installation known issues and errors](/en-us/azure/aks/aksarc/known-issues-installation) for more information.

## Scale a Kubernetes cluster

If you need to scale your cluster up or down, you can change the number of control plane nodes by using the [Set-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/set-akshcicluster) command. To change the number of Linux or Windows worker nodes in your node pool, use the [Set-AksHciNodePool](/en-us/azure/aks/aksarc/reference/ps/set-akshcinodepool) command.

To scale control plane nodes, run the following command:

```powershell
Set-AksHciCluster -name mycluster -controlPlaneNodeCount 3
```

To scale the worker nodes in your node pool, run the following command:

```powershell
Set-AksHciNodePool -clusterName mycluster -name linuxnodepool -count 3
```

Note

In previous versions of AKS on Windows Server, the [Set-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/set-akshcicluster) command was also used to scale worker nodes. Now that AKS is introducing node pools in workload clusters, you can only use this command to scale worker nodes if your cluster was created with the old parameter set in [New-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/new-akshcicluster).

To scale worker nodes in a nodepool, use the [Set-AksHciNodePool](/en-us/azure/aks/aksarc/reference/ps/set-akshcinodepool) command.

## Access your clusters using kubectl

To access your Kubernetes clusters using **kubectl**, run the [Get-AksHciCredential](/en-us/azure/aks/aksarc/reference/ps/get-akshcicredential) PowerShell command. This command uses the specified cluster's **kubeconfig** file as the default **kubeconfig** file for **kubectl**. You can also use **kubectl** to [deploy applications using Helm](helm-deploy):

```powershell
Get-AksHciCredential -name mycluster
```

## Delete a Kubernetes cluster

To delete a Kubernetes cluster, run the following command:

```powershell
Remove-AksHciCluster -name mycluster
```

Note

Make sure that your cluster is deleted by looking at the existing VMs in Hyper-V Manager. If they aren't deleted, you can manually delete the VMs. Then, run the command `Restart-Service wssdagent`. Run this command on each node in the failover cluster.

## Get logs

To get logs from your all your pods, run the [Get-AksHciLogs](/en-us/azure/aks/aksarc/reference/ps/get-akshcilogs) command. This command creates an output zipped folder called `akshcilogs.zip` in your working directory. The full path to the `akshcilogs.zip` folder is the output after running the following command:

```powershell
Get-AksHciLogs
```

In this quickstart, you learned how to set up an AKS host and create Kubernetes clusters using PowerShell. You also learned how to use PowerShell to scale a Kubernetes cluster and to access clusters with **kubectl**.