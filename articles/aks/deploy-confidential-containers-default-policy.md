---
layout: Conceptual
title: Deploy an AKS cluster with Confidential containers (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/deploy-confidential-containers-default-policy
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
description: Learn how to create an Azure Kubernetes Service (AKS) cluster with Confidential containers (preview) and a default security policy by using the Azure CLI.
ms.topic: quickstart
ms.subservice: aks-security
ms.date: 2026-09-17T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: devx-track-azurecli, ignite-fall-2023, mode-api
ai-usage: ai-assisted
locale: en-us
document_id: ef2fbc00-90aa-09cf-e082-6a5a01697ce7
document_version_independent_id: 579f9eeb-b047-72b4-b86b-f329b43d7bdf
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/deploy-confidential-containers-default-policy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/deploy-confidential-containers-default-policy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/deploy-confidential-containers-default-policy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 8a11cb9e-af4a-4f7d-e782-52bb2225eca6
---

# Deploy an AKS cluster with Confidential containers (preview) - Azure Kubernetes Service | Microsoft Learn

In this article, you use the Azure CLI to deploy an Azure Kubernetes Service (AKS) cluster and configure Confidential containers (preview) with an automatically generated security policy. You then deploy an application as a Confidential container. To learn more, read the [Overview of AKS Confidential containers](confidential-containers-overview).

In general, getting started with AKS Confidential containers involves the following steps.

- Deploy or upgrade an AKS cluster using the Azure CLI.
- Add an annotation to your pod YAML manifest to mark the pod as using Confidential containers.
- Add a security policy to your pod YAML manifest.
- Deploy your application in confidential computing.

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Prerequisites

- The latest version of the Azure CLI. Run `az version` to find the version, and run `az upgrade` to upgrade the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The latest version of the `aks-preview` Azure CLI extension.
- The latest version of the `confcom` Confidential Container Azure CLI extension. `confcom` is required to generate a [security policy](/en-us/azure/confidential-computing/confidential-containers-aks-security-policy).
- A workload identity and a federated identity credential. The workload identity credential enables Kubernetes applications access to Azure resources securely with a Microsoft Entra ID based on annotated service accounts. If you aren't familiar with Microsoft Entra Workload ID, see the [Microsoft Entra Workload ID overview](/en-us/azure/active-directory/workload-identities/workload-identities-overview) and review how [Workload Identity works with AKS](workload-identity-overview).
- The identity you're using to create your cluster has the appropriate minimum permissions. For more information about access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](concepts-identity).
- To manage a Kubernetes cluster, use the Kubernetes command-line client [kubectl](https://kubernetes.io/docs/reference/kubectl/). Azure Cloud Shell comes with `kubectl`. You can install `kubectl` locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.
- Confidential containers on AKS provide a sidecar open source container for attestation and secure key release. The sidecar integrates with a Key Management Service (KMS), like Azure Key Vault, for releasing a key to the container group after validation is completed. Deploying an [Azure Key Vault Managed HSM](/en-us/azure/key-vault/managed-hsm/overview) (Hardware Security Module) is optional but recommended to support container-level integrity and attestation. See [Provision and activate a Managed HSM](/en-us/azure/key-vault/managed-hsm/quick-create-cli) to deploy Managed HSM.

### Install the `aks-preview` Azure CLI extension

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

1. Run the following command to install the `aks-preview` extension:

    ```azurecli
    az extension add --name aks-preview
    ```
2. Run the following command to update to the latest version of the extension:

    ```azurecli
    az extension update --name aks-preview
    ```

### Install the `confcom` Azure CLI extension

1. Run the following command to install the `confcom` extension:

    ```azurecli
    az extension add --name confcom
    ```
2. Run the following command to update to the latest version of the extension:

    ```azurecli
    az extension update --name confcom
    ```

### Register the `KataCcIsolationPreview` feature flag

1. Run the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command to register the `KataCcIsolationPreview` feature flag, as shown in the following example:

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "KataCcIsolationPreview"
    ```
2. Wait a few minutes for the status to show *Registered*. Run the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command to verify the registration status:

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "KataCcIsolationPreview"
    ```
3. When the status shows *Registered*, run the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command to refresh the registration of the *Microsoft.ContainerService* resource provider:

    ```azurecli
    az provider register --namespace "Microsoft.ContainerService"
    ```

## Create a cluster with Confidential containers enabled

1. Create an AKS cluster by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. Specify the following parameters:

    - **--os-sku**: *AzureLinux*. Only the Azure Linux os-sku supports this feature in this preview release.
    - **--node-vm-size**: Any Azure VM size that supports nested virtualization for AMD SEV-SNP protected child VMs works. For example, [Standard_DC8as_cc_v5](/en-us/azure/virtual-machines/dcasccv5-dcadsccv5-series) VMs.
    - **--enable-workload-identity**: Enables creating a Microsoft Entra Workload ID so pods can use a Kubernetes identity.
    - **--enable-oidc-issuer**: Enables OpenID Connect (OIDC) Issuer. It allows a Microsoft Entra ID or other cloud provider identity and access management platform to discover the API server's public signing keys.
    - **--workload-runtime**: Specify *KataCcIsolation* to enable the Confidential containers feature on the node pool.

    ```azurecli
    az aks create --resource-group myResourceGroup --name myAKSCluster --os-sku AzureLinux --node-vm-size Standard_DC8as_cc_v5 --workload-runtime KataCcIsolation --node-count 1 --enable-oidc-issuer --enable-workload-identity --generate-ssh-keys
    ```

    After a few minutes, the command finishes and returns JSON-formatted information about the cluster.
2. When the cluster is ready, get the cluster credentials by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```

## Enable Confidential containers on an existing cluster

To use this feature with an existing AKS cluster, the following requirements must be met:

- Follow the steps to register the `KataCcIsolationPreview` feature flag.
- [Enable workload identity](workload-identity-deploy-cluster#deploy-and-configure-microsoft-entra-workload-id-on-an-azure-kubernetes-service-aks-cluster) on the cluster if it isn't already.

### Add a node pool with Confidential containers enabled

Use the following command to enable Confidential containers (preview) by creating a node pool to host it.

1. Add a node pool to your AKS cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Specify the following parameters:

    - **--resource-group**: Enter the name of an existing resource group to create the AKS cluster in.
    - **--cluster-name**: Enter a unique name for the AKS cluster, such as *myAKSCluster*.
    - **--name**: Enter a unique name for your cluster's node pool, such as *nodepool2*.
    - **--workload-runtime**: Specify *KataCcIsolation* to enable the feature on the node pool. Along with the `--workload-runtime` parameter, these other parameters satisfy the following requirements. Otherwise, the command fails and reports an issue with the corresponding parameters.
    - **--os-sku**: *AzureLinux*. Only the Azure Linux os-sku supports this feature in this preview release.
    - **--node-vm-size**: Any Azure VM size that supports nested virtualization for AMD SEV-SNP protected child VMs works. For example, [Standard_DC8as_cc_v5](/en-us/azure/virtual-machines/dcasccv5-dcadsccv5-series) VMs.

    The following example adds a user node pool to *myAKSCluster* with two nodes in *nodepool2* in the *myResourceGroup*:

    ```azurecli
    az aks nodepool add --resource-group myResourceGroup --name nodepool2 --cluster-name myAKSCluster --node-count 2 --os-sku AzureLinux --node-vm-size Standard_DC8as_cc_v5 --workload-runtime KataCcIsolation
    ```

    After a few minutes, the command completes and returns JSON-formatted information about the cluster.
2. Run the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command to reconcile the cluster configuration after adding the Confidential containers node pool.

    ```azurecli
    az aks update --name myAKSCluster --resource-group myResourceGroup
    ```

    After a few minutes, the command completes and returns JSON-formatted information about the cluster.
3. When the cluster is ready, get the cluster credentials by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```

## Deploy and configure workload identity

Before you configure access to the Azure Key Vault and secret, and deploy an application as a Confidential container, you need to complete the configuration of the workload identity.

To configure the workload identity, perform the following steps described in the [Deploy and configure workload identity](workload-identity-deploy-cluster) article:

- Retrieve the OIDC Issuer URL
- Create a managed identity
- Create Kubernetes service account
- Establish federated identity credential

Important

To continue this tutorial, set the environment variables from the **Export environmental variables** section in the [Deploy and configure workload identity](workload-identity-deploy-cluster) article. Set the variable `SERVICE_ACCOUNT_NAMESPACE` to `kafka`, and run the command `kubectl create namespace kafka` before configuring workload identity.

## Deploy a trusted application with kata-cc and attestation container

The following steps configure end-to-end encryption for Kafka messages using encryption keys managed by [Azure Managed Hardware Security Modules](/en-us/azure/key-vault/managed-hsm/overview) (Managed HSM). The key is only released when the Kafka consumer runs within a Confidential Container with an Azure attestation secret provisioning container injected into the pod.

This configuration is based on the following three components:

- Kafka Cluster: A simple Kafka cluster deployed in the Kafka namespace on the cluster.
- Kafka Producer: A Kafka producer running as a vanilla Kubernetes pod that sends encrypted user-configured messages using a public key to a Kafka topic.
- Kafka Consumer: A Kafka consumer pod that runs with the kata-cc runtime, retrieves the private key from a secure key release container to decrypt Kafka messages, and renders the messages to a web UI.

For this preview release, we recommend for test and evaluation purposes to either create or use an existing Azure Key Vault Premium tier resource to support storing keys in a hardware security module (HSM). We don't recommend using your production key vault. If you don't have an Azure Key Vault, see [Create a key vault using the Azure CLI](/en-us/azure/key-vault/general/quick-create-cli).

1. Grant the managed identity you created earlier, and your account, access to the key vault. [Assign](/en-us/azure/key-vault/general/rbac-guide#assign-role) both identities the **Key Vault Crypto Officer** and **Key Vault Crypto User** Azure RBAC roles.

    Note

    - The managed identity is the value you assign to the `USER_ASSIGNED_IDENTITY_NAME` variable.
    - To add role assignments, you must have `Microsoft.Authorization/roleAssignments/write` and `Microsoft.Authorization/roleAssignments/delete` permissions, such as [Key Vault Data Access Administrator](/en-us/azure/role-based-access-control/built-in-roles#key-vault-data-access-administrator), [User Access Administrator](/en-us/azure/role-based-access-control/built-in-roles#user-access-administrator), or [Owner](/en-us/azure/role-based-access-control/built-in-roles#owner).
    - You must use the Key Vault Premium SKU to support HSM-protected keys.

    Run the following command to set the scope:

    ```azurecli
    AKV_SCOPE=$(az keyvault show --name <AZURE_AKV_RESOURCE_NAME> --query id --output tsv)
    ```

    Run the following command to assign the **Key Vault Crypto Officer** role.

    ```azurecli
    az role assignment create --role "Key Vault Crypto Officer" --assignee "${USER_ASSIGNED_IDENTITY_NAME}" --scope $AKV_SCOPE
    ```

    Run the following command to assign the **Key Vault Crypto User** role.

    ```azurecli
    az role assignment create --role "Key Vault Crypto User" --assignee "${USER_ASSIGNED_IDENTITY_NAME}" --scope $AKV_SCOPE
    ```
2. Install the Kafka cluster in the kafka namespace by running the following command:

    ```bash
    kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
    ```
3. Run the following command to apply the `kafka` cluster CR file.

    ```bash
    kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-persistent-single.yaml -n kafka
    ```
4. Prepare the RSA Encryption/Decryption key using the [bash script](https://github.com/microsoft/confidential-container-demos/raw/main/kafka/setup-key.sh) for the workload from GitHub. Save the file as `setup-key.sh`.
5. Set the `MAA_ENDPOINT` environment variable with the FQDN of Attest URI by running the following command.

    ```bash
    export MAA_ENDPOINT="$(az attestation show --name "myattestationprovider" --resource-group "MyResourceGroup" --query 'attestUri' -o tsv | cut -c 9-)"
    ```

    Check if the FQDN of Attest URI is in correct format (the MAA\_ENDPOINT should not include the prefix "https://"):

    ```bash
    echo $MAA_ENDPOINT
    ```

    Note

    To set up Microsoft Azure Attestation, see [Quickstart: Set up Azure Attestation with Azure CLI](/en-us/azure/attestation/quickstart-azure-cli).
6. Copy the following YAML manifest and save it as `consumer.yaml`.

    ```yml
    apiVersion: v1
    kind: Pod
    metadata:
      name: kafka-golang-consumer
      namespace: kafka
      labels:
        azure.workload.identity/use: "true"
        app.kubernetes.io/name: kafka-golang-consumer
    spec:
      serviceAccountName: workload-identity-sa
      runtimeClassName: kata-cc-isolation
      containers:
        - image: "mcr.microsoft.com/aci/skr:2.7"
          imagePullPolicy: Always
          name: skr
          env:
            - name: SkrSideCarArgs
              value: ewogICAgImNlcnRjYWNoZSI6IHsKCQkiZW5kcG9pbnRfdHlwZSI6ICJMb2NhbFRISU0iLAoJCSJlbmRwb2ludCI6ICIxNjkuMjU0LjE2OS4yNTQvbWV0YWRhdGEvVEhJTS9hbWQvY2VydGlmaWNhdGlvbiIKCX0gIAp9
          command:
            - /bin/skr
          volumeMounts:
            - mountPath: /opt/confidential-containers/share/kata-containers/reference-info-base64
              name: endor-loc
        - image: "mcr.microsoft.com/acc/samples/kafka/consumer:1.0"
          imagePullPolicy: Always
          name: kafka-golang-consumer
          env:
            - name: SkrClientKID
              value: kafka-encryption-demo
            - name: SkrClientMAAEndpoint
              value: sharedeus2.eus2.test.attest.azure.net
            - name: SkrClientAKVEndpoint
              value: "myKeyVault.vault.azure.net"
            - name: TOPIC
              value: kafka-demo-topic
          command:
            - /consume
          ports:
            - containerPort: 3333
              name: kafka-consumer
          resources:
            limits:
              memory: 1Gi
              cpu: 200m
      volumes:
        - name: endor-loc
          hostPath:
            path: /opt/confidential-containers/share/kata-containers/reference-info-base64
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: consumer
      namespace: kafka
    spec:
      type: LoadBalancer
      selector:
        app.kubernetes.io/name: kafka-golang-consumer
      ports:
        - protocol: TCP
          port: 80
          targetPort: kafka-consumer
    ```

    Note

    Update the value for the pod environment variable `SkrClientAKVEndpoint` to match the URL of your Azure Key Vault, excluding the protocol value `https://`. The current value placeholder value is `myKeyVault.vault.azure.net`. Update the value for the pod environment variable `SkrClientMAAEndpoint` with the value of `MAA_ENDPOINT`. You can find the value of `MAA_ENDPOINT` by running the command `echo $MAA_ENDPOINT` or the command `az attestation show --name "myattestationprovider" --resource-group "MyResourceGroup" --query 'attestUri' -o tsv | cut -c 9-`.
7. Generate the security policy for the Kafka consumer YAML manifest and obtain the hash of the security policy stored in the `WORKLOAD_MEASUREMENT` variable by running the following command:

    ```bash
    export WORKLOAD_MEASUREMENT=$(az confcom katapolicygen -y consumer.yaml --print-policy | base64 -d | sha256sum | cut -d' ' -f1)
    ```
8. To generate an RSA asymmetric key pair (public and private keys), run the `setup-key.sh` script using the following command. The `<Azure Key Vault URL>` value should be `<your-unique-keyvault-name>.vault.azure.net`

    ```bash
    export MANAGED_IDENTITY=${USER_ASSIGNED_CLIENT_ID}
    bash setup-key.sh "kafka-encryption-demo" <Azure Key Vault URL>
    ```

    Note

    - The bash script `setup-key.sh` requires the environment variable `MANAGED_IDENTITY`.
    - The public key will be saved as `kafka-encryption-demo-pub.pem` after executing the bash script.

    Important

    If you receive the error `ForbiddenByRbac`, wait up to 24 hours. Backend services for managed identities cache per resource URI for up to 24 hours. For more information, see [Troubleshoot Azure RBAC](/en-us/azure/role-based-access-control/troubleshooting#symptom---role-assignment-changes-are-not-being-detected).
9. To verify the keys have been successfully uploaded to the key vault, run the following commands:

    ```azurecli
    az account set --subscription <Subscription ID>
    az keyvault key list --vault-name <KeyVault Name> -o table
    ```
10. Copy the following YAML manifest and save it as `producer.yaml`.

    ```yml
    apiVersion: v1
    kind: Pod
    metadata:
      name: kafka-producer
      namespace: kafka
    spec:
      containers:
        - image: "mcr.microsoft.com/acc/samples/kafka/producer:1.0"
          name: kafka-producer
          command:
            - /produce
          env:
            - name: TOPIC
              value: kafka-demo-topic
            - name: MSG
              value: "Azure Confidential Computing"
            - name: PUBKEY
              value: |-
                -----BEGIN PUBLIC KEY-----
                MIIBojAN***AE=
                -----END PUBLIC KEY-----
          resources:
            limits:
              memory: 1Gi
              cpu: 200m
    ```

    Note

    Update the value which begin with `-----BEGIN PUBLIC KEY-----` and ends with `-----END PUBLIC KEY-----` strings with the content from `kafka-encryption-demo-pub.pem` which was created in the previous step.
11. Deploy the `consumer` and `producer` YAML manifests using the files you saved earlier.

    ```bash
    kubectl apply -f consumer.yaml
    ```

    ```bash
    kubectl apply -f producer.yaml
    ```
12. Get the IP address of the web service using the following command:

    ```bash
    kubectl get svc consumer -n kafka
    ```
13. Copy and paste the external IP address of the consumer service into your browser and observe the decrypted message.

    The following example resembles the output of the command:

    ```output
    Welcome to Confidential containers on AKS!
    Encrypted Kafka Message:
    Msg 1: Azure Confidential Computing
    ```
14. You should also attempt to run the consumer as a regular Kubernetes pod by removing the `skr container` and `kata-cc runtime class` spec. Since you aren't running the consumer with kata-cc runtime class, you no longer need the policy.
15. Remove the entire policy and observe the messages again in the browser after redeploying the workload. Messages appear as base64-encoded ciphertext because the private encryption key can't be retrieved. The key can't be retrieved because the consumer is no longer running in a confidential environment, and the `skr container` is missing, preventing decryption of messages.

## Clean up resources

When you finish evaluating this feature, clean up unnecessary resources to avoid Azure charges. If you deployed a new cluster as part of your evaluation or testing, you can delete the cluster by using the [`az aks delete`](/en-us/cli/azure/aks#az-aks-delete) command.

```azurecli
az aks delete --resource-group myResourceGroup --name myAKSCluster
```

If you enabled Confidential containers (preview) on an existing cluster, you can remove the pods by using the [`kubectl delete pod`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete) command.

```bash
kubectl delete pod <pod-name>
```