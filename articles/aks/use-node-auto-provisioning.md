---
layout: Conceptual
title: Enable or Disable Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-node-auto-provisioning
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to enable or disable node auto-provisioning (NAP) in AKS using the Azure CLI or ARM templates.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2025-09-29T00:00:00.0000000Z
ms.author: wilsondarko
author: wdarko1
zone_pivot_groups: arm-azure-cli
locale: en-us
document_id: 19c07a75-b25f-81a9-17d0-907dcf610b58
document_version_independent_id: 79f29e1f-631d-b042-63b3-5816f9bc90b1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-node-auto-provisioning.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-node-auto-provisioning
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-node-auto-provisioning.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
platformId: 10830042-1676-5682-fe77-76cfcc2076e3
---

# Enable or Disable Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article explains how to enable or disable node auto-provisioning (NAP) in Azure Kubernetes Service (AKS) using the Azure CLI or Azure Resource Manager (ARM) templates.

If you want to create a NAP-enabled AKS cluster with a custom virtual network (VNet) and subnets, see [Create a node auto-provisioning (NAP) cluster in a custom virtual network](node-auto-provisioning-custom-vnet).

## Before you begin

Before you begin, review the [Overview of node auto-provisioning (NAP) in AKS](node-auto-provisioning) article, which details [how NAP works](node-auto-provisioning#how-does-node-auto-provisioning-work), [prerequisites](node-auto-provisioning#prerequisites) and [limitations](node-auto-provisioning#limitations-and-unsupported-features).

## Enable node auto-provisioning (NAP) on an AKS cluster

The following sections explain how to enable NAP on a new or existing AKS cluster:

Note

You can enable [control plane metrics](control-plane-metrics-monitor) to see the logs and operations from [node auto-provisioning](control-plane-metrics-default-list#minimal-ingestion-for-default-off-targets) with the [Azure Monitor managed service for Prometheus add-on](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview).

### Enable NAP on a new cluster

::: zone pivot="azure-cli"

- Enable node auto-provisioning on a new cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--node-provisioning-mode` flag set to `Auto`. The following command also sets the `--network-plugin` to `azure`, `--network-plugin-mode` to `overlay`, and `--network-dataplane` to `cilium`.

    ```azurecli
    az aks create \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --node-provisioning-mode Auto \
        --network-plugin azure \
        --network-plugin-mode overlay \
        --network-dataplane cilium \
        --generate-ssh-keys
    ```

::: zone-end

::: zone pivot="arm"

1. Create a file named `nap.json` and add the following ARM template configuration with the `properties.nodeProvisioningProfile.mode` field set to `Auto`, which enables NAP. (The default setting is `Manual`.)

    ```JSON
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "metadata": {},
      "parameters": {},
      "resources": [
        {
          "type": "Microsoft.ContainerService/managedClusters",
          "apiVersion": "2025-05-01",
          "sku": {
            "name": "Base",
            "tier": "Standard"
          },
          "name": "napcluster",
          "location": "uksouth",
          "identity": {
            "type": "SystemAssigned"
          },
          "properties": {
            "networkProfile": {
                "networkPlugin": "azure",
                "networkPluginMode": "overlay",
                "networkPolicy": "cilium",
                "networkDataplane":"cilium",
                "loadBalancerSku": "Standard"
            },
            "dnsPrefix": "napcluster",
            "agentPoolProfiles": [
              {
                "name": "agentpool",
                "count": 3,
                "vmSize": "standard_d2s_v3",
                "osType": "Linux",
                "mode": "System"
              }
            ],
            "nodeProvisioningProfile": {
              "mode": "Auto"
            }
          }
        }
      ]
    }
    ```
2. Enable node auto-provisioning on a new cluster using the [`az deployment group create`](/en-us/cli/azure/deployment/group#az-deployment-group-create) command with the `--template-file` flag set to the path of the ARM template file.

    ```azurecli
    az deployment group create --resource-group $RESOURCE_GROUP --template-file ./nap.json
    ```

::: zone-end

::: zone pivot="azure-cli"

### Enable NAP on an existing cluster

- Enable node auto-provisioning on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--node-provisioning-mode` flag set to `Auto`.

    ```azurecli
    az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --node-provisioning-mode Auto
    ```

::: zone-end

## Disable node auto-provisioning (NAP) on an AKS cluster

Important

You can only disable NAP on a cluster if the following conditions are met:

- There are no existing NAP nodes. You can use the `kubectl get nodes -l karpenter.sh/nodepool` command to check for existing NAP-managed nodes.
- All existing Karpenter [`NodePools`](node-auto-provisioning-node-pools) have their `spec.limits.cpu` field set to `0`. This action prevents new nodes from being created, but doesn't disrupt currently running nodes.

1. Set the `spec.limits.cpu` field to `0` for every existing Karpenter `NodePool`. For example:

    ```yaml
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: default
    spec:
      limits:
        cpu: 0
    ```

    Important

    If you don't want to ensure that every pod previously running on a NAP node is safely migrated to a non-NAP node before disabling NAP, you can skip steps 2 and 3 and instead use the `kubectl delete node` command for each NAP-managed node. However, **we don't recommend skipping these steps**, as it might leave some pods pending and doesn't honor Pod Disruption Budgets (PDBs).

    When using the `kubectl delete node` command, be careful to only delete NAP-managed nodes. You can identify NAP-managed nodes using the `kubectl get nodes -l karpenter.sh/nodepool` command.
2. Add the `karpenter.azure.com/disable:NoSchedule` taint to every Karpenter `NodePool`. For example:

    ```yaml
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          ...
          taints:
            - key: karpenter.azure.com/disable
              effect: NoSchedule
    ```

    This action starts the process of migrating the workloads on the NAP-managed nodes to non-NAP nodes, honoring PDBs and disruption limits. Pods migrate to non-NAP nodes if they can fit. If there isn't enough fixed-size capacity, some node NAP-managed nodes remain.
3. Scale up existing fixed-size `ManagedCluster``AgentPools` or create new fixed-size `AgentPools` to take the load from the node NAP-managed nodes. As these nodes are added to the cluster, the node NAP-managed nodes are drained, and work is migrated to the fixed-size nodes.
4. Delete all NAP-managed nodes using the `kubectl get nodes -l karpenter.sh/nodepool` command. If NAP-managed nodes still exist, the cluster likely lacks fixed-size capacity. In this case, you should add more nodes so the remaining workloads can be migrated.

::: zone pivot="azure-cli"

1. Update the NAP mode to `Manual` using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) Azure CLI command with the `--node-provisioning-mode` flag set to `Manual`.

    ```azurecli
    az aks update \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --node-provisioning-mode Manual
    ```

::: zone-end

::: zone pivot="arm"

1. Update the `properties.nodeProvisioningProfile.mode` field to `Manual` in your ARM template and redeploy it.

    ```JSON
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "metadata": {},
      "parameters": {},
      "resources": [
        {
          "type": "Microsoft.ContainerService/managedClusters",
          "apiVersion": "2025-05-01",
          "sku": {
            "name": "Base",
            "tier": "Standard"
          },
          "name": "napcluster",
          "location": "uksouth",
          "identity": {
            "type": "SystemAssigned"
          },
          "properties": {
            "networkProfile": {
                "networkPlugin": "azure",
                "networkPluginMode": "overlay",
                "networkPolicy": "cilium",
                "networkDataplane":"cilium",
                "loadBalancerSku": "Standard"
            },
            "dnsPrefix": "napcluster",
            "agentPoolProfiles": [
              {
                "name": "agentpool",
                "count": 3,
                "vmSize": "standard_d2s_v3",
                "osType": "Linux",
                "mode": "System"
              }
            ],
            "nodeProvisioningProfile": {
              "mode": "Manual"
            }
          }
        }
      ]
    }
    ```

::: zone-end

## Migrate from self-hosted open-source Karpenter to managed node auto-provisioning (NAP)

If Karpenter was installed from the [open source Helm chart](https://github.com/Azure/karpenter-provider-azure#installation-self-hosted-karpenter), you can still enable NAP on your cluster. These steps assume that the Karpenter Helm chart is installed.

Important

Ensure you're running the [latest version](https://github.com/Azure/karpenter-provider-azure/releases/latest) of Karpenter before initiating the migration. NAP is always running the latest version.

Important

Be careful not to remove the Karpenter CRDs when performing this migration process. If the CRDs are deleted it deletes the underlying NodeClaims, which could disrupt your workloads.

1. To ensure the Karpenter CRDs are not uninstalled in step 2, remove the `managed-by=Helm` labels and annotations.:

    ```bash
    kubectl get crds -l app.kubernetes.io/managed-by=Helm -o name | grep karpenter.azure.com | xargs -I{} kubectl patch {} --type=json -p '
    [
      {"op":"remove","path":"/metadata/annotations/meta.helm.sh~1release-name"},
      {"op":"remove","path":"/metadata/annotations/meta.helm.sh~1release-namespace"},
      {"op":"remove","path":"/metadata/labels/app.kubernetes.io~1managed-by"}
    ]'
    ```
2. Uninstall the Helm chart to remove the Deployment, Service, Roles, and other resources used by open source Karpenter. At this point, Karpenter is no-longer reacting to scaling events, but existing nodes continue to function.

    ```bash
    helm uninstall karpenter -n kube-system  # If you installed Karpenter into a different namespace than kube-system, specify that here instead of kube-system
    ```
3. Enable NAP on your cluster:

    ```bash
    az aks update --name ${CLUSTER_NAME} --resource-group ${RESOURCE_GROUP} --node-provisioning-mode Auto --node-provisioning-default-pools None
    ```

    This command disables the default NodePools because you have existing NodePools and would like to continue using them. If you would like to enable node auto-provisioning default pools, you can omit the `--node-provisioning-default-pools None` from the `az aks update` command.
4. Verify migration complete: When the `az aks update` from step 3 completes successfully, migration is done. You can also confirm that migration is done by checking the annotations on the Karpenter CRDs. You should see:

    ```bash
        meta.helm.sh/release-name: aks-managed-karpenter-overlay-base
        meta.helm.sh/release-namespace: kube-system
    ```

    At this point, NAP is enabled and auto-scaling should resume.

## Monitoring Node auto-provisioning

### Retrieve Karpenter logs and status

You can retrieve logs and status updates from Karpenter to help diagnose and debug NAP-related events. AKS manages node auto-provisioning on your behalf and runs it in the managed control plane. You can enable control plane logs to see the Karpenter logs and operations from node auto-provisioning. For more on control plane logs, see the [AKS control plane logs documentation](monitor-aks-reference#supported-resource-logs-for-microsoftcontainerservicemanagedclusters)

1. Set up a rule for resource logs to push node auto-provisioning logs to Log Analytics using the [instructions here](monitor-aks#aks-control-plane-resource-logs). Make sure you check the box for `node-auto-provisioning` when selecting options for **Logs**.
2. Select the **Log** section on your cluster.
3. Enter the following example query into Log Analytics:

    ```kusto
    AKSControlPlane
    | where Category == "karpenter-events"
    ```
4. View node auto-provisioning events on CLI:

    ```bash
    kubectl get events --field-selector source=karpenter-events
    ```

## Node auto-provisioning metrics

You can enable [control plane metrics (Preview)](control-plane-metrics-monitor) to see specific Karpenter metrics and operations from [node auto-provisioning](control-plane-metrics-default-list#minimal-ingestion-for-default-off-targets) with the [Azure Monitor managed service for Prometheus add-on](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview).