---
layout: Conceptual
title: Upgrade from Basic Load Balancer on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-basic-load-balancer-on-aks
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
description: Upgrade guidance for migrating Basic Load Balancer to Standard Load Balancer on AKS.
author: wdarko1
ms.author: wilsondarko
ms.topic: how-to
ms.date: 2025-08-29T00:00:00.0000000Z
locale: en-us
document_id: a79b0625-a880-3dcc-6e5d-370e45c21316
document_version_independent_id: abcd47a0-0453-a86e-a35b-3e2ac80f22bf
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-basic-load-balancer-on-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/upgrade-basic-load-balancer-on-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-basic-load-balancer-on-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: bc0c517a-c572-c8ff-27f3-489337ab6d26
---

# Upgrade from Basic Load Balancer on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to upgrade your Basic Load Balancer instances to Standard Load Balancer on Azure Kubernetes Services (AKS). We recommend using Standard Load Balancer for all production instances. It provides many [key differences](/en-us/azure/load-balancer/load-balancer-basic-upgrade-guidance#basic-load-balancer-sku-vs-standard-load-balancer-sku) to your infrastructure. For guidance on upgrading from Basic Load Balancer to Standard Load Balancer outside of AKS, see the [official guidance for Basic Load Balancer upgrade](/en-us/azure/load-balancer/load-balancer-basic-upgrade-guidance).

Important

Starting on **September 30, 2025**, Azure Kubernetes Service (AKS) no longer supports Basic Load Balancer. To avoid any potential service disruptions, we recommend using Standard Load Balancer for new deployments and [upgrading any existing deployments to the Standard Load Balancer](/en-us/azure/load-balancer/load-balancer-basic-upgrade-guidance). For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5020) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/azure-basic-load-balancer-will-be-retired-on-30-september-2025-upgrade-to-standard-load-balancer/). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

For clusters using both Availability Sets and the Basic Load Balancer, there's a separate `az aks update` command you need to run to perform both migrations at once (Availability Sets to Virtual Machine node pools, and Basic Load Balancer to Standard Load Balancer). For steps on performing this migration, see the [Availability Sets migration](availability-sets-on-aks) guidance.

## Before you begin

Before you begin the migration, review the following information:

- Downtime occurs during migration. Plan for downtime accordingly.
- Once the migration begins, roll back isn't allowed.
- This process also migrates your Basic IP to a Standard IP, while keeping the inbound IP addresses associated with the load balancer the same. New public IPs are created and associated to the Standard Load Balancer outbound rules to serve cluster egress traffic.

## Prerequisites

Your cluster must meet the following prerequisites before you can perform the migration:

- The minimum Kubernetes version for this script is 1.27. If you need to upgrade your AKS cluster, see [Upgrade an AKS cluster](upgrade-aks-cluster#upgrade-an-aks-cluster).
- You need the [Azure CLI installed](/en-us/cli/azure/install-azure-cli). The minimum version you need is 2.76.0.
- If the cluster runs Key Management Service with private key vault, you need to disable Key Management Service before performing the migration. For more information, see [Turn off KMS](/en-us/azure/aks/use-kms-etcd-encryption#disable-kms-on-an-aks-cluster).
- You need to disable any `ValidatingAdmissionWebhooks` or `MutatingAdmissionWebhooks` before performing the migration.

## Upgrade Basic Load Balancer to Standard Load Balancer

1. Upgrade your Basic Load Balancer to Standard Load Balancer using the [`az aks update`](/en-us/cli/azure/aks#az-aks-create) command with the `--load-balancer-sku` flag set to `Standard`.

    ```azurecli
    az aks update \
      --name $CLUSTER_NAME \
      --resource-group $RESOURCE_GROUP \
      --load-balancer-sku=Standard
    ```
2. Verify the migration was successful using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show \
      --name $CLUSTER_NAME \
      --resource-group $RESOURCE_GROUP
    ```

    In the output, confirm the `load-balancer` type is set to `Standard`.
3. Verify that all pods and services are running successfully using the `kubectl get pods` and `kubectl get svc` commands.

    ```bash
    kubectl get svc -A
    kubectl get pods -A
    ```

### Confirm new outbound IP addresses

You can confirm the new IP addresses associated with outbound rules by confirming the resource IDs for the IP addresses and then listing the IP addresses.

1. Get the resource ID for the outbound IP addresses using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query networkProfile.loadBalancerProfile.effectiveOutboundIPs[].id
    ```
2. Get the new IP address for each resource ID using the [`az network public-ip show`](/en-us/cli/azure/network/public-ip#az-network-public-ip-show) command.

    ```azurecli
    az network public-ip show --ids $IP_RESOURCE_ID --query ipAddress -o tsv
    ```

## FAQ

### Why am I getting `Error: “Load Balancer SKU 'basic' is invalid; must use 'standard'.` when creating a new AKS cluster or upgrading?

Microsoft deprecated Basic Load Balancer SKU for certain AKS operations, and creation is now blocked in some regions.

To resolve this issue, make sure you specify `--load-balancer-sku standard` when creating a new cluster. For example:

```azurecli
az aks create \
  --name $CLUSTER_NAME \
  --resource-group $RESOURCE_GROUP \
  --load-balancer-sku standard
```

### Why can’t I change my Basic Load Balancer to Standard Load Balancer in-place?

The Load Balancer SKU is immutable after creation in AKS, as it's a managed resource owned by the cluster.

You can resolve this using one of the following options:

- **Option 1**: Use the `az aks update run` command to upgrade Basic Load Balancer to Standard. For more information, see [Upgrade Basic Load Balancer on Azure Kubernetes Service (AKS)](upgrade-basic-load-balancer-on-aks).
- **Option 2**: Create a new AKS cluster with Standard Load Balancer (blue-green migration) and move any existing workloads.

### Why can't I find my public IP after upgrading from Basic to Standard Load Balancer?

The Load Balancer object lost the reference to your public IP resource during migration. This can occur if the IP was tied to the Basic SKU Load Balancer and wasn't rebound.

To resolve this issue:

1. Ensure the new Standard public IP exists in the correct resource group.
2. Reassociate it in the service manifest using the following configuration:

    ```yaml
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-ipv4: <your-ip>
    ```

### When migrating the load balancer on a private cluster without a public IP, why is a public IP still created during the migration?

If `outboundType` is `LoadBalancer`, AKS automatically provisions a public IP (PIP), regardless of Load Balancer SKU.

To resolve this issue:

1. Change `outboundType` to `userDefinedRouting` for a fully private cluster.
2. Ensure custom outbound routing is configured via Azure Firewall/NVA.

### Why does migration fail in my internal Load Balancer setup?

Current migration tooling doesn’t support internal virtual network (VNet) Load Balancers with Basic to Standard in-place.

To resolve this issue:

1. Recreate the cluster in the same VNet with Standard Load Balancer.
2. Deploy workloads and validate internal name resolution.

### My node pools are using Availability Sets. Will I still have issues even after Load Balancer migration?

Yes. If your node pools use Availability Sets, they're also deprecated in AKS after September 30, 2025.

To resolve this issue:

1. For clusters using both Availability Sets and the Basic Load Balancer, there's a separate `az aks update` command you must run to perform both migrations at once (Availability Sets to Virtual Machine node pools, and Basic Load Balancer to Standard Load Balancer). For steps on performing this migration, see the [Availability Sets migration](availability-sets-on-aks) guidance.
2. After the upgrade, Azure CLI or REST APIs must be used to perform CRUD operations or manage the pool. Check the [limitations](virtual-machines-node-pools#limitations).

### Do I need to delete default webhooks before upgrading?

No. If no other `ValidatingAdmissionWebhooks` or `MutatingAdmissionWebhooks` are present in the cluster, the default webhooks in the control plane should be fine to keep during the migration.

Default webhooks include:

- `aks-node-mutating-webhook`
- `webhook-admission-controller`
- `node-validating-webhook`

### What access is required to run the migration commands?

To run the migration commands, you need:

- Either the Contributor or Owner role on the subscription or resource group.
- The Azure CLI version must be ≥ 2.72.0.
- The AKS preview extension version must be ≥ 0.5.170.

### How can I see if Key Management Service (KMS) encryption is disabled?

You can check whether KMS encryption is enabled on your AKS cluster using the [`az aks list`](/en-us/cli/azure/aks#az-aks-list) command.

```azurecli
az aks list --query "[].{Name:name, KmsEnabled:securityProfile.azureKeyVaultKms.enabled, KeyId:securityProfile.azureKeyVaultKms.keyId}"
```

- If the output shows `"KmsEnabled": null`, it means KMS encryption isn't enabled for that cluster, and you can skip any steps to disable it. For example:

    ```output
      {
    
        "KeyId": null,
    
        "KmsEnabled": null,
    
        "Name": "myAKSCluster"
    
      },
    ...
    ```
- If KMS is enabled and you want to disable it, see [Turn off KMS encryption](/en-us/azure/aks/use-kms-etcd-encryption#disable-kms-on-an-aks-cluster).