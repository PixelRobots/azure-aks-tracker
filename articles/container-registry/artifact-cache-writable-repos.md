---
layout: Conceptual
title: Enable writable repositories for artifact cache in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/artifact-cache-writable-repos
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
description: Enable writable artifact cache repositories to push or import images and OCI artifacts alongside cached upstream content in Azure Container Registry.
ms.topic: how-to
ms.date: 2026-11-23T00:00:00.0000000Z
ai-usage: ai-generated
locale: en-us
document_id: 08d7218f-c306-7720-7c44-acc7b43dfbb9
document_version_independent_id: 14732a1d-ba4d-7a39-f9ce-8eeadf70f57d
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/artifact-cache-writable-repos.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/artifact-cache-writable-repos
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/artifact-cache-writable-repos.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: cb4b46d3-f3b1-7875-a6d6-6d2fed7dce36
---

# Enable writable repositories for artifact cache in Azure Container Registry - Azure Container Registry | Microsoft Learn

[Artifact cache](artifact-cache-overview) provides pull-through caching (PTC) for images from upstream registries. By default, you can't push artifacts directly to repositories targeted by cache rules.

Enable writable cache repositories to push your own images and OCI artifacts to these repositories. For example, you can publish a patched image under a new tag or attach supply chain artifacts, such as signatures and lifecycle metadata, to an image in a cache-backed repository.

You can also prehydrate the cache by pushing or [importing images](container-registry-import-images) into a cache-backed repository before workloads request them. Prehydrating makes those images available locally for subsequent pulls, avoiding the initial upstream fetch on the workload's first pull.

The setting applies to the registry, not to an individual cache rule. You don't need to recreate existing cache rules.

Important

Writable cache repositories are in preview. Enabling this setting permits authorized clients to write to repositories targeted by cache rules throughout the registry. Review repository permissions before enabling it.

## Prerequisites

- An Azure container registry with an [artifact cache rule](artifact-cache-cli). Artifact cache is available in the Basic, Standard, and Premium service tiers.
- Azure CLI version **2.89.0 or later**. Run `az version` to check your version. See [Install Azure CLI](/en-us/cli/azure/install-azure-cli) if you need to install or update it.
- Permission to update the registry configuration, such as the **Container Registry Contributor and Data Access Configuration Administrator** role.
- Permission to push and pull artifacts in the target repository. For registries using **RBAC Registry + ABAC Repository Permissions**, use **Container Registry Repository Writer**, with repository conditions where appropriate. For registries using **RBAC Registry Permissions**, use **AcrPush**. See [Azure Container Registry roles and permissions](container-registry-rbac-built-in-roles-overview).
- Docker installed and running if you follow the push example.

Enabling writable repositories doesn't grant data-plane permissions or change the credentials used to access the upstream registry.

The following examples use Bash, which is available in [Azure Cloud Shell](https://shell.azure.com). Run the Docker commands in an environment with a running Docker daemon.

## Enable writable cache repositories

Sign in and select the subscription containing your registry:

```azurecli
az login
az account set --subscription "<subscription-id>"
```

Set the registry name and resource group:

```bash
registryName="<registry-name>"
resourceGroup="<resource-group-name>"
```

Enable writes to cache-backed repositories:

```azurecli
az acr update --name "$registryName" --resource-group "$resourceGroup" --writable-cache-repos Enabled
```

Verify the setting:

```azurecli
az acr show --name "$registryName" --resource-group "$resourceGroup" --query writableCacheRepos --output tsv
```

The expected output is:

```output
Enabled
```

To enable the setting when creating a registry, include the same parameter in `az acr create`. The resource group must already exist, and the registry name must be globally unique:

```azurecli
az acr create --name "$registryName" --resource-group "$resourceGroup" --sku Standard --writable-cache-repos Enabled
```

Creating a registry with this setting doesn't create cache rules. Configure a rule before using pull-through caching.

## Push an image to a cache-backed repository

This example uses an existing cache rule that maps `mcr.microsoft.com/hello-world` to the target repository `cache/hello-world`. If you don't have this rule, create it by using an unused target repository path. Creating a rule also requires cache-rule management permissions, such as the **Container Registry Cache Rule Administrator** role:

```azurecli
az acr cache create --registry "$registryName" --resource-group "$resourceGroup" --name hello-world-cache --source-repo mcr.microsoft.com/hello-world --target-repo cache/hello-world
```

If you're using a different existing rule, substitute its target repository and an available upstream tag in the following commands.

Get the registry's login server and authenticate Docker:

```bash
loginServer=$(az acr show --name "$registryName" --resource-group "$resourceGroup" --query loginServer --output tsv)
az acr login --name "$registryName"
```

Pull an upstream image through the cache rule:

```bash
docker pull "$loginServer/cache/hello-world:latest"
```

Push the image back to the same repository under a distinct tag:

```bash
docker tag "$loginServer/cache/hello-world:latest" "$loginServer/cache/hello-world:local-demo-v1"
docker push "$loginServer/cache/hello-world:local-demo-v1"
```

This example retags the image to demonstrate a write operation; it doesn't modify or patch the image. In a patching workflow, build and test your modified image, then push it under a distinct tag.

Verify that you can pull the new tag:

```bash
docker image rm "$loginServer/cache/hello-world:local-demo-v1"
docker pull "$loginServer/cache/hello-world:local-demo-v1"
```

The new tag is stored in your ACR repository. It isn't pushed to the upstream registry.

## Attach lifecycle metadata to a cached image

Writable cache repositories also let you attach OCI artifacts to a cached image without write access to the upstream registry. For example, you can attach end-of-life (EOL) metadata to the image cached from Microsoft Artifact Registry in the preceding example.

Install the [ORAS CLI](https://oras.land/docs/installation), and then authenticate it with your Azure CLI identity:

```bash
az acr login --name "$registryName" --expose-token --query accessToken --output tsv | oras login "$loginServer" --username 00000000-0000-0000-0000-000000000000 --password-stdin
```

Attach an OCI artifact containing an example EOL date:

```bash
oras attach --artifact-type application/vnd.microsoft.artifact.lifecycle --annotation "vnd.microsoft.artifact.lifecycle.end-of-life.date=2027-12-31" "$loginServer/cache/hello-world:latest"
```

Discover the artifacts attached to the image:

```bash
oras discover "$loginServer/cache/hello-world:latest"
```

The lifecycle artifact is stored in your downstream ACR repository and refers to the image digest resolved from the tag. It doesn't modify the upstream image or publish metadata to Microsoft Artifact Registry. If the tag later resolves to a different image digest, the lifecycle artifact still refers to the original digest.

The EOL annotation is metadata; it doesn't automatically expire the image or prevent pulls. To enforce a lifecycle policy, use tooling that reads and acts on the metadata.

## Behavior and considerations

- **Registry-wide setting:** Writable cache repositories are disabled by default. When you enable the setting, it applies to repositories targeted by existing and future cache rules in the registry.
- **Authorization still applies:** Clients need the usual permissions to push images or OCI artifacts. Repository locks and other write restrictions aren't bypassed.
- **Use distinct tags:** Use a separate naming convention for locally published images, such as `local-demo-v1` or a build-specific patched tag. Avoid reusing tags supplied by the upstream repository.
- **No upstream write-back:** Local pushes don't modify the upstream registry. Upstream authentication requirements remain unchanged.
- **Pull-through caching continues:** Enabling writes doesn't proactively download every upstream image or introduce automatic synchronization of new tags.
- **Local-only content needs its own recovery strategy:** Content that exists only in your registry can't be recovered from the upstream registry if you delete it.
- **Discovery is separate:** Enabling writes doesn't by itself provide a merged inventory of upstream and locally stored repositories or tags.

### Tag resolution and upstream refresh

A locally pushed or imported tag isn't a permanent override of an upstream tag. When PTC rechecks upstream, it compares the current upstream digest with the last upstream digest it synchronized.

Suppose the downstream tag `app:v1` points to digest **A**, while upstream points to **B**:

| Sync history | Result when PTC rechecks upstream |
| --- | --- |
| The tag has never been synchronized from upstream. | PTC returns **B** and queues an import that can overwrite the downstream tag with **B**. |
| PTC previously synchronized **B**, then you replaced the downstream tag with **A**. Upstream still contains **B**. | PTC preserves **A**, provided the recorded last-synchronized digest is **B**. |
| Same history, but upstream changes from **B** to **C**. | PTC returns **C** and queues a refresh that can replace the local override with **C**. |

Between upstream rechecks, pulls can use the current downstream tag. Resolution isn't determined simply by which registry received the latest push.

Important

Use distinct tags for locally published images to avoid collisions with upstream tags. Pull by digest when you require a specific image version.

## Disable writable cache repositories

To stop allowing direct writes to cache-backed repositories, disable the setting:

```azurecli
az acr update --name "$registryName" --resource-group "$resourceGroup" --writable-cache-repos Disabled
```

Verify the setting:

```azurecli
az acr show --name "$registryName" --resource-group "$resourceGroup" --query writableCacheRepos --output tsv
```

The expected output is `Disabled`. This operation changes the write setting; it isn't a content cleanup operation.

## Troubleshoot

| Symptom | Action |
| --- | --- |
| Azure CLI doesn't recognize `--writable-cache-repos`. | Check `az version` and update to Azure CLI 2.89.0 or later. The parameter name ends in `repos`, not `repo`. |
| A push reports that pushes to a repository matching a cache rule aren't supported. | Verify that `az acr show --query writableCacheRepos` returns `Enabled` for the destination registry. |
| A push returns an authorization error. | Check the client's repository write permissions and the registry's role assignment permissions mode. Enabling this setting doesn't assign roles. |
| A cache-rule creation attempt fails because the target already exists or overlaps another rule. | Use an unused, nonoverlapping target path, or use the existing rule. You don't need a new rule to enable writes. |
| Pulling an upstream image fails after writes are enabled. | Check upstream credentials, source availability, network access, and the cache-rule configuration. Writable repositories don't change these requirements. |