---
layout: Conceptual
title: Control plane configuration validation errors | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/control-plane-validation-errors
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
description: Learn details about each control plane configuration validation error.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: troubleshooting
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: a49cb334-dc23-e164-d6a9-25c922bb069d
document_version_independent_id: 15d5fd13-2809-00fc-7b54-ffca804a8723
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/control-plane-validation-errors.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/control-plane-validation-errors
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/control-plane-validation-errors.md
platformId: 4a628b6e-f401-7f6e-d79b-1715a61abc07
---

# Control plane configuration validation errors | Microsoft Learn

This article describes how to identify and resolve [ControlPlaneConfigurationValidation](configure-ssh-keys) error codes that can occur when you create and deploy an AKS cluster on Azure Local.

## Symptoms

When you try to create an AKS cluster, you receive an error message that appears as follows:

```json
admission webhook "vhybridakscluster.kb.io" denied the request: { 
   "result": "Failed", 
   "validationChecks": [ 
      { 
         "name": "ControlPlaneConfigurationValidation", 
         "message": "ControlPlane: Global LinuxProfile SSH public keys should be valid and non-empty. ssh: no key found", 
         "recommendation": "Please check https://aka.ms/AKSArcValidationErrors/ControlPlaneConfigurationValidation for recommendations" 
      } 
   ] 
}
```

The following section describes the error messages that you might see when you encounter the **ControlPlaneConfigurationValidation** error code.

## Global LinuxProfile SSH public keys must be valid and non-empty

If you don't provide valid SSH key information during Kubernetes cluster creation and no SSH key exists, you receive error messages similar to the following:

- An RSA key file or key value must be supplied to SSH Key Value.
- Control Plane: Missing Security Keys in Cluster Configuration.
- LinuxProfile SSH public keys should be valid and non-empty.
- Global LinuxProfile SSH public keys should be valid and non-empty.

To mitigate the issue, see [Generate and store SSH keys with the Azure CLI](/en-us/azure/virtual-machines/ssh-keys-azure-cli#generate-new-keys) to create the SSH keys. Then, see [Create Kubernetes clusters](../aks-create-clusters-cli) for the interface you're using. If you're using the REST API, see [provisioned cluster instances](/en-us/rest/api/hybridcontainer/provisioned-cluster-instances) to create the provisioned cluster instance.

## Control plane count and VM size

In Kubernetes, control plane nodes manage and orchestrate the cluster. They run key components such as API Server, etcd, scheduler, etc. Control plane nodes maintain cluster state, schedule workloads, and ensure high availability, often using multiple nodes for redundancy.

To successfully create an AKS cluster, you must specify at least one control plane node count. Also, to maintain etcd quorum, the control plane node count should be an odd number. For more information about supported count and VM SKU options, see [Scale requirements for AKS on Azure Local](scale-requirements#support-count-for-aks-on-azure-local).