---
layout: Conceptual
title: Connect an application to an AI Manager model endpoint by using Microsoft Entra ID (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-manager/connect-to-endpoint-entra-id
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Use a Microsoft Entra ID token and an OpenAI-compatible client to send chat completion requests to an AI Manager model deployment.
ai-usage: ai-assisted
author: asabbour
ms.author: asabbour
ms.topic: how-to
ms.date: 2026-10-20T00:00:00.0000000Z
ms.custom: devx-track-azurecli
locale: en-us
document_id: fc6433eb-2709-113d-e04e-6eab6e0825d2
document_version_independent_id: dc9fec4d-b0f8-a8e3-81d3-e274218c2438
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-manager/connect-to-endpoint-entra-id.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/ai-manager/connect-to-endpoint-entra-id
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-manager/connect-to-endpoint-entra-id.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/b1cfdec6-b0c3-4209-818c-736879856e0e
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/2d0723c1-cf38-4c30-ab3d-5df787b33270
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
platformId: b3a4d0fa-ee2d-44d8-7797-a58aece5a9dc
---

# Connect an application to an AI Manager model endpoint by using Microsoft Entra ID (preview) - Azure Kubernetes Service | Microsoft Learn

Use a Microsoft Entra ID token instead of a namespace API key to send requests to a model deployment through the namespace endpoint. Azure role assignments control access, so you don't need to store or rotate API keys. This article shows how to send a request with `curl` and with the OpenAI Python client.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Before you begin

- A model deployment whose `provisioningState` is `Succeeded`. To check the state, see [Manage model deployments](manage-deployments).
- The AI Manager extension for the Azure CLI. To install it or update an older version, run `az extension add --name aimanager --upgrade --allow-preview true`.
- The **Azure AIManager Inference User** role for the user or application that sends requests, at the namespace scope or at the AI Manager scope to cover all its namespaces. This role grants the inference data action that Microsoft Entra ID requests require. **Azure AIManager User** and **Azure AIManager Contributor** don't grant it. To assign the role, see [Grant access to AI Manager](grant-access).
- For the Python example, Python and the `openai` and `azure-identity` packages.

## Get the endpoint

1. Sign in with the account that has the **Azure AIManager Inference User** role, and select the subscription that contains the AI Manager. The token must come from that subscription's Microsoft Entra tenant.

    ```azurecli
    az login
    az account set --subscription "<subscription-id>"
    ```
2. Set variables for your resources.

    ```azurecli
    export RESOURCE_GROUP="<resource-group>"
    export MANAGER_NAME="<ai-manager-name>"
    export NAMESPACE_NAME="<namespace-name>"
    export DEPLOYMENT_NAME="<model-deployment-name>"
    ```
3. Get the namespace endpoint by using the [`az aimanager namespace list-accesskeys`](/en-us/cli/azure/aimanager/namespace#az-aimanager-namespace-list-accesskeys) command. The command also returns the namespace API keys, and the `--query` option keeps only the endpoint.

    ```azurecli
    export ENDPOINT=$(az aimanager namespace list-accesskeys \
      --resource-group "$RESOURCE_GROUP" \
      --aimanager "$MANAGER_NAME" \
      --name "$NAMESPACE_NAME" \
      --query endpoint \
      --output tsv)
    ```

## Send a request with curl

1. Get an access token by using the [`az account get-access-token`](/en-us/cli/azure/account#az-account-get-access-token) command. By default, the command returns a token for Azure Resource Manager (`https://management.core.windows.net/`), which is the audience that the endpoint accepts.

    ```azurecli
    export ACCESS_TOKEN=$(az account get-access-token --query accessToken --output tsv)
    ```
2. Send a chat completion request. Set the `model` field to the model deployment name, not the catalog model ID.

    ```azurecli
    curl "$ENDPOINT/chat/completions" \
      --header "Authorization: Bearer $ACCESS_TOKEN" \
      --json @- <<EOF
    {
      "model": "$DEPLOYMENT_NAME",
      "messages": [
        { "role": "user", "content": "What does Kubernetes do?" }
      ]
    }
    EOF
    ```

    A successful request returns a JSON chat completion with the response under `choices[0].message.content`.

## Send a request with the OpenAI Python client

1. Install the `openai` and `azure-identity` packages.

    ```azurecli
    python -m pip install openai azure-identity
    ```
2. Get a token with `DefaultAzureCredential`, and pass it to the OpenAI client as the API key. On your computer, `DefaultAzureCredential` uses your Azure CLI sign-in. In Azure, it can use a managed identity that has the **Azure AIManager Inference User** role.

    ```python
    import os
    
    from azure.identity import DefaultAzureCredential
    from openai import OpenAI
    
    credential = DefaultAzureCredential()
    token = credential.get_token("https://management.core.windows.net//.default")
    
    client = OpenAI(
        api_key=token.token,
        base_url=os.environ["ENDPOINT"],
    )
    
    response = client.chat.completions.create(
        model=os.environ["DEPLOYMENT_NAME"],
        messages=[
            {"role": "user", "content": "What does Kubernetes do?"},
        ],
    )
    
    print(response.choices[0].message.content)
    ```

Access tokens expire, typically after about an hour. In a long-running application, get a new token before the current one expires, and create a new client with it.

## Troubleshoot authentication

If the endpoint rejects the request, check the following:

- **Token audience:** Get the token for `https://management.core.windows.net/`. A token for another resource, such as `https://management.azure.com/`, isn't accepted.
- **Tenant:** Get the token from the Microsoft Entra tenant of the subscription that contains the AI Manager.
- **Role assignment:** Confirm that the caller has **Azure AIManager Inference User** at the namespace or a parent scope. A new role assignment can take several minutes to take effect.