---
layout: Conceptual
title: Istio service mesh add-on minor revision upgrade troubleshooting - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-minor-revision-upgrade
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: SanyaKochhar
ms.author: kochhars
ms.topic: troubleshooting
description: Learn how to do minor revision upgrade troubleshooting on the Istio service mesh add-on for Azure Kubernetes Service (AKS).
ms.date: 2025-02-07T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: fuyuanbie, shasb, nshankar, ddama, v-leedennis, v-weizhu
ms.custom: sap:Extensions, Policies and Add-Ons
ms.service: azure-kubernetes-service
locale: en-us
document_id: 87527bf9-ee80-239a-201a-1f3ee41b0f8f
document_version_independent_id: 87527bf9-ee80-239a-201a-1f3ee41b0f8f
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/istio-add-on-minor-revision-upgrade.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/istio-add-on-minor-revision-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/istio-add-on-minor-revision-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c3db0b67-de5e-b804-fd27-8272a161cd0d
---

# Istio service mesh add-on minor revision upgrade troubleshooting - Azure | Microsoft Learn

## Summary

This article discusses troubleshooting scenarios and restrictions in the minor revision upgrade and rollback processes for the Istio service mesh add-on in Microsoft Azure Kubernetes Service (AKS).

Note

Istio uses the term "revisions" to implement the canary upgrade process and distinguish between versions. Each revision designation (written as *x*-*y*) corresponds to a major.minor version designation (*x*.*y*). You can control your control plane revision, but you can't control the specific patch version within a revision band.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool, or a similar tool to connect to the cluster. To install kubectl by using [Azure CLI](/en-us/cli/azure/install-azure-cli), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.

## Troubleshooting matrix

The following table lists various problems and the different scenarios and solutions for those problems.

| Scenario | Problem | Solution |
| --- | --- | --- |
| Data plane workloads are dropped from the mesh. | Data plane and control plane revisions didn't correspond before you completed or rolled back an upgrade. | Follow these steps:<br><br>1. Relabel namespaces that contain workloads by specifying the revision that's expected to exist after the upgrade completion or rollback:<br><br><br>    ```<br>    kubectl label namespace default istio.io/rev=asm-x-y --overwrite<br>    ```<br>2. Restart the corresponding workload deployments using the [kubectl rollout restart](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/kubectl_rollout_restart/) command to trigger sidecar reinjection of the correct revision:<br><br><br>    ```<br>    kubectl rollout restart deployment <deployment name><br>    ```<br>3. Verify that the sidecar images exist using the [kubectl get](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_get/) command:<br><br><br>    ```<br>    kubectl get pods --namespace <namespace> --output yaml | grep mcr.microsoft.com/oss/istio/proxyv2:<br>    ``` |
| Control plane pods are in the pending state. | The pods lack capacity. | Verify the state of the pods by running the [kubectl describe](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_describe/) command. If capacity is the problem, you can scale up your cluster to add another node. For more information, see [Manually scale the node count in an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/scale-cluster). |
| The [az aks mesh get-upgrades](/en-us/cli/azure/aks/mesh#az-aks-mesh-get-upgrades) command returns no available upgrades. | The next Istio revision might be incompatible with the current AKS cluster version. | You can use the [az aks mesh get-revisions](/en-us/cli/azure/aks/mesh#az-aks-mesh-get-revisions) command to discover whether newer Istio revisions exist. The output includes a list of compatible cluster versions for each Istio revision. Therefore, you can determine whether a cluster upgrade is necessary. If *both* mesh and cluster are no longer supported, upgrade the cluster version first, and then the mesh revision. To recover from this scenario, a cluster upgrade is permitted even if it's incompatible with the mesh revision. |

Note

To avoid unintended behavior and broken functionality, and also make sure that you're receiving updates for security vulnerabilities, we strongly recommend that you upgrade to a supported and up-to-date [AKS version](/en-us/azure/aks/supported-kubernetes-versions) and Istio add-on revision. Remember that the add-on revision should also be within the supported Kubernetes version range for the given AKS cluster. As highlighted in the [Minor revision upgrade](/en-us/azure/aks/istio-upgrade#minor-revision-upgrade) section of the Istio upgrade article, you can run the `az aks mesh get-revisions` and `az aks mesh get-upgrades` commands to learn about available add-on revisions, upgrades, and compatibility information.

## Restrictions

- A downgrade to an older revision (outside the canary rollback process) isn't allowed.
- Available upgrades for a revision depend on whether it's currently supported. For example, if `n` is the currently installed revision and `n+2` is the latest revision:

    - If `n` is supported, you may upgrade to the next revision `n+1` or directly to the newest revision `n+2`.
    - If both `n` and `n+1` (next consecutive) are unsupported, the only available upgrade is `n+2` (next supported).
    - If `n` has been unsupported for a while, it's possible both of the next two consecutive revisions are unsupported. In this case, the only available upgrade is the lowest supported revision.
- The Istio `sidecar.istio.io/inject` label doesn't enable sidecar injection for the Istio add-on. You must use the `istio.io/rev` label when you label and relabel your namespaces during the canary upgrade.
- Labeling must occur on a namespace level instead of on a per-deployment level. If you want to be able to roll over pods individually, you can choose to restart individual deployments instead of using pod labeling.
- If you're using the Istio add-on Shared MeshConfig, you have to copy or transfer MeshConfig settings to the new ConfigMap before you do a canary upgrade. For more information, see [Mesh configuration and upgrades](/en-us/azure/aks/istio-meshconfig#mesh-configuration-and-upgrades).
- The Istio add-on deploys Istio ingress gateway pods and deployments per revision. If you're doing a [canary upgrade](https://istio.io/latest/docs/setup/upgrade/canary/) and have two control plane revisions installed in your cluster, you might have to troubleshoot multiple ingress gateway pods across both revisions.

## References

- [Safely upgrade the Istio control plane with revisions and tags](https://istio.io/v1.16/blog/2021/revision-tags/)
- [General Istio service mesh add-on troubleshooting](istio-add-on-general-troubleshooting)
- [Istio service mesh add-on MeshConfig troubleshooting](istio-add-on-meshconfig)
- [Istio service mesh add-on ingress gateway troubleshooting](istio-add-on-ingress-gateway)
- [Istio service mesh add-on plug-in CA certificate troubleshooting](istio-add-on-plug-in-ca-certificate)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.