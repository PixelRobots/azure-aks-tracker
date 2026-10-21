---
layout: Conceptual
title: AKS Regulated Cluster for PCI DSS 4.0.1 - Cryptography and Key Management - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pci-cryptography-key-management
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
description: Cryptography and key management guidance for AKS clusters under PCI DSS 4.0.1.
ms.date: 2025-06-25T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: schaffererin
ms.author: schaffererin
ms.custom:
- pci-dss
- compliance
locale: en-us
document_id: 0d241a09-6a20-be47-6786-9e2af34ebd15
document_version_independent_id: b5fbadf2-d92c-0f20-35a7-e75d54f23b76
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pci-cryptography-key-management.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/pci-cryptography-key-management
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pci-cryptography-key-management.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 5826415d-86b6-a34e-0165-f068f77003f2
---

# AKS Regulated Cluster for PCI DSS 4.0.1 - Cryptography and Key Management - Azure Kubernetes Service | Microsoft Learn

This article describes cryptography and key management considerations for an Azure Kubernetes Service (AKS) cluster that's configured in accordance with the Payment Card Industry Data Security Standard (PCI DSS 4.0.1).

> 
> This article is part of a series. Read the [introduction](pci-intro).

This architecture and the implementation are focused on infrastructure and not the workload. This article provides general considerations and best practices to help you make design decisions. Follow the requirements in the official PCI-DSS 4.0.1 standard and use this article as additional information, where applicable.

Important

The guidance and the accompanying implementation builds on the [AKS baseline architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks), which is based on a hub-spoke network topology. The hub virtual network contains the firewall to control egress traffic, gateway traffic from on-premises networks, and a third network for maintenance. The spoke virtual network contains the AKS cluster that provides the card-holder environment (CDE), and hosts the PCI DSS workload.

![GitHub logo](media/pci-dss/github.png)**Reference Implementation Coming Soon**: The Azure Kubernetes Service (AKS) baseline cluster for regulated workloads reference implementation for PCI DSS 4.0.1 is currently being updated and will be available soon. This implementation will demonstrate a regulated infrastructure that illustrates the use of various network and security controls within your CDE. This includes both network controls native to Azure and controls native to Kubernetes. It will also include an application to demonstrate the interactions between the environment and a sample workload. The focus of this article is the infrastructure. The sample will not be indicative of an actual PCI-DSS 4.0.1 workload.

## Protect cardholder data

Note

This article has been updated for PCI DSS 4.0.1. Major changes include support for the customized approach to controls, enhanced multifactor authentication (MFA), updated cryptography requirements, expanded monitoring and logging, and a focus on continuous security and risk management. Ensure you review the official [PCI DSS 4.0.1 documentation](https://www.pcisecuritystandards.org/document_library) for full details and future-dated requirements.

### Requirement 3: Protect stored cardholder data (continued)

#### AKS feature support

AKS provides several features to help you meet PCI DSS 4.0.1 cryptography and key management requirements:

- **Azure Key Vault:** Secure storage and management of cryptographic keys, secrets, and certificates. Integrates with AKS for both workload and cluster-level secrets.
- **Managed identities:** Allow AKS workloads to securely access Key Vault without storing credentials in code.
- **TLS enforcement:** AKS supports enforcing TLS 1.2+ for all ingress/egress traffic.
- **Integration with HSM:** Azure Key Vault can be backed by hardware security modules (HSM) for FIPS 140-2 Level 3 compliance.
- **Automated key rotation:** Azure Key Vault supports automated key rotation and alerting.

### Requirement 3.5

Document and implement procedures to protect keys used to secure stored cardholder data against disclosure and misuse.

#### Your responsibilities

| Requirement | Responsibility |
| --- | --- |
| Requirement 3.5.1 | Additional requirement for service providers only: Maintain a documented description of the cryptographic architecture that includes details of all algorithms, protocols, and keys used for the protection of cardholder data. |
| Requirement 3.5.2 | Restrict access to plaintext cryptographic keys to the fewest number of custodians necessary. |
| Requirement 3.5.3 | Store secret and private keys used to encrypt/decrypt cardholder data in one (or more) of the following forms at all times. |

#### Requirement 3.5.1

Additional requirement for service providers only: Maintain a documented description of the cryptographic architecture that includes details of all algorithms, protocols, and keys used for the protection of cardholder data.

##### Your responsibilities

If you're a service provider, maintain comprehensive documentation of your cryptographic architecture. This documentation should include:

- All cryptographic algorithms used for cardholder data protection.
- Protocols implemented for secure communication.
- Key management procedures and key lifecycle management.
- Integration points with Azure Key Vault and other cryptographic services.
- Compliance with current industry standards and PCI DSS requirements.

Use Azure Key Vault to centralize key management and maintain audit trails of all cryptographic operations. Document the integration between AKS workloads and Azure Key Vault, including authentication methods using managed identities.

#### Requirement 3.5.2

Restrict access to plaintext cryptographic keys to the fewest number of custodians necessary.

##### Your responsibilities

Implement the principle of least privilege for cryptographic key access:

- Use Azure Key Vault access policies and Azure RBAC to restrict access to cryptographic keys.
- Implement managed identities for AKS workloads to access Key Vault without storing credentials.
- Regularly review and audit access to cryptographic keys.
- Implement proper separation of duties for key management operations.
- Use Azure Key Vault's built-in logging and monitoring capabilities to track key access.

Configure Azure Key Vault with appropriate access policies that limit access to only the necessary principals. Use Azure RBAC roles such as "Key Vault Crypto Officer" and "Key Vault Crypto User" to implement granular access controls.

#### Requirement 3.5.3

Store secret and private keys used to encrypt/decrypt cardholder data in one (or more) of the following forms at all times.

##### Your responsibilities

Ensure that all secret and private keys are stored securely using one of the approved methods:

- **In a cryptographic device (such as a hardware security module (HSM) or PCI-approved point-of-interaction device)**: Use Azure Key Vault Premium tier with HSM-backed keys for FIPS 140-2 Level 3 compliance.
- **In a secure cryptographic token (such as a hardware token)**: Implement hardware-based key storage solutions.
- **Encrypted by a key-encrypting key**: Use Azure Key Vault's envelope encryption capabilities.
- **Split knowledge and dual control**: Implement multi-person control mechanisms for sensitive operations.

Azure Key Vault integrates with AKS through the CSI Secret Store driver, allowing secure retrieval of keys and secrets directly into pod filesystems or environment variables.

### Requirement 3.6

Fully document and implement all key-management processes and procedures for cryptographic keys used for encryption of cardholder data.

#### Your responsibilities

| Requirement | Responsibility |
| --- | --- |
| Requirement 3.6.1 | Generation of strong cryptographic keys. |
| Requirement 3.6.2 | Secure cryptographic key distribution. |
| Requirement 3.6.3 | Secure cryptographic key storage. |
| Requirement 3.6.4 | Cryptographic key changes for keys that have reached the end of their cryptoperiod. |
| Requirement 3.6.5 | Retirement or replacement of keys as deemed necessary when the integrity of the key has been weakened or keys are suspected of being compromised. |
| Requirement 3.6.6 | If manual clear-text cryptographic key-management operations are used, these operations are managed using split knowledge and dual control. |
| Requirement 3.6.7 | Prevention of unauthorized substitution of cryptographic keys. |
| Requirement 3.6.8 | Replacement of cryptographic keys if the key is known or suspected to be compromised. |

#### Requirement 3.6.1

Generation of strong cryptographic keys.

##### Your responsibilities

Implement strong key generation practices:

- Use Azure Key Vault's cryptographically secure random number generation.
- Follow industry standards for key strength (minimum 2048-bit RSA, 256-bit AES).
- Implement proper entropy sources for key generation.
- Use HSM-backed keys in Azure Key Vault Premium for enhanced security.
- Document key generation procedures and ensure they meet PCI DSS requirements.

Configure Azure Key Vault to generate keys with appropriate algorithms and key sizes. Use the Azure Key Vault REST API or Azure CLI to create keys with specific parameters.

#### Requirement 3.6.2

Secure cryptographic key distribution.

##### Your responsibilities

Implement secure key distribution mechanisms:

- Use Azure Key Vault's secure key distribution capabilities.
- Implement managed identities for AKS workloads to securely access keys.
- Use TLS 1.2+ for all key distribution communications.
- Implement proper authentication and authorization for key access.
- Monitor and log all key distribution activities.

Configure the CSI Secret Store driver in AKS to securely distribute keys from Azure Key Vault to workloads. Use pod identities or workload identities to authenticate with Key Vault.

#### Requirement 3.6.3

Secure cryptographic key storage.

##### Your responsibilities

Ensure secure storage of cryptographic keys:

- Store all keys in Azure Key Vault with appropriate access controls.
- Use HSM-backed keys for enhanced security.
- Implement proper backup and recovery procedures for keys.
- Use Azure Key Vault's soft delete and purge protection features.
- Regularly review and audit key storage configurations.

Configure Azure Key Vault with appropriate security settings, including firewall rules, private endpoints, and access policies. Enable logging and monitoring for all key storage operations.

#### Requirement 3.6.4

Cryptographic key changes for keys that have reached the end of their cryptoperiod.

##### Your responsibilities

Implement key rotation procedures:

- Define appropriate cryptoperiods for different types of keys.
- Implement automated key rotation using Azure Key Vault's capabilities.
- Document key rotation procedures and schedules.
- Test key rotation procedures regularly.
- Monitor key expiration and ensure timely rotation.

Use Azure Key Vault's automatic key rotation features and set up alerts for key expiration. Implement application logic to handle key rotation seamlessly.

#### Requirement 3.6.5

Retirement or replacement of keys as deemed necessary when the integrity of the key has been weakened or keys are suspected of being compromised.

##### Your responsibilities

Implement key compromise response procedures:

- Define procedures for key compromise detection and response.
- Implement immediate key replacement capabilities.
- Document key compromise response procedures.
- Test key compromise response procedures regularly.
- Monitor for signs of key compromise.

Configure Azure Key Vault to support rapid key replacement and implement monitoring to detect potential key compromise.

### Requirement 4: Protect cardholder data with strong cryptography during transmission over open, public networks

#### AKS feature support

AKS provides several features to help you meet PCI DSS 4.0.1 data transmission requirements:

- **TLS termination:** AKS ingress controllers support TLS 1.2+ termination.
- **Service mesh:** Integration with service mesh solutions like Istio for mutual TLS (mTLS).
- **Network policies:** Kubernetes network policies for secure internal communications.
- **Azure Front Door:** Integration with Azure Front Door for enhanced security and performance.

#### Your responsibilities

| Requirement | Responsibility |
| --- | --- |
| Requirement 4.1 | Ensure that security policies and operational procedures for protecting cardholder data with strong cryptography during transmission over open, public networks are documented, in use, and known to all affected parties. |
| Requirement 4.2 | Strong cryptography and security protocols are used to safeguard sensitive cardholder data during transmission over open, public networks. |

#### Requirement 4.1

Ensure that security policies and operational procedures for protecting cardholder data with strong cryptography during transmission over open, public networks are documented, in use, and known to all affected parties.

##### Your responsibilities

Document and implement comprehensive cryptographic policies for data transmission:

- Define approved cryptographic standards and protocols (TLS 1.2+).
- Document procedures for certificate management and renewal.
- Implement proper key management for TLS certificates.
- Train staff on secure transmission procedures.
- Regularly review and update cryptographic policies.

Use Azure Key Vault to manage TLS certificates and integrate with AKS ingress controllers for automatic certificate provisioning and renewal.

#### Requirement 4.2

Strong cryptography and security protocols are used to safeguard sensitive cardholder data during transmission over open, public networks.

##### Your responsibilities

Implement strong cryptographic protection for data in transit:

- Use TLS 1.2 or higher for all cardholder data transmission.
- Implement proper certificate validation and hostname verification.
- Configure secure cipher suites and disable weak protocols.
- Implement mutual TLS (mTLS) for internal service communication.
- Monitor and log all secure transmission activities.

Configure AKS ingress controllers to enforce TLS 1.2+ and implement service mesh solutions for internal mTLS communication.