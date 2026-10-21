---
layout: Conceptual
title: Network validation error due to .local domain | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/network-validation-error-local
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
description: Learn how to troubleshoot network validation errors due to the .local domain.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: troubleshooting
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: pradwivedi
ms.lastreviewed: 2025-04-30T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: b698bf3f-2f18-1ced-f543-74b41c4ec690
document_version_independent_id: 603c0832-ba2f-4e60-55cd-b9fce4649192
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/network-validation-error-local.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/network-validation-error-local
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/network-validation-error-local.md
platformId: b8a0eb50-4709-b9ed-8a8c-deba0dcfc85b
---

# Network validation error due to .local domain | Microsoft Learn

This article describes how to resolve the `Not able to connect to http://cloudagent.contoso.local:50000` error. This error occurs when you try to create and deploy an AKS on Azure Local cluster.

## Symptoms

You can deploy `.local` domains on Azure Local but might sometimes encounter failures during AKS scenarios, such as create, scale, update, upgrade, and delete. You might see the following error message:

`Error: Network validation failed during cluster creation. Detailed message: Not able to connect to http://cloudagent.contoso.local:50000. Error returned: action failed after 5 attempts: Get "http://cloudagent.contoso.local:50000": dial tcp: lookup http://cloudagent.contoso.local: Temporary failure in name resolution`

## Possible causes

There are two possible causes for this error:

1. Because `.local` is an officially reserved special-use domain name, host names with this top-level label are only resolvable via the multicast DNS name resolution protocol. Other mechanisms such as unicast DNS can also be used to resolve this name.

    When a URL ending with `.local` for the failover cluster is used, a fully qualified domain name (FQDN) ending with `.local` is also used for the MOC cloud agent. The Azure Local 2503 release consists of various network validation tests. One of the tests tries to connect to the MOC cloud FQDN from the AKS control plane VM. This specific test fails when the MOC cloud agent FQDN uses the `.local` domain name. This is because the **Go HTTP** client relies on standard DNS resolution, so it doesn't automatically resolve the `.local` address via mDNS.
2. When the on-premises directory is synchronized with Microsoft 365, you must have a verified domain in Microsoft Entra ID. Only the user principal names (UPNs) that are associated with the on-premises Active Directory Domain Services (AD DS) domain are synchronized. However, any UPN that contains a non-routable domain, such as `.local` (for example, `billa@contoso.local`), is synchronized to an `.onmicrosoft.com` domain (for example, `billa@contoso.onmicrosoft.com`). For more information, see [Prepare a nonroutable domain for directory synchronization](/en-us/microsoft-365/enterprise/prepare-a-non-routable-domain-for-directory-synchronization?view=o365-worldwide&amp;preserve-view=true).

## Mitigation

If you are on Azure Local 2503 or a later release, don't use `.local` in the domain name.

Per the possible cause #2, if you currently use a `.local` domain for your user accounts in AD DS, we recommend that you change them to use a verified domain; for example, `billa@contoso.com`, to properly synchronize with your Microsoft 365 domain.

As a temporary mitigation, the checks for the `.local` domain are disabled in the Azure Local 2504 release. For more information, see [What's new in Azure Local, version 2504](/en-us/azure/azure-local/whats-new?view=azloc-2504&amp;preserve-view=true).