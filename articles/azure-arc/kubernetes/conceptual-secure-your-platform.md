---
layout: Conceptual
title: Secure your platform in Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-secure-your-platform
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
description: Guidance on securing the platform layer of Azure Arc-enabled Kubernetes clusters, including node, OS, and control plane protections.
locale: en-us
document_id: 462e9473-6ed5-f148-59b0-5ff3026c312c
document_version_independent_id: 5fc49f78-1e21-c9ce-cb99-3ebdfb96bae6
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-secure-your-platform.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-secure-your-platform
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-secure-your-platform.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
platformId: d1641986-d829-9fa6-5f27-a7f3dc41cc71
---

# Secure your platform in Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

Securing your platform is foundational to improving the overall security of your Kubernetes environment. This article focuses on configuring your Kubernetes cluster, its underlying operating system, and hardware infrastructure to operate more securely. By leveraging built-in capabilities and following best practices, you can help ensure that your platform is more resilient against threats and provides a stronger base for your workloads and operations.

## Stay up to date with the latest security patches

We recommend upgrading your cluster and node OS with the latest security patches as they're published. In turn, this means it’s important to keep your cluster up to date with a supported version of Kubernetes, for which patches are released. Similarly, it's also important to keep your nodes up to date with a supported version of their OS.

If you're using AKS enabled by Azure Arc, you can apply upgrades on [Azure Local hyperconverged deployments](/en-us/azure/aks/aksarc/cluster-upgrade) or on [bare-metal deployments](/en-us/azure/aks/aksarc/aks-bare-metal-upgrade-cluster). You can also manage updates to the underlying Azure Local platform for [hyperconverged deployments](/en-us/azure/azure-local/update/about-updates-23h2) and [small form factor deployments](/en-us/azure/azure-local/small-form-factor/small-form-factor-resource-overview).

If you connect your own cluster via Arc-enabled Kubernetes, then keep it up to date following your vendor’s guidance, and [configure automatic upgrades](/en-us/azure/azure-arc/kubernetes/agent-upgrade) for the Arc-enabled Kubernetes agents that maintain the cluster’s connection to Azure.

You may also deploy [extensions](/en-us/azure/azure-arc/kubernetes/extensions) to your cluster: other sections of this security book recommend many of these extensions for the security benefits they can help bring. If so, configure automatic upgrades for these extensions too.

### References

- [NSA Kubernetes Hardening Guidance – "Upgrading and application security patches"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [Kubernetes Security - OWASP Cheat Sheet Series – "Securing Kubernetes Hosts"](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)

## Configure security protections on control plane and worker nodes

AKS enabled by Azure Arc automatically configures its control plane and worker nodes with more secure defaults. For protections provided by the underlying Azure Local platform, see the [security features for hyperconverged deployments](/en-us/azure/azure-local/concepts/security-features) and the [security features for small form factor deployments](/en-us/azure/azure-local/small-form-factor/small-form-factor-security) (preview). You can also review the [benefits of Azure Linux OS](/en-us/azure/azure-linux/intro-azure-linux#azure-linux-container-host-key-benefits), which AKS enabled by Azure Arc uses as its container host.

If you connect your own cluster via Arc-enabled Kubernetes, then confirm that your vendor can similarly help to automatically configure secure defaults across their hardware, OS, and Kubernetes stack. Evaluate if they have appropriate features such as a hardware root-of-trust, secure boot, and drive encryption. Also consider if [Microsoft Defender for Endpoint](/en-us/defender-endpoint) can help further protect your cluster nodes.

In addition, whether your cluster is fully Microsoft managed or you connect your own cluster, you can use Microsoft Defender for Containers. It helps [assess the health of your Kubernetes nodes](/en-us/azure/defender-for-cloud/kubernetes-nodes-va) and notify you of any issues. See the [support matrix](/en-us/azure/defender-for-cloud/support-matrix-defender-for-containers?tabs=azureva%2Carcrt%2Carcspm%2Carcnet) for which features are supported on which cluster types at which level (preview or general availability).

### References

- [CIS Kubernetes Benchmark - Sections 1, 2, and 4](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST Application Container Security Guide - Section 4.5.1-3](https://csrc.nist.gov/pubs/sp/800/190/final)

## Protect the communication between Kubernetes control plane components

If you run multinode deployments of AKS enabled by Azure Arc, Transport Layer Security (TLS) protects all cross-node communication between control plane components, such as the API server and etcd. TLS certificates rotate regularly.

If you connect your own cluster via Arc-enabled Kubernetes, then determine if traffic between your nodes is similarly protected. Evaluate if there are any steps you need to take to enable this protection (for example, creating and updating certificates) by following your vendor’s guidance.

### References

- [NIST Application Container Security Guide - Section 4.3.5](https://csrc.nist.gov/pubs/sp/800/190/final)
- [NSA Kubernetes Hardening Guidance – "Encryption"](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [Kubernetes Security - OWASP Cheat Sheet Series – "Restricting access to etcd"](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html)

## Protect direct access to your nodes

In general, we don't recommend direct access to your cluster’s nodes. It’s best to administer your cluster via the API server, and Role-Based Access Control (RBAC) can help you control which users can perform which operations. See our [further guidance](conceptual-secure-your-operations#control-who-can-deploy-to-your-cluster-with-role-based-access-control-rbac) on this topic.

Disable SSH access to your worker nodes by default. If you need this access and you're running AKS enabled by Azure Arc, manage it carefully as follows. (Beyond this limited exception, there should be no other way to reach the control plane nodes and the Kubernetes infrastructure components that run on them such as kube-scheduler, etcd, kubelet.)

- On Azure Local hyperconverged deployments, [safely store the SSH keys when you create the cluster](/en-us/azure/aks/aksarc/configure-ssh-keys) and [restrict SSH access to only expected network addresses](/en-us/azure/aks/hybrid/restrict-ssh-access).
- On Azure Local small form factor deployments, control SSH through just-in-time (JIT) access rather than creating standing administrative permissions. Grant eligible role assignments through Microsoft Entra Privileged Identity Management (PIM). This means a user activates the role only when needed, for a limited time, and then connects over SSH using a short-lived certificate that expires automatically.

Because edge clusters often reside in nonsecure locations, consider what physical protections are appropriate, such as locked access and tamper-evident measures.

### References

- [NIST Application Container Security Guide - Section 4.5.4 and 4.5.5](https://csrc.nist.gov/pubs/sp/800/190/final)