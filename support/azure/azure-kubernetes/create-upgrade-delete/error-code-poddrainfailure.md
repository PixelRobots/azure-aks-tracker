---
layout: Conceptual
title: Troubleshoot UpgradeFailed errors due to eviction failures caused by PDBs - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-poddrainfailure
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
description: Troubleshoot UpgradeFailed errors caused by Pod Disruption Budgets during AKS upgrades and restore cluster health. Follow steps to complete upgrade successfully.
ms.date: 2026-06-09T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: chiragpa, jotavar, v-leedennis, v-weizhu, andraciobanu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: a8f70c7d-2e21-c300-970c-90d740621947
document_version_independent_id: a8f70c7d-2e21-c300-970c-90d740621947
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-poddrainfailure.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-poddrainfailure
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-poddrainfailure.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 375bd557-ca72-5c32-01fe-38861d081498
---

# Troubleshoot UpgradeFailed errors due to eviction failures caused by PDBs - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve `UpgradeFailed` errors due to eviction failures caused by Pod Disruption Budgets (PDBs) that occur when you try to upgrade an Azure Kubernetes Service (AKS) cluster.

## Prerequisites

This article requires Azure CLI version 2.67.0 or a later version. To find the version number, run `az --version`. If you need to install or upgrade Azure CLI, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

For more detailed information about the upgrade process, see the "Upgrade an AKS cluster" section in [Upgrade an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/upgrade-cluster#upgrade-an-aks-cluster).

Tip

Before starting an AKS upgrade, run the **Upgrade readiness** check in the Azure portal:

**AKS cluster** &gt; **Settings** &gt; **Upgrades** &gt; **Upgrade version**

After selecting the target Kubernetes version, select **Check** next to **Upgrade readiness**. This pre-validation can identify potential upgrade blockers, including Pod Disruption Budget (PDB) configurations that might prevent successful node draining during the upgrade.

## Symptoms

An AKS cluster upgrade operation fails with one of the following error messages:

- > 
> (UpgradeFailed) Drain `node aks-<nodepool-name>-xxxxxxxx-vmssxxxxxx` failed when evicting pod `<pod-name>` failed with Too Many Requests error. This error is often caused by a restrictive Pod Disruption Budget (PDB) policy. See https://aka.ms/aks/debugdrainfailures. Original error: Cannot evict pod as it would violate the pod's disruption budget.. PDB debug info: `<namespace>/<pod-name>` blocked by pdb `<pdb-name>` with 0 unready pods.
- > 
> Code: UpgradeFailed Message: Drain node `aks-<nodepool-name>-xxxxxxxx-vmssxxxxxx` failed when evicting pod `<pod-name>` failed with Too Many Requests error. This error is often caused by a restrictive Pod Disruption Budget (PDB) policy. See https://aka.ms/aks/debugdrainfailures. Original error: Cannot evict pod as it would violate the pod's disruption budget.. PDB debug info: `<namespace>/<pod-name>` blocked by pdb `<pdb-name>` with 0 unready pods.

## Cause

This error occurs if a pod is protected by the Pod Disruption Budget (PDB) policy. In this situation, the pod resists being drained. After several attempts, the upgrade operation fails, and the cluster or node pool falls into a `Failed` state.

Check the PDB configuration: `ALLOWED DISRUPTIONS` value. The value should be `1` or greater. For more information, see [Plan for availability using pod disruption budgets](/en-us/azure/aks/operator-best-practices-scheduler#plan-for-availability-using-pod-disruption-budgets). For example, you can check the workload and its PDB as follows. You should observe the `ALLOWED DISRUPTIONS` column doesn't allow any disruption. If the `ALLOWED DISRUPTIONS` value is `0`, the pods aren't evicted and node drain fails during the upgrade process:

```console
$ kubectl get deployments.apps nginx
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   2/2     2            2           62s

$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7854ff8877-gbr4m   1/1     Running   0          68s
nginx-7854ff8877-gnltd   1/1     Running   0          68s

$ kubectl get pdb
NAME        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
nginx-pdb   2               N/A               0                     24s

```

You can also check for any entries in Kubernetes events by using the command `kubectl get events | grep -i drain`. A similar output shows the message "Eviction blocked by Too Many Requests (usually a pdb)":

```console
$ kubectl get events | grep -i drain
LAST SEEN   TYPE      REASON                    OBJECT                                   MESSAGE
(...)
32m         Normal    Drain                     node/aks-<nodepool-name>-xxxxxxxx-vmssxxxxxx   Draining node: aks-<nodepool-name>-xxxxxxxx-vmssxxxxxx
2m57s       Warning   Drain                     node/aks-<nodepool-name>-xxxxxxxx-vmssxxxxxx   Eviction blocked by Too Many Requests (usually a pdb): <pod-name>
12m         Warning   Drain                     node/aks-<nodepool-name>-xxxxxxxx-vmssxxxxxx   Eviction blocked by Too Many Requests (usually a pdb): <pod-name>
32m         Warning   Drain                     node/aks-<nodepool-name>-xxxxxxxx-vmssxxxxxx   Eviction blocked by Too Many Requests (usually a pdb): <pod-name>
32m         Warning   Drain                     node/aks-<nodepool-name>-xxxxxxxx-vmssxxxxxx   Eviction blocked by Too Many Requests (usually a pdb): <pod-name>
31m         Warning   Drain                     node/aks-<nodepool-name>-xxxxxxxx-vmssxxxxxx   Eviction blocked by Too Many Requests (usually a pdb): <pod-name>
```

To resolve this issue, use one of the following solutions.

## Solution 1: Enable pods to drain

1. Adjust the PDB to enable pod draining. Generally, the allowed disruption is controlled by the `Min Available / Max unavailable` or `Running pods / Replicas` parameter. Modify the `Min Available / Max unavailable` parameter at the PDB level or increase the number of `Running pods / Replicas` to push the Allowed Disruption value to **1** or greater.
2. Try again to upgrade the AKS cluster to the same version that you tried to upgrade to previously. This process triggers a reconciliation.

    ```console
    $ az aks upgrade --name <aksName> --resource-group <resourceGroupName>
    Are you sure you want to perform this operation? (y/N): y
    Cluster currently in failed state. Proceeding with upgrade to existing version 1.28.3 to attempt resolution of failed cluster state.
    Since control-plane-only argument is not specified, this will upgrade the control plane AND all nodepools to version . Continue? (y/N): y
    ```

## Solution 2: Back up, delete, and redeploy the PDB

Note

Use this solution if editing the PDB resource isn't a viable option.

1. Back up the PDBs by running the following command:

    `kubectl get pdb <pdb-name> -n <pdb-namespace> -o yaml > pdb-name-backup.yaml`and
2. Delete the PDB by running the following command:

    `kubectl delete pdb <pdb-name> -n <pdb-namespace>`
3. After the new upgrade attempt finishes, redeploy the PDB by applying the backup file using the following command:

    `kubectl apply -f pdb-name-backup.yaml`.
4. Try to upgrade the AKS cluster to the same version again that you tried to upgrade to previously. This process triggers a reconciliation.

    ```console
    $ az aks upgrade --name <aksName> --resource-group <resourceGroupName>
    Are you sure you want to perform this operation? (y/N): y
    Cluster currently in failed state. Proceeding with upgrade to existing version 1.28.3 to attempt resolution of failed cluster state.
    Since control-plane-only argument is not specified, this will upgrade the control plane AND all nodepools to version . Continue? (y/N): y
    ```

## Solution 3: Delete the pods that you can't drain or scale the workload down to zero

1. Delete the pods that you can't drain.

Note

If a Deployment or StatefulSet creates the pods, a ReplicaSet controls them. If that's the case, you might need to delete or scale the workload replicas to zero for the Deployment or StatefulSet. Before you make this change, back up the resource by running: `kubectl get <deployment.apps -or- statefulset.apps> <name> -n <namespace> -o yaml > backup.yaml`.

1. To scale down the workload, use `kubectl scale --replicas=0 <deployment.apps -or- statefulset.apps> <name> -n <namespace>`.
2. Try again to upgrade the AKS cluster to the same version that you tried to upgrade to previously. This process triggers a reconciliation.

    ```console
    $ az aks upgrade --name <aksName> --resource-group <resourceGroupName>
    Are you sure you want to perform this operation? (y/N): y
    Cluster currently in failed state. Proceeding with upgrade to existing version 1.28.3 to attempt resolution of failed cluster state.
    Since control-plane-only argument is not specified, this will upgrade the control plane AND all nodepools to version . Continue? (y/N): y
    ```