---
layout: Conceptual
title: Quick Diagnostics for Azure Container Registry Health - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-check-health
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
description: Learn how to run a quick diagnostic command to identify common problems with Azure container registry, including Docker configuration and connectivity.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 70c29709-b461-9b56-eb1b-2202f4d83904
document_version_independent_id: ac46ac32-a26a-4874-5e58-bbacb5f0f5cb
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-check-health.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-check-health
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-check-health.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 1c0c69d6-ed6a-a80d-14ce-8f30ae78f3ab
---

# Quick Diagnostics for Azure Container Registry Health - Azure Container Registry | Microsoft Learn

When using an Azure container registry, you might occasionally encounter problems. For example, you might not be able to pull a container image because of an issue with Docker in your local environment. Or, a network issue might prevent you from connecting to the registry.

As a first diagnostic step, run the [az acr check-health](/en-us/cli/azure/acr#az-acr-check-health) command to get information about the health of the environment and optionally access to a target registry. This command is available in Azure CLI version 2.0.67 or later. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

For additional registry troubleshooting guidance, see:

- [Troubleshoot registry login, authentication, and authorization](container-registry-troubleshoot-login-authn-authz)
- [Troubleshoot network issues with registry](container-registry-troubleshoot-access)
- [Troubleshoot registry performance](container-registry-troubleshoot-performance)

## Run az acr check-health

The following examples show different ways to run the `az acr check-health` command.

Note

If you run the command in Azure Cloud Shell, the local environment isn't checked. However, you can check the access to a target registry.

### Check the environment only

To check the local Docker daemon, CLI version, and Helm client configuration, run the command without additional parameters:

```azurecli
az acr check-health
```

### Check the environment and a target registry

To check access to a registry as well as perform local environment checks, pass the name of a target registry. For example:

```azurecli
az acr check-health --name myregistry
```

### Check registry access in a virtual network

To verify DNS settings to route to a private endpoint, pass the virtual network's name or resource ID. The resource ID is required when the virtual network is in a different subscription or resource group than the registry.

```azurecli
az acr check-health --name myregistry --vnet myvnet
```

## Error reporting

The command logs information to the standard output. If a problem is detected, it provides an error code and description. For more information about the codes and possible solutions, see the [error reference](container-registry-health-error-reference).

By default, the command stops whenever it finds an error. You can also run the command so that it provides output for all health checks, even if errors are found. Add the `--ignore-errors` parameter, as shown in the following examples:

```azurecli
# Check environment only
az acr check-health --ignore-errors

# Check environment and target registry; skip confirmation to pull image
az acr check-health --name myregistry --ignore-errors --yes
```

Sample output:

```azurecli
az acr check-health --name myregistry --ignore-errors --yes
```

```output
Docker daemon status: available
Docker version: Docker version 18.09.2, build 6247962
Docker pull of 'mcr.microsoft.com/mcr/hello-world:latest' : OK
ACR CLI version: 2.2.9
Helm version:
Client: &version.Version{SemVer:"v2.14.1", GitCommit:"5270352a09c7e8b6e8c9593002a73535276507c0", GitTreeState:"clean"}
DNS lookup to myregistry.azurecr.io at IP 40.xxx.xxx.162 : OK
Challenge endpoint https://myregistry.azurecr.io/v2/ : OK
Fetch refresh token for registry 'myregistry.azurecr.io' : OK
Fetch access token for registry 'myregistry.azurecr.io' : OK
```

## Check if registry is configured with quarantine

Once you enable a container registry to be quarantined, every image you publish to this repository will be quarantined. Any attempts to access or pull quarantined images will fail with an error. For more information, See [pull the quarantine image](https://github.com/Azure/acr/tree/main/docs/preview/quarantine#pull-the-quarantined-image).