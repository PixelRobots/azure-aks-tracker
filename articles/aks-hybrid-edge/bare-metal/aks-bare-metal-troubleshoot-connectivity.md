---
layout: Conceptual
title: Troubleshoot AKS on Bare Metal Connectivity | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-connectivity
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
description: Resolve Azure Arc proxy, kubeconfig, authentication, authorization, and kubectl issues for AKS on bare metal clusters.
ms.topic: troubleshooting-general
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: rishimody
ms.author: rmody
ms.custom: bare-metal
locale: en-us
document_id: bf988119-5380-45a3-8d06-a4f84632d78f
document_version_independent_id: 8c4db4cd-02c5-9f32-4110-f0043bac8de8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-connectivity.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-connectivity
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-troubleshoot-connectivity.md
platformId: a389d272-c3ce-2e79-6f30-12dccf58328a
---

# Troubleshoot AKS on Bare Metal Connectivity | Microsoft Learn

Use this guidance when you can't connect to an Azure Kubernetes Service (AKS) on bare metal cluster or run `kubectl` commands.

## Azure Arc proxy doesn't connect

1. Confirm that the cluster provisioning state is `Succeeded`.
2. Confirm that the host and connected Kubernetes resources are connected to Azure Arc.
3. Install or update the `connectedk8s` extension.

    ```azurecli
    az extension add --name connectedk8s --upgrade
    ```
4. Sign in again with `az login`, then restart `az connectedk8s proxy`.

Keep the proxy command running in its terminal and run `kubectl` in a second terminal.

## kubectl uses the wrong cluster

Check the current context:

```bash
kubectl config current-context
```

If you downloaded Ubuntu credentials to a separate file, specify that file:

```bash
kubectl --kubeconfig ./aks-ubuntu.kubeconfig get nodes
```

## Authentication or RBAC fails

Confirm that you're signed in with the expected Azure account and subscription:

```azurecli
az account show \
  --query "{subscription:name,user:user.name}" \
  --output table
```

Make sure your account belongs to the Microsoft Entra security group configured for cluster administration.

## The node isn't ready

Check node conditions and recent cluster events:

```bash
kubectl describe node <node-name>
kubectl get events --all-namespaces --sort-by=.lastTimestamp
```

Look for `MemoryPressure`, `DiskPressure`, image pull failures, or network errors.