---
layout: Conceptual
title: Istio Service Mesh Add-on CNI Troubleshooting - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-cni-troubleshooting
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
description: Troubleshoot Istio CNI add-on issues in Azure Kubernetes Service (AKS) and restore reliable pod networking and sidecar startup. Follow these steps.
ms.date: 2025-10-22T00:00:00.0000000Z
ms.reviewer: gerobayopaz, kochhars
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 86fcb245-76b5-6846-f558-211b61a10ca5
document_version_independent_id: 86fcb245-76b5-6846-f558-211b61a10ca5
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/istio-add-on-cni-troubleshooting.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/istio-add-on-cni-troubleshooting
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/istio-add-on-cni-troubleshooting.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: b424cdba-0a6e-1505-a335-fc739934960c
---

# Istio Service Mesh Add-on CNI Troubleshooting - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot [Istio CNI](/en-us/azure/aks/istio-cni) issues in Azure Kubernetes Service (AKS) so you can resolve pod startup and traffic redirection problems quickly.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli)
- The `aks-preview` Azure CLI extension version 19.0.0b5 or later:

    ```azurecli
    az extension add --name aks-preview
    ```

    If you already have the `aks-preview` extension installed, update it to the latest version:

    ```azurecli
    az extension update --name aks-preview
    ```
- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) CLI, or a similar tool to connect to the cluster

    Alternatively, you can install kubectl using Azure CLI by using the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- Make sure that your Istio service mesh uses revision `asm-1-25` or a later version. To check the current revision, run the following command:

    ```azurecli
    az aks show --resource-group <resource-group-name> --name <cluster-name> --query 'serviceMeshProfile.istio.revisions'
    ```
- Make sure that Istio CNI is enabled in your cluster:

    ```azurecli
    az aks show --resource-group <resource-group-name> --name <cluster-name> --query "serviceMeshProfile.istio.components.proxyRedirectioMechanism" -o table
    ```

    The command output should be `CNIChaining`. If the add-on isn't enabled, refer to [this guide to Istio CNI](/en-us/azure/aks/istio-cni).

## Troubleshoot CNI DaemonSet provisioning issues

### Step 1: Verify that the Istio CNI DaemonSet is provisioned and ready

Check that the CNI DaemonSet is deployed and that all pods are running:

```bash
kubectl get daemonset azure-service-mesh-istio-cni-addon-node -n aks-istio-system
kubectl get pods -n aks-istio-system -l k8s-app=azure-service-mesh-istio-cni-addon-node
```

You should see a DaemonSet that has pods that run on each node in your cluster.

### Step 2: Check CNI DaemonSet pod logs

To identify any installation or configuration issues, examine the logs of the CNI DaemonSet pods:

```bash
kubectl logs -n aks-istio-system -l k8s-app=azure-service-mesh-istio-cni-addon-node
```

Look for error messages that are related to the following items:

- CNI plugin installation failures
- Network configuration errors
- Permission or file system issues
- Node-specific issues

### Step 3: Check for node taints and tolerations

Verify that the CNI DaemonSet can be scheduled on all nodes:

```bash
kubectl describe daemonset istio-cni-node -n aks-istio-system
kubectl get nodes -o wide
kubectl describe nodes
```

Look for node taints that might prevent CNI pod scheduling, and make sure that the DaemonSet has appropriate tolerations.

## Troubleshoot init container injection issues

### Step 1: Check whether istio-init containers are still injected

For newly created pods in the mesh, verify that `istio-init` containers are no longer present:

```bash
# Check a sample pod in an injected namespace
kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.initContainers[*].name}{"\n"}{end}'
```

If `istio-init` containers are still being injected, CNI isn't working correctly.

### Step 2: Inspect pod events for CNI-related errors

Check pod events for any CNI plugin failures during pod startup:

```bash
kubectl describe pod $POD_NAME -n $NAMESPACE
```

Look for events that are related to the following items:

- Network setup failures
- CNI plugin errors
- Container creation issues

### Step 3: Verify istio-proxy sidecar startup

Check whether the `istio-proxy` sidecar container starts successfully without the init container:

```bash
kubectl logs $POD_NAME -n $NAMESPACE -c istio-proxy
```

If CNI is working correctly, the sidecar should start normally even without the `istio-init` container.

## Troubleshoot pod startup failures

If pods don't start, check for `istio-validation` init container errors:

```bash
kubectl logs $POD_NAME -n $NAMESPACE -c istio-validation
```

Look for "connection refused" error messages that indicate failures in traffic redirection setup.

## References

[Open-source Istio's CNI troubleshooting](https://istio.io/latest/docs/ops/diagnostic-tools/cni/)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.