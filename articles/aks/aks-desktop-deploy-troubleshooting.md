---
layout: Conceptual
title: Troubleshoot an Application using Insights in AKS Desktop (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-desktop-deploy-troubleshooting
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
description: Learn how to troubleshoot Kubernetes applications in AKS desktop using the built-in Insights feature powered by Inspektor Gadget.
ms.subservice: aks-developer
author: danielsollondon
ms.reviewer: schaffererin
ms.topic: how-to
ms.date: 2026-04-16T00:00:00.0000000Z
ms.author: danis
locale: en-us
document_id: 0afd2c33-2b4c-3f93-0e7c-d00155739b4a
document_version_independent_id: 3198d759-3997-7cb2-0a23-98836713b50b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-desktop-deploy-troubleshooting.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-desktop-deploy-troubleshooting
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-desktop-deploy-troubleshooting.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: cfd3d4bb-205d-c4f5-97e8-aec45072eb90
---

# Troubleshoot an Application using Insights in AKS Desktop (preview) - Azure Kubernetes Service | Microsoft Learn

AKS desktop includes an integrated troubleshooting suite called **Insights**, powered by [Inspektor Gadget](https://inspektor-gadget.io/), an open-source eBPF (extended Berkeley Packet Filter)-based debugging tool. Without modifying your code or restarting anything, it lets you understand network traffic between pods, trace DNS failures, and explore running processes to spot unexpected or resource-heavy activity, all through an intuitive UI with a few clicks.

This article walks you through enabling Insights and using it to diagnose common application issues in your AKS cluster.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- **AKS desktop** installed and signed in to your AKS cluster. See [Set up an AKS cluster for AKS desktop](aks-desktop-install-cluster-setup) or [Deploy applications with AKS Automatic using AKS desktop](aks-desktop-quickstart-auto).
- **Cluster admin** or equivalent Role-Based Access Control (RBAC) permissions on the target AKS cluster. Installing Inspektor Gadget requires creating a `ClusterRole`, `ClusterRoleBinding`, and a privileged `DaemonSet`.
- Your cluster nodes must run **Linux** with kernel version **≥ 5.4**. Windows node pools aren't supported.
- If your cluster uses Azure Policy or OPA Gatekeeper with restricted pod security, add an exemption for the `gadget` namespace to allow privileged pods.
- The target cluster must be an AKS Standard cluster.

## Enable Insights in AKS desktop

1. Launch the AKS Desktop application and ensure you're signed in and connected to your AKS cluster.
2. From the left-hand navigation, select **Settings**.
3. From the Settings menu, select **Plugins**.
4. Locate the **Insights** plugin in the list, and select the **Enable** toggle.

    ![Screenshot of enabling the Insights plugin in AKS desktop.](media/aks-desktop-app/aks-desktop-enable-insights-plugin.png)

## Access Insights for your Project

In the left-hand navigation, select the **Project** you want to use Insights with. The **Insights** tab will now be visible in the Project view.

![Screenshot of the Insights tab in AKS desktop.](media/aks-desktop-app/aks-desktop-project-insights-tab.png)

## Deploy Inspektor Gadget to the cluster

On the Insights tab, you're prompted to deploy **Inspektor Gadget** to your cluster if it isn't already installed.

1. Select **Deploy Inspektor Gadget**. AKS desktop deploys the Inspektor Gadget DaemonSet to the `gadget` namespace on your cluster.
2. Wait for the deployment to complete. A status indicator confirms when Inspektor Gadget is ready.

## View Insights data

Once Inspektor Gadget is deployed, the Insights tab populates with live observability data from your cluster. See What you can do with Insights for the full set of capabilities.

![Screenshot of the Insights overview screen in AKS desktop.](media/aks-desktop-app/aks-desktop-insights-overview.png)

## What you can do with Insights

### Performance troubleshooting with Processes

The Processes view shows you every running process across your cluster's pods in real time, along with CPU, memory, and disk I/O usage. Use it to:

- Identify which pods are consuming excessive CPU or memory.
- Spot abnormal block I/O activity, for example, unusually high disk reads or writes that can indicate a misconfigured app, a runaway log writer, or a storage bottleneck.
- Detect unexpected processes that shouldn't be running in a container.

![Screenshot of the Insights Processes view in AKS desktop showing per-pod CPU, memory, and I/O metrics.](media/aks-desktop-app/aks-desktop-insights-process.png)

### Network visibility with Trace Transmission Control Protocol (TCP)

Trace TCP captures live TCP connection events at the kernel level using eBPF, without a proxy or sidecar. Use it to:

- See which pods are opening outbound connections and to which destination IPs and ports.
- Detect unexpected or unauthorized connections that might indicate a misconfiguration or security issue.
- Correlate network anomalies with specific pods or workloads.

![Screenshot of the Insights Trace TCP view in AKS desktop showing live pod-to-pod and external TCP connections.](media/aks-desktop-app/aks-desktop-insights-tcp-trace.png)

Note

You must stop the trace when finished, select the red stop button in the top-right of the trace.

### Solve DNS issues with Trace DNS

Trace DNS captures every DNS query and response made by pods in your cluster. Use it to:

- Identify DNS queries that are failing to resolve, a common cause of pod-to-service connectivity failures.
- Measure DNS latency to determine whether CoreDNS (the in-cluster DNS server) or an upstream DNS resolver is slow.
- Check the health of CoreDNS and whether external DNS resolution is working correctly.

![Screenshot of the Insights Trace DNS view in AKS desktop showing DNS queries, responses, and latency per pod.](media/aks-desktop-app/aks-desktop-insights-dns-trace.png)

Note

You must stop the trace when finished, select the red stop button in the top-right of the trace.

## Uninstall Inspektor Gadget

Remove Inspektor Gadget from your cluster by deleting the `gadget` namespace. This removes all Insights data and functionality, so only do this when you no longer need any of the Insights features.

```bash
kubectl delete ns gadget
```

Warning

This command removes all resources in the `gadget` namespace, not only those created by Inspektor Gadget.

## Troubleshooting issues with Insights

The following table outlines common issues you might encounter when using Insights along with their resolutions:

| Issue | Resolution |
| --- | --- |
| **Insights tab isn't visible** | Ensure the Insights plugin is enabled. Go to **Settings** &gt; **Plugins** and toggle **Insights** on. |
| **Deployment of Inspektor Gadget fails** | Verify you have sufficient RBAC permissions to create DaemonSets and ClusterRoles in the cluster. |
| **No data appears after deployment** | Confirm the cluster nodes are running a supported Linux kernel (≥ 5.4). Check the Inspektor Gadget pod logs for errors. |