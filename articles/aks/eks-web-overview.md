---
layout: Conceptual
title: Replicate an AWS web application with AWS WAF in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-web-overview
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
description: Learn how to replicate an AWS web application protected by AWS WAF in Azure Kubernetes Service (AKS).
author: DixitArora-MSFT
ms.author: dixitaro
ms.topic: how-to
ms.date: 2025-11-10T00:00:00.0000000Z
ms.collection:
- migration
- aws-to-azure
locale: en-us
document_id: 158450c9-a25a-1ed6-c074-52f7a6738a52
document_version_independent_id: 5e819f26-03e1-7316-79ad-eff435f4fd22
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-web-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/eks-web-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-web-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/e8fdebed-2921-4997-a75a-fa863723a535
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/cf1e63a8-325f-42be-b60c-d84a95a42b1f
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6af354b4-86ee-674a-ecea-19a8270626ee
---

# Replicate an AWS web application with AWS WAF in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to replicate an Amazon Elastic Kubernetes Service (EKS) web application with AWS Web Application Firewall (WAF) using [Azure Web Application Firewall (WAF)](/en-us/azure/web-application-firewall/overview) and [Azure Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview) in [Azure Kubernetes Service (AKS)](what-is-aks).

This workload implements a WAF to protect a [Yelb](https://github.com/mreferre/yelb/) web-based application running in a Kubernetes cluster. Applications rely on WAFs to block unwanted traffic and protect apps from common vulnerabilities. A centralized web application firewall helps simplify security management and helps ensure better protection against threats or intrusions.

If you plan to migrate an AWS workload to Azure, see [Migrate compute from Amazon Web Services to Azure](/en-us/azure/migration/migrate-compute-from-aws), which includes [example migration scenarios](/en-us/azure/migration/migrate-compute-from-aws#migration-scenarios) that might align to your use case. For a more detailed understanding of the AWS workload, see [Protecting your Amazon EKS web apps with AWS WAF](https://aws.amazon.com/it/blogs/containers/protecting-your-amazon-eks-web-apps-with-aws-waf/).

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Deployment process

1. [**Understand the conceptual differences**](eks-web-understand): Start by reviewing the differences between EKS and AKS in terms of services, architecture, and deployment.
2. [**Rearchitect the workload**](eks-web-rearchitect): Analyze the existing AWS workload architecture and identify the components or services, like the workload infrastructure, application architecture, and deployment process, that you need to redesign to fit AKS.
3. [**Update the application code**](eks-web-refactor): Ensure your code is compatible with Azure APIs, services, and authentication models.
4. [**Prepare for deployment**](eks-web-prepare): Modify the AWS deployment process to use the Azure CLI.
5. [**Deploy the workload**](eks-web-deploy): Deploy the replicated workload in AKS and test the workload to ensure that it functions as expected.

## Prerequisites

- An active [Azure subscription](/en-us/azure/guides/developer/azure-developer-guide#understanding-accounts-subscriptions-and-billing). If you don't have one, create a [free Azure account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- The **Owner**[Azure built-in role](/en-us/azure/role-based-access-control/built-in-roles), or the **User Access Administrator** and **Contributor** built-in roles, on a subscription in your Azure account.
- [Azure CLI](/en-us/cli/azure/install-azure-cli) version 2.61.0 or later. For more information, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- [Azure Kubernetes Service (AKS) preview extension](/en-us/azure/aks/draft#install-the-aks-preview-azure-cli-extension).
- [jq](https://jqlang.github.io/jq/) version 1.5 or later.
- [Python 3](https://www.python.org/downloads/) or later.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) version 1.21.0 or later
- [Helm](https://helm.sh/docs/intro/install/) version 3.0.0 or later
- [Visual Studio Code](https://code.visualstudio.com/Download) installed on one of the [supported platforms](https://code.visualstudio.com/docs/supporting/requirements#_platforms) along with the [Bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep).
- An existing [Azure Key Vault](/en-us/azure/key-vault/general/overview) resource with a valid TLS certificate for the Yelb web application.
- An existing [Azure DNS Zone](/en-us/azure/dns/dns-overview) or equivalent DNS server for the name resolution of the [Yelb](https://github.com/mreferre/yelb/) application.

### Download the Azure application code

The **completed** application code for this workflow is available in our [GitHub repository](https://github.com/azure-samples/aks-web-application-replicate-from-aws).

1. Clone the repository to a directory called `aws-to-azure-web-app-workshop` on your local machine using the following command:

    ```bash
    git clone https://github.com/azure-samples/aks-web-application-replicate-from-aws ./aws-to-azure-web-app-workshop
    ```
2. After you clone the repository, navigate to the `aws-to-azure-web-app-workshop` directory and start Visual Studio Code using the following commands:

    ```bash
    cd aws-to-azure-web-app-workshop
    code .
    ```