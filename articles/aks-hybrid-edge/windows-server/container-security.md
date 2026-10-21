---
layout: Conceptual
title: Container security in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/container-security
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
description: Learn ways to implement security on containers used to package and deploy applications in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: EkeleAsonye
ms.custom: windows-server
locale: en-us
document_id: bc6e5a93-9cff-1670-b3c8-f302476cbcd5
document_version_independent_id: db4c2b1c-ad1d-9b7e-6c45-5680a837dec8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/container-security.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/container-security
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/container-security.md
platformId: 70f777a5-e5a7-a984-40dd-e0f04d8b8693
---

# Container security in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes various methods to secure the containers used to package and deploy applications and avoid introducing security vulnerabilities in AKS on Windows Server.

Containers provide operational and security benefits because applications and services are separated within an environment. Containers also help to reduce the effects of system-wide failures because of their abstraction, which ensures uptime and prevents attacks that could compromise applications or services. Containers typically run on an abstracted layer on top of the host operating system, and the abstraction offers some barrier of separation and the opportunity to apply a layered defense model.

You can also set up continuous container security by securing the container pipeline, the application, and the container deployment environment. The following sections describe some recommended practices for implementing container security.

## Secure images

To prevent unauthorized access, host the images on a secure and trusted registry. The images should have a TLS certificate with a trusted root CA, and the registry should use role-based access control (RBAC) with strong authentication. You should include an image scanning solution when designing CI/CD for the container build and delivery. The image scanning solution helps identify common vulnerabilities and exposures (CVEs) and ensures that exploitable images are not deployed without remediation.

## Harden host environment

An important aspect of container security is the need to harden the security of the systems that your containers are running on, and the way they act during runtime. Container security should focus on the entire stack, including your host and the daemons. You should remove services from the host that are non-critical, and you should not deploy non-compliant containers in the environment. By doing so, access to the host can only occur through the containers and control is centralized to the container daemon, removing the host from the attack surface. These steps are especially helpful when you use proxy servers to access your containers, which can accidentally bypass your container security controls.

## Limit container resources

When a container is compromised, attackers might attempt to use the underlying host resources to perform malicious activities. It's a good practice to set memory and CPU usage limits to minimize the impact of breaches.

## Properly secure secrets

A *secret* is an object containing sensitive information that might need to be passed between the host and the container; for example, passwords, SSL/TLS certificates, SSH private keys, tokens, connection strings, and other data that shouldn't be transmitted in plain text or stored unencrypted. You should keep all secrets out of the images and mount them through the container orchestration engine or an external secrets manager.

## Practice isolation

Use isolation, and don't use a privileged user or root user to run the application in a container. Avoid running containers in privileged mode because doing so can allow an attacker to easily escalate privileges if the container is compromised. Knowing the UID (Unique Identification Code) and GID (Group Identification Code) of the root user in a container can allow an attacker to access and modify the files written by the root on the host machine. It's also necessary to use the principle of least privileges where an application only has access to the secrets it needs. You can create an application user to run the application process.

## Deploy runtime security monitoring

Since there's still the chance of getting compromised even after taking precautions against attacks on your infrastructure, it's important to continuously monitor and log the application's behavior to prevent and detect malicious activities. Tools such as [Prometheus](https://github.com/prometheus/prometheus) provide an effective means to monitor your infrastructure.