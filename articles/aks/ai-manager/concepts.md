---
layout: Conceptual
title: AI Manager concepts (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-manager/concepts
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
description: Learn how AI Manager organizes model deployments, cluster resources, and access.
ai-usage: ai-assisted
author: asabbour
ms.author: asabbour
ms.topic: concept-article
ms.date: 2026-10-13T00:00:00.0000000Z
locale: en-us
document_id: 44391a62-5a5b-bc62-96eb-5bf795294743
document_version_independent_id: 3f817a6e-7fa8-e66f-982e-2f5193ab34be
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-manager/concepts.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../toc.json
asset_id: aks/ai-manager/concepts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-manager/concepts.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 79eb0501-910c-ff41-1958-76a0b0e7be47
---

# AI Manager concepts (preview) - Azure Kubernetes Service | Microsoft Learn

AI Manager lets you deploy open-weight models on AKS and serve them through an OpenAI-compatible endpoint. You create an AI Manager, organize model deployments into namespaces, and base each deployment on a model from the regional catalog.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Resource model

[!\[Diagram of an AI Manager in a resource group. The AI Manager provisions a managed AKS cluster and contains N namespaces, each with M model deployments. Each model deployment deploys one Hugging Face model from the model catalog.\](../media/ai-manager/ai-manager-resource-model.svg)
 An Azure subscription contains a resource group and a model catalog. The resource group contains one AI Manager. The AI Manager provisions an AKS cluster for itself and contains N namespaces. Each namespace contains M model deployments. The model catalog contains Hugging Face models. An arrow from each model deployment shows that it deploys one model from the catalog.](../media/ai-manager/ai-manager-resource-model.svg#lightbox)

| Resource | Purpose |
| --- | --- |
| AI Manager | Top-level resource that provisions and manages the AKS infrastructure for model deployments. |
| Namespace | Child of an AI Manager that provides a logical boundary for organizing model deployments, such as by team or workload. |
| Model deployment | Child of a namespace. It deploys a catalog model and configures the VM size and scaling settings used to serve it. Runtime status can report the serving endpoint and current and desired replica counts. |
| Model source | A **ModelSource** (`Microsoft.ContainerService/AIManagers/ModelSources`) is a child resource of a Manager. It represents an external model registry (for example, Hugging Face) and stores the information required to pull models: repository URL, authentication credentials, and any provider-specific configuration. |
| AI model | A list of curated models from Hugging Face. |

## Set up an AI Manager and namespaces

A platform administrator with the `Azure AIManager Contributor` role creates the AI Manager, which provisions and manages the AKS cluster that hosts model deployments. The administrator then creates namespaces to separate teams or workloads. Each namespace has its own OpenAI-compatible endpoint and API keys, and it's the usual scope for granting access to model operators and application developers.

The AI Manager's delete policy (`properties.deletePolicy`) controls what happens to its AKS cluster when you delete the AI Manager. You can set it when you create or update the AI Manager:

- **`Delete`** (default): Deleting the AI Manager also deletes its AKS cluster and the managed resource group that holds the cluster.
- **`Keep`**: Deleting the AI Manager removes the AI Manager, namespace, and model deployment resources from Azure, but keeps the AKS cluster and its managed resource group. AI Manager stops managing the cluster, so you can manage it directly. The cluster keeps running and incurring charges until you delete it.

For more information, see [AI Manager properties](reference#ai-manager-properties).

To create an AI Manager and a namespace, see the [quickstart](quickstart#create-an-ai-manager). To give other people access, see [Grant access to AI Manager](grant-access#choose-a-role-and-scope).

## Deploy a model from the catalog

An application developer chooses a model from the regional catalog, picks a GPU VM size, and creates a model deployment in a namespace.

1. **Choose a model.** The catalog lists the models available to your subscription in a location. Each model has a readable model ID and a separate ARM resource name. See [List available models](estimate-cost#list-available-models).
2. **Choose a GPU.** The cost calculator compares VM sizes for the model. It shows whether each plan is feasible and its estimated hourly price per replica. See [Compare GPU plans and estimates](estimate-cost#compare-gpu-plans-and-estimates).
3. **Deploy.** Create a model deployment that uses the chosen model and VM size, with either a fixed replica count or an autoscale range. See [Manage model deployments](manage-deployments).

## Send inference requests to a deployment

An application developer uses a model deployment by sending OpenAI-compatible requests to the namespace endpoint.

[!\[Diagram of a POST /chat/completions request sent to a namespace endpoint, authorized with an API key or Microsoft Entra ID, and routed to an AI Manager model deployment by deployment name.\](../media/ai-manager/ai-manager-inference-flow.svg)
 Five numbered circles mark the request flow from left to right. The client sends `POST /chat/completions` to the namespace endpoint and authenticates with an API key or Microsoft Entra ID. After access is checked, the service selects the catalog model deployment by the deployment name in the request's `model` field. The request reaches the model runtime inside the AI Manager-managed AKS cluster, shown with the Azure Kubernetes Service icon. A `Completion response` arrow returns the result to the client.](../media/ai-manager/ai-manager-inference-flow.svg#lightbox)

The client sends a chat completion request to the namespace endpoint and identifies the target model deployment in the request's `model` field. AI Manager checks the caller's access, sends the request to that deployment, and returns the completion to the client. The field contains the model deployment name, not the catalog model ID.

You can authenticate an inference request with a namespace API key or a Microsoft Entra ID token. For Microsoft Entra ID authentication, Azure RBAC checks the inference data action, which the **Azure AIManager Inference User** role grants.

To get the endpoint and a key and send a first request, see [Connect an application to a model endpoint](connect-to-endpoint). To use a Microsoft Entra ID token instead of a key, see [Connect an application to an AI Manager model endpoint by using Microsoft Entra ID](connect-to-endpoint-entra-id).

## AI Manager identity and access

Azure RBAC separately controls resource management, catalog access, direct inference, and Kubernetes object access. A namespace API key provides another way to send inference requests. Anyone who obtains a namespace API key can use it without the inference data action. The **Azure AIManager User**, **Azure AIManager Contributor**, and **Azure AIManager Inference User** roles can list namespace API keys, so treat those assignments as access to inference credentials. A namespace API key doesn't grant general Kubernetes object access. Treat the primary key and the secondary key as secrets.

To grant another person or application a role, the person making the assignment also needs **User Access Administrator** or another role that can create role assignments. Azure AIManager Contributor doesn't grant this delegation permission.

| Role | Access |
| --- | --- |
| `Azure AIManager Contributor` | Grants read/write access to Azure resources provided by Azure AIManager, including aimanagers, deployments, namespace, and models. (Does not grant permissions for inference data actions, Kubernetes object access, or permission to assign roles to other users.) |
| `Azure AIManager User` | Reads AI Manager resources and can list credentials and namespace API keys, which grant API-key inference. It doesn't grant the inference data action. |
| `Azure AIManager Model User` | Reads model catalog entries and calculates deployment costs. Because catalog models are location-scoped, assign this role at the subscription or another applicable parent scope, not only at the AI Manager or resource group. |
| `Azure AIManager Inference User` | Grants the inference data action and allows listing namespace API keys. At the AI Manager scope, it applies across namespaces; a narrower supported scope limits access. It doesn't grant access to secrets or general Kubernetes objects. |
| `Azure AIManager RBAC Reader` | Reads Kubernetes objects except secrets, roles, and role bindings. |
| `Azure AIManager RBAC Admin` | Grants read and write access to Kubernetes objects. Reserve it for exceptional recovery, not routine access. |

The following personas describe common AI Manager tasks. One person can act as more than one persona, as in the [quickstart](quickstart).

- **Platform administrator:** Creates the AI Manager and its namespaces, and grants other people access to them.
- **Model operator:** Chooses a catalog model and GPU size, and creates and manages model deployments in a namespace.
- **Application developer:** Sends inference requests to model deployments from an application.

The following table lists the role assignments that each persona typically needs:

| Persona | Role | Scope | Used to |
| --- | --- | --- | --- |
| Platform administrator | `Azure AIManager Contributor` | Resource group | Create the AI Manager and its namespaces. |
| Platform administrator | `User Access Administrator` | AI Manager | Grant model operators and application developers access to the AI Manager and its namespaces. |
| Platform administrator | `User Access Administrator` | Subscription | Assign `Azure AIManager Model User` to model operators. Needed only for that assignment, because the model catalog is scoped to the subscription. |
| Platform administrator | `Azure AIManager RBAC Reader` (optional) | AI Manager | View Kubernetes objects, except secrets, to troubleshoot deployments. |
| Model operator | `Azure AIManager Contributor` | Namespace | Create, update, and delete model deployments in the namespace. |
| Model operator | `Azure AIManager Model User` | Subscription | List catalog models and compare GPU plans and costs. |
| Model operator | `Azure AIManager RBAC Reader` (optional) | Namespace | View Kubernetes objects in the namespace, except secrets, to troubleshoot a deployment that's slow or failed. |
| Application developer | `Azure AIManager Inference User` | Namespace | Get the namespace endpoint and API keys, and send inference requests with an API key or a Microsoft Entra ID token. |