---
layout: Conceptual
title: How to Configure and use cross-cluster networking for Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-configure-use-cross-cluster-networking
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
learn_banner_products:
- azure
description: Learn how to use Azure Kubernetes Fleet Manager to set up multi-cluster networking for highly available global services and service discovery.
ms.topic: how-to
ms.date: 2026-07-20T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
zone_pivot_groups: azure-portal-azure-cli
locale: en-us
document_id: bba20053-9e4c-10f1-ae6a-1a5b3e6d1b43
document_version_independent_id: eb76c049-d06c-02c6-27bb-bd316b311367
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-configure-use-cross-cluster-networking.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-configure-use-cross-cluster-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-configure-use-cross-cluster-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 832a8026-6391-2d27-c426-99477f69c383
---

# How to Configure and use cross-cluster networking for Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Cross-cluster networking for Azure Kubernetes Fleet Manager provides managed Cilium multi-cluster that extends Cilium's eBPF-based networking and observability across multiple clusters.

Fleet Manager supports creation of multiple cross-cluster networking profiles with each supporting up to 255 member clusters. Clusters in a profile participate in a managed federated network with access to global services and service discovery and observability via Hubble.

Platform engineers label member clusters that should participate in a single cross-cluster network, specifying the label in a selector when defining the network profile. To allow for bulk membership management and avoid unintended interruptions, the cross-cluster network is only updated when explicitly requested by an authorized user.

This article provides instructions on how to configure a cross-cluster networking profile, add member clusters and how to expose global services.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## Prerequisites and limitations

- A cross-cluster network can have up to 255 member clusters.
- Fleet Manager member clusters can only participate in a single cross-cluster network at any time.
- Clusters must run Kubernetes v1.32 or later and have Advanced Container Networking Services (ACNS) with Cilium enabled.
- Clusters must be connected to a [single flat network](../aks/concepts-network-cni-overview#flat-networks) (virtual network or multiple peered networks).
- Overlay networking with tunnels isn't currently supported.
- Self-managed Cilium multi-cluster can't be deployed at the same time.
- ACNS sets the Cilium version and enabled features which are read-only and can't be modified by users.

## Before you begin

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

Install the [Cilium CLI](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli) so you can verify the cross-cluster network in a later step.

## Set up your environment

If you're not currently using Fleet Manager and want to try out cross-cluster networking, follow the steps in this section.

If you already have a configured environment, you can skip to Create a cross-cluster network.

Set the following environment variables:

```bash
export CLUSTER_RESOURCE_GROUP=<cluster-resource-group>
export FLEET_RESOURCE_GROUP=<fleet-resource-group>
export RESOURCE_LOCATION=<azure-region-name>
export FLEET=<fleet-name>
export MEMBER_CLUSTER_1=aks-member-1
export MEMBER_CLUSTER_2=aks-member-2
export NETWORK_NAME=<network-name>
export NETWORK_PROFILE_NAME=fccnp-demo-01
export CC_NETWORK_NAME=demo-01
```

### Create network and subnets

Create a new Azure Virtual Network.

```azurecli
az network vnet create \
    --resource-group ${CLUSTER_RESOURCE_GROUP} \
    --location ${RESOURCE_LOCATION} \
    --name ${NETWORK_NAME} \
    --address-prefixes 10.0.0.0/8 \
    --output none
```

Then create four subnets that you can use to connect the two clusters.

```azurecli
# Subnets for cluster 1

SUBNET_ID_1=$(az network vnet subnet create \
    --resource-group ${CLUSTER_RESOURCE_GROUP} \
    --vnet-name ${NETWORK_NAME} \
    --name ${NETWORK_NAME}-01 \
    --address-prefixes 10.240.0.0/16 \
    --output tsv \
    --query id)

SUBNET_ID_2=$(az network vnet subnet create \
    --resource-group ${CLUSTER_RESOURCE_GROUP} \
    --vnet-name ${NETWORK_NAME} \
    --name ${NETWORK_NAME}-02 \
    --address-prefixes 10.241.0.0/16 \
    --output tsv \
    --query id)

# Subnets for cluster 2

SUBNET_ID_3=$(az network vnet subnet create \
    --resource-group ${CLUSTER_RESOURCE_GROUP} \
    --vnet-name ${NETWORK_NAME} \
    --name ${NETWORK_NAME}-03 \
    --address-prefixes 10.242.0.0/16 \
    --output tsv \
    --query id)

SUBNET_ID_4=$(az network vnet subnet create \
    --resource-group ${CLUSTER_RESOURCE_GROUP} \
    --vnet-name ${NETWORK_NAME} \
    --name ${NETWORK_NAME}-04 \
    --address-prefixes 10.243.0.0/16 \
    --output tsv \
    --query id)
```

### Create AKS clusters

Create two AKS clusters with ACNS enabled, using a flat network such as the one you created in the previous section.

For the first cluster, select the appropriate subnets.

```azurecli
    CLUSTER_ID_1=$(az aks create \
        --name ${MEMBER_CLUSTER_1} \
        --resource-group ${CLUSTER_RESOURCE_GROUP} \
        --location ${RESOURCE_LOCATION} \
        --node-count 1 \
        --vnet-subnet-id ${SUBNET_ID_1} \
        --pod-subnet-id ${SUBNET_ID_2} \
        --network-plugin azure \
        --network-dataplane cilium \
        --enable-acns \
        --generate-ssh-keys \
        --output tsv \
        --query id)
```

Use the remaining subnets for the second cluster as shown.

```azurecli
CLUSTER_ID_2=$(az aks create \
    --name ${MEMBER_CLUSTER_2} \
    --resource-group ${CLUSTER_RESOURCE_GROUP} \
    --location ${RESOURCE_LOCATION} \
    --node-count 1 \
    --vnet-subnet-id ${SUBNET_ID_3} \
    --pod-subnet-id ${SUBNET_ID_4} \
    --network-plugin azure \
    --network-dataplane cilium \
    --enable-acns \
    --generate-ssh-keys \
    --output tsv \
    --query id)
```

### Create a Fleet Manager and join clusters

In this guide, you create a new Fleet Manager. You don't need a hub cluster.

::: zone pivot="azure-cli"

```azurecli
az fleet create \
    --name ${FLEET} \
    --resource-group ${FLEET_RESOURCE_GROUP} \
    --location ${RESOURCE_LOCATION} 
```

Next, add your two clusters. Make sure you add a label that you can use to select the cluster to join the cross-cluster network.

```azurecli
az fleet member create \
    --fleet-name ${FLEET} \
    --resource-group ${FLEET_RESOURCE_GROUP} \
    --name mbr-${MEMBER_CLUSTER_1} \
    --member-cluster-id ${CLUSTER_ID_1} \
    --labels "network=${CC_NETWORK_NAME}"
```

Repeat this step for the second cluster.

```azurecli
az fleet member create \
    --fleet-name ${FLEET} \
    --resource-group ${FLEET_RESOURCE_GROUP} \
    --name mbr-${MEMBER_CLUSTER_2} \
    --member-cluster-id ${CLUSTER_ID_2} \
    --labels "network=${CC_NETWORK_NAME}"
```

::: zone-end

::: zone pivot="azure-portal"

You can follow the existing quickstart [Create an Azure Kubernetes Fleet Manager and join member clusters using the Azure portal](quickstart-create-fleet-and-members-portal).

Make sure you add a label such as `network=demo01` that you can use to select the cluster to join the cross-cluster network.

::: zone-end

## Create a cross-cluster network

Fleet Manager supports multiple cross-cluster networks, with each network configuration defined in a cross-cluster network profile.

Let's set up a new cross-cluster network by using the AKS clusters you provisioned.

::: zone pivot="azure-cli"

1. Create a cross-cluster network profile by using the [`az fleet clustermeshprofile create`](/en-us/cli/azure/fleet/clustermeshprofile#az-fleet-clustermeshprofile-create) command.

    ```azurecli
    az fleet clustermeshprofile create \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME} \
        --member-selector "network=${CC_NETWORK_NAME}"
    ```

    The profile defines the labels that pick the member clusters to join the network, but it doesn't apply any configuration to clusters until you apply it.
2. Validate which clusters are included in the cross-cluster network by using the [`az fleet clustermeshprofile apply`](/en-us/cli/azure/fleet/clustermeshprofile#az-fleet-clustermeshprofile-apply) command with the `what-if` parameter.

    ```azurecli
    az fleet clustermeshprofile apply \
        --what-if \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME} \
        --output table
    ```

    As you're creating a new cross-cluster network, both clusters have an `Add` action.

    ```output
    Action    ClusterResourceId                   ETag        MeshMembershipState    Name
    --------  ----------------------------------  ----------  ---------------------  ----------------
    Add       /subscription/…/…/mbr-aks-member-1  "fd009cd9"  -                      mbr-aks-member-1
    Add       /subscription/…/…/mbr-aks-member-2  "a400f86e"  -                      mbr-aks-member-2
    ```
3. Create the network by applying the cross-cluster networking changes by using the [`az fleet clustermeshprofile apply`](/en-us/cli/azure/fleet/clustermeshprofile#az-fleet-clustermeshprofile-apply) command without the `what-if` parameter.

    ```azurecli
    az fleet clustermeshprofile apply \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME}
    ```

    The cross-cluster network creation starts with the Cilium components being configured on the selected member clusters. The creation process is asynchronous, and the overall duration depends on the number of clusters being joined.
4. Monitor the status of the overall cross-cluster network provisioning as follows.

    ```azurecli
    az fleet clustermeshprofile show \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME} \
        --query "properties.status.state" \
        -o tsv
    ```

    The output should look similar to the following.

    ```output
    Result
    --------
    Applying
    ```

    The apply operation runs to completion and can't be interrupted. While it's running, you can monitor the network status of each member.

    ```azurecli
    az fleet clustermeshprofile list-members \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME} \
        --query "[].{name: name, state: meshProperties.status.state}" \
        -o table
    ```

    The output should look similar to the following.

    ```output
    Name              State
    ----------------  ----------
    mbr-aks-member-1  Connecting
    mbr-aks-member-2  Connecting
    ```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, go to your Azure Kubernetes Fleet Manager.
2. From the service menu, under **Settings**, select **Cross-cluster networking** &gt; **+ Create**.
3. Enter a name for the cross-cluster networking profile.

    [![Screenshot of the Azure portal showing how to set a cross-cluster profile name.](media/cross-cluster-networking/fleet-cross-cluster-creating-set-name.png)](media/cross-cluster-networking/fleet-cross-cluster-creating-set-name.png#lightbox)
4. Select one of the following options for the **Member label selector**, then select **Next**.

    - **Choose how to pick the label selector**: Use existing member cluster labels. Select one or more existing labels from the **Label selector(s)** dropdown.

    [![Screenshot of the Azure portal showing how to use existing labels in a cross-cluster profile.](media/cross-cluster-networking/fleet-cross-cluster-creating-use-existing-labels.png)](media/cross-cluster-networking/fleet-cross-cluster-creating-use-existing-labels.png#lightbox)

    - **Create new label**: Define a new label that you apply to member clusters you select. Create the label by selecting **+ Create new label** and completing the form.

    [![Screenshot of the Azure portal showing how to use a new label in a cross-cluster profile.](media/cross-cluster-networking/fleet-cross-cluster-creating-create-new-label.png)](media/cross-cluster-networking/fleet-cross-cluster-creating-create-new-label.png#lightbox)
5. Validate which clusters will be included in the cross-cluster network. Select **Next** or **Review**.

    [![Screenshot showing list of member clusters that will be included in a cross-cluster network.](media/cross-cluster-networking/fleet-cross-cluster-creating-validate-members.png)](media/cross-cluster-networking/fleet-cross-cluster-creating-validate-members.png#lightbox)

    If any clusters are missing, ensure they are labelled to match the cross-cluster network profile's label selector.
6. Review the proposed cross-cluster network and select **Create** to start the creation process.

    [![Screenshot showing review screen for the cross-cluster network being created.](media/cross-cluster-networking/fleet-cross-cluster-creating-review.png)](media/cross-cluster-networking/fleet-cross-cluster-creating-review.png#lightbox)
7. The cross-cluster networking list is displayed, with the new network showing the status **Applying**.

    [![Screenshot showing cross-cluster network list with a new network with the status of applying.](media/cross-cluster-networking/fleet-cross-cluster-creating-list-applying.png)](media/cross-cluster-networking/fleet-cross-cluster-creating-list-applying.png#lightbox)
8. Open the cross-cluster networking profile to view the details for each member cluster.

    [![Screenshot showing cross-cluster network details page while the network is being created.](media/cross-cluster-networking/fleet-cross-cluster-creating-details-applying.png)](media/cross-cluster-networking/fleet-cross-cluster-creating-details-applying.png#lightbox)
9. When the cross-cluster network is created, both the network and members show as Connected.

    [![Screenshot showing cross-cluster network details page with the network connected.](media/cross-cluster-networking/fleet-cross-cluster-creating-details-connected.png)](media/cross-cluster-networking/fleet-cross-cluster-creating-details-connected.png#lightbox)

::: zone-end

Note

Cluster connection attempts time out after 15 minutes. After this timeout, the connection state shows as `Failed`. See the Troubleshooting section for tips to identify the cause and resolve.

## Confirm cross-cluster network connection

When the member cluster states show as `Connected`, the cross-cluster network is established.

1. Get the Kubernetes access credentials for both member clusters by using [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) and set `context` appropriately.

    ```azurecli
    az aks get-credentials \
        --resource-group ${CLUSTER_RESOURCE_GROUP} \
        --name ${MEMBER_CLUSTER_1} \
        --context cluster1
    ```

    ```azurecli
    az aks get-credentials \
        --resource-group ${CLUSTER_RESOURCE_GROUP} \
        --name ${MEMBER_CLUSTER_2} \
        --context cluster2
    ```
2. Use the Cilium CLI status command to see that all member clusters are connected:

    ```bash
    cilium clustermesh status --context cluster1
    ```

    ```output
    ✅ Service "clustermesh-apiserver" of type "LoadBalancer" found
    ✅ Cluster access information is available:
      - 10.240.0.5:2379
    ✅ Deployment clustermesh-apiserver is ready
    ℹ️  KVStoreMesh is enabled
    
    ✅ All 1 nodes are connected to all clusters [min:1 / avg:1.0 / max:1]
    ✅ All 1 KVStoreMesh replicas are connected to all clusters [min:1 / avg:1.0 / max:1]
    
    🔌 Cluster Connections:
      - mbr-aks-member-021: 1/1 configured, 1/1 connected - KVStoreMesh: 1/1 configured, 1/1 connected
    ```

    Note

    Fleet Manager cross-cluster networking appends the Cilium cluster ID to the Fleet Manager member cluster name when registering it with the network. This registration adds a number to the peer in `Cluster Connections`. For example, the peer appears as `<fleet-member-name>` followed by a number, such as `mbr-aks-member-22`.

## Setup and test global services

After you create the cross-cluster network, test load balancing by following the [official Cilium multi-cluster example](https://docs.cilium.io/en/stable/network/clustermesh/services/#deploying-a-simple-example-service) or using the steps shown next. The steps in this article provide extra guidance on working with AKS clusters and Fleet Manager.

Note

Fleet Manager's cross-cluster networking sets Cilium's `clustermesh-default-global-namespace` to `false`, which differs from the Cilium default. You must set the annotation to `true` on a namespace to use it with cross-cluster service sharing.

- On `mbr-aks-member-1` create a dedicated namespace and annotate it so Services within it are eligible to be shared across the cross-cluster network. Then apply the `Deployment` and `Service` resources using the `cluster1.yaml` manifest.

    ```bash
    kubectl --context=cluster1 create namespace rebel-base-demo
    kubectl --context=cluster1 annotate namespace rebel-base-demo clustermesh.cilium.io/global="true" --overwrite
    kubectl --context=cluster1 -n rebel-base-demo apply -f https://raw.githubusercontent.com/cilium/cilium/refs/heads/main/examples/kubernetes/clustermesh/cluster1.yaml
    kubectl --context=cluster1 -n rebel-base-demo apply -f https://raw.githubusercontent.com/cilium/cilium/refs/heads/main/examples/kubernetes/clustermesh/global-service-example.yaml
    ```

    Note

    The example Cilium manifests use container images from public registries (`docker.io` and `quay.io`). If your environment uses Azure Policy or similar admission controls to restrict container image sources, the example Deployments might generate policy warnings or be blocked. In that case, mirror the images to a registry that is allowed by your policy and update the manifests accordingly.
- On `mbr-aks-member-2` apply the equivalent, but this time use the `cluster2.yaml` manifest.

    ```bash
    kubectl --context=cluster2 create namespace rebel-base-demo
    kubectl --context=cluster2 annotate namespace rebel-base-demo clustermesh.cilium.io/global="true" --overwrite
    kubectl --context=cluster2 -n rebel-base-demo apply -f https://raw.githubusercontent.com/cilium/cilium/refs/heads/main/examples/kubernetes/clustermesh/cluster2.yaml
    kubectl --context=cluster2 -n rebel-base-demo apply -f https://raw.githubusercontent.com/cilium/cilium/refs/heads/main/examples/kubernetes/clustermesh/global-service-example.yaml
    ```
- Run the following command multiple times on each cluster. Observe the serving cluster changes, demonstrating the request is being served by multiple clusters despite calling the service on only one.

    ```bash
    kubectl --context=cluster1 -n rebel-base-demo exec -ti deployment/x-wing -- curl rebel-base
    ```

    ```output
    {"Galaxy": "Alderaan", "Cluster": "Cluster-1"}
    {"Galaxy": "Alderaan", "Cluster": "Cluster-1"}
    {"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
    ```
- Set the `clustermesh.cilium.io/global` annotation on the `rebel-base-demo` Namespace on `mbr-aks-member-1` (cluster 1) to `"false"` so Services in that Namespace are no longer shared across the cross-cluster network from cluster 1.

    ```bash
    kubectl --context=cluster1 annotate namespace rebel-base-demo clustermesh.cilium.io/global="false" --overwrite
    ```

    Note

    After changing the Namespace-level `clustermesh.cilium.io/global` annotation, reconciling each Service within that Namespace is necessary to put the new configuration into effect (e.g. with `kubectl --context=cluster1 -n rebel-base-demo apply -f <service-manifest>.yaml`). The per-Service `service.cilium.io/global` annotation, by contrast, takes effect on both clusters within a few seconds.
- Let's validate `mbr-aks-member-1` (cluster 1) can reach the `rebel-base` Service on cluster 1, and `mbr-aks-member-2` (cluster 2) can't.

    ```bash
    kubectl --context=cluster1 -n rebel-base-demo exec -ti deployment/x-wing -- curl rebel-base
    ```

    On cluster 1, we only see local responses because the Namespace is no longer global and remote endpoints aren't imported.

    ```output
    {"Galaxy": "Alderaan", "Cluster": "Cluster-1"}
    {"Galaxy": "Alderaan", "Cluster": "Cluster-1"}
    {"Galaxy": "Alderaan", "Cluster": "Cluster-1"}
    ```

    Repeat the command on cluster 2.

    ```bash
    kubectl --context=cluster2 -n rebel-base-demo exec -ti deployment/x-wing -- curl rebel-base
    ```

    On cluster 2, we only see local responses because the Service on cluster 1 is no longer shared.

    ```output
    {"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
    {"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
    {"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
    ```

## Updating a cross-cluster network

The process of adding or removing clusters from a cross-cluster network follows this process.

::: zone pivot="azure-cli"

1. Modify the labels on the clusters to be added or removed.

    ```azurecli
    az fleet member update \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name mbr-${MEMBER_CLUSTER_1} \
        --labels "network=none"
    ```
2. Review cross-cluster networking changes with the [`az fleet clustermeshprofile apply`](/en-us/cli/azure/fleet/clustermeshprofile#az-fleet-clustermeshprofile-apply) command by using the `what-if` parameter.

    ```azurecli
    az fleet clustermeshprofile apply \
        --what-if \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME} \
        --output table
    ```

    The `aks-member-1` cluster shows a `Remove` action as you're removing it.

    ```output
    Action    ClusterResourceId                   ETag        MeshMembershipState    Name
    --------  ----------------------------------  ----------  ---------------------  ----------------
    Remove    /subscription/…/…/mbr-aks-member-1  "fd009cd9"  -                      mbr-aks-member-1
    -         /subscription/…/…/mbr-aks-member-2  "a400f86e"  -                      mbr-aks-member-2
    ```

    Reviewing the changes is optional, but recommended, especially for larger cross-cluster networks where any change can take some time to complete.
3. Once satisfied with the changes, apply to the network by running the same command, omitting the `what-if` parameter.

    ```azurecli
    az fleet clustermeshprofile apply \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME} \
        --output table
    ```

::: zone-end

::: zone pivot="azure-portal"

1. From the service menu, under **Settings**, select **Member clusters**.
2. Use the **Member clusters** list to modify the labels on clusters to be added or removed from the cross-cluster network.
3. From the service menu, under **Settings**, select **Cross-cluster networking**. The cross-cluster network **Drift status** shows `Detected`.

    [![Screenshot showing cross-cluster network list containing a profile with a detected drift status.](media/cross-cluster-networking/fleet-cross-cluster-drifted-list.png)](media/cross-cluster-networking/fleet-cross-cluster-drifted-list.png#lightbox)
4. Select the `Detected` drift status which opens the **Reconcile** dialog.

    [![Screenshot showing cross-cluster network reconciliation dialog with one cluster marked for removal.](media/cross-cluster-networking/fleet-cross-cluster-reconcile-changes.png)](media/cross-cluster-networking/fleet-cross-cluster-reconcile-changes.png#lightbox)
5. Review the proposed changes, selecting **Apply** to proceed.

::: zone-end

## Delete a cross-cluster network

To delete a cross-cluster network, first remove the members from the cross-cluster network by removing the labels used in the cross-cluster network profile.

Important

To prevent unexpected outages, you can't delete a cross-cluster network when it still contains member clusters. Additionally, you can't remove member clusters joined to a cross-cluster network from a Fleet Manager.

::: zone pivot="azure-cli"

1. Change the cross-cluster network profile's member selector to a value that no member cluster has, then apply the change so all members are disconnected from the cross-cluster network.

    ```azurecli
    az fleet clustermeshprofile create \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME} \
        --member-selector "network=none"
    
    az fleet clustermeshprofile apply \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME}
    ```
2. Confirm the profile reports no members before continuing.

    ```azurecli
    az fleet clustermeshprofile list-members \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME}
    ```

    ```output
    []
    ```
3. Delete the cross-cluster network profile.

    ```azurecli
    az fleet clustermeshprofile delete \
        --fleet-name ${FLEET} \
        --resource-group ${FLEET_RESOURCE_GROUP} \
        --name ${NETWORK_PROFILE_NAME} \
        --yes
    ```
4. Delete the member clusters from the fleet resource (or delete the fleet resource entirely with `az fleet delete`) and, when no longer needed, delete the AKS clusters and resource group.

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, go to your Azure Kubernetes Fleet Manager.
2. From the service menu, under **Settings**, select **Member clusters**.
3. Select the desired cluster in the list, select **Edit labels**.
4. In the **Edit labels** dialog, delete the label used for the cross-cluster network and choose **Apply**. Repeat for each cluster.

    [![Screenshot of the Azure portal showing how to use manage labels on a member cluster.](media/cross-cluster-networking/fleet-cross-cluster-manage-labels.png)](media/cross-cluster-networking/fleet-cross-cluster-manage-labels.png#lightbox)
5. From the service menu, under **Settings**, select **Cross-cluster networking**.
6. Select the desired cross-cluster networking profile in the list, and then select **Reconcile**.
7. In the **Reconcile** dialog, review the member cluster list and check that all clusters have **Remove** as their Action. Select **Apply**.

    [![Screenshot of the Azure portal showing the list of member clusters to be reconciled.](media/cross-cluster-networking/fleet-cross-cluster-reconcile.png)](media/cross-cluster-networking/fleet-cross-cluster-reconcile.png#lightbox)
8. The cross-cluster networking profile status changes to **Applying**. Once reconciliation completes, the network shows status **Not connected**.
9. Select the networking profile, and then select **Delete**.
10. In the **Delete cross-cluster networking profile** dialog, validate the profile is the correct one, then select **Delete**.

::: zone-end

## Troubleshooting

When members fail to connect, the `clustermesh-apiserver` LoadBalancer Service on the cluster has no external IP.

Check the `clustermesh-apiserver` Service on each affected member cluster:

```bash
kubectl --context=cluster1 -n kube-system get svc clustermesh-apiserver
```

If `EXTERNAL-IP` shows as `<pending>`, the Service isn't assigned an internal load balancer IP.

```output
NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
clustermesh-apiserver   LoadBalancer   10.0.221.162   <pending>     2379:31640/TCP   31s
```

Inspect the Service events to identify the underlying cause:

```bash
kubectl --context=cluster1 -n kube-system describe svc clustermesh-apiserver
```

A common cause is an `AuthorizationFailed` (HTTP 403) error, which indicates that the AKS cluster identity doesn't have permission to manage the subnet the cluster connects to.

```output
Events:
  Type     Reason                  Age   From                Message
  ----     ------                  ----  ----                -------
  Normal   EnsuringLoadBalancer    6s    service-controller  Ensuring load balancer
  Warning  SyncLoadBalancerFailed  6s    service-controller  Error syncing load balancer: failed to ensure load balancer: ...
                                                             RESPONSE 403: 403 Forbidden
                                                             ERROR CODE: AuthorizationFailed
                                                             {
                                                               "error": {
                                                                 "code": "AuthorizationFailed",
                                                                 "message": "The client '...' with object id '...' does not have authorization to perform action 'Microsoft.Network/virtualNetworks/subnets/read' over scope '/subscriptions/.../virtualNetworks/<vnet>/subnets/<subnet>' or the scope is invalid..."
                                                               }
                                                             }
```

Without this permission, the AKS load balancer controller can't assign an internal IP to the `clustermesh-apiserver` Service, and the cross-cluster network can't complete the connection.

The AKS cluster identity normally receives a **Network Contributor** role assignment on the virtual network or subnet when the cluster is created, but in some configurations this assignment isn't created. Manually grant the AKS cluster identity the **Network Contributor** role on the virtual network for every affected member cluster, then force a reconcile on the cluster using the `az aks update` command so the new role takes effect.

```azurecli
AKS_IDENTITY=$(az aks show --resource-group ${CLUSTER_RESOURCE_GROUP} --name ${MEMBER_CLUSTER_1} --query "identity.principalId" -o tsv)
VNET_ID=$(az network vnet show --resource-group ${CLUSTER_RESOURCE_GROUP} --name ${NETWORK_NAME} --query id -o tsv)

az role assignment create \
    --assignee-object-id ${AKS_IDENTITY} \
    --assignee-principal-type ServicePrincipal \
    --role "Network Contributor" \
    --scope ${VNET_ID}

az aks update --resource-group ${CLUSTER_RESOURCE_GROUP} --name ${MEMBER_CLUSTER_1}
```

Once the cluster is updated with the role assignment, run `az fleet clustermeshprofile apply` again.

Note

During preview, the status of a cross-cluster network profile might continue to show as `Failed` even when member clusters show as `Connected`.