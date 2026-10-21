---
layout: Conceptual
title: Troubleshooting Azure Container Registry Performance Issues - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-troubleshoot-performance
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
description: Identify and resolve common performance issues with Azure Container Registry. Learn about symptoms, causes, and solutions to enhance performance.
ms.topic: troubleshooting
ms.date: 2026-10-15T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 5791bc4d-4459-3ef2-b8dd-a1fcaa3b3289
document_version_independent_id: 07617982-bd9e-205e-b6fa-9167cabf1e61
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-troubleshoot-performance.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-troubleshoot-performance
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-troubleshoot-performance.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: e050733e-83f5-03a0-7504-817ff76641b2
---

# Troubleshooting Azure Container Registry Performance Issues - Azure Container Registry | Microsoft Learn

This article helps you troubleshoot problems you might encounter with the performance of an Azure container registry.

## Symptoms

May include one or more of the following:

- Pull or push images with the Docker CLI takes longer than expected
- Deployment of images to a service such as Azure Kubernetes Service takes longer than expected
- You're not able to complete a large number of concurrent pull or push operations in the expected time
- You see an HTTP 429 error similar to `Too many requests`
- Pull or push operations in a geo-replicated registry take longer than expected, or push fails with error `Error writing blob` or `Error writing manifest`

## Causes

- Your network connection speed may slow registry operations - solution
- Image layer compression or extraction may be slow on the client - solution
- You're reaching a configured limit in your registry service tier or environment - solution
- Your geo-replicated registry has replicas in nearby regions - solution
- You're pulling from a geographically distant registry replica - solution

If you don't resolve your problem here, see Advanced troubleshooting and Next steps for other options.

## Potential solutions

### Check expected network speed

Check your internet upload and download speed, or use a tool such as AzureSpeed to test [upload](https://www.azurespeed.com/Azure/Upload) and [download](https://www.azurespeed.com/Azure/Download) from Azure blob storage, which hosts registry image layers.

Check your image size against the maximum supported size and the supported download or upload bandwidth for your registry service tier. If your registry is in the Basic or Standard tier, consider upgrading to improve performance.

For image deployment to other services, check the regions where the registry and target are located. Consider locating the registry and the deployment target in the same or network-close regions to improve performance.

Related links:

- [Azure Container Registry service tiers](container-registry-skus)
- [Container registry FAQ](container-registry-faq)
- [Performance and scalability targets for Azure Blob Storage](/en-us/azure/storage/blobs/scalability-targets)

### Check client hardware

The disk type and CPU on the docker client can affect the speed of extracting or compressing image layers on the client as part of pull or push operations. For example, layer extraction on a hard disk drive will take longer than on a solid-state disk. Compare pull operations for comparable images from your Azure container registry and a public registry such as Docker Hub.

### Review configured limits

If you're concurrently pushing or pulling multiple or many multi-layered images to your registry, review the supported ReadOps and WriteOps limits for the registry service tier. If your registry is in the Basic or Standard tier, consider upgrading to increase the limits. Check also with your networking provider about network throttling that may occur with many concurrent operations.

Review your Docker daemon configuration for the maximum concurrent uploads or downloads for each push or pull operation on the client. Configure higher limits if needed.

Because each image layer requires a separate registry read or write operation, check the number of layers in your images. Consider strategies to reduce the number of image layers.

Use Azure Monitor metrics or the integrated Grafana dashboards to determine whether the registry is throttling requests or whether performance differs by operation or region:

- Filter `Transactions` by `ResponseType = Throttled` to identify HTTP 429 responses.
- Split `Transactions` by `ApiName` to identify the affected registry operations.
- Split `Transactions` by `Region` to compare the home region and geo-replicas.
- Split `DataTransfer` by `ApiName` or `Region` to compare transferred data by operation or serving region.

For dimension descriptions and possible values, see [Azure Container Registry monitoring data reference](monitor-container-registry-reference#metric-dimensions). For reusable dashboards and ad hoc analysis, see [Grafana dashboards in Azure Container Registry](/en-us/azure/container-registry/container-registry-dashboards-with-grafana).

Related links:

- [Azure Container Registry service tiers](container-registry-skus)
- [dockerd](https://docs.docker.com/engine/reference/commandline/dockerd/)

### Configure geo-replicated registry

A Docker client that pushes an image to a geo-replicated registry might not push all image layers and its manifest to a single replicated region. This situation may occur because Azure Traffic Manager routes registry requests to the network-closest replicated registry. If the registry has two nearby replication regions, image layers and the manifest could be distributed to the two sites, and the push operation fails when the manifest is validated.

To optimize DNS resolution to the closest replica when pushing images, configure a geo-replicated registry in the same Azure regions as the source of the push operations, or the closest region when working outside of Azure.

To troubleshoot operations with a geo-replicated registry, you can also temporarily disable Traffic Manager routing to one or more replications.

Related links:

- [Geo-replication in Azure Container Registry](container-registry-geo-replication)

### Configure DNS for geo-replicated registry

If pull operations from a geo-replicated registry appear slow, the DNS configuration on the client might resolve to a geographically distant DNS server. In this case, Traffic Manager might be routing requests to a replica that is network-close to the DNS server but distant from the client. Run a tool such as `nslookup` or `dig` (on Linux) to determine the replica that Traffic Manager routes registry requests to. For example:

```console
nslookup myregistry.azurecr.io
```

A potential solution is to configure a closer DNS server.

Related links:

- [Geo-replication in Azure Container Registry](container-registry-geo-replication)
- [Troubleshooting geo-replicated registries](container-registry-geo-replication#troubleshooting)
- [Temporarily exclude a geo-replica from global endpoint routing](container-registry-geo-replication#temporarily-exclude-a-geo-replica-from-global-endpoint-routing)
- [Traffic Manager FAQs](/en-us/azure/traffic-manager/traffic-manager-faqs)

### Advanced troubleshooting

If your permissions to registry resources allow, [check the health of the registry environment](container-registry-check-health). If errors are reported, review the [error reference](container-registry-health-error-reference) for potential solutions.

If [collection of resource logs](monitor-service) is enabled in the registry, review the ContainterRegistryRepositoryEvents log. This log stores information for operations such as push or pull events. Query the log for [repository-level operation failures](monitor-service#repository-level-operation-failures).

Related links:

- [Logs for diagnostic evaluation and auditing](monitor-service)
- [Container registry FAQ](container-registry-faq)
- [Best practices for Azure Container Registry](container-registry-best-practices)