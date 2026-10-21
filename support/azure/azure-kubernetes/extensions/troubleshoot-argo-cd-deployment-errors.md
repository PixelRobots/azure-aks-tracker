---
layout: Conceptual
title: Troubleshoot GitOps with Argo CD extension deployment errors - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-argo-cd-deployment-errors
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
description: Learn how to troubleshoot and fix GitOps with Argo CD extension installation and deployment errors on AKS and Azure Arc-enabled Kubernetes clusters.
ms.service: azure-kubernetes-service
ms.date: 2026-09-28T00:00:00.0000000Z
ms.subservice: aks-developer
ms.reviewer: ponatara
ai-usage: ai-assisted
locale: en-us
document_id: 47224298-beed-e474-7f81-e44b22b00e41
document_version_independent_id: 47224298-beed-e474-7f81-e44b22b00e41
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-argo-cd-deployment-errors.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-argo-cd-deployment-errors
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-argo-cd-deployment-errors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 1453a9e4-ea92-1a3b-d332-f04d59f922ed
---

# Troubleshoot GitOps with Argo CD extension deployment errors - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot common issues when you install and operate the GitOps with Argo CD extension on Azure Kubernetes Service (AKS) and Azure Arc-enabled Kubernetes clusters.

## Errors when installing the GitOps with Argo CD extension

If you encounter an installation error, or if the extension enters a `Failed` provisioning state, verify the following items:

- The cluster has sufficient compute capacity to deploy all required Argo CD components.
- No Azure Policy, Gatekeeper, Kyverno, or admission controller policies are blocking creation of the `argocd` namespace or resources within it.
- Required Custom Resource Definitions (CRDs) can be installed.
- The cluster can pull container images from Azure Container Registry (ACR).
- The cluster can reach Azure management endpoints required by the extension.

## Scenario 1: Installation fails with context deadline exceeded error

### Symptoms

The extension installation fails with an error similar to the following message.

```
(ExtensionOperationFailed) Helm installation failed: context deadline exceeded
```

### Cause

This error typically indicates that the Helm installation timed out while waiting for Argo CD pods to become ready.

A common cause is deploying the extension with **High Availability (HA)** enabled on clusters that don't have sufficient node capacity. HA deployments require multiple replicas of core Argo CD components and generally need at least four schedulable worker nodes.

Other causes include the following:

- Insufficient CPU or memory on cluster nodes
- Pending pods due to resource constraints
- Image pull failures
- Storage provisioning delays
- Network connectivity issues preventing component startup

### Resolution

1. Verify pod status. Run the following command.

    ```bash
    kubectl get pods -n argocd
    ```
2. Check for pending or failed pods. Run the following command.

    ```bash
    kubectl describe pod <pod-name> -n argocd
    ```
3. Review extension deployment logs and Kubernetes events. Run the following command.

    ```bash
    kubectl get events -n argocd --sort-by=.lastTimestamp
    ```
4. If HA is enabled, do one of the following:

    - Reinstall the extension with HA disabled.
    - Increase cluster capacity to support the required replicas.
5. Retry installation after resolving resource constraints.

## Scenario 2: Installation fails because the argocd namespace can't be created

### Symptoms

The extension installation fails and the extension remains in a `Failed` state.

### Cause

Cluster governance policies might block creation of the `argocd` namespace or resources that the extension needs.

Examples include the following items:

- Azure Policy constraints
- Gatekeeper admission policies
- Kyverno policies
- Namespace allow-list restrictions
- Resource quota limitations

### Resolution

1. Verify whether the namespace exists. Run the following command.

    ```bash
    kubectl get namespace argocd
    ```
2. Check admission controller or policy violations. Run the following command.

    ```bash
    kubectl get events --all-namespaces
    ```
3. Review policy configuration and ensure resources in the `argocd` namespace are permitted. Update the policy configuration if necessary.
4. Retry the extension installation after updating the policy configuration.

## Scenario 3: Pods remain in Pending state after installation

### Symptoms

The extension is created, but some Argo CD pods never become Ready.

### Cause

Kubernetes can't successfully schedule the pods.

Common reasons include the following:

- Insufficient CPU or memory
- Taints preventing scheduling
- Unsatisfied node selectors or affinity rules
- Persistent volume provisioning failures

### Resolution

Inspect pod scheduling information. Run the following command.

```bash
kubectl describe pod <pod-name> -n argocd
```

Review scheduler events and resolve any reported scheduling constraints.

## Scenario 4: Container image pull failures

### Symptoms

Pods enter an `ImagePullBackOff` or `ErrImagePull` status.

### Cause

The cluster can't pull required images from Microsoft Container Registry (MCR).

Common causes include the following items:

- Firewall restrictions
- Proxy misconfiguration
- DNS resolution failures
- Missing outbound connectivity

### Resolution

Check pod details. Run the following command.

```bash
kubectl describe pod <pod-name> -n argocd
```

Verify that nodes can reach required MCR endpoints and that any proxy settings are correctly configured.

## Scenario 5: CRD installation failures

### Symptoms

The installation fails while creating Argo CD custom resources.

### Cause

The installation of one or more required CRDs failed.

Potential reasons include the following items:

- Existing conflicting CRDs
- Insufficient permissions
- Admission policy restrictions

### Resolution

Check the CRD status. Run the following command.

```bash
kubectl get crds | grep argoproj.io
```

Review Kubernetes events and admission controller logs for more details.

## Scenario 6: Extension is installed but shows a Failed provisioning state

### Symptoms

The extension resource exists in Azure, but the provisioning state shows `Failed`.

### Cause

The extension deployment completed partially, but one or more validation or health checks didn't succeed.

### Resolution

Review the extension status. Run the following command.

```azurecli
az k8s-extension show \
  --cluster-name <cluster-name> \
  --resource-group <resource-group> \
  --cluster-type connectedClusters \
  --name <extension-name>
```

Inspect Argo CD pod health. Run the following command.

```bash
kubectl get pods -n argocd
```

Resolve any unhealthy components, and then refresh or re-create the extension.

## Scenario 7: Extension upgrade fails

### Symptoms

An extension upgrade operation remains stuck or fails.

### Cause

Upgrade failures can occur when one of the following conditions is true:

- Cluster capacity is insufficient.
- Existing workloads are unhealthy.
- Previous extension resources are in an inconsistent state.
- Admission policies block modified resources.

### Resolution

Follow these steps to troubleshoot and resolve extension upgrade failures.

1. Verify that all existing Argo CD components are healthy.
2. Review extension operation status in Azure.
3. Check Kubernetes events and pod logs.
4. Resolve any reported issues and retry the upgrade.

## Scenario 8: Workload Identity integration isn't functioning

### Symptoms

Applications managed through Argo CD can't authenticate to Azure resources by using Workload Identity.

### Cause

One or more Workload Identity configuration steps are missing or incorrect.

### Resolution

Verify the following configuration:

- The AKS or Arc-enabled cluster has **Workload Identity** enabled.
- Federated identity credentials are configured correctly.
- Service accounts contain the required annotations.
- Managed identities have appropriate Azure role-based access control (RBAC) permissions.

Review pod logs for authentication-related errors.

## Collect diagnostic information

Before opening a Microsoft Support request, gather the following information. Run the following commands.

```bash
kubectl get pods -n argocd
```

```bash
kubectl get events -n argocd --sort-by=.lastTimestamp
```

```bash
kubectl describe pod <pod-name> -n argocd
```

```bash
kubectl logs <pod-name> -n argocd
```

```azurecli
az k8s-extension show \
  --name <extension-name> \
  --cluster-name <cluster-name> \
  --resource-group <resource-group>
```