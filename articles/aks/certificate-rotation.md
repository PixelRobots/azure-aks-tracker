---
layout: Conceptual
title: Certificate Management and Rotation in Azure Kubernetes Service (AKS) Overview - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/certificate-rotation
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
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn about certificate management and rotation in Azure Kubernetes Service (AKS) clusters, including how to manually rotate certificates and enable autorotation for enhanced security.
author: schaffererin
ms.author: schaffererin
ms.topic: overview
ms.subservice: aks-security
ms.custom: devx-track-azurecli
ms.date: 2026-10-13T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: a7e9545e-8f84-f5b1-b25e-5aad8f2f05a1
document_version_independent_id: 27235dc6-a3e6-8992-49bc-8c2c7d25e649
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/certificate-rotation.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/certificate-rotation
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/certificate-rotation.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 6f3aa43f-a196-9226-2c00-a0c04e004a1e
---

# Certificate Management and Rotation in Azure Kubernetes Service (AKS) Overview - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) clusters use certificates for authentication between various components, including AKS managed control plane components and data plane components. This article provides an overview of certificate management and rotation in AKS.

Important

Starting on **April 01, 2027** Azure Kubernetes Service (AKS) no longer supports the `aks-disable-kubelet-serving-certificate-rotation=true` node pool tag to disable Kubelet Serving Certificate Rotation (KSCR). You can create new node pools using this tag, but AKS won't respect it. This behavior means that the node pools will be created with KSCR enabled. For existing node pools, KSCR will be automatically enabled on their next reimage operation. Before this date you can update your node pools using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `aks-disable-kubelet-serving-certificate-rotation=true` tag. To prepare for the removal, you should update your workloads with the correct cert path. For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5539). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

Certificate autorotation for node client and serving certificates is enabled by default for clusters that enable [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/).

- AKS clusters created **before May 2019** have cluster CA certificates that expire after two years.
- AKS clusters created **after May 2019** have cluster CA certificates that expire after 30 years.

## What is certificate rotation?

Certificate rotation is the process of replacing digital certificates with new ones to maintain security and prevent disruptions. It's a crucial security practice performed to replace expired certificates, mitigate risks from compromised keys, and respond to new security requirements. This process can involve automatically renewing certificates or manually replacing them. Often, it requires a planned maintenance window for complex replacements, especially when a root certificate is involved.

## Certificates, certificate authorities, and service account tokens in AKS

AKS generates and uses the following certificates, certificate authorities (CA), and service accounts (SA) tokens:

| Certificate | Description | Rotation method |
| --- | --- | --- |
| Cluster certificate authority | Created by AKS on your behalf and is unique to your cluster. This CA certificate is used to issue both client and server certificates to the kubelets running in your data plane and the certificate used by the API server. | Manual |
| Service account token | JSON Web Tokens (JWT) signed by the cluster CA certificate. The kubelets running on your agent nodes automatically request and renew these tokens. For more information, see [Launch a Pod using service account token projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#launch-a-pod-using-service-account-token-projection). | Automatically refreshed as part of manual cluster CA rotation |
| API server certificate | Signed and issued by the cluster CA certificate. This certificate is used whenever establishing TLS-based connections with the API server, such as with `kubectl`. | Automatically refreshed as part of manual cluster CA rotation |
| Kubelet serving certificate | In clusters that enable [kubelet serving certificate rotation](https://aka.ms/aks/kubelet-serving-certificate-rotation), the cluster CA certificate issues and signs this certificate. Otherwise, the agent node generates and self-signs this certificate. This certificate establishes TLS-based connections with components that need to connect to any one of the kubelet serving endpoints, such as *metrics-server*. | Automatic for clusters enabled with kubelet serving certificate rotation |
| Kubelet client certificate | Signed and issued by the cluster CA certificate. This certificate uses an AKS-specific TLS bootstrapping protocol that provides kubelet its client certificate and corresponding kubeconfig before kubelet starts. The AKS TLS protocol is only enabled on Kubernetes clusters version 1.32 or higher. | Automatically refreshed by default using vanilla TLS bootstrapping and as part of manual cluster CA rotation |
| `kubectl` client certificate | Used for certificate-based authentication with the API server. | Manually rotate after manual cluster CA rotation |

Note

AKS doesn't manage any certificate created for or specific to a customer's workload.

## Certificate autorotation in AKS

AKS automatically rotates the following certificates:

- Clusters created **after March 2022 with Kubernetes RBAC enabled** enable kubelet client certificate autorotation by default.

Note

You might need to periodically rotate these certificates manually for security or policy reasons. For example, you might have a policy to rotate all your certificates every 90 days. By default, kubelet client certificate autorotation occurs manually.

### Limitations for certificate autorotation

The following limitations apply to certificate autorotation:

- The cluster must use [vanilla TLS bootstrapping](https://kubernetes.io/docs/reference/access-authn-authz/kubelet-tls-bootstrapping/) or AKS secure TLS bootstrapping, which is [rolling out](https://github.com/azure/aks/releases) by default to all Azure regions.
- For existing clusters, you need to upgrade the cluster to enable certificate autorotation.

## Manual certificate rotation in AKS

You must [manually rotate](rotate-certificates) the following certificates:

- Cluster CA certificates using the [`az aks rotate-certs`](/en-us/cli/azure/aks#az-aks-rotate-certs).
- `kubectl` client certificates using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command (after manual rotation of the cluster CA certificate).

When you rotate the cluster CA certificate, the following child certificates are also refreshed:

- Service account (SA) tokens
- API server certificates
- Kubelet client certificates
- Kubelet server certificates (if kubelet serving certificate rotation is enabled on the cluster)

After you rotate the cluster CA certificate, you must also manually rotate the `kubectl` client certificates to ensure continued access to the API server.

## TLS bootstrapping for the kubelet client certificate

Kubelet uses an AKS-specific TLS bootstrapping protocol and relies on the node's identity within Entra ID. This identity provides kubelet its client certificate and corresponding kubeconfig before kubelet starts. This change aims to harden the AKS node security posture by eliminating kubelet's dependency on a static bootstrap token secret to register itself with the API server. If the secure TLS bootstrapping protocol fails for any reason, kubelet can still register itself with the API server by using a bootstrap token, and the node eventually becomes ready. You see `aksService` (instead of `system:bootstrap:<>`) as the requestor field on the certificate signing request (CSR) objects created by the protocol.

The kubelet client certificate is still located within */var/lib/kubelet/pki/kubelet-client-current.pem* on Linux nodes and *C:\k\pki\kubelet-client-current.pem* on Windows nodes. The *bootstrap-kubeconfig* is still located in the same spot. AKS continues to automatically rotate this certificate as part of its certificate rotation process.

Important

Starting on **November 30, 2026**, AKS requires a dedicated Azure role-based access control (Azure RBAC) DataAction to authorize kubelet client certificate issuance. If you use a custom Azure role for external-node bootstrap or kubelet client certificate renewal, [update the custom role before this date](update-custom-roles-external-node-certificate-bootstrap). Otherwise, new external nodes might fail to join the cluster, and existing external nodes might fail to renew their kubelet client certificates. AKS-managed nodes aren't expected to be affected.

## Kubelet serving certificate rotation

Kubelet serving certificate rotation enables AKS to use kubelet server TLS bootstrapping for both bootstrapping and rotating serving certificates that the cluster CA signs.

For more information, see [Manage and rotate certificates in Azure Kubernetes Service (AKS)](rotate-certificates).

### Kubelet serving certificate rotation limitations

- Supported on Kubernetes version 1.27 and above.
- Not supported when the node pool is using a node pool snapshot based on any node image older than `202501.12.0`.
- You can't manually enable this feature. Existing node pools have kubelet serving certificate rotation enabled by default after they perform their first upgrade to any Kubernetes version 1.27 or greater. New node pools on Kubernetes version 1.27 or greater have kubelet serving certificate rotation enabled by default. To see if kubelet serving certificate rotation is enabled in your region, see [AKS Releases](https://github.com/Azure/AKS/releases).
- Kubernetes RBAC must be enabled on the cluster for kubelet serving certificate rotation to be enabled. If you have an existing cluster, you must upgrade that cluster to enable Kubernetes RBAC.