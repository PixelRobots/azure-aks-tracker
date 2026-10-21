---
layout: Conceptual
title: Troubleshoot the VMExtensionError_OutboundConnFail error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/vmextensionerror-outboundconnfail
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
description: Fix the VMExtensionError_OutboundConnFail error in AKS. Learn to diagnose and resolve outbound connectivity failures when creating or starting an AKS cluster.
ms.date: 2026-07-01T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, v-leedennis, jovieir
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 19d9615d-d7c0-2c09-a25d-f6d4c4fa90e7
document_version_independent_id: 19d9615d-d7c0-2c09-a25d-f6d4c4fa90e7
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/vmextensionerror-outboundconnfail.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/vmextensionerror-outboundconnfail
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/vmextensionerror-outboundconnfail.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: dfb36244-dbde-d075-b04f-f490a5740447
---

# Troubleshoot the VMExtensionError_OutboundConnFail error code - Azure | Microsoft Learn

## Summary

This article describes how to identify and resolve the `VMExtensionError_OutboundConnFail` error (also known as the `ERR_OUTBOUND_CONN_FAIL` message, error number 50) that might occur if you try to start or create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- The [Netcat](https://linuxcommandlibrary.com/man/netcat) (nc) command-line tool
- The [dig](https://linux.die.net/man/1/dig) command-line tool
- The Client URL ([cURL](https://curl.se/download.html)) tool

## Symptoms

When you try to start or create an AKS cluster, you receive the following error message:

> 
> Unable to establish outbound connection from agents, please see https://aka.ms/aks-required-ports-and-addresses for more information.
> 
> Code: "VMExtensionProvisioningError"
> 
> Message: CSE failed with 'VMExtensionError\_OutboundConnFail'. AKS Node provisioning failed due to inability to establish outbound connectivity to obtain packages with exit status 50. Please refer to https://aka.ms/aks/outbound-rules-control-egress and https://aka.ms/aks/vmextensionerror_outboundconnfail for troubleshooting.
> 
> "In some logs, this may also appear as exit status=50 / ExitCode: 50"

## Cause

The custom script extension that downloads the necessary components to provision the nodes couldn't establish the necessary outbound connectivity to obtain packages. For public clusters, the nodes try to communicate with the Microsoft Container Registry (MCR) endpoint (`mcr.microsoft.com`) on port 443.

There are many reasons why the traffic might be blocked. In any of these situations, the best way to test connectivity is to use the Secure Shell protocol (SSH) to connect to the node. To make the connection, follow the instructions in [Connect to Azure Kubernetes Service (AKS) cluster nodes for maintenance or troubleshooting](/en-us/azure/aks/node-access). Then, test the connectivity on the cluster by following these steps:

1. After you connect to the node, run the `nc` and `dig` commands:

    ```bash
    nc -vz mcr.microsoft.com 443 
    dig mcr.microsoft.com 443
    ```

    Note

    If you can't access the node through SSH, you can test the outbound connectivity by running the [az vmss run-command invoke](/en-us/cli/azure/vmss/run-command#az-vmss-run-command-invoke) command against the Virtual Machine Scale Set instance:

    ```azurecli
    # Get the VMSS instance IDs.
    az vmss list-instances --resource-group <mc-resource-group-name> \
        --name <vmss-name> \
        --output table
    
    # Use an instance ID to test outbound connectivity.
    az vmss run-command invoke --resource-group <mc-resource-group-name> \
        --name <vmss-name> \
        --command-id RunShellScript \
        --instance-id <vmss-instance-id> \
        --output json \
        --scripts "nc -vz mcr.microsoft.com 443"
    ```
2. If you try to create an AKS cluster by using an HTTP proxy, run the `nc`, `curl`, and `dig` commands after you connect to the node:

    ```bash
    # Test connectivity to the HTTP proxy server from the AKS node.
    nc -vz <http-s-proxy-address> <port>
    
    # Test traffic from the HTTP proxy server to HTTPS.
    curl --proxy http://<http-proxy-address>:<port>/ --head https://mcr.microsoft.com
    
    # Test traffic from the HTTPS proxy server to HTTPS.
    curl --proxy https://<https-proxy-address>:<port>/ --head https://mcr.microsoft.com
    
    # Test DNS functionality.
    dig mcr.microsoft.com 443
    ```

    Note

    If you can't access the node through SSH, you can test the outbound connectivity by running the `az vmss run-command invoke` command against the Virtual Machine Scale Set instance:

    ```azurecli
    # Get the VMSS instance IDs.
    az vmss list-instances --resource-group <mc-resource-group-name> \
        --name <vmss-name> \
        --output table
    
    # Use an instance ID to test connectivity from the HTTP proxy server to HTTPS.
    az vmss run-command invoke --resource-group <mc-resource-group-name> \
        --name <vmss-name> \
        --command-id RunShellScript \
        --instance-id <vmss-instance-id> \
        --output json \
        --scripts "curl --proxy http://<http-proxy-address>:<port>/ --head https://mcr.microsoft.com"
    
    # Use an instance ID to test connectivity from the HTTPS proxy server to HTTPS.
    az vmss run-command invoke --resource-group <mc-resource-group-name> \
        --name <vmss-name> \
        --command-id RunShellScript \
        --instance-id <vmss-instance-id> \
        --output json \
        --scripts "curl --proxy https://<https-proxy-address>:<port>/ --head https://mcr.microsoft.com"
    
    # Use an instance ID to test DNS functionality.
    az vmss run-command invoke --resource-group <mc-resource-group-name> \
        --name <vmss-name> \
        --command-id RunShellScript \
        --instance-id <vmss-instance-id> \
        --output json \
        --scripts "dig mcr.microsoft.com 443"
    ```

## Solution

The following table lists specific reasons why traffic might be blocked, and the corresponding solution for each reason:

| Issue | Solution |
| --- | --- |
| Traffic is blocked by firewall rules, a proxy server or Network Security Group (NSG) | This issue occurs when the AKS required ports or Fully Qualified Domain Names (FQDNs) are blocked by a firewall, proxy server, or NSG. Ensure these ports and FQDNs are allowed. To determine what's blocked, check the connectivity provided in the preceding Cause section. For more information about AKS required ports and FQDNs, see [Outbound network and FQDN rules for Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/outbound-rules-control-egress). |
| The AAAA (IPv6) record is blocked on the firewall | On your firewall, verify that nothing exists that would block the endpoint from resolving in Azure DNS. |
| Private cluster can't resolve internal Azure resources | In private clusters, the Azure DNS IP address (`168.63.129.16`) must be added as an upstream DNS server if custom DNS is used. Verify that the address is set on your DNS servers. For more information, see [Create a private AKS cluster](/en-us/azure/aks/private-clusters) and [What is IP address 168.63.129.16?](/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16) |

## More information

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.