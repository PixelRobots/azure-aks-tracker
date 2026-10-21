---
layout: Conceptual
title: Avoid running as root in containers on Azure Kubernetes Service - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/avoid-running-as-root-in-containers
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
description: Learn how to avoid running as root in containers on Azure Kubernetes Service by configuring securityContext settings to improve pod security. Start now.
ms.date: 2024-04-15T00:00:00.0000000Z
ms.reviewer: chiragpa, andbar, haitch, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: dc926a9a-559c-7377-3aee-0527780b67e6
document_version_independent_id: dc926a9a-559c-7377-3aee-0527780b67e6
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/avoid-running-as-root-in-containers.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/avoid-running-as-root-in-containers
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/avoid-running-as-root-in-containers.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 43e2235a-979a-45f7-353e-19b8fc6b089b
---

# Avoid running as root in containers on Azure Kubernetes Service - Azure | Microsoft Learn

## Summary

To improve security, we recommend that you don't run as a root user inside containers that are hosted on Azure Kubernetes Service. To run the container as a nonroot user, specify the following `securityContext`settings in the YAML file when you deploy a pod or other Azure Kubernetes resources.

**SecurityContext**

- Resource: Pod / Deployment / DaemonSet / StatefulSet / ReplicaSet / ReplicationController / Job / CronJob
- Arguments:
    - **runAsNonRoot (Optional)**: If it's true, the container operates without root privileges. Default is false.
    - **runAsUser (Optional)**: If user number is anything other than **0** (root), the container runs by using that user ID (not the root user).

By default, the `securityContext` field is `empty ({})`. To implement these fields in the YAML file, see [Configure a security context for a pod or container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). After you add these configurations, redeploy the pods to enforce the updates. If the `securityContext` field is omitted, the pod runs as root.