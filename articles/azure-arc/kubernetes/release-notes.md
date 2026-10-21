---
layout: Conceptual
title: What's new with Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/release-notes
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2026-08-10T00:00:00.0000000Z
ms.topic: concept-article
description: Learn about the latest releases of Arc-enabled Kubernetes.
locale: en-us
document_id: 74103d54-4720-a555-20a6-5944fbe72bc6
document_version_independent_id: c236e5b5-bf1f-1e7e-f8c7-628660ef2934
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/release-notes.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/release-notes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/release-notes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 4860d415-c45e-47c5-5274-23562e2ad0fb
---

# What's new with Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

Azure Arc-enabled Kubernetes is updated on an ongoing basis. To stay up to date with the most recent developments, this article provides you with information about recent releases of the [Azure Arc-enabled Kubernetes agents](conceptual-agent-overview).

When any of the Arc-enabled Kubernetes agents are updated, all of the agents in the `azure-arc` namespace are incremented with a new version number, so that the version numbers are consistent across agents. When a new version is released, all of the agents are upgraded together to the newest version (whether or not there are functionality changes in a given agent), unless you [disabled automatic upgrades](agent-upgrade) for the cluster.

We generally recommend using the most recent versions of the agents. The [version support policy](agent-upgrade#version-support-policy) covers the most recent version and the two previous versions (N-2).

## Version 1.38.0 (October 2026)

- Security vulnerability fixes
- General bug fixes and reliability improvements
- Enabled managed least-privilege RBAC for Azure Arc agents, replacing shared cluster-admin access with dedicated, minimally scoped service accounts

## Version 1.37.3 (September 2026)

- Security vulnerability fixes
- General bug fixes and reliability improvements

## Version 1.36.1 (July 2026)

- Security vulnerability fixes
- FIPS compliance updates for the Azure Arc-enabled Kubernetes agent
- Pod Security Standards (PSS) compliance improvements. Azure Arc-enabled Kubernetes is now compliant with PSS, with the exception of the Azure Arc RBAC (Guard) component.
- General bug fixes and reliability improvements

## Version 1.35.3 (June 2026)

- Security vulnerability fixes

## Version 1.34.2 (May 2026)

- Security vulnerability fixes

## Older agent releases

### Version 1.33.0 (March 2026)

- Security vulnerability fixes

### Version 1.32.7 (February 2026)

- General availability of [workload identity federation](workload-identity) for Arc‑enabled Kubernetes
- General availability of [Azure Arc gateway for Kubernetes](arc-gateway-simplify-networking)
- Preview support for Kubernetes [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- Security improvements, including vulnerability fixes and minor bug fixes to improve overall reliability

### Version 1.31.2 (November 2025)

- Security enhancements
- Improved handling of cases where the Kubernetes API server is temporarily unavailable during extension reconciliation, providing clearer status and automatic recovery when connectivity returns.

### Version 1.31.0 (October 2025)

- Security vulnerability fixes

### Version 1.30.1 (September 2025)

- Security vulnerability fixes

### Version 1.29.3 (August 2025)

- Updated to Microsoft Go v1.24.6
- Security vulnerability fixes

### Version 1.28.0 (July 2025)

- Security vulnerability fixes

### Version 1.27.0 (June 2025)

- Security vulnerability fixes

### Version 1.26.0 (May 2025)

- Updated to Microsoft Go v1.24.2
- Migrated from Mariner 2.0 to Azure Linux 3.0
- Security vulnerability fixes

### Version 1.25.0 (April 2025)

- Fixes to MSI-Adapter response to improve retrieval of JWT tokens by extensions and upstream libraries
- Make agent update state mutually exclusive to avoid conflicts
- Upgrade connected proxy agent
- Security vulnerability fixes

### Version 1.24.4 (March 2025)

- Security vulnerability fixes
- Various bug fixes
- Support for [version-managed extensions](managed-extensions)

### Version 1.23.3 (February 2025)

- Updates to improve MSI adapter support
- Updates to improve disconnected scenario
- Security vulnerability fixes
- Various bug fixes

### Version 1.22.4 (January 2025)

- Fixed issue with resource health reporting
- Allow special characters in password for proxy server
- Security vulnerability fixes

### Version 1.21.10 (November 2024)

- Container images and charts are now signed
- Security vulnerability fixes

### Version 1.20.10 (September 2024)

- Functionality enhancements
- Security vulnerability fixes

### Version 1.19.x (September 2024)

- Various enhancements and bug fixes

### Version 1.18.x (July 2024)

- Fixed `logCollector` pod restarts
- Updated to Microsoft Go v1.22.5
- Other bug fixes

### Version 1.17.x (June 2024)

- Upgraded to use [Microsoft Go 1.22 to be FIPS compliant](https://github.com/microsoft/go/blob/microsoft/main/eng/doc/fips/README.md#tls-with-fips-compliant-settings)

### Version 1.16.x (May 2024)

- Migrated to use Microsoft Go w/ OpenSSL and fixed some vulnerabilities

### Version 1.15.3 (March 2024)

- Various enhancements and bug fixes

### Version 1.14.5 (December 2023)

- Migrated automatic upgrade to use latest Helm release

### Version 1.13.4 (October 2023)

- Various enhancements and bug fixes

### Version 1.13.1 (September 2023)

- Various enhancements and bug fixes

### Version 1.12.5 (July 2023)

- Alpine base image powering our Arc agent containers has been updated from 3.7.12 to 3.18.0

### Version 1.11.7 (May 2023)

- Updates to enable users that belong to more than 200 groups in cluster connect scenarios

### Version 1.11.3 (April 2023)

- Updates to base image of Arc-enabled Kubernetes agents to address security CVE