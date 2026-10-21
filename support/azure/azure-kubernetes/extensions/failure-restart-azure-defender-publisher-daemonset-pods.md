---
layout: Conceptual
title: Pods fail and restart after you enable Defender Profile for AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/failure-restart-azure-defender-publisher-daemonset-pods
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: mosbahmajed
ms.author: momajed
ms.topic: troubleshooting-problem-resolution
description: Learn how to resolve a scenario in which the azure-defender-publisher DaemonSet pods fail and restart after you enable Defender Profile for AKS.
ms.date: 2024-08-07T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: cssakscic, v-rekhanain, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: f5fff5d0-b6ea-9c8b-c564-7785ab400fde
document_version_independent_id: f5fff5d0-b6ea-9c8b-c564-7785ab400fde
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/failure-restart-azure-defender-publisher-daemonset-pods.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/failure-restart-azure-defender-publisher-daemonset-pods
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/failure-restart-azure-defender-publisher-daemonset-pods.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/8e3fdb08-a059-4277-98f6-c0e21e940707
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/88291526-9c74-4f87-878c-de0a82134421
platformId: 00b8d1ac-5eff-7169-06b1-e3412b3c187d
---

# Pods fail and restart after you enable Defender Profile for AKS - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot a scenario in which the `azure-defender-publisher` DaemonSet pods fail and then restart after you enable Defender Profile for Microsoft Azure Kubernetes Service (AKS).

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli)
- [curl](https://curl.se)

## Symptoms

Consider the following scenario:

- You're using the Azure Policy Add-on for AKS.
- You enable Defender Profile for AKS per the [Azure Advisor](/en-us/azure/advisor/advisor-overview) recommendation.

In this scenario, the `azure-defender-publisher` DaemonSet pods continually restart.

## Cause

This problem might be caused by authentication issues or a misconfiguration.

## Workaround

Disable the Azure Defender profile by following these steps:

1. Obtain the access token for your account by running the following [az account get-access-token](/en-us/cli/azure/account#az-account-get-access-token) command:

    ```azurecli
    az account get-access-token --query 'accessToken' --output tsv
    ```

    Note

    Save the access token from the output to use for commands in the following steps. The access token is an encoded string that can exceed 2,000 characters.
2. To determine whether the Azure Defender profile is enabled on your cluster, invoke the following REST API GET method by running the following curl command. Replace the `<access-token>` placeholder in the `Authorization` header with the access token from the previous step, and then replace the placeholders in the URI that represent the Azure subscription GUID, resource group name, and cluster name:

    ```bash
    curl -X GET \
        -H "Authorization: Bearer <access-token>" \
        -H "Content-Type: application/json" \
        https://management.azure.com/subscriptions/<subscription-guid>/resourceGroups/<resource-group-name>/providers/Microsoft.ContainerService/managedClusters/<cluster-name>?api-version=2020-04-01
    ```

    If the Azure Defender profile is enabled on your cluster, the command returns JSON output that resembles the following snippet:

    ```json
    "securityProfile": {
     "azureDefender": {
      "enabled": true,
      "logAnalyticsWorkspaceResourceId": "/subscriptions/<subscription-guid>/resourceGroups/<resource-group-name>/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-<guid>-<region>"
     }
    ```
3. Remove the Azure Defender profile by invoking the following REST API PUT method through the curl command. This command resembles the previous command, except that you specify `-X PUT` instead of `-X GET` for the method request, and you specify a `-d` parameter to pass data to the request. The required placeholder value replacements are identical to the previous command.

    ```bash
    curl -X PUT \
        -H "Authorization: Bearer <access-token>" \
        -H 'Content-Type: application/json' \
        -d '{"location": "northeurope", "properties": {"securityProfile": {"azureDefender": {"enabled": false }}}}' \
        https://management.azure.com/subscriptions/<subscription-guid>/resourceGroups/<resource-group-name>/providers/Microsoft.ContainerService/managedClusters/<cluster-name>?api-version=2020-04-01
    ```

    If the command runs as expected, the result shows your cluster in the `Updating` state, and the Azure Defender profile is disabled.

    ```json
    {
     "id": "",
     "location": "northeurope",
     "name": "<cluster-name>",
     "type: "Microsoft.ContainerService/ManagedClusters",
     "properties": {
      "provisioningState": "Updating",
      "powerState": {
       "code": "Running"
      },
    
    ...
    
     },
     "securityProfile": {
      "azureDefender": {
       "enabled": false
      }
     }
    }
    ```

After you disable the Azure Defender profile, check whether the `azure-defender-publisher` DaemonSet pods continue their previous cycle of failing and restarting.