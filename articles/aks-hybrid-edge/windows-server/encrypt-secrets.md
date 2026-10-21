---
layout: Conceptual
title: Encrypt etcd secrets for Azure Kubernetes Service clusters | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/encrypt-secrets
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
description: Learn how to encrypt etcd secrets in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: aathipsa
ms.custom: windows-server
locale: en-us
document_id: 1f1521a0-e014-879f-802e-b220a887cce4
document_version_independent_id: 2b4f1d83-84ce-8a88-8d3f-57270e2acb30
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/encrypt-secrets.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/encrypt-secrets
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/encrypt-secrets.md
platformId: 5683e0bd-19f0-8c07-c5fc-5ed14650a69b
---

# Encrypt etcd secrets for Azure Kubernetes Service clusters | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to monitor and troubleshoot the encryption of etcd secrets for Azure Kubernetes Service (AKS) management clusters and workload clusters in AKS on Windows Server.

A *secret* in Kubernetes is an object that contains a small amount of sensitive data, such as passwords and SSH keys. In the Kubernetes API server, secrets are stored in *etcd*, which is a highly available key values store used as the Kubernetes backing store for all cluster data. AKS comes with encryption of etcd secrets and automates the management and rotation of encryption keys.

## Monitor and troubleshoot

To simplify application deployment on Kubernetes clusters, review the [documentation and scripts](https://github.com/microsoft/AKS-Arc-Apps).

- To set up logging using Elasticsearch, Fluent Bit, and Kibana, follow the steps to [install the tools and set up logging](https://github.com/microsoft/AKS-Arc-Apps/tree/main/Logging).
- To use the monitoring tool Prometheus, follow the steps to [install Prometheus in a Kubernetes cluster](https://github.com/microsoft/AKS-Arc-Apps/tree/main/Monitoring#certs-and-keys-monitoring).

Note

You can find the logs on the control plane node under **/var/log/pods**.