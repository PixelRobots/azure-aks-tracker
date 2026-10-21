---
layout: Conceptual
title: Fine-tune and deploy an AI model on Azure Kubernetes Service (AKS) with the AI toolchain operator add-on - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator-fine-tune
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
description: Learn how to fine-tune and deploy a language model with the AI toolchain operator add-on on your AKS cluster.
ms.topic: how-to
ms.author: schaffererin
author: schaffererin
ms.custom: aks-ai-ml
ms.date: 2026-09-12T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: e1d8fe7d-e6b6-29b1-5ba8-9f532587578b
document_version_independent_id: 91754425-85a3-6471-f194-f70fe8f55c68
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-toolchain-operator-fine-tune.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/ai-toolchain-operator-fine-tune
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-toolchain-operator-fine-tune.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: b4359f61-ce59-2475-450e-dfc71e67b9c3
---

# Fine-tune and deploy an AI model on Azure Kubernetes Service (AKS) with the AI toolchain operator add-on - Azure Kubernetes Service | Microsoft Learn

This article shows you how to fine-tune and deploy a language model inferencing workload on AKS with the AI toolchain operator add-on. You learn how to accomplish the following tasks:

- Set environment variables to reference your Azure Container Registry (ACR) and repository details.
- Create your container registry image push/pull secret to store and retrieve private fine-tuning adapter images.
- Select a supported model and fine-tune it to your data.
- Test the inference service endpoint.
- Clean up resources.

The AI toolchain operator (KAITO) is a managed add-on for AKS that simplifies the deployment and operations for AI models on your AKS clusters. You can use the AKS managed add-on to fine-tune supported foundation models with new data and enhance the accuracy of your AI models. To learn more about parameter efficient fine-tuning methods and their use cases, see [Concepts - Fine-tuning language models for AI and machine learning workflows on AKS](concepts-fine-tune-language-models).

## Before you begin

- This article assumes you have an existing AKS cluster. If you don't have a cluster, create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).
- Azure CLI version 2.47.0 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Prerequisites

- The Kubernetes command-line client, kubectl, installed and configured. For more information, see [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- Configure [Azure Container Registry (ACR) integration](aks-extension-attach-azure-container-registry) of a new or existing ACR with your AKS cluster.
- Install the [AI toolchain operator add-on](ai-toolchain-operator) on your AKS cluster.
- If you already have the AI toolchain operator add-on installed, update your AKS cluster to the latest version and ensure that the AI toolchain operator add-on feature flag is enabled.

## Export environmental variables

To simplify the configuration steps in this article, you can define environment variables using the following commands. Make sure to replace the placeholder values with your own.

```azurecli
ACR_NAME="myACRname"
ACR_USERNAME="myACRusername"
REPOSITORY="myRepository"
VERSION="repositoryVersion'
ACR_PASSWORD=$(az acr token create --name $ACR_USERNAME --registry $ACR_NAME --expiration-in-days 10 --repository $REPOSITORY content/write content/read --query "credentials.passwords[0].value" --output tsv)
```

## Create a new secret for your private registry

In this example, your KAITO fine-tuning deployment produces a containerized adapter output, and the KAITO workspace requires a new push secret as authorization to push the adapter image to your ACR.

Generate a new secret to provide the KAITO fine-tuning workspace access to push the model fine-tuning output image to your ACR using the `kubectl create secret docker-registry` command.

```bash
kubectl create secret docker-registry myregistrysecret --docker-server=$ACR_NAME.azurecr.io --docker-username=$ACR_USERNAME --docker-password=$ACR_PASSWORD
```

## Fine-tune an AI model

In this example, you fine-tune the [Phi-3-mini small language model](https://huggingface.co/docs/transformers/main/en/model_doc/phi3) using the qLoRA tuning method by applying the following Phi-3-mini KAITO fine-tuning workspace CRD:

```yaml
apiVersion: kaito.sh/v1beta1
kind: Workspace
metadata:
  name: workspace-tuning-phi-3-mini
resource:
  instanceType: "Standard_NC24ads_A100_v4"
  labelSelector:
    matchLabels:
      apps: tuning-phi-3-mini-pycoder
tuning:
  preset:
    name: phi-3-mini-128k-instruct
  method: qlora
  input:
    urls:
      - "myDatasetURL"
  output:
    image: "$ACR_NAME.azurecr.io/$REPOSITORY:$VERSION"
    imagePushSecret: myregistrysecret
```

This example uses a public dataset specified by a URL in the input. If choosing an image as the source of your fine-tuning data, please refer to the [KAITO fine-tuning API](https://github.com/kaito-project/kaito/tree/main) specification to adjust the input to pull an image from your ACR.

Note

The choice of GPU SKU is critical since model fine-tuning normally requires more GPU memory compared to model inference. To avoid GPU Out-Of-Memory errors, we recommend using NVIDIA A100 or higher tier GPUs.

1. Apply the KAITO fine-tuning workspace CRD using the `kubectl apply` command.

    ```bash
    kubectl apply -f workspace-tuning-phi-3-mini.yaml
    ```
2. Track the readiness of your GPU resources, fine-tuning job, and workspace using the `kubectl get workspace` command.

    ```bash
    kubectl get workspace -w
    ```

    Your output should look similar to the following example output:

    ```output
    NAME                         INSTANCE                  RESOURCE READY  INFERENCE READY  JOB STARTED  WORKSPACE SUCCEEDED  AGE
    workspace-tuning-phi-3-mini  Standard_NC24ads_A100_v4  True                             True                              3m 45s
    ```
3. Check the status of your fine-tuning job pods using the `kubectl get pods` command.

    ```bash
    kubectl get pods
    ```

Note

You can store the adapter to your specific output location as a container image or any storage type supported by Kubernetes.

## Deploy the fine-tuned model for inferencing

Now, you use the Phi-3-mini adapter image created in the previous section for a new inferencing deployment with this model.

The KAITO inference workspace CRD below consists of the following resources and adapter(s) to deploy on your AKS cluster:

```yaml
apiVersion: kaito.sh/v1beta1
kind: Workspace
metadata:
  name: workspace-phi-3-mini-adapter
resource:
  instanceType: "Standard_NC24ads_A100_v4"
  labelSelector:
    matchLabels:
      apps: phi-3-adapter
inference:
  preset:
    name: "phi-3-mini-128k-instruct"
  adapters:
    - source:
        name: kubernetes-adapter
        image: $ACR_NAME.azurecr.io/$REPOSITORY:$VERSION
        imagePullSecrets:
          - myregistrysecret
      strength: "1.0"
```

Note

Optionally, you can pull in several adapters created from fine-tuning deployments with the same model on different data sets by defining additional "source" fields. Inference with different adapters to compare the performance of your fine-tuned model in varying contexts.

1. Apply the KAITO inference workspace CRD using the `kubectl apply` command.

    ```bash
    kubectl apply -f workspace-phi-3-mini-adapter.yaml
    ```
2. Track the readiness of your GPU resources, inference server, and workspace using the `kubectl get workspace` command.

    ```bash
    kubectl get workspace -w
    ```

    Your output should look similar to the following example output:

    ```output
    NAME                          INSTANCE                   RESOURCE READY  INFERENCE READY  JOB STARTED  WORKSPACE SUCCEEDED  AGE
    workspace-phi-3-mini-adapter  Standard_NC24ads_A100_v4   True            True                          True                 5m 47s
    ```
3. Check the status of your inferencing workload pods using the `kubectl get pods` command.

    ```bash
    kubectl get pods
    ```

    It might take several minutes for your pods to show the `Running` status.

## Test the model inference service endpoint

1. Check your model inferencing service and retrieve the service IP address using the `kubectl get svc` command.

    ```bash
    export SERVICE_IP=$(kubectl get svc workspace-phi-3-mini-adapter -o jsonpath='{.spec.clusterIP}')
    ```
2. Run your fine-tuned Phi-3-mini model with a sample input of your choice using the `kubectl run` command. The following example asks the generative AI model, *"What is AKS?"*:

    ```bash
    kubectl run -it --rm --restart=Never curl --image=curlimages/curl -- curl -X POST http://$SERVICE_IP/chat -H "accept: application/json" -H "Content-Type: application/json" -d "{\"prompt\":\"What is AKS?\"}"
    ```

    Your output might look similar to the following example output:

    ```output
    "Kubernetes on Azure" is the official name.
    https://learn.microsoft.com/azure/aks/ ...
    ```

## Clean up resources

If you no longer need these resources, you can delete them to avoid incurring extra Azure charges. To calculate the estimated cost of your resources, you can use the [Azure pricing calculator](https://azure.microsoft.com/pricing/calculator/?service=kubernetes-service).

Delete the KAITO workspaces and their allocated resources on your AKS cluster using the `kubectl delete workspace` command.

```bash
kubectl delete workspace workspace-tuning-phi-3-mini
kubectl delete workspace workspace-phi-3-mini-adapter
```