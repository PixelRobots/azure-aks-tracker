---
layout: Conceptual
title: Deploy the Connected Registry Arc Extension - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/quickstart-connected-registry-arc-cli
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
description: Learn how to deploy the connected registry extension to an Arc-enabled Kubernetes cluster using Azure CLI with secure-by-default settings for efficient and secure container workload operations.
ms.topic: how-to
ms.date: 2026-01-23T00:00:00.0000000Z
ai-usage: ai-assisted
ms.custom: sfi-ropc-blocked
locale: en-us
document_id: 8680325c-a9da-a52b-14e2-5ec4b1072709
document_version_independent_id: 688290c3-11a8-8c6a-eb03-9561a8f7d53a
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/quickstart-connected-registry-arc-cli.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/quickstart-connected-registry-arc-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/quickstart-connected-registry-arc-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: bd3dabd4-312c-51ba-4081-bb18180f1fff
---

# Deploy the Connected Registry Arc Extension - Azure Container Registry | Microsoft Learn

In this article, you learn how to deploy the connected registry extension to an Arc-enabled Kubernetes cluster using Azure CLI.

The [connected registry feature of Azure Container Registry](intro-connected-registry) enables efficient management and access to containerized workloads, whether on-premises or at remote sites. Deploying the connected registry Arc extension on Arc-enabled Kubernetes clusters simplifies the management and access of these workloads.

## Prerequisites

- An [Azure Container Registry (ACR)](container-registry-get-started-azure-cli) with the **Premium** service tier (SKU), with at least one repository and a connected registry. If you don't already have a connected registry resource, follow the steps in [Create a connected registry](quickstart-create-connected-registry).
- An [Azure Arc-enabled Kubernetes cluster](/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster).
- The latest version of [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The latest versions of the `connectedk8s` and `k8s-extension` Azure CLI extensions. To install these extensions, run the following commands:

    ```azurecli
    az extension add --name k8s-extension
    az extension add --name connectedk8s
    ```

## Deploy the connected registry extension to the Arc-enabled Kubernetes cluster

By deploying the connected registry Arc extension, you can synchronize container images and other Open Container Initiative (OCI) artifacts with your ACR registry. The deployment helps speed-up access to registry artifacts and enables the building of advanced scenarios. The extension deployment ensures secure trust distribution between the connected registry and all client nodes within the cluster, and installs the cert-manager service for Transport Layer Security (TLS) encryption.

To learn more about deploying extensions to Azure Arc-enabled Kubernetes clusters, see [Deploy and manage an Azure Arc-enabled Kubernetes cluster extension](/en-us/azure/azure-arc/kubernetes/extensions).

### Generate the connection string and protected settings JSON File

For secure deployment of the connected registry extension, generate the connection string, including a new password and the specification of the transport protocol, and store the details in the `protected-settings-extension.json` file.

# [Bash](#tab/bash)
```bash
cat << EOF > protected-settings-extension.json
{
  "connectionString": "$(az acr connected-registry get-settings \
  --name myconnectedregistry \
  --registry myacrregistry \
  --parent-protocol https \
  --generate-password 1 \
  --query ACR_REGISTRY_CONNECTION_STRING --output tsv --yes)"
}
EOF
```

# [PowerShell](#tab/powershell)
```azurepowershell
echo "{\"connectionString\":\"$(az acr connected-registry get-settings \
--name myconnectedregistry \
--registry myacrregistry \
--parent-protocol https \
--generate-password 1 \
--query ACR_REGISTRY_CONNECTION_STRING \
--output tsv \
--yes | tr -d '\r')\" }" > settings.json
```

---

### Deploy the connected registry extension

Next, deploy the connected registry extension to your Arc-enabled Kubernetes cluster, referencing the JSON file you created. Use the [az k8s-extension create](/en-us/cli/azure/k8s-extension#az-k8s-extension-create) command:

```azurecli
  az k8s-extension create --cluster-name myarck8scluster \ 
  --cluster-type connectedClusters \
  --extension-type Microsoft.ContainerRegistry.ConnectedRegistry \
  --name myconnectedregistry \
  --resource-group myresourcegroup \ 
  --config service.clusterIP=192.100.100.1 \ 
  --config-protected-file protected-settings-extension.json  
  --auto-upgrade-minor-version true
```

The `clusterIP` must be from the cluster subnet IP range. The `service.clusterIP` parameter specifies the IP address of the connected registry service within the cluster. Ensure that the IP address you specify for `service.clusterIP` falls within the designated service IP range defined during the cluster's initial configuration, typically found in the cluster's networking settings. If the `service.clusterIP` isn't within this range, update it to an IP address that is both within the valid range and not currently in use by another service.

Tip

The example here enables automatic upgrades for the connected registry extension whenever a new version becomes available. If you prefer not to automatically upgrade, use `--auto-upgrade-minor-version false`.

To deploy a specific version of the connected registry extension, include the `--version <version number>` parameter in your [az-k8s-extension-create](/en-us/cli/azure/k8s-extension#az-k8s-extension-create) command.

## Verify connected registry extension deployment

To verify the deployment of the connected registry extension in the Arc-enabled Kubernetes cluster, run the [az k8s-extension show](/en-us/cli/azure/k8s-extension#az-k8s-extension-show) command to check the deployment status of the connected registry extension:

```azurecli
  az k8s-extension show 
  --name myconnectedregistry \ 
  --cluster-name myarck8scluster \
  --resource-group myresourcegroup \
  --cluster-type connectedClusters
```

For an example of the output, see [Show extension details](/en-us/azure/azure-arc/kubernetes/extensions#show-extension-details).

Next, for each connected registry, view the status and state of the connected registry using the [az acr connected-registry list](/en-us/cli/azure/acr/connected-registry#az-acr-connected-registry-list) command:

```azurecli
az acr connected-registry list --registry myacrregistry \
--output table
```

You should see output similar to the following example:

```console
    | NAME | MODE | CONNECTION STATE | PARENT | LOGIN SERVER | LAST SYNC(UTC) |
    |------|------|------------------|--------|--------------|----------------|
    | myconnectedregistry | ReadWrite | online | myacrregistry | myacrregistry.azurecr.io | 2026-01-09 12:00:00 |
    | myreadonlyacr | ReadOnly | offline | myacrregistry | myacrregistry.azurecr.io | 2026-01-09 12:00:00 |
```

For details on a specific connected registry, use [az acr connected-registry show](/en-us/cli/azure/acr/connected-registry#az-acr-connected-registry-show):

```azurecli
  az acr connected-registry show --registry myacrregistry \
  --name myreadonlyacr \ 
  --output table
```

This command shows output similar to the following example:

```console
   | NAME                | MODE      | CONNECTION STATE | PARENT        | LOGIN SERVER             | LAST SYNC(UTC)      | SYNC SCHEDULE | SYNC WINDOW       |
   | ------------------- | --------- | ---------------- | ------------- | ------------------------ | ------------------- | ------------- | ----------------- |
   | myconnectedregistry | ReadWrite | online           | myacrregistry | myacrregistry.azurecr.io | 2026-01-09 12:00:00 | 0 0 * * *     | 00:00:00-23:59:59 |
```

## Deploy a pod that uses an image from connected registry

To deploy a pod that uses an image from connected registry within the cluster, run the operation from the cluster node itself.

1. Run the [kubectl create secret docker-registry](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_secret_docker-registry/) command to create a secret in the cluster to authenticate with the connected registry:

    ```bash
    kubectl create secret docker-registry regcred --docker-server=192.100.100.1 --docker-username=mytoken --docker-password=mypassword
    ```
2. Deploy the pod that uses the desired image from the connected registry. This example uses service.clusterIP address `192.100.100.1` and image name `hello-world` with tag `latest`:

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: hello-world-deployment
      labels:
        app: hello-world
    spec:
      selector:
        matchLabels:
          app: hello-world
      replicas: 1
      template:
        metadata:
          labels:
            app: hello-world
        spec:
          imagePullSecrets:
            - name: regcred
          containers:
            - name: hello-world
              image: 192.100.100.1/hello-world:latest
    EOF
    ```

## Clean up resources

If you no longer want to use your connected registry, delete the extension from your Arc-enabled Kubernetes cluster and then delete the connected registry resource.

1. Run the [az k8s-extension delete](/en-us/cli/azure/k8s-extension#az-k8s-extension-delete) command to delete the connected registry extension:

    ```azurecli
    az k8s-extension delete --name myconnectedregistry 
    --cluster-name myarcakscluster \ 
    --resource-group myresourcegroup \ 
    --cluster-type connectedClusters
    ```
2. Run the [az acr connected-registry delete](/en-us/cli/azure/acr/connected-registry#az-acr-connected-registry-delete) command to delete the connected registry resource:

    ```azurecli
    az acr connected-registry delete --registry myacrregistry \
    --name myconnectedregistry \
    --resource-group myresourcegroup 
    ```