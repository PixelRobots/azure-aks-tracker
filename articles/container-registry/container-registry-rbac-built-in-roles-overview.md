---
layout: Conceptual
title: Azure Container Registry Entra permissions and role assignments overview - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-rbac-built-in-roles-overview
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
description: Use Microsoft Entra role-based access control to manage permissions for an Azure Container Registry.
ms.topic: concept-article
ms.date: 2026-03-25T00:00:00.0000000Z
locale: en-us
document_id: bfa3b124-0975-c69f-b16b-91a5d487ed0f
document_version_independent_id: b9021757-7569-8112-40a4-c63e01007dae
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-rbac-built-in-roles-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-rbac-built-in-roles-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-rbac-built-in-roles-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: e25a19b3-639b-b292-0367-f5d5a9771b0e
---

# Azure Container Registry Entra permissions and role assignments overview - Azure Container Registry | Microsoft Learn

Azure Container Registry (ACR) offers a set of [built-in roles](/en-us/azure/role-based-access-control/built-in-roles) that provide Microsoft Entra-based permissions management to an ACR registry.

By using [Azure role-based access control (RBAC)](/en-us/azure/role-based-access-control/), you can assign a built-in role to users, managed identities, or service principals to grant Microsoft Entra-based permissions defined within the role.

You can also define and assign [custom roles](container-registry-rbac-custom-roles) with fine-grained permissions tailored to your specific needs if the built-in roles don't meet your requirements.

## Supported role assignment identity types

You can assign ACR roles to the following identity types to grant permissions to a registry:

- [Individual user identity](container-registry-authentication#individual-login-with-azure-ad)
- [Managed identity for Azure resources](container-registry-authentication-managed-identity)
    - [Azure DevOps - Azure Pipelines identity](/en-us/azure/devops/pipelines/ecosystems/containers/publish-to-acr)
    - [Azure Kubernetes Service (AKS) node's kubelet identity](/en-us/azure/aks/cluster-container-registry-integration) to enable the AKS node to pull images from ACR. ACR supports role assignments for both [AKS-managed kubelet identity and AKS pre-created kubelet identity](/en-us/azure/aks/use-managed-identity) for AKS nodes to pull images from ACR.
    - [Azure Container Apps identity](/en-us/azure/container-apps/managed-identity-image-pull)
    - [Azure Container Instances identity](/en-us/azure/container-instances/using-azure-container-registry-mi)
    - [Azure Machine Learning workspace identity](/en-us/azure/machine-learning/how-to-identity-based-service-authentication)
    - [Azure Machine Learning attached Kubernetes cluster node kubelet identity](/en-us/azure/machine-learning/how-to-attach-kubernetes-to-workspace) to allow the Kubernetes cluster's nodes to pull images from ACR.
    - [Azure Machine Learning online endpoint identity](/en-us/azure/machine-learning/how-to-access-resources-from-endpoints-managed-identities)
    - [Azure App Service identity](/en-us/azure/app-service/tutorial-custom-container)
    - [Azure Web Apps identity](/en-us/troubleshoot/azure/azure-container-registry/pull-image-to-web-app-fail)
    - [Azure Batch identity](/en-us/azure/batch/batch-docker-container-workloads)
    - [Azure Functions identity](/en-us/azure/azure-functions/functions-app-settings#acrusermanagedidentityid)
- [Service principal](container-registry-authentication#service-principal)
    - [AKS cluster service principal](authenticate-aks-cross-tenant) to enable AKS nodes to pull images from ACR. ACR also supports cross-tenant AKS node to ACR authentication through [cross-tenant service principal role assignments and authentication](authenticate-aks-cross-tenant).
    - [Azure Container Instance service principal](container-registry-auth-aci)
    - [Hybrid or on-premises AKS clusters on Azure Stack Hub using service principal](/en-us/azure-stack/user/container-registry-deploy-image-aks-cluster)

Note

[Connected registries](intro-connected-registry) don't support Azure role assignments or Microsoft Entra-based permissions management.

## Perform role assignments to grant permissions

To perform role assignments, you must have either the `Owner` role or the `Role Based Access Control Administrator` role on the registry. You can make role assignments by using the [Azure portal](/en-us/azure/role-based-access-control/role-assignments-portal), [Azure CLI](/en-us/azure/role-based-access-control/role-assignments-cli), or [Azure PowerShell](/en-us/azure/role-based-access-control/role-assignments-powershell).

For information about how to assign a role to an identity, see [Steps to add a role assignment](/en-us/azure/role-based-access-control/role-assignments-steps).

## Scope role assignments to specific repositories

Use Microsoft Entra attribute-based access control (ABAC) to manage Microsoft Entra-based repository permissions. This feature lets you scope role assignments to specific repositories in a registry.

For an overview of Microsoft Entra ABAC repository permissions, including the ACR built-in roles that support Microsoft Entra ABAC conditions, see [Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions).

Alternatively, see the [Azure Container Registry roles directory reference](container-registry-rbac-built-in-roles-directory-reference) for a list of built-in roles that support Microsoft Entra ABAC conditions.

## Recommended built-in roles by scenario

Apply the principle of least privilege by assigning only the permissions necessary for an identity to perform its intended function.

The applicable built-in roles and role behavior depend on the registry's **Role assignment permissions mode**:

- **RBAC Registry + ABAC Repository Permissions**: Supports standard RBAC role assignments with optional [Microsoft Entra ABAC conditions](container-registry-rbac-abac-repository-permissions). to scope assignments to specific repositories.
- **RBAC Registry Permissions**: Supports only standard RBAC assignments without ABAC conditions.

To view this setting in the Azure portal, go to your registry, and then select **Properties** under the **Settings** section in the service menu.

The following list describes common container registry scenarios and their recommended roles, depending on the registry's role assignment permissions mode.

# [Registries configured with &quot;RBAC Registry + ABAC Repository Permissions&quot;](#tab/registries-configured-with-rbac-registry-abac-repository-permissions)
- **Scenario: Identities that need to pull images and validate supply chain artifacts such as developers, pipelines, and container deployment orchestrators (Azure Kubernetes Service, Azure Container Apps, Azure Container Instances, Azure Machine Learning workspaces)**

    - Role: `Container Registry Repository Reader`
    - Purpose: Grants data plane read-only access to pull images and artifacts, view tags, repositories, Open Container Initiative (OCI) referrers, and artifact streaming configurations. Doesn't include any control plane or write permissions. **Doesn't grant repository catalog list permissions** to list any repositories in the registry.
    - ABAC support: This role supports optional Microsoft Entra ABAC conditions to scope role assignments to specific repositories in the registry.
- **Scenario: Identities such as CI/CD build pipelines and developers that build and push images, as well as manage image tags**

    - Role: `Container Registry Repository Writer`
    - Permissions: Grants data plane access to push, pull, and update (but not delete) images and artifacts, read/manage tags, read/manage OCI referrers, and enable (but not disable) artifact streaming for repositories and images. Doesn't include any control plane permissions. **Doesn't grant repository catalog list permissions** to list any repositories in the registry.
    - ABAC support: This role supports optional Microsoft Entra ABAC conditions to scope role assignments to specific repositories in the registry.
- **Scenario: Identities that need to delete images, artifacts, tags, and OCI referrers**

    - Role: `Container Registry Repository Contributor`
    - Permissions: Grants permissions to **read, write, update, and delete** images and artifacts, read/manage/delete tags, read/manage/delete OCI referrers, and enable/disable artifact streaming for repositories and images. Doesn't include any control plane permissions. **Doesn't grant repository catalog list permissions** to list any repositories in the registry.
    - ABAC support: This role supports optional Microsoft Entra ABAC conditions to scope role assignments to specific repositories in the registry.
- **Scenario: Identities that need to list all repositories in the registry**

    - Role: `Container Registry Repository Catalog Lister`
    - Permissions: Grants data plane access to list all repositories in the registry, including through the `{loginServerURL}/acr/v1/_catalog` or `{loginServerURL}/v2/_catalog` registry API endpoints. Doesn't include any control plane permissions or permissions to push/pull images.
    - ABAC support: This role **doesn't support Microsoft Entra ABAC conditions**. As such, this role assignment **grants permissions to list all repositories** in the registry.
- **Scenario: Pipelines, identities, and developers that sign images**

    - For signing images with OCI referrers such as [Notary Project](container-registry-tutorial-sign-build-push):
        - Role: `Container Registry Repository Writer`
        - Permissions: Grants data plane access to push signatures in the form of OCI referrers attached to images and artifacts. Doesn't include any control plane permissions.
        - ABAC support: This role supports optional Microsoft Entra ABAC conditions to scope role assignments to specific repositories in the registry.
    - For signing images with [Docker Content Trust (DCT)](container-registry-content-trust):
        - Signing images with DCT for ABAC-enabled registries isn't supported.
- **Scenario: Developers and command line scripts that use `az` CLI to authenticate and login to the registry (via the `az acr login` command), as well as to run other `az` CLI control plane commands on a registry.** Take note that identities that only need image pull, push, or delete permissions do not need the following role. This scenario is strictly about clarifying the role that grants permissions to enable running `az` CLI on a registry, including `az acr login` and other `az` CLI control plane commands on a registry. This role also grants permissions to create, update, or delete ACR registries, as well as control plane permissions to manage registry configuration. This role does not grant data plane permissions to pull, push, or delete images; those are granted by the separate data plane roles.

    - Role: `Container Registry Contributor and Data Access Configuration Administrator`
    - ABAC support: This role doesn't support Microsoft Entra ABAC conditions as the role is scoped to the registry level, granting permissions to authenticate to the registry using `az` CLI (via the `az acr login` command) and manage control plane settings and configurations for the entire registry.
- **Scenario: Pipelines, identities, and developers that need to create, update, or *delete* ACR registries**

    - Role: `Container Registry Contributor and Data Access Configuration Administrator`
    - Permissions:
        - Grants control plane access to **create, configure, manage, and *delete***registries, including:
            - authenticate and login to the registry using `az` CLI via the `az acr login` command. Note that on an ABAC-enabled registry, `az acr login` succeeds with this role, but the identity is still not granted any data plane operations (pull, push, delete) unless it also holds an ABAC-compatible data plane role.
            - run other `az` CLI control plane commands on a registry that read, update, or delete registry control plane configuration (take note that this role does not grant data plane permissions needed to run certain `az` CLI commands)
            - configure [registry SKUs](container-registry-skus)
            - authentication access settings ([admin user login credentials](container-registry-authentication#admin-account), [anonymous pull](anonymous-pull-access), [non-Microsoft Entra token-based repository permissions](container-registry-token-based-repository-permissions), and [Microsoft Entra authentication-as-arm token audience](container-registry-disable-authentication-as-arm)),
            - configure ([geo-replications](container-registry-geo-replication)),
            - on-premises features ([connected registries](intro-connected-registry)),
            - registry endpoints ([dedicated data endpoints](container-registry-dedicated-data-endpoints))
            - network access ([private link and private endpoint settings](container-registry-private-endpoints), [public network access](container-registry-private-endpoints#disable-public-access-to-a-registry), [trusted services bypass](allow-access-trusted-services), [network firewall rules](container-registry-access-selected-networks), and [Virtual Network (VNET) service endpoints](container-registry-vnet))
            - registry policies ([retention policy](container-registry-retention-policy), [registry-wide quarantine enablement](https://github.com/Azure/acr/blob/main/docs/preview/quarantine/readme.md), [soft-delete enablement](container-registry-soft-delete-policy), and [data exfiltration export policy](data-loss-prevention))
            - [diagnostics and monitoring settings](monitor-container-registry) (diagnostic settings, logs, metrics, [webhooks for registries and geo-replications](container-registry-webhook), and [Event Grid](container-registry-event-grid-quickstart))
            - manage a [registry's system-assigned managed identity](/en-us/cli/azure/acr/identity)
        - Note: this role grants permissions to delete the registry itself.
        - Note: this role doesn't include data plane operations (for example, image push/pull), role assignment capabilities, or ACR task.
        - Note: to manage a [registry's user-assigned managed identity](/en-us/cli/azure/acr/identity), the assignee must also have the [`Managed Identity Operator`](/en-us/azure/role-based-access-control/built-in-roles/identity#managed-identity-operator) role.
    - ABAC support: This role doesn't support Microsoft Entra ABAC conditions as the role is scoped to the registry level, granting permissions to manage control plane settings and configurations for the entire registry.
- **Scenario: Pipelines, infrastructure engineers, or control plane observability/monitoring tools that need to list registries and view registry configurations, but not access to registry images**

    - Role: `Container Registry Configuration Reader and Data Access Configuration Reader`
    - Permissions: **Read-only counterpart of the `Container Registry Contributor and Data Access Configuration Administrator` role**. Grants control plane access to view and list registries and inspect registry configurations, but not modify them. Doesn't include data plane operations (for example, image push/pull) or role assignment capabilities.
    - ABAC support: This role doesn't support Microsoft Entra ABAC conditions as the role is scoped to the registry level, granting permissions to read control plane settings and configurations for the entire registry.
- **Scenario: Vulnerability scanners and tools that need to audit registries and registry configurations, as well as access to registry images to scan them for vulnerabilities**

    - Roles: `Container Registry Repository Reader`, `Container Registry Repository Catalog Lister`, and `Container Registry Configuration Reader and Data Access Configuration Reader`
    - Permissions: Grants control plane access to view and list ACR registries, as well as to audit registry configurations for audit and compliance. Also grants permissions to pull images, artifacts, and view tags to scan and analyze images for vulnerabilities.
    - ABAC support: ACR recommends that vulnerability scanners and monitors have full data plane access to all repositories in the registry. As such, assign these roles without Microsoft Entra ABAC conditions to grant role permissions without scoping them to specific repositories.
- **Scenario: Pipelines and identities that orchestrate [ACR tasks](container-registry-tasks-overview)**

    - Role: `Container Registry Tasks Contributor`
    - Permissions: Manage [ACR tasks](container-registry-tasks-overview), including task definitions and task runs, [task agent pools](tasks-agent-pools), [quick builds with `az acr build`](/en-us/cli/azure/acr#az-acr-build) and [quick runs with `az acr run`](/en-us/cli/azure/acr#az-acr-run), and [task logs](container-registry-tasks-logs). Doesn't include data plane permissions or broader registry configuration.
    - Note: To fully manage [task identities](container-registry-tasks-authentication-managed-identity), the assignee must have the [`Managed Identity Operator`](/en-us/azure/role-based-access-control/built-in-roles/identity#managed-identity-operator) role.
    - ABAC support: This role doesn't support Microsoft Entra ABAC conditions as the role is scoped to the registry level, granting permissions to manage all ACR Tasks in the registry.
- **Scenario: Identities such as pipelines and developers that [import images with `az acr import`](container-registry-import-images)**

    - Role: `Container Registry Data Importer and Data Reader`
    - Permissions: Grants control plane access to trigger [image imports using `az acr import`](container-registry-import-images), and data plane access to validate import success (pull imported images and artifacts, view repository contents, list OCI referrers, and inspect imported tags). Doesn't allow pushing or modifying any content in the registry.
    - ABAC support: This role doesn't support Microsoft Entra ABAC conditions as the role is scoped to the registry level, granting permissions to import images into any repository in the registry. It also grants permissions to read images in all repositories in the registry.
- **Scenario: Identities such as pipelines and developers that manage [ACR transfer pipelines](container-registry-transfer-cli) for transferring artifacts between registries using intermediary storage accounts across network, tenant, or air gap boundaries**

    - Role: `Container Registry Transfer Pipeline Contributor`
    - Permissions: Grants control plane access to manage [ACR import/export transfer pipelines and pipeline runs](container-registry-transfer-cli) using intermediary storage accounts. Doesn't include data plane permissions, broader registry access, or permissions to manage other Azure resource types such as storage accounts or key vaults.
    - ABAC support: This role doesn't support Microsoft Entra ABAC conditions as the role is scoped to the registry level, granting permissions to manage all ACR transfer pipelines in the registry.
- **Scenario: Management of [quarantined images](https://github.com/Azure/acr/blob/main/docs/preview/quarantine/readme.md)**

    - Roles: `AcrQuarantineReader` and `AcrQuarantineWriter`
    - Permissions: Manage quarantined images in the registry, including listing and pulling quarantined images for further inspection, and modifying the quarantine status of images. Quarantined images are pushed images that can't be pulled or used until they're unquarantined.
    - ABAC support: This role doesn't support Microsoft Entra ABAC conditions as the role is scoped to the registry level, granting permissions to manage all quarantined images in the registry.
- **Scenario: Developers or processes that configure registry [auto-purge on ACR Tasks](container-registry-auto-purge)**

    - Role: `Container Registry Tasks Contributor`
    - Permissions: Grants control plane permissions to manage [auto-purge, which runs on ACR Tasks](container-registry-auto-purge).
    - ABAC support: This role doesn't support Microsoft Entra ABAC conditions as the role is scoped to the registry level, granting permissions to manage all ACR Tasks in the registry.
- **Scenario: Visual Studio Code Docker extension users**

    - Roles: `Container Registry Repository Writer`, `Container Registry Tasks Contributor`, and `Container Registry Contributor and Data Access Configuration Administrator`
    - Permissions: Grants capabilities to browse registries, pull and push images, and build images by using `az acr build`, supporting common developer workflows in Visual Studio Code.
    - ABAC support: ACR recommends that Visual Studio Code users have full data plane access to all repositories in the registry. As such, assign these roles without Microsoft Entra ABAC conditions to grant role permissions without scoping them to specific repositories.

# [Registries configured with &quot;RBAC Registry Permissions&quot;](#tab/registries-configured-with-rbac-registry-permissions)
- **Scenario: Identities that need to pull images and validate supply chain artifacts such as developers, pipelines, and container orchestrators (for example, Azure Kubernetes Service node kubelet identity, Azure Container Apps, Azure Container Instances, Azure Machine Learning workspaces)**

    - Role: `AcrPull`
    - Purpose: Grants data plane read-only access to pull images and artifacts, view tags, repositories, Open Container Initiative (OCI) referrers, and artifact streaming configurations. Doesn't include any control plane or write permissions.
- **Scenario: Identities such as CI/CD build pipelines and developers that build and push images, as well as manage image tags**

    - Role: `AcrPush`
    - Permissions: Grants data plane access to push and pull images and artifacts, manage tags, work with OCI referrers, and configure artifact streaming for repositories and images. Doesn't include any control plane permissions.
- **Scenario: Pipelines, identities, and developers that sign images**

    - For signing images with OCI referrers such as [Notary Project](container-registry-tutorial-sign-build-push):
        - Role: `AcrPush`
        - Permissions: Grants data plane access to push signatures in the form of OCI referrers attached to images and artifacts. Doesn't include any control plane permissions.
    - For signing images with [Docker Content Trust (DCT)](container-registry-content-trust):
        - Role: `AcrImageSigner`
        - Permissions: Sign images in the registry with [Docker Content Trust (DCT)](container-registry-content-trust).
        - Note: Docker Content Trust is being [deprecated](container-registry-content-trust-deprecation).
- **Scenario: Developers and command line scripts that use `az` CLI to authenticate and login to the registry (via the `az acr login` command), as well as to run other `az` CLI control plane commands on a registry.** Take note that identities that only need image pull, push, or delete permissions do not need the following role. This scenario is strictly about clarifying the role that grants permissions to enable running `az` CLI on a registry, including `az acr login` and other `az` CLI control plane commands on a registry. This role also grants permissions to create, update, or delete ACR registries, as well as control plane permissions to manage registry configuration. This role does not grant data plane permissions to pull, push, or delete images; those are granted by the separate data plane roles.

    - Role: `Container Registry Contributor and Data Access Configuration Administrator`
- **Scenario: Pipelines, identities, and developers that need to create, update, or *delete* ACR registries**

    - Role: `Container Registry Contributor and Data Access Configuration Administrator`
    - Permissions:
        - Grants control plane access to **create, configure, manage, and *delete***registries, including:
            - authenticate and login to the registry using `az` CLI via the `az acr login` command
            - run other `az` CLI control plane commands on a registry that read, update, or delete registry control plane configuration (take note that this role does not grant data plane permissions needed to run certain `az` CLI commands)
            - configure [registry SKUs](container-registry-skus)
            - authentication access settings ([admin user login credentials](container-registry-authentication#admin-account), [anonymous pull](anonymous-pull-access), [non-Microsoft Entra token-based repository permissions](container-registry-token-based-repository-permissions), and [Microsoft Entra authentication-as-arm token audience](container-registry-disable-authentication-as-arm)),
            - configure ([geo-replications](container-registry-geo-replication)),
            - on-premises features ([connected registries](intro-connected-registry)),
            - registry endpoints ([dedicated data endpoints](container-registry-dedicated-data-endpoints))
            - network access ([private link and private endpoint settings](container-registry-private-endpoints), [public network access](container-registry-private-endpoints#disable-public-access-to-a-registry), [trusted services bypass](allow-access-trusted-services), [network firewall rules](container-registry-access-selected-networks), and [Virtual Network (VNET) service endpoints](container-registry-vnet))
            - registry policies ([retention policy](container-registry-retention-policy), [registry-wide quarantine enablement](https://github.com/Azure/acr/blob/main/docs/preview/quarantine/readme.md), [soft-delete enablement](container-registry-soft-delete-policy), and [data exfiltration export policy](data-loss-prevention))
            - [diagnostics and monitoring settings](monitor-container-registry) (diagnostic settings, logs, metrics, [webhooks for registries and geo-replications](container-registry-webhook), and [Event Grid](container-registry-event-grid-quickstart))
            - manage a [registry's system-assigned managed identity](/en-us/cli/azure/acr/identity)
        - Note: this role grants permissions to delete the registry itself.
        - Note: this role doesn't include data plane operations (for example, image push/pull), role assignment capabilities, or ACR task.
        - Note: to manage a [registry's user-assigned managed identity](/en-us/cli/azure/acr/identity), the assignee must also have the [`Managed Identity Operator`](/en-us/azure/role-based-access-control/built-in-roles/identity#managed-identity-operator) role.
- **Scenario: Pipelines, infrastructure engineers, or control plane observability/monitoring tools that need to list registries and view registry configurations, but not access to registry images**

    - Role: `Container Registry Configuration Reader and Data Access Configuration Reader`
    - Permissions: **Read-only counterpart of the `Container Registry Contributor and Data Access Configuration Administrator` role**. Grants control plane access to view and list registries and inspect registry configurations, but not modify them. Doesn't include data plane operations (for example, image push/pull) or role assignment capabilities.
- **Scenario: Vulnerability scanners and tools that need to audit registries and registry configurations, as well as access to registry images to scan them for vulnerabilities**

    - Roles: `AcrPull` and `Container Registry Configuration Reader and Data Access Configuration Reader`
    - Permissions: Grants control plane access to view and list ACR registries, as well as to audit registry configurations for audit and compliance. Also grants permissions to pull images, artifacts, and view tags to scan and analyze images for vulnerabilities.
- **Scenario: Pipelines and identities that orchestrate [ACR tasks](container-registry-tasks-overview)**

    - Role: `Container Registry Tasks Contributor`
    - Permissions: Manage [ACR tasks](container-registry-tasks-overview), including task definitions and task runs, [task agent pools](tasks-agent-pools), [quick builds with `az acr build`](/en-us/cli/azure/acr#az-acr-build) and [quick runs with `az acr run`](/en-us/cli/azure/acr#az-acr-run), and [task logs](container-registry-tasks-logs). Doesn't include data plane permissions or broader registry configuration.
    - Note: To fully manage [task identities](container-registry-tasks-authentication-managed-identity), the assignee must have the [`Managed Identity Operator`](/en-us/azure/role-based-access-control/built-in-roles/identity#managed-identity-operator) role.
- **Scenario: Identities such as pipelines and developers that [import images with `az acr import`](container-registry-import-images)**

    - Role: `Container Registry Data Importer and Data Reader`
    - Permissions: Grants control plane access to trigger [image imports using `az acr import`](container-registry-import-images), and data plane access to validate import success (pull imported images and artifacts, view repository contents, list OCI referrers, and inspect imported tags). Doesn't allow pushing or modifying any content in the registry.
- **Scenario: Identities such as pipelines and developers that manage [ACR transfer pipelines](container-registry-transfer-cli) for transferring artifacts between registries using intermediary storage accounts across network, tenant, or air gap boundaries**

    - Role: `Container Registry Transfer Pipeline Contributor`
    - Permissions: Grants control plane access to manage [ACR import/export transfer pipelines and pipeline runs](container-registry-transfer-cli) using intermediary storage accounts. Doesn't include data plane permissions, broader registry access, or permissions to manage other Azure resource types such as storage accounts or key vaults.
- **Scenario: Management of [quarantined images](https://github.com/Azure/acr/blob/main/docs/preview/quarantine/readme.md)**

    - Roles: `AcrQuarantineReader` and `AcrQuarantineWriter`
    - Permissions: Manage quarantined images in the registry, including listing and pulling quarantined images for further inspection, and modifying the quarantine status of images. Quarantined images are pushed images that can't be pulled or used until they're unquarantined.
- **Scenario: Deleting images, artifacts, tags, and OCI referrers**

    - Role: `AcrDelete`
    - Permissions: Provides permissions to delete artifacts and tags across all repositories in the registry. This role doesn't grant permissions to delete the registry itself.
- **Scenario: Developers or processes that configure registry [auto-purge on ACR Tasks](container-registry-auto-purge)**

    - Role: `Container Registry Tasks Contributor`
    - Permissions: Grants control plane permissions to manage [auto-purge, which runs on ACR Tasks](container-registry-auto-purge).
- **Scenario: Visual Studio Code Docker extension users**

    - Roles: `AcrPush`, `Container Registry Tasks Contributor`, and `Container Registry Contributor and Data Access Configuration Administrator`
    - Permissions: Grants capabilities to browse registries, pull and push images, and build images by using `az acr build`, supporting common developer workflows in Visual Studio Code.

---