---
layout: Conceptual
title: 'Quickstart: Deploy a model with AI Manager (preview) - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-manager/quickstart
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Create an AI Manager, deploy a model, and send an inference request with the Azure CLI.
ai-usage: ai-assisted
author: asabbour
ms.author: asabbour
ms.topic: quickstart
ms.date: 2026-10-13T00:00:00.0000000Z
ms.custom: devx-track-azurecli
zone_pivot_groups: azure-portal-azure-cli
locale: en-us
document_id: ab7d43f4-504e-6403-4daa-d24ec114c25c
document_version_independent_id: c8e6f22d-5597-6e3f-f230-2fb759789d78
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-manager/quickstart.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/ai-manager/quickstart
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-manager/quickstart.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 88887e14-f82d-8273-4625-3b0f5a1362f6
---

# Quickstart: Deploy a model with AI Manager (preview) - Azure Kubernetes Service | Microsoft Learn

In this quickstart, you create an AI Manager with a managed AKS cluster, add a namespace, deploy a supported model from the regional catalog, and send a chat completion request.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Before you begin

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- A location supported by the AI Manager public preview.
- If you have multiple Azure subscriptions, select the subscription to use by using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.
- `curl`, to send an inference request. Azure Cloud Shell includes `curl`.
- The permissions in the following table.

    | Task | Role or permission | Notes |
    | --- | --- | --- |
    | Register preview features and resource providers | **Contributor** or **Owner** at the subscription scope | These roles include the required permissions. |
    | Create an AI Manager and its child resources | A role that can create these resources | For role choices and scopes, see [Grant access to AI Manager](grant-access). |
    | Read model catalog entries and calculate deployment costs | **Azure AIManager Model User** | Assign the role at the subscription scope or another applicable parent scope. |
    | Create and delete the dedicated resource group | Permission to create and delete resource groups | The resource group is used only for this quickstart. |

::: zone pivot="azure-cli"

## Install the AI Manager CLI extension

Install the `aimanager` Azure CLI extension, or update it to the latest version, by using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command. All published versions of the extension are previews, so include `--allow-preview true`.

```azurecli
az extension add --name aimanager --upgrade --allow-preview true
```

## Register the AI Manager preview feature

Register the `AIManagerPreview` feature flag by using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

```azurecli
az feature register --namespace Microsoft.ContainerService --name AIManagerPreview
```

Verify the registration status by using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*. If the status is *Pending*, the preview requires approval. Don't continue until the status is *Registered*.

```azurecli
az feature show --namespace Microsoft.ContainerService --name AIManagerPreview --query properties.state --output tsv
```

When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider by using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

```azurecli
az provider register --namespace Microsoft.ContainerService
```

Note

If a later `az aimanager create` command reports that the `AIManagerPreview` feature flag isn't registered, wait a few minutes for the resource provider registration to finish, and then try again.

## Define environment variables

Define the following environment variables for use throughout this quickstart. Replace `<supported-region>` with a location supported by the AI Manager public preview.

```bash
export RANDOM_STRING=$(printf '%05d%05d' "$RANDOM" "$RANDOM")
export SUBSCRIPTION_ID=$(az account show --query id --output tsv)
export LOCATION="<supported-region>"
export RESOURCE_GROUP="myAIManagerResourceGroup$RANDOM_STRING"
export MANAGER_NAME="myaimanager$RANDOM_STRING"
export NAMESPACE_NAME="quickstart"
export DEPLOYMENT_NAME="demo-model"
```

The `RANDOM_STRING` variable stores a random 10-digit string. The `RESOURCE_GROUP` and `MANAGER_NAME` values include it to create unique names. The `SUBSCRIPTION_ID` variable stores the ID of your current subscription. AI Manager, namespace, and model deployment names can contain only lowercase letters, numbers, and hyphens.

## Choose a model

List the catalog models that are available in your location by using the [`az aimanager model list`](/en-us/cli/azure/aimanager/model#az-aimanager-model-list) command.

```azurecli
az aimanager model list --location "$LOCATION" --output table
```

Choose a model by its readable `ModelId`. Store its matching `Name` value, which is the model's ARM resource name, in the `MODEL_NAME` variable.

```azurecli
export MODEL_NAME="<name-from-the-list>"
```

## Choose a GPU VM size

Compare GPU plans for the model by using the [`az aimanager model calculate-cost`](/en-us/cli/azure/aimanager/model#az-aimanager-model-calculate-cost) command. The calculator estimates VM cost per model replica, not the full deployment cost. For more information about GPU plans, quota, and what the estimate includes, see [Choose a model and estimate deployment cost](estimate-cost).

```azurecli
az aimanager model calculate-cost --location "$LOCATION" --name "$MODEL_NAME" --output table
```

Choose a plan where `Feasible` is `True`, and store its `VmSize` value in the `VM_SIZE` variable.

```azurecli
export VM_SIZE="<vm-size-from-a-feasible-plan>"
```

## Create a resource group

Create a resource group by using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```azurecli
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
```

## Create an AI Manager

Create an AI Manager by using the [`az aimanager create`](/en-us/cli/azure/aimanager#az-aimanager-create) command. The AI Manager provisions and manages an AKS cluster for your model deployments, so the command can take several minutes to finish.

```azurecli
az aimanager create --resource-group "$RESOURCE_GROUP" --name "$MANAGER_NAME" --location "$LOCATION"
```

## Create a namespace

Create a namespace in the AI Manager by using the [`az aimanager namespace create`](/en-us/cli/azure/aimanager/namespace#az-aimanager-namespace-create) command.

```azurecli
az aimanager namespace create --resource-group "$RESOURCE_GROUP" --aimanager "$MANAGER_NAME" --name "$NAMESPACE_NAME"
```

## Deploy a model

Create a model deployment that runs one replica by using the [`az aimanager namespace modeldeployment create`](/en-us/cli/azure/aimanager/namespace/modeldeployment#az-aimanager-namespace-modeldeployment-create) command. The command waits until the deployment is ready, which can take several minutes or longer.

```azurecli
az aimanager namespace modeldeployment create \
  --resource-group "$RESOURCE_GROUP" \
  --aimanager "$MANAGER_NAME" \
  --namespace "$NAMESPACE_NAME" \
  --name "$DEPLOYMENT_NAME" \
  --model-resource-id "/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.ContainerService/locations/$LOCATION/aiModels/$MODEL_NAME" \
  --vm-size "$VM_SIZE" \
  --replicas 1
```

Verify the deployment by using the [`az aimanager namespace modeldeployment show`](/en-us/cli/azure/aimanager/namespace/modeldeployment#az-aimanager-namespace-modeldeployment-show) command. The deployment is ready when `ProvisioningState` is `Succeeded` and `Replicas` is `1/1`. If the state is `Failed` or `Canceled`, run the command without `--output table` to inspect the full resource.

```azurecli
az aimanager namespace modeldeployment show \
  --resource-group "$RESOURCE_GROUP" \
  --aimanager "$MANAGER_NAME" \
  --namespace "$NAMESPACE_NAME" \
  --name "$DEPLOYMENT_NAME" \
  --output table
```

## Send an inference request

Use the `RESOURCE_GROUP`, `MANAGER_NAME`, `NAMESPACE_NAME`, and `DEPLOYMENT_NAME` variables from the previous sections.

1. Get the namespace endpoint and the primary namespace API key (`primaryKey`). Keep the key secret.

    ```azurecli
    export ENDPOINT="$(az aimanager namespace list-accesskeys \
      --resource-group "$RESOURCE_GROUP" \
      --aimanager "$MANAGER_NAME" \
      --name "$NAMESPACE_NAME" \
      --query endpoint \
      --output tsv)"
    
    export API_KEY="$(az aimanager namespace list-accesskeys \
      --resource-group "$RESOURCE_GROUP" \
      --aimanager "$MANAGER_NAME" \
      --name "$NAMESPACE_NAME" \
      --query primaryKey \
      --output tsv)"
    ```

    Confirm that both values are set. The command prints a message only if neither value is empty.

    ```azurecli
    test -n "$ENDPOINT" && test -n "$API_KEY" && echo "Endpoint and key retrieved."
    ```
2. Send a chat completion request. The `model` value is the **model deployment name** (`DEPLOYMENT_NAME`), not the catalog model ID.

    ```bash
    curl "$ENDPOINT/chat/completions" \
      --header "Authorization: Bearer $API_KEY" \
      --json @- <<EOF
    {
      "model": "$DEPLOYMENT_NAME",
      "messages": [
        { "role": "user", "content": "What does Kubernetes do?" }
      ]
    }
    EOF
    ```

    A successful request returns a JSON chat completion with a response under `choices[0].message.content`. The response text varies by model. For an OpenAI-compatible Python client, see [Connect an application to a model endpoint](connect-to-endpoint).

## Clean up resources

When you no longer need the resources, delete the resource group by using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command. Deleting the resource group deletes the AI Manager, its namespace and model deployment, and the AKS cluster that the AI Manager manages.

```azurecli
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
```

::: zone-end

::: zone pivot="azure-portal"

## Browse model catalog

Browse available models in your location by navigating to the **Kubernetes center** &gt; **AI workloads** &gt; **AI/ML**. You can filter models by collection, inference task, and provider.

[![A screenshot of the model catalog in Kubernetes center.](../media/ai-manager/model-catalog.png)](../media/ai-manager/model-catalog.png#lightbox)

You can preview model details such as provider, capability, and context length by selecting any model card in the catalog. Select **Deploy** to proceed.

## Select GPU VM size and deploy model

Under **Project details**, choose a subscription, resource group, and region to deploy your model in. Under **Deployment profile**, select whether to create a new AI Manager or use an existing one. You can also bring your own cluster for your AI Manager deployment.

Note

To be eligible for AI Manager deployments, existing clusters must run in the same region as your AI Manager deployment and use Kubernetes role-based access control (RBAC), system-assigned managed identity, and Cilium network dataplane.

A default recommended GPU VM size is based on the model you select. Choose **Select SKU** to compare different GPU VM sizes based on cost, available quota, and estimated performance.

[![A screenshot showing GPU sizes for model deployment.](../media/ai-manager/select-size.png)](../media/ai-manager/select-size.png#lightbox)

For more information about GPU plans, quota, and what the estimate includes, see [Choose a model and estimate deployment cost](estimate-cost).

After you deploy, monitor the provisioning status of your deployment by going to **AI/ML** &gt; **Deployments**. When your provisioning status is `Succeeded`, you can verify current endpoint and inference status by selecting **Check status**, as shown in the following image.

[![A screenshot of the deployment tab in AI/ML in Kubernetes center.](../media/ai-manager/deployment-grid.png)](../media/ai-manager/deployment-grid.png#lightbox)

## Test model

After your model is successfully provisioned, test its output by selecting the model and choosing **Test model** in the toolbar.

[![A screenshot of the test model function in the toolbar.](../media/ai-manager/test-model-toolbar.png)](../media/ai-manager/test-model-toolbar.png#lightbox)

This action opens the **Developer playground**, where you can experiment with your model output by adjusting vLLM parameters such as temperature and completion tokens.

[![A screenshot of the test model interface with a sample question and response.](../media/ai-manager/test-model.png)](../media/ai-manager/test-model.png#lightbox)

Note

Any parameter adjustments you make in the **Developer playground** are temporary and aren't saved.

## Send an inference request

1. Select your model deployment and go to **Overview** &gt; **Authentication** to view your namespace API keys.

    [![A screenshot of the api key location in Model Overview.](../media/ai-manager/api-key.png)](../media/ai-manager/api-key.png#lightbox)
2. Go to **Get started** to view code samples for a chat-completion request. Select **Open in VS Code Web** to directly edit or apply files in VS Code. Remember to replace the placeholder `api-key` with your primary namespace API key from the previous step.

    [![A screenshot of the Get Started tab with code samples.](../media/ai-manager/get-started.png)](../media/ai-manager/get-started.png#lightbox)

## Clean up resources

When you no longer need the resources, go to **AI/ML** &gt; **Deployments** and select the **AI Manager** that you want to delete. Select **Delete AI Manager** in the toolbar to proceed. You receive a summary of the resources to delete before confirming.

::: zone-end