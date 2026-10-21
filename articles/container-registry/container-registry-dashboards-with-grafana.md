---
layout: Conceptual
title: Use Grafana dashboards in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-dashboards-with-grafana
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
author: jeburke
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: jeburke
ms.service: azure-container-registry
description: Use prebuilt and customizable Grafana dashboards for Azure Container Registry directly in the Azure portal.
ms.topic: how-to
ms.date: 2026-10-08T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 71252707-be17-e5c1-6485-d9db8a9a8d48
document_version_independent_id: 204bfcf5-2a1c-6944-073b-65406349354d
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-dashboards-with-grafana.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-dashboards-with-grafana
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-dashboards-with-grafana.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: d339f208-2cd6-1793-2595-5dadd6478827
---

# Use Grafana dashboards in Azure Container Registry - Azure Container Registry | Microsoft Learn

Azure Container Registry (ACR) provides an integrated metrics visualization experience enabled by [Azure Managed Grafana](/en-us/azure/managed-grafana/overview). Use prebuilt or customizable Grafana dashboards to understand registry usage patterns, monitor performance, identify throttling, track storage and data transfer, and troubleshoot operational issues.

Access this experience from the **Dashboards with Grafana** page in your container registry. You don't need to deploy or manage a separate Grafana instance. From the Azure portal, you can:

- Start with Azure-managed dashboards for common ACR monitoring scenarios.
- Create and edit dashboards by adding panels, modifying queries, and applying client-side transformations.
- Save and share dashboards as Azure resources governed by [Azure role-based access control (Azure RBAC)](/en-us/azure/role-based-access-control/overview).
- Automate dashboard deployment with [Azure Resource Manager templates](/en-us/azure/azure-resource-manager/templates/overview) or [Bicep](/en-us/azure/azure-resource-manager/bicep/overview).
- Import compatible dashboards from the Grafana community.
- Open Grafana **Explore** from the registry's integrated portal experience to investigate data and add results to dashboards.

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/).
- An [Azure container registry](container-registry-get-started-portal).
- Permissions to read ACR monitoring data and create resources in the target subscription and resource group. After you save a dashboard, use Azure RBAC to assign access to the dashboard resource.

## Open the Grafana experience in Azure Container Registry

1. In the Azure portal, open your container registry.
2. On the resource menu, under **Monitoring**, select **Dashboards with Grafana**.

The gallery lists Azure-managed dashboards and dashboards saved for the current registry. It automatically filters the gallery to dashboards associated with Azure Container Registry. You can't change this filter when you access the gallery from a registry.

## Start with a prebuilt dashboard

Azure provides dashboards for common ACR monitoring scenarios. The gallery includes the **Azure Container Registry - Observability** dashboard, which provides an overview of data transfer, transaction trends, throttling, and storage consumption. You can analyze this data by dimensions such as API name and region.

To view the dashboard, select its name in the gallery.

[![Screenshot of the Azure Container Registry observability dashboard.](media/dashboards-with-grafana.png)](media/dashboards-with-grafana.png#lightbox)

## Create, edit, and save dashboards

You can customize an Azure-managed dashboard or create a dashboard from scratch.

- To edit an Azure-managed dashboard, open it and select **Edit**. Modify its panels, queries, and transformations.
- To save your changes as a new dashboard, select **Save As**, and then choose a subscription, resource group, and name.
- To create a dashboard from scratch, return to the gallery, select **New**, and add panels.

Each saved dashboard is an Azure resource. You can manage it with Azure RBAC, export it as an ARM template, and include it in deployment automation.

Note

Dashboards you create within a registry are automatically tagged so that they appear in the Azure Container Registry Grafana gallery.

## Explore registry data

You can access Grafana **Explore** from the **Dashboards with Grafana** page in your container registry. It lets you run ad hoc queries without starting from a dashboard and add the results to a new or existing dashboard.

1. In the Azure portal, open your container registry.
2. On the resource menu, under **Monitoring**, select **Dashboards with Grafana** then **Dashboards**.
3. From the top menu, select **Explore**.
4. Choose a data source, and then build a query for the desired time range.
5. Select **Add to dashboard** to turn the visualization into a panel.

## Import dashboards from the Grafana community

You can import compatible dashboards from the Grafana public gallery that use Azure Monitor or Azure Monitor managed service for Prometheus data sources.

1. In **Dashboards with Grafana**, select **Dashboards**.
2. Select **Browse Grafana dashboards Gallery**.
3. Choose a compatible dashboard, and then copy its dashboard ID.
4. Return to **Dashboards with Grafana**, and then select **New**.
5. Select **Import**, and then follow the prompts.

The imported dashboard is saved as an Azure resource.

Important

The integrated portal experience supports Azure data sources only. For information about supported data sources and how this experience compares with a dedicated Azure Managed Grafana workspace, see [Visualize Azure Monitor data with Grafana](/en-us/azure/azure-monitor/visualize/visualize-grafana-overview).

## Make dashboards visible in Azure Container Registry

To make dashboards visible from the **Dashboards with Grafana** page in a registry, use the following Azure resource tag:

- Name: `GrafanaDashboardResourceType`
- Value: `Microsoft.ContainerRegistry/registries`

Dashboards you create from within a registry automatically receive this tag. If you create or import a dashboard outside of the registry and want it to appear in the registry's gallery, add the tag manually:

1. Open the dashboard resource.
2. Select **Tags**, and then add the tag name and value.
3. Save the changes.

After you add the tag, refresh the gallery in the registry. The dashboard appears under **Saved dashboards**.

## Manage access and automate deployment

- To control access, assign Azure roles at the dashboard resource, resource group, or subscription scope.
- To automate deployment, export an ARM template from a dashboard and use it to deploy the dashboard across environments.
- The Grafana user interface uses the language configured for the Azure portal.

## Limitations

The integrated Grafana experience in the Azure portal supports only Azure data sources. It doesn't support the following Grafana features:

- Alerts
- Reports
- Library panels
- Snapshots
- Playlists
- App plugins

For current data-source support, feature limitations, and a comparison with Azure Managed Grafana, see [Visualize Azure Monitor data with Grafana](/en-us/azure/azure-monitor/visualize/visualize-grafana-overview).

## Troubleshooting

### A dashboard doesn't appear in the gallery

Confirm that the dashboard resource has the `GrafanaDashboardResourceType` tag with the value `Microsoft.ContainerRegistry/registries`. Refresh the gallery after you add or update the tag.

### You can't save a dashboard

Verify that you have permission to create resources in the target subscription and resource group.

### Data doesn't load

Confirm that the registry and selected data source contain data for the selected time range. Also verify that you have permission to read the data source.