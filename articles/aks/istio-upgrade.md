---
layout: Conceptual
title: Upgrade Istio-based service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-upgrade
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
description: Upgrade Istio-based service mesh add-on for Azure Kubernetes Service
ms.topic: how-to
ms.date: 2023-05-04T00:00:00.0000000Z
ms.author: shasb
author: shashankbarsin
ms.custom: devx-track-azurecli
locale: en-us
document_id: de10a7f3-ed62-42dd-176a-970a314560b0
document_version_independent_id: 25896a52-9a55-3167-3347-797f47d8332b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-upgrade.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/istio-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: bfa125f1-6181-ecd8-3b6f-d169782e5a8e
---

# Upgrade Istio-based service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

This article addresses upgrade experiences for Istio-based service mesh add-on for Azure Kubernetes Service (AKS).

Announcements about the releases of new minor revisions or patches to the Istio-based service mesh add-on are published in the [AKS release notes](https://github.com/Azure/AKS/releases). To learn more about the release schedule and support for service mesh add-on revisions, read the [support policy](istio-support-policy#versioning-and-support-policy).

Note

The service mesh add-on doesn't support automatic upgrades. On clusters that are auto-upgraded, an out-of-date mesh revision can eventually become incompatible and block the cluster's automatic upgrade. Upgrade the add-on to keep it compatible with the cluster's Kubernetes version.

## Minor revision upgrade

Istio add-on allows upgrading the minor revision using [canary upgrade process](https://istio.io/latest/docs/setup/upgrade/canary/). When an upgrade is initiated, the control plane of the new (canary) revision is deployed alongside the initial (stable) revision's control plane. You can then manually roll over data plane workloads while using monitoring tools to track the health of workloads during this process. If you don't observe any issues with the health of your workloads, you can complete the upgrade so that only the new revision remains on the cluster. Else, you can roll back to the previous revision of Istio.

Available upgrades depend on whether the current Istio revision and AKS cluster version are supported:

- You can upgrade to the **next supported revision (`n+1`)** or skip one and upgrade to **`n+2`**, as long as both are supported and compatible with the cluster version.
- If both your current revision (`n`) and the next revision (`n+1`) are unsupported, you can only upgrade to the **nearest supported revision (`n+2` or higher)**, but not beyond it.
- If the cluster version and Istio revision are both unsupported, the cluster version must be upgraded before an Istio upgrade can be initiated.

Note

Once an AKS version or mesh revision falls outside the support window, upgrading either version becomes error-prone. While such upgrades are **allowed** to recover to a supported version, **the upgrade process and the out-of-support versions themselves are both not supported by Microsoft**. We strongly recommend keeping AKS version and mesh revision up to date to avoid running into unsupported scenarios. Refer to the [Istio add-on support calendar](istio-support-policy#service-mesh-add-on-release-calendar) for estimated release and end-of-life dates and the [upstream Istio release notes](https://istio.io/latest/news/releases/) for the new revision for notable changes.

The following example illustrates how to upgrade from revision `asm-1-23` to `asm-1-24` with all workloads in the `default` namespace. The steps are the same for all minor upgrades and may be used for any number of namespaces.

1. Use the [az aks mesh get-upgrades](/en-us/cli/azure/aks/mesh#az-aks-mesh-get-upgrades) command to check which revisions are available for the cluster as upgrade targets:

    ```azurecli
    az aks mesh get-upgrades --resource-group $RESOURCE_GROUP --name $CLUSTER
    ```

    If you expect to see a newer revision not returned by this command, you may need to upgrade your AKS cluster first so that it's compatible with the newest revision.
2. If you set up [mesh configuration](istio-meshconfig) for the existing mesh revision on your cluster, you need to create a separate ConfigMap corresponding to the new revision in the `aks-istio-system` namespace **before initiating the canary upgrade** in the next step. This configuration is applicable the moment the new revision's control plane is deployed on cluster. More details can be found [here](istio-meshconfig#mesh-configuration-and-upgrades).
3. Initiate a canary upgrade from revision `asm-1-23` to `asm-1-24` using [az aks mesh upgrade start](/en-us/cli/azure/aks/mesh/upgrade#az-aks-mesh-upgrade-start):

    ```azurecli
    az aks mesh upgrade start --resource-group $RESOURCE_GROUP --name $CLUSTER --revision asm-1-24
    ```

    A canary upgrade means the 1.24 control plane is deployed alongside the 1.23 control plane. They continue to coexist until you either complete or roll back the upgrade.

    While a canary upgrade is in progress, the higher revision is considered the *default revision* used for validation of Istio resources.
4. Optionally, revision tags may be used to roll over the data plane to the new revision without needing to manually relabel each namespace. Manually relabeling namespaces when moving them to a new revision can be tedious and error-prone. [Revision tags](https://istio.io/latest/docs/setup/upgrade/canary/#stable-revision-labels) solve this problem by serving as stable identifiers that point to revisions.

    Rather than relabeling each namespace, a cluster operator can change the tag to point to a new revision. All namespaces labeled with that tag are updated at the same time. However, you still need to restart the workloads to make sure the correct version of `istio-proxy` sidecars are injected.

    To use revision tags during an upgrade:

    1. [Install istioctl CLI](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/)
    2. Create a revision tag for the initial revision. In this example, we name it `prod-stable`:

        ```bash
        istioctl tag set prod-stable --revision asm-1-23 --istioNamespace aks-istio-system
        ```
    3. Create a revision tag for the revision installed during the upgrade. In this example, we name it `prod-canary`:

        ```bash
        istioctl tag set prod-canary --revision asm-1-24 --istioNamespace aks-istio-system
        ```
    4. Label application namespaces to map to revision tags:

        ```bash
        # label default namespace to map to asm-1-23
        kubectl label ns default istio.io/rev=prod-stable --overwrite
        ```

        You may also label namespaces with `istio.io/rev=prod-canary` for the newer revision. However, the workloads in those namespaces aren't updated to a new sidecar until they're restarted.

        If a new application is created in a namespace after it is labeled, a sidecar will be injected corresponding to the revision tag on that namespace.
5. Verify control plane pods corresponding to both `asm-1-23` and `asm-1-24` exist:

    1. Verify `istiod` pods:

        ```bash
        kubectl get pods -n aks-istio-system
        ```

        Example output:

        ```
        NAME                                        READY   STATUS    RESTARTS   AGE
        istiod-asm-1-23-55fccf84c8-dbzlt            1/1     Running   0          58m
        istiod-asm-1-23-55fccf84c8-fg8zh            1/1     Running   0          58m
        istiod-asm-1-24-f85f46bf5-7rwg4             1/1     Running   0          51m
        istiod-asm-1-24-f85f46bf5-8p9qx             1/1     Running   0          51m
        ```
    2. If ingress is enabled, verify ingress pods:

        ```bash
        kubectl get pods -n aks-istio-ingress
        ```

        Example output:

        ```
        NAME                                                          READY   STATUS    RESTARTS   AGE
        aks-istio-ingressgateway-external-asm-1-23-58f889f99d-qkvq2   1/1     Running   0          59m
        aks-istio-ingressgateway-external-asm-1-23-58f889f99d-vhtd5   1/1     Running   0          58m
        aks-istio-ingressgateway-external-asm-1-24-7466f77bb9-ft9c8   1/1     Running   0          51m
        aks-istio-ingressgateway-external-asm-1-24-7466f77bb9-wcb6s   1/1     Running   0          51m
        aks-istio-ingressgateway-internal-asm-1-23-579c5d8d4b-4cc2l   1/1     Running   0          58m
        aks-istio-ingressgateway-internal-asm-1-23-579c5d8d4b-jjc7m   1/1     Running   0          59m
        aks-istio-ingressgateway-internal-asm-1-24-757d9b5545-g89s4   1/1     Running   0          51m
        aks-istio-ingressgateway-internal-asm-1-24-757d9b5545-krq9w   1/1     Running   0          51m
        ```

        Observe that ingress gateway pods of both revisions are deployed side-by-side. However, the service and its IP remain immutable.
6. Relabel the namespace so that any new pods are mapped to the Istio sidecar associated with the new revision and its control plane:

    1. If using revision tags, overwrite the `prod-stable` tag itself to change its mapping:

        ```bash
        istioctl tag set prod-stable --revision asm-1-24 --istioNamespace aks-istio-system --overwrite
        ```

        Verify the tag-to-revision mappings:

        ```bash
        istioctl tag list
        ```

        Both tags should point to the newly installed revision:

        ```
        TAG           REVISION   NAMESPACES
        prod-canary   asm-1-24   default
        prod-stable   asm-1-24   ...
        ```

        In this case, you don't need to relabel each namespace individually.
    2. If not using revision tags, data plane namespaces must be relabeled to point to the new revision:

        ```bash
        kubectl label namespace default istio.io/rev=asm-1-24 --overwrite
        ```

    Relabeling doesn't affect your workloads until they're restarted.
7. Individually roll over each of your application workloads by restarting them. For example:

    ```bash
    kubectl rollout restart deployment <deployment name> -n <deployment namespace>
    ```
8. Check your monitoring tools and dashboards to determine whether your workloads are all running in a healthy state after the restart. Based on the outcome, you have two options:

    1. **Complete the canary upgrade**: If you're satisfied that the workloads are all running in a healthy state as expected, you can complete the canary upgrade. Completion of the upgrade removes the previous revision's control plane and leaves behind the new revision's control plane on the cluster. Run the following command to complete the canary upgrade:

        ```azurecli
        az aks mesh upgrade complete --resource-group $RESOURCE_GROUP --name $CLUSTER
        ```
    2. **Rollback the canary upgrade**: In case you observe any issues with the health of your workloads, you can roll back to the previous revision of Istio:

    - Relabel the namespace to the previous revision: If using revision tags:

        ```bash
        istioctl tag set prod-stable --revision asm-1-23 --istioNamespace aks-istio-system --overwrite
        ```

        Or, if not using revision tags:

        ```bash
        kubectl label namespace default istio.io/rev=asm-1-23 --overwrite
        ```
    - Roll back the workloads to use the sidecar corresponding to the previous Istio revision by restarting these workloads again:

        ```bash
        kubectl rollout restart deployment <deployment name> -n <deployment namespace>
        ```
    - Roll back the control plane to the previous revision:

        ```azurecli
        az aks mesh upgrade rollback --resource-group $RESOURCE_GROUP --name $CLUSTER
        ```

    The `prod-canary` revision tag can be removed:

    ```bash
    istioctl tag remove prod-canary --istioNamespace aks-istio-system
    ```
9. If [mesh configuration](istio-meshconfig) was previously set up for the revisions, you can now delete the ConfigMap for the revision that was removed from the cluster during complete/rollback.

### Minor revision upgrades with ingress and egress gateways

If you're currently using [Istio ingress gateways](istio-deploy-ingress) or [egress gateways](istio-deploy-egress) and are performing a minor revision upgrade, keep in mind that Istio ingress and egress gateway pods / deployments are deployed per-revision, but the service is shared across both revisions.

We provide a single `LoadBalancer` service across all ingress gateway pods over multiple revisions, so the external/internal IP address of the ingress gateways remains unchanged throughout the course of an upgrade. Thus, during the canary upgrade, when two revisions exist simultaneously on the cluster, the ingress gateway pods of both revisions serve incoming traffic.

Likewise, during a canary upgrade, all pods for an egress gateway across both revisions will be served by a single `ClusterIP` service.

### Minor revision upgrades with horizontal pod autoscaling customizations

If you have customized [horizontal pod autoscaling (HPA) settings for Istiod or the ingress gateways](istio-scale#horizontal-pod-autoscaling-hpa-customization), note the following behavior for how HPA settings are applied across both revisions to maintain consistency during a canary upgrade:

- If you update the HPA spec before initiating an upgrade, the settings from the existing (stable) revision will be applied to the HPAs of the canary revision when the new control plane is installed.
- If you update the HPA spec while a canary upgrade is in progress, the HPA spec of the stable revision will take precedence and be applied to the HPA of the canary revision.
    - If you update the HPA of the stable revision during an upgrade, the HPA spec of the canary revision will be updated to reflect the new settings applied to the stable revision.
    - If you update the HPA of the canary revision during an upgrade, the HPA spec of the canary revision will be reverted to the HPA spec of the stable revision.

## Patch version upgrade

- Istio add-on patch version availability information is published in [AKS release notes](https://github.com/Azure/AKS/releases).
- Patches are rolled out automatically for istiod and ingress pods as part of these AKS releases, which respect the `default`[planned maintenance window](planned-maintenance) set up for the cluster.
- User needs to initiate patches to Istio proxy in their workloads by restarting the pods for reinjection:
    - Check the version of the Istio proxy intended for new or restarted pods. This version is the same as the version of the istiod and Istio ingress pods after they were patched:

        ```bash
        kubectl get cm -n aks-istio-system -o yaml | grep "mcr.microsoft.com\/oss\/istio\/proxyv2"
        ```

        Example output:

        ```bash
        "image": "mcr.microsoft.com/oss/istio/proxyv2:1.23.0-distroless",
        "image": "mcr.microsoft.com/oss/istio/proxyv2:1.23.0-distroless"
        ```
    - Check the Istio proxy image version for all pods in a namespace:

        ```bash
        kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |\
        sort |\
        grep "mcr.microsoft.com\/oss\/istio\/proxyv2"
        ```

        Example output:

        ```bash
        productpage-v1-979d4d9fc-p4764:	docker.io/istio/examples-bookinfo-productpage-v1:1.23.0, mcr.microsoft.com/oss/istio/proxyv2:1.23.0-distroless
        ```
    - To trigger reinjection, restart the workloads. For example:

        ```bash
        kubectl rollout restart deployments/productpage-v1 -n default
        ```
    - To verify that they're now on the newer versions, check the Istio proxy image version again for all pods in the namespace:

        ```bash
        kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |\
        sort |\
        grep "mcr.microsoft.com\/oss\/istio\/proxyv2"
        ```

        Example output:

        ```bash
        productpage-v1-979d4d9fc-p4764:	docker.io/istio/examples-bookinfo-productpage-v1:1.2.0, mcr.microsoft.com/oss/istio/proxyv2:1.24.0-distroless
        ```

Note

In case of any issues encountered during upgrades, refer to [article on troubleshooting mesh revision upgrades](/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-minor-revision-upgrade)