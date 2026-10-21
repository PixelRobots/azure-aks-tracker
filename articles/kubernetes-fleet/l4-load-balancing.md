---
layout: Conceptual
title: How to set up multi-cluster Layer 4 load balancing across Azure Kubernetes Fleet Manager member clusters (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/l4-load-balancing
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
learn_banner_products:
- azure
description: Learn how to use Azure Kubernetes Fleet Manager to set up multi-cluster Layer 4 load balancing across workloads deployed on multiple member clusters.
ms.topic: how-to
ms.date: 2026-05-14T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.custom:
- devx-track-azurecli
locale: en-us
document_id: 1945441e-4e14-c90a-6a28-7f86b0ff5661
document_version_independent_id: 0c0680a2-0329-8039-63c2-76abad671ec4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/l4-load-balancing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/l4-load-balancing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/l4-load-balancing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 0c84389e-45ae-21c7-5238-12a651743966
---

# How to set up multi-cluster Layer 4 load balancing across Azure Kubernetes Fleet Manager member clusters (preview) | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

For applications deployed across multiple clusters, admins often want to route incoming traffic to them across clusters.

You can follow this document to set up layer 4 load balancing for such multi-cluster applications.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## Prerequisites

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Read the [conceptual overview of this feature](concepts-l4-load-balancing), which provides an explanation of `ServiceExport` and `MultiClusterService` objects referenced in this document.
- You must have a Fleet resource with a hub cluster and member clusters. If you don't have this resource, follow [Quickstart: Create a Fleet resource and join member clusters](quickstart-create-fleet-and-members).
- The target Azure Kubernetes Service (AKS) clusters on which the workloads are deployed need to be present on either the same [virtual network](/en-us/azure/virtual-network/virtual-networks-overview) or on [peered virtual networks](/en-us/azure/virtual-network/virtual-network-peering-overview).

    - These target clusters have to be [added as member clusters to the Fleet resource](quickstart-create-fleet-and-members#join-member-clusters).
    - These target clusters should be using [Azure CNI (Container Networking Interface) networking](/en-us/azure/aks/configure-azure-cni).
- You must gain access to the Kubernetes API of the hub cluster by following the steps in [Access Fleet hub cluster Kubernetes API](access-fleet-hub-cluster-kubernetes-api).
- Set the following environment variables and obtain the kubeconfigs for the fleet and all member clusters:

    ```bash
    export GROUP=<resource-group>
    export FLEET=<fleet-name>
    export MEMBER_CLUSTER_1=aks-member-1
    export MEMBER_CLUSTER_2=aks-member-2
    
    az fleet get-credentials --resource-group ${GROUP} --name ${FLEET} --file fleet
    
    az aks get-credentials --resource-group ${GROUP} --name ${MEMBER_CLUSTER_1} --file aks-member-1
    
    az aks get-credentials --resource-group ${GROUP} --name ${MEMBER_CLUSTER_2} --file aks-member-2
    ```

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

## Deploy a workload across member clusters of the Fleet resource

Note

- The steps in this how-to guide refer to a sample application for demonstration purposes only. You can substitute this workload for any of your own existing Deployment and Service objects.
- These steps deploy the sample workload from the Fleet Manager hub cluster to member clusters using Fleet Manager resource placement. Alternatively, you can choose to deploy these Kubernetes configurations to each member cluster separately, one at a time.

1. Create a namespace on the fleet cluster:

    ```bash
    KUBECONFIG=fleet kubectl create namespace kuard-demo
    ```

    Output looks similar to the following example:

    ```console
    namespace/kuard-demo created
    ```
2. Apply the Deployment, Service, ServiceExport objects:

    ```bash
    KUBECONFIG=fleet kubectl apply -f https://raw.githubusercontent.com/Azure/AKS/master/examples/fleet/kuard/kuard-export-service.yaml
    ```

    The `ServiceExport` specification in the above file allows you to export a service from member clusters to the Fleet resource. Once successfully exported, the service and all its endpoints are synced to the fleet cluster and can then be used to set up multi-cluster load balancing across these endpoints. The output looks similar to the following example:

    ```console
    deployment.apps/kuard created
    service/kuard created
    serviceexport.networking.fleet.azure.com/kuard created
    ```
3. Create the following `ClusterResourcePlacement` in a file called `crp-2.yaml`. Notice we're selecting clusters in the `eastus` region:

    ```yaml
    apiVersion: placement.kubernetes-fleet.io/v1
    kind: ClusterResourcePlacement
    metadata:
      name: kuard-demo
    spec:
      resourceSelectors:
        - group: ""
          version: v1
          kind: Namespace
          name: kuard-demo
      policy:
        affinity:
          clusterAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              clusterSelectorTerms:
                - labelSelector:
                    matchLabels:
                      fleet.azure.com/location: eastus
    ```
4. Apply the `ClusterResourcePlacement`:

    ```bash
    KUBECONFIG=fleet kubectl apply -f crp-2.yaml
    ```

    If successful, the output looks similar to the following example:

    ```console
    clusterresourceplacement.placement.kubernetes-fleet.io/kuard-demo created
    ```
5. Check the status of the `ClusterResourcePlacement`:

    ```bash
    KUBECONFIG=fleet kubectl get clusterresourceplacements
    ```

    If successful, the output looks similar to the following example:

    ```console
    NAME            GEN   SCHEDULED   SCHEDULEDGEN   APPLIED   APPLIEDGEN   AGE
    kuard-demo      1     True        1              True      1            20s
    ```

## Create MultiClusterService to load balance across the service endpoints in multiple member clusters

1. Check whether the service is successfully exported for the member clusters in `eastus` region:

    ```bash
    KUBECONFIG=aks-member-1 kubectl get serviceexport kuard --namespace kuard-demo
    ```

    Output looks similar to the following example:

    ```console
    NAME    IS-VALID   IS-CONFLICTED   AGE
    kuard   True       False           25s
    ```

    ```bash
    KUBECONFIG=aks-member-2 kubectl get serviceexport kuard --namespace kuard-demo
    ```

    Output looks similar to the following example:

    ```console
    NAME    IS-VALID   IS-CONFLICTED   AGE
    kuard   True       False           55s
    ```

    You should see that the service is valid for export (`IS-VALID` field is `true`) and has no conflicts with other exports (`IS-CONFLICT` is `false`).

    Note

    It may take a minute or two for the ServiceExport to be propagated.
2. Create `MultiClusterService` on one member to load balance across the service endpoints in these clusters:

    ```bash
    KUBECONFIG=aks-member-1 kubectl apply -f https://raw.githubusercontent.com/Azure/AKS/master/examples/fleet/kuard/kuard-mcs.yaml
    ```

    Note

    To expose the service via the internal IP instead of public one, add the annotation to the MultiClusterService:

    ```yaml
    apiVersion: networking.fleet.azure.com/v1alpha1
    kind: MultiClusterService
    metadata:
      name: kuard
      namespace: kuard-demo
      annotations:
         networking.fleet.azure.com/azure-load-balancer-internal: "true"
      ...
    ```

    Output looks similar to the following example:

    ```console
    multiclusterservice.networking.fleet.azure.com/kuard created
    ```
3. Verify the MultiClusterService is valid by running the following command:

    ```bash
    KUBECONFIG=aks-member-1 kubectl get multiclusterservice kuard --namespace kuard-demo
    ```

    The output should look similar to the following example:

    ```console
    NAME    SERVICE-IMPORT   EXTERNAL-IP     IS-VALID   AGE
    kuard   kuard            <a.b.c.d>       True       40s
    ```

    The `IS-VALID` field should be `true` in the output. Check out the external load balancer IP address (`EXTERNAL-IP`) in the output. It may take a while before the import is fully processed and the IP address becomes available.
4. Run the following command multiple times using the external load balancer IP address:

    ```bash
    curl <a.b.c.d>:8080 | grep addrs 
    ```

    Notice that the IPs of the pods serving the request is changing and that these pods are from member clusters `aks-member-1` and `aks-member-2` from the `eastus` region. You can verify the pod IPs by running the following commands on the clusters from `eastus` region:

    ```bash
    KUBECONFIG=aks-member-1 kubectl get pods -n kuard-demo -o wide
    ```

    ```bash
    KUBECONFIG=aks-member-2 kubectl get pods -n kuard-demo -o wide
    ```