---
layout: Conceptual
title: Update a certificate bundle on container hosts | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/update-certificate-bundle
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
description: Learn how to add a certificate chain of trust (root, intermediate and lead certificates) with public key in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: sulahiri
ms.custom: windows-server
locale: en-us
document_id: 1606ebcb-4ba8-1e75-8664-c00841accffc
document_version_independent_id: 91734be0-e6cb-4b15-a7d6-34b29070a6e1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/update-certificate-bundle.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/update-certificate-bundle
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/update-certificate-bundle.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: de17a97c-6be4-38b3-149b-862b3dab9558
---

# Update a certificate bundle on container hosts | Microsoft Learn

> 
> Applies to: AKS on Windows Server

An AKS cluster needs to trust other on-premises resources such as the container registry. This article describes how to add a certificate chain of trust (root, intermediate and lead certificates) with a public key, for the endpoints the cluster is expected to trust and allow communication. The certificates are added on the Linux hosts.

This scenario uses a modified version of the [noProxy settings](proxy-change) command.

## Prerequisites and details

- An AKS on Windows Server deployment running the October 2022 release or later.
- The certificates aren't immediately available upon running the command; they're deployed on the next update.
- You can check if there's an update available using the PowerShell cmdlet [Get-AksHciClusterUpdates](/en-us/azure/aks/aksarc/reference/ps/get-akshciclusterupdates).
- Currently there's no command to view, change, or delete scheduled update. Once the update is applied, it's possible to SSH into the container host and see the certs installed, then delete them.

## Certificate format

- The certificates should be specified in a single .crt file in PEM format. This format is applicable for updating certificates on Linux container hosts.
- It's important to make sure the certificates are added in the right order in a single .crt file. For example, `<.leaf.crt>`, `<intermediate.crt>`,`<root.crt>`.
- The contents of the certificate file aren't validated. You must ensure that the file contains the right certificates and is in the correct format.

## Example: create a single certificate bundle

For Linux hosts:

```bash
cat [leaf].crt  [intermediate].crt [Root].crt >  [your single cert file].crt
```

PowerShell:

```powershell
$noProxy = "" # keep this as an empty string
$certFile ="/../[bundle].crt" # path to the bundled .crt file
Set-AksHciProxySetting -noProxy $noProxy -certFile $certFile
```