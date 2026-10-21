---
layout: Conceptual
title: Connected Registry in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/intro-connected-registry
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Use the connected registry of Azure Container Registry to help speed up access to registry artifacts. on-premises or remote.
ms.topic: overview
ms.date: 2025-05-20T00:00:00.0000000Z
ms.custom: references_regions
locale: en-us
document_id: 1e8d5dce-6c11-2b7b-211a-9ea8965735b6
document_version_independent_id: 4db24503-a807-53de-571b-381fd4b0d2d7
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/intro-connected-registry.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/intro-connected-registry
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/intro-connected-registry.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: a7bf1729-d014-2db5-8a8c-b77b8a15fb2c
---

# Connected Registry in Azure Container Registry - Azure Container Registry | Microsoft Learn

The connected registry feature of [Azure Container Registry](container-registry-intro) enables an on-premises or remote replica that synchronizes container images with your cloud-based Azure container registry. Use a connected registry to help speed up access to registry artifacts hosted on-premises or remotely.

A cloud-based Azure container registry provides features including geo-replication, integrated security, Azure-managed storage, and integration with Azure development and deployment pipelines. However, you might want to extend your cloud investments to your on-premises and field solutions, requiring options outside of the standard cloud-based Azure container registry, or you might have intermittent or limited connectivity to the cloud.

In on-premises or remote environments, container workloads need container images and related artifacts to be available nearby in order to maintain performance and reliability. Connected registries provide a performant, on-premises registry solution that regularly synchronizes content with a cloud-based Azure container registry.

## Pricing and availability

The connected registry feature is currently available only for the **Premium**[service tier](container-registry-skus) (SKU).

You can deploy a connected registry in any region where Azure Container Registry is available.

Changes to connected registry billing begin on August 1, 2025. These changes include a monthly charge applied to the Azure subscription associated with the parent registry. For more information, see [Azure Container Registry pricing](https://azure.microsoft.com/pricing/details/container-registry/).

## How does the connected registry work?

You can deploy a connected registry on a server or device on-premises, or in an environment that supports container workloads on-premises, such as [Azure Arc-enabled Kubernetes](/en-us/azure/azure-arc/kubernetes/overview). The connected registry synchronizes container images and other OCI (Open Container Initiative) artifacts with a cloud-based Azure container registry.

The following diagram shows a typical deployment model for a connected registry using an Azure Arc-enabled Kubernetes cluster.

![Diagram of connected registry overview using Arc-enabled Kubernetes.](media/intro-connected-registry/connected-registry-azure-arc.png)

### Deployment and synchronization

You manage each connected registry as a resource within a cloud-based Azure container registry. This Azure container registry is the parent of the connected registry.

You can [deploy the connected registry Arc extension to the Arc-enabled Kubernetes cluster](quickstart-connected-registry-arc-cli). Secure the connection by using TLS (Transport Layer Security) with default configurations for read-only access and a continuous sync window. This setup allows the connected registry to synchronize images from the Azure container registry (ACR) to the connected registry on-premises, enabling image pulls from the connected registry.

The connected registry's *activation status* indicates whether it's deployed on-premises (**Active**) or not currently deployed (**Inactive**).

Once the connected registry is **Active**, it regularly accesses the cloud registry to synchronize container images and OCI artifacts.

You can also [configure synchronization](tutorial-connected-registry-sync) to synchronize a subset of the repositories from the cloud registry, or to synchronize only during certain intervals, to reduce traffic between the cloud and the premises.

### Modes

A connected registry works in one of two modes: `ReadWrite` or `ReadOnly`.

**`ReadOnly mode`** is the default. When the connected registry is in `ReadOnly` mode, clients can only pull (read) artifacts. Use this configuration in scenarios where clients need to pull a container image to operate. This default mode aligns with the secure-by-default approach.

**`ReadWrite mode`** - This mode allows clients to [pull and push artifacts (read and write) to the connected registry](pull-images-from-connected-registry). Artifacts that you push to the connected registry synchronize with the cloud registry. The ReadWrite mode is useful when a local development environment is in place. You push the images to the local connected registry, and from there they're synchronized to the cloud-based parent registry.

Connected registries must be compatible with their parent registry capabilities. If a parent registry uses `ReadWrite` mode, child registries can use either mode. However, if the parent registry uses `ReadOnly` mode, child registries must also use `ReadOnly` mode.

## Client access

On-premises clients use standard tools such as the Docker CLI to push or pull content from a connected registry. To manage client access, create Azure container registry [non-Microsoft Entra tokens](container-registry-token-based-repository-permissions) for access to each connected registry. You can scope the client tokens for pull or push access to one or more repositories in the registry.

Each connected registry also needs to regularly communicate with its parent registry. For this purpose, the cloud registry issues the registry a synchronization token (*sync token*). Use this token to authenticate with its parent registry for synchronization and management operations.

The following diagram shows how each connected registry uses two different types of tokens.

![Connected registry authentication verview](media/intro-connected-registry/connected-registry-authentication-overview.svg)

Important

Store token passwords for each connected registry in a safe location. After you create them, you can't retrieve token passwords. You can regenerate token passwords at any time.

### Client tokens

To manage client access to a connected registry, create tokens scoped for actions on one or more repositories. After creating a token, configure the connected registry to accept the token by using the [az acr connected-registry update](/en-us/cli/azure/acr/connected-registry#az-acr-connected-registry-update) command. A client can then use the token credentials to access a connected registry endpoint in order to use Docker CLI commands to pull or push images to the connected registry.

Update client tokens, passwords, or scope maps as needed by using [az acr token](/en-us/cli/azure/acr#az-acr-token) and [az acr scope-map](/en-us/cli/azure/acr#az-acr-scope-map) commands. Client token updates automatically propagate to the connected registries that accept the token.

A client token accesses the connected registry's endpoint. The connected registry endpoint is the login server URI, which is typically the IP address of the server or device that hosts it.

### Sync token

Each connected registry uses a sync token to authenticate with its immediate parent, which can be another connected registry or the cloud registry.

The sync token and passwords are generated automatically when you create the connected registry resource. Run the [az acr connected-registry get-settings][/cli/azure/acr/connected-registry#az-acr-connected-registry-get-settings] command to regenerate the passwords, or update them in the Azure portal.

By default, the sync token has permission to synchronize selected repositories with its parent. It also has permissions to read and write synchronization messages on a gateway used to communicate with the connected registry's parent. These messages control the synchronization schedule and manage other updates between the connected registry and its parent.

Update sync tokens, passwords, or scope maps as needed by using [az acr token](/en-us/cli/azure/acr#az-acr-token) and [az acr scope-map](/en-us/cli/azure/acr#az-acr-scope-map) commands. Sync token updates automatically propagate to the connected registry. Follow the standard practices of rotating passwords when updating the sync token.

Note

You can't delete the sync token until you delete the connected registry associated with the token. To disable a connected registry, set the status of the sync token to `disabled`.

A sync token accesses the endpoint of the parent registry, which is either another connected registry endpoint or the cloud registry itself. When scoped to access the cloud registry, the sync token needs to reach two registry endpoints:

- The fully qualified login server name, such as `contoso.azurecr.io`. This endpoint is used for authentication.
- A fully qualified regional [data endpoint](container-registry-firewall-rules#enable-dedicated-data-endpoints) for the cloud registry, such as `contoso.westus2.data.azurecr.io`. This endpoint is used to exchange messages with the connected registry for synchronization purposes.

## Current limitations

When you use connected registries, be aware of the following limitations:

- The number of tokens and scope maps for a single container registry is [limited](container-registry-skus) to 20,000 each. This limit indirectly limits the number of connected registries for a cloud registry, because every connected registry needs a sync token and a client token.
- The number of repository permissions in a scope map is limited to 500.
- The number of clients for the connected registry is limited to 50.
- The number of connected registries per container registry is limited to 50.
- [Image locking](container-registry-image-lock) through repository, manifest, or tag metadata isn't supported for connected registries.
- [Repository delete](container-registry-delete) isn't supported on the connected registry when using ReadOnly mode.
- [Resource logs](monitor-service-reference#resource-logs) for connected registries aren't supported.
- Connected registry is coupled with the registry's home region data endpoint. Automatic migration for [geo-replication](container-registry-geo-replication) isn't supported.
- Deletion of a connected registry requires manual removal of the containers on-premises and removal of the respective scope map or tokens in the cloud.
- Connected registry sync limitations are as follows:
    - For continuous sync:
        - `minMessageTtl` is one day.
        - `maxMessageTtl` is 90 days.
    - For occasionally connected scenarios, where you want to specify sync window:
        - `minSyncWindow` is 1 hr.
        - `maxSyncWindow` is seven days.