---
layout: Conceptual
title: Train an LLM with Ray on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ray-train-llm
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
description: Learn how to fine-tune Qwen2.5-7B with LLaMA-Factory using distributed Ray training and Kueue on AKS.
ms.topic: how-to
ms.date: 2026-06-26T00:00:00.0000000Z
author: feiskyer
ms.author: peni
ms.custom: stateful-workloads
locale: en-us
document_id: 425e5fe6-911e-db37-030d-f25077c19704
document_version_independent_id: 149cc648-daa6-b61c-6215-0114b12354b2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ray-train-llm.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/ray-train-llm
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ray-train-llm.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 3679a98e-6276-c6bd-2e98-9a02d36a1e52
---

# Train an LLM with Ray on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you submit a RayJob that fine-tunes Qwen2.5-7B-Instruct on the viggo NLG dataset using [LLaMA-Factory](https://github.com/hiyouga/LLaMA-Factory) and distributed Ray Train. The job uses four workers with one GPU each, reads training data from Azure Blob Storage, and uploads the trained LoRA adapter for downstream inference.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Prerequisites

- Infrastructure deployed following [Deploy infrastructure for Ray and Kueue on AKS](deploy-ray-infrastructure).
- Kueue queues configured following [Configure Kueue queues for Ray workloads on AKS](configure-ray-kueue-queues).
- At least four A100 GPUs available in the cluster (this example uses four workers with one GPU each).
- Viggo dataset uploaded to blob storage at `llm-pipeline/data/` (done automatically by the infrastructure Terraform module).
- `envsubst` installed (`gettext` package on Linux, `brew install gettext` on macOS).

## Set environment variables

Navigate to the LLM training example in the cloned repository and configure the required environment variables:

```bash
cd <path-to-cloned-repo>/AKS/examples/kueue-and-ray-on-aks/3-workloads/llm-training
export AZURE_STORAGE_ACCOUNT_NAME=$(terraform -chdir=../../1-infrastructure/terraform output -raw storage_account_name)
source env.example
```

Note

If you configured team queues (Option B), set `export QUEUE_NAME=team-a` or `export QUEUE_NAME=team-b` before running `source env.example`. The default `QUEUE_NAME=default` only works with the single-queue configuration (Option A).

## Submit the workload

Submit the distributed training RayJob:

```bash
./submit.sh
```

The script creates a ConfigMap from the training script, renders the manifest template with four GPU workers via `envsubst`, and applies it. Kueue admits the job when four GPUs are available in the configured queue.

Tip

Run `./submit.sh --dry-run` to validate the rendered manifest without applying it to the cluster.

## Monitor progress

Find and export the job name if you're in a new shell:

```bash
export JOB_NAME=$(kubectl -n ray get rayjob --no-headers -o custom-columns=":metadata.name" | grep llm-training)
```

Watch the RayJob status and Kueue admission:

```bash
kubectl -n ray get rayjob ${JOB_NAME} -w
kubectl -n ray get workload -w
```

Expected output when the job completes:

```output
NAME                      JOB STATUS   DEPLOYMENT STATUS   START TIME             END TIME               AGE
llm-training-xxxxxxxxxx   SUCCEEDED    Complete            2026-01-01T00:00:00Z   2026-01-01T00:19:00Z   19m
```

```output
NAME                                   QUEUE     RESERVED IN     ADMITTED   FINISHED   AGE
rayjob-llm-training-xxxxxxxxxx-xxxxx   default   cluster-queue   True       True       19m
```

Tail the head pod logs:

```bash
kubectl -n ray logs -f -l ray.io/cluster=$(kubectl -n ray get rayjob ${JOB_NAME} -o jsonpath='{.status.rayClusterName}') -c ray-head
```

## Verify results

Check the LoRA adapter upload:

```bash
az storage blob list -c llm-pipeline --prefix lora/ \
  --account-name ${AZURE_STORAGE_ACCOUNT_NAME} --auth-mode login -o table
```

Expected output:

```output
Name                                       Blob Type    Blob Tier    Length    Content Type
-----------------------------------------  -----------  -----------  --------  ------------------------
lora/latest.txt                            BlockBlob    Hot          86        application/octet-stream
lora/<job-name>/rng_state_3.pth            BlockBlob    Hot          14725     application/octet-stream
```

Verify the `latest.txt` pointer was written (used by the batch inference example for auto-discovery):

```bash
az storage blob download -c llm-pipeline -n lora/latest.txt \
  --account-name ${AZURE_STORAGE_ACCOUNT_NAME} --auth-mode login
```

Expected output:

```output
azure://llm-pipeline@<storage-account>.blob.core.windows.net/lora/<job-name>
```

## Configuration reference

| Variable | Default | Description |
| --- | --- | --- |
| `AZURE_STORAGE_ACCOUNT_NAME` | *(required)* | Storage account from Module 1 |
| `NUM_WORKERS` | `4` | GPU worker replicas (4 x 1 GPU each) |
| `QUEUE_NAME` | `default` | Kueue LocalQueue name |
| `LLM_DATA_CONTAINER` | `llm-pipeline` | Blob container for input data |
| `LLM_LORA_CONTAINER` | `llm-pipeline` | Blob container for LoRA upload |
| `CONFIGMAP_NAME` | `llm-training-scripts` | Name for the ConfigMap holding the training script |

## Clean up resources

Delete the RayJob and its ConfigMap:

```bash
kubectl -n ray delete rayjob ${JOB_NAME}
kubectl -n ray delete configmap ${CONFIGMAP_NAME}
```