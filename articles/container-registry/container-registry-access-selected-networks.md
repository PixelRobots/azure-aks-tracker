---
layout: Conceptual
title: Configure Public Registry Access in Azure - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-access-selected-networks
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
description: Configure IP rules to enable access to an Azure container registry from selected public IP addresses or address ranges.
ms.topic: how-to
ms.date: 2025-02-28T00:00:00.0000000Z
locale: en-us
document_id: fd78d056-1d75-fd50-e591-58fca2c88731
document_version_independent_id: df19f1d9-f58b-cda6-3755-2ef4df664cb5
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-access-selected-networks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-access-selected-networks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-access-selected-networks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 685e7cd6-db86-bfac-2c24-82fd4d7ad089
---

# Configure Public Registry Access in Azure - Azure Container Registry | Microsoft Learn

An Azure container registry by default accepts connections over the internet from hosts on any network. This article shows how to configure your container registry to allow access from only specific public IP addresses or address ranges. It provides equivalent steps using the Azure CLI and Azure portal.

IP network rules are configured on the public registry endpoint. IP network rules don't apply to private endpoints configured with [Private Link](container-registry-private-endpoints).

Configuring IP access rules is available in the **Premium** container registry service tier. For information about registry service tiers and limits, see [Azure Container Registry tiers](container-registry-skus).

Each registry supports a maximum of 200 IP access rules.

The maximum of 200 public IP network rules per registry is a non-adjustable Azure Container Registry service limit. Azure Support can't increase this limit.

Important

If your container registry restricts access to private endpoints, selected subnets, or IP addresses, some functionality might be unavailable or require more configuration.

- When you disable public network access to a registry, certain [trusted services](allow-access-trusted-services), including Microsoft Defender for Cloud, can access the registry only if you enable a network setting to bypass the network rules.
- Once you disable the public network access, instances of certain Azure services, including Azure DevOps Services, can't access the container registry.
- Private endpoints aren't currently supported with agents managed by Azure DevOps. You need to use a self-hosted agent with network line of sight to the private endpoint.
- If the registry has an approved private endpoint and you disable public network access, you can't list repositories and tags outside the virtual network by using the Azure portal, Azure CLI, or other tools.

## Access from selected public network - CLI

### Change default network access to registry

To limit access to a selected public network, first change the default action to deny access. Substitute the name of your registry in the following [az acr update](/en-us/cli/azure/acr#az-acr-update) command:

```azurecli
az acr update --name myContainerRegistry --default-action Deny
```

### Add network rule to registry

Use the [az acr network-rule add](/en-us/cli/azure/acr/network-rule/#az-acr-network-rule-add) command to add a network rule to your registry that allows access from a public IP address or range. For example, substitute the container registry's name and the public IP address of a VM in a virtual network.

```azurecli
az acr network-rule add \
  --name mycontainerregistry \
  --ip-address <public-IP-address>
```

Note

After adding a rule, wait a few minutes for the rule to take effect.

## Access from selected public network - portal

1. In the portal, navigate to your container registry.
2. Under **Settings**, select **Networking**.
3. On the **Public access** tab, select to allow public access from **Selected networks**.
4. Under **Firewall**, enter a public IP address, such as the public IP address of a VM in a virtual network. Or, enter an address range in CIDR notation that contains the VM's IP address.
5. Select **Save**.

![Configure firewall rule for container registry](media/container-registry-access-selected-networks/acr-access-selected-networks.png)

Note

After adding a rule, wait a few minutes for the rule to take effect.

Tip

Optionally, enable registry access from a local client computer or IP address range. To allow this access, you need the computer's public IPv4 address. You can find this address by searching "what is my IP address" in an internet browser. The current client IPv4 address also appears automatically when you configure firewall settings on the **Networking** page in the portal.

## Disable public network access

Optionally, disable the public endpoint on the registry. Disabling the public endpoint overrides all firewall configurations. For example, you might want to disable public access to a registry secured in a virtual network using [Private Link](container-registry-private-endpoints).

Note

If the registry is set up in a virtual network with a [service endpoint](container-registry-vnet), disabling access to the registry's public endpoint also disables access to the registry within the virtual network.

### Disable public access - CLI

To disable public access using the Azure CLI, run [az acr update](/en-us/cli/azure/acr#az-acr-update) and set `--public-network-enabled` to `false`. The `public-network-enabled` argument requires Azure CLI 2.6.0 or later.

```azurecli
az acr update --name myContainerRegistry --public-network-enabled false
```

### Disable public access - portal

1. In the portal, navigate to your container registry and select **Settings &gt; Networking**.
2. On the **Public access** tab, in **Allow public network access**, select **Disabled**. Then select **Save**.

![Disable public access](media/container-registry-access-selected-networks/acr-access-disabled.png)

## Restore public network access

To re-enable the public endpoint, update the networking settings to allow public access. Enabling the public endpoint overrides all firewall configurations.

### Restore public access - CLI

Run [az acr update](/en-us/cli/azure/acr#az-acr-update) and set `--public-network-enabled` to `true`.

Note

The `public-network-enabled` argument requires Azure CLI 2.6.0 or later.

```azurecli
az acr update --name myContainerRegistry --public-network-enabled true
```

### Restore public access - portal

1. In the portal, navigate to your container registry and select **Settings &gt; Networking**.
2. On the **Public access** tab, in **Allow public network access**, select **All networks**. Then select **Save**.

![Public access from all networks](media/container-registry-access-selected-networks/acr-access-all-networks.png)

## Troubleshoot

### Access behind HTTPS proxy

If you set a public network rule or deny public access to the registry, sign ins to the registry fail from a disallowed public network. Client access from behind an HTTPS proxy also fails if you don't set an access rule for the proxy. You see an error message similar to `Error response from daemon: login attempt failed with status: 403 Forbidden` or `Looks like you don't have access to registry`.

These errors can also occur if you use an HTTPS proxy that a network access rule allows, but the proxy isn't properly configured in the client environment. Check that both your Docker client and the Docker daemon are configured for proxy behavior. For details, see [HTTP/HTTPS proxy](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy) in the Docker documentation.

### Access from Azure Pipelines

If you use Azure Pipelines with an Azure container registry that limits access to specific IP addresses, the pipeline might be unable to access the registry. The outbound IP address from the pipeline isn't fixed. By default, the pipeline runs jobs using a Microsoft-hosted [agent](/en-us/azure/devops/pipelines/agents/agents) on a virtual machine pool with a changing set of IP addresses.

One workaround is to change the agent used to run the pipeline from Microsoft-hosted to self-hosted. With a self-hosted agent running on a [Windows](/en-us/azure/devops/pipelines/agents/v2-windows) or [Linux](/en-us/azure/devops/pipelines/agents/v2-linux) machine that you manage, you control the outbound IP address of the pipeline. You can add this address in a registry IP access rule.

### Access from AKS

If you use Azure Kubernetes Service (AKS) with an Azure container registry that limits access to specific IP addresses, you can't configure a fixed AKS IP address by default. The egress IP address from the AKS cluster is randomly assigned.

To allow the AKS cluster to access the registry, use one of these options:

- For the Azure Basic Load Balancer, set up a [static IP address](/en-us/azure/aks/egress) for the AKS cluster.
- For the Azure Standard Load Balancer, see guidance to [control egress traffic](/en-us/azure/aks/limit-egress-traffic) from the cluster.