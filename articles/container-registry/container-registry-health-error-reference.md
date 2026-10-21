---
layout: Conceptual
title: Error Reference for Registry Health Checks - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-health-error-reference
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
description: Error codes and possible solutions to problems found by running the az acr check-health diagnostic command in Azure Container Registry
ms.topic: reference
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 63a4a6d7-2f3b-1f3a-fbfe-f10b55a35c03
document_version_independent_id: 8acdf23c-1d6b-0734-a345-a7a1863440e1
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-health-error-reference.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-health-error-reference
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-health-error-reference.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: bf910b0b-d35d-5152-f6bc-5ffd4479d24c
---

# Error Reference for Registry Health Checks - Azure Container Registry | Microsoft Learn

Following are details about error codes returned by the [az acr check-health](/en-us/cli/azure/acr#az-acr-check-health) command. For each error, possible solutions are listed.

For information about running `az acr check-health`, see [Check the health of an Azure container registry](container-registry-check-health).

## DOCKER\_COMMAND\_ERROR

This error means that Docker client for CLI couldn't be found. As a result, the following additional checks aren't run: finding Docker version, evaluating Docker daemon status, and running a Docker pull command.

*Potential solutions*: Install Docker client; add Docker path to the system variables.

## DOCKER\_DAEMON\_ERROR

This error means that the Docker daemon status is unavailable, or that it couldn't be reached using the CLI. As a result, Docker operations (such as `docker login` and `docker pull`) are unavailable through the CLI.

*Potential solutions*: Restart Docker daemon, or validate that it is properly installed.

## DOCKER\_VERSION\_ERROR

This error means that CLI wasn't able to run the command `docker --version`.

*Potential solutions*: Try running the command manually, make sure you have the latest CLI version, and investigate the error message.

## DOCKER\_PULL\_ERROR

This error means that the CLI wasn't able to pull a sample image to your environment.

*Potential solutions*: Validate that all components necessary to pull an image are running properly. Additionally, validate permissions and [troubleshoot registry login, authentication, and authorization](container-registry-troubleshoot-login-authn-authz). If you're using [Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions) and authenticating with a Microsoft Entra identity (user, managed identity, or service principal), make sure the identity has permissions to the specific repository being accessed.

## HELM\_COMMAND\_ERROR

This error means that Helm client couldn't be found by the CLI, which precludes other Helm operations.

*Potential solutions*: Verify that Helm client is installed, and that its path is added to the system environment variables.

## HELM\_VERSION\_ERROR

This error means that the CLI was unable to determine the Helm version installed. This can happen if the Azure CLI version (or if the Helm version) being used is obsolete.

*Potential solutions*: Update to the latest Azure CLI version or to the recommended Helm version; run the command manually and investigate the error message.

## CMK\_ERROR

This error means that the registry can't access the user-assigned or sysem-assigned managed identity used to configure registry encryption with a customer-managed key. The managed identity might have been deleted.

*Potential solution*: To resolve the issue and rotate the key using a different managed identity, see steps to troubleshoot [the user-assigned identity](tutorial-troubleshoot-customer-managed-keys).

## CONNECTIVITY\_DNS\_ERROR

This error means that the DNS for the given registry login server was pinged but didn't respond, which means it is unavailable. This can indicate some connectivity issues. Alternatively, the registry might not exist, the user might not have the permissions on the registry (to retrieve its login server properly), or the target registry is in a different cloud than the one used in the Azure CLI.

*Potential solutions*: Validate connectivity; verify spelling of the registry, and that registry exists; verify that the user has the right permissions on it and that the registry's cloud is the same that is used in the Azure CLI.

## CONNECTIVITY\_FORBIDDEN\_ERROR

This error means that the challenge endpoint for the given registry responded with a 403 Forbidden HTTP status. This error means that users don't have access to the registry, most likely because of a virtual network configuration or because access to the registry's public endpoint isn't allowed. To see the currently configured firewall rules, run `az acr show --query networkRuleSet --name <registry>`.

*Potential solutions*: Remove virtual network rules, or add the current client IP address to the allowed list.

## CONNECTIVITY\_CHALLENGE\_ERROR

This error means that the challenge endpoint of the target registry didn't issue a challenge.

*Potential solutions*: Try again after some time. If the error persists, open an issue at https://aka.ms/acr/issues.

## CONNECTIVITY\_AAD\_LOGIN\_ERROR

This error means that the challenge endpoint of the target registry issued a challenge, but the registry doesn't support Microsoft Entra authentication.

*Potential solutions*: Try a different way to authenticate, for example, with admin credentials. If users need to authenticate using Microsoft Entra ID, open an issue at https://aka.ms/acr/issues.

## CONNECTIVITY\_REFRESH\_TOKEN\_ERROR

This error means that the registry login server didn't respond with a refresh token, so access to the target registry was denied. This error can occur if the user doesn't have the right permissions on the registry or if the user credentials for the Azure CLI are stale.

*Potential solutions*: Verify if the user has the right permissions on the registry; run `az login` to refresh permissions, tokens, and credentials. Additionally, validate permissions and [troubleshoot registry login, authentication, and authorization](container-registry-troubleshoot-login-authn-authz). If you're using [Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions) and authenticating with a Microsoft Entra identity (user, managed identity, or service principal), make sure the identity has permissions to the specific repository being accessed.

## CONNECTIVITY\_ACCESS\_TOKEN\_ERROR

This error means that the registry login server didn't respond with an access token, so that the access to the target registry was denied. This error can occur if the user doesn't have the right permissions on the registry or if the user credentials for the Azure CLI are stale.

*Potential solutions*: Verify if the user has the right permissions on the registry; run `az login` to refresh permissions, tokens, and credentials. Additionally, validate permissions and [troubleshoot registry login, authentication, and authorization](container-registry-troubleshoot-login-authn-authz). If you're using [Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions) and authenticating with a Microsoft Entra identity (user, managed identity, or service principal), make sure the identity has permissions to the specific repository being accessed.

## CONNECTIVITY\_SSL\_ERROR

This error means that the client was unable to establish a secure connection to the container registry. This error generally occurs if you're running or using a proxy server.

*Potential solutions*: More information on working behind a proxy can be [found here](/en-us/cli/azure/use-cli-effectively).

## LOGIN\_SERVER\_ERROR

This error means that the CLI was unable to find the login server of the given registry, and no default suffix was found for the current cloud. This error can occur if the registry doesn't exist, if the user doesn't have the right permissions on the registry, if the registry's cloud and the current Azure CLI cloud do not match, or if the Azure CLI version is obsolete.

*Potential solutions*: Verify that the spelling is correct and that the registry exists; verify that user has the right permissions on the registry, and that the clouds of the registry and the CLI environment match; update Azure CLI to the latest version.

## NOTARY\_VERSION\_ERROR

This error means that the CLI isn't compatible with the currently installed version of Docker/Notary. Try downgrading your notary.exe version to a version earlier than 0.6.0 by replacing your Docker installation's Notary client manually to resolve this issue. You can also try downloading and installing a pre-compiled binary of Notary earlier than 0.6.0 for 64 bit Linux or macOS X from the Notary repository's releases page on GitHub. For windows download the .exe, place it in the(default path: C:\ProgramFiles\Docker\Docker\resources\bin) and rename it to notary.exe.

## NOTARY\_COMMAND\_ERROR

This error means that Notary client CLI couldn't be found. As a result, the notary checks aren't run.

*Potential solutions*: Install Notary client; add Notary path to the system variables.

## CONNECTIVITY\_TOOMANYREQUESTS\_ERROR

This error means that the user has sent too many requests in a short period causing the authentication system to block further requests to prevent overload. This error occurs by reaching a configured limit in the user's registry service tier or environment. We recommend waiting for a moment before sending another request. This will allow the authentication system's block to lift and you can try sending a request again.