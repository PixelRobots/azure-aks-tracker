---
layout: Conceptual
title: Enable the Kubernetes Event-driven Autoscaling (KEDA) add-on on an existing AKS cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/enable-keda-existing-cluster
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
description: Use the Azure portal to enable the Kubernetes Event-driven Autoscaling (KEDA) add-on on an existing Azure Kubernetes Service (AKS) cluster.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.date: 2024-09-19T00:00:00.0000000Z
ms.custom: aks-scaling
locale: en-us
document_id: 5fad618b-c5aa-0c71-5e49-08c0f73c98cd
document_version_independent_id: fee04808-64e7-1747-12c0-64c78ccf9d66
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/enable-keda-existing-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/enable-keda-existing-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/enable-keda-existing-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1f6f8cfe-312b-0610-b2a2-81d752fbd39e
---

# Enable the Kubernetes Event-driven Autoscaling (KEDA) add-on on an existing AKS cluster - Azure Kubernetes Service | Microsoft Learn

Important

The KEDA add-on for AKS doesn't currently support modifying the CPU requests or limits and other Helm values for the [Metrics Server](https://keda.sh/docs/2.14/operate/metrics-server/) or [Operator](https://keda.sh/docs/2.14/operate/cluster/). Keep this limitation in mind when using the add-on. If you have any questions, feel free to reach out [here](https://github.com/Azure/AKS/issues).

This article shows you how to enable the Kubernetes Event-driven Autoscaling (KEDA) add-on on an existing Azure Kubernetes Service (AKS) cluster using the Azure portal.

Important

Your cluster Kubernetes version determines what KEDA version will be installed on your AKS cluster. To see which KEDA version maps to each AKS version, see the **AKS managed add-ons** column of the [Kubernetes component version table](/en-us/azure/aks/supported-kubernetes-versions#aks-components-breaking-changes-by-version).

For GA Kubernetes versions, AKS offers full support of the corresponding KEDA minor version in the table. Kubernetes preview versions and the latest KEDA patch are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](https://azure.microsoft.com/support/legal/faq/)

Note

KEDA version 2.15+ introduces a breaking change that [removes pod identity support](https://github.com/kedacore/keda/issues/5035). We recommend moving over to workload identity for your authentication if you're using pod identity. While the KEDA managed add-on doesn't currently run KEDA version 2.15, it will begin running it in the AKS preview version 1.31.

For more information on how to securely scale your applications with workload identity, please read our [tutorial](keda-workload-identity). To view KEDA's breaking change/deprecation policy, please read their [official documentation](https://github.com/kedacore/governance/blob/main/DEPRECATIONS.md).

## Before you begin

- An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- An existing AKS cluster. If you don't have an AKS cluster, create one using the steps in [Deploy an Azure Kubernetes Service (AKS) cluster](learn/quick-kubernetes-deploy-portal).
- Ensure you have firewall rules configured to allow access to the Kubernetes API server. For more information, see [Outbound network and FQDN rules for Azure Kubernetes Service (AKS) clusters](outbound-rules-control-egress#azure-global-required-network-rules).

Note

If you're using [Microsoft Entra Workload ID](/en-us/azure/aks/workload-identity-overview) and you enable KEDA before Workload ID, you need to restart the KEDA operator pods so the proper environment variables can be injected:

1. Restart the pods by running `kubectl rollout restart deployment keda-operator -n kube-system`.
2. Obtain KEDA operator pods using `kubectl get pod -n kube-system` and finding pods that begin with `keda-operator`.
3. Verify successful injection of the environment variables by running `kubectl describe pod <keda-operator-pod> -n kube-system`. Under `Environment`, you should see values for `AZURE_TENANT_ID`, `AZURE_FEDERATED_TOKEN_FILE`, and `AZURE_AUTHORITY_HOST`.

## Enable the KEDA add-on on an existing AKS cluster

1. Sign in to the [Azure portal](https://portal.azure.com/) and navigate to your AKS cluster resource.
2. From the service menu, under **Settings**, select **Application scaling** &gt; **Enable KEDA add-on**.

    It may take a few minutes for the changes to take effect.
3. Once the KEDA add-on is enabled, you can verify KEDA is running on your cluster.

## Verify KEDA is running on your cluster

1. From the service menu of your AKS cluster resource, under **Kubernetes resources**, select **Workloads**.
2. Select the **Pods** tab, and look for the `keda` pods. If they're listed, KEDA is successfully running on your cluster.

    ![Screenshot of the KEDA pods running on the existing AKS cluster.](media/enable-keda-existing-cluster/keda-pods.png)
3. Once you verify that KEDA is running, you can check the KEDA version on your cluster.

## Check the KEDA version on your cluster

1. From the service menu of your AKS cluster resource, under **Kubernetes resources**, select **Custom resources**.
2. Find the **keda.sh** resource. From there, you can view the KEDA version running on your cluster.

    ![Screenshot of the KEDA CRD that shows the KEDA version running on the AKS cluster.](media/enable-keda-existing-cluster/keda-version.png)

## Disable the KEDA add-on on an existing cluster

To disable the KEDA add-on, see [Disable the KEDA add-on on your AKS cluster](keda-deploy-add-on-cli#disable-the-keda-add-on-on-your-aks-cluster).