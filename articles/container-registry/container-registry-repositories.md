---
layout: Conceptual
title: View Repositories in the Azure portal - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-repositories
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
description: Use the Azure portal to view Azure Container Registry repositories, which host Docker container images and other supported artifacts.
ms.topic: how-to
ms.date: 2025-12-18T00:00:00.0000000Z
locale: en-us
document_id: 28256060-09e0-c284-21cd-49e3507e03be
document_version_independent_id: 20451f18-f6e7-fa41-1777-bacc26a70639
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-repositories.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-repositories
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-repositories.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 82c211af-e647-a5c4-ebc5-2f97c0bf6201
---

# View Repositories in the Azure portal - Azure Container Registry | Microsoft Learn

Azure Container Registry allows you to store Docker container images and other artifacts in [repositories](container-registry-concepts#repository). When you push images to repositories, you can see a list of the repositories hosting your images, as well as any image tags, in the Azure portal.

To view a repository and its image tags in the Azure portal, follow these steps:

1. In the [Azure portal](https://portal.azure.com), go to the container registry where you pushed the Nginx image.
2. Under **Services**, select **Repositories** to see a list of the repositories that contain the images in the registry.
3. Select a repository to see the image tags within that repository.

For example, if you followed the steps in [Push and pull an image](container-registry-get-started-docker-cli) and didn't subsequently delete the image, you should have an Nginx image in your container registry. The instructions in that article specify that you tag the `nginx` image with a `samples` namespace tag, resulting in `/samples/nginx`. In this case, you see something similar to the following image:

[![Screenshot showing a repository and tags for a container registry in the Azure portal.](media/container-registry-repositories/container-registry-repositories.png)](media/container-registry-repositories/container-registry-repositories.png#lightbox)