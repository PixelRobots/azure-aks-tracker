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
ai-usage: ai-assisted
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
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/341fdab2-4964-4759-8241-f5820b012a47
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/cc1f92bb-c0d6-4d40-99ce-dabea3161a84
platformId: 1d472a12-47ab-661d-d2c5-af2f6bba97b7
---

# Troubleshoot Azure Kubernetes Service (AKS) Workloads with Natural Language in AKS Desktop (preview) - Azure Kubernetes Service | Microsoft Learn

The AI Assistant in AKS desktop provides enhanced natural language troubleshooting for AKS workloads. Powered by the Headlamp AI Assistant, it delivers AKS-specific skills, cluster-aware observability, guided troubleshooting workflows, and seamless integration with your existing GitHub Copilot entitlement.

After securely connecting to your cluster, the assistant combines language models with AKS-specific context, logs, events, and metrics to identify issues and recommend resolutions in plain language. This approach allows developers and operators to quickly understand and fix problems without needing deep Kubernetes expertise. This article walks you through how to enable and use the AI Assistant in AKS desktop.

## Prerequisites

Before you enable the AI Assistant in AKS desktop, make sure you have:

- [AKS desktop v0.10.0 or later installed](aks-desktop-overview#install-aks-desktop).
- Access to one or more Kubernetes clusters that you want to investigate.
- The AI Assistant plugin enabled in **Settings** &gt; **Plugins**. The plugin is enabled by default.
- One of the following provider configurations:
    - **GitHub Copilot Auto Detect (recommended)**: A GitHub Copilot subscription, [GitHub CLI (`gh`)](https://cli.github.com/) installed on your machine, and GitHub CLI authenticated with your GitHub account.
    - **Another supported AI provider**: Access to a supported provider or OpenAI-compatible endpoint.

## What is the AI Assistant?

The AI Assistant is bundled with AKS desktop and provides a guided experience for diagnosing issues in your cluster. The assistant helps you:

- Run scoped diagnostics that analyze logs, events, and metrics.
- Receive AI-generated summaries with clear reasoning and evidence.
- Preview recommended actions and apply them with confidence.
- Use GitHub Copilot when available for a streamlined setup experience.
- Use cluster-aware observability and AKS-specific skills to bring additional context and best practices into investigations.

## How does the AI Assistant work?

You have two options for enabling the AI Assistant in AKS desktop:

- Use **GitHub Copilot (recommended)**. If GitHub CLI is installed and authenticated with an account that has a GitHub Copilot subscription, AKS desktop can detect and configure GitHub Copilot as the provider.
- **Another supported AI provider**: Manually configure a supported provider or OpenAI-compatible endpoint.

For either option, AKS desktop can provide cluster context and enabled AKS skills to the configured provider.

The AI Assistant runs as part of AKS desktop and doesn't deploy an agent or other workload to your cluster. AKS desktop connects to the selected cluster through the Kubernetes API by using the credentials in your kubeconfig. The assistant is limited to the operations allowed by your Kubernetes RBAC permissions.

## Enable GitHub Copilot (Auto Detect)

1. Install GitHub CLI (`gh`) on your machine and sign in to your GitHub account.
2. In AKS desktop, go to **Settings** &gt; **Plugins** &gt; **AI Assistant**.
3. Select **Auto Detect**.
4. Verify that GitHub Copilot appears as the configured provider.

    ![Screenshot of AKS desktop AI Assistant settings showing the Auto Detect button.](media/aks-desktop-app/aks-desktop-github-copilot-auto-detect.png)

## Configure your own AI provider

1. In AKS desktop, go to **Settings** &gt; **Plugins** &gt; **AI Assistant**.
2. Select **Add Provider**.
3. Select the AI provider you want to use.
4. Enter the required configuration information for your provider.
5. Verify that the provider appears in the configured providers list.

    ![Screenshot of the AKS desktop provider selection dialog showing the supported AI providers.](media/aks-desktop-app/aks-desktop-select-ai-provider.png)

## Enable Kubernetes API requests for the assistant

The **Kubernetes API Request** setting allows the AI Assistant to make live Kubernetes API requests against your cluster. When enabled, the assistant can query resource state, pod logs, events, and metrics to provide context-aware analysis. If disabled, the assistant can only reason from information you manually provide in the chat.

Read requests can run automatically. Requests that create, update, or delete Kubernetes resources require your approval and are still subject to your Kubernetes RBAC permissions.

1. Go to **Settings** &gt; **Plugins** &gt; **AI Assistant**.
2. Enable the **Kubernetes API Request** toggle.

    ![Screenshot of AKS desktop AI Tools settings showing Kubernetes API Request enabled.](media/aks-desktop-app/aks-desktop-kubernetes-api-request.png)

## Enable MCP servers

Model Context Protocol (MCP) servers allow the AI Assistant to connect to external tools and data sources. MCP servers extend the capabilities of the AI Assistant by providing additional context and actions that can be used during troubleshooting and investigation workflows.

AKS desktop supports connections to MCP servers, but MCP servers aren't enabled by default.

MCP servers are optional and aren't required for the AI Assistant's built-in AKS troubleshooting and cluster-aware observability. Configure an MCP server only when you need to connect the AI Assistant to a specific external tool or data source.

### Choose an MCP server

Choose a server based on the capability you need:

- Use Flux Operator MCP to investigate Flux GitOps resources and workflows.
- Use Inspektor Gadget for eBPF tracing and runtime diagnostics.

Before you configure an MCP server in AKS desktop, install the server and confirm that it can run as a local command. If you don't need one of these additional integrations, continue using the AI Assistant without an MCP server.

### Configure an MCP server

1. In AKS desktop, go to **Settings** &gt; **Plugins** &gt; **AI Assistant**.
2. View **MCP Servers**.
3. Turn on **Enable MCP Servers**.
4. Select **Add MCP Server**.
5. Enter the required configuration information for the MCP server.
6. Configure the approval settings for the server.

    ![Screenshot of AKS desktop MCP Servers settings showing the Enable MCP Servers toggle and Add MCP Server button.](media/aks-desktop-app/aks-desktop-mcp-servers.png)

### MCP server approvals

When an MCP server performs an action on behalf of the AI Assistant, AKS desktop can require approval before the action is executed. Configure approval settings for each MCP server.

By default, **Auto Approve Actions** is disabled. The AI Assistant displays each requested action in the chat window and requires your approval before the MCP server can execute it.

Enable **Auto Approve Actions** for a specific MCP server to automatically approve requests from that server. When enabled, the AI Assistant can use MCP tools without prompting for approval for each request.

## Enable skill repositories

Skills provide instructions and supporting information for specific tasks. AKS desktop includes an AKS skill from the Azure Skills repository, which is enabled by default. You can enable other skill repositories or add a custom repository.

1. In AKS desktop, go to **Settings** &gt; **Plugins** &gt; **AI Assistant**.
2. Review the list of built-in skill repositories.
3. Use the toggle next to each repository to enable or disable repositories.
4. Select **Add Repository** to add a custom repository.
5. Enter the repository URL and save your changes.

    ![Screenshot of AKS desktop skill settings showing the Azure Skills repository configured with the azure-kubernetes path and enabled.](media/aks-desktop-app/aks-desktop-azure-skills-repository.png)

## Proactive diagnosis

Proactive diagnosis is a separate, opt-in feature that's disabled by default. When enabled, it uses one-shot requests through Headlamp's Kubernetes API proxy to poll selected clusters for recent events with a type of `Warning` or `Error` rather than continuously watching the clusters.

The first check occurs shortly after the AI backend is ready, and the scheduler checks once per minute. When qualifying events are found, the assistant diagnoses up to three of the most recent distinct affected workloads sequentially. After a diagnosis cycle completes, a 20-minute cooldown begins before another cycle can run. If no qualifying events are found, no diagnosis cycle starts, so the lightweight event query can run again at the next one-minute check. Successful results are cached to avoid repeatedly diagnosing the same resource.

### Enable proactive diagnosis

1. In AKS desktop, go to **Settings** &gt; **Plugins** &gt; **AI Assistant**.
2. Turn on the **Proactive Diagnosis** toggle.
3. Review detected problems and recommendations surfaced by the AI Assistant.
4. Select a recommendation to investigate or begin troubleshooting.

    ![Screenshot of AKS desktop AI Assistant settings showing the Proactive Diagnosis toggle.](media/aks-desktop-app/aks-desktop-proactive-diagnosis.png)

## Disable the AI Assistant

1. Go to **Settings** &gt; **Plugins**.
2. Turn off **AI Assistant**.
3. Select **Save & Apply**.
4. Reload AKS desktop if prompted.

    ![Screenshot of the AKS desktop plugin list showing the AI Assistant toggle turned off.](media/aks-desktop-app/aks-desktop-disable-ai-assistant.png)