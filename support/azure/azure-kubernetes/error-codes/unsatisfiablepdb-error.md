---
layout: Conceptual
title: AKS cluster upgrade fails with UnsatisfiablePDB error - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/unsatisfiablepdb-error
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
description: Fix the UnsatisfiablePDB error in AKS cluster upgrades by resolving Pod Disruption Budget issues that block node drain. Get your cluster upgraded successfully.
ms.date: 2025-03-05T00:00:00.0000000Z
ms.reviewer: chiragpa, v-weizhu, addobres
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 570cc254-3a4d-b010-bba7-9102cd395a07
document_version_independent_id: 570cc254-3a4d-b010-bba7-9102cd395a07
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/unsatisfiablepdb-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/unsatisfiablepdb-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/unsatisfiablepdb-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 79eb1be3-4019-2a91-cda7-67ef01d63905
---

# AKS cluster upgrade fails with UnsatisfiablePDB error - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve the "UnsatisfiablePDB" error that occurs when you upgrade an Azure Kubernetes Service (AKS) cluster, so you can complete the upgrade successfully.

## Prerequisites

This article requires Azure CLI version 2.53.0 or a later version. Run `az --version` to find your installed version. If you need to install or upgrade the Azure CLI, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

## Symptoms

An AKS cluster upgrade operation fails with the following error message:

> 
> Code: UnsatisfiablePDB Message: 1 error occurred: \* PDB &lt;pdb-namespace&gt;/&lt;pdb-name&gt; has maxunavailble == 0 can't proceed with put operation

## Cause

Before starting an upgrade operation, AKS checks the cluster for any existing [Pod Disruption Budgets (PDBs)](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets) that have the `maxUnavailable` parameter set to 0. Such PDBs are likely to block node drain operations. If node drain operations are blocked, the cluster upgrade operation can't complete successfully. This might potentially cause the cluster to be in a failed state.

After receiving the "UnsatisfiablePDB" error, you can confirm the PDB's status by running the following command:

```console
$ kubectl get pdb <pdb-name> -n <pdb-namespace>
```

The output of this command should be similar to the following one:

```output
NAME         MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
<pdb-name>   N/A             0                 0                     49s
```

If the value of `MAX UNAVAILABLE` is 0, the node drain fails during the upgrade process.

To resolve this issue, use one of the following solutions.

## Solution 1: Adjust the PDB's "maxUnavailable" parameter

Note

Use this solution if you can edit the PDB resource directly.

1. Set the PDB's `maxUnavailable` parameter to `1` or a greater value. For more information, see [Specifying a PodDisruptionBudget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget).
2. Retry the AKS cluster upgrade operation.

## Solution 2: Back up, delete, and redeploy the PDB

Note

Use this solution if directly editing the PDB resource isn't viable.

1. Back up the PDB using the following command:

    ```console
    $ kubectl get pdb <pdb-name> -n <pdb-namespace> -o yaml > pdb_backup.yaml
    ```
2. Delete the PDB using the following command:

    ```console
    $ kubectl delete pdb <pdb-name> -n <pdb-namespace>
    ```
3. Retry the AKS cluster upgrade operation.
4. If the AKS cluster upgrade operation succeeds, redeploy the PDB using the following command:

    ```console
    $ kubectl apply -f pdb_backup.yaml
    ```