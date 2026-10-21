---
layout: Conceptual
title: Configure group Managed Service Accounts (gMSA) for Windows containers with Azure Kubernetes Service on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/prepare-windows-nodes-gmsa
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
description: Learn how to configure  Managed Service Accounts (gMSA) for containers on Windows nodes
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server
locale: en-us
document_id: 41319767-6315-c395-47d4-1a6433258c08
document_version_independent_id: 3ff2e68c-6660-dc8a-1ca0-2f902397491e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/prepare-windows-nodes-gmsa.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/prepare-windows-nodes-gmsa
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/prepare-windows-nodes-gmsa.md
platformId: efb9981b-5a9e-12c8-0c83-ce9997f51620
---

# Configure group Managed Service Accounts (gMSA) for Windows containers with Azure Kubernetes Service on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

To use AD Authentication, you can configure group Managed Service Accounts (gMSA) for Windows containers to run with a non-domain joined host. A [group Managed Service Account](/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview) is a special type of service account introduced in Windows Server 2012 that's designed to allow multiple computers to share an identity without knowing the password. Windows containers can't be domain joined, but many Windows applications that run in Windows containers still need AD Authentication.

Note

To learn how the Kubernetes community supports using gMSA with Windows containers, see [Configure gMSA](https://kubernetes.io/docs/tasks/configure-pod-container/configure-gmsa).

## Architecture of gMSA for containers with a non-domain joined host

gMSA for containers with a non-domain joined host uses a portable user identity instead of a host identity to retrieve gMSA credentials. Therefore, you don't need to manually join Windows worker nodes to a domain. The user identity is saved as a secret in Kubernetes. The following diagram shows the process for configuring gMSA for containers with a non-domain joined host:

![Diagram of group Managed Service Accounts version two](../media/gmsa/gmsa-v-2.png)

gMSA for containers with a non-domain joined host provides the flexibility of creating containers with gMSA without joining the host node to the domain. Starting with Windows Server 2019, ccg.exe is supported, which enables a plug-in mechanism to retrieve gMSA credentials from Active Directory. You can use that identity to start the container. For more information on ccg.exe, see [ICcgDomainAuthCredentials interface](/en-us/windows/win32/api/ccgplugins/nn-ccgplugins-iccgdomainauthcredentials).

## Comparison of gMSA for containers with a non-domain joined host and a domain joined host

When gMSA was initially introduced, it required the container host to be domain joined, which created a lot of overhead to join Windows worker nodes manually to a domain. This limitation was addressed with gMSA for containers with a non-domain joined host, so you can now use gMSA with domain-unjoined hosts. Other improvements to gMSA include the following features:

- Eliminating the requirement to manually join Windows worker nodes to a domain. For scaling scenarios, this simplification helps.
- In rolling update scenarios, you no longer need to rejoin the node to a domain.
- An easier process for managing the worker node machine accounts to retrieve gMSA service account passwords.
- A less complicated end-to-end process to configure gMSA with Kubernetes.

## Before you begin

To run a Windows container with a group managed service account, you need the following prerequisites:

- An Active Directory domain with at least one domain controller running Windows Server 2012 or later. There are no forest or domain functional level requirements to use gMSAs, but only domain controllers running Windows Server 2012 or later can distribute gMSA passwords. For more information, see [Active Directory requirements for gMSAs](/en-us/windows-server/security/group-managed-service-accounts/getting-started-with-group-managed-service-accounts#BKMK_gMSA_Req).
- Permission to create a gMSA account. To create a gMSA account, you must be a Domain Administrator or use an account that has permissions to create **msDS-GroupManagedServiceAccount** objects.
- Access to the internet to download the [CredentialSpec](https://aka.ms/credspec) PowerShell module. If you're working in a disconnected environment, you can [save the module](/en-us/powershell/module/powershellget/save-module?preserve-view=true&amp;view=powershell-5.1) on a computer with internet access and copy it to your development machine or container host.
- To ensure gMSA and AD authentication work, ensure that the Windows Server cluster nodes are configured to synchronize their time with either a domain controller or other time source. You should also make sure Hyper-V is configured to synchronize time to any virtual machines.

## Prepare the gMSA in the domain controller

Follow these steps to prepare the gMSA in the domain controller:

1. In the domain controller, [prepare Active Directory](/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#one-time-preparation-of-active-directory) and [create the gMSA account](/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#create-a-group-managed-service-account).
2. Create a domain user account. Save this user account and password credentials as a Kubernetes secret. Use these credentials to retrieve the gMSA password.
3. To create a gMSA account and grant permission to read the password for the gMSA account created in Step 2, run the following [New-ADServiceAccount](/en-us/powershell/module/activedirectory/new-adserviceaccount?preserve-view=true&amp;view=windowsserver2019-ps) PowerShell command:

    ```powershell
     New-ADServiceAccount -Name "<gmsa account name>" -DnsHostName "<gmsa account name>.<domain name>.com" -ServicePrincipalNames "host/<gmsa account name>", "host/<gmsa account name>.<domain name>.com" -PrincipalsAllowedToRetrieveManagedPassword <username you created earlier> 
    ```

    For `-PrincipalsAllowedToRetrieveManagedPassword`, specify the domain username you created earlier as shown in the following example:

    ```powershell
    New-ADServiceAccount -Name "WebApp01" -DnsHostName "WebApp01.akshcitest.com" -ServicePrincipalNames "host/WebApp01", "host/WebApp01.akshcitest.com" -PrincipalsAllowedToRetrieveManagedPassword "testgmsa"
    ```

## Prepare the gMSA credential spec JSON file

To prepare the gMSA credential spec JSON file, follow the steps for [creating a credential spec](/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#create-a-credential-spec).

## Configure gMSA for Windows pods and containers in the cluster

The Kubernetes community already supports domain joined Windows worker nodes for [gMSA](https://kubernetes.io/docs/tasks/configure-pod-container/configure-gmsa/). Although you don't need to domain join a Windows worker node in AKS on Windows Server, you need to complete other configuration steps. These steps include installing the webhook, the custom resource definition (CRD), and the credential spec, and enabling role-based access control (RBAC role). The following steps use PowerShell commands that simplify the configuration process.

Before completing the following steps, make sure you install the **AksHci** PowerShell module and `kubectl` can connect to your cluster.

1. To install the webhook, run the following [Install-AksHciGmsaWebhook](/en-us/azure/aks/aksarc/reference/ps/install-akshcigmsawebhook) PowerShell command:

    ```powershell
    Install-AksHciGMSAWebhook -Name <cluster name>
    ```

    To validate that the webhook pod is running, run the following command:

    ```powershell
    kubectl get pods -n kube-system | findstr gmsa
    ```

    You should see one pod with the *gmsa-webhook* prefix that is running.
2. Create the secret object that stores the Active Directory user credential. Complete the following configuration data and save the settings into a file named secret.yaml.

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
       name: <secret-name>
       namespace: <secret under namespace other than the default>
    type: Opaque
    stringData:
       domain: <FQDN of the domain, for example: akshcitest.com>
       username: <domain user who can retrieve the gMSA password>
       password: <password>
    ```

    Then, run the following command to create the secret object:

    ```powershell
    kubectl apply -f secret.yaml
    ```

    Note

    If you create a secret under a namespace other than the default, remember to set the namespace of the deployment to the same namespace.
3. Use the [Add-AksHciGMSACredentialSpec](/en-us/azure/aks/aksarc/reference/ps/add-akshcigmsacredentialspec) PowerShell cmdlet to create the gMSA CRD, enable role-based access control (RBAC), and then assign the role to the service accounts to use a specific gMSA credential spec file. These steps are described in more detail in this Kubernetes article on [Configure gMSA for Windows pods and containers](https://kubernetes.io/docs/tasks/configure-pod-container/configure-gmsa/).

    Use the JSON credential spec as input for the following PowerShell command (parameters with asterisks \* are mandatory):

    ```powershell
    Add-AksHciGMSACredentialSpec -Name <cluster name>*
      -credSpecFilePath <path to JSON credspec>*
      -credSpecName <name for credspec as the k8s GMSACredentialSpec object>*
      -secretName <name of secret>*
      -secretNamespace <namespace of secret>
      -serviceAccount <name of service account to bind to clusterrole>
      -clusterRoleName <name of clusterrole to use the credspec>*
      -overwrite
    ```

    To view an example, see the following code:

    ```powershell
    Add-AksHciGMSACredentialSpec -Name mynewcluster
      -credSpecFilePath .\credspectest.json
      -credSpecName credspec-mynewcluster
      -secretName mysecret
      -clusterRoleName clusterrole-mynewcluster
    ```

## Deploy the application

Create the deployment YAML file using the following example settings. The required entries include `serviceAccountName`, `gmsaCredentialSpecName`, `volumeMounts`, and `dnsconfig`.

1. Add the service account:

    ```yaml
    serviceAccountName: default
       securityContext:
         windowsOptions:
           gmsaCredentialSpecName:
    ```
2. Add the credential spec object:

    ```yaml
    securityContext:
         windowsOptions:
           gmsaCredentialSpecName: <cred spec name>
    ```
3. Mount the secret for the deployment:

    ```yaml
    volumeMounts:
         - name: <volume name>
           mountPath: <vmount path>
           readOnly: true
       volumes:
         - name: <volume name>
           secret:
             secretName: <secret name>
             items:
               - key: username
                 path: my-group/my-username
    ```
4. Add the IP address of the domain controller and domain name under dnsConfig:

    ```yaml
    dnsConfig:
         nameservers:
           - <IP address for domain controller>
         searches:
           - <domain>
    ```

## Verify the container is working with gMSA

After you deploy the container, use the following steps to verify that it's working:

1. Get the container ID for your deployment by running the following command:

    ```console
    kubectl get pods
    ```
2. Open PowerShell and run the following command:

    ```powershell
    kubectl exec -it <container id> powershell
    ```
3. Once you're in the container, run the following command:

    ```console
    Nltest /parentdomain
    Nltest /sc_verify:<domain>
    ```

    ```output
    Connection Status = 0 0x0 NERR_Success The command completed successfully.
    ```

    This output shows that the computer was authenticated by a domain controller, and a secure channel exists between the client computer and the domain controller.
4. Check if the container can obtain a valid Kerberos Ticket Granting Ticket (TGT).

    ```console
    klist get krbtgt
    ```

    ```output
    A ticket to krbtgt has been retrieved successfully
    ```

## Clean up gMSA settings in the cluster

If you need to clean up gMSA settings, use the following uninstall steps.

### Uninstall the credential spec

To uninstall, run the following [Remove-AksHcigmsaCredentialSpec](/en-us/azure/aks/aksarc/reference/ps/remove-akshcigmsacredentialspec) PowerShell command:

```powershell
Remove-AksHciGMSACredentialSpec -Name <cluster name> -credSpecName <cred spec object name> -clusterRoleName <clusterrole object name> -serviceAccount <serviceaccount object name> -secretNamespace <namespace of the secret object>
```

### Uninstall webhook

To uninstall the webhook, run the following [Uninstall-AksHciGMSAWebhook](/en-us/azure/aks/aksarc/reference/ps/uninstall-akshcigmsawebhook) PowerShell command:

```powershell
Uninstall-AksHciGMSAWebhook -Name <cluster name>
```