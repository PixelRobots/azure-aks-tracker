---
layout: Conceptual
title: Dapr Extension for Azure Kubernetes Service (AKS) and Arc-enabled Kubernetes - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/dapr-overview
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
description: Learn more about using Dapr on your Azure Kubernetes Service (AKS) cluster to develop applications.
author: shivamkm07
ms.author: shivamkumar
ms.reviewer: ramithar
ms.topic: overview
ms.subservice: dapr-aks
ms.date: 2026-02-05T00:00:00.0000000Z
locale: en-us
document_id: 10a6985f-9105-6efc-7e62-bb834308f099
document_version_independent_id: 6efdc14e-06d7-9bd4-0328-14d52c49b9c1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/dapr-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/dapr-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/dapr-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ed63b1b0-98b0-37fd-4a94-5761fb5f036a
---

# Dapr Extension for Azure Kubernetes Service (AKS) and Arc-enabled Kubernetes - Azure Kubernetes Service | Microsoft Learn

[Distributed Application Runtime (Dapr)](https://docs.dapr.io/) offers APIs that help you write and implement simple, portable, resilient, and secured microservices. Dapr APIs run as a sidecar process in tandem with your applications and abstract away common complexities you might encounter when building distributed applications, such as:

- Service discovery
- Message broker integration
- Encryption
- Observability
- Secret management

Dapr is incrementally adoptable. You can use any of the API building blocks as needed. To learn about the support level Microsoft offers for the Dapr extension, see Issue handling.

## Capabilities and features

Using the [Dapr extension](dapr) to provision Dapr on your AKS or Arc-enabled Kubernetes cluster eliminates the overhead of:

- Downloading Dapr tooling
- Manually installing and managing the Dapr runtime on your AKS cluster

You can install, deploy, and configure the Dapr extension on your cluster by using either the Azure CLI or a Bicep template.

Additionally, the extension offers support for all [native Dapr configuration capabilities](dapr-settings) through simple command-line arguments.

Dapr provides the following set of capabilities to help with your microservice development on AKS:

- Easy provisioning of Dapr on AKS through [cluster extensions](cluster-extensions)
- Portability enabled through HTTP and gRPC APIs that abstract underlying technologies choices
- Reliable, secure, and resilient service-to-service calls through HTTP and gRPC APIs
- Publish-and-subscribe messaging made easy with support for CloudEvent filtering and *at-least-once* semantics for message delivery
- Pluggable observability and monitoring through Open Telemetry API collector
- Language independence, while also offering language-specific software development kits (SDKs)
- Integration with Visual Studio Code through the Dapr extension
- [Building block APIs](https://docs.dapr.io/concepts/building-blocks-concept/) for solving distributed application challenges

## Issue handling

Microsoft categorizes issues raised against the Dapr extension into two parts:

- Extension operations
- Dapr runtime (including APIs and components)

The following table breaks down support priority levels for each of these categories.

| - | Description | Security risks/regressions | Functional issues |
| --- | --- | --- | --- |
| **Extension operations** | Issues encountered during extension operations, such as installing, uninstalling, or upgrading the Dapr extension. | Microsoft prioritizes for immediate resolution. | Microsoft investigates and addresses as needed. |
| **Dapr runtime** | Issues encountered when using the Dapr runtime, APIs, and components via the extension, like cert expiration and unexpected component behavior. | Work with the [Dapr open-source project](https://github.com/dapr/dapr/issues/new/choose) to resolve in a hotfix or future Dapr open-source release. Once fixes are released in Dapr open source, they're then made available in the Dapr extension. Known open-source security risks and regressions won't be investigated by Microsoft at this time. | Discuss issues with the [Dapr open-source project](https://github.com/dapr/dapr/issues/new/choose) to resolve in a hotfix or future Dapr open-source release. Known open-source functional issues won't be investigated by Microsoft at this time. |

### Clouds/regions

Global Azure cloud is supported with AKS and Arc support in the following regions:

| Region | AKS support | Arc for Kubernetes support |
| --- | --- | --- |
| `australiaeast` | ✔️ | ✔️ |
| `australiasoutheast` | ✔️ | ❌ |
| `brazilsouth` | ✔️ | ❌ |
| `canadacentral` | ✔️ | ✔️ |
| `canadaeast` | ✔️ | ✔️ |
| `centralindia` | ✔️ | ✔️ |
| `centralus` | ✔️ | ✔️ |
| `eastasia` | ✔️ | ✔️ |
| `eastus` | ✔️ | ✔️ |
| `eastus2` | ✔️ | ✔️ |
| `eastus2euap` | ❌ | ✔️ |
| `francecentral` | ✔️ | ✔️ |
| `francesouth` | ✔️ | ❌ |
| `germanywestcentral` | ✔️ | ✔️ |
| `japaneast` | ✔️ | ✔️ |
| `japanwest` | ✔️ | ❌ |
| `koreacentral` | ✔️ | ✔️ |
| `koreasouth` | ✔️ | ❌ |
| `northcentralus` | ✔️ | ✔️ |
| `northeurope` | ✔️ | ✔️ |
| `norwayeast` | ✔️ | ❌ |
| `southafricanorth` | ✔️ | ❌ |
| `southcentralus` | ✔️ | ✔️ |
| `southeastasia` | ✔️ | ✔️ |
| `southindia` | ✔️ | ❌ |
| `swedencentral` | ✔️ | ✔️ |
| `switzerlandnorth` | ✔️ | ✔️ |
| `uaenorth` | ✔️ | ❌ |
| `uksouth` | ✔️ | ✔️ |
| `ukwest` | ✔️ | ❌ |
| `westcentralus` | ✔️ | ✔️ |
| `westeurope` | ✔️ | ✔️ |
| `westus` | ✔️ | ✔️ |
| `westus2` | ✔️ | ✔️ |
| `westus3` | ✔️ | ✔️ |

## Frequently asked questions

### How do Dapr and service meshes compare?

While Dapr and service meshes do offer some overlapping capabilities, a service mesh is focused on networking concerns, whereas Dapr is focused on providing building blocks that make building applications as microservices easier. Dapr is developer-centric, while service meshes are infrastructure-centric.

Some common capabilities that Dapr shares with service meshes include:

- Secure service-to-service communication with mTLS encryption
- Service-to-service metric collection
- Service-to-service distributed tracing
- Resiliency through retries

Dapr provides other application-level building blocks for state management, pub/sub messaging, actors, and more. However, Dapr doesn't provide capabilities for traffic behavior, such as routing or traffic splitting. If your solution would benefit from the traffic splitting a service mesh provides, consider using [Open Service Mesh](open-service-mesh-about).

For more information on Dapr and service meshes, and how they can be used together, visit the [Dapr documentation](https://docs.dapr.io/).

### How does the Dapr secrets API compare to the Secrets Store CSI driver?

Both the Dapr secrets API and the managed Secrets Store CSI driver allow for the integration of secrets held in an external store, abstracting secret store technology from application code.

The Secrets Store CSI driver mounts secrets held in Azure Key Vault as a CSI volume for consumption by an application.

Dapr exposes secrets via a RESTful API that can be:

- Called by application code
- Configured with assorted secret stores

The following table lists the capabilities of each offering:

| - | Dapr secrets API | Secrets Store CSI driver |
| --- | --- | --- |
| **Supported secrets stores** | Local environment variables (for development); Local file (for development); Kubernetes secrets; AWS Secrets Manager; Azure Key Vault secret store; Azure Key Vault with Managed Identities on Kubernetes; GCP Secret Manager; HashiCorp Vault | Azure Key Vault secret store |
| **Accessing secrets in application code** | Call the Dapr secrets API | Access the mounted volume or sync mounted content as a Kubernetes secret and set an environment variable |
| **Secret rotation** | New API calls obtain the updated secrets | Polls for secrets and updates the mount at a configurable interval |
| **Logging and metrics** | The Dapr sidecar generates logs, which can be configured with collectors such as Azure Monitor, emits metrics via Prometheus, and exposes an HTTP endpoint for health checks | Emits driver and Azure Key Vault provider metrics via Prometheus |

To learn more about secrets management in Dapr, see the [secrets management overview](https://docs.dapr.io/developing-applications/building-blocks/secrets/secrets-overview/).

For more information on the Secrets Store CSI driver and Azure Key Vault provider, see the [Secrets Store CSI driver overview](csi-secrets-store-driver).

### How does the managed Dapr cluster extension compare to the open-source Dapr offering?

The managed Dapr cluster extension is the easiest method to provision Dapr on an AKS cluster. With the extension, you're able to offload management of the Dapr runtime version by opting into automatic upgrades. Additionally, the extension installs Dapr with smart defaults (for example, provisioning the Dapr control plane in high availability mode).

When installing Dapr open source via helm or the Dapr CLI, developers and cluster maintainers are also responsible for runtime versions and configuration options.

Lastly, the Dapr extension is an extension of AKS, therefore you can expect the same support policy as other AKS features.

Learn more about [migrating from Dapr open source to the Dapr extension for AKS](dapr-migration).

### How can I authenticate Dapr components with Microsoft Entra ID using managed identities?

- Learn how [Dapr components authenticate with Microsoft Entra ID](https://docs.dapr.io/developing-applications/integrations/azure/azure-authentication).
- Learn about [using managed identities with AKS](use-managed-identity).

### How can I switch to using the Dapr extension if I've already installed Dapr via a method, such as Helm?

Recommended guidance is to completely uninstall Dapr from the AKS cluster and reinstall it via the cluster extension. You can also [check for the existing Dapr installation and migrate it to AKS](dapr-migration).

If you install Dapr through the AKS extension, our recommendation is to continue using the extension for future management of Dapr instead of the Dapr CLI. Combining the two tools can cause conflicts and result in undesired behavior.