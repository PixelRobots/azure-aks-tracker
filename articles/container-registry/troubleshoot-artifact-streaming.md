---
layout: Conceptual
title: Troubleshoot Artifact Streaming in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/troubleshoot-artifact-streaming
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
description: Learn how to troubleshoot Artifact streaming in Azure Container Registry to diagnose and resolve issues with managing and deploying artifacts.
ms.topic: troubleshooting-general
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: db15640a-e976-db30-e90d-23f4182d27a0
document_version_independent_id: 23f4c817-c92d-e627-ba11-aa6d5b847b3c
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/troubleshoot-artifact-streaming.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/troubleshoot-artifact-streaming
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/troubleshoot-artifact-streaming.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/2d774b87-7dcb-40bf-a0b9-5a7a9efff0d1
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/89dc5f37-0e4e-4b05-ad87-5fcd2b941a8a
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 883c90ab-1f56-ab0f-f3a2-3be7899cb32c
---

# Troubleshoot Artifact Streaming in Azure Container Registry - Azure Container Registry | Microsoft Learn

The troubleshooting steps in this article can help you resolve common issues that you might encounter when using artifact streaming in Azure Container Registry (ACR). These steps and recommendations can help diagnose and resolve issues related to artifact streaming as well as provide insights into the underlying processes and logs for debugging purposes.

## Symptoms

- Conversion operation failed due to an unknown error.
- Troubleshooting Failed AKS Pod Deployments.
- Pod conditions indicate "UpgradeIfStreamableDisabled."
- Digest usage instead of Tag for Streaming Artifact.

## Causes

- Issues with authentication, network latency, image retrieval, streaming operations, or other issues.
- Issues with image pull or streaming, streaming artifacts configurations, image sources, and resource constraints.
- Issues with ACR configurations or permissions.

## Conversion operation failed

| Error Code | Error Message | Troubleshooting Info |
| --- | --- | --- |
| UNKNOWN\_ERROR | Conversion operation failed due to an unknown error. | Caused by an internal error. A retry helps here. If retry is unsuccessful, contact support. |
| RESOURCE\_NOT\_FOUND | Conversion operation failed because target resource isn't found. | If the target image isn't found in the registry, verify typos in the image digest. If the image is deleted, or missing in the target region (replication consistency isn't immediate for example) |
| UNSUPPORTED\_PLATFORM | Conversion isn't currently supported for image platform. | Only linux/amd64 images are initially supported. |
| NO\_SUPPORTED\_PLATFORM\_FOUND | Conversion isn't currently supported for any of the image platforms in the index. | Only linux/amd64 images are initially supported. No image with this platform is found in the target index. |
| UNSUPPORTED\_MEDIATYPE | Conversion isn't supported for the image MediaType. | Conversion can only target images with media type: application/vnd.oci.image.manifest.v1+json, application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.v2+json, or application/vnd.docker.distribution.manifest.list.v2+json |
| UNSUPPORTED\_ARTIFACT\_TYPE | Conversion isn't supported for the image ArtifactType. | Streaming Artifacts (Artifact type: application/vnd.azure.artifact.streaming.v1) can't be converted again. |
| IMAGE\_NOT\_RUNNABLE | Conversion isn't supported for nonrunnable images. | Only linux/amd64 runnable images are initially supported. |

## Troubleshooting Failed AKS Pod Deployments

If AKS pod deployment fails with an error related to image pulling, like the following example.

```bash
Failed to pull image "mystreamingtest.azurecr.io/jupyter/all-spark-notebook:latest":
rpc error: code = Unknown desc = failed to pull and unpack image
"mystreamingtest.azurecr.io/latestobd/jupyter/all-spark-notebook:latest":
failed to resolve reference "mystreamingtest.azurecr.io/jupyter/all-spark-notebook:latest":
unexpected status from HEAD request to http://localhost:8578/v2/jupyter/all-spark-notebook/manifests/latest?ns=mystreamingtest.azurecr.io:503 Service Unavailable
```

To troubleshoot this issue, you should check the following guidelines:

1. Verify if the AKS has permissions to access the container registry `mystreamingtest.azurecr.io`.
2. Ensure that the container registry `mystreamingtest.azurecr.io` is accessible and properly attached to AKS.

## Checking for "UpgradeIfStreamableDisabled" Pod Condition:

If the AKS pod condition shows "UpgradeIfStreamableDisabled," check if the image is from an Azure Container Registry.

## Using Digest Instead of Tag for Streaming Artifact:

If you deploy the streaming artifact using digest instead of tag (for example, mystreamingtest.azurecr.io/jupyter/all-spark-notebook@sha256:4ef83ea6b0f7763c230e696709d8d8c398e21f65542db36e82961908bcf58d18), AKS pod event and condition message won't include streaming related information. However, you see fast container startup as the underlying container engine. This engine stream the image to AKS if it detects the actual image content is streamed.