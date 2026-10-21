---
layout: Conceptual
title: Azure Container Registry Authentication Options Explained - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication
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
description: Authentication options for a private Azure container registry, including signing in with a Microsoft Entra identity, using service principals, and using optional admin credentials.
ms.topic: concept-article
ms.date: 2026-02-02T00:00:00.0000000Z
locale: en-us
document_id: df40e112-6cf4-f6ce-4d82-d36bbd561405
document_version_independent_id: a68e6e7b-dfa2-8640-0a43-cd15f24facdb
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-authentication.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-authentication
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-authentication.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d640dfa0-0420-f1f8-6c72-b1e72f012dc1
---

# Azure Container Registry Authentication Options Explained - Azure Container Registry | Microsoft Learn

You can authenticate with an Azure container registry in several ways. Review these options to determine what works best for your container registry usage scenario.

For most scenarios, authenticate by using one of the following Microsoft Entra ID-based methods:

- Individual login - Authenticate directly to a registry
- Service principal - Use a Microsoft Entra service principal for unattended, or "headless," authentication by applications and container orchestrators

## Authentication options

The following table lists available authentication methods and typical scenarios, with links to more details.

Tip

For authentication from Azure Kubernetes Service (AKS) or another Kubernetes cluster, see [Scenarios to authenticate with Azure Container Registry from Kubernetes](authenticate-kubernetes-options).

| Method | How to authenticate | Scenarios | Microsoft Entra role-based access control (RBAC) | Limitations |
| --- | --- | --- | --- | --- |
| Individual Microsoft Entra identity | `az acr login` in Azure CLI`Connect-AzContainerRegistry` in Azure PowerShell | Interactive push/pull by developers, testers | Yes | Microsoft Entra token must be renewed every 3 hours |
| Microsoft Entra service principal | `docker login``az acr login` in Azure CLI`Connect-AzContainerRegistry` in Azure PowerShell Registry login settings in APIs or tooling | Unattended push from CI/CD pipeline Unattended pull to Azure or external services | Yes | SP password default expiry is 1 year |
| [Microsoft Entra managed identity for Azure resources](container-registry-authentication-managed-identity) | `docker login``az acr login` in Azure CLI`Connect-AzContainerRegistry` in Azure PowerShell | Unattended push from Azure CI/CD pipeline Unattended pull to Azure servicesFor a list of managed identity role assignment scenarios, see [ACR Entra permissions and role assignments](container-registry-rbac-built-in-roles-overview). | Yes | Can only be used from select Azure services that [support managed identities for Azure resources](/en-us/azure/active-directory/managed-identities-azure-resources/services-support-managed-identities#azure-services-that-support-managed-identities-for-azure-resources) |
| Admin user | `docker login` | Interactive push/pull by individual developer or testerPortal deployment of image from registry to Azure App Service or Azure Container Instances | No, always pull and push access | High level of access. Single account per registry; not recommended for multiple users |
| [Non-Microsoft Entra token-based repository permissions](container-registry-token-based-repository-permissions) | `docker login``az acr login` in Azure CLI`Connect-AzContainerRegistry` in Azure PowerShell | Interactive push/pull to repository by individual developer or tester Unattended pull from repository by individual system or external device | Token-based repository permissions **does not** support Microsoft Entra RBAC role assignments.For Microsoft Entra-based repository permissions, see [Azure attribute-based access control (ABAC) repository permissions in Azure Container Registry](container-registry-rbac-abac-repository-permissions) instead. | Not currently integrated with Microsoft Entra ID |

## Authenticate with Microsoft Entra ID

When working with your registry directly, such as pulling images and pushing images from a development workstation to a registry you created, authenticate by using your individual Azure identity.

# [Azure CLI](#tab/azure-cli)
Sign in to the [Azure CLI](/en-us/cli/azure/install-azure-cli) by using [az login](/en-us/cli/azure/reference-index#az-login), and then run the [az acr login](/en-us/cli/azure/acr#az-acr-login) command:

```azurecli
az login
az acr login --name <acrName>
```

When you sign in by using `az acr login`, the CLI uses the token created when you executed `az login` to seamlessly authenticate your session with your registry. To complete the authentication flow, the Docker CLI and Docker daemon must be installed and running in your environment. `az acr login` uses the Docker client to set a Microsoft Entra token in the `docker.config` file. After you sign in this way, your credentials are cached, and subsequent `docker` commands in your session don't require a username or password.

Tip

Also use `az acr login` to authenticate an individual identity when you want to push or pull artifacts other than Docker images to your registry, such as [OCI artifacts](container-registry-manage-artifact).

For registry access, the token that `az acr login` uses is valid for **3 hours**, so always sign in to the registry before running a `docker` command. If your token expires, refresh it by using the `az acr login` command again to reauthenticate.

Using `az acr login` with Azure identities enables [Azure role-based access control (RBAC)](/en-us/azure/role-based-access-control/overview). For some scenarios, you might want to sign in to a registry with your own individual identity in Microsoft Entra ID, or configure other Azure users with [specific roles](container-registry-rbac-built-in-roles-overview). For cross-service scenarios, or for a workgroup or a development workflow where you don't want to manage individual access, you can also sign in by using a [managed identity for Azure resources](container-registry-authentication-managed-identity).

### Use az acr login without Docker daemon

In some cases, you need to authenticate by using `az acr login` when the Docker daemon isn't running in your environment. For example, you might need to run `az acr login` in a script in Azure Cloud Shell, which provides the Docker CLI but doesn't run the Docker daemon.

For this scenario, run `az acr login` with the `--expose-token` parameter. This option returns an access token instead of signing in through the Docker CLI.

```azurecli
az acr login --name <acrName> --expose-token
```

The output displays the access token, abbreviated here:

```console
{
  "accessToken": "eyJhbGciOiJSUzI1NiIs[...]24V7wA",
  "loginServer": "myregistry.azurecr.io"
}
```

For registry authentication, store the token credential in a safe location and follow recommended practices to manage [docker login](https://docs.docker.com/engine/reference/commandline/login/) credentials. For example, store the token value in an environment variable:

```azurecli
TOKEN=$(az acr login --name <acrName> --expose-token --output tsv --query accessToken)
```

Then, run `docker login`, passing `00000000-0000-0000-0000-000000000000` as the username and using the access token as the password:

```console
docker login myregistry.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password-stdin <<< $TOKEN
```

Likewise, you can use the token returned by `az acr login` with the `helm registry login` command to authenticate with the registry:

```console
echo $TOKEN | helm registry login myregistry.azurecr.io \
            --username 00000000-0000-0000-0000-000000000000 \
            --password-stdin
```

# [Azure PowerShell](#tab/azure-powershell)
When you work directly with your registry, such as pulling images to and pushing images from a development workstation to a registry you created, authenticate by using your individual Azure identity. Sign in to [Azure PowerShell](/en-us/powershell/azure/uninstall-az-ps) by using [Connect-AzAccount](/en-us/powershell/module/az.accounts/connect-azaccount), and then run the [Connect-AzContainerRegistry](/en-us/powershell/module/az.containerregistry/connect-azcontainerregistry) cmdlet:

```azurepowershell
Connect-AzAccount
Connect-AzContainerRegistry -Name <acrName>
```

When you sign in by using `Connect-AzContainerRegistry`, PowerShell uses the token created when you executed `Connect-AzAccount` to seamlessly authenticate your session with your registry. To complete the authentication flow, the Docker CLI and Docker daemon must be installed and running in your environment. `Connect-AzContainerRegistry` uses the Docker client to set a Microsoft Entra token in the `docker.config` file. After you sign in this way, your credentials are cached, and subsequent `docker` commands in your session don't require a username or password.

Tip

Also use `Connect-AzContainerRegistry` to authenticate an individual identity when you want to push or pull artifacts other than Docker images to your registry, such as [OCI artifacts](container-registry-manage-artifact).

For registry access, the token used by `Connect-AzContainerRegistry` is valid for **3 hours**, so always log in to the registry before running a `docker` command. If your token expires, refresh it by using the `Connect-AzContainerRegistry` command again to reauthenticate.

Using `Connect-AzContainerRegistry` with Azure identities enables [Azure role-based access control (RBAC)](/en-us/azure/role-based-access-control/overview). For some scenarios, you might want to sign in to a registry with your own individual identity in Microsoft Entra ID, or configure other Azure users with [specific roles](container-registry-rbac-built-in-roles-overview). For cross-service scenarios, or for a workgroup or a development workflow where you don't want to manage individual access, you can also sign in by using a [managed identity for Azure resources](container-registry-authentication-managed-identity).

---

## Service principal

If you assign a [service principal](/en-us/azure/active-directory/develop/app-objects-and-service-principals) to your registry, your application or service can use it for headless authentication. Service principals enable [Azure role-based access control (RBAC)](/en-us/azure/role-based-access-control/overview) in a registry. You can assign multiple service principals to a registry, so you can use different [supported roles](container-registry-rbac-built-in-roles-overview) for specific applications.

For more information, see [Azure Container Registry authentication with service principals](container-registry-auth-service-principal).

## Admin account

Each container registry includes an admin user account, which is disabled by default. You can enable the admin user and manage its credentials in the Azure portal, or by using the Azure CLI, Azure PowerShell, or other Azure tools. The admin account has full permissions to the registry, so you should enable it only when necessary.

The admin account is currently required for some scenarios to deploy an image from a container registry to certain Azure services. For example, the admin account is needed when you use the Azure portal to deploy a container image from a registry directly to [Azure Container Instances](/en-us/azure/container-instances/container-instances-using-azure-container-registry) or Azure Container Apps.

Important

The admin account is designed for a single user to access the registry, mainly for testing purposes. Don't share the admin account credentials among multiple users. All users authenticating with the admin account appear as a single user with push and pull access to the registry. Changing or disabling this account disables registry access for all users who use its credentials. Use individual identity for users and service principals for headless scenarios.

The admin account has two passwords, both of which you can regenerate. Regenerating passwords for admin accounts takes approximately 60 seconds to replicate and become available. Because the account has two passwords, you can maintain connection to the registry by using one password while you regenerate the other. If you enable the admin account, you can pass the username and either password to the `docker login` command when prompted for basic authentication to the registry. For recommended practices to manage authentication credentials, see the [docker login](https://docs.docker.com/engine/reference/commandline/login/) command reference.

# [Azure CLI](#tab/azure-cli)
To enable the admin user for an existing registry, use the `--admin-enabled` parameter of the [az acr update](/en-us/cli/azure/acr#az-acr-update) command in the Azure CLI:

```azurecli
az acr update -n <acrName> --admin-enabled true
```

# [Azure PowerShell](#tab/azure-powershell)
To enable the admin user for an existing registry, use the `EnableAdminUser` parameter of the [Update-AzContainerRegistry](/en-us/powershell/module/az.containerregistry/update-azcontainerregistry) command in Azure PowerShell:

```azurepowershell
Update-AzContainerRegistry -Name <acrName> -ResourceGroupName myResourceGroup -EnableAdminUser
```

---

You can also enable the admin user for your registry in the Azure portal. In the service menu, under **Settings**, select **Access keys**. Then check the **Admin user** box to enable the account. The admin username is displayed, along with the two passwords, which you can show or regenerate as needed.

## Sign in by using an alternative container tool instead of Docker

In some scenarios, you need to use alternative container tools like `podman` instead of Docker.

The default container tool is set to `docker` for `az acr login` commands. If you don't set the default container tool and the `docker` command is missing in your environment, you see an error. To change the default container tool that the `az acr login` command uses, set the environment variable `DOCKER_COMMAND`. For example:

```azurecli
DOCKER_COMMAND=podman \
az acr login --name <acrName>
```