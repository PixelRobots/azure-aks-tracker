---
layout: Conceptual
title: AKS Edge Essentials offline installation | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-offline-install
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
description: Learn how to configure your machine for AKS Edge Essentials offline installation.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-how-to, edge-essentials
locale: en-us
document_id: a14364d8-c168-96fe-3a42-543ef9fe9542
document_version_independent_id: f731af8c-1972-e489-f144-4abda9875957
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-offline-install.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-offline-install
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-offline-install.md
platformId: d3365332-c038-e071-90bd-0450ce6c426d
---

# AKS Edge Essentials offline installation | Microsoft Learn

AKS Edge Essentials is primarily designed to be installed on an internet-connected machine, since many components are updated regularly. However, with some extra steps, it's possible to deploy AKS Edge Essentials in an offline environment.

The following article describes the required configuration needed for an AKS Edge Essentials offline installation:

- Windows certificates
- Internet checks
- Licensing

## Windows certificates

The AKS Edge Essentials setup only installs content that is trusted. It verifies that trust by checking Authenticode signatures of the content being downloaded and verifying that all content is trusted before installing it. Also, the **AKSEdge.psm1** PowerShell module and cmdlets used to deploy the cluster are signed and verified. This keeps your environment safe from attacks where the download location is compromised.

Therefore, AKS Edge Essentials setup requires that several standard Microsoft root and intermediate certificates are installed and up-to-date on a user's machine. If the machine has been kept up to date with Windows Update, signing certificates usually are up to date. If the machine is offline, the certificates must be refreshed another way.

One way to check on the installing system is to follow these steps:

1. Open an elevated PowerShell session.
2. Check for the **Microsoft Root Certificate Authority 2011** by running the following command:

    ```powershell
    Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object {$_.Subject -like "CN=Microsoft Root Certificate Authority 2011*"}
    ```

    If the **Microsoft Root Certificate Authority 2011** is installed on this machine, you should see the following output:

    ```output
    PSParentPath: Microsoft.PowerShell.Security\Certificate::LocalMachine\Root
    
    Thumbprint                                Subject
    ----------                                -------
    8F43288AD272F3103B6FB1428485EA3014C0BCFE  CN=Microsoft Root Certificate Authority 2011, O=Microsoft Corporation, L=R...
    ```
3. Check for the **Microsoft Code Signing PCA 2011** by running the following command:

    ```powershell
    Get-ChildItem -Path Cert:\LocalMachine\CA | Where-Object {$_.Subject -like "CN=Microsoft Code Signing PCA 2011*"}
    ```

    If the **Microsoft Code Signing PCA 2011** is installed on this machine, you should see the following output:

    ```output
    PSParentPath: Microsoft.PowerShell.Security\Certificate::LocalMachine\CA
    
    Thumbprint                                Subject
    ----------                                -------
    F252E794FE438E35ACE6E53762C0A234A2C52135  CN=Microsoft Code Signing PCA 2011, O=Microsoft Corporation, L=Redmond, S=...
    ```

If the **Microsoft Code Signing PCA 2011** intermediate certificate was only in the **Current User** intermediate certificate store, then it's available only to the user that is signed in. You might need to install it for other users.

### Install or refresh certificates when offline

There are two options for installing or updating certificates in an offline environment.

#### Option 1: install certificates manually or as part of a scripted deployment

If you're scripting the deployment of AKS Edge Essentials in an offline environment to client workstations, follow these steps:

1. Open an elevated PowerShell session.
2. Download the necessary certificates:

    1. [MicrosoftRootCertificateAuthority2011.cer](https://download.microsoft.com/download/2/4/8/248D8A62-FCCD-475C-85E7-6ED59520FC0F/MicrosoftRootCertificateAuthority2011.cer)
    2. [MicCodSigPCA2011.crt](https://www.microsoft.com/pkiops/certs/MicCodSigPCA2011_2011-07-08.crt)
3. Manually run the following commands or add them to your AKS Edge Essentials installation script:

    ```powershell
    certutil.exe -addstore -f "AuthRoot" "[download path]\MicrosoftRootCertificateAuthority2011.cer"
    
    certutil.exe -addstore -f "CA" "[download path]\MicCodSigPCA2011_2011-07-08.crt"
    ```
4. To check if the certificates were correctly installed, use the PowerShell commands provided in the Windows certificates section.

#### Option 2: distribute trusted root certificates in an enterprise environment

For enterprises with offline machines that don't have the latest root certificates, an administrator can use the instructions in [Configure Trusted Roots and Disallowed Certificates](/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/dn265983%28v=ws.11%29) to update them.

## Internet checks

During the deployment of an AKS Edge Essentials cluster, the PowerShell deployment script checks for internet connectivity. These checks are to make sure that DNS servers work, the cluster is able to connect to the internet, and that an Arc connection can be established if the user wants this. However, when doing offline installations, these checks aren't required and should be avoided.

During the creation of the [deployment JSON file](aks-edge-howto-setup-machine), ensure that you mark the `InternetDisabled` parameter inside the `Networking` section as **true**.

## Configure your network adaptors

During deployment, AKS Edge Essentials needs an adapter that is enabled and has the correct IP address, subnet, and default gateway properties. These values are automatically populated in a DHCP environment. If you're setting manually, ensure that all three properties are set before you begin deployment.

## Licensing

You can license AKS Edge Essentials offline deployments for commercial use using the **Volume licensing model**. AKS Edge Essentials is licensed and priced as a per-device, per-month model. Each licensed unit is applied to a device in your cluster. For more licensing information, see [AKS Edge Essentials - Licensing](aks-edge-licensing).