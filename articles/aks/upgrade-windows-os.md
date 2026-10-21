---
layout: Conceptual
title: Upgrade the Operating System (OS) Version for your Azure Kubernetes Service (AKS) Windows Workloads - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-windows-os
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
description: Learn how to upgrade the OS version for Windows workloads on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.subservice: aks-upgrade
ms.date: 2026-09-24T00:00:00.0000000Z
author: allyford
ms.author: allyford
ai-usage: ai-assisted
locale: en-us
document_id: 4f435f88-d7f4-adc4-064a-2a32ebfb591a
document_version_independent_id: 852f6928-5813-4064-5965-9e27d522b9b7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-windows-os.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/upgrade-windows-os
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-windows-os.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 8b920d1d-ee2b-2346-ceee-35438ed0848a
---

# Upgrade the Operating System (OS) Version for your Azure Kubernetes Service (AKS) Windows Workloads - Azure Kubernetes Service | Microsoft Learn

When you upgrade the OS version of a running Windows workload on Azure Kubernetes Service (AKS), use one of the following migration methods:

- **In-place migration**: Update the OS SKU on an existing node pool to migrate from Windows Server 2022 to Windows Server 2025.
- **Manual migration**: Create a new node pool with your desired Windows Server OS version, move your workloads to the new node pool, and delete the old node pool.

When a new Windows Server OS version is released, AKS is committed to supporting it. We recommend that you upgrade to the latest version to take advantage of the fixes, improvements, and new functionality. AKS provides a five-year support lifecycle for every Windows Server version, starting with Windows Server 2022. During this period, AKS releases a new version that supports a newer version of Windows Server OS for you to upgrade to. After the five-year lifecycle ends, you must migrate workloads to newer supported versions to ensure compatibility, security updates, and continued support from AKS.

Important

Starting on June 30, 2028, Azure Kubernetes Service (AKS) no longer supports Windows Server 2022 node pools. Windows Server 2022 isn't supported in Kubernetes version 1.37 and later. Starting on June 30, 2029, AKS will remove all existing node images for Windows Server 2022, meaning that scaling operations will fail. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4168) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=ws2022-retirement-aks). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

The following limitations apply to Windows Server OS version migration:

- Node pool update to migrate from one Windows Server version to another is supported only for Windows Server 2022-to-Windows Server 2025 migration by using the `aks-preview` Azure CLI extension version 22.0.0b6 or later. For all other Windows Server OS version migrations, create a new node pool.
- Different Windows Server versions can't coexist on the same node pool on AKS. If you create a new node pool to host the new OS version, ensure that you match the permissions and access of the previous node pool to the new one.
- Windows Server 2025 is supported starting in Kubernetes version 1.32.0.

## Prerequisites

- Update the `FROM` statement in your Dockerfile to the new OS version.
- Check your application and verify the container app works on the new OS version.
- Deploy the verified container app on AKS to a development or testing environment.
- Take note of the new image name or tag for use in this article.
- For in-place migration from Windows Server 2022 to Windows Server 2025, install or update the `aks-preview` Azure CLI extension to version 22.0.0b6 or later.

Note

To learn how to build a Dockerfile for Windows workloads, see [Dockerfile on Windows](/en-us/virtualization/windowscontainers/manage-docker/manage-windows-dockerfile) and [Optimize Windows Dockerfiles](/en-us/virtualization/windowscontainers/manage-docker/optimize-windows-dockerfile).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

### Install the `aks-preview` Azure CLI extension

- To install the aks-preview extension, run the following command:

## In-place migration from Windows Server 2022 to Windows Server 2025

You can migrate an existing Windows Server 2022 node pool to Windows Server 2025 in place by updating the OS SKU on the existing node pool with the `az aks nodepool update` command. This migration path uses the `aks-preview` Azure CLI extension version 22.0.0b6 or later. The cluster must run Kubernetes version 1.32 to 1.36 where both OS versions are supported.

### In-place migration considerations

Consider the following details before you migrate a Windows Server 2022 node pool to Windows Server 2025:

- Windows Server 2025 uses FIPS-enabled images by default. If your Windows Server 2022 node pool doesn't already use a FIPS-enabled image, include `--enable-fips-image` when you run the update command.
- The update command triggers an automatic reimage of the existing node pool.
- Windows Server 2025 uses Generation 2 VMs by default. You don't need to have an existing Generation 2 Windows Server 2022 node pool to migrate in place. Standard Windows Server 2022 `containerd` node pools are supported.
- If the existing VM size supports Generation 2, AKS can select a Windows Server 2025 Generation 2 image during migration. This default image selection might affect image compatibility for some configurations.

The following table describes which source configurations support in-place migration with the update command. For unsupported configurations, use manual migration instead.

| Existing configuration | Support | Result |
| --- | --- | --- |
| Standard Windows Server 2022 `containerd` Generation 1 image with a Generation 1-only VM size | Yes | Migrates to Windows Server 2025 Generation 1. |
| Standard Windows Server 2022 `containerd` Generation 1 image with a Generation 2-capable VM size | Yes | Migrates to Windows Server 2025 Generation 2. |
| Standard Windows Server 2022 `containerd` Generation 2 image with a Generation 2-capable VM size | Yes | Migrates to Windows Server 2025 Generation 2. |

### Update existing Windows Server 2022 node pool to Windows Server 2025

1. Update the node pool OS SKU to `Windows2025` by using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command.

    ```azurecli
    az aks nodepool update \
        --resource-group <resource-group-name> \
        --cluster-name <cluster-name> \
        --name <node-pool-name> \
        --os-sku Windows2025 \
        --enable-fips-image
    ```
2. Verify that a node in the updated node pool uses the `Windows2025` OS SKU and a Windows Server 2025 image by using the `kubectl describe node` command.

    ```bash
    kubectl describe node <node-name>
    ```

    The following condensed example output shows the `Windows2025` OS SKU label and Windows Server 2025 OS image:

    ```output
    Labels:
      kubernetes.azure.com/os-sku=Windows2025
      kubernetes.io/os=windows
    ...
    System Info:
      OS Image:                   Windows Server 2025 Datacenter
      Container Runtime Version:  containerd://2.0.4+azure
    ```

## Manual migration to a new node pool

Manual migration uses a new node pool instead of updating the existing node pool. Use manual migration for Windows Server OS version migrations that don't support in-place migration, or when your source configuration isn't supported for in-place migration. To manually migrate, create a new node pool with your desired Windows Server OS version and move your workloads to the new node pool.

### Add a new node pool to an existing cluster

Add a node pool with your desired OS version to your existing cluster:

- [Use CLI to add a Windows node pool](learn/quick-windows-container-deploy-cli) to an existing cluster.
- [Use Portal to add a Windows node pool](learn/quick-windows-container-deploy-portal) to an existing cluster.
- [Use PowerShell to add a Windows node pool](learn/quick-windows-container-deploy-powershell) to an existing cluster.
- [Use Terraform to add a Windows node pool](learn/quick-windows-container-deploy-terraform) to an existing cluster.

Windows Server 2025 node pools require a FIPS-enabled image. When you add a Windows Server 2025 node pool, include `--enable-fips-image` (Azure CLI) or `-EnableFIPS` (Azure PowerShell).

### Update the YAML file

Node Selector is the most common and recommended option for placement of Windows pods on Windows nodes.

1. Add Node Selector to your YAML file by adding the following annotation:

    ```yaml
          nodeSelector:
            "kubernetes.io/os": windows
    ```

    The annotation finds any available Windows node and places the pod on that node (following all other scheduling rules). When upgrading your OS version, you need to enforce the placement on a Windows node and a node running the latest OS version. To accomplish this, one option is to use a different annotation. Update `<OSSKU>` to match the ossku your desired Windows OS version, for example `Windows2025`.

    ```yaml
          nodeSelector:
            "kubernetes.azure.com/os-sku": <OSSKU>
    ```
2. Once you update the `nodeSelector` in the YAML file, you also need to update the container image you want to use. You can get this information from the previous step in which you created a new version of the containerized application by changing the `FROM` statement on your Dockerfile.

    Note

    You should use the same YAML file you used to initially deploy the application. This ensures that no other configuration changes besides the `nodeSelector` and container image.

### Apply the updated YAML file to the existing workload

1. View the nodes on your cluster using the `kubectl get nodes` command.

    ```bash
    kubectl get nodes -o wide
    ```

    The following example output shows all nodes on the cluster, including the new node pool you created and the existing node pools:

    ```output
    NAME                                STATUS   ROLES   AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION     CONTAINER-RUNTIME
    aks-agentpool-18877473-vmss000000   Ready    agent   5h40m   v1.33.12   10.240.0.4     <none>        Ubuntu 22.04.5 LTS               5.15.0-1116-azure  containerd://1.7.33-1
    akspoolws000000                     Ready    agent   3h15m   v1.33.12   10.240.0.208   <none>        Windows Server 2022 Datacenter   10.0.20348.825     containerd://1.6.6+azure
    akspoolws000001                     Ready    agent   3h17m   v1.33.12   10.240.0.239   <none>        Windows Server 2022 Datacenter   10.0.20348.825     containerd://1.6.6+azure
    akspoolws000002                     Ready    agent   3h17m   v1.33.12   10.240.1.14    <none>        Windows Server 2022 Datacenter   10.0.20348.825     containerd://1.6.6+azure
    akswspool000000                     Ready    agent   5h37m   v1.33.12   10.240.0.115   <none>        Windows Server 2025 Datacenter   10.0.26100.32995    containerd://2.0.4+azure
    akswspool000001                     Ready    agent   5h37m   v1.33.12   10.240.0.146   <none>        Windows Server 2025 Datacenter   10.0.26100.32995    containerd://2.0.4+azure
    akswspool000002                     Ready    agent   5h37m   v1.33.12   10.240.0.177   <none>        Windows Server 2025 Datacenter   10.0.26100.32995    containerd://2.0.4+azure
    ```
2. Apply the updated YAML file to the existing workload using the `kubectl apply` command and specify the name of the YAML file.

    ```bash
    kubectl apply -f <filename>
    ```

    The following example output shows a *configured* status for the deployment:

    ```output
    deployment.apps/sample configured
    service/sample unchanged
    ```

    At this point, AKS starts the process of terminating the existing pods and deploying new pods to the nodes with the `nodeSelector` annotation.
3. Check the status of the deployment using the `kubectl get pods` command.

    ```bash
    kubectl get pods -o wide
    ```

    The following example output shows the pods in the `default` namespace:

    ```output
    NAME                      READY   STATUS    RESTARTS   AGE     IP             NODE              NOMINATED NODE   READINESS GATES
    sample-7794bfcc4c-k62cq   1/1     Running   0          2m49s   10.240.0.238   akspoolws000000   <none>           <none>
    sample-7794bfcc4c-rswq9   1/1     Running   0          2m49s   10.240.1.10    akspoolws000001   <none>           <none>
    sample-7794bfcc4c-sh78c   1/1     Running   0          2m49s   10.240.0.228   akspoolws000000   <none>           <none>
    ```

### Update security and authentication configuration

If you're using Group Managed Service Accounts (gMSA), you need to update the Managed Identity configuration for the new node pool. gMSA uses a secret (user account and password) so the node that runs the Windows pod can authenticate the container against Microsoft Entra ID. To access that secret on Azure Key Vault, the node uses a Managed Identity that allows the node to access the resource. Since Managed Identities are configured per node pool, and the pod now resides on a new node pool, you need to update that configuration. For more information, see [Enable Group Managed Service Accounts (GMSA) for your Windows Server nodes on your Azure Kubernetes Service (AKS) cluster](use-group-managed-service-accounts).

The same principle applies to Managed Identities for any other pod or node pool when accessing other Azure resources. You need to update any access that Managed Identity provides to reflect the new node pool. To view update and sign-in activities, see [How to view Managed Identity activity](/en-us/azure/active-directory/managed-identities-azure-resources/how-to-view-managed-identity-activity).