---
layout: Conceptual
title: Deploy and test highly available GitHub Actions on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/github-actions-azure-files-deploy-test
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
description: Learn how to deploy and test highly available GitHub Actions with Azure Files on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.subservice: aks-storage
ms.date: 2025-06-13T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: stateful-workloads
locale: en-us
document_id: 438f0424-f54d-ea1d-0649-6ffc2b204884
document_version_independent_id: e0a4dc27-650d-0bb7-496e-71c4c90177b8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/github-actions-azure-files-deploy-test.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/github-actions-azure-files-deploy-test
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/github-actions-azure-files-deploy-test.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
- https://authoring-docs-microsoft.poolparty.biz/devrel/7696cda6-0510-47f6-8302-71bb5d2e28cf
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
- https://authoring-docs-microsoft.poolparty.biz/devrel/69c76c32-967e-4c65-b89a-74cc527db725
platformId: 7356cf6e-7cdc-07a8-5962-46ff140836e4
---

# Deploy and test highly available GitHub Actions on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to deploy and test highly available GitHub Actions with Azure Files on Azure Kubernetes Service (AKS).

## GitHub Actions sample workflows

The repository has three sample workloads in the default [GitHub workflow folder](https://github.com/jorgearteiro/azurefiles-actions-aks/tree/main/.github/workflows) for you to test the self-hosted ARC runners:

- **`dotnet-using-container.yml`**: .NET Build using containers install .NET SDK and restore/build/publish application on the runner itself.
- **`dotnet-without-container.yml`**: .NET Build without containers use workflow container feature to run a .NET SDK container and build inside the application inside the container. NuGet caching is mounted by default on this container.
- **`container-service-test.yml`**: Container and Service Test testing workflows also using containers feature to create an Ubuntu container and a Redis service. Both containers run on the same AKS Pod. NuGet caching is also mounted by default on this container.

All three workflows have an input parameter for the ARC runner name to be used on the `runs-on:` field of your workflow. This is the `ARC_RUNNER_SCALESET_NAME="arc-runner-set"` variable we defined previously. To facilitate testing, we use the `workflow_dispatch:` option on the three workflows to only run those workflows when it's requested manually. On the GitHub Actions tab of your repository, select one of the workflows and run the workload.

Once the workflow is running, it requests a runner to ARC running on the AKS cluster. Once this runner, a pod on Kubernetes, is allocated for the job, the workflow runs in there to completion. We use the ephemeral runner approach, so the pod running the workflow is destroyed at the end and a new one is created for the next workflow run.

## Delete the resources

When you're ready, you can delete all the resources created in this guide using the following commands:

```bash
# Delete ARC runners scale sets 

helm delete "${ARC_RUNNER_SCALESET_NAME}" -n "${NAMESPACE_ARC_RUNNERS}" --wait 

# Delete ARC runners scale set controller 

helm delete "${ARC_CONTROLLER_NAME}" -n "${NAMESPACE_ARC_CONTROLLER}" --wait 

# Delete Azure File share configurations 

kubectl delete -f ./install/arc-runners-set-pv-pvc.yaml --wait 
kubectl delete -f ./install/arc-runners-storage-class-files.yaml --wait 

# Delete secrets 

kubectl delete secret azure-storage-secret -n arc-runners --wait 
kubectl delete secret ${ARC_RUNNER_GITHUB_SECRET_NAME} -n arc-runners --wait 

# Delete container runner configmap pod spec 

kubectl delete -f ./install/arc-runners-set-container-pod-spec.yaml --wait 

# Delete namespaces 

kubectl delete namespace ${NAMESPACE_ARC_RUNNERS} 
kubectl delete namespace ${NAMESPACE_ARC_CONTROLLER} 
```