---
layout: Conceptual
title: Block pod access to the IMDS endpoint (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/imds-restriction
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
description: Learn how to enable IMDS restriction on an AKS cluster to restrict pod access to the IMDS endpoint (preview).
author: charleswool
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2025-05-30T00:00:00.0000000Z
ms.author: yuewu2
ai-usage: ai-assisted
locale: en-us
document_id: 2d6e3ecd-199b-5c08-aa73-3e1ea4f4baec
document_version_independent_id: 30a452e8-2981-5f29-caff-f4ce9c468270
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/imds-restriction.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/imds-restriction
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/imds-restriction.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6c4cf767-02dd-fb62-a482-73c477042cee
---

# Block pod access to the IMDS endpoint (preview) - Azure Kubernetes Service | Microsoft Learn

By default, all pods running in an Azure Kubernetes Service (AKS) cluster can access the [Azure Instance Metadata Service (IMDS)](/en-us/azure/virtual-machines/instance-metadata-service) endpoint. You can now optionally restrict access to the IMDS endpoint from your Azure Kubernetes Service (AKS) clusters to enhance security (preview).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## About IMDS restriction for AKS clusters

Azure IMDS is a REST API that provides information about currently running virtual machine instances. This information includes the SKU, storage, network configurations, and upcoming maintenance events.

The IMDS REST API is available at a well-known, nonroutable IP address (169.254.169.254) that is by default accessible from all pods running in an AKS cluster. This default access introduces certain security risks for an AKS cluster:

- Malicious users might exploit the service to obtain sensitive information such as tokens and other platform information, leading to information leakage.
- Potential authentication vulnerabilities are then exposed, because applications could misuse these credentials.

You can now opt to restrict access to the IMDS endpoint for non host network pods running in your cluster. Non host network pods have `hostNetwork` set to **false** in their specs. When IMDS restriction is enabled, non host network pods are unable to access the IMDS endpoint or acquire OAuth 2.0 tokens for authorization by a managed identity. Non host network pods should rely on [Microsoft Entra Workload ID](workload-identity-overview) after IMDS restriction is enabled.

Host network pods have `hostNetwork` set to **true** in their specs. Host network pods can continue to access the IMDS endpoint after IMDS restriction is enabled as they share the same network namespace with the host processes. Local processes in nodes can use the IMDS endpoint to retrieve instance metadata, so they're permitted to access the endpoint after the IMDS restriction is enabled.

## Before you begin

1. Make sure you have Azure CLI version 2.61.0 or later installed. To find the version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
2. Install the `aks-preview` Azure CLI extension version 7.0.0b2 or later.

    - If you don't already have the `aks-preview` extension, install it using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

        ```azurecli
        az extension add --name aks-preview
        ```
    - If you already have the `aks-preview` extension, update it to make sure you have the latest version using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

        ```azurecli
        az extension update --name aks-preview
        ```
3. Register the `IMDSRestrictionPreview` feature flag using the [az feature register](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace Microsoft.ContainerService --name IMDSRestrictionPreview
    ```

    Verify the registration status by using the [az feature show](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*:

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name IMDSRestrictionPreview
    ```

    When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider by using the [az provider register](/en-us/cli/azure/provider#az-provider-register) command:

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```
4. Enable OIDC Issuer on your AKS cluster. To create a new cluster or update an existing cluster, see [Configure an AKS cluster with OIDC Issuer](use-oidc-issuer).

## Limitations

Certain add-ons that need to access the IMDS endpoint aren't supported with IMDS restriction. If you have these add-ons installed on your cluster, you can't enable IMDS restriction. Conversely, if IMDS restriction is enabled, then you can't install these add-ons. Unsupported add-ons include:

- Application gateway ingress controller
- Azure Monitor for containers (Container Insights)
- Virtual nodes
- Azure Policy
- Cluster extensions: Flux (GitOps), Dapr, Azure App Configuration, Azure Machine Learning, Azure Container Storage, Azure Backup
- AI toolchain operator (preview)
- Application routing
- HTTP application routing
- Web application routing
- Azure cost analysis

The Azure Key Vault provider for Secrets Store Container Storage Interface (CSI) driver now supports workload identity authentication mode and therefore can work with IMDS restriction enabled.

Additionally, Windows node pools aren't currently supported with IMDS restriction.

Caution

Enabling IMDS restrictions for a cluster that uses unsupported add-ons results in an error.

## Important considerations

When IMDS restriction is enabled, AKS manages the iptables rules on the node. Keep in mind the following points to prevent the iptables rules from being accidentally removed or tampered with:

- The iptables rules can be modified with SSH or node-shell, so we recommend using [Disable SSH](manage-ssh-node-access) or using a policy to disable privileged pods.
- The iptables rules that restrict access to IMDS are restored when the node is [reimaged](node-image-upgrade) or restarted.

## Enable IMDS restriction on a new cluster

To enable IMDS restriction on a new cluster and block all traffic from non host network pods to the IMDS endpoint, run the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-imds-restriction` parameter.

```azurecli
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --enable-imds-restriction
```

## Enable IMDS restriction on an existing cluster

To enable IMDS restriction on an existing cluster and block all traffic from non host network pods to the IMDS endpoint, run the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-imds-restriction` parameter.

```azurecli
az aks update \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --enable-imds-restriction
```

After you update the cluster, you must [reimage](node-image-upgrade) the nodes in your cluster with `az aks upgrade --node-image-only` to begin to block traffic to the cluster's pods.

## Verify the traffic on a cluster with IMDS restriction enabled

To verify that IMDS restriction is in effect, test traffic to both the non host and host network pods.

### Verify the traffic on a non host network pod

1. Create a pod with `hostNetwork: false`. If you don't have a test pod with `hostNetwork: false`, you can run the following command to create one.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
         name: non-host-nw
    spec:
      hostNetwork: false
      containers:
      - name: non-host-nw
        image: mcr.microsoft.com/azurelinux/base/nginx:1
        command: ["sleep", "infinity"]
    EOF
    ```
2. Connect to the shell in the pod with `kubectl exec`.

    ```bash
    kubectl exec -it non-host-nw -- /bin/bash
    ```
3. Test the traffic from the pod to the IMDS endpoint.

    ```bash
    curl -s -H Metadata:true --connect-timeout 10 --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2023-11-15" 
    ```

Wait about 10 seconds and observe that the command doesn't return anything, which means that the connection timed out and the pod is unable to access the IMDS endpoint.

After that, clean up the pod with `kubectl delete pod non-host-nw`.

### Verify the traffic on a host network pod

1. Create a pod with `hostNetwork: true`. If you don't have a test pod with `hostNetwork: true`, you can run the following command to create one.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: host-nw
    spec:
      hostNetwork: true
      containers:
      - name: host-nw
        image: mcr.microsoft.com/azurelinux/base/nginx:1
        command: ["sleep", "infinity"]
    EOF
    ```
2. Connect to the shell in the pod with `kubectl exec`.

    ```bash
    kubectl exec -it host-nw -- /bin/bash
    ```
3. Test the traffic from the pod to the IMDS endpoint

    ```bash
    curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2023-11-15" 
    ```

Observe that the command returns the results, which means that the pod can access IMDS endpoints as expected.

After that, clean up the pod with `kubectl delete pod host-nw`.

## Disable IMDS restriction for a cluster

To disable IMDS restriction on an existing cluster and allow all traffic from any pods to the IMDS endpoint, run the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-imds-restriction` parameter.

```azurecli
az aks update \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --disable-imds-restriction
```

After you update the cluster, you must [reimage](node-image-upgrade) the nodes in your cluster to begin to allow all traffic to the cluster's pods.