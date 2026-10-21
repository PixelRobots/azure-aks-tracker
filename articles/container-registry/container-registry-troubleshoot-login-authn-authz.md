---
layout: Conceptual
title: Troubleshooting Login, Authentication, and Authorization - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-troubleshoot-login-authn-authz
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
description: Identify symptoms, causes, and resolution of common problems when logging in, authenticating, or authorizing with Azure Container Registry.
ms.topic: troubleshooting
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 68f7af6f-e399-0cc1-c309-d930ddeaaade
document_version_independent_id: da9d1a53-07fd-7f72-3f31-d642927a7b36
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-troubleshoot-login-authn-authz.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-troubleshoot-login-authn-authz
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-troubleshoot-login-authn-authz.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
- https://authoring-docs-microsoft.poolparty.biz/devrel/b1cfdec6-b0c3-4209-818c-736879856e0e
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
- https://authoring-docs-microsoft.poolparty.biz/devrel/2d0723c1-cf38-4c30-ab3d-5df787b33270
platformId: 7b46c2d9-56c0-5d89-3491-9dba78641beb
---

# Troubleshooting Login, Authentication, and Authorization - Azure Container Registry | Microsoft Learn

This article helps you troubleshoot problems you might encounter when logging into, authenticating, or authorizing with an Azure Container Registry.

## Symptoms

May include one or more of the following:

- Unable to log in to registry using `docker login`, `az acr login`, or both
- Unable to log in to registry and you receive error `unauthorized: authentication required` or `unauthorized: Application not registered with AAD`
- Unable to log in to registry and you receive Azure CLI error `Could not connect to the registry login server`
- Unable to push or pull images and you receive Docker error `unauthorized: authentication required`
- Unable to access a registry using `az acr login` and you receive error `CONNECTIVITY_REFRESH_TOKEN_ERROR. Access to registry was denied. Response code: 403. Unable to get admin user credentials with message: Admin user is disabled. Unable to authenticate using AAD or admin login credentials.`
- Unable to access registry from Azure Kubernetes Service, Azure DevOps, or another Azure service
- Unable to access registry and you receive error `Error response from daemon: login attempt failed with status: 403 Forbidden` - See [Troubleshoot network issues with registry](container-registry-troubleshoot-access)
- Unable to access or view registry settings in Azure portal or manage registry using the Azure CLI

## Causes

- Docker isn't configured properly in your environment - solution
- The registry doesn't exist or the name is incorrect - solution
- The registry credentials aren't valid - solution
- The registry public access is disabled. Public network access rules on the registry prevent access - [solution](container-registry-troubleshoot-access#configure-public-access-to-registry)
- The credentials aren't authorized for push, pull, or Azure Resource Manager operations - solution
- The credentials are expired - solution
- If you're using Microsoft Entra role-based access control (RBAC) for managing registry permissions for a Microsoft Entra identity (user, managed identity, or service principal), the identity may have registry permissions but not repository permissions - solution

## Further diagnosis

Run the [az acr check-health](/en-us/cli/azure/acr#az-acr-check-health) command to get more information about the health of the registry environment and optionally access to a target registry. For example, diagnose Docker configuration errors or Microsoft Entra login problems.

See [Check the health of an Azure container registry](container-registry-check-health) for command examples. If errors are reported, review the [error reference](container-registry-health-error-reference) and the following sections for recommended solutions.

Follow the instructions from the [AKS support doc](/en-us/troubleshoot/azure/azure-kubernetes/cannot-pull-image-from-acr-to-aks-cluster) if you fail to pull images from ACR to the AKS cluster.

Note

Some authentication or authorization errors can also occur if there are firewall or network configurations that prevent registry access. See [Troubleshoot network issues with registry](container-registry-troubleshoot-access).

## Potential solutions

### Check Docker configuration

Most Azure Container Registry authentication flows require a local Docker installation so you can authenticate with your registry for operations such as pushing and pulling images. Confirm that the Docker CLI client and daemon (Docker Engine) are running in your environment. You need Docker client version 18.03 or later.

Related links:

- [Authentication overview](container-registry-authentication#authentication-options)
- [Container registry FAQ](container-registry-faq)

### Specify correct registry name

When using `docker login`, provide the full login server name of the registry, such as *myregistry.azurecr.io*. Ensure that you use only lowercase letters. Example:

```console
docker login myregistry.azurecr.io
```

When using [az acr login](/en-us/cli/azure/acr#az-acr-login) with a Microsoft Entra identity, first [sign in to the Azure CLI](/en-us/cli/azure/authenticate-azure-cli), and then specify the Azure resource name of the registry. The resource name is the name provided when the registry was created, such as *myregistry* (without a domain suffix). Example:

```azurecli
az acr login --name myregistry
```

### Confirm credentials to access registry

Check the validity of the credentials you use for your scenario, or were provided to you by a registry owner. Some possible issues:

- If using an Active Directory service principal, ensure you use the correct credentials in the Active Directory tenant:
    - User name - service principal application ID (also called *client ID*)
    - Password - service principal password (also called *client secret*)
- If using an Azure service such as Azure Kubernetes Service or Azure DevOps to access the registry, confirm the registry configuration for your service.
- If you ran `az acr login` with the `--expose-token` option, which enables registry login without using the Docker daemon, ensure that you authenticate with the username `00000000-0000-0000-0000-000000000000`.
- If your registry is configured for [anonymous pull access](container-registry-faq#how-do-i-enable-anonymous-pull-access-), existing Docker credentials stored from a previous Docker login can prevent anonymous access. Run `docker logout` before attempting an anonymous pull operation on the registry.

Related links:

- [Authentication overview](container-registry-authentication#authentication-options)
- [Manage Microsoft Entra role-based access control (RBAC) for registry permissions](container-registry-rbac-built-in-roles-overview).
- [Manage Microsoft Entra attribute-based access control (ABAC) for Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions).
- [Individual login with Microsoft Entra ID](container-registry-authentication#individual-login-with-azure-ad)
- [Login with service principal](container-registry-auth-service-principal)
- [Login with managed identity](container-registry-authentication-managed-identity)
- [Login with non-Microsoft Entra token-based repository permissions](container-registry-token-based-repository-permissions)
- [Login with admin account](container-registry-authentication#admin-account)
- [Microsoft Entra authentication and authorization error codes](/en-us/azure/active-directory/develop/reference-aadsts-error-codes)
- [az acr login](/en-us/cli/azure/acr#az-acr-login) reference

### Confirm credentials are authorized to access registry

- If your permissions recently changed to allow registry access though the portal, you might need to try an incognito or private session in your browser to avoid any stale browser cache or cookies.
- You or a registry owner must have sufficient privileges in the subscription to add, modify, or remove Microsoft Entra role assignments. Permissions to manage Microsoft Entra role assignments is granted by the `Role Based Access Control Administrator` role.
- Access to a registry in the portal or registry management using the Azure CLI requires at least the `Container Registry Contributor and Data Access Configuration Administrator` role or equivalent permissions to perform Azure Resource Manager operations.

#### Validate identity permissions and role assignments

- If you're using Microsoft Entra role-based access control (RBAC) for managing registry permissions, confirm that the identity (user, managed identity, or service principal) has the correct role assignment and permissions.
    - If your "Registry role assignment permissions mode" (in the Azure portal "Properties" blade) is set to the new "RBAC Registry + ABAC Repository Permissions" option, and the identity can't push, pull, or delete images, the identity may not have permissions to access the specific repository the image is in.
        - Check existing role assignments and role assignment ABAC conditions to ensure the identity has the correct permissions to access the repository.
        - **Registries with "RBAC Registry + ABAC Repository Permissions" mode don't honor the existing `AcrPull`, `AcrPush`, or `AcrDelete` roles.**
        - **Instead, such registries only honor the `Container Registry Repository Reader`, `Container Registry Repository Writer`, and `Container Registry Repository Contributor` roles to read, write, or delete images within repositories in a registry.** These roles may have optional ABAC conditions that restrict permissions granted to specific repositories.
        - Take note that these roles don't grant permissions to catalog listing to list repositories in the registry. To list repositories (but not read content within repositories), you must separately assign the `Container Registry Repository Catalog Lister` role to the identity. This role doesn't support ABAC conditions so it grants permissions to list all repositories in a registry.
        - For more information, see [Microsoft Entra attribute-based access control (ABAC) for Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions).
    - If your "Registry role assignment permissions mode" is set to the old "RBAC Registry Permissions" option, the identity may not have permissions to access the registry and its repositories.
        - Check existing role assignments to ensure the identity has the correct permissions to access the registry and its repositories.
        - **Registries with "RBAC Registry Permissions" mode only honor the `AcrPull`, `AcrPush`, or `AcrDelete` roles to read, write, or delete images within repositories in a registry.**
        - For more information, see [Azure Container Registry Microsoft Entra permissions and roles overview](container-registry-rbac-built-in-roles-overview).

Related links:

- [Azure Container Registry Microsoft Entra permissions and roles overview](container-registry-rbac-built-in-roles-overview)
- [Manage Microsoft Entra role-based access control (RBAC) for registry permissions](container-registry-rbac-built-in-roles-overview).
- [Manage Microsoft Entra attribute-based access control (ABAC) for Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions).
- [Add or remove Azure role assignments using the Azure portal](/en-us/azure/role-based-access-control/role-assignments-portal)
- [Use the portal to create a Microsoft Entra application and service principal that can access resources](/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- [Create a new application secret](/en-us/azure/active-directory/develop/howto-create-service-principal-portal#option-3-create-a-new-client-secret)
- [Microsoft Entra authentication and authorization codes](/en-us/azure/active-directory/develop/reference-aadsts-error-codes)
- [Login with non-Microsoft Entra token-based repository permissions](container-registry-token-based-repository-permissions)

### Check that credentials aren't expired

Tokens and Active Directory credentials may expire after defined periods, preventing registry access. To enable access, credentials might need to be reset or regenerated.

- If using an individual AD identity, a managed identity, or service principal for registry login, the AD token expires after 3 hours. Log in again to the registry.
- If using an AD service principal with an expired client secret, a subscription owner or account administrator needs to reset credentials or generate a new service principal.
- If using a [non-Microsoft Entra token-based repository permissions](container-registry-token-based-repository-permissions), a registry owner might need to reset a password or generate a new token.

Related links:

- [Reset service principal credentials](/en-us/cli/azure/ad/sp/credential#az-ad-sp-credential-reset)
- [Regenerate non-Microsoft Entra token passwords](container-registry-token-based-repository-permissions#regenerate-token-passwords)
- [Individual login with Microsoft Entra ID](container-registry-authentication#individual-login-with-azure-ad)

## Advanced troubleshooting

If [collection of resource logs](monitor-service) is enabled in the registry, review the ContainerRegistryLoginEvents log. This log stores authentication events and status, including the incoming identity and IP address. Query the log for [registry authentication failures](monitor-service#registry-authentication-failures).

Related links:

- [Logs for diagnostic evaluation and auditing](monitor-service)
- [Container registry FAQ](container-registry-faq)
- [Best practices for Azure Container Registry](container-registry-best-practices)