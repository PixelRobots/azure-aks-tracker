---
layout: Conceptual
title: Restrict SSH access to virtual machines in AKS Hybrid and Edge on Azure Local | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/restrict-ssh-access
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
description: Learn how to restrict SSH access in AKS Hybrid and Edge on Azure Local.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2023-04-27T00:00:00.0000000Z
ms.reviewer: oadeniji
ms.custom: hyperconverged
locale: en-us
document_id: 36e05ab3-2f16-6b98-aeb5-bb2f79fb04ec
document_version_independent_id: 3612678e-ded7-bc7b-dbd0-0bb3f5961b59
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/restrict-ssh-access.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/restrict-ssh-access
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/restrict-ssh-access.md
platformId: 07e23a5d-c0f7-a25f-72c8-dec258d11a00
---

# Restrict SSH access to virtual machines in AKS Hybrid and Edge on Azure Local | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This article describes a new security feature in AKS that restricts Secure Shell Protocol (SSH) access to underlying virtual machines (VMs). The feature limits access to only certain IP addresses, and restricts the set of commands that you can run over SSH.

## Overview

Currently, anyone with administrator access to AKS Hybrid and Edge has access to VMs through SSH on any machine. In some scenarios, you might want to limit that access, because unlimited access makes it difficult to pass compliance.

Note

Currently, this capability is available only for a new installation of AKS, and not for upgrades. Only a new installation of AKS can pass the restricted IPs and restrict the commands that run over SSH.

## Enable SSH restrictions

The following command limits the set of hosts that can be authorized to be SSH clients. You can only run the SSH commands on those hosts, and the set of commands that you can run is restricted. The hosts are designed either via IP addresses or via CIDR ranges:

```azurecli
az aksarc create --ssh-authorized-ip-ranges CIDR format
```

The CIDR format is `0.0.0.0/32`.

This command does two things: it limits the scope of the command, and it also limits the hosts from which this command can be run.