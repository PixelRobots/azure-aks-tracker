---
layout: Conceptual
title: Connect an application to an AI Manager model endpoint by using an API key (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-manager/connect-to-endpoint
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
description: Use an OpenAI-compatible Python client and a namespace API key to send chat completion requests.
ai-usage: ai-assisted
author: asabbour
ms.author: asabbour
ms.topic: how-to
ms.date: 2026-10-13T00:00:00.0000000Z
locale: en-us
document_id: 64767f5f-7350-5ebe-e5fe-beb1aa8300a7
document_version_independent_id: 838fac70-e0ed-5725-97d8-38f3442429c7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-manager/connect-to-endpoint.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/ai-manager/connect-to-endpoint
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-manager/connect-to-endpoint.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
platformId: 18efe51d-0de5-b9d0-e5e6-770ff374c2bf
---

# Connect an application to an AI Manager model endpoint by using an API key (preview) - Azure Kubernetes Service | Microsoft Learn

Use an OpenAI-compatible client to send requests to a model deployment through the namespace endpoint. This article uses the OpenAI Python client and a namespace API key. To use Microsoft Entra ID instead, see [Connect an application to an AI Manager model endpoint by using Microsoft Entra ID](connect-to-endpoint-entra-id). For Azure RBAC role assignment, see [Grant access to AI Manager](grant-access).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Before you begin

- A model deployment whose `provisioningState` is `Succeeded` and that has at least one ready replica (`currentReplicas` greater than `0`). To check readiness, see the [quickstart](quickstart). For state meanings, see [Provisioning states](reference#provisioning-states).
- Azure CLI with access to the AI Manager CLI extension for the public preview.
- An Azure sign-in for a subscription that contains the AI Manager.
- Python and the `openai` package.
- Permission to list namespace API keys. **Azure AIManager Inference User** grants this permission with the least privilege. **Azure AIManager User** and **Azure AIManager Contributor** also include it. Assign the role at the namespace or a parent scope.

## Get the endpoint and key

1. Set variables for your resource group, AI Manager, and namespace.

    ```azurecli
    az login
    az account set --subscription "<subscription-id>"
    
    export RESOURCE_GROUP="<resource-group>"
    export MANAGER_NAME="<ai-manager-name>"
    export NAMESPACE_NAME="<namespace-name>"
    ```
2. Retrieve the namespace endpoint and the primary namespace API key (`primaryKey`). The namespace also has a `secondaryKey` that works the same way.

    ```bash
    export AI_MANAGER_ENDPOINT="$(az aimanager namespace list-accesskeys \
      --resource-group "$RESOURCE_GROUP" \
      --aimanager "$MANAGER_NAME" \
      --name "$NAMESPACE_NAME" \
      --query endpoint \
      --output tsv)"
    
    export AI_MANAGER_API_KEY="$(az aimanager namespace list-accesskeys \
      --resource-group "$RESOURCE_GROUP" \
      --aimanager "$MANAGER_NAME" \
      --name "$NAMESPACE_NAME" \
      --query primaryKey \
      --output tsv)"
    ```
3. Confirm that both values are set. The command prints a message only if neither value is empty.

    ```bash
    test -n "$AI_MANAGER_ENDPOINT" && test -n "$AI_MANAGER_API_KEY" && echo "Endpoint and key retrieved."
    ```

The `endpoint` value is the OpenAI-compatible base URL. Use it as returned, including any path component.

## Send a request with the OpenAI Python client

1. Install the `openai` package if it isn't already installed.

    ```bash
    python -m pip install openai
    ```
2. Set the `model` value to your model deployment name. Then use `AI_MANAGER_ENDPOINT` and `AI_MANAGER_API_KEY` from Get the endpoint and key to send a chat completion request.

    ```bash
    export AI_MANAGER_DEPLOYMENT="<model-deployment-name>"
    ```

    ```python
    import os
    
    from openai import OpenAI
    
    client = OpenAI(
        api_key=os.environ["AI_MANAGER_API_KEY"],
        base_url=os.environ["AI_MANAGER_ENDPOINT"],
    )
    
    response = client.chat.completions.create(
        model=os.environ["AI_MANAGER_DEPLOYMENT"],
        messages=[
            {"role": "user", "content": "What does Kubernetes do?"},
        ],
    )
    
    print(response.choices[0].message.content)
    ```

The request uses the following values:

- **`model` field:** The model deployment name. Don't use the model catalog's `modelId` value.
- **`Authorization: Bearer` header:** Carries the namespace API key. The OpenAI client sends it automatically.
- **`api-key` header:** Carries the namespace API key for clients that set headers directly.

A successful request prints the response text from `choices[0].message.content`. The text varies by model. For a request using `curl`, see the [AI Manager quickstart](quickstart).