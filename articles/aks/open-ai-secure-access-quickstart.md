---
layout: Conceptual
title: Secure access to Azure OpenAI from Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/open-ai-secure-access-quickstart
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
description: Learn how to secure access to Azure OpenAI from Azure Kubernetes Service (AKS).
ms.custom: devx-track-azurecli
ms.topic: how-to
ms.date: 2023-09-18T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ms.subservice: aks-developer
locale: en-us
document_id: 181e9777-31a5-0e02-6853-60d688d694f5
document_version_independent_id: 59eff811-a32a-ed09-465b-b1f82e62770d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/open-ai-secure-access-quickstart.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/open-ai-secure-access-quickstart
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/open-ai-secure-access-quickstart.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/8a6e4dad-7050-4ce7-83f9-eb4123577a54
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/0a5fc323-00ce-4c20-9095-41948f54c83f
platformId: 9eb53c60-5f72-b52a-7452-5c4e2d1d1443
---

# Secure access to Azure OpenAI from Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to secure access to Azure OpenAI from Azure Kubernetes Service (AKS) using Microsoft Entra Workload ID. You learn how to:

- Enable workload identities on an AKS cluster.
- Create an Azure user-assigned managed identity.
- Create a Microsoft Entra ID federated credential.
- Enable workload identity on a Kubernetes Pod.

Note

We recommend using Microsoft Entra Workload ID and managed identities on AKS for Azure OpenAI access because it enables a secure, passwordless authentication process for accessing Azure resources.

## Before you begin

- You need an Azure account with an active subscription. If you don't have one, [create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- This article builds on [Deploy an application that uses OpenAI on AKS](open-ai-quickstart). You should complete that article before you begin this one.
- You need a custom domain name enabled on your Azure OpenAI account to use for Microsoft Entra authorization. For more information, see [Custom subdomain names for Foundry Tools](/en-us/azure/ai-services/cognitive-services-custom-subdomains).

## Prerequisites

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

## Enable Microsoft Entra Workload ID on an AKS cluster

The Microsoft Entra Workload ID and OIDC Issuer Endpoint features aren't enabled on AKS by default. You must enable them on your AKS cluster before you can use them.

1. Set the resource group name and AKS cluster resource group name variables.

    ```azurecli
    # Set the resource group variable
    RG_NAME=myResourceGroup
    
    # Set the AKS cluster name based on the resource group variable
    AKS_NAME=$(az resource list --resource-group $RG_NAME --resource-type Microsoft.ContainerService/managedClusters --query "[0].name" -o tsv)
    ```
2. Enable the Microsoft Entra Workload ID and OIDC Issuer Endpoint features on your existing AKS cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

    ```azurecli
    az aks update \
        --resource-group $RG_NAME \
        --name $AKS_NAME \
        --enable-workload-identity \
        --enable-oidc-issuer
    ```
3. Get the AKS OIDC Issuer Endpoint URL using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    AKS_OIDC_ISSUER=$(az aks show --resource-group $RG_NAME --name $AKS_NAME --query "oidcIssuerProfile.issuerUrl" -o tsv)
    ```

## Create an Azure user-assigned managed identity

1. Create an Azure user-assigned managed identity using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    # Set the managed identity name variable
    MANAGED_IDENTITY_NAME=myIdentity
    
    # Create the managed identity
    az identity create \
        --resource-group $RG_NAME \
        --name $MANAGED_IDENTITY_NAME
    ```
2. Get the managed identity client ID and object ID using the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command.

    ```azurecli
    # Get the managed identity client ID
    MANAGED_IDENTITY_CLIENT_ID=$(az identity show --resource-group $RG_NAME --name $MANAGED_IDENTITY_NAME --query clientId -o tsv)
    
    # Get the managed identity object ID
    MANAGED_IDENTITY_OBJECT_ID=$(az identity show --resource-group $RG_NAME --name $MANAGED_IDENTITY_NAME --query principalId -o tsv)
    ```
3. Get the Azure OpenAI resource ID using the [`az resource list`](/en-us/cli/azure/resource#az-resource-list) command.

    ```azurecli
    AOAI_RESOURCE_ID=$(az resource list --resource-group $RG_NAME --resource-type Microsoft.CognitiveServices/accounts --query "[0].id" -o tsv)
    ```
4. Grant the managed identity access to the Azure OpenAI resource using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create \
        --role "Cognitive Services OpenAI User" \
        --assignee-object-id $MANAGED_IDENTITY_OBJECT_ID \
        --assignee-principal-type ServicePrincipal \
        --scope $AOAI_RESOURCE_ID
    ```

## Create a Microsoft Entra ID federated credential

1. Set the federated credential, namespace, and service account variables.

    ```azurecli
    # Set the federated credential name variable
    FEDERATED_CREDENTIAL_NAME=myFederatedCredential
    
    # Set the namespace variable
    SERVICE_ACCOUNT_NAMESPACE=default
    
    # Set the service account variable
    SERVICE_ACCOUNT_NAME=ai-service-account
    ```
2. Create the federated credential using the [`az identity federated-credential create`](/en-us/cli/azure/identity/federated-credential#az-identity-federated-credential-create) command.

    ```azurecli
    az identity federated-credential create \
        --name ${FEDERATED_CREDENTIAL_NAME} \
        --resource-group ${RG_NAME} \
        --identity-name ${MANAGED_IDENTITY_NAME} \
        --issuer ${AKS_OIDC_ISSUER} \
        --subject system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}
    ```

## Use Microsoft Entra Workload ID on AKS

To use Microsoft Entra Workload ID on AKS, you need to make a few changes to the `ai-service` deployment manifest.

### Create a ServiceAccount

1. Get the kubeconfig for your cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials \
        --resource-group $RG_NAME \
        --name $AKS_NAME
    ```
2. Create a Kubernetes ServiceAccount using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```azurecli
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      annotations:
        azure.workload.identity/client-id: ${MANAGED_IDENTITY_CLIENT_ID}
      name: ${SERVICE_ACCOUNT_NAME}
      namespace: ${SERVICE_ACCOUNT_NAMESPACE}
    EOF
    ```

### Enable Microsoft Entra Workload ID on the Pod

1. Set the Azure OpenAI resource name, endpoint, and deployment name variables.

    ```azurecli
    # Get the Azure OpenAI resource name
    AOAI_NAME=$(az resource list \
      --resource-group $RG_NAME \
      --resource-type Microsoft.CognitiveServices/accounts \
      --query "[0].name" -o tsv)
    
    # Get the Azure OpenAI endpoint
    AOAI_ENDPOINT=$(az cognitiveservices account show \
      --resource-group $RG_NAME \
      --name $AOAI_NAME \
      --query properties.endpoint -o tsv)
    
    # Get the Azure OpenAI deployment name
    AOAI_DEPLOYMENT_NAME=$(az cognitiveservices account deployment list  \
      --resource-group $RG_NAME \
      --name $AOAI_NAME \
      --query "[0].name" -o tsv)
    ```
2. Redeploy the `ai-service` with the ServiceAccount and the `azure.workload.identity/use` annotation set to `true` using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```azurecli
    kubectl apply -f - <<EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ai-service
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: ai-service
      template:
        metadata:
          labels:
            app: ai-service
            azure.workload.identity/use: "true"
        spec:
          serviceAccountName: $SERVICE_ACCOUNT_NAME
          nodeSelector:
            "kubernetes.io/os": linux
          containers:
          - name: ai-service
            image: ghcr.io/azure-samples/aks-store-demo/ai-service:latest
            ports:
            - containerPort: 5001
            env:
            - name: USE_AZURE_OPENAI
              value: "True"
            - name: USE_AZURE_AD
              value: "True"
            - name: AZURE_OPENAI_DEPLOYMENT_NAME
              value: "${AOAI_DEPLOYMENT_NAME}"
            - name: AZURE_OPENAI_ENDPOINT
              value: "${AOAI_ENDPOINT}"
            resources:
              requests:
                cpu: 20m
                memory: 50Mi
              limits:
                cpu: 50m
                memory: 128Mi
    EOF
    ```

### Test the application

1. Verify the new pod is running using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```azurecli
    kubectl get pods --selector app=ai-service
    ```
2. Get the pod environment variables using the [`kubectl describe pod`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command. The output demonstrates that the Azure OpenAI API key no longer exists in the Pod's environment variables.

    ```azurecli
    kubectl describe pod --selector app=ai-service
    ```
3. Open a new terminal and get the IP of the store admin service using the following `echo` command.

    ```azurecli
    echo "http://$(kubectl get svc/store-admin -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
    ```
4. Open a web browser and navigate to the IP address from the previous step.
5. Select **Products**. You should be able to add a new product and get a description for it using Azure OpenAI.