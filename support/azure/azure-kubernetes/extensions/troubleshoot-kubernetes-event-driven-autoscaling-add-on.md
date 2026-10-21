---
layout: Conceptual
title: Troubleshoot the Kubernetes Event-driven Autoscaling (KEDA) add-on - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-kubernetes-event-driven-autoscaling-add-on
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
description: Learn how to troubleshoot the Kubernetes Event-driven Autoscaling (KEDA) add-on in AKS, fix common scaling errors, and restore autoscaling now.
ms.service: azure-kubernetes-service
ms.date: 2024-08-13T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: nickoman, v-leedennis, v-weizhu
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: f75e032d-b34a-82ea-93d9-56a37874d423
document_version_independent_id: f75e032d-b34a-82ea-93d9-56a37874d423
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-kubernetes-event-driven-autoscaling-add-on.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-kubernetes-event-driven-autoscaling-add-on
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-kubernetes-event-driven-autoscaling-add-on.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d9f0a4d5-29d0-d374-19b1-c2d9a3525422
---

# Troubleshoot the Kubernetes Event-driven Autoscaling (KEDA) add-on - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot the Kubernetes Event-driven Autoscaling (KEDA) add-on to the Microsoft Azure Kubernetes Service (AKS). When you deploy the KEDA AKS add-on, you might experience problems that are associated with the configuration of the application autoscaler. This article will help you troubleshoot errors and resolve common problems that affect the add-on but aren't covered in the official KEDA [FAQ](https://keda.sh/docs/latest/reference/faq/) and [troubleshooting guide](https://keda.sh/docs/latest/troubleshooting/).

## Prerequisites

- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool. To install kubectl by using the [Azure CLI](/en-us/cli/azure/install-azure-cli), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.

## KEDA add-on support

The KEDA add-on follows a similar support model to other [AKS add-ons](/en-us/azure/aks/integrations). All [Azure KEDA scalers](https://keda.sh/docs/scalers/) are supported, but AKS doesn't support third-party scalers. If you encounter issues with third-party scalers, open an issue in the official [KEDA GitHub repository](https://github.com/kedacore/keda).

## Troubleshooting checklist

Verify and troubleshoot KEDA components by using the instructions in the following sections.

### Check the available KEDA version

You can determine the available KEDA version by using the [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command:

```bash
kubectl get crd/scaledobjects.keda.sh -o custom-columns='APP:.metadata.labels.app\.kubernetes\.io/version'
```

The command output displays the installed version of KEDA:

```output
APP
2.8.1
```

### Make sure that the cluster firewall is configured correctly

KEDA might not scale applications successfully because it can't start.

When you check the operator logs, you might find error entries that resemble the following text:

```output
1.6545953013458195e+09 ERROR Failed to get API Group-Resources {"error": "Get \"https://10.0.0.1:443/api?timeout=32s\": EOF"}
sigs.k8s.io/controller-runtime/pkg/cluster.New
/go/pkg/mod/sigs.k8s.io/controller-runtime@v0.11.2/pkg/cluster/cluster.go:160
sigs.k8s.io/controller-runtime/pkg/manager.New
/go/pkg/mod/sigs.k8s.io/controller-runtime@v0.11.2/pkg/manager/manager.go:313
main.main
/workspace/main.go:87
runtime.main
/usr/local/go/src/runtime/proc.go:255
1.6545953013459463e+09 ERROR setup unable to start manager {"error": "Get \"https://10.0.0.1:443/api?timeout=32s\": EOF"}
main.main
/workspace/main.go:97
runtime.main
/usr/local/go/src/runtime/proc.go:255
```

In the metric server section, you might discover that KEDA can't start:

```output
I0607 09:53:05.297924 1 main.go:147] keda_metrics_adapter "msg"="KEDA Version: 2.7.1"
I0607 09:53:05.297979 1 main.go:148] keda_metrics_adapter "msg"="KEDA Commit: "
I0607 09:53:05.297996 1 main.go:149] keda_metrics_adapter "msg"="Go Version: go1.17.9"
I0607 09:53:05.298006 1 main.go:150] keda_metrics_adapter "msg"="Go OS/Arch: linux/amd64"
E0607 09:53:15.344324 1 logr.go:279] keda_metrics_adapter "msg"="Failed to get API Group-Resources" "error"="Get \"https://10.0.0.1:443/api?timeout=32s\": EOF"
E0607 09:53:15.344360 1 main.go:104] keda_metrics_adapter "msg"="failed to setup manager" "error"="Get \"https://10.0.0.1:443/api?timeout=32s\": EOF"
E0607 09:53:15.344378 1 main.go:209] keda_metrics_adapter "msg"="making provider" "error"="Get \"https://10.0.0.1:443/api?timeout=32s\": EOF"
E0607 09:53:15.344399 1 main.go:168] keda_metrics_adapter "msg"="unable to run external metrics adapter" "error"="Get \"https://10.0.0.1:443/api?timeout=32s\": EOF"
```

This scenario probably means that the KEDA add-on isn't able to start because of a misconfigured firewall. To make sure that KEDA runs correctly, configure the firewall to meet the [Azure Global required network rules](/en-us/azure/aks/limit-egress-traffic#azure-global-required-network-rules).

### Enable the add-on for clusters with self-managed open-source KEDA installations

In theory, you can install KEDA many times, even though Kubernetes allows only one metric server to be installed. However, we don't recommend multiple installations because only one installation would work.

When the KEDA add-on is installed on an AKS cluster, the previous installation of open-source KEDA will be overridden, and the add-on will take over. In this scenario, the customization and configuration of the self-installed KEDA deployment will be lost and no longer applied.

Though the existing autoscaling might continue to be operational, this situation introduces a risk. The KEDA add-on will be configured differently, and it won't support features such as managed identity. To prevent errors during the installation, we recommend that you uninstall existing KEDA installations before you enable the KEDA add-on.

To determine which metrics adapter is used by KEDA, run the `kubectl get` command:

```bash
kubectl get APIService/v1beta1.external.metrics.k8s.io -o custom-columns='NAME:.spec.service.name,NAMESPACE:.spec.service.namespace'
```

An overview shows the service and namespace that Kubernetes will use to get metrics:

```output
NAME                              NAMESPACE
keda-operator-metrics-apiserver   kube-system
```

Warning

If the namespace isn't `kube-system`, the AKS add-on is being ignored, and another metric server is being used.

### How to restart KEDA operator pods when workload identity isn't injected properly

If you're using [Microsoft Entra Workload ID](/en-us/azure/aks/workload-identity-overview) and you enable KEDA before the Workload ID is used, you must restart the KEDA operator pods. This ensures the correct environment variables are injected. To do this, follow these steps:

1. Restart the pods by running the following command:

    ```bash
    kubectl rollout restart deployment keda-operator -n kube-system
    ```
2. Obtain KEDA operator pods by running the following command, and then locate pods with names starting with 'keda-operator'.

    ```bash
    kubectl get pod -n kube-system
    ```
3. To verify that the environment variables have been successfully injected, run the following command:

    ```bash
    kubectl describe pod <keda-operator-pod-name> -n kube-system
    ```

    If the variables have been successfully injected, you should see values for `AZURE_TENANT_ID`, `AZURE_FEDERATED_TOKEN_FILE`, and `AZURE_AUTHORITY_HOST` in the **Environment** section.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.