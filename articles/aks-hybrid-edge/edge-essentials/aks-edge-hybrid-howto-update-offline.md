---
layout: Conceptual
title: AKS Edge Essentials update (offline) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-hybrid-howto-update-offline
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
description: Learn how to update disconnected AKS Edge Essentials clusters.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-how-to, edge-essentials
locale: en-us
document_id: 01e6041f-d06b-c806-6cae-cac2fb86ba1e
document_version_independent_id: 15b6a187-cc93-8498-82fa-d1a6c6180396
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-hybrid-howto-update-offline.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-hybrid-howto-update-offline
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-hybrid-howto-update-offline.md
platformId: b5df4f07-2f5a-05f9-b94d-98c64d6af165
---

# AKS Edge Essentials update (offline) | Microsoft Learn

In a disconnected (offline, air-gapped) environment, where your AKS Edge Essentials nodes are isolated from WSUS and the internet, it's still possible to update AKS Edge Essentials. However, a little more manual effort is required to stage the update. This article explains that process.

## Step 1: Download the update files on an Internet-connected machine

Because the update delivery mechanism for AKS Edge Essentials updates is Microsoft Update, the update files are available for download on the Microsoft Update Catalog web site.

1. On a computer with internet access, navigate to the [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/Search.aspx?q=aks+edge+essentials) and search for the AKS Edge Essentials updates.
2. In the list, locate the desired version and Kubernetes implementation (`k8s` or `k3s`), for example `AKS Edge Essentials k8s 1.26.6 (Version 1.5.203.0)` and click the `Download` button.
3. Download each of the files that make up the full update. There are multiple files; the exact number depends on the update. They have names like `akswindows3_2526412badc9e781382a5e064b9f1b664f414c67.exe`.
4. Copy the executables to a folder on all of the AKS Edge Essentials nodes using any available mechanism (USB flash drive, optical disk, etc.).

## Step 2: Stage the update

After the executables are copied to the AKS Edge Essentials nodes, stage the update on each node by running all of the patch executables on each node. The executables are self-extracting executables that place the files into the staging location on the node.

The executables, when run, refer to themselves as a name along the lines of "`AKS-EE Windows Fragment`." Each executable displays a single dialog box confirming the installation; there's no other user interaction.

It's possible to perform an unattended extraction by running the executable with a `-y` parameter. Thus, it's possible to automate the installation on a node through a script. For example, the following PowerShell stages from all the executables in a single folder:

```powershell
foreach ($i in Get-ChildItem) { Start-Process $i.fullname -Wait -ArgumentList "-y" }
```

## Step 3: Validate the files are staged

Optionally, validate the files are staged into `C:\Program Files\AKS-Edge\update-cache`. The exact list of files and content of the files vary depending on the update; your validation is reviewing that files were placed into the folder.

## Step 4: Perform the update

After the update are staged, follow the [standard update process](/en-us/azure/aks/hybrid/aks-edge-howto-update) starting at Step 2.