---
layout: Conceptual
title: Long-Term Support for Azure Kubernetes Service (AKS) Versions - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/long-term-support
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn about Azure Kubernetes Service (AKS) long-term support for Kubernetes
author: schaffererin
ms.author: schaffererin
ms.date: 2026-08-05T00:00:00.0000000Z
ms.topic: how-to
ms.custom:
- devx-track-azurecli
- build-2025
ai-usage: ai-assisted
locale: en-us
document_id: 97377a85-3ab2-e897-aced-07545bae5191
document_version_independent_id: 7fb52f89-abcf-49fe-d354-25dfb314e3cc
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/long-term-support.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/long-term-support
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/long-term-support.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a69d6c45-0a88-dbdc-103a-fe643d373841
---

# Long-Term Support for Azure Kubernetes Service (AKS) Versions - Azure Kubernetes Service | Microsoft Learn

Important

**AKS platform-initiated upgrades.** Starting on **June 1, 2027**, AKS automatically upgrades any cluster that stays on an unsupported Kubernetes version after its 60-day [platform support grace period](platform-initiated-upgrades#platform-support-grace-period) ends. A platform-initiated upgrade **doesn't follow your maintenance window**, **doesn't stop for deprecated API usage**, and **can override a Pod Disruption Budget** that blocks a node drain, so workloads might be disrupted. Before the upgrade month, replace APIs removed from the target Kubernetes version and update incompatible self-managed add-ons. Keep your clusters on a supported Kubernetes version to avoid a platform-initiated upgrade. For more information, see [Prepare for platform-initiated upgrades in AKS](platform-initiated-upgrades#prepare-before-aks-starts-the-upgrade).

The Kubernetes community releases a new minor version approximately every four months, and each version has a support window of one year. In Azure Kubernetes Service (AKS), this support window is called *community support*.

For Kubernetes versions in *community support*, AKS provides bug fixes and security updates from community releases. It can be difficult to stay current with the Kubernetes release cadence when your applications have complex dependencies.

Long-term support (LTS) extends the support window so you have more time to plan and test upgrades to newer Kubernetes versions.

## AKS support types

After approximately one year, a given Kubernetes minor version exits *community support*, and bug fixes and security updates aren't available for your AKS clusters.

AKS provides one year of *community support*, followed by one additional year of *long-term support*. Together, the community support and LTS periods provide approximately 24 months of total support from the Kubernetes version's general availability (GA). During the LTS year, AKS backports security fixes from the upstream community. The upstream LTS working group contributes to the community, extending the support window.

| - | Community support | Long-term support |
| --- | --- | --- |
| **When to use** | When you can keep up with upstream Kubernetes releases | When you need control over when to migrate from one version to another |
| **Supported versions** | Three most recent GA minor versions | All supported Kubernetes versions are eligible for LTS. See the [AKS LTS release calendar](supported-kubernetes-versions#lts-versions). |

## Long-term support patch process

LTS supports only the two most recent patch versions. Community support can include any number of currently offered patches. However, AKS reserves the right to deprecate any patch version in response to critical security vulnerabilities (CVEs). For more information about community support policy, see [Kubernetes version support policy](supported-kubernetes-versions#kubernetes-version-support-policy).

To identify the latest supported patch versions, see the [AKS release tracker](https://releases.aks.azure.com/webpage/index.html).

## Enable long-term support

**Enabling LTS requires moving your cluster to the Premium tier and explicitly selecting the LTS support plan**. You can opt in at any time, including while your cluster is still in *community support*.

LTS is available on the Premium tier. For current rates, see [AKS pricing](https://azure.microsoft.com/pricing/details/kubernetes-service/).

Note

Enable the [patch auto-upgrade channel](auto-upgrade-cluster) to keep your cluster on the latest supported patches. LTS supports only the two most recent patch versions for each minor version. Clusters that don't run one of those patch versions might lose support.

## Enable LTS on a new cluster

Create a new cluster with LTS enabled using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. AKS uses the default supported Kubernetes version and latest patch available in the region.

```azurecli
az aks create \
    --resource-group <resource-group-name> \
    --name <cluster-name> \
    --tier premium \
    --k8s-support-plan AKSLongTermSupport \
    --auto-upgrade-channel patch \
    --generate-ssh-keys
```

The command uses the following LTS-specific parameter values:

- `--tier premium` sets the cluster management tier to Premium, which is required for LTS.
- `--k8s-support-plan AKSLongTermSupport` enrolls the cluster in LTS and provides one additional year of security fixes.
- `--auto-upgrade-channel patch` automatically upgrades the cluster to supported patch versions while keeping the same minor version.

## Enable LTS on an existing cluster

Enable LTS on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

```azurecli
az aks update --resource-group <resource-group-name> --name <cluster-name> --tier premium --k8s-support-plan AKSLongTermSupport --auto-upgrade-channel patch
```

The command uses the following LTS-specific parameter values:

- `--tier premium` moves the cluster to the Premium cluster management tier, which is required for LTS.
- `--k8s-support-plan AKSLongTermSupport` enrolls the cluster in LTS and provides one additional year of security fixes.
- `--auto-upgrade-channel patch` automatically upgrades the cluster to supported patch versions while keeping the same minor version.

Tip

To see which Kubernetes versions you can upgrade to, use the [AKS release tracker](https://releases.aks.azure.com/webpage/index.html) or run `az aks get-upgrades --resource-group <resource-group-name> --name <cluster-name>`.

## Migrate to the latest LTS version

To perform an in-place upgrade to the latest LTS version, specify a higher LTS version offered by AKS as the upgrade target. An LTS cluster can skip minor versions when the upgrade satisfies version-skew requirements and validation checks. For more information, see [Kubernetes version upgrade rules](upgrade-aks-control-plane#kubernetes-version-upgrade-rules).

During a full in-place upgrade, AKS upgrades the control plane first and then upgrades each node pool sequentially. Test your workloads against deprecated APIs and other breaking changes between the current and target versions before upgrading.

1. List the versions that AKS offers as upgrade targets for your cluster using the `az aks get-upgrades` command.

    ```azurecli
    az aks get-upgrades --resource-group <resource-group-name> --name <cluster-name> --output table
    ```
2. Upgrade to an offered LTS version using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command.

    ```azurecli
    az aks upgrade --resource-group <resource-group-name> --name <cluster-name> --kubernetes-version <lts-kubernetes-version>
    ```

    Note

    All supported AKS Kubernetes versions are LTS-compatible. For the latest LTS calendar, see the [AKS Kubernetes release calendar](supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions). To view available LTS releases and their patches by region, see the [AKS release tracker](release-tracker).

## Disable long-term support on an existing cluster

**To disable LTS on an existing cluster, move your cluster to the Free or Standard tier and explicitly select the `KubernetesOfficial` support plan**.

You can disable LTS while the cluster's Kubernetes version is still in community support. After that version exits community support, upgrade the cluster to a community-supported version before you disable LTS. Check the [AKS Kubernetes release calendar](supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions) to determine the support status of your version.

1. If your current version is outside community support, list the available upgrade targets using the `az aks get-upgrades` command.

    ```azurecli
    az aks get-upgrades --resource-group <resource-group-name> --name <cluster-name> --output table
    ```
2. If necessary, upgrade the cluster to an offered version that is in community support using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command.

    ```azurecli
    az aks upgrade --resource-group <resource-group-name> --name <cluster-name> --kubernetes-version <community-supported-kubernetes-version>
    ```
3. Disable LTS using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command. The following example moves the cluster to the Free tier and selects the `KubernetesOfficial` support plan.

    ```azurecli
    az aks update --resource-group <resource-group-name> --name <cluster-name> --tier free --k8s-support-plan KubernetesOfficial
    ```

    The `--tier free` value moves the cluster to the Free cluster management tier, and `--k8s-support-plan KubernetesOfficial` switches the cluster from LTS to the standard AKS Kubernetes support plan.

## Add-on and feature lifecycle considerations

LTS extends support for the Kubernetes version, but add-ons and features can have separate support lifecycles. Before moving a cluster to LTS, review the lifecycle and Kubernetes-version compatibility of each add-on and feature that the cluster uses.

The following table summarizes current lifecycle considerations:

| Add-on or feature | Lifecycle consideration |
| --- | --- |
| Calico | Confirm that your Calico version supports the target Kubernetes version and review Tigera support terms for use beyond Kubernetes community support. |
| Key Management Service (KMS) | The existing KMS experience is now designated as legacy. For Kubernetes 1.33 and later, review the new [KMS data encryption](kms-data-encryption) experience and the applicable [migration guidance](migrate-key-management-service-platform-managed-key-customer-managed-key). Both the new experience and its migration workflow are in preview. |
| Dapr | The managed [Dapr extension](dapr-overview) uses a rolling support window that includes the current and previous Dapr versions. Keep the extension within its supported version window. |
| Application Gateway Ingress Controller (AGIC) | AGIC remains available. Begin [transitioning to Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/migrate-from-agic-to-agc). |
| Open Service Mesh (OSM) | AKS support for the managed OSM add-on ends on September 30, 2027. Migrate to the [Istio add-on](open-service-mesh-istio-migration-guidance) before that date. |
| Microsoft Entra pod-managed identity | Support for the managed add-on ended in September 2025. Migrate to [Microsoft Entra Workload ID](workload-identity-overview). |
| Azure Confidential Compute SGX (ACC SGX) | Confirm that ACC SGX supports the target Kubernetes version before moving the cluster beyond community support. |

## Plan the next LTS upgrade

AKS makes consecutive Kubernetes versions eligible for LTS and publishes a separate LTS end-of-life date for each version. Use the [AKS LTS release calendar](supported-kubernetes-versions#lts-versions) and [AKS release tracker](release-tracker) to choose an offered target version and plan your migration before the current version reaches its LTS end-of-life date.

If you don't upgrade, AKS upgrades the cluster for you after the 60-day grace period that follows the LTS end-of-life date, through a [platform-initiated upgrade](platform-initiated-upgrades). The cluster stays on the LTS track and moves to the next supported LTS version. Platform-initiated upgrades don't follow your maintenance window, so upgrading on your own schedule is the only way to keep control of the timing.

## Frequently asked questions

### Can I create a new AKS cluster with an LTS version after community support ends?

Yes, you can create a new AKS cluster using an LTS version after its community support period ends if you enable LTS. LTS support continues only until the end of that version's lifecycle. You must then upgrade to the next supported LTS version. For more information, see the [AKS Kubernetes release calendar](supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions).

### Can I enable and disable LTS on an AKS-supported version after community support ends?

Yes, you can enable the LTS support plan on any AKS-supported version even after its community support period has ended. However, once the community support period has ended, you can't disable LTS for that version.

### Does a community-supported AKS cluster automatically become eligible for LTS after end of life?

No. You must explicitly enable LTS and move the cluster to the Premium tier.

### Does a platform-initiated upgrade enroll my cluster in LTS?

No. AKS never enrolls a cluster in LTS on your behalf and never changes your billing tier. A [platform-initiated upgrade](platform-initiated-upgrades) keeps the cluster in its current support tier: a community-support cluster moves to the lowest supported community minor version, and an LTS cluster moves to the applicable LTS version.

### What happens if my cluster's LTS version reaches end of life and I don't upgrade?

AKS upgrades the cluster to the next supported LTS version after the 60-day grace period that follows the LTS end-of-life date. The cluster isn't dropped to a community-supported version. To find the month for your version, see the [AKS LTS release calendar](supported-kubernetes-versions#lts-versions). For more information, see [Platform-initiated upgrades](platform-initiated-upgrades).

### Is every AKS version eligible for long-term support?

Yes. All supported Kubernetes versions are eligible for LTS.

### What is the pricing model for LTS?

LTS is offered on the Premium tier. For current rates, see [Premium tier pricing](https://azure.microsoft.com/pricing/details/kubernetes-service/).

### Does enabling LTS disrupt workloads?

No. It's a configuration-only change; it doesn't reimage nodes or disrupt workloads, so no downtime is expected.