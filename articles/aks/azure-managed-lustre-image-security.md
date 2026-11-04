---
layout: Conceptual
title: Validate Azure Managed Lustre CSI Driver container image security - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-managed-lustre-image-security
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
description: Learn how to verify the integrity and origin of Azure Lustre CSI Driver container images using Notation CLI and AKS Image Integrity.
ms.topic: how-to
ms.subservice: aks-storage
ms.date: 2026-10-30T00:00:00.0000000Z
author: pauljewellmsft
ms.author: akashdubey
ms.reviewer: brianl
ms.custom: sfi-image-nochange
locale: en-us
document_id: 84382098-6571-de3b-2751-b7f5dba2bb3f
document_version_independent_id: ce736fd0-cb82-c278-2b61-e386276c50d7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-managed-lustre-image-security.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/azure-managed-lustre-image-security
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-managed-lustre-image-security.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ae365aa9-5e19-49e1-95cb-6d0af6f19080
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/06cefb7d-f6d5-4371-a867-a6339677d3ad
platformId: 36ccccbc-e9a5-0a81-49f5-004914af16f1
---

# Validate Azure Managed Lustre CSI Driver container image security - Azure Kubernetes Service | Microsoft Learn

Azure Lustre CSI Driver signs its container images so you can verify the integrity and origin of the images you use. The signing process uses a public/private key pair to prove that Microsoft built a container image by creating a digital signature and adding it to the image. This article provides the steps to verify that an image was signed by Microsoft.

## Understanding image security in Kubernetes system components

The version-pinned examples in the following section verify upstream v0.6.0 images that Helm and script installations use. For the alternative AKS CLI option in preview, see [Image security on AKS](azure-managed-lustre-overview#image-security). These examples don't establish the extension version or verify all of its component images.

## Pre-deployment image verification

Before you deploy the Azure Lustre CSI Driver, verify the digital signatures and authenticity of the container images by using Microsoft's public signing certificates.

### Verify image signatures with Notation CLI

1. **Download Notation CLI**:

    ```bash
    export NOTATION_VERSION=1.3.2
    curl -LO https://github.com/notaryproject/notation/releases/download/v$NOTATION_VERSION/notation_$NOTATION_VERSION\_linux_amd64.tar.gz
    sudo tar xvzf notation_$NOTATION_VERSION\_linux_amd64.tar.gz -C /usr/bin/ notation
    ```
2. **Download the Microsoft signing public certificate**:

    ```bash
    curl -sSL "https://www.microsoft.com/pkiops/certs/Microsoft%20Supply%20Chain%20RSA%20Root%20CA%202022.crt" -o msft_signing_cert.crt
    ```
3. **Add the certificate to notation CLI**:

    ```bash
    notation cert add --type ca --store supplychain msft_signing_cert.crt
    ```
4. **Check the certificate in notation**:

    ```bash
    notation cert ls
    ```

    The output of the command looks like the following example:

    ```output
    STORE TYPE  STORE NAME  CERTIFICATE
    ca          supplychain msft_signing_cert.crt
    ```
5. **Create a trust policy file for Azure Lustre CSI Driver images**:

    Create a file called `trustpolicy.json`:

    ```json
    {
        "version": "1.0",
        "trustPolicies": [
            {
                "name": "supplychain",
                "registryScopes": [ "*" ],
                "signatureVerification": {
                    "level" : "strict"
                },
                "trustStores": [ "ca:supplychain" ],
                "trustedIdentities": [
                    "x509.subject: CN=Microsoft SCD Products RSA Signing,O=Microsoft Corporation,L=Redmond,ST=Washington,C=US"
                ]
            }
        ]
    }
    ```
6. **Use notation to verify Azure Lustre CSI Driver images**:

    ```bash
    notation policy import trustpolicy.json
    export NOTATION_EXPERIMENTAL=1
    
    # Verify the Jammy image used by Jammy node pods
    notation verify --allow-referrers-api mcr.microsoft.com/oss/v2/kubernetes-csi/azurelustre-csi:v0.6.0-jammy
    
    # Verify the Noble image used by the controller and Noble node pods
    notation verify --allow-referrers-api mcr.microsoft.com/oss/v2/kubernetes-csi/azurelustre-csi:v0.6.0-noble
    
    # Verify the Azure Linux 3 image used by Azure Linux 3 node pods
    notation verify --allow-referrers-api mcr.microsoft.com/oss/v2/kubernetes-csi/azurelustre-csi:v0.6.0-azurelinux3
    ```

    The output of a successful verification looks like the following example:

    ```output
    Successfully verified signature for mcr.microsoft.com/oss/v2/kubernetes-csi/azurelustre-csi@sha256:a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
    ```

## Application workload image integrity

For application workloads, review AKS Image Integrity to validate container image signatures. Keep application policy configuration separate from extension lifecycle management.

To learn more about implementing image integrity policies for your application workloads, see [Image Integrity in Azure Kubernetes Service (AKS)](/en-us/azure/aks/image-integrity).