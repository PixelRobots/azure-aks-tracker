---
layout: Conceptual
title: Troubleshoot the "Failed to either reach kube-apiserver or control plane IP of Kubernetes cluster from Arc Resource Bridge IP" error | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/kube-api-server-unreachable
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
description: Learn how to troubleshoot the "failed to either reach kube-apiserver or control plane IP of Kubernetes cluster from Arc Resource Bridge IP error" when you try to create and deploy an AKS Hybrid and Edge cluster.
ms.topic: troubleshooting
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: hyperconverged
locale: en-us
document_id: 664b94f5-9d83-d502-b648-0804d02916f0
document_version_independent_id: b93adf33-68e3-6426-31dd-afb139b7b0eb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/kube-api-server-unreachable.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/kube-api-server-unreachable
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/kube-api-server-unreachable.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 7180d154-5c50-6b4e-5ba1-de40dcd65c68
---

# Troubleshoot the "Failed to either reach kube-apiserver or control plane IP of Kubernetes cluster from Arc Resource Bridge IP" error | Microsoft Learn

This article describes how to identify and resolve the "failed to either reach kube-apiserver or control plane IP of Kubernetes cluster from Arc Resource Bridge IP" error that occurs when you try to create and deploy a Microsoft Azure Kubernetes Service Arc cluster.

## Symptoms

When you try to create an AKS cluster, you receive the following error message:

```output
Failed to either reach kube-apiserver or control plane IP %s:%d of Kubernetes cluster %s from Arc Resource Bridge IP %v. Read aka.ms/aks-arc-kubeapiserver-unreachable for more information.
```

## Possible causes and follow-ups

- Check whether the logical network into which you deployed the AKS cluster is reachable from the [management IP pool](/en-us/azure/azure-local/plan/cloud-deployment-network-considerations#management-ip-pool).
- Check whether the `control plane IP` address of the AKS cluster is reachable from the [management IP pool](/en-us/azure/azure-local/plan/cloud-deployment-network-considerations#management-ip-pool). You can find the control plane IP address by running the [`az aksarc show`](/en-us/cli/azure/aksarc#az-aksarc-show) command.
- One possible reason for connectivity issues here is if the Arc Resource Bridge is in a different vlan than the logical network in which you created the AKS cluster. If the Arc Resource Bridge is in a different vlan, ensure that cross-vlan communication is enabled.
- Another frequent issue occurs if you have a firewall that isolates the management network from logical networks. Ensure that you opened the required ports so the management network can reach AKS VMs. Review [the network requirements](network-system-requirements#network-port-and-cross-vlan-requirements) for more information about required ports.
- Duplicate IPs and IP address collisions are other reasons why the API server might be unreachable. Ensure that you didn't use the IP addresses provided in the management network anywhere else. Likewise, ensure that the control plane IP provided during the AKS cluster creation operation isn't used anywhere else.

## Use the diagnostic checker tool

The diagnostic checker is a PowerShell-based tool that can help identify AKS cluster creation failures due to potential issues in the environment. [Use the diagnostic checker tool](aks-arc-diagnostic-checker) to identify some of the common networking issues that can lead to an AKS cluster creation failure due to the API server being unreachable.

## Contact Microsoft Support

If the problem persists, collect the following information before [creating a support request](aks-troubleshoot#open-a-support-request). Collect [AKS cluster logs](get-on-demand-logs) before creating the support request.