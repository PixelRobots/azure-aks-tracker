---
layout: Conceptual
title: Using Webhooks to Respond to Registry Actions in Azure - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-webhook
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
description: Learn how to use webhooks to trigger events when push or pull actions occur in your registry repositories.
ms.topic: how-to
ms.date: 2026-10-15T00:00:00.0000000Z
ai-usage: ai-assisted
ms.custom:
- devx-track-azurecli
- sfi-image-nochange
locale: en-us
document_id: 5f76a789-abd7-e24b-216c-ecc8bb7754b1
document_version_independent_id: c704537a-206f-c06b-7dd5-a0503738cd14
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-webhook.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/container-registry-webhook
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-webhook.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: dd2304a1-a3e4-a889-e550-04141fa66ff1
---

# Using Webhooks to Respond to Registry Actions in Azure - Azure Container Registry | Microsoft Learn

An Azure container registry stores and manages private Docker container images, similar to the way Docker Hub stores public Docker images. It can also host repositories for [Helm charts](container-registry-helm-repos) (preview), a packaging format to deploy applications to Kubernetes. You can use webhooks to trigger events when certain actions take place in one of your registry repositories. Webhooks can respond to events at the registry level, or they can be scoped down to a specific repository tag. With a [geo-replicated](container-registry-geo-replication) registry, you configure each webhook to respond to events in a specific regional replica.

The endpoint for a webhook must be publicly accessible from the registry. You can configure registry webhook requests to authenticate to a secured endpoint.

For details on webhook requests, see [Azure Container Registry webhook schema reference](container-registry-webhook-reference).

Important

Use HTTPS, and send webhook credentials only in the `Authorization` header. Azure Container Registry masks the `Authorization` header value in the webhook event history. It doesn't mask credentials in the service URI, in other custom headers, or in request or response bodies.

Don't include passwords, access tokens, API keys, or other secrets anywhere in the service URI. This restriction includes credentials before the host name (for example, `https://user:password@host`), the path, and the query string. It also includes signed callback URLs that contain authentication tokens in their query strings. Don't include secrets in any custom header other than `Authorization`. For more information, see Protect webhook credentials.

## Prerequisites

- Azure container registry - Create a container registry in your Azure subscription. For example, use the [Azure portal](container-registry-get-started-portal) or the [Azure CLI](container-registry-get-started-azure-cli). The [Azure Container Registry service tiers](container-registry-skus) have different webhooks quotas.
- Docker CLI - To set up your local computer as a Docker host and access the Docker CLI commands, install [Docker Engine](https://docs.docker.com/engine/install/).

## Create webhook - Azure portal

1. Sign in to the [Azure portal](https://portal.azure.com).
2. Navigate to the container registry in which you want to create a webhook.
3. Under **Services**, select **Webhooks**.
4. Select **Add** in the webhook toolbar.
5. Complete the *Create webhook* form with the following information:

| Value | Description |
| --- | --- |
| Webhook name | The name you want to give to the webhook. It may contain only letters and numbers, and must be 5-50 characters in length. |
| Location | For a [geo-replicated](container-registry-geo-replication) registry, specify the Azure region of the registry replica. |
| Service URI | The HTTPS URI where the webhook should send POST notifications. Don't include passwords, access tokens, API keys, or other secrets anywhere in the URI. This rule applies to credentials before the host name (for example, `https://user:password@host`), the path, and the query string. |
| Custom headers | Headers you want to pass along with the POST request. They should be in "key: value" format. Send credentials only in the `Authorization` header. Don't include passwords, access tokens, API keys, or other secrets in any other header. Only the `Authorization` header value is masked in the webhook event history. |
| Trigger actions | Actions that trigger the webhook. Actions include image push, image delete, Helm chart push, Helm chart delete, and image quarantine. You can choose one or more actions to trigger the webhook. |
| Status | The status for the webhook after it's created. It's enabled by default. |
| Scope | The scope at which the webhook works. If not specified, the scope is for all events in the registry. It can be specified for a repository or a tag by using the format "repository:tag", or "repository:\*" for all tags under a repository. |

Example webhook form:

![Screenshot that shows the ACR webhook creation U I in the Azure portal.](media/container-registry-webhook/webhook.png)

## Create webhook - Azure CLI

To create a webhook using the Azure CLI, use the [az acr webhook create](/en-us/cli/azure/acr/webhook#az-acr-webhook-create) command. The following command creates a webhook for all image delete events in the registry *mycontainerregistry*:

```azurecli
az acr webhook create --registry mycontainerregistry --name myacrwebhook01 --actions delete --uri https://webhookuri.com --headers "Authorization=$WEBHOOK_AUTH"
```

## Protect webhook credentials

Azure Container Registry stores the webhook configuration and records the requests that it sends to your endpoint, together with the responses, in the webhook event history. To reduce the risk of exposing credentials, follow these guidelines:

- Use an HTTPS service URI. Don't send credentials over HTTP.
- Send credentials only in the `Authorization` header. In the webhook event history, Azure Container Registry masks the `Authorization` header value in recorded request and response headers.
- Don't put credentials anywhere else. Azure Container Registry doesn't mask these values in the webhook event history:
    - The service URI, including credentials before the host name (for example, `https://user:password@host`), the path, and the query string.
    - Custom headers other than `Authorization`.
    - Request and response bodies.
- Ensure that your endpoint doesn't echo credentials in its response body or in response headers other than `Authorization`.
- Don't rely on encoding to hide credentials. URL encoding, Base64 encoding, and shell quoting don't protect a secret.
- Limit who can read webhook configuration. Users with the `Microsoft.ContainerRegistry/registries/webhooks/getCallbackConfig/action` permission can read the configured service URI and all custom headers, including the unmasked `Authorization` header value. Users with the `Microsoft.ContainerRegistry/registries/webhooks/listEvents/action` permission can read the webhook event history but can't view the unmasked `Authorization` header value. Built-in roles such as Owner and Contributor include these permissions.
- If a credential was previously included in the service URI, in another custom header, or in a request or response body, revoke or rotate that credential.

## Test webhook

### Azure portal

Prior to using the webhook, you can test it with the **Ping** button. Ping sends a generic POST request to the specified endpoint and logs the response. Using the ping feature can help you verify you've correctly configured the webhook.

1. Select the webhook you want to test.
2. In the top toolbar, select **Ping**.
3. Check the endpoint's response in the **HTTP STATUS** column.

![ACR webhook creation UI in the Azure portal](media/container-registry-webhook/webhook-02.png)

### Azure CLI

To test an ACR webhook with the Azure CLI, use the [az acr webhook ping](/en-us/cli/azure/acr/webhook#az-acr-webhook-ping) command.

```azurecli
az acr webhook ping --registry mycontainerregistry --name myacrwebhook01
```

To see the results, use the [az acr webhook list-events](/en-us/cli/azure/acr/webhook) command.

```azurecli
az acr webhook list-events --registry mycontainerregistry08 --name myacrwebhook01
```

## Delete webhook

### Azure portal

Each webhook can be deleted by selecting the webhook and then the **Delete** button in the Azure portal.

### Azure CLI

```azurecli
az acr webhook delete --registry mycontainerregistry --name myacrwebhook01
```