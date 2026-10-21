---
layout: Conceptual
title: Troubleshoot BGP with FRR in AKS environments | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/connectivity-troubleshoot
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
description: Learn how to troubleshoot BGP connectivity issues when using MetalLB with FRR in AKS deployments.
author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.topic: troubleshooting
ms.reviewer: srikantsarwa
ms.lastreviewed: 2025-06-19T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: 63774716-938f-1b3f-092e-1bbe6bd9806f
document_version_independent_id: 0b947862-bdeb-5eb2-42a7-35bc74c98801
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/connectivity-troubleshoot.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/connectivity-troubleshoot
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/connectivity-troubleshoot.md
platformId: 3fe9c8a1-496a-e282-86c6-3287dcf763aa
---

# Troubleshoot BGP with FRR in AKS environments | Microsoft Learn

This article helps you identify and resolve Border Gateway Protocol (BGP) connectivity issues when using MetalLB with Free Range Routing (FRR) in Azure Kubernetes Service (AKS) Arc environments.

Use this guidance when BGP sessions fail to establish, external IP routing doesn't work correctly, or network connectivity to exposed services becomes unreliable in your AKS deployment.

## Symptoms

In environments using MetalLB with FRR for BGP peering, you might experience the following issues:

- BGP sessions are not established or keep flapping, a condition where the BGP session repeatedly goes up and down, causing route instability. This behavior can be due to network issues, misconfigurations, or hardware problems. It can result in degraded performance or loss of service availability.
- Services of type `LoadBalancer` don't receive properly routed external IPs.
- Advertised routes are missing or not propagated to upstream routers.
- Network connectivity to exposed services is inconsistent or unavailable.

These symptoms are often observed in specific hardware environments such as Hyper-Converged Infrastructure (HCI) or where strict network/security policies are enforced.

## Mitigation

If you encounter these issues with FRR, you can temporarily disable it using Azure CLI:

```azurecli
# Retrieve the object ID for the managed identity
$objID = az ad sp list --filter "appId eq '087fca6e-4606-4d41-b3f6-5ebdf75b8b4c'" --query "[].id" --output tsv

# Update the arcnetworking extension to disable FRR
az k8s-extension update \
  --cluster-name $clusterName \
  -g $rgName \
  --cluster-type connectedClusters \
  --extension-type microsoft.arcnetworking \
  --config "k8sRuntimeFpaObjectId=$objID" \
  --config "metallb.speaker.frr.enabled=false" \
  -n arcnetworking
```

## Troubleshooting steps

Use the following steps to diagnose and resolve BGP issues with MetalLB and FRR in your AKS environment.

### Check BGP configuration

```azurecli
kubectl get ipaddresspools -A -o yaml
kubectl get bgppeers.metallb.io -A -o yaml
kubectl get bgpadvertisements -A -o yaml
```

### Collect logs from MetalLB speaker (FRR)

```azurecli
# Get the list of MetalLB speaker pods
kubectl get pods -n kube-system

# Speaker container logs
kubectl logs -n kube-system arcnetworking-metallb-speaker-xxxxx -c speaker

# FRR container logs
kubectl logs -n kube-system arcnetworking-metallb-speaker-xxxxx -c frr
```

### Review TOR switch configuration

- Configuration and logs from the top-of-rack (TOR) switch or upstream router might be necessary.
- These logs are hardware/vendor-specific and not covered in this guide.