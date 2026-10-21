---
layout: Conceptual
title: Troubleshoot the K8SAPIServerDNSLookupFailVMExtensionError error code (52) - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-k8sapiserverdnslookupfailvmextensionerror
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
description: Learn how to troubleshoot the K8SAPIServerDNSLookupFailVMExtensionError error (52) when you try to start or create and deploy an Azure Kubernetes Service (AKS) cluster.
ms.date: 2024-01-24T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, erbookbi, v-leedennis, jovieir
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool),  innovation-engine
locale: en-us
document_id: 950d51c5-ee10-135e-0b09-50ae75759d2d
document_version_independent_id: 950d51c5-ee10-135e-0b09-50ae75759d2d
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-k8sapiserverdnslookupfailvmextensionerror.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-k8sapiserverdnslookupfailvmextensionerror
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-k8sapiserverdnslookupfailvmextensionerror.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: af40085c-29cc-15b7-e9d8-c9cc0cf5f9f8
---

# Troubleshoot the K8SAPIServerDNSLookupFailVMExtensionError error code (52) - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `K8SAPIServerDNSLookupFailVMExtensionError` error (also known as error code ERR\_K8S\_API\_SERVER\_DNS\_LOOKUP\_FAIL, error number 52) that occurs when you try to start or create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- The [nslookup](/en-us/windows-server/administration/windows-commands/nslookup) DNS lookup tool for Windows nodes or the [dig](https://linuxize.com/post/how-to-use-dig-command-to-query-dns-in-linux/) tool for Linux nodes.
- [Azure CLI](/en-us/cli/azure/install-azure-cli), version 2.0.59 or a later version. If Azure CLI is already installed, you can find the version number by running `az --version`.

## Symptoms

When you try to start or create an AKS cluster, you receive the following error message:

> 
> Agents are unable to resolve Kubernetes API server name. It's likely custom DNS server is not correctly configured, please see https://aka.ms/aks/private-cluster#hub-and-spoke-with-custom-dns for more information.
> 
> Details: Code="VMExtensionProvisioningError"
> 
> Message="VM has reported a failure when processing extension 'vmssCSE'.
> 
> Error message: "**Enable failed: failed to execute command: command terminated with exit status=52**\n[stdout]\n{
> 
> "ExitCode": "52",
> 
> "Output": "Fri Oct 15 10:06:00 UTC 2021,aks- nodepool1-36696444-vmss000000\nConnection to mcr.microsoft.com 443 port [tcp/https]

## Cause

The cluster nodes can't resolve the cluster's fully qualified domain name (FQDN) in Azure DNS. Run the following DNS lookup command on the failed cluster node to find DNS resolutions that are valid.

| Node OS | Command |
| --- | --- |
| Linux | `dig <cluster-fqdn>` |
| Windows | `nslookup <cluster-fqdn>` |

## Solution

On your DNS servers and firewall, make sure that nothing blocks the resolution to your cluster's FQDN. Your custom DNS server might be incorrectly configured if something is blocking even after you run the `nslookup` or `dig` command and apply any necessary fixes. For help to configure your custom DNS server, review the following articles:

- [Create a private AKS cluster](/en-us/azure/aks/private-clusters)
- [Private Azure Kubernetes service with custom DNS server](https://github.com/Azure/terraform/tree/00d15e09c54f25fb6387330c36aa4366122c5aaa/quickstart/301-aks-private-cluster)
- [What is IP address 168.63.129.16?](/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16)

When you use a private cluster that has a custom DNS, a DNS zone is created. The DNS zone must be linked to the virtual network. This occurs after the cluster is created. Creating a private cluster that has a custom DNS fails during creation. However, you can restore the creation process to a "success" state by reconciling the cluster. To do this, run the [az resource update](/en-us/cli/azure/resource#az-resource-update) command in Azure CLI, as follows:

Below, set your AKS cluster and resource group names, then run the update command to reconcile the cluster. The environment variables will make your resource names unique and are declared just before use.

```azurecli
az resource update --resource-group $RESOURCE_GROUP_NAME \
    --name $CLUSTER_NAME \
    --namespace Microsoft.ContainerService \
    --resource-type ManagedClusters
```

Results:

```output
{
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroupxxx/providers/Microsoft.ContainerService/ManagedClusters/myAksClusterxxx",
  "location": "eastus",
  "name": "myAksClusterxxx",
  "properties": {
      // ...other properties...
  },
  "resourceGroup": "myResourceGroupxxx",
  "type": "Microsoft.ContainerService/ManagedClusters"
}
```

Also verify that your DNS server is configured correctly for your private cluster, as described earlier.

Note

Conditional Forwarding doesn't support subdomains.

## More information

- [General troubleshooting of AKS cluster creation issues](troubleshoot-aks-cluster-creation-issues)