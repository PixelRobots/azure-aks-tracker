---
layout: Conceptual
title: Securely scale your applications using the Kubernetes Event-driven Autoscaling (KEDA) add-on and workload identity - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/keda-workload-identity
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
description: Learn how to securely scale your applications using the KEDA add-on and workload identity on Azure Kubernetes Service (AKS).
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.date: 2024-07-08T00:00:00.0000000Z
ms.custom: template-how-to, aks-scaling
locale: en-us
document_id: 2d302b12-6804-db8e-f7df-737961323734
document_version_independent_id: 9b520c13-5a8c-36c9-72dc-b324bf132272
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/keda-workload-identity.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/keda-workload-identity
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/keda-workload-identity.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7c66e5cd-d5c5-4a61-a3bd-3b24186af7c8
---

# Securely scale your applications using the Kubernetes Event-driven Autoscaling (KEDA) add-on and workload identity - Azure Kubernetes Service | Microsoft Learn

This article shows you how to securely scale your applications with the Kubernetes Event-driven Autoscaling (KEDA) add-on and workload identity on Azure Kubernetes Service (AKS).

Important

Your cluster Kubernetes version determines what KEDA version will be installed on your AKS cluster. To see which KEDA version maps to each AKS version, see the **AKS managed add-ons** column of the [Kubernetes component version table](/en-us/azure/aks/supported-kubernetes-versions#aks-components-breaking-changes-by-version).

For GA Kubernetes versions, AKS offers full support of the corresponding KEDA minor version in the table. Kubernetes preview versions and the latest KEDA patch are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](https://azure.microsoft.com/support/legal/faq/)

## Before you begin

- You need an Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- You need the [Azure CLI installed](/en-us/cli/azure/install-azure-cli).
- Ensure you have firewall rules configured to allow access to the Kubernetes API server. For more information, see [Outbound network and FQDN rules for Azure Kubernetes Service (AKS) clusters](outbound-rules-control-egress#azure-global-required-network-rules).

## Create a resource group

- Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command. Make sure you replace the placeholder values with your own values.

    ```azurecli
    LOCATION=<azure-region>
    RG_NAME=<resource-group-name>
    
    az group create --name $RG_NAME --location $LOCATION
    ```

## Create an AKS cluster

1. Create an AKS cluster with the KEDA add-on, workload identity, and OIDC issuer enabled using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-workload-identity`, `--enable-keda`, and `--enable-oidc-issuer` flags. Make sure you replace the placeholder value with your own value.

    ```azurecli
    AKS_NAME=<cluster-name>
    
    az aks create \
        --name $AKS_NAME \
        --resource-group $RG_NAME \
        --enable-workload-identity \
        --enable-oidc-issuer \
        --enable-keda \
        --generate-ssh-keys 
    ```
2. Validate the deployment was successful and make sure the cluster has KEDA, workload identity, and OIDC issuer enabled using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command with the `--query` flag set to `"[workloadAutoScalerProfile, securityProfile, oidcIssuerProfile]"`.

    ```azurecli
    az aks show \
        --name $AKS_NAME \
        --resource-group $RG_NAME \
        --query "[workloadAutoScalerProfile, securityProfile, oidcIssuerProfile]"
    ```
3. Connect to the cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials \
        --name $AKS_NAME \
        --resource-group $RG_NAME \
        --overwrite-existing
    ```

## Create an Azure Service Bus

1. Create an Azure Service Bus namespace using the [`az servicebus namespace create`](/en-us/cli/azure/servicebus/namespace#az-servicebus-namespace-create) command. Make sure to replace the placeholder value with your own value.

    ```azurecli
    SB_NAME=<service-bus-name>
    SB_HOSTNAME="${SB_NAME}.servicebus.windows.net"
    
    az servicebus namespace create \
        --name $SB_NAME \
        --resource-group $RG_NAME \
        --disable-local-auth
    ```
2. Create an Azure Service Bus queue using the [`az servicebus queue create`](/en-us/cli/azure/servicebus/queue#az-servicebus-queue-create) command. Make sure to replace the placeholder value with your own value.

    ```azurecli
    SB_QUEUE_NAME=<service-bus-queue-name>
    
    az servicebus queue create \
        --name $SB_QUEUE_NAME \
        --namespace $SB_NAME \
        --resource-group $RG_NAME
    ```

## Create a managed identity

1. Create a managed identity using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command. Make sure to replace the placeholder value with your own value.

    ```azurecli
    MI_NAME=<managed-identity-name>
    
    MI_CLIENT_ID=$(az identity create \
        --name $MI_NAME \
        --resource-group $RG_NAME \
        --query "clientId" \
        --output tsv)
    ```
2. Get the OIDC issuer URL using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command with the `--query` flag set to `oidcIssuerProfile.issuerUrl`.

    ```azurecli
    AKS_OIDC_ISSUER=$(az aks show \
        --name $AKS_NAME \
        --resource-group $RG_NAME \
        --query oidcIssuerProfile.issuerUrl \
        --output tsv)
    ```
3. Create a federated credential between the managed identity and the namespace and service account used by the workload using the [`az identity federated-credential create`](/en-us/cli/azure/identity/federated-credential#az-identity-federated-credential-create) command. Make sure to replace the placeholder value with your own value.

    ```azurecli
    FED_WORKLOAD=<federated-credential-workload-name>
    
    az identity federated-credential create \
        --name $FED_WORKLOAD \
        --identity-name $MI_NAME \
        --resource-group $RG_NAME \
        --issuer $AKS_OIDC_ISSUER \
        --subject system:serviceaccount:default:$MI_NAME \
        --audience api://AzureADTokenExchange
    ```
4. Create a second federated credential between the managed identity and the namespace and service account used by the keda-operator using the [`az identity federated-credential create`](/en-us/cli/azure/identity/federated-credential#az-identity-federated-credential-create) command. Make sure to replace the placeholder value with your own value.

    ```azurecli
    FED_KEDA=<federated-credential-keda-name>
    
    az identity federated-credential create \
        --name $FED_KEDA \
        --identity-name $MI_NAME \
        --resource-group $RG_NAME \
        --issuer $AKS_OIDC_ISSUER \
        --subject system:serviceaccount:kube-system:keda-operator \
        --audience api://AzureADTokenExchange
    ```

## Create role assignments

1. Get the object ID for the managed identity using the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command with the `--query` flag set to `"principalId"`.

    ```azurecli
    MI_OBJECT_ID=$(az identity show \
        --name $MI_NAME \
        --resource-group $RG_NAME \
        --query "principalId" \
        --output tsv)
    ```
2. Get the Service Bus namespace resource ID using the [`az servicebus namespace show`](/en-us/cli/azure/servicebus/namespace#az-servicebus-namespace-show) command with the `--query` flag set to `"id"`.

    ```azurecli
    SB_ID=$(az servicebus namespace show \
        --name $SB_NAME \
        --resource-group $RG_NAME \
        --query "id" \
        --output tsv)
    ```
3. Assign the Azure Service Bus Data Owner role to the managed identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create \
        --role "Azure Service Bus Data Owner" \
        --assignee-object-id $MI_OBJECT_ID \
        --assignee-principal-type ServicePrincipal \
        --scope $SB_ID
    ```

## Enable Workload Identity on KEDA operator

1. After creating the federated credential for the `keda-operator` ServiceAccount, annotate the ServiceAccount with the managed identity's client ID. This tells the workload identity webhook which identity to bind to the `keda-operator` pods.

    ```azurecli
    kubectl annotate serviceaccount keda-operator \
        azure.workload.identity/client-id=$MI_CLIENT_ID \
        -n kube-system
    ```
2. Restart the `keda-operator` pods to ensure Workload Identity environment variables are injected into the pod.

    ```azurecli
    kubectl rollout restart deploy keda-operator -n kube-system
    ```
3. Confirm the keda-operator pods restart

    ```azurecli
    kubectl get pod -n kube-system -lapp=keda-operator -w
    ```
4. Once you've confirmed the keda-operator pods have finished rolling hit `Ctrl+c` to break the previous watch command then confirm the Workload Identity environment variables have been injected.

    ```azurecli
    KEDA_POD_ID=$(kubectl get po -n kube-system -l app.kubernetes.io/name=keda-operator -ojsonpath='{.items[0].metadata.name}')
    kubectl describe po $KEDA_POD_ID -n kube-system
    ```
5. You should see output similar to the following under **Environment**.

    ```text
    ---
    AZURE_CLIENT_ID:               xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx
    AZURE_TENANT_ID:               xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx
    AZURE_FEDERATED_TOKEN_FILE:    /var/run/secrets/azure/tokens/azure-identity-token
    AZURE_AUTHORITY_HOST:          https://login.microsoftonline.com/
    ---
    ```
6. Deploy a KEDA TriggerAuthentication resource that includes the User-Assigned Managed Identity's Client ID.

    ```azurecli
    kubectl apply -f - <<EOF
    apiVersion: keda.sh/v1alpha1
    kind: TriggerAuthentication
    metadata:
      name: azure-servicebus-auth
      namespace: default  # this must be same namespace as the ScaledObject/ScaledJob that will use it
    spec:
      podIdentity:
        provider:  azure-workload
        identityId: $MI_CLIENT_ID
    EOF
    ```

    Note

    With the TriggerAuthentication in place, KEDA will be able to authenticate via workload identity. The `keda-operator` Pods use the `identityId` to authenticate against Azure resources when evaluating scaling triggers.

## Publish messages to Azure Service Bus

At this point everything is configured for scaling with KEDA and Microsoft Entra Workload Identity. We will test this by deploying producer and consumer workloads.

1. Create a new ServiceAccount for the workloads.

    ```azurecli
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      annotations:
        azure.workload.identity/client-id: $MI_CLIENT_ID
      name: $MI_NAME
    EOF
    ```
2. Deploy a Job to publish 100 messages.

    ```azurecli
    kubectl apply -f - <<EOF
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: myproducer
    spec:
      template:
        metadata:
          labels:
            azure.workload.identity/use: "true"
        spec:
          serviceAccountName: $MI_NAME
          containers:
          - image: ghcr.io/azure-samples/aks-app-samples/servicebusdemo:latest
            name: myproducer
            resources: {}
            env:
            - name: OPERATION_MODE
              value: "producer"
            - name: MESSAGE_COUNT
              value: "100"
            - name: AZURE_SERVICEBUS_QUEUE_NAME
              value: $SB_QUEUE_NAME
            - name: AZURE_SERVICEBUS_HOSTNAME
              value: $SB_HOSTNAME
          restartPolicy: Never
    EOF
    ```

## Consume messages from Azure Service Bus

Now that we have published messages to the Azure Service Bus queue, we will deploy a ScaledJob to consume the messages. This ScaledJob will use the KEDA TriggerAuthentication resource to authenticate against the Azure Service Bus queue using the workload identity and scale out every 10 messages.

1. Deploy a ScaledJob resource to consume the messages. The scale trigger will be configured to scale out every 10 messages. The KEDA scaler will create 10 jobs to consume the 100 messages.

    ```azurecli
    kubectl apply -f - <<EOF
    apiVersion: keda.sh/v1alpha1
    kind: ScaledJob
    metadata:
      name: myconsumer-scaledjob
    spec:
      jobTargetRef:
        template:
          metadata:
            labels:
              azure.workload.identity/use: "true"
          spec:
            serviceAccountName: $MI_NAME
            containers:
            - image: ghcr.io/azure-samples/aks-app-samples/servicebusdemo:latest
              name: myconsumer
              env:
              - name: OPERATION_MODE
                value: "consumer"
              - name: MESSAGE_COUNT
                value: "10"
              - name: AZURE_SERVICEBUS_QUEUE_NAME
                value: $SB_QUEUE_NAME
              - name: AZURE_SERVICEBUS_HOSTNAME
                value: $SB_HOSTNAME
            restartPolicy: Never
      triggers:
      - type: azure-servicebus
        metadata:
          queueName: $SB_QUEUE_NAME
          namespace: $SB_NAME
          messageCount: "10"
        authenticationRef:
          name: azure-servicebus-auth
    EOF
    ```

    Note

    ScaledJob creates a Kubernetes Job resource whenever a scaling event occurs and thus a Job template needs to be passed in when creating the resource. As new Jobs are created, Pods will be deployed with workload identity bits to consume messages.
2. Verify the KEDA scaler worked as intended.

    ```azurecli
    kubectl describe scaledjob myconsumer-scaledjob
    ```
3. You should see events similar to the following.

    ```text
    Events:
    Type     Reason              Age   From           Message
    ----     ------              ----  ----           -------
    Normal   KEDAScalersStarted  10m   scale-handler  Started scalers watch
    Normal   ScaledJobReady      10m   keda-operator  ScaledJob is ready for scaling
    Warning  KEDAScalerFailed    10m   scale-handler  context canceled
    Normal   KEDAJobsCreated     10m   scale-handler  Created 10 jobs
    ```

## Clean up resources

After you verify that the deployment is successful, you can clean up the resources to avoid incurring Azure costs.

1. Delete the Azure resource group and all resources in it using the [`az group delete`][az-group-delete] command.

    ```azurecli
    az group delete --name $RG_NAME --yes --no-wait
    ```