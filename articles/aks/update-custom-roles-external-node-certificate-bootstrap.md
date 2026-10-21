---
layout: Conceptual
title: Update custom Azure roles for external-node certificate bootstrap - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/update-custom-roles-external-node-certificate-bootstrap
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
description: Update custom Azure roles with the DataAction required for external-node bootstrap and kubelet client certificate renewal in AKS.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2026-10-13T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 4ef49144-e95c-3764-3a35-9018b31e9367
document_version_independent_id: a13a62c4-c2ef-4db0-8a21-e05cbe4d61a9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/update-custom-roles-external-node-certificate-bootstrap.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/update-custom-roles-external-node-certificate-bootstrap
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/update-custom-roles-external-node-certificate-bootstrap.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 5c8b3da5-c72e-ba89-2dec-28026f9e98de
---

# Update custom Azure roles for external-node certificate bootstrap - Azure Kubernetes Service | Microsoft Learn

Starting on November 30, 2026, Azure Kubernetes Service (AKS) requires a dedicated Azure role-based access control (Azure RBAC) DataAction to authorize kubelet client certificate issuance.

Important

Update affected custom Azure roles before **November 30, 2026**. Otherwise, new external nodes might fail to join the AKS cluster, and existing external nodes might fail to renew their kubelet client certificates.

This requirement applies to custom Azure roles used for external-node bootstrap or kubelet client certificate renewal, including AKS Stretch integrations. AKS-managed nodes aren't expected to be affected.

Previously, the broader `certificatesigningrequests/write` DataAction also authorized kubelet client certificate issuance. AKS is separating these permissions to help prevent principals with general certificate signing request write access from obtaining certificates that authenticate them as Kubernetes nodes.

## Determine whether a custom role is affected

A custom role is affected if it's used for either of the following operations:

- External-node bootstrap.
- Kubelet client certificate renewal for an external node.

If a custom role is used only for general certificate signing request operations, you don't need to add the new permission.

Review the role IDs in your Azure Service Health notification or your role inventory, and determine how each role is used. Retain each affected role's existing certificate signing request and API discovery permissions.

## Add the required DataAction

Add the DataAction that corresponds to the resource endpoint used by your integration:

| Resource endpoint | Required DataAction |
| --- | --- |
| Managed cluster | `Microsoft.ContainerService/managedClusters/certificates.k8s.io/certificatesigningrequests/nodeclient/action` |
| Fleet hub | `Microsoft.ContainerService/fleets/certificates.k8s.io/certificatesigningrequests/nodeclient/action` |
| Fleet member | `Microsoft.ContainerService/fleets/members/certificates.k8s.io/certificatesigningrequests/nodeclient/action` |
| AI Manager | `Microsoft.ContainerService/aiManagers/certificates.k8s.io/certificatesigningrequests/nodeclient/action` |

For example, a custom role used for external-node bootstrap through a managed-cluster endpoint includes the following permissions:

```json
{
  "DataActions": [
    "Microsoft.ContainerService/managedClusters/certificates.k8s.io/certificatesigningrequests/write",
    "Microsoft.ContainerService/managedClusters/certificates.k8s.io/certificatesigningrequests/read",
    "Microsoft.ContainerService/managedClusters/certificates.k8s.io/certificatesigningrequests/delete",
    "Microsoft.ContainerService/managedClusters/apis/certificates.k8s.io/read",
    "Microsoft.ContainerService/managedClusters/apis/certificates.k8s.io/v1beta1/read",
    "Microsoft.ContainerService/managedClusters/certificates.k8s.io/certificatesigningrequests/nodeclient/action"
  ]
}
```

For Fleet hub, Fleet member, or AI Manager access, use the corresponding resource path from the preceding table.

To update an affected role:

1. Retrieve the current role definition.
2. Add the applicable `certificatesigningrequests/nodeclient/action` permission to the role's `DataActions` property.
3. Confirm that all existing certificate signing request and API discovery permissions remain unchanged.
4. [Update the custom role definition](/en-us/azure/role-based-access-control/custom-roles).
5. Allow time for the Azure RBAC update to propagate.

## Validate the role update

After you update an affected custom role:

1. Retrieve the role definition, and confirm that the applicable `certificatesigningrequests/nodeclient/action` permission appears in `DataActions`.
2. Confirm that all existing certificate signing request and API discovery permissions remain unchanged.
3. In a test environment, perform an end-to-end external-node bootstrap test, and confirm that the node reaches the `Ready` state.
4. For an existing integration, verify that the kubelet client certificate can be renewed successfully through your normal validation process.

Allow approximately one hour for the end-to-end external-node bootstrap test. The total time required might vary depending on your organization's change-management process and the number of roles being updated.