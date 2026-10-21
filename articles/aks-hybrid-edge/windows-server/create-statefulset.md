---
layout: Conceptual
title: Create StatefulSets in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/create-statefulset
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
description: Learn how to create StatefulSets in Azure Kubernetes Service (AKS) on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: EkeleAsonye
ms.custom: windows-server
locale: en-us
document_id: 6b0bfec8-f668-26c4-ea32-a05c7e7b6ead
document_version_independent_id: a5358407-97e7-3543-2d10-e48be9fca6e1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/create-statefulset.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/create-statefulset
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/create-statefulset.md
platformId: a7248340-225b-47c7-d6a9-0407ea77f9c3
---

# Create StatefulSets in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to create, update, and delete *StatefulSets*, which are used to maintain the state of an application beyond a pod lifecycle in an AKS deployment in AKS on Windows Server.

## Overview of StatefulSets

StatefulSets maintain the state of applications beyond an individual pod lifecycle. Like deployments, a StatefulSet creates and manages at least one identical pod with unique, persistent identities and stable host names. Replicas in a StatefulSet follow a sequential approach to deployment, scale, and upgrade.

A StatefulSet is useful for applications that require stable and unique identifiers, persistent storage, an ordered deployment, and scaling. Examples of these apps include MySQL, MongoDB, Kafka, and Cassandra. Stateless applications, such as Apache and Tomcat, aren't concerned with what network they're using and do not require persistent storage.

The main components of StatefulSets are the persistent volume provisioner and the headless service. For more information, see [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/).

## How to create a StatefulSet

You can create a StatefulSet using the `kubectl create` or the `kubectl apply` command. For example:

```powershell
kubectl create –f statefulset.yaml
```

In the same manifest YAML file, you can also create the headless service that the StatefulSet uses.

To view the components you created for your StatefulSet, run the following command:

```powershell
kubectl get statefulset
```

If you want to view persistent volumes, run `kubectl get pv`. To view a persistent volume claim, run `kubectl get pvc`.

## Update StatefulSets

To update a StatefulSet, edit the manifest file, and run the same command used when creating the StatefulSet: `kubectl apply –f statefulset.yaml`.

You can use either an **OnDelete** update or a **rolling** update as the update strategy:

- With an OnDelete update, pods are not replaced when you apply the manifest, but you must manually delete existing StatefulSet pods before the new version is created.
- In a rolling update, StatefulSet pods are removed and then replaced in reverse ordinal order when you apply the manifest.

## Delete a StatefulSet

Use the `kubectl delete` command to delete a StatefulSet and to delete the headless service separately. To delete the StatefulSet, run the following command:

```powershell
kubectl delete statefulset <statefulset_NAME>
```

Then, to delete the headless service, run the following command:

```powershell
kubectl delete service <svc_NAME>
```

To delete the persistent volume and the persistent volume claim, use the `kubectl delete pv` and `kubectl delete pvc` commands, respectively. To prevent data loss, the persistent volume and persistent volume claim aren't deleted when a StatefulSet is deleted.