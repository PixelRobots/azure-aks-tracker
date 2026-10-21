---
layout: Conceptual
title: Upgrade the Windows Server version on your node pools | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/howto-upgrade-windows-os
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to upgrade the Windows Server version on your node pools in AKS Hybrid and Edge.
ms.topic: how-to
author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2025-09-24T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: a2500afb-d30a-6b6c-2bd9-a6c7ed3d5f70
document_version_independent_id: 0aa17341-d35d-419a-a8f3-f6409e6de115
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/howto-upgrade-windows-os.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/howto-upgrade-windows-os
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/howto-upgrade-windows-os.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 9ec0ec17-3f0d-0e7b-bcdb-9901f46e5580
---

# Upgrade the Windows Server version on your node pools | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This article describes the steps to upgrade the OS version for Windows workloads on AKS. While this example focuses on the upgrade from Windows Server 2019 to Windows Server 2022, you can follow the same process to upgrade from any Windows Server version to another version.

## Windows Server OS version support

When a new version of the Windows Server operating system is released, AKS is committed to supporting it, and recommends that you upgrade to the latest version to take advantage of its fixes, improvements, and new functionality.

Important

Windows Server 2019 is being retired in March 2026. Azure Local version 2510 will be the last release to include the Windows Server 2019 VHDs. The last Kubernetes version available on Windows Server 2019 is 1.32. Windows Server 2019 won't be supported on 1.33 and later. For more information, see [Windows Server 2019 node pool retirement](https://techcommunity.microsoft.com/blog/containers/announcing-the-3-year-retirement-of-windows-server-2019-on-azure-kubernetes-serv/3777341).

Windows Server 2022 is being retired in October 2026. Azure Local version 2603 will be the last release to include the Windows Server 2022 VHDs. The last Kubernetes version available on Windows Server 2022 is 1.34. Windows Server 2022 won't be supported on 1.35 and later.

## Before you begin

- Update the FROM statement in your Dockerfile to the new OS version.
- Check your application and verify the container app works on the new OS version.
- Deploy the verified containerized application on AKS in a development or testing environment.
- Take note of the new image name or tag for use in this article.
- Ensure that the [Windows node pool feature is enabled](howto-enable-windows-node-pools) on your AKS cluster.

## Add a new Windows-based node pool to an existing cluster

Select the right OS SKU and create a new [Windows-based node pool](howto-create-windows-node-pools) on your AKS cluster.

### gMSA authentication isn't supported for Windows node pools on Azure Local 23H2 and 24H2

[Group Managed Service Account (gMSA)](/en-us/windows-server/identity/ad-ds/manage/group-managed-service-accounts/group-managed-service-accounts/group-managed-service-accounts-overview) authentication for Windows node pools isn't supported on AKS on Azure Local 23H2 and 24H2 or Windows node pools that require gMSA-based authentication for Active Directory access.

The gMSA components are preinstalled on Windows node pools, but the configuration path to set up gMSA authentication isn't available through CLI commands, APIs, or other management tools. Customers who follow standard Kubernetes documentation for Windows containers and create a credential spec receive anonymous sign-in failures because the required `HostAccountConfig` configuration isn't supported.

For example, after deploying a Windows container workload that requires gMSA-based authentication (Kerberos or NTLM), pods fail to authenticate against Active Directory. Applications receive `NT AUTHORITY\ANONYMOUS LOGON` errors for all Kerberos and NTLM authentication calls from the container.

An option to resolve this limitation is to move workloads to a platform that supports gMSA for Windows nodes, like Azure Kubernetes Service (AKS). For more information, see how to [enable gMSA for Windows Server nodes on an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/use-group-managed-service-accounts).

## Update the application YAML to use the new OS SKU

A node selector is the most common and recommended option for placement of Windows pods on Windows nodes.

1. Update the `nodeSelector` field in your application's deployment YAML to match the label of the new Windows node pool.

    ```yaml
    nodeSelector:
         "kubernetes.azure.com/os-sku": Windows2022
    ```

    This enforces the placement of the pod on a Windows node that's running the latest OS version.
2. Once you update the `nodeSelector` in the YAML file, you also need to update the container image you want to use. You can get this information from the previous step in which you created a new version of the containerized application by changing the FROM statement on your Dockerfile.

    Note

    You should use the same YAML file you used to initially deploy the application. This ensures that no other configuration changes besides the nodeSelector and container image.

## Apply the updated YAML file to the existing workload

1. View the nodes on your cluster using the `kubectl get nodes` command:

    ```bash
    kubectl get nodes -o wide
    ```

    This command shows all the nodes on your cluster, including the new node pool you created and the existing node pools.
2. Apply the updated YAML file to the existing workload using the `kubectl apply` command, and specify the name of the YAML file:

    ```bash
    kubectl apply -f <filename>
    ```

    At this point, AKS starts the process of terminating the existing pods and deploying new pods to the Windows Server 2022 nodes.
3. Check the status of the deployment using the `kubectl get pods` command.

    ```bash
    kubectl get pods -o wide
    ```

You should now see the pods running on the new Windows node pool you created. You can now delete the old Windows node pool that's running on the older Windows SKU.