---
layout: Conceptual
title: Troubleshoot Azure Kubernetes Service pod scheduler errors - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/troubleshoot-pod-scheduler-errors
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
description: Learn how to troubleshoot AKS pod scheduler errors, understand common causes, and apply proven fixes to get pods running. Start resolving issues now.
ms.date: 2025-06-30T00:00:00.0000000Z
ms.reviewer: 
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
locale: en-us
document_id: e9d0cfa0-8bec-bb9e-4704-b9f3b9094c02
document_version_independent_id: e9d0cfa0-8bec-bb9e-4704-b9f3b9094c02
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/troubleshoot-pod-scheduler-errors.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/troubleshoot-pod-scheduler-errors
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/troubleshoot-pod-scheduler-errors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: ba33c684-8207-db10-a8fa-a8b663e80aeb
---

# Troubleshoot Azure Kubernetes Service pod scheduler errors - Azure | Microsoft Learn

## Summary

When you deploy workloads in Azure Kubernetes Service (AKS), you might encounter scheduler errors that prevent pods from running. This article provides solutions to common scheduler errors.

## Error: 0/(X) nodes are available: Y node(s) had volume node affinity conflict

Note

X and Y represent the number of nodes. These values depend on your cluster configuration.

Pods remain in the Pending state with the following scheduler error message:

> 
> 0/(X) nodes are available: Y node(s) had volume node affinity conflict.

### Cause

[Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#node-affinity) define `nodeAffinity` rules that restrict which nodes can access the volume. If none of the available nodes satisfy the volume's affinity rules, the scheduler can't assign the pod to any node.

### Solution

1. Review the node affinity set on your Persistent Volume resource:

    ```bash
     kubectl get pv <pv-name> -o yaml 
    ```
2. Check node labels in the cluster:

    ```bash
    kubectl get nodes --show-labels
    ```
3. Make sure that at least one node's labels match the `nodeAffinity` specified in the Persistent Volume's YAML spec.
4. To resolve the conflict, update the Persistent Volume's `nodeAffinity` rules to match existing node labels or add the required labels to the correct node:

    ```bash
    kubectl label nodes <node-name> <key>=<value>
    ```

    Or, modify the PV's affinity rules to match existing node labels.
5. After resolving the conflict, monitor the Pod status or retry the deployment.

## Error: 0/(X) nodes are available: Insufficient CPU

Pods remain in the Pending state with the scheduler error:

> 
> Error: 0/(X) nodes are available: Insufficient CPU.

### Cause

This issue occurs when one or more of the following conditions are met:

- All node resources are in use.
- The pending Pod's resource requests exceed available CPU on the nodes.
- The node pools lack sufficient resources or have incorrect configuration settings.

### Solution

1. Review CPU usage on all nodes and verify if there's enough unallocated CPU to meet the pod's request.

    ```bash
    kubectl describe pod <pod-name>
    kubectl describe nodes
    ```
2. If no node has enough CPU, increase the number of nodes or use larger VM sizes in the node pool.

    ```bash
    
    az aks nodepool scale \
      --resource-group <resource-group> \
      --cluster-name <aks-name> \
      --name <nodepool-name> \
      --node-count <desired-node-count>
    ```
3. Optimize pod resource requests. Make sure that CPU requests and limits are appropriate for your node sizes.
4. Verify if any scheduling constraints are restricting pod placement across available nodes.

## Error: 0/(X) nodes are available: Y node(s) had untolerated taint

Pods remain in the Pending state with the error message:

> 
> Error: 0/(X) nodes are available: Y node(s) had untolerated taint.

### Cause

The Kubernetes scheduler tries to assign the pod to a node, but all nodes are rejected for one of the following reasons:

- The node has a taint (`key=value:effect`) that the pod doesn't tolerate.
- The node has other taint-based restrictions that prevent the pod from being scheduled.

### Solution

1. Check node taints.

    ```bash
     kubectl get nodes -o json | jq '.items[].spec.taints'   
    ```
2. Add necessary tolerations to the Pod spec: Edit your deployment or Pod YAML to include matching tolerations for the taints on your nodes. For example, if your node has the taint `key=value:NoSchedule`, your Pod spec must include:

    ```yml
    tolerations:
      - key: "key"
        operator: "Equal"
        value: "value"
        effect: "NoSchedule"
    ```

    If the taint isn't needed, remove it from the node:

    ```bash
    kubectl taint nodes <node-name> <key>:<effect>-  
    ```
3. Redeploy or monitor the Pod status.

    ```bash
    kubectl get pods -o wide  
    ```

## Reference

- [Kubernetes: Use Azure Disks with Azure Kubernetes Service](/en-us/azure/aks/azure-disks-dynamic-pv)
- [Kubernetes: Use node taints](/en-us/azure/aks/use-node-taints)
- [Kubernetes Documentation: Insufficient CPU](https://kubernetes.io/docs/concepts/scheduling-eviction/resource-bin-packing/#insufficient-resource)
- [Kubernetes Documentation: Assign and Schedule Pods with Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.