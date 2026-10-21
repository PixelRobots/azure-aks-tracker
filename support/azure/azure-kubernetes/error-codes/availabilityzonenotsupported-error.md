---
layout: Conceptual
title: Troubleshoot AvailabilityZoneNotSupported Error Code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/availabilityzonenotsupported-error
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
description: Learn how to troubleshoot the AvailabilityZoneNotSupported error in AKS cluster creation, verify SKU restrictions, and create your cluster successfully.
ms.date: 2025-06-04T00:00:00.0000000Z
ms.reviewer: marcha, skuchipudi, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: d99ed9bc-84d5-4726-18f5-aae3d36b2f89
document_version_independent_id: d99ed9bc-84d5-4726-18f5-aae3d36b2f89
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/availabilityzonenotsupported-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/availabilityzonenotsupported-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/availabilityzonenotsupported-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 761c8c38-85a9-acac-3780-2b68358203c4
---

# Troubleshoot AvailabilityZoneNotSupported Error Code - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the "AvailabilityZoneNotSupported" error that occurs when you try to create an Azure Kubernetes Service (AKS) cluster.

## Prerequisites

Access to [Azure CLI](/en-us/cli/azure/get-started-with-azure-cli).

## Symptoms

An AKS cluster creation fails in specified availability zones, and you receive an "AvailabilityZoneNotSupported" error with the following message:

> 
> Preflight validation check for resource(s) for container service &lt;resource-name&gt; in resource group &lt;resource-group-name&gt; failed. Message: The zone(s) '1' for resource '&lt;agentpoolName&gt;' is not supported. The supported zones for location '&lt;location&gt;' are 'A', 'B'

## Cause

The issue occurs because the requested SKU has restrictions in some or all zones of your subscription. To verify the restrictions, go to the Verify SKU restrictions section.

## Solution

To resolve this issue, follow the [Azure region access request process](../../general/region-access-request-process) to request access to the specified region or zone.

## Verify SKU restrictions

1. List the SKU details by running one of the following commands:

    ```azurecli
    az vm list-skus -l <location> --size <SKU> 
    ```

    ```azurecli
    az rest --method get \
        --url "https://management.azure.com/subscriptions/<subscription>/providers/Microsoft.Compute/skus?%24filter=location+eq+%27<location>%27&api-version=2022-03-01"  >> availableSkus.txt
    ```

    Note

    Replace `<subscription>`, `<SKU>`, and `<location>` accordingly.
2. Search for the requested SKU from the command output.
3. If you see information like the following, it indicates that the requested SKU has restrictions in some or all zones of your subscription:

    ```json
    "restrictions": [
                    {
                        "type": "Zone",
                        "values": [
                            "<zone>"
                        ],
                        "restrictionInfo": {
                            "locations": [
                                "<location>"
                            ],
                            "zones": [
                                "1",
                                "2",
                                "3"
                            ]
                        },
                        "reasonCode": "NotAvailableForSubscription"
                    }
                ]
    ```