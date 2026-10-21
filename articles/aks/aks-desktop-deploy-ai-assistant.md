---
layout: Conceptual
title: Troubleshoot Azure Kubernetes Service (AKS) Workloads with Natural Language in AKS Desktop (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-desktop-deploy-ai-assistant
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
description: Learn how to use the AI-powered troubleshooting assistant in AKS desktop to diagnose and resolve Kubernetes issues using natural language.
ms.subservice: aks-developer
author: danielsollondon
ms.reviewer: schaffererin
ms.topic: how-to
ms.date: 2026-04-16T00:00:00.0000000Z
ms.author: danis
locale: en-us
document_id: 33b17975-df86-462f-450f-a1450d9da3a6
document_version_independent_id: 36e11c87-eebf-3c47-1441-b6b2c5385d7d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-desktop-deploy-ai-assistant.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-desktop-deploy-ai-assistant
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-desktop-deploy-ai-assistant.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1d472a12-47ab-661d-d2c5-af2f6bba97b7
---

# Troubleshoot Azure Kubernetes Service (AKS) Workloads with Natural Language in AKS Desktop (preview) - Azure Kubernetes Service | Microsoft Learn

AKS desktop includes an AI-powered troubleshooting assistant that provides natural language diagnostics for your AKS workloads. By securely connecting to your cluster, the assistant can analyze logs, events, and metrics to identify issues and recommend resolutions in plain language. This allows developers and operators to quickly understand and fix problems without needing deep Kubernetes expertise. This article walks you through how to enable and use the AI troubleshooting assistant in AKS desktop.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## What is the AI troubleshooting assistant?

The AKS desktop troubleshooting assistant is built into [AKS desktop](aks-desktop-overview) and provides a guided experience for diagnosing issues in your cluster. With the assistant, you can:

- Select a project, namespace, or workload to investigate.
- Run scoped diagnostics that analyze logs, events, and metrics.
- Receive AI-generated summaries with clear reasoning and evidence.
- Preview recommended actions and apply them with confidence.
- Use your own language models or connect to Azure managed options.
- Work alongside existing dashboards in AKS desktop for a cohesive troubleshooting experience.

Warning

This plugin is in early development and isn't ready for production use. Using it might incur costs from your AI provider.

## How does the AI troubleshooting assistant work?

You have two options for enabling the AI troubleshooting assistant in AKS desktop:

- Use the **[Azure AKS Agentic CLI Agent](https://blog.aks.azure.com/2025/08/15/cli-agent-for-aks)** (recommended for AKS): This is an AI-powered tool that helps diagnose, troubleshoot, and optimize AKS clusters using natural language queries. It provides root cause analysis by connecting to your AKS cluster (using your permissions) and remediation suggestions. This is backed by an LLM of your choice.
- Use the **AKS desktop Agent**: AKS desktop acts as an Agent itself, providing context to your model of your choice.

### Which option should I choose?

Asking a standalone LLM a question is similar to asking an expert for advice based only on what you tell them. In contrast, the AKS Agentic CLI integrates the HolmesGPT agentic framework with the AKS Model Context Protocol (MCP) server. Combined, they know which tools, troubleshooting techniques, and other MCP servers to use, enabling the agent to securely access live cluster state, logs, metrics, and Azure resource data to perform iterative, context-aware investigations within Role-Based Access Control (RBAC) boundaries rather than relying solely on static user-provided input.

By default, the AKS Agentic CLI connects to a hosted LLM endpoint using a customer‑provided API key, but organizations with strict data residency or compliance requirements might instead choose to deploy a model within their own environment.

In the following sections, we provide end-to-end steps for setting up both options, but we recommend the AKS Agentic CLI for the best experience with AKS desktop.

## Enable the AI troubleshooting assistant in AKS desktop

1. Go to **Settings** &gt; **Plugins**, and make sure the AI Assistant plugin is enabled.
2. Select **AI Assistant** in the list of plugins.
3. Toggle **Preview** to the enabled state. After this, the AI Assistant icon appears in the top right.

## Configure a provider for the AI troubleshooting assistant

1. Go to **Settings** &gt; **Plugins** &gt; **AI Assistant** &gt; **Add provider**.

    ![Screenshot of the AKS desktop Settings panel showing the AI Assistant plugin with the Enable toggle.](media/aks-desktop-app/aks-desktop-enable-ai-assistant.png)
2. Choose your provider option:

    - **Use the Azure AKS Agentic CLI Agent** (recommended for AKS): Install the [Agentic CLI Agent](agentic-cli-for-aks-install) on your cluster, configure it to connect to a model, and ensure the cluster running the Agentic CLI Agent is a registered cluster in AKS desktop (you should see it in your cluster list).
    - **Use an existing model**: Configure the provider so that AKS desktop can act as an agent and send cluster context to your existing model.

## Enable Kubernetes API requests for the assistant

The **AI tool Kubernetes Requests** setting allows the AI Assistant to make live Kubernetes API requests against your cluster. When enabled, the assistant can query resource state, pod logs, events, and metrics to provide context-aware analysis. If disabled, the assistant can only reason from information you manually provide in the chat.

1. Go to **Settings** &gt; **Plugins** &gt; **AI Assistant**.
2. Enable the **AI tool Kubernetes Requests** toggle.

## Set the AI Assistant to use the AKS Agentic CLI Agent

1. Open the AI Assistant.
2. Select **Agent**.
3. Select the cluster where the Agentic CLI Agent is running.

    ![Screenshot of the AKS desktop AI Assistant panel with Agent mode selected and a cluster dropdown.](media/aks-desktop-app/aks-desktop-set-agent-mode.png)

## Investigate degraded resources

The assistant is context-aware. When you see errors or warnings highlighted in the interface, select the resource and ask the assistant for an explanation and recommended resolution.

1. Go to the cluster resource (for example a service) or go to the AKS desktop Project and select the workload.
2. Select the Kubernetes resource that's degraded or showing errors in the event log.
3. Select **Agent** and start chatting.

    ![Screenshot of a chat with natural language feature in AKS desktop.](media/aks-desktop-app/aks-desktop-ai-assistant.png)