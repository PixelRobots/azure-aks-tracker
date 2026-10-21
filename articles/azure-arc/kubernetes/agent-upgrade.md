---
layout: Conceptual
title: Upgrade Azure Arc-enabled Kubernetes agents - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/agent-upgrade
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
ms.date: 2025-01-07T00:00:00.0000000Z
ms.topic: how-to
ms.custom: devx-track-azurecli
description: Control agent upgrades for Azure Arc-enabled Kubernetes
locale: en-us
document_id: 9b49520e-430a-723e-c284-4cb6b38ca418
document_version_independent_id: 1b8ea006-328b-b22d-b0f5-57f5455f68d8
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/agent-upgrade.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/agent-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/agent-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 036295f4-e399-101e-5402-9e2380baefd5
---

# Upgrade Azure Arc-enabled Kubernetes agents - Azure Arc | Microsoft Learn

Azure Arc-enabled Kubernetes provides both automatic and manual upgrade capabilities for its [agents](conceptual-agent-overview) so that agents are upgraded to the [latest version](release-notes). If you disable automatic upgrade and instead rely on manual upgrade, a version support policy applies for Arc agents and the underlying Kubernetes clusters.

## Toggle automatic upgrade on or off when connecting a cluster to Azure Arc

Azure Arc-enabled Kubernetes provides its agents with out-of-the-box automatic upgrade capabilities. When automatic upgrade is enabled, the agent polls Azure hourly to check for a newer version. When a newer version becomes available, it triggers a Helm chart upgrade for the Azure Arc agents.

When you [connect a cluster to Azure Arc](quickstart-connect-cluster), the default setting is to enable automatic upgrade.

The following command connects a cluster to Azure Arc with automatic upgrade enabled:

```azurecli
az connectedk8s connect --name AzureArcTest1 --resource-group AzureArcTest
```

Important

Be sure you allow [connectivity to all required endpoints](network-requirements). In particular, connectivity to `dl.k8s.io` is required for automatic upgrades.

To opt out of automatic upgrade, specify the `--disable-auto-upgrade` parameter while connecting the cluster to Azure Arc.

The following command connects a cluster to Azure Arc with auto-upgrade disabled:

```azurecli
az connectedk8s connect --name AzureArcTest1 --resource-group AzureArcTest --disable-auto-upgrade
```

Tip

If you plan to disable automatic upgrade, be aware of the version support policy for Azure Arc-enabled Kubernetes.

## Toggle automatic upgrade on or off after connecting a cluster to Azure Arc

After you connect a cluster to Azure Arc, you can change the automatic upgrade selection by using the `az connectedk8s update` command and setting `--auto-upgrade` to either true or false.

The following command turns automatic upgrade off for a connected cluster:

```azurecli
az connectedk8s update --name AzureArcTest1 --resource-group AzureArcTest --auto-upgrade false
```

## Manually upgrade agents

If you've disabled automatic upgrade, you can manually initiate upgrades for the agents by using the `az connectedk8s upgrade` command. When doing so, you must specify the version to which you want to upgrade.

Azure Arc-enabled Kubernetes follows the standard [semantic versioning scheme](https://semver.org/) of `MAJOR.MINOR.PATCH` for versioning its agents. Each number in the version indicates general compatibility with the previous version:

- **Major versions** change when there are incompatible API updates or backwards-compatibility may be broken.
- **Minor versions** change when functionality changes are backwards-compatible to other minor releases.
- **Patch versions** change when backwards-compatible bug fixes are made.

While the schedule may vary, a new minor version of Azure Arc-enabled Kubernetes agents is [released approximately once per month](release-notes).

The following command manually upgrades the agents to version 1.8.14:

```azurecli
az connectedk8s upgrade -g AzureArcTest1 -n AzureArcTest --agent-version 1.8.14
```

## Check agent version

To list connected clusters and reported agent version, use the following command:

```azurecli
az connectedk8s list --query '[].{name:name,rg:resourceGroup,id:id,version:agentVersion}'
```

## Check if automatic upgrade is enabled on a cluster

To check whether a cluster is enabled for automatic upgrade, run the following kubectl command. Note that the automatic upgrade configuration is not available in the public API for Azure Arc-enabled Kubernetes.

```console
kubectl -n azure-arc get cm azure-clusterconfig -o jsonpath="{.data['AZURE_ARC_AUTOUPDATE']}"
```

## Version support policy

When you [create support requests](../../azure-portal/supportability/how-to-create-azure-support-request) for Azure Arc-enabled Kubernetes, the following version support policy applies:

- Azure Arc-enabled Kubernetes agents have a support window of "N-2", where 'N' is the latest minor release of agents.

    - For example, if Azure Arc-enabled Kubernetes introduces 0.28.a today, versions 0.28.a, 0.28.b, 0.27.c, 0.27.d, 0.26.e, and 0.26.f are supported.
- Kubernetes clusters connecting to Azure Arc have a support window of "N-2", where 'N' is the latest stable minor release of [upstream Kubernetes](https://github.com/kubernetes/kubernetes/releases).

    - For example, if Kubernetes introduces 1.20.a today, versions 1.20.a, 1.20.b, 1.19.c, 1.19.d, 1.18.e, and 1.18.f are supported.

If you create a support request and are using a version that is outside of the support policy (older than the "N-2" supported versions of agents and upstream Kubernetes clusters), you'll be asked to upgrade the clusters and agents to a supported version.