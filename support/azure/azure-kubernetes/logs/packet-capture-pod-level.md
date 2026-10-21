---
layout: Conceptual
title: How to capture a TCP dump from a pod running on an AKS cluster - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/logs/packet-capture-pod-level
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
description: Learn how to capture a TCP dump from a pod on an AKS cluster, download the capture to your local computer, and troubleshoot connectivity issues. Get started now.
ms.date: 2026-07-20T00:00:00.0000000Z
ms.reviewer: addobres
ms.service: azure-kubernetes-service
ms.custom: sap:Monitoring and Logging
locale: en-us
document_id: 1b11599f-940f-6a0d-04d6-5ae05744c752
document_version_independent_id: 1b11599f-940f-6a0d-04d6-5ae05744c752
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/logs/packet-capture-pod-level.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/logs/packet-capture-pod-level
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/logs/packet-capture-pod-level.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 17bb555e-6a8c-3416-8aa3-050ab9c8c0fe
---

# How to capture a TCP dump from a pod running on an AKS cluster - Azure | Microsoft Learn

## Summary

This article explains how to capture TCP traffic at a pod in an Azure Kubernetes Service (AKS) cluster and download the capture to your local computer.

## Prerequisites

You must run the Azure CLI version 2.0.59 or a later version.

Run `az --version` to verify the version. To install the latest version of the Azure CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Identify the pod and install TCPdump

1. Identify the name of the pod that you want to capture the TCP packets from. This pod should be the one that has the connectivity problems. To identify the pod, run `kubectl get pods -A` to see the list of pods on your AKS cluster. The following example shows the output:

    ```output
    NAME                               READY     STATUS    RESTARTS   AGE
    azure-vote-back-2549686872-4d2r5   1/1       Running   0          31m
    azure-vote-front-848767080-tf34m   1/1       Running   0          31m
    ```

    If you know the namespace that the pod runs in, you can also run `kubectl get pods -n <namespace>` to get a list of pods that are running in that namespace.
2. Connect to the pod that you identified in the previous step. The following commands use `azure-vote-front-848767080-tf34m` as the pod name. Replace it with the correct pod name. If the pod isn't in the default namespace, add the `--namespace` parameter to the `kubectl exec` command.

    ```azurecli
    kubectl exec azure-vote-front-848767080-tf34m -it -- /bin/bash
    ```
3. After you connect to the pod, run `tcpdump --version` to check whether TCPdump is installed. If you receive a "command not found" message, run the following command to install TCPdump in the pod:

    ```azurecli
    apt-get update && apt-get install tcpdump
    ```

    If your pod uses Alpine Linux, run the following command to install TCPdump:

    ```azurecli
     apk add tcpdump
    ```

## Capture TCP packets and save them to a local directory

1. Run `tcpdump -s 0 -vvv -w /capture.cap` to start capturing TCP packets on your pod.
2. After the packet capture finishes, exit your pod shell session.
3. Run the following command to save the packets to the current directory:

    ```azurecli
    kubectl cp azure-vote-front-848767080-tf34m:/capture.cap capture.cap
    ```