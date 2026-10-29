---
layout: Conceptual
title: Secure your data in Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-secure-your-data
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2026-07-17T00:00:00.0000000Z
ms.topic: concept-article
ai-usage: ai-assisted
description: Best practices for protecting data at rest and in transit in Azure Arc-enabled Kubernetes clusters.
locale: en-us
document_id: d963edc0-ee2b-1762-ee43-3b6b2a8d9e76
document_version_independent_id: a26d64e0-4edb-0e3d-bc95-fbbd4911f8fa
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-secure-your-data.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-secure-your-data
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-secure-your-data.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6a558a65-50d5-1636-eaae-0fb812a899f9
---

# Secure your data in Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

Protecting your data is essential for maintaining confidentiality, integrity, and availability in your Kubernetes environment. This article outlines strategies for securing secrets, encrypting data at rest and in transit, and planning for cluster recovery. By following these practices, you can help safeguard sensitive information and support business continuity.

## Use a vault to store your secrets and sync to the cluster as needed

Keep secret values (passwords, keys, etc.) in a vault, such as [Azure Key Vault](/en-us/azure/key-vault/general/overview). It's good practice for such secrets never to leave the vault, and to be used only for signing/crypto operations inside the vault itself. However, for on-premises clusters, you may not be able to reliably maintain your cloud connection to this vault and hence maintain your ability always to use secrets when they're needed.

If so, consider using the [Azure Key Vault Secret Store extension for Kubernetes](/en-us/azure/azure-arc/kubernetes/secret-store-extension) ("SSE"). This extension can help automatically synchronize selected secrets from an Azure Key Vault and store them for offline use in the Kubernetes secrets store of an Azure Arc-enabled Kubernetes cluster.

### References

- [CIS Kubernetes Benchmark - Sections 1, 2, and 4](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST Application Container Security Guide - Section 4.5.1-3](https://csrc.nist.gov/pubs/sp/800/190/final)

## Protect the Kubernetes secrets store

On Azure Local hyperconverged deployments, AKS enabled by Azure Arc restricts direct access to the Kubernetes configuration store, etcd, which holds Kubernetes secrets. It also includes a built-in [KMS plugin](/en-us/azure/aks/aksarc/encrypt-etcd-secrets) that helps automatically encrypt these secrets. This plugin generates the [Key Encryption Key](https://kubernetes.io/docs/tasks/administer-cluster/kms-provider/#kms-encryption-and-per-object-encryption-keys) (KEK), isolates it away from the cluster in the underlying Windows host, and automatically rotates it every 30 days.

If you connect your own cluster via Arc-enabled Kubernetes, then help ensure etcd is protected, and your secrets are encrypted, by following your vendor’s guidance.

### References

- [Section 2 of the CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NSA Kubernetes Hardening Guidance – "Secrets"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [Kubernetes Security - OWASP Cheat Sheet Series – "Securing data"](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)

## Protect other workload data

Beyond your secret values, consider the protection at rest of other workload data that might still be sensitive. If you're running AKS enabled by Azure Arc on an Azure Local hyperconverged deployment, all data volumes are [encrypted at rest using BitLocker](/en-us/azure/azure-local/concepts/security-features#bitlocker-encryption). On [Azure Local small form factor](/en-us/azure/azure-local/small-form-factor/small-form-factor-security#data-protection-by-default) (preview), persistent data partitions that store workload data are likewise encrypted at rest by default, using hardware-backed disk encryption whose keys are sealed by the TPM and released only when the device boots into a known, verified state. If you connect your own cluster via Arc-enabled Kubernetes, use any similar protection offered by the vendor.

In addition to helping protect your workload data at rest, it’s also important to help protect your workload data in transit. See sections 2.5-2.7 above about establishing encryption, authentication, and authorization for data traffic between your workloads and to/from Azure. See also [our guidance](conceptual-secure-your-network) on adding further network layer protections. If you use [Azure Container Storage enabled by Azure Arc](/en-us/azure/azure-arc/container-storage/overview) to store data locally and synchronize it with Azure in the cloud, then it uses such transit protections automatically.

## Enable cluster recovery without impacting your security posture

Plan how you would recover from a loss of your cluster. If your AKS enabled by Azure Arc deployment on Azure Local is configured for high availability, it can help protect against regular hardware failures. But it’s still possible that the cluster can be lost due to an incident that impacts your whole site or to a cyberattack.

A starting point is to aim for all your configuration and data to be sourced from, and synchronized back to, the cloud. This synchronization means that reinstating your cluster is like initial activation. Consider configuring your cluster using [GitOps with Flux](/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli), synchronizing your Azure Key Vault secrets using the [Secret Store extension](/en-us/azure/azure-arc/kubernetes/secret-store-extension?tabs=arc-k8s), and synchronizing your data using [Azure Container Storage (preview)](/en-us/azure/azure-arc/container-storage/overview).

Alternatively, you may still need to consider using a dedicated cluster backup solution such as [Velero](https://velero.io/). Such as solution could be necessary if the only copy of some of your data is stored in your cluster or if you require extra protection.