---
layout: Conceptual
title: Azure Key Vault Provider for Secrets Store CSI Driver for Azure Kubernetes Service (AKS) Configuration Options - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-configuration-options
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
description: Learn about configuration and troubleshooting options for the Azure Key Vault provider for Secrets Store CSI Driver in AKS.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-security
ms.topic: how-to
ms.date: 2025-01-03T00:00:00.0000000Z
ms.custom: template-how-to, devx-track-azurecli
locale: en-us
document_id: a05c7fc4-1aa1-5f35-92d7-c88fe3e48de1
document_version_independent_id: 8fcba2e1-80bd-ce9d-30d6-64fe5643b0a2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/csi-secrets-store-configuration-options.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/csi-secrets-store-configuration-options
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/csi-secrets-store-configuration-options.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 938cd000-cfd9-f61d-0cc6-e1ffad887aa7
---

# Azure Key Vault Provider for Secrets Store CSI Driver for Azure Kubernetes Service (AKS) Configuration Options - Azure Kubernetes Service | Microsoft Learn

This article describes configuration options for the Azure Key Vault provider for Secrets Store CSI Driver in Azure Kubernetes Service (AKS), including how to enable and customize autorotation of secrets, sync mounted content with a Kubernetes secret, and access metrics.

## Prerequisites

Before you begin, complete the steps in [Use the Azure Key Vault provider for Secrets Store CSI Driver in an AKS cluster](csi-secrets-store-driver) and [Provide an identity to access the Azure Key Vault provider for Secrets Store CSI Driver in AKS](csi-secrets-store-identity-access).

## Autorotation and secret sync overview

Once you enable autorotation, the Azure Key Vault provider for Secrets Store CSI Driver updates the pod mount and the Kubernetes secret defined in the `secretObjects` field of the `SecretProviderClass`. It does so by polling for changes periodically, based on the rotation poll interval you defined. The default rotation poll interval is *two minutes*.

When you update a secret in an external secrets store after initial pod deployment, the Kubernetes Secret and the pod mount periodically update depending on how the application consumes the secret data.

- **Mount the Kubernetes Secret as a volume**: Use the autorotation and sync K8s secrets features of Secrets Store CSI Driver. The application needs to watch for changes from the mounted Kubernetes Secret volume. When the CSI Driver updates the Kubernetes Secret, the corresponding volume contents automatically update as well.
- **Application reads the data from the container filesystem**: Use the rotation feature of Secrets Store CSI Driver. The application needs to watch for the file change from the volume mounted by the CSI driver.
- **Use the Kubernetes Secret for an environment variable**: Restart the pod to get the latest secret as an environment variable. Use a tool such as [Reloader](https://github.com/stakater/Reloader) to watch for changes on the synced Kubernetes Secret and perform rolling upgrades on pods.

## Enable autorotation on a new AKS cluster

- Enable autorotation of secrets on a new cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command and with the `--enable-secret-rotation` flag and the `--enable-addons` flat set to `azure-keyvault-secrets-provider`. The following example creates a new AKS cluster named `myAKSCluster` in the resource group `myResourceGroup`:

    ```azurecli
    az aks create \
        --name myAKSCluster \
        --resource-group myResourceGroup \
        --enable-addons azure-keyvault-secrets-provider \
        --enable-secret-rotation \
        --generate-ssh-keys
    ```

    Condensed example output:

    ```output
    {
      "aadProfile": null,
      "addonProfiles": {
        "azureKeyvaultSecretsProvider": {
          "config": {
            "enableSecretRotation": "true",
            "rotationPollInterval": "2m"
          },
          "enabled": true,
    ...
    ```

## Enable autorotation on an existing AKS cluster

- Update an existing cluster to enable secret autorotation using the [`az aks addon update`](/en-us/cli/azure/aks#az-aks-addon-update) command with the `enable-secret-rotation` parameter and the `--addon` flag set to `azure-keyvault-secrets-provider`. The following example updates an existing AKS cluster named `myAKSCluster` in the resource group `myResourceGroup`:

    ```azurecli
    az aks addon update --resource-group myResourceGroup --name myAKSCluster --addon azure-keyvault-secrets-provider --enable-secret-rotation
    ```

## Customize rotation interval

- Specify a custom rotation interval using the [`az aks addon update`](/en-us/cli/azure/aks#az-aks-addon-update) command with the `rotation-poll-interval` parameter. The following example sets the rotation poll interval to five minutes for an existing AKS cluster named `myAKSCluster` in the resource group `myResourceGroup`:

    ```azurecli
    az aks addon update --resource-group myResourceGroup --name myAKSCluster --addon azure-keyvault-secrets-provider --enable-secret-rotation --rotation-poll-interval 5m
    ```

    Condensed example output:

    ```output
    ...
            "rotationPollInterval": "5m"
    ...
    ```

## Disable autorotation on an existing AKS cluster

Tip

If you're already using a `SecretProviderClass`, you can update the add-on without disabling it first using the `az aks addon enable` command without the `--enable-secret-rotation` parameter.

1. Disable the Azure Key Vault provider for Secrets Store Driver add-on using the [`az aks addon disable`](/en-us/cli/azure/aks#az-aks-addon-disable) command. The following example disables the add-on for an existing AKS cluster named `myAKSCluster` in the resource group `myResourceGroup`:

    ```azurecli
    az aks addon disable --resource-group myResourceGroup --name myAKSCluster --addon azure-keyvault-secrets-provider
    ```

    Condensed example output:

    ```output
    ...
        "azureKeyvaultSecretsProvider": {
          "config": null,
          "enabled": false,
          "identity": null
    ...
    ```
2. Re-enable the Azure Key Vault provider for Secrets Store Driver add-on without the `enable-secret-rotation` parameter using the [`az aks addon enable`](/en-us/cli/azure/aks#az-aks-addon-enable) command. The following example re-enables the add-on for the existing AKS cluster named `myAKSCluster` in the resource group `myResourceGroup`:

    ```azurecli
    az aks addon enable --resource-group myResourceGroup --name myAKSCluster --addon azure-keyvault-secrets-provider
    ```

    Condensed example output:

    ```output
    ...
            "enableSecretRotation": "false",
            "rotationPollInterval": "2m"
          },
          "enabled": true,
    ...
    ```

## Sync mounted content with a Kubernetes secret

Note

Before using the YAML example in this section, you need to modify them to support your chosen method of access to your key vault identity. For more information, see [Provide an identity to access the Azure Key Vault provider for Secrets Store CSI Driver](csi-secrets-store-identity-access).

You might want to create a Kubernetes secret to mirror your mounted secrets content. Your secrets sync after you start a pod to mount them. When you delete the pods that consume the secrets, your Kubernetes secret is also deleted.

- Sync mounted content with a Kubernetes secret using the `secretObjects` field when creating a `SecretProviderClass` to define the desired state of the Kubernetes secret, as shown in the following example YAML.

    ```yml
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: azure-sync
    spec:
      provider: azure
      secretObjects:                              # [OPTIONAL] SecretObjects defines the desired state of synced Kubernetes secret objects
      - data:
        - key: username                           # data field to populate
          objectName: foo1                        # name of the mounted content to sync; this could be the object name or the object alias
        secretName: foosecret                     # name of the Kubernetes secret object
        type: Opaque                              # type of Kubernetes secret object (for example, Opaque, kubernetes.io/tls)
    ```

    Note

    Make sure the `objectName` in the `secretObjects` field matches the file name of the mounted content. If you use `objectAlias` instead, it should match the object alias.

## Set an environment variable to reference Kubernetes secrets

Note

The example YAML demonstrates access to a secret through env variables and volume/volumeMount. A typical application would use one method or the other. Keep in mind that a secret needs to be mounted by at least one pod in order to become available through env variables.

- Reference your newly created Kubernetes secret by setting an environment variable in your pod, as shown in the following example YAML:

    ```yml
    kind: Pod
    apiVersion: v1
    metadata:
      name: busybox-secrets-store-inline
    spec:
      containers:
        - name: busybox
          image: registry.k8s.io/e2e-test-images/busybox:1.29-1
          command:
            - "/bin/sleep"
            - "10000"
          volumeMounts:
          - name: secrets-store01-inline
            mountPath: "/mnt/secrets-store"
            readOnly: true
          env:
          - name: SECRET_USERNAME
            valueFrom:
              secretKeyRef:
                name: foosecret
                key: username
      volumes:
        - name: secrets-store01-inline
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: "azure-sync"
    ```

## Access Azure Key Vault provider and Secrets Store CSI Driver metrics

You can access metrics provided by both the Azure Key Vault provider for Secrets Store CSI Driver and the Secrets Store CSI Driver itself. These metrics can help you monitor the performance and health of your secrets management solution.

### Azure Key Vault provider metrics

The Azure Key Vault provider exposes the following metrics:

| Metric | Description | Tags |
| --- | --- | --- |
| `keyvault_request` | The distribution of how long it took to get from the key vault. | `os_type=<runtime os>`, `provider=azure`, `object_name=<keyvault object name>`, `object_type=<keyvault object type>`, `error=<error if failed>` |
| `grpc_request` | The distribution of how long it took for the gRPC requests. | `os_type=<runtime os>`, `provider=azure`, `grpc_method=<rpc full method>`, `grpc_code=<grpc status code>`, `grpc_message=<grpc status message>` |

Metrics are served via Prometheus from port 8898, but this port isn't exposed outside the pod by default.

- Access the Azure Key Vault provider metrics over localhost using the `kubectl port-forward` command.

    ```bash
    kubectl port-forward -n kube-system ds/aks-secrets-store-provider-azure 8898:8898 & curl localhost:8898/metrics
    ```

### Secrets Store CSI Driver metrics

The Secrets Store CSI Driver exposes the following metrics:

| Metric | Description | Tags |
| --- | --- | --- |
| `total_node_publish` | The total number of successful volume mount requests. | `os_type=<runtime os>`, `provider=<provider name>` |
| `total_node_unpublish` | The total number of successful volume unmount requests. | `os_type=<runtime os>` |
| `total_node_publish_error` | The total number of errors with volume mount requests. | `os_type=<runtime os>`, `provider=<provider name>`, `error_type=<error code>` |
| `total_node_unpublish_error` | The total number of errors with volume unmount requests. | `os_type=<runtime os>` |
| `total_sync_k8s_secret` | The total number of Kubernetes secrets synced. | `os_type=<runtime os>`, `provider=<provider name>` |
| `sync_k8s_secret_duration_sec` | The distribution of how long it took to sync the Kubernetes secret. | `os_type=<runtime os>` |
| `total_rotation_reconcile` | The total number of rotation reconciles. | `os_type=<runtime os>`, `rotated=<true or false>` |
| `total_rotation_reconcile_error` | The total number of rotation reconciles with errors. | `os_type=<runtime os>`, `rotated=<true or false>`, `error_type=<error code>` |
| `rotation_reconcile_duration_sec` | The distribution of how long it took to rotate secrets-store content for pods. | `os_type=<runtime os>` |

Metrics are served from port 8095, but this port isn't exposed outside the pod by default.

- Access the Secrets Store CSI Driver metrics over localhost using the `kubectl port-forward` command.

    ```bash
    kubectl port-forward -n kube-system ds/aks-secrets-store-csi-driver 8095:8095 &
    curl localhost:8095/metrics
    ```

## Migrate from open-source to AKS-managed Secrets Store CSI Driver

1. Uninstall the open-source Secrets Store CSI Driver using the following `helm delete` command.

    ```bash
    helm delete <release name>
    ```

    Note

    If you installed the driver and provider using deployment YAMLs, you can delete the components using the following `kubectl delete` commands:

    ```bash
    # Delete AKV provider pods from Linux nodes
    kubectl delete -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml
    
    # Delete AKV provider pods from Windows nodes
    kubectl delete -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer-windows.yaml
    ```
2. Upgrade your existing AKS cluster with the feature using the [`az aks enable-addons`](/en-us/cli/azure/aks#az-aks-enable-addons) command with the `--addons` parameter set to `azure-keyvault-secrets-provider`. The following example enables the add-on for an existing AKS cluster named `myAKSCluster` in the resource group `myResourceGroup`:

    ```azurecli
    az aks enable-addons --addons azure-keyvault-secrets-provider --name myAKSCluster --resource-group myResourceGroup
    ```