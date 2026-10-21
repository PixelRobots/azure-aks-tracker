---
layout: Conceptual
title: Get kubelet logs from cluster nodes | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/aks-get-kubelet-logs
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
description: Learn how to get kubelet logs in an Azure Kubernetes Service (AKS) Hybrid and Edge deployment.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2024-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: hyperconverged
locale: en-us
document_id: f751d73b-d0d5-c113-3234-2d5db7a83c16
document_version_independent_id: 764e917a-777f-1334-b449-e1d435a85367
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/aks-get-kubelet-logs.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/aks-get-kubelet-logs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/aks-get-kubelet-logs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: aa4d9ec0-17c0-4082-3ded-98b7244233ad
---

# Get kubelet logs from cluster nodes | Microsoft Learn

> 
> Applies to: AKS on Azure Local

As part of operating a Kubernetes cluster in AKS Hybrid and Edge, you might need to review logs at some point to troubleshoot a problem. This article describes how to use `journalctl` to view the kubelet logs on a node.

## Create an SSH connection

First, you must create an SSH connection with the node on which you need to view the kubelet logs. To sign in using SSH, see [connect with SSH](../../windows-server/ssh-connection) for Windows and Linux worker nodes.

## Get kubelet logs

Once you connect to the node, run the following command to pull the kubelet logs:

```console
chroot /host
journalctl -u kubelet -o cat
```

The following sample output shows the kubelet log data:

```output
I0512 19:15:19.651370    1824 server.go:411] Version: v1.19.7
I0512 19:15:19.651680    1824 server.go:831] Client rotation is on, will bootstrap in background
I0512 19:15:19.709716    1824 dynamic_cafile_content.go:167] Starting client-ca-bundle::/etc/kubernetes/pki/ca.crt
I0512 19:15:19.867693    1824 server.go:640] --cgroups-per-qos enabled, but --cgroup-root was not specified.  defaulting to /
I0512 19:15:19.868130    1824 container_manager_linux.go:276] container manager verified user specified cgroup-root exists: []
I0512 19:15:19.868169    1824 container_manager_linux.go:281]
```

You can get the full on-demand logs from the cluster, then contact Microsoft for any required troubleshooting.