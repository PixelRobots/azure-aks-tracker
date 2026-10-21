---
layout: Conceptual
title: Onboard custom models for inferencing with the AI toolchain operator (KAITO) on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kaito-custom-inference-model
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
description: Learn how to onboard custom models for inferencing with the AI toolchain operator (KAITO) on AKS.
ms.topic: how-to
ms.custom: azure-kubernetes-service, aks-ai-ml
ms.date: 2026-09-12T00:00:00.0000000Z
ai-usage: ai-assisted
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 793b6519-40f3-4f94-482d-88b30ecda8ee
document_version_independent_id: 42fb92e7-1305-f618-6db3-7e3572c80f33
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kaito-custom-inference-model.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/kaito-custom-inference-model
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kaito-custom-inference-model.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ed66bdf4-ebd6-573a-4cd5-7e55bf7327de
---

# Onboard custom models for inferencing with the AI toolchain operator (KAITO) on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

As an AI engineer or developer, you might need to prototype and deploy AI workloads with a range of different model weights. AKS provides the option to deploy inferencing workloads by using open-source presets that the KAITO [model catalog](https://kaito-project.github.io/kaito/docs/presets) supports and manages out of the box, or to dynamically download models from the [HuggingFace registry](https://huggingface.co/models) at runtime onto your AKS cluster.

In this article, you learn how to onboard a sample HuggingFace model for inferencing with the AI toolchain operator add-on without having to manage custom images on Azure Kubernetes Service (AKS).

## Prerequisites

- An Azure account with an active subscription. If you don't have an account, you can [create one for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- An AKS cluster with the AI toolchain operator add-on enabled. For more information, see [Enable KAITO on an AKS cluster](ai-toolchain-operator#enable-the-ai-toolchain-operator-add-on-on-an-aks-cluster).
- Quota for the `Standard_NVadsA10_v5` virtual machine (VM) family in your Azure subscription. If you don't have quota for this VM family, [request a quota increase](/en-us/azure/quotas/quickstart-increase-quota-portal).

    Note

    Currently, only the HuggingFace runtime supports inference with the KAITO custom model deployment template.

## Choose an open-source language model from HuggingFace

In this example, we use the [HuggingFaceTB SmolLM2-1.7B-Instruct](https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B-Instruct) small language model. Alternatively, you can choose from thousands of text-generation models supported on [HuggingFace](https://huggingface.co/models?pipeline_tag=text-generation).

1. Connect to your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
    ```
2. Clone the KAITO project GitHub repository using the `git clone` command.

    ```bash
    git clone https://github.com/kaito-project/kaito.git
    ```

## Deploy your model inferencing workload using the KAITO workspace template

1. Navigate to the `kaito` directory and copy the [sample deployment YAML](https://github.com/kaito-project/kaito/tree/main/examples/custom-model-integration/custom-model-deployment.yaml) manifest. Replace the default values in the following fields with your model's requirements:

    - `instanceType`: The VM size for your inference service deployment. For larger model sizes you can choose a VM in the [`Standard_NCads_A100_v4`](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nca100v4-series) family with higher memory capacity.
    - `MODEL_ID`: Your model's specific HuggingFace identifier, which can be found after `https://huggingface.co/` in the model card URL.
    - `"--torch_dtype"`: Set to `"bfloat16"`, which is supported on all GPU SKUs that KAITO supports.
    - For this example, use `Standard_NV36ads_A10_v5` as the instance type and the [HuggingFaceTB SmolLM2-1.7B-Instruct](https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B-Instruct) model.

    ```yml
    apiVersion: kaito.sh/v1beta1
    kind: Workspace
    metadata:
      name: workspace-custom-llm
    resource:
      instanceType: "Standard_NV36ads_A10_v5" # Required VM SKU based on model requirements
      labelSelector:
        matchLabels:
          apps: custom-llm
    inference:
      template:
        spec:
          containers:
            - name: custom-llm-container
              image: mcr.microsoft.com/aks/kaito/kaito-base:0.2.0 # KAITO base image which includes hf runtime
              livenessProbe:
                failureThreshold: 3
                httpGet:
                  path: /health
                  port: 5000
                  scheme: HTTP
                initialDelaySeconds: 600
                periodSeconds: 10
                successThreshold: 1
                timeoutSeconds: 1
              readinessProbe:
                failureThreshold: 3
                httpGet:
                  path: /health
                  port: 5000
                  scheme: HTTP
                initialDelaySeconds: 30
                periodSeconds: 10
                successThreshold: 1
                timeoutSeconds: 1
              resources:
                requests:
                  nvidia.com/gpu: 1  # Request 1 GPU; adjust as needed
                limits:
                  nvidia.com/gpu: 1  # Optional: Limit to 1 GPU
              command:
                - "accelerate"
              args:
                - "launch"
                - "--num_processes"
                - "1"
                - "--num_machines"
                - "1"
                - "--gpu_ids"
                - "all"
                - "tfs/inference_api.py"
                - "--pipeline"
                - "text-generation"
                - "--trust_remote_code"
                - "--allow_remote_files"
                - "--pretrained_model_name_or_path"
                - "HuggingFaceTB/SmolLM2-1.7B-Instruct" # The model's HuggingFace identifier
                - "--torch_dtype"
                - "bfloat16"
              volumeMounts:
                - name: dshm
                  mountPath: /dev/shm
          volumes:
          - name: dshm
            emptyDir:
              medium: Memory
    ```
2. Save these changes to your `custom-model-deployment.yaml` file.
3. Run the deployment in your AKS cluster using the `kubectl apply` command.

    ```bash
    kubectl apply -f custom-model-deployment.yaml
    ```

## Test your custom model inferencing service

1. Track the live resource changes in your KAITO workspace using the `kubectl get workspace` command.

    ```bash
    kubectl get workspace workspace-custom-llm -w
    ```

    Note

    Note that machine readiness can take *up to 10 minutes*, and workspace readiness *up to 20 minutes*. Proceed to the next step only once the workspace status shows `Ready`.
2. Once the workspace is ready, port forward the inference service to your local machine in a separate terminal.

    ```bash
    kubectl port-forward svc/workspace-custom-llm 5000:80
    ```
3. Install the OpenAI Python client.

    ```bash
    pip install openai
    ```
4. Save the following script as `test_inference.py` and run it using `python test_inference.py`:

    ```python
    from openai import OpenAI
    
    client = OpenAI(
        base_url="http://127.0.0.1:5000/v1",
        api_key="unused",
    )
    
    response = client.chat.completions.create(
        model="workspace-custom-llm",
        messages=[{"role": "user", "content": "What sport should I play in rainy weather?"}],
        max_tokens=400,
        stream=True,
    )
    
    print("".join(chunk.choices[0].delta.content or "" for chunk in response))
    ```

## Clean up resources

If you no longer need these resources, you can delete them to avoid incurring extra Azure compute charges.

Delete the KAITO inference workspace using the `kubectl delete workspace` command.

```bash
kubectl delete workspace workspace-custom-llm
```