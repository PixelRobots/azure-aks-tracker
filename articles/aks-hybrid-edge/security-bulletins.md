---
layout: Conceptual
title: Security bulletins for AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/security-bulletins
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
description: Security vulnerability advisories and mitigation guidance for AKS Hybrid and Edge.
author: leslielin
ms.author: leslielin
ms.topic: concept-article
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: overview
locale: en-us
document_id: a3211000-7771-d80e-d782-ae15cd93d06a
document_version_independent_id: 6df9f622-8001-793c-38ae-7c101bf6e910
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/security-bulletins.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../aks/toc.json
asset_id: aks-hybrid-edge/security-bulletins
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/security-bulletins.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
platformId: 0d1e9ad5-5481-45fa-fb6d-f3db4e056bf4
---

# Security bulletins for AKS Hybrid and Edge | Microsoft Learn

This article provides information on security vulnerabilities that affect AKS Hybrid and Edge and its components. This information includes details on:

- **Critical Security Advisories:** High-impact security vulnerabilities, including zero-day vulnerabilities and other critical CVEs that require immediate attention, along with mitigation guidance.
- **Ongoing Security Investigations:** Security issues under review, including CVEs where a patch isn't yet available or further assessment is needed.
- **False Positives & Non-Exploitable CVEs:** Cases where a reported CVE doesn't impact AKS Hybrid and Edge due to specific configurations, mitigations, or lack of exploitability.

Note

For security bulletins that affect AKS in Azure, see [Security bulletins for Azure Kubernetes Service (AKS)](/en-us/azure/aks/security-bulletins/overview).

## AKSARC-2026-0001: Advisory and Mitigation Guide for CVE-2026-31431 (Copy Fail)

**Last updated**: May 18, 2026

### Description

This bulletin provides an update on a local privilege escalation (LPE) vulnerability that was publicly disclosed on April 29, 2026. The vulnerability affects the Linux kernel's `algif_aead` module. It has been assigned **CVE-2026-31431** and is referred to as **"Copy Fail"**.

- **CVSS Score**: 7.8 HIGH (`CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`)
- **Attack Vector**: Local — requires code execution on the node, for example, from a container
- **Affected Component**: `algif_aead` kernel module (hardware-accelerated cryptographic functions)
- **Canonical Advisory**: [Fixes available for Copy Fail vulnerability](https://ubuntu.com/blog/copy-fail-vulnerability-fixes-available)

### References

- [CVE-2026-31431](https://nvd.nist.gov/vuln/detail/CVE-2026-31431)
- [AKS Advisory](https://github.com/Azure/AKS/issues/5753)

### Affected Components

# [AKS on Azure Local](#tab/azure-local)
**Affected Versions**

- All current AKS on Azure Local Linux nodes are exploitable. Microsoft is working on integrating this fix into a future Azure Local update. In the meantime, follow the remediation steps in this article.
- Although `algif_aead` isn't loaded by default on AKS nodes, the Linux kernel's module autoloading mechanism (`request_module`) **automatically loads it on demand**. Any process, **including unprivileged containers**, can trigger this mechanism by creating an AF\_ALG socket with AEAD type. This condition means:
- **An attacker with code execution in any pod, even non-root, can escalate to root on the node.**
- No special pod privileges, capabilities, or host access are required.

**Resolutions**

Choose one of the following remediation paths.

#### Option A: Patch your Azure Local instance (recommended)

This option patches VHD images at the Azure Local level. After patching, upgrade each AKS cluster to refresh nodes with the patched VHDs.

##### Step 1: Upgrade Azure Local (if needed)

If your Azure Local deployment is on version 2601 or earlier, upgrade to 2602 or later before you continue. For upgrade guidance, see [Azure Local update documentation](/en-us/azure/azure-local/update/about-updates-23h2).

##### Step 2: Run the remediation command

1. Install the [AKS Support Tool](/en-us/azure/aks/aksarc/support-module) and run `az login` on your Azure Local node.
2. Run the remediation command:

    ```powershell
    Invoke-SupportAksArcRemediation_FixCVE_2026_31431
    ```

    When complete, you see a confirmation message indicating that the update was applied or that no update is needed.

    Note

    After the command completes, wait 10-15 minutes for the new VHD images to download to your Azure Local deployment before proceeding to step 3.

##### Step 3: Upgrade AKS clusters

Upgrade each AKS cluster to refresh nodes with patched VHDs. Use the following table to determine your upgrade path.

| Current K8s version | Supported versions for Azure Local 2602 |
| --- | --- |
| 1.30 or earlier | 1.31.12, 1.31.13 |
| 1.31.12 | 1.31.13, 1.32.8, 1.32.9 |
| 1.31.13 | 1.32.8, 1.32.9 |
| 1.32.8 | 1.32.9, 1.33.4, 1.33.5 |
| 1.32.9 | 1.33.4, 1.33.5 |
| 1.33.4 | 1.33.5 |
| 1.33.5 (latest) | No upgrade available - use Option B |

To upgrade your cluster, follow the steps in [Upgrade the Kubernetes version](/en-us/azure/aks/aksarc/cluster-upgrade#upgrade-the-kubernetes-version). For the full version list, see [Supported Kubernetes versions](/en-us/azure/aks/aksarc/supported-kubernetes-versions#aks-arc-supported-kubernetes-minor-and-patch-versions-per-release).

After the upgrade completes, verify that all nodes are running the new image:

```bash
kubectl get nodes -o wide
```

#### Option B: Self-service mitigation (alternative)

If you can't upgrade Azure Local or your AKS clusters immediately, apply this per-cluster mitigation. This process blocks the vulnerable kernel module from loading without requiring an Azure Local update or Kubernetes upgrade. Apply this mitigation to each existing cluster that needs protection. New clusters also require this mitigation until you complete Option A.

Apply the self-service mitigation described in the [AKS Advisory](https://github.com/Azure/AKS/issues/5753). Once you upgrade your clusters and validate that the kernel includes the fix, you can remove the mitigation by following the cleanup steps in the same advisory.

---