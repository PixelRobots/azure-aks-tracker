---
layout: Conceptual
title: Set Up Conditional Access for Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-configure-conditional-access
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Learn how to configure conditional access to your Azure Container Registry by using Azure CLI and Azure portal to enhance security.
ms.custom: devx-track-azurecli
ms.topic: how-to
ms.date: 2026-02-27T00:00:00.0000000Z
locale: en-us
document_id: 6d7c638c-749a-6e47-51fd-111a87a43634
document_version_independent_id: d3c6d97f-3310-c9c4-ed5e-2373dd680929
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-configure-conditional-access.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-configure-conditional-access
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-configure-conditional-access.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 2dacb9be-547c-d64e-5c04-7c161c134bfb
---

# Set Up Conditional Access for Azure Container Registry - Azure Container Registry | Microsoft Learn

Azure Container Registry (ACR) gives you the option to create and configure [Microsoft Entra Conditional Access policies](/en-us/entra/identity/conditional-access/overview) to enforce strong authentication and access controls.

The Conditional Access policy is designed to enforce strong authentication. The policy helps your organization meet compliance requirements and keeps data and user accounts safe.

Conditional access policies apply after a user authenticates to the Azure Container Registry. You can configure options to block or grant access based on your [policy decisions](/en-us/azure/active-directory/conditional-access/overview#common-decisions).

Azure Container Registry supports Conditional Access policy for Microsoft Entra user accounts only. Conditional Access policy for service principal accounts isn't currently supported.

Important

To configure Conditional Access policy for the registry, first configure all registries in your tenant to [accept only ACR-scoped Microsoft Entra authentication](container-registry-disable-authentication-as-arm) for all the registries within the desired tenant.

This article shows you how to create and configure a Conditional Access policy for Azure Container Registry, and how to troubleshoot common issues.

## Prerequisites

- An Azure account with the [Conditional Access Administrator](/en-us/entra/identity/role-based-access-control/permissions-reference#conditional-access-administrator) role.
- An Azure Container Registry. If you don't have a registry, create one by following the [Quickstart: Create a container registry using the Azure portal](/en-us/azure/container-registry/container-registry-get-started-portal) tutorial.

## Create and configure a Conditional Access policy

Create a Conditional Access policy and assign your test group of users as follows:

1. Sign in to the [Azure portal](https://portal.azure.com) with an account that has the [Conditional Access Administrator](/en-us/entra/identity/role-based-access-control/permissions-reference#conditional-access-administrator) role.
2. Search for and select **Microsoft Entra ID**.
3. In the service menu, under **Manage**, select **Security**.
4. Select **Conditional Access**, select **+ New policy**, and then select **Create new policy**.
5. Enter a name for the policy, such as *demo*.
6. Under **What does this policy apply to?**, select **Users and groups**.
7. Under **Include**, choose **Select users and groups**, and then select **All users**.

    ![A screenshot of the page for creating a new policy, where you select options to specify users.](media/container-registry-enable-conditional-policy/03-conditional-access-users-groups-select-users.png)
8. Under **Exclude**, choose **Select users and groups**, then make any selections for users or groups to exclude from the policy.
9. Under **Cloud apps or actions**, choose **Cloud apps**.
10. Under **Include**, choose **Select apps**.

    ![A screenshot of the page for creating a new policy, where you select options to specify cloud apps.](media/container-registry-enable-conditional-policy/04-select-cloud-apps-select-apps.png)
11. Select *Azure Container Registry*, then choose **Select**.
12. Under **Conditions**, set the [conditions](/en-us/entra/identity/conditional-access/concept-conditional-access-conditions) that you want to apply.
13. Under **Access controls**, select **Grant**. Select **Grant access** with **Require multifactor authentication**, then choose **Select**.

    Tip

    For details about how to configure and grant multifactor authentication, see [Configure the conditions for multifactor authentication.](/en-us/entra/identity/authentication/tutorial-enable-azure-mfa#configure-the-conditions-for-multi-factor-authentication)
14. Under **Session**, optionally choose options to enable any control on session level experience of the cloud apps.
15. Set **Enable policy** to **On**, then select **Create**

You have now created a Conditional Access policy for your Azure Container Registry.

## Troubleshoot Conditional Access policy problems

For problems with Conditional Access sign-in, see [Troubleshoot Conditional Access sign-in](/en-us/entra/identity/conditional-access/troubleshoot-conditional-access).

For problems with Conditional Access policy, see [Troubleshoot Conditional Access policy](/en-us/entra/identity/conditional-access/troubleshoot-conditional-access-what-if).