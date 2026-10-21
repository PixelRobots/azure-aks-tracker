---
layout: Conceptual
title: AKS Regulated Cluster for PCI DSS 4.0.1 - Enhanced MFA Implementation - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pci-enhanced-mfa-implementation
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
description: Enhanced multifactor authentication (MFA) implementation guidance for AKS clusters under PCI DSS 4.0.1.
ms.date: 2025-06-25T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: schaffererin
ms.author: schaffererin
ms.custom:
- pci-dss
- compliance
locale: en-us
document_id: 7afa9664-4343-ca3e-c465-8c3fb6d72f32
document_version_independent_id: bfebd395-3450-27fd-cb43-dec4b1aa64cc
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pci-enhanced-mfa-implementation.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/pci-enhanced-mfa-implementation
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pci-enhanced-mfa-implementation.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
platformId: df3d3b62-5838-348f-9ce1-418e758b12f9
---

# AKS Regulated Cluster for PCI DSS 4.0.1 - Enhanced MFA Implementation - Azure Kubernetes Service | Microsoft Learn

This article describes enhanced multifactor authentication (MFA) considerations for an Azure Kubernetes Service (AKS) cluster that's configured in accordance with the Payment Card Industry Data Security Standard (PCI DSS 4.0.1).

> 
> This article is part of a series. Read the [introduction](pci-intro).

PCI DSS 4.0.1 significantly expands MFA requirements for all access to the cardholder data environment (CDE) and cloud administrative access. This architecture and the implementation are focused on infrastructure and not the workload. This article provides general considerations and best practices to help you make design decisions. Follow the requirements in the official PCI-DSS 4.0.1 standard and use this article as additional information, where applicable.

Important

The guidance and the accompanying implementation builds on the [AKS baseline architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks), which is based on a hub-spoke network topology. The hub virtual network contains the firewall to control egress traffic, gateway traffic from on-premises networks, and a third network for maintenance. The spoke virtual network contains the AKS cluster that provides the card-holder environment (CDE), and hosts the PCI DSS workload.

![GitHub logo](media/pci-dss/github.png)**Reference Implementation Coming Soon**: The Azure Kubernetes Service (AKS) baseline cluster for regulated workloads reference implementation for PCI DSS 4.0.1 is currently being updated and will be available soon. This implementation will demonstrate a regulated infrastructure that illustrates the use of various network and security controls within your CDE. This includes both network controls native to Azure and controls native to Kubernetes. It will also include an application to demonstrate the interactions between the environment and a sample workload. The focus of this article is the infrastructure. The sample will not be indicative of an actual PCI-DSS 4.0.1 workload.

## Restrict access to cardholder data by business need to know

Note

This article has been updated for PCI DSS 4.0.1. Major changes include expanded MFA requirements for all access to the CDE, enhanced authentication for cloud administrative access, and stronger controls for privileged access. Ensure you review the official [PCI DSS 4.0.1 documentation](https://www.pcisecuritystandards.org/document_library) for full details and future-dated requirements.

### Requirement 8: Identify and authenticate access to system components

#### AKS feature support

AKS provides several features to help you meet PCI DSS 4.0.1 MFA requirements:

- **Microsoft Entra ID (Azure AD) integration**: Enables centralized identity management and MFA enforcement for AKS cluster access through Azure AD RBAC.
- **Conditional access policies**: Allow you to require MFA for all privileged roles and access paths to AKS resources, including API, CLI, and portal access.
- **Azure Policy**: Can be used to audit and enforce MFA requirements for AKS administrators and ensure compliance.
- **Just-in-Time (JIT) access**: Supported via Microsoft Entra Privileged Identity Management (PIM) for time-limited privileged access.
- **Workload identity**: Enables secure authentication for applications running in AKS without storing credentials.

### Requirement 8.4

Multifactor authentication (MFA) is implemented for all access into the CDE.

#### Your responsibilities

| Requirement | Responsibility |
| --- | --- |
| Requirement 8.4.1 | MFA is implemented for all non-console access into the CDE for personnel with administrative access. |
| Requirement 8.4.2 | MFA is implemented for all access into the CDE. |
| Requirement 8.4.3 | MFA is implemented for all remote access originating from outside the entity's network that could access or impact the CDE. |

#### Requirement 8.4.1

MFA is implemented for all non-console access into the CDE for personnel with administrative access.

##### Your responsibilities

Implement MFA for all administrative access to your AKS clusters:

- **Enable Microsoft Entra ID integration**: Configure AKS clusters to use Azure AD for authentication and authorization. For detailed instructions, see [Use Azure AD in AKS](/en-us/azure/aks/managed-aad).
- **Configure Conditional Access policies**: Create policies that require MFA for all administrative roles accessing AKS resources. See [Common Conditional Access policies](/en-us/azure/active-directory/conditional-access/concept-conditional-access-policies).
- **Implement Azure RBAC**: Use Azure role-based access control to manage access to AKS resources with built-in roles like "Azure Kubernetes Service Cluster Admin Role" and "Azure Kubernetes Service RBAC Cluster Admin". For more information, see [Use Microsoft Entra ID authorization for the Kubernetes API](entra-id-authorization).
- **Monitor administrative access**: Use Azure Monitor and Azure AD logs to track all administrative access to AKS clusters.

**Implementation steps:**

1. Enable Azure AD integration for your AKS cluster:

    ```azurecli
    az aks update --resource-group myResourceGroup --name myAKSCluster --enable-aad --aad-admin-group-object-ids <admin-group-object-id>
    ```
2. Create a Conditional Access policy requiring MFA for AKS administrators:

    - Navigate to **Azure AD** &gt; **Security** &gt; **Conditional Access**.
    - Create a new policy targeting users with AKS administrative roles.
    - Set conditions for cloud apps (Azure Kubernetes Service).
    - Require MFA as an access control.
3. Assign appropriate Azure RBAC roles to users and groups for AKS access.

#### Requirement 8.4.2

MFA is implemented for all access into the CDE.

##### Your responsibilities

Extend MFA requirements to all users accessing the CDE, not just administrators:

- **Configure comprehensive Conditional Access policies**: Create policies that require MFA for all users accessing AKS resources, including developers and operational staff.
- **Implement workload identity**: Use workload identity for applications running in AKS to eliminate the need for stored credentials while maintaining secure authentication.
- **Use Azure AD groups**: Organize users into appropriate Azure AD groups and apply MFA requirements at the group level.
- **Document access patterns**: Maintain documentation of all access patterns and ensure MFA is enforced for each.

**Implementation steps:**

1. Create Conditional Access policies for all CDE access:

    ```powershell
    # Example PowerShell script to create a Conditional Access policy
    $policy = @{
        displayName = "Require MFA for AKS CDE Access"
        state = "enabled"
        conditions = @{
            applications = @{
                includeApplications = @("6dae42f8-4368-4678-94ff-3960e28e3630") # Azure Kubernetes Service
            }
            users = @{
                includeGroups = @("your-cde-access-group-id")
            }
        }
        grantControls = @{
            operator = "AND"
            builtInControls = @("mfa")
        }
    }
    ```
2. Configure workload identity for AKS applications:

    ```azurecli
    # Enable workload identity on AKS cluster
    az aks update -g myResourceGroup -n myAKSCluster --enable-workload-identity
    
    # Create service account with workload identity
    kubectl create serviceaccount myserviceaccount
    kubectl annotate serviceaccount myserviceaccount azure.workload.identity/client-id="your-client-id"
    ```

#### Requirement 8.4.3

MFA is implemented for all remote access originating from outside the entity's network that could access or impact the CDE.

##### Your responsibilities

Ensure MFA is enforced for all remote access to AKS resources:

- **Configure location-based policies**: Use Conditional Access to require MFA for access from outside trusted network locations.
- **Implement device compliance**: Require managed devices for remote access to AKS resources.
- **Use Azure Private Link**: Configure private endpoints for AKS API server access to limit remote access vectors.
- **Monitor remote access**: Implement logging and monitoring for all remote access attempts.

**Implementation steps:**

1. Configure location-based Conditional Access policies:

    - Define named locations in Azure AD for trusted network ranges.
    - Create policies that require MFA for access from untrusted locations.
    - Apply policies to all AKS-related cloud applications.
2. Implement private cluster configuration for enhanced security:

    ```azurecli
    # Create private AKS cluster
    az aks create \
      --resource-group myResourceGroup \
      --name myPrivateCluster \
      --enable-private-cluster \
      --enable-aad \
      --aad-admin-group-object-ids <admin-group-object-id>
    ```
3. Configure Azure Private Link for secure remote access:

    ```azurecli
    # Enable private endpoint for AKS
    az aks update \
      --resource-group myResourceGroup \
      --name myPrivateCluster \
      --enable-private-cluster \
      --private-dns-zone system
    ```

### Requirement 8.5

Multifactor authentication (MFA) systems are configured to prevent misuse.

#### Your responsibilities

| Requirement | Responsibility |
| --- | --- |
| Requirement 8.5.1 | MFA systems are implemented such that the MFA process must be completed before access is granted. |

#### Requirement 8.5.1

MFA systems are implemented such that the MFA process must be completed before access is granted.

##### Your responsibilities

Ensure MFA cannot be bypassed and is enforced before granting access:

- **Configure session controls**: Use Azure AD session controls to ensure MFA is required for each session.
- **Implement sign-in frequency controls**: Configure policies to require re-authentication at appropriate intervals.
- **Use persistent browser sessions carefully**: Limit persistent browser sessions and require MFA for sensitive operations.
- **Monitor bypass attempts**: Implement monitoring for any attempts to bypass MFA requirements.

**Implementation steps:**

1. Configure session controls in Conditional Access:

    ```json
    {
      "sessionControls": {
        "signInFrequency": {
          "value": 1,
          "type": "hours",
          "isEnabled": true
        },
        "persistentBrowser": {
          "mode": "never",
          "isEnabled": true
        }
      }
    }
    ```
2. Use Azure AD Identity Protection to detect and respond to anomalous access patterns.
3. Implement continuous access evaluation for real-time policy enforcement.

## Additional MFA considerations for AKS

### Service account and workload authentication

While the focus is on user authentication, consider how workloads authenticate:

- **Use workload identity**: Implement Azure AD workload identity for applications running in AKS to eliminate stored credentials.
- **Avoid service account keys**: Don't use long-lived service account keys for workload authentication.
- **Implement token rotation**: Ensure workload tokens are rotated regularly and automatically.

### Emergency access procedures

Maintain emergency access procedures while ensuring MFA compliance:

- **Break-glass accounts**: Configure emergency access accounts with appropriate monitoring and approval processes.
- **Document emergency procedures**: Maintain clear documentation for emergency access scenarios.
- **Test emergency procedures**: Regularly test emergency access procedures to ensure they work when needed.

### Monitoring and compliance

Implement comprehensive monitoring for MFA compliance:

- **Use Azure Monitor**: Monitor MFA success and failure rates across all AKS access.
- **Implement alerting**: Set up alerts for MFA bypass attempts or failures.
- **Regular access reviews**: Conduct regular reviews of user access and MFA compliance.
- **Audit logs**: Maintain comprehensive audit logs of all authentication events.

**Implementation steps for monitoring:**

1. Configure Azure Monitor workbooks for MFA reporting:

    ```kusto
    SigninLogs
    | where TimeGenerated > ago(30d)
    | where AppDisplayName contains "Azure Kubernetes Service"
    | where AuthenticationRequirement == "multiFactorAuthentication"
    | summarize MFAAttempts = count(), MFASuccesses = countif(ResultType == 0), MFAFailures = countif(ResultType != 0) by UserPrincipalName
    | extend MFASuccessRate = (MFASuccesses * 100.0) / MFAAttempts
    ```
2. Set up Azure Monitor alerts for MFA compliance:

    ```json
    {
      "criteria": {
        "allOf": [
          {
            "query": "SigninLogs | where AppDisplayName contains \"Azure Kubernetes Service\" | where AuthenticationRequirement == \"multiFactorAuthentication\" | where ResultType != 0",
            "timeAggregation": "Count",
            "operator": "GreaterThan",
            "threshold": 5
          }
        ]
      },
      "actions": {
        "actionGroups": ["your-action-group-id"]
      }
    }
    ```