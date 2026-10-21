---
layout: Conceptual
title: OrasPullNetworkTimeoutVMExtensionError When Creating AKS Clusters - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/vmextensionerror-oraspullnetworktimeout
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
description: Troubleshoot OrasPullNetworkTimeoutVMExtensionError (211) in AKS. Fix private link and network issues, then create your cluster successfully—start now.
ms.date: 2026-07-21T00:00:00.0000000Z
ms.reviewer: xinhl, v-weizhu, mhedhbisaber
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: c8e30ed1-a049-2a44-d9ee-88ad33980169
document_version_independent_id: c8e30ed1-a049-2a44-d9ee-88ad33980169
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/vmextensionerror-oraspullnetworktimeout.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/vmextensionerror-oraspullnetworktimeout
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/vmextensionerror-oraspullnetworktimeout.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 38dff187-7967-3544-604c-9e9e3558c8ea
---

# OrasPullNetworkTimeoutVMExtensionError When Creating AKS Clusters - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve the `OrasPullNetworkTimeoutVMExtensionError` error (error code 211) that occurs when you try to create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you try to create an AKS cluster with the outbound type `none` or `block`, you receive the following error message:

> 
> VMExtensionProvisioningError: VM reported a failure when processing extension 'vmssCSE'.
> 
> Error message: "Enable failed: failed to execute command: command terminated with exit status=211
> 
> Bootstrap Container Registry isn't reachable. Check the network configuration and try again.

## Cause

For [network isolated cluster](/en-us/azure/aks/concepts-network-isolated), egress traffic is limited. The feature introduces a private Azure Container Registry (ACR) cache that acts as a proxy to download necessary binaries or images from Microsoft Artifact Registry (MAR) for AKS bootstrap. VM instances connect to the private ACR through a private link. Incorrect configuration of the private link causes VM bootstrap Custom Script Extension (CSE) to fail.

## Solution

To resolve this issue, follow these steps:

1. Retrieve the ACR resource ID that AKS uses as the bootstrap ACR by running the following command:

    ```console
    az aks show -g ${RESOURCE_GROUP} -n ${CLUSTER_NAME} --query 'bootstrapProfile.containerRegistryResourceId'
    ```
2. Verify the ACR cache rule. It should include `aks-managed-rule` with source repo `mcr.microsoft.com/*` and target repo `aks-managed-repository/*`. Ensure no other cache rule exists with source or target repo as `*`, which override `aks-managed-rule`.
3. Review the [container registry private link](/en-us/azure/container-registry/container-registry-private-link) to ensure that the connection configuration is correct, including the private Domain Name System (DNS) zone and private link.
4. Verify that the AKS kubelet identity has `AcrPull` access to the bootstrap ACR: AKS requires permission to pull images and artifacts from the bootstrap Azure Container Registry (ACR). Verify that the AKS kubelet identity has the required permissions (AcrPull) on the bootstrap Azure Container Registry (ACR).
5. Access any failed VM instance using Secure Shell (SSH) and run curl on the ACR host. If successful, reconcile the cluster. If it still fails, return to step 3.

## References

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)
- [Network isolated Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/concepts-network-isolated)
- [Container registry private link](/en-us/azure/container-registry/container-registry-private-link)
- [The AKS-ACR integration](/en-us/azure/aks/cluster-container-registry-integration?pivots=azure-cli)