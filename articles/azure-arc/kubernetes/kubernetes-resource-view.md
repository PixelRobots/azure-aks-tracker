---
layout: Conceptual
title: Access Kubernetes resources from Azure portal - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/kubernetes-resource-view
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
ms.date: 2025-02-12T00:00:00.0000000Z
ms.topic: how-to
description: Learn how to interact with Kubernetes resources to manage an Azure Arc-enabled Kubernetes cluster from the Azure portal.
locale: en-us
document_id: 3eb54ce4-7808-564c-6aa6-2efcad524ef2
document_version_independent_id: 4d2152bf-3f15-fa1a-fdc1-37a88b2ffcbf
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/kubernetes-resource-view.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/kubernetes-resource-view
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/kubernetes-resource-view.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 7b4a3087-04a9-c169-4878-2ff1f4c47fc3
---

# Access Kubernetes resources from Azure portal - Azure Arc | Microsoft Learn

The Azure portal includes a Kubernetes resource view for easy access to the Kubernetes resources in your Azure Arc-enabled Kubernetes cluster. Viewing Kubernetes resources from the Azure portal reduces context switching between the Azure portal and the `kubectl` command-line tool, streamlining the experience for viewing and editing your Kubernetes resources. The resource viewer currently includes multiple resource types, including deployments, pods, and replica sets.

## Prerequisites

- An existing Kubernetes cluster [connected](quickstart-connect-cluster) to Azure as an Azure Arc-enabled Kubernetes resource.
- An account that can authenticate to the cluster and access the resources in the portal:

    - If using [Azure role-based access control (Azure RBAC)](azure-rbac), ensure that the Microsoft Entra account has a role that lets it authenticate to the cluster, such as [Azure Arc Kubernetes Viewer](/en-us/azure/role-based-access-control/built-in-roles):

    ```azurecli
    az role assignment create --role "Azure Arc Kubernetes Viewer" --assignee $AAD_ENTITY_OBJECT_ID --scope $ARM_ID_CLUSTER
    ```

    - If using [cluster connect with service account token authentication](cluster-connect#service-account-token-authentication-option), ensure that the account uses a Kubernetes cluster role that can authenticate to the cluster, such as `cluster-admin`:

    ```console
    kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin --user=$AAD_ENTITY_OBJECT_ID`
    ```

    The same account must have an Azure role such as [Azure Arc Kubernetes Viewer](/en-us/azure/role-based-access-control/built-in-roles) in order to authenticate to the Azure portal and view Arc-enabled cluster resources.

## View Kubernetes resources

To see the Kubernetes resources, navigate to your cluster in the Azure portal. In the service menu, expand **Kubernetes resources (preview)**. Within this section, there are several options to view information:

- **Namespaces**: The namespaces of your cluster. The filter at the top of the namespace list provides a quick way to filter and display your namespace resources.
- **Workloads**: Information about deployments, pods, replica sets, stateful sets, daemon sets, jobs, and cron jobs deployed to your cluster.
- **Services and ingresses**: Your cluster's service and ingress resources.
- **Storage**: Your Azure storage classes and persistent volume information.
- **Configuration**: Your cluster's config maps and secrets.

[![Screenshot of Kubernetes workloads information in the Azure portal.](media/kubernetes-resource-view/workloads.png)](media/kubernetes-resource-view/workloads.png#lightbox)

## Edit YAML

The Kubernetes resource view also includes a YAML editor. A built-in YAML editor means you can update Kubernetes objects from within the portal and apply changes immediately.

Warning

The Azure portal Kubernetes management capabilities and the YAML editor are built for learning and flighting new deployments in a development and test setting. Performing direct production changes by editing the YAML isn't recommended. For production environments, consider using [GitOps to apply configurations](tutorial-use-gitops-flux2).

After you edit the YAML, select **Review + save**, confirm the changes, and then save again.

![Screenshot showing the YAML editor for Kubernetes objects displayed in the Azure portal.](media/kubernetes-resource-view/yaml-editor.png)