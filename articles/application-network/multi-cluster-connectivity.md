---
layout: Conceptual
title: Configure Multi-Cluster Connectivity for Azure Kubernetes Application Network (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/multi-cluster-connectivity
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
learn_banner_products:
- azure
description: Learn how to choose a multi-cluster topology, configure network names and east-west gateway visibility, and verify connectivity between Application Network members.
author: jack4it
ms.author: mjac
ms.service: azure-kubernetes-app-net
ms.topic: how-to
ms.date: 2026-10-30T00:00:00.0000000Z
ai-usage: ai-generated
locale: en-us
document_id: 5be67f49-ea46-91fa-14d4-07e27737b858
document_version_independent_id: ca4eff6b-8ecb-c13c-2899-8a2d22693032
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/multi-cluster-connectivity.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: application-network/multi-cluster-connectivity
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/multi-cluster-connectivity.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 99338893-3eec-82f9-c923-bc3fecb26b08
---

# Configure Multi-Cluster Connectivity for Azure Kubernetes Application Network (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Application Network connects multiple AKS member clusters into a service network. You provide the underlying network connectivity and configure which workloads and services participate.

This article explains how network names determine the cross-cluster traffic path, how to configure member connectivity, and how to verify the result. A network name describes your mesh topology; it doesn't create a virtual network, configure peering, or make unreachable pod addresses routable.

## Prerequisites

- An [Application Network resource](get-started#create-an-azure-kubernetes-application-network-resource) and two AKS clusters that meet the [onboarding prerequisites](get-started#prerequisites). Both clusters must join the same Application Network, and all members must be in the same tenant.
- A [supported Application Network version](supported-versions#supported-application-network-versions-and-compatible-aks-versions) compatible with both clusters. Check available versions in each member cluster's region by using the [`az appnet list-versions`](/en-us/cli/azure/appnet#az-appnet-list-versions) command before selecting the version used in the examples:

    ```azurecli
    az appnet list-versions --location <member-cluster-region> -o table
    ```
- Azure CLI version 2.84.0 or later and the `appnet-preview` extension. Network-name commands require extension version **1.0.0b4 or later**, which uses API version `2026-08-01-preview`. Install or update the extension by using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command:

    ```azurecli
    az extension add --name appnet-preview --upgrade
    az extension show --name appnet-preview --query version -o tsv
    ```

    The `--upgrade` flag updates an already installed CLI extension, or installs it if it's missing. It doesn't upgrade Application Network members.
- `kubectl` access to both clusters. For the application-level verification walkthrough, also install a compatible `istioctl` version as described in the [traffic management prerequisites](traffic-management-use-cases#prerequisites).
- Network reachability appropriate for the topology you choose in the next section.

## Choose a topology

Application Network uses each member's network identity to distinguish these traffic paths:

| Topology | Member network names | Required reachability | Cross-cluster traffic path |
| --- | --- | --- | --- |
| Different networks | Different names, or the distinct defaults assigned when names are omitted | Each member's data plane can reach the other members' east-west gateways | Through east-west gateways |
| Same network | The same explicitly configured name | Direct, bidirectional reachability between non-overlapping pod IP addresses | Directly between workloads through the ambient data plane, without an east-west gateway on the path |

When you join a member without specifying `--network-name`, Application Network uses a distinct default network identity for that member. Assign the same name only when the clusters actually share direct pod-IP reachability. Being in the same VNet or having peered node subnets isn't sufficient by itself.

Important

[Azure CNI Overlay](../aks/concepts-network-azure-cni-overlay) pod addresses aren't directly reachable from outside their cluster. VNet peering alone doesn't provide the pod-IP reachability required by the same-network topology. Use the gateway-based topology when direct pod-IP connectivity isn't available.

For different networks, provide paths from each member's data plane to the remote east-west gateways through VNet peering, VPN, or another connectivity solution appropriate for your environment. For the same network, provide routes and network security rules that allow the required traffic between pod addresses in both directions. A shared network name doesn't configure either of these.

### Choose east-west gateway visibility

Gateway visibility is independent of the network name:

| `--east-west-gateway`value | Gateway load balancer | Connectivity responsibility |
| --- | --- | --- |
| `Internal` (default) | Private address | Provide private network reachability from each member to the remote gateways. |
| `External` | Public address | Allow the required gateway traffic under your organization's network security policy. |

An east-west gateway carries cross-cluster service traffic; it isn't an application ingress gateway. Changing its visibility doesn't enroll workloads, export services, or change Kubernetes API-server access.

Note

A shared network name doesn't disable east-west gateway provisioning or remove existing gateways and load balancers.

The [supported cluster configurations and limitations](overview#limitations) apply to both topologies. Network naming doesn't enable otherwise unsupported cluster configurations.

## Set environment variables

The following examples use Bash syntax and values without whitespace. Replace the placeholders with your resource names, cluster resource IDs, and a compatible Application Network version. The examples join new members in `SelfManaged` mode; for other upgrade choices, see [Configure upgrades](upgrades).

- Set the following environment variables for your Application Network resource and member clusters:

    ```bash
    export APPNET_RG=<appnet-resource-group>
    export APPNET_NAME=<appnet-name>
    export MEMBER_NAME_1=member-1
    export MEMBER_NAME_2=member-2
    export CLUSTER_ID_1=/subscriptions/<subscription-id>/resourceGroups/<aks-resource-group-1>/providers/Microsoft.ContainerService/managedClusters/<cluster-1>
    export CLUSTER_ID_2=/subscriptions/<subscription-id>/resourceGroups/<aks-resource-group-2>/providers/Microsoft.ContainerService/managedClusters/<cluster-2>
    export APPNET_VERSION=<compatible-appnet-version>
    export NETWORK_NAME=shared-network
    export CONTEXT_1=<kubectl-context-for-cluster-1>
    export CONTEXT_2=<kubectl-context-for-cluster-2>
    ```

## Join new members

If your clusters haven't joined the Application Network yet, choose one of the following topology options. They are alternatives, not sequential steps for the same members. If your clusters are already members, skip this section and configure the existing members instead.

### Option 1: Different networks through east-west gateways

Join the two clusters without specifying a network name so that each member uses its own default identity. The following example sets gateway visibility to `Internal`. You provide the private connectivity from each member's data plane to the remote gateway addresses.

- Join both clusters by using the [`az appnet member join`](/en-us/cli/azure/appnet/member#az-appnet-member-join) command:

    ```azurecli
    az appnet member join \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $MEMBER_NAME_1 \
        --member-resource-id $CLUSTER_ID_1 \
        --upgrade-mode SelfManaged \
        --version $APPNET_VERSION \
        --east-west-gateway Internal
    
    az appnet member join \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $MEMBER_NAME_2 \
        --member-resource-id $CLUSTER_ID_2 \
        --upgrade-mode SelfManaged \
        --version $APPNET_VERSION \
        --east-west-gateway Internal
    ```

You can also use different explicit network names for the two members. Different names describe different mesh networks even if the clusters are in the same Azure VNet.

### Option 2: Same network with direct pod-IP connectivity

First verify that pod addresses in each cluster are directly reachable from the other cluster and that the address spaces don't overlap.

- Join both members by using the same network name and the [`az appnet member join`](/en-us/cli/azure/appnet/member#az-appnet-member-join) command:

    ```azurecli
    az appnet member join \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $MEMBER_NAME_1 \
        --member-resource-id $CLUSTER_ID_1 \
        --upgrade-mode SelfManaged \
        --version $APPNET_VERSION \
        --network-name $NETWORK_NAME \
        --east-west-gateway Internal
    
    az appnet member join \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $MEMBER_NAME_2 \
        --member-resource-id $CLUSTER_ID_2 \
        --upgrade-mode SelfManaged \
        --version $APPNET_VERSION \
        --network-name $NETWORK_NAME \
        --east-west-gateway Internal
    ```

The shared name tells the mesh to use the same-network path. It doesn't establish the routes or disable gateway provisioning.

## Configure existing members

If your clusters are already members, update their network names rather than joining them again. Choose the same direct pod-IP or gateway-based topology described earlier.

- Configure the same-network topology by assigning the same name to both existing members by using the [`az appnet member update`](/en-us/cli/azure/appnet/member#az-appnet-member-update) command:

    ```azurecli
    az appnet member update \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $MEMBER_NAME_1 \
        --network-name $NETWORK_NAME
    
    az appnet member update \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $MEMBER_NAME_2 \
        --network-name $NETWORK_NAME
    ```

For a different-network topology, assign different explicit names to the members. Omitting `--network-name` from an update leaves the existing name unchanged; it doesn't reset the member to a default identity.

Treat a name change as a traffic-topology change. Plan and test the transition, including the connectivity required while members have different identities during the update. These commands don't change the member's upgrade mode or create underlying network connectivity.

## Enroll workloads and configure global services

Joining a cluster doesn't automatically enroll every workload or export every service. Enroll the application namespace in ambient mode, and mark services that participate in cross-cluster discovery as global.

The service must exist in the same namespace with the same name in both clusters.

- Set the application namespace and service name, then apply the labels in both clusters:

    ```bash
    export WORKLOAD_NAMESPACE=<application-namespace>
    export SERVICE_NAME=<service-name>
    
    kubectl --context $CONTEXT_1 label namespace $WORKLOAD_NAMESPACE istio.io/dataplane-mode=ambient --overwrite
    kubectl --context $CONTEXT_2 label namespace $WORKLOAD_NAMESPACE istio.io/dataplane-mode=ambient --overwrite
    
    kubectl --context $CONTEXT_1 -n $WORKLOAD_NAMESPACE label service $SERVICE_NAME istio.io/global=true --overwrite
    kubectl --context $CONTEXT_2 -n $WORKLOAD_NAMESPACE label service $SERVICE_NAME istio.io/global=true --overwrite
    ```

For L7 routing or authorization, follow the [waypoint deployment and global-service configuration steps](traffic-management-use-cases#install-waypoint-and-mark-services-as-global). The walkthrough also covers labeling waypoint services for cross-cluster use.

Network reachability and global discovery don't override your authorization policies. Allow the intended workload identities under the policies for your application.

## Verify configuration and traffic

Check the member configuration, then verify actual application traffic. A successful ARM operation alone doesn't prove cross-cluster connectivity.

### Check member configuration

- Inspect both members' connectivity profiles by using the [`az appnet member show`](/en-us/cli/azure/appnet/member#az-appnet-member-show) command:

    ```azurecli
    az appnet member show \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $MEMBER_NAME_1 \
        --query properties.connectivityProfile
    
    az appnet member show \
        --resource-group $APPNET_RG \
        --appnet-name $APPNET_NAME \
        --member-name $MEMBER_NAME_2 \
        --query properties.connectivityProfile
    ```

For explicitly named same-network members, confirm that both `network` values match. An omitted `network` value isn't evidence of a shared network: Application Network uses a distinct default identity for each member when a name isn't provided.

### Validate the data path

For different networks, inspect the services in `applink-system` to find the east-west gateway addresses and exposed ports. Verify that routes, network security groups, and network policies permit access from each member's data plane to the remote gateways:

- Inspect the gateway services in both clusters by using the `kubectl get services` command:

    ```bash
    kubectl --context $CONTEXT_1 -n applink-system get services -o wide
    kubectl --context $CONTEXT_2 -n applink-system get services -o wide
    ```

With `Internal` visibility, the load balancer address is private even though `kubectl` displays it in the `EXTERNAL-IP` column.

For the same network, inspect application pod addresses and verify direct connectivity from a test workload in the other cluster, in both directions. Checking only node addresses or peering status isn't sufficient.

For an application-level test, use the [multi-cluster traffic management walkthrough](traffic-management-use-cases). Generate traffic from both member clusters and confirm that requests reach a backend in the other cluster, not just a local backend. Use backend-specific responses, application logs, or [data plane metrics](metrics) to distinguish the destinations.

If cross-cluster traffic fails, check:

- Both clusters belong to the same Application Network.
- Network names reflect actual pod-IP reachability, and same-network pod address spaces don't overlap.
- Remote gateway addresses and ports are reachable from each member's data plane for different-network members.
- Application namespaces are enrolled and the intended services are marked global in both clusters.
- Services use matching names and namespaces, and the intended L7 path has the required waypoint configuration.
- Network and authorization policies permit the test traffic.