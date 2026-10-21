---
layout: Conceptual
title: RequestDisallowedByPolicy Error When Deploying an AKS Cluster - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/requestdisallowedbypolicy-error
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
description: Learn how to fix the RequestDisallowedByPolicy error when you try to create and deploy an Azure Kubernetes Service (AKS) cluster.
ms.date: 2025-03-13T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, erbookbi, albarqaw, jacobbaek, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: a7c98ba5-dc58-69b8-a046-0ba8f60c4b67
document_version_independent_id: a7c98ba5-dc58-69b8-a046-0ba8f60c4b67
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/requestdisallowedbypolicy-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/requestdisallowedbypolicy-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/requestdisallowedbypolicy-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: bbbf7a2d-7b3c-fc5c-8544-5333d7b29494
---

# RequestDisallowedByPolicy Error When Deploying an AKS Cluster - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `RequestDisallowedByPolicy` error that occurs when you try to create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you try to deploy an AKS cluster, you receive the following error message:

> 
> Resource request failed due to RequestDisallowedByPolicy. Please see https://aka.ms/aks-requestdisallowedbypolicy for more details. The detailed error message: Code="RequestDisallowedByPolicy"
> 
> **Message="Resource 'MC\_clustername' was disallowed by policy.**

## Cause

For security or compliance, your subscription administrators might assign policies that limit how resources are deployed. For example, your subscription might have a policy that prevents you from creating public IP addresses, network security groups, user-defined routes, or route tables. The error message includes the specific reason why the cluster creation was blocked.

Note

Only you can manage the policies in your environment. Microsoft can't disable or bypass those policies.

## Solution

To fix this issue, follow these steps:

1. Find the policy that blocks the action. These policies are listed in the error message. The name of a policy assignment or definition is the last segment of the `id` string that's shown in the error message.

    ```
    # Example
    Code: RequestDisallowedByPolicy
    Message: Resource 'resourcegroup' was disallowed by policy. Policy identifiers: '[{"policyAssignment":{"name":"Not allowed resource types","id":"/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/policyAssignments/00000000000000000000000"},"policyDefinition":{"name":"Not allowed resource types","id":"/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/policyDefinitions/not-allowed-resourcetypes","version":"1.0.0"}}]'.
    ```
2. If possible, update your deployment to comply with the policy restrictions, and then retry the deployment. Alternatively, if you have permission to update policy, [add an exemption](/en-us/azure/governance/policy/tutorials/disallowed-resources#create-an-exemption) to the policy.

To get details about the policy that blocked your cluster deployment, see [RequestDisallowedByPolicy error with Azure resource policy](/en-us/azure/azure-resource-manager/troubleshooting/error-policy-requestdisallowedbypolicy).

Note

After you fix the policy that blocks the AKS cluster creation, run the `az aks update -g MyResourceGroup -n MyManagedCluster` command to change the cluster from a failed state to a successful state. This change reconciles the cluster and retries the last failed operation. For more information about clusters in a failed state, see [Troubleshoot Azure Kubernetes Service clusters or nodes in a failed state](../availability-performance/cluster-node-virtual-machine-failed-state).

## More information

[General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)