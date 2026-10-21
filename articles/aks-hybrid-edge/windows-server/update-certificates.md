---
layout: Conceptual
title: Update certificates in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/update-certificates
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
description: Learn how to update certificates in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2023-04-01T00:00:00.0000000Z
ms.reviewer: leslielin
ms.custom: windows-server
locale: en-us
document_id: 22b62ca4-0bc1-0c91-9037-2191e659564c
document_version_independent_id: 84117b5e-4e74-92d1-ef5a-7b5a2cf3f6f0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/update-certificates.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/update-certificates
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/update-certificates.md
platformId: b6c96812-f185-8781-02bc-2439c67906eb
---

# Update certificates in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

AKS certificate management covers two layers of the stack. First, the infrastructure layer brings up AKS clusters on Windows Server nodes. This is referred to as the *MOC* (Microsoft On-premises Cloud) layer. The second layer is the AKS Kubernetes layer. This includes the Kubernetes infrastructure certificates auto-provisioned as part of the cluster bootstrapping.

The behavior of the certificates at the MOC layer and AKS Kubernetes layer has a few differences depending on two factors: cluster shutdown and cluster updates.

## Certificate renewal dependencies on cluster shutdown

| Shutdown | MOC certificates | AKS on Windows Server Kubernetes certificates |
| --- | --- | --- |
| Shutdown less than 30 days | Not impacted | Impacted |
| Shutdown more than 30 days | Impacted | Impacted |

## Certificate renewal dependencies on cluster renewal

| Cluster | MOC certificates | AKS on Windows Server Kubernetes certificates |
| --- | --- | --- |
| Cluster updated within 90 days | Not impacted | Not impacted |
| Cluster not updated within 90 days | Not impacted | Not impacted |

## Commands for fixing certificates

| Cluster | MOC certificates | AKS on Windows Server Kubernetes control plane certificates |
| --- | --- | --- |
| Management cluster | [`Update-AksHciCertificates`](/en-us/azure/aks/aksarc/reference/ps/update-akshcicertificates) | N/A |
| Target cluster | [`Update-AksHciClusterCertificates -name -fixCloudCredentials`](/en-us/azure/aks/aksarc/reference/ps/update-akshciclustercertificates) | [`Update-AksHciClusterCertificates -name -fixKubeletCredentials`](/en-us/azure/aks/aksarc/reference/ps/update-akshciclustercertificates) |
| Load balancer | [`Update-AksHciClusterCertificates -name -patchLoadBalancer -fixCloudCredentials`](/en-us/azure/aks/aksarc/reference/ps/update-akshciclustercertificates) |  |

## When both MOC and AKS Kubernetes certificates are impacted

When the cluster has been shut down for more than 30 days, run the following commands in the following sequence:

1. `Update-AksHciCertificates` (to fix management cluster certificates).
2. `Update-AksHciClusterCertificates –fixkubeletcredentials` (to fix target cluster control plane certificates).
3. `Update-AksHciClusterCertificates –fixcloudcredentials` (to fix target cluster MOC certificates).