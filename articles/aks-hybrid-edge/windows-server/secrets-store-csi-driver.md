---
layout: Conceptual
title: Kubernetes Secrets Store CSI driver integration | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/secrets-store-csi-driver
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
ms.service: azure-kubernetes-service-hybrid
description: Learn how to use the Azure Key Vault Provider for Secrets Store CSI Driver to integrate secrets stores with AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.custom: windows-server
locale: en-us
document_id: b4b7f802-15df-5fcc-7b7c-5a48bc3a601b
document_version_independent_id: 8f836f7b-6ac8-1db6-2ded-2e789cbbcb76
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/secrets-store-csi-driver.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/secrets-store-csi-driver
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/secrets-store-csi-driver.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 210f7d4a-5bdc-f1b9-ab95-fcc82b662231
---

# Kubernetes Secrets Store CSI driver integration | Microsoft Learn

> 
> Applies to: AKS on Windows Server

The *Kubernetes Secrets Store CSI driver* integrates secrets stores with Kubernetes using a [Container Storage Interface (CSI) volume](https://kubernetes-csi.github.io/docs/). If you integrate the Secrets Store CSI driver with AKS on Windows Server, you can mount secrets, keys, and certificates as a volume. The data is then mounted in the container's file system.

With the Secrets Store CSI driver, you can also integrate a key vault with one of the supported providers, such as [Azure Key Vault](/en-us/azure/key-vault/general/overview).

## Before you begin

Before you begin, make sure you have the following prerequisites:

- An Azure account and subscription.
- An existing deployment of AKS on Windows Server with an existing workload cluster. If you don't have a deployment, follow this [Quickstart for deploying an AKS host and a workload cluster](kubernetes-walkthrough-powershell).
- If you're running Linux clusters, they must be on version Linux 1.16.0 or later.
- If you're running Windows clusters, they must be on version Windows 1.18.0 or later.
- Make sure you complete the following installations:
    - [Helm](https://helm.sh/)
    - [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
    - The latest version of the [Azure CLI](/en-us/cli/azure/install-azure-cli).

## Access your clusters using kubectl

Run the following command to access your cluster by using `kubectl`. In the command, replace the value of `-name` with your existing cluster name. Your cluster name uses the specified cluster's `kubeconfig` file as the default `kubeconfig` file for `kubectl`:

```powershell
Get-AksHciCredential -name mycluster
```

## Install the Secrets Store CSI driver

To install the Secrets Store CSI driver, run the following Helm command:

```powershell
helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure/charts
```

The following command installs both the Secrets Store CSI driver and the Azure Key Vault provider:

```powershell
helm install csi csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --namespace kube-system
```

Note

You should install the Secrets Store CSI driver and Azure Key Vault provider in the `kube-system` namespace. This article uses the `kube-system` namespace for all instances.

## Verify the Secrets Store CSI driver and Azure Key Vault provider are successfully installed

Check your running pods to make sure the Secrets Store CSI driver and the Azure Key Vault provider are installed by running the following commands:

- To verify the Secrets Store CSI driver is installed, run this command:

    ```powershell
    kubectl get pods -l app=secrets-store-csi-driver -n kube-system
    ```

    Example output:

    ```output
    NAME                             READY   STATUS    RESTARTS   AGE
    secrets-store-csi-driver-spbfq   3/3     Running   0          3h52m
    ```
- To verify the Azure Key Vault provider is installed, run this command:

    ```powershell
    kubectl get pods -l app=csi-secrets-store-provider-azure -n kube-system
    ```

    Example output:

    ```output
    NAME                                         READY   STATUS    RESTARTS   AGE
    csi-csi-secrets-store-provider-azure-tpb4j   1/1     Running   0          3h52m
    ```

## Add secrets in an Azure key vault

You need an Azure Key Vault resource that contains your secret data. You can use an existing Azure Key Vault resource or create a new one.

If you need to create an Azure Key Vault resource, run the following command. Make sure you're signed in by running `az login` with your Azure credentials. Then change the following values to your environment:

```azurecli
az keyvault create -n <keyvault-name> -g <resourcegroup-name> -l eastus
```

Azure Key Vault can store keys, secrets, and certificates. In the following example, a plain-text secret called `ExampleSecret` is configured:

```azurecli
az keyvault secret set --vault-name <keyvault-name> -n ExampleSecret --value MyAKSHCIExampleSecret
```

## Create an identity in Azure

Use a service principal to access the Azure Key Vault instance that you created in the previous step. Record the output when running the following commands. You use both the client secret and client ID in the next steps.

Provide the client secret by running the following command:

```azurecli
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription-id> --name http://secrets-store-test --query 'password' -otsv
```

Provide the client ID by running the following command:

```azurecli
az ad sp show --id http://secrets-store-test --query 'appId' -otsv
```

## Provide the identity to access the Azure key vault

Use the values from the previous step to set permissions as shown in the following command:

```azurecli
az keyvault set-policy -n <keyvault-name> --secret-permissions get --spn <client-id>
```

## Create the Kubernetes secret with credentials

To create the Kubernetes secret with the service principal credentials, run the following command. Replace the following values with the appropriate client ID and client secret from the previous step:

```powershell
kubectl create secret generic secrets-store-creds --from-literal clientid=<client-id> --from-literal clientsecret=<client-secret>
```

By default, the secret store provider filters watch on secrets. You can allow the command to find the secret in the default configuration by adding the label `secrets-store.csi.k8s.io/used=true` to the secret:

```powershell
kubectl label secret secrets-store-creds secrets-store.csi.k8s.io/used=true
```

## Create and apply your own SecretProviderClass object

To use and configure the Secrets Store CSI driver for your Kubernetes cluster, create a `SecretProviderClass` custom resource. Ensure the `objects` array matches the objects you stored in the Azure Key Vault instance:

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: <keyvault-name>                  # The name of the Azure key vault
  namespace: kube-system
spec:
  provider: azure
  parameters:
    keyvaultName: "<keyvault-name>"       # The name of the Azure key vault
    useVMManagedIdentity: "false"         
    userAssignedIdentityID: "false" 
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud 
    objects:  |
      array:
        - |
          objectName: <secret-name>       # In this example, 'ExampleSecret'   
          objectType: secret              # Object types: secret, key or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
    tenantId: "<tenant-id>"               # The tenant ID containing the Azure Key Vault instance
```

## Apply the SecretProviderClass to your cluster

To deploy the `SecretProviderClass` you created in the previous step, use the following command:

```powershell
kubectl apply -f ./new-secretproviderclass.yaml
```

## Update and apply your cluster's deployment YAML file

To ensure that your cluster uses the new custom resource, update the deployment YAML file. For example:

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: busybox-secrets-store-inline
spec:
  containers:
  - name: busybox
    image: k8s.gcr.io/e2e-test-images/busybox:1.29
    command:
      - "/bin/sleep"
      - "10000"
    volumeMounts:
    - name: secrets-store-inline
      mountPath: "/mnt/secrets-store"
      readOnly: true
  volumes:
    - name: secrets-store-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "<keyvault-name>"
        nodePublishSecretRef:                       # Only required when using service principal mode
          name: secrets-store-creds                 # Only required when using service principal mode
```

Then, apply the updated deployment YAML file to the cluster:

```powershell
kubectl apply -f ./my-deployment.yaml 
```

## Validate the Secrets Store deployment

To show the secrets that are held in `secrets-store`, run the following command:

```powershell
kubectl exec busybox-secrets-store-inline --namespace kube-system -- ls /mnt/secrets-store/
```

The output should show the name of the secret. In this example, it displays the following output:

```output
ExampleSecret
```

To show the test secret held in `secrets-store`, run the following command:

```powershell
kubectl exec busybox-secrets-store-inline --namespace kube-system -- cat /mnt/secrets-store/ExampleSecret 
```

The output should show the value of the secret. In this example, it shows the following output:

```output
MyAKSHCIExampleSecret
```