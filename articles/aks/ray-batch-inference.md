---
layout: Conceptual
title: Run batch inference with Ray on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ray-batch-inference
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
description: Learn how to run vLLM batch inference using a trained LoRA adapter with Ray and Kueue on AKS.
ms.topic: how-to
ms.date: 2026-06-26T00:00:00.0000000Z
author: feiskyer
ms.author: peni
ms.custom: stateful-workloads
locale: en-us
document_id: 9de05d1d-84aa-87cb-3a66-beba2bd4d079
document_version_independent_id: 96770c02-c37c-65de-9d92-65abd68ca601
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ray-batch-inference.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/ray-batch-inference
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ray-batch-inference.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/86a4b315-a9f1-4577-b985-6fb0e0e67420
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/96ac410d-d052-4707-8007-df31dd0fe041
platformId: 3ae3197f-09c6-2a81-517b-4d24381a408a
---

# Run batch inference with Ray on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you submit a RayJob that runs vLLM offline batch inference using the LoRA adapter produced by the [LLM training example](ray-train-llm). The job reads the viggo test split and LoRA adapter from Azure Blob Storage, generates predictions on a single GPU, and uploads the results.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Prerequisites

- Infrastructure deployed following [Deploy infrastructure for Ray and Kueue on AKS](deploy-ray-infrastructure).
- Kueue queues configured following [Configure Kueue queues for Ray workloads on AKS](configure-ray-kueue-queues).
- At least one A100 GPU available in the cluster.
- LLM training completed following [Train an LLM with Ray on AKS](ray-train-llm) — the LoRA adapter must exist at `llm-pipeline/lora/` in blob storage.
- `envsubst` installed (`gettext` package on Linux, `brew install gettext` on macOS).

## Set environment variables

Navigate to the batch inference example in the cloned repository and configure the required environment variables:

```bash
cd <path-to-cloned-repo>/AKS/examples/kueue-and-ray-on-aks/3-workloads/batch-inference
export AZURE_STORAGE_ACCOUNT_NAME=$(terraform -chdir=../../1-infrastructure/terraform output -raw storage_account_name)
source env.example
```

Note

If you configured team queues (Option B), set `export QUEUE_NAME=team-a` or `export QUEUE_NAME=team-b` before running `source env.example`. The default `QUEUE_NAME=default` only works with the single-queue configuration (Option A).

## Submit the workload

Submit the batch inference RayJob:

```bash
./submit.sh
```

The script creates a ConfigMap from the inference script, renders the manifest template via `envsubst`, and applies it. Kueue admits the job when 1 GPU is available in the configured queue.

Tip

Run `./submit.sh --dry-run` to validate the rendered manifest without applying it to the cluster.

## Monitor progress

Find and export the job name if you're in a new shell:

```bash
export JOB_NAME=$(kubectl -n ray get rayjob --no-headers -o custom-columns=":metadata.name" | grep batch-inference)
```

Watch the RayJob status and Kueue admission:

```bash
kubectl -n ray get rayjob ${JOB_NAME} -w
kubectl -n ray get workload -w
```

Expected output when the job completes:

```output
NAME                         JOB STATUS   DEPLOYMENT STATUS   START TIME             END TIME               AGE
batch-inference-xxxxxxxxxx   SUCCEEDED    Complete            2026-01-01T00:00:00Z   2026-01-01T00:09:00Z   9m
```

```output
NAME                                      QUEUE     RESERVED IN     ADMITTED   FINISHED   AGE
rayjob-batch-inference-xxxxxxxxxx-xxxxx   default   cluster-queue   True       True       9m
```

Tail the worker logs:

```bash
kubectl -n ray logs -l ray.io/cluster=$(kubectl -n ray get rayjob ${JOB_NAME} -o jsonpath='{.status.rayClusterName}') -f --tail=100
```

## Verify results

List prediction files in blob storage:

```bash
az storage blob list -c llm-pipeline --prefix "inference/${JOB_NAME}/" \
  --account-name ${AZURE_STORAGE_ACCOUNT_NAME} --auth-mode login -o table
```

Expected output:

```output
Name                                                 Blob Type    Blob Tier    Length    Content Type
---------------------------------------------------  -----------  -----------  --------  ------------------------
inference/<job-name>/metrics.json                    BlockBlob    Hot          128       application/octet-stream
inference/<job-name>/predictions.jsonl               BlockBlob    Hot          411777    application/octet-stream
```

Download and inspect the predictions:

```bash
az storage blob download -c llm-pipeline \
  -n "inference/${JOB_NAME}/predictions.jsonl" \
  --account-name ${AZURE_STORAGE_ACCOUNT_NAME} --auth-mode login \
  --file /tmp/predictions.jsonl
head -1 /tmp/predictions.jsonl | python3 -m json.tool
```

Expected output:

```output
{
    "input": "I'm wondering, have you played any games you found genuinely shocking?",
    "expected": "request(specifier[shocking])",
    "generated": "request_explanation"
}
```

## Configuration reference

| Variable | Default | Description |
| --- | --- | --- |
| `AZURE_STORAGE_ACCOUNT_NAME` | *(required)* | Storage account from Module 1 |
| `JOB_NAME` | `batch-inference-<timestamp>` | Unique RayJob name |
| `QUEUE_NAME` | `default` | Kueue LocalQueue name |
| `LLM_DATA_CONTAINER` | `llm-pipeline` | Blob container with viggo test data |
| `LLM_LORA_CONTAINER` | `llm-pipeline` | Blob container with LoRA adapters |
| `CONFIGMAP_NAME` | `batch-inference-scripts` | Name for the ConfigMap holding the inference script |

## Clean up resources

Delete the RayJob and its ConfigMap:

```bash
kubectl -n ray delete rayjob ${JOB_NAME}
kubectl -n ray delete configmap ${CONFIGMAP_NAME}
```

To tear down all infrastructure, see [Deploy infrastructure — Clean up resources](deploy-ray-infrastructure#clean-up-resources).