---
layout: Conceptual
title: Configure Firewall Access Rules to access an Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-firewall-rules
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
description: Configure rules to access an Azure container registry from behind a firewall, allowing access to REST API and data endpoint domain names.
ms.topic: how-to
ms.date: 2026-06-15T00:00:00.0000000Z
locale: en-us
document_id: 2f231f59-9f66-6c3d-17ad-111b938aba85
document_version_independent_id: 94feb5a8-9e12-227a-bfd3-c7682c551242
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-firewall-rules.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-firewall-rules
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-firewall-rules.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 4f792fff-f14b-4112-3748-0b71c15a649d
---

# Configure Firewall Access Rules to access an Azure Container Registry - Azure Container Registry | Microsoft Learn

This article explains how to configure rules on your firewall to allow access to an Azure container registry. For example, an Azure IoT Edge device behind a firewall or proxy server might need to access a container registry to pull a container image. Or, a locked-down server in an on-premises network might need access to push an image.

To configure inbound network access to a container registry only within an Azure virtual network, see [Configure Azure Private Link for an Azure container registry](container-registry-private-endpoints).

## About registry endpoints

To pull or push images or other artifacts to an Azure container registry, a client such as a Docker daemon needs to interact over HTTPS with two or more distinct endpoints. For clients that access a registry from behind a firewall, you need to configure access rules for each endpoint. All endpoints are reached over port 443.

- **Global endpoint (REST API)** — Authentication and registry management operations are handled through the registry's public REST API endpoint. This endpoint is the login server name of the registry. Example: `myregistry.azurecr.io`

    - **Registry REST API endpoint for certificates** — Azure container registry uses a wildcard SSL certificate for all subdomains. When connecting to the Azure container registry using SSL, the client must be able to download the certificate for the TLS handshake. In such cases, `azurecr.io` must also be accessible.
- **Storage (data) endpoint** — Azure [allocates blob storage](container-registry-storage) in Azure Storage accounts on behalf of each registry to manage the data for container images and other artifacts. When a client accesses image layers in an Azure container registry, it makes requests using a storage account endpoint provided by the registry.

If your registry is [geo-replicated](container-registry-geo-replication), a client might need to interact with the data endpoint in a specific region or in multiple replicated regions.

- **Regional endpoint** (if enabled) — When [regional endpoints](container-registry-geo-replication#regional-endpoints-of-a-geo-replicated-registry-preview) are enabled on a **Premium** SKU registry, each geo-replica gets a regional endpoint of the form `<registry-name>.<region>.geo.azurecr.io`. Regional endpoints allow clients to connect directly to a specific geo-replica for authentication and push/pull/delete operations, bypassing the global endpoint. If you use firewall rules, you need to allow access to the regional endpoint for each geo-replica that clients connect to.

For the full list of endpoint types and FQDN patterns, see the [endpoint reference](container-registry-endpoint-reference).

## Allow access to REST and data endpoints

- **REST endpoint** - Allow access to the fully qualified registry login server name, `<registry-name>.azurecr.io`, or an associated IP address range
- **Storage (data) endpoint** - Allow access to all Azure blob storage accounts using the wildcard `*.blob.core.windows.net`, or an associated IP address range.

Note

Azure Container Registry supports [dedicated data endpoints](container-registry-dedicated-data-endpoints), allowing you to tightly scope client firewall rules for your registry storage. Optionally enable data endpoints in all regions where the registry is located or replicated, using the form `<registry-name>.<region>.data.azurecr.io`.

If [regional endpoints](container-registry-geo-replication#regional-endpoints-of-a-geo-replicated-registry-preview) are also enabled, allow access to `<registry-name>.<region>.geo.azurecr.io` for each geo-replica that clients connect to.

If [IPv6 dual-stack endpoints](container-registry-ipv6-dual-stack) are enabled, registry endpoints resolve over both IPv4 and IPv6. Firewall rules based on the FQDNs above continue to work unchanged. If you allow access by IP address ranges instead of FQDNs, account for IPv6 traffic in your rules.

## About Azure Container Registry FQDNs

Azure Container Registry uses two FQDNs: the login URL and the data endpoint.

- Both the login URL and the data endpoint are accessible from within the virtual network, using private IPs by enabling a private link.
- A registry that doesn't use data endpoints must access data from an endpoint of the form `*.blob.core.windows.net`. This doesn't provide the required isolation when configuring firewall rules.
- A registry with a private link enabled gets the dedicated data endpoint automatically.
- One dedicated data endpoint is created per region for a registry.
- The login URL remains the same whether dedicated data endpoint is enabled or disabled.

## Allow access by IP address range

If your organization has policies to allow access only to specific IP addresses or address ranges, download the latest version of [Azure IP Ranges and Service Tags – Public Cloud](https://www.microsoft.com/download/details.aspx?id=56519).

To find the ACR REST endpoint IP ranges for which you need to allow access, search for **AzureContainerRegistry** in the JSON file.

Important

IP address ranges for Azure services can change, and updates are published weekly. Download the JSON file regularly, and make necessary updates in your access rules. If your scenario involves configuring network security group rules in an Azure virtual network or you use Azure Firewall, use the **AzureContainerRegistry**service tag instead.

### REST IP addresses for all regions

```json
{
  "name": "AzureContainerRegistry",
  "id": "AzureContainerRegistry",
  "properties": {
    "changeNumber": 10,
    "region": "",
    "platform": "Azure",
    "systemService": "AzureContainerRegistry",
    "addressPrefixes": [
      "13.66.140.72/29",
    [...]
```

### REST IP addresses for a specific region

Search for the specific region, such as **AzureContainerRegistry.AustraliaEast**.

```json
{
  "name": "AzureContainerRegistry.AustraliaEast",
  "id": "AzureContainerRegistry.AustraliaEast",
  "properties": {
    "changeNumber": 1,
    "region": "australiaeast",
    "platform": "Azure",
    "systemService": "AzureContainerRegistry",
    "addressPrefixes": [
      "13.70.72.136/29",
    [...]
```

### Storage IP addresses for all regions

```json
{
  "name": "Storage",
  "id": "Storage",
  "properties": {
    "changeNumber": 19,
    "region": "",
    "platform": "Azure",
    "systemService": "AzureStorage",
    "addressPrefixes": [
      "13.65.107.32/28",
    [...]
```

### Storage IP addresses for specific regions

Search for the specific region, such as **Storage.AustraliaCentral**.

```json
{
  "name": "Storage.AustraliaCentral",
  "id": "Storage.AustraliaCentral",
  "properties": {
    "changeNumber": 1,
    "region": "australiacentral",
    "platform": "Azure",
    "systemService": "AzureStorage",
    "addressPrefixes": [
      "52.239.216.0/23"
    [...]
```

## Allow access by service tag

In an Azure virtual network, use network security rules to filter traffic from a resource such as a virtual machine to a container registry. To simplify the creation of Azure network rules, use the **AzureContainerRegistry**[service tag](/en-us/azure/virtual-network/network-security-groups-overview#service-tags). A service tag represents a group of IP address prefixes to access an Azure service globally or per Azure region. The tag is automatically updated when addresses change.

For example, create an outbound network security group rule with destination **AzureContainerRegistry** to allow traffic to an Azure container registry. To allow access to the service tag only in a specific region, specify the region in the following format: `AzureContainerRegistry.[region name]`.

## Enable dedicated data endpoints

For steps to enable dedicated data endpoints using the Azure portal or Azure CLI, see [Dedicated data endpoints in Azure Container Registry](container-registry-dedicated-data-endpoints#enable-dedicated-data-endpoints).

After you set up dedicated data endpoints for your registry, you can enable client firewall access rules for the data endpoints. Enable data endpoint access rules for all required registry regions.

## Configure client firewall rules for MCR

To access Microsoft Container Registry (MCR) from behind a firewall, see the guidance to configure [MCR client firewall rules](https://github.com/microsoft/containerregistry/blob/main/docs/client-firewall-rules.md). MCR is the primary registry for all Microsoft-published docker images, such as Windows Server images.