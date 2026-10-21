---
layout: Conceptual
title: Access Network-Restricted Registry By Trusted Azure Service - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/allow-access-trusted-services
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
description: Enable a trusted Azure service instance to securely access a network-restricted container registry to pull or push images
ms.topic: how-to
ms.date: 2025-02-28T00:00:00.0000000Z
locale: en-us
document_id: e9a7797a-6eb0-4321-c99a-2b0088d69407
document_version_independent_id: 779bb545-f07f-661c-e2d9-7797d744e6f7
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/allow-access-trusted-services.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/allow-access-trusted-services
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/allow-access-trusted-services.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 229b24b4-8343-4a77-14b3-238963635592
---

# Access Network-Restricted Registry By Trusted Azure Service - Azure Container Registry | Microsoft Learn

With Azure Container Registry, you can allow select trusted Azure services to access a registry that's configured with network access rules. When you allow trusted services, a trusted service instance can securely bypass the registry's network rules and perform operations such as pulling or pushing images. This article explains how to enable and use trusted services with a network-restricted Azure container registry.

Use the Azure Cloud Shell or a local installation of the Azure CLI to run the command examples in this article. Use version 2.18 or later to run it locally. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Limitations

- Certain registry access scenarios with trusted services require a [managed identity for Azure resources](/en-us/azure/active-directory/managed-identities-azure-resources/overview). Except where noted that a user-assigned managed identity is supported, only a system-assigned identity can be used.
- Allowing trusted services doesn't apply to a container registry configured with a [service endpoint](container-registry-vnet). The feature only affects registries that are restricted with a [private endpoint](container-registry-private-endpoints) or that have [public IP access rules](container-registry-access-selected-networks) applied.

## About trusted services

Azure Container Registry has a layered security model that supports multiple network configurations to restrict access to a registry. These configurations include:

- [Private endpoint with Azure Private Link](container-registry-private-endpoints). When configured, a registry's private endpoint is accessible only to resources within the virtual network, using private IP addresses.
- [Registry firewall rules](container-registry-access-selected-networks), which allow access to the registry's public endpoint only from specific public IP addresses or address ranges. You can also configure the firewall to block all access to the public endpoint when using private endpoints.

When you deploy a registry in a virtual network or configure it with firewall rules, it denies access to users or services from outside those sources.

Several multitenant Azure services operate from networks that you can't include in these registry network settings. As a result, these services can't perform operations such as pulling or pushing images to the registry. By designating certain service instances as "trusted", a registry owner can allow select Azure resources to securely bypass the registry's network settings to perform registry operations.

### Trusted services

Instances of the following services can access a network-restricted container registry if the registry's **allow trusted services** setting is enabled (the default). More services will be added over time.

Where indicated, access by the trusted service requires additional configuration of a managed identity in a service instance, assignment of an [RBAC role](container-registry-rbac-built-in-roles-overview), and authentication with the registry. For example steps, see Trusted services workflow, later in this article.

| Trusted service | Supported usage scenarios | Configure managed identity with RBAC role |
| --- | --- | --- |
| Azure Container Instances | [Deploy to Azure Container Instances from Azure Container Registry using a managed identity](/en-us/azure/container-instances/using-azure-container-registry-mi) | Yes, either system-assigned or user-assigned identity |
| Microsoft Defender for Cloud | Vulnerability scanning by [Microsoft Defender for container registries](scan-images-defender) | No |
| Machine Learning | [Deploy](/en-us/azure/machine-learning/how-to-deploy-custom-container) or [train](/en-us/azure/machine-learning/how-to-train-with-custom-image) a model in a Machine Learning workspace using a custom Docker container image | Yes |
| Azure Container Registry | [Import images](container-registry-import-images) to or from a network-restricted Azure container registry | No |

Note

Currently, enabling the `allow trusted services` setting doesn't apply to App Service.

## Allow trusted services - CLI

By default, the allow trusted services setting is enabled in a new Azure container registry. Disable or enable the setting by running the [az acr update](/en-us/cli/azure/acr#az-acr-update) command.

To disable:

```azurecli
az acr update --name myregistry --allow-trusted-services false
```

To enable the setting in an existing registry or a registry where it's already disabled:

```azurecli
az acr update --name myregistry --allow-trusted-services true
```

## Allow trusted services - portal

By default, the allow trusted services setting is enabled in a new Azure container registry.

To disable or re-enable the setting in the portal:

1. In the portal, navigate to your container registry.
2. Under **Settings**, select **Networking**.
3. In **Allow public network access**, select **Selected networks** or **Disabled**.
4. Do one of the following steps:
    - To disable access by trusted services, under **Firewall exception**, uncheck **Allow trusted Microsoft services to access this container registry**.
    - To allow trusted services, under **Firewall exception**, check **Allow trusted Microsoft services to access this container registry**.
5. Select **Save**.

## Trusted services workflow

Here's a typical workflow to enable an instance of a trusted service to access a network-restricted container registry. This workflow is needed when you use a service instance's managed identity to bypass the registry's network rules.

1. Enable a managed identity in an instance of one of the trusted services for Azure Container Registry.
2. Assign the identity an [Azure role](container-registry-rbac-built-in-roles-overview) to your registry. For example, assign either `Container Registry Repository Reader` (for [ABAC-enabled registries](container-registry-rbac-abac-repository-permissions)) or `AcrPull` (for non-ABAC registries).
3. Configure the setting in the network-restricted registry to allow access by trusted services.
4. Use the identity's credentials to authenticate with the network-restricted registry.
5. Pull images from the registry, or perform other operations allowed by the role.