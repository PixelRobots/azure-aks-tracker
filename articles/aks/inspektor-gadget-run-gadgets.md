---
layout: Conceptual
title: Run gadgets to inspect workloads on AKS (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/inspektor-gadget-run-gadgets
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
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to use the kubectl gadget plugin to run gadgets and inspect DNS, file, process, and network activity on Azure Kubernetes Service (AKS).
author: mqasimsarfraz
ms.author: qasimsarfraz
ms.date: 2026-06-26T00:00:00.0000000Z
ms.topic: how-to
ai-usage: ai-assisted
locale: en-us
document_id: d979eadf-24df-bf90-dd7d-0b0ec9238ebb
document_version_independent_id: 8cabc6e6-4941-3188-4838-d11f70227212
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/inspektor-gadget-run-gadgets.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: bash
toc_rel: toc.json
asset_id: aks/inspektor-gadget-run-gadgets
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/inspektor-gadget-run-gadgets.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a16411c9-a320-e522-1ee6-e5723bf900c6
---

# Run gadgets to inspect workloads on AKS (preview) - Azure Kubernetes Service | Microsoft Learn

After you install the Inspektor Gadget cluster extension, use the `kubectl gadget` plugin to run *gadgets*. A gadget is a purpose-built tool that captures a specific kind of system activity, such as DNS queries, file access, process execution, or network connections, and correlates it with Kubernetes metadata.

To install the extension, see [Install and configure the Inspektor Gadget extension on AKS](inspektor-gadget-configure).

Tip

The examples in this article use a few common gadgets. To browse all available gadgets and choose the right one for your task, see [the Inspektor Gadget gadget catalog](inspektor-gadget-catalog).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- The Inspektor Gadget extension installed on your AKS cluster. See [Install and configure the Inspektor Gadget extension on AKS](inspektor-gadget-configure).
- The `kubectl gadget` plugin to run gadgets. You can run gadgets without any local setup by using Azure Cloud Shell, which has the `kubectl gadget` plugin preinstalled. Select **Try it** on any code block in this article to open Cloud Shell. To learn more, see [Overview of Azure Cloud Shell](/en-us/azure/cloud-shell/overview).

    To run gadgets from your own workstation instead, install the `kubectl gadget` plugin with [Krew](https://krew.sigs.k8s.io/):

    ```bash
    kubectl krew install gadget
    ```

    Alternatively, download the `kubectl-gadget` binary from the [Inspektor Gadget releases page](https://go.microsoft.com/fwlink/?LinkId=2370532) and add it to your `PATH`. Verify the installation:

    ```bash
    kubectl gadget version
    ```

Tip

The `kubectl gadget` plug-in is also available from the Microsoft Cloud-Native package repository at `packages.microsoft.com` for Azure Linux and Ubuntu. After you add the repository, install it by using the OS package manager, such as `tdnf install -y kubectl-gadget` on Azure Linux or `apt install -y kubectl-gadget` on Ubuntu.

## Scope a gadget

You can scope a gadget to a namespace, a pod, or the entire cluster:

- Use `--namespace <namespace>` to limit a gadget to a single namespace.
- Use `--all-namespaces` to run a gadget across the whole cluster.
- Use `--timeout <seconds>` to stop the gadget after a set duration.
- Use `--fields <field-list>` to choose which columns appear in the output.

## Trace DNS queries

Capture DNS queries and responses with the originating pod:

```bash
kubectl gadget run trace_dns \
    --namespace default \
    --timeout 30 \
    --fields k8s.node,k8s.podName,id,qr,name,rcode,nameserver
```

Successful lookups show an `rcode` of `NoError`.

## Trace file access

Record file open events, including the file name and access flags:

```bash
kubectl gadget run trace_open \
    --namespace default \
    --timeout 30 \
    --fields k8s.node,k8s.podName,comm,fname,flags,error
```

The `flags` field shows the access mode, such as `O_RDONLY` for reads and `O_WRONLY` for writes.

## Trace process execution

Report process creation events with the command, PID, and arguments:

```bash
kubectl gadget run trace_exec \
    --namespace default \
    --timeout 30 \
    --fields k8s.node,k8s.podName,comm,pid,args
```

The `comm` field shows the name of the executed binary.

## Trace TCP connections

Capture TCP accept and close events with source and destination addresses across all namespaces:

```bash
kubectl gadget run trace_tcp \
    --all-namespaces \
    --timeout 30
```