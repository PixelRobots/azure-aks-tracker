---
layout: Conceptual
title: Troubleshoot Node Not Ready state when certificates have expired - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/node-not-ready-expired-certificates
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
description: Learn how to fix expired certificates causing Node Not Ready failures in AKS. Follow steps to rotate certificates and restore your cluster nodes.
ms.date: 2025-04-10T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, momajed, v-leedennis, addobres, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
locale: en-us
document_id: 8335138c-d04f-9de4-1f77-6ba5c834a6c3
document_version_independent_id: 8335138c-d04f-9de4-1f77-6ba5c834a6c3
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/node-not-ready-expired-certificates.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/node-not-ready-expired-certificates
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/node-not-ready-expired-certificates.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: fc05880e-8786-535b-8346-522c6fcbf711
---

# Troubleshoot Node Not Ready state when certificates have expired - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot Node Not Ready failures in an Azure Kubernetes Service (AKS) cluster caused by expired certificates. Learn how to identify expired certificates and rotate them to restore node availability.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli)
- The [OpenSSL](https://www.openssl.org/source/) command-line tool for certificate display and signing

## Symptoms

You discover that an AKS cluster node is in the Node Not Ready state.

## Cause

One or more certificates are expired.

## Prevention: Run OpenSSL to sign the certificates

Check the expiration dates of certificates by invoking the [openssl-x509](https://www.openssl.org/docs/man3.0/man1/openssl-x509.html) command, as follows:

- For virtual machine (VM) scale set nodes, use the [az vmss run-command invoke](/en-us/cli/azure/vmss/run-command#az-vmss-run-command-invoke) command:

    ```azurecli
    az vmss run-command invoke \
        --resource-group <resource-group-name> \
        --name <vm-scale-set-name> \
        --command-id RunShellScript \
        --instance-id 0 \
        --output tsv \
        --query "value[0].message" \
        --scripts "openssl x509 -in /etc/kubernetes/certs/apiserver.crt -noout -enddate"
    ```
- For VM availability set nodes, use the [az vm run-command invoke](/en-us/cli/azure/vm/run-command#az-vm-run-command-invoke) command:

    ```azurecli
    az vm run-command invoke \
        --resource-group <resource-group-name> \
        --name <vm-availability-set-name> \
        --command-id RunShellScript \
        --output tsv \
        --query "value[0].message" \
        --scripts "openssl x509 -in /etc/kubernetes/certs/apiserver.crt -noout -enddate"
    ```

You might receive certain error codes after you invoke these commands. For information about error codes 50, 51, and 52, see the following links, as necessary:

- [Troubleshoot the OutboundConnFailVMExtensionError error code (50)](../create-upgrade-delete/error-code-outboundconnfailvmextensionerror)
- [Troubleshoot the K8SAPIServerConnFailVMExtensionError error code (51)](../create-upgrade-delete/error-code-k8sapiserverconnfailvmextensionerror)
- [Troubleshoot the K8SAPIServerDNSLookupFailVMExtensionError error code (52)](../create-upgrade-delete/error-code-k8sapiserverdnslookupfailvmextensionerror)

If you receive error code 99, this error indicates that the [apt-get update](https://linux.die.net/man/8/apt-get) command is blocked from accessing one or more of the following domains:

- security.ubuntu.com
- azure.archive.ubuntu.com
- nvidia.github.io

To allow access to these domains, update the configuration of any blocking firewalls, network security groups (NSGs), or network virtual appliances (NVAs).

## Solution: Rotate the certificates

You can apply [certificate auto rotation](/en-us/azure/aks/certificate-rotation#certificate-auto-rotation) to rotate certificates in the nodes before they expire. This option requires no downtime for the AKS cluster.

If you can accommodate cluster downtime, you can [manually rotate the certificates](/en-us/azure/aks/certificate-rotation#rotate-your-cluster-certificates) instead.

Note

Starting in the [July 15, 2021, release of AKS](https://github.com/Azure/AKS/releases/tag/2021-07-15), an AKS cluster upgrade automatically helps to rotate the cluster certificates. However, this behavioral change doesn't take effect for an expired cluster certificate. If an upgrade takes only the following actions, the expired certificates aren't renewed:

- Upgrade a node image.
- Upgrade a node pool to the same version.
- Upgrade a node pool to a more recent version.

Only a full upgrade (that is, an upgrade for both the control plane and the node pool) helps renew the expired certificates.

## More information

- For general troubleshooting steps, see [Basic troubleshooting of Node Not Ready failures](node-not-ready-basic-troubleshooting).