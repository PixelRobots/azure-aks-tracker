---
layout: Conceptual
title: Troubleshoot the MissingSubscriptionRegistration error - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-missingsubscriptionregistration
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
description: Describes how to troubleshoot the MissingSubscriptionRegistration error when you try to create and deploy an Azure Kubernetes Service (AKS) cluster.
ms.date: 2026-07-21T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, erbookbi, v-leedennis, addobres
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: b883d33d-b2fb-8eb8-f21a-09ea8ef5d710
document_version_independent_id: b883d33d-b2fb-8eb8-f21a-09ea8ef5d710
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-missingsubscriptionregistration.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-missingsubscriptionregistration
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-missingsubscriptionregistration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: a0de8225-6fd7-cd22-3925-a30c1c1edfae
---

# Troubleshoot the MissingSubscriptionRegistration error - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `MissingSubscriptionRegistration` error that occurs when you try to create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you try to deploy an AKS cluster, you receive the following error message:

> 
> Code="MissingSubscriptionRegistration"
> 
> Message="**The subscription is not registered to use namespace 'Microsoft.OperationsManagement'.** See https://aka.ms/rps-not-found for how to register subscriptions."
> 
> Details=[{
> 
> "code": "MissingSubscriptionRegistration",
> 
> "message": "The subscription is not registered to use namespace 'Microsoft.OperationsManagement'. See https://aka.ms/rps-not-found for how to register subscriptions.",
> 
> "target": "Microsoft.OperationsManagement"
> 
> }]

## Cause

You receive this error message for one of the following reasons:

- The required resource provider isn't registered for your subscription.
- The API version isn't supported for the resource type.
- The location isn't supported for the resource type.

## Solution

To resolve this issue, follow the instructions in the "Solution" section of [Resolve errors for resource provider registration](/en-us/azure/azure-resource-manager/troubleshooting/error-register-resource-provider?tabs=azure-portal#solution). Replace the existing namespace with the namespace that's shown in the error message. In the example in the "Symptoms" section, the namespace is `Microsoft.OperationsManagement`.

## More information

- [General troubleshooting of AKS cluster creation issues](troubleshoot-aks-cluster-creation-issues)