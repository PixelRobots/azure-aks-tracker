---
layout: Conceptual
title: Operator best practices - Container image management in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-container-image-management
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
description: Learn the cluster operator best practices for how to manage and secure container images in Azure Kubernetes Service (AKS).
ms.topic: best-practice
ms.custom: aks-getting-started
ms.date: 2023-06-27T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 6b4fb562-2aec-e8fd-6431-7fc7ba2c97aa
document_version_independent_id: 8175749c-dfb9-127c-e3d8-8740fc9e5d06
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/operator-best-practices-container-image-management.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/operator-best-practices-container-image-management
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/operator-best-practices-container-image-management.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 97f98655-4e1d-95c0-ee9c-e576c1216ae8
---

# Operator best practices - Container image management in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn

Container and container image security is a major priority when developing and running applications in Azure Kubernetes Service (AKS). Containers with outdated base images or unpatched application runtimes introduce security risks and possible attack vectors. You can minimize these risks by integrating and running scan and remediation tools in your containers at build and runtime. The earlier you catch the vulnerability or outdated base image, the more secure your application is.

In this article, *"containers"* refers to both the container images stored in a container registry and running containers.

This article focuses on how to secure your containers in AKS. You learn how to:

- Scan for and remediate image vulnerabilities.
- Automatically trigger and redeploy container images when a base image is updated.

- You can read the best practices for [cluster security](operator-best-practices-cluster-security) and [pod security](developer-best-practices-pod-security).
- You can use [Container security in Defender for Cloud](/en-us/azure/security-center/container-security) to help scan your containers for vulnerabilities. [Azure Container Registry integration](/en-us/azure/security-center/defender-for-container-registries-introduction) with Defender for Cloud helps protect your images and registry from vulnerabilities.

## Secure the images and runtime

> 
> **Best practice guidance**
> 
> - Scan your container images for vulnerabilities.
> - Only deploy validated images.
> - Regularly update the base images and application runtime.
> - Redeploy workloads in the AKS cluster.
> 

When adopting container-based workloads, you want to verify the security of images and runtime used to build your own applications. To help avoid introducing security vulnerabilities into your deployments, you can use the following best practices:

- Include in your deployment workflow a process to scan container images using tools, such as [Twistlock](https://www.twistlock.com/) or [Aqua](https://www.aquasec.com/).
- Only allow verified images to be deployed.

![Scan and remediate container images, validate, and deploy](media/operator-best-practices-container-security/scan-container-images-simplified.png)

For example, you can use a continuous integration and continuous deployment (CI/CD) pipeline to automate the image scans, verification, and deployments. Azure Container Registry includes these vulnerabilities scanning capabilities.

## Automatically build new images on base image update

> 
> **Best practice guidance**
> 
> As you use base images for application images, use automation to build new images when the base image is updated. Since updated base images typically include security fixes, update any downstream application container images.

Each time a base image is updated, you should also update any downstream container images. Integrate this build process into validation and deployment pipelines such as [Azure Pipelines](/en-us/azure/devops/pipelines/) or Jenkins. These pipelines ensure your applications continue to run on the updated based images. Once your application container images are validated, you can then update AKS deployments to run the latest secure images.

Azure Container Registry Tasks can also automatically update container images when the base image is updated. With this feature, you build a few base images and keep them updated with bug and security fixes.

For more information about base image updates, see [Automate image builds on base image update with Azure Container Registry Tasks](/en-us/azure/container-registry/container-registry-tutorial-base-image-update).