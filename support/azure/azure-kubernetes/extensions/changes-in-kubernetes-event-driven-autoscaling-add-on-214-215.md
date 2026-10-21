---
layout: Conceptual
title: Guide to prepare AKS clusters for KEDA 2.15 and 2.14 breaking changes - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/changes-in-kubernetes-event-driven-autoscaling-add-on-214-215
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Learn about KEDA 2.15 and 2.14 breaking changes in AKS and how to prepare your clusters. Follow this guide to avoid disruptions and stay up to date.
ms.service: azure-kubernetes-service
ms.date: 2025-03-03T00:00:00.0000000Z
ms.reviewer: albarqaw, v-weizhu
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: da592df7-8484-47a6-b65d-3ee067abca8f
document_version_independent_id: da592df7-8484-47a6-b65d-3ee067abca8f
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/changes-in-kubernetes-event-driven-autoscaling-add-on-214-215.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/changes-in-kubernetes-event-driven-autoscaling-add-on-214-215
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/changes-in-kubernetes-event-driven-autoscaling-add-on-214-215.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: fc3c2dc2-cb1c-ce36-6dae-1f86dad888ba
---

# Guide to prepare AKS clusters for KEDA 2.15 and 2.14 breaking changes - Azure | Microsoft Learn

## Summary

This article explores the key breaking changes that are introduced in Event-driven Autoscaling (KEDA) add-ons 2.15 and 2.14. It also provides information about how to prepare your Azure Kubernetes Service (AKS) clusters for these updates.

## KEDA 2.15 and 2.14 breaking changes

Your AKS cluster Kubernetes version determines which KEDA version will be installed on your AKS cluster. For AKS clusters that are running Kubernetes version 1.30, KEDA add-on version 2.14 is installed. The upcoming release of Kubernetes 1.32 on Azure will ship together with KEDA add-on version 2.15.

### KEDA 2.15

- [Removal of pod-managed identities support](https://github.com/kedacore/keda/issues/5035).

    If you're using pod-managed identities, we recommend that you migrate to [workload identity for authentication](/en-us/azure/aks/keda-workload-identity).

### KEDA 2.14

- [Removal of Azure Data Explorer 'metadata.clientSecret' as it wasn't safe for managing secrets](https://github.com/kedacore/keda/issues/4514).

    To ensure safe handling of secrets, use `clientSecretFromEnv` instead.
- [Removal of the deprecated `metricName` from trigger metadata section](https://github.com/kedacore/keda/issues/4240).

    The two affected Azure Scalers are **Azure Blob Scaler** and **Azure Log Analytics Scaler**. If you're using `metricName`, move `metricName` to outside the trigger metadata section to `trigger.name` in the trigger section to optionally name your trigger. The following examples show how to update configuration.

    Example before KEDA 2.14

    ```yaml
    triggers:
    - type: any-type
      metadata:
        metricName: "my-custom-name"
    ```

    Example by using KEDA 2.15 or 2.14

    ```yaml
    triggers:
    - type: any-type
      name: "my-custom-name"
      metadata:
    ```

## Frequently asked questions

### How can I determine whether my cluster is affected?

To determine whether your cluster is affected by the recent KEDA upgrades, follow these steps:

1. Identify the Kubernetes version of your AKS cluster.

    Clusters that are running Kubernetes versions 1.30 or later will be affected by the KEDA upgrades (2.15 or 2.14). If you're on version 1.29 or earlier, these updates will not affect you. However, if you plan to upgrade your AKS cluster to Kubernetes version 1.30 or 1.31, make sure to review the changes and prepare accordingly before you upgrade.

    To check the cluster version, run the following the Azure CLI command:

    ```
    az aks show --resource-group <your-resource-group> --name <your-cluster-name> --query kubernetesVersion
    ```

    Example of the output:

    ```output
    "1.30"
    ```
2. Review the configurations of KEDA Scalers that are currently deployed in your cluster. Check whether Microsoft Entra pod-managed Identities are used for authentication. The following command displays output only if you're using Pod Identity together with KEDA:

    ```bash
    kubectl get TriggerAuthentication --all-namespaces -o jsonpath='{range .items[?(@.spec.podIdentity.provider=="azure")]}{.metadata.namespace}{"/"}{.metadata.name}{"\n"}{end}'
    ```

    Example of the output:

    ```output
    NAME                      PODIDENTITY                 SECRET                 ENV            VAULTADDRESS  
    keda-trigger-auth-azure     yourPodIdentity    azure-secret                                  <URL>
    ```

### What steps can I take to mitigate the issues?

1. Migrate from Microsoft Entra pod-managed identities to workload identity for authentication. For more information, see [Use Microsoft Entra Workload ID with AKS](/en-us/azure/aks/workload-identity-overview?tabs=dotnet) and [Migrate from pod managed-identity to workload identity](/en-us/azure/aks/workload-identity-migrate-from-pod-identity).
2. Update Scaler Configurations to align with the new configuration requirements:

    - For **Azure Data Explorer Scaler**, replace `metadata.clientSecret` with `clientSecretFromEnv`. For more information about the `clientSecretFromEnv` definition, see [Trigger Specifications](https://keda.sh/docs/2.15/scalers/azure-data-explorer/).
    - For **Azure Blob Scaler** and **Azure Log Analytics Scaler**, move `trigger.metadata.metricName` to `trigger.name`.
3. Test changes in a nonproduction environment. Deploy the updated configurations in a staging or development environment to make sure that they work correctly and don't affect your applications.
4. Monitor logs and alerts. After you make changes, monitor the cluster logs for any warnings or errors that are related to the new KEDA configuration and behavior.

### How can I get support if I have follow-up questions?

If you have questions or need help, [create a support request for KEDA add-on](https://ms.portal.azure.com/#create/Microsoft.Support/Parameters/%7B%0D%0A%09%22subId%22%3A+%22%22%2C%0D%0A%09%22pesId%22%3A+%2216450%22%2C%0D%0A%09%22supportTopicId%22%3A+%2232844723%22%2C%0D%0A%09%22contextInfo%22%3A+%22Keda214215%22%2C%0D%0A%09%22caller%22%3A+%22Keda214215comms%22%2C%0D%0A%09%22severity%22%3A+%223%22%0D%0A%7D).

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.