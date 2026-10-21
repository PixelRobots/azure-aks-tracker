---
layout: Conceptual
title: Continuous Patching in Azure Container Registry Key Concepts - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/key-concept-continuous-patching
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
description: Learn about Key Concepts for continuous patching in Azure Container Registry.
ms.topic: concept-article
ms.date: 2025-03-27T00:00:00.0000000Z
locale: en-us
document_id: 50fe9d43-3ba3-c12e-a8d9-496cae2b1ca8
document_version_independent_id: 23db17de-834d-5750-f0e9-449ea9ffd2dd
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/key-concept-continuous-patching.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/key-concept-continuous-patching
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/key-concept-continuous-patching.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: db2f0bfa-c978-1fc9-631b-27af2c36ec15
---

# Continuous Patching in Azure Container Registry Key Concepts - Azure Container Registry | Microsoft Learn

Azure Container Registry's Continuous Patching feature automates the detection and remediation of operating system(OS) level vulnerabilities in container images. By scheduling regular scans with [Trivy](https://trivy.dev/) and applying security fixes using [Copa](https://project-copacetic.github.io/copacetic/website/), you can maintain secure, up-to-date images in your registry—without requiring access to source code or build pipelines. Freely customize the schedule and target images to keep your Azure Container Registry(ACR) environment safe and compliant

## Use Cases

Here are a few scenarios to use Continuous Patching:

- **Enforcing container security and hygiene:** Continuous Patching enables users to quickly fix OS container CVEs (Common Vulnerabilities and Exposures) without the need to fully rebuild from upstream.
- **Speed of Use:** Continuous Patching removes the dependency on upstream updates for specific images by updating packages automatically. Vulnerabilities can appear every day, while popular image publishers might only offer a new release once a month. With continuous patching, you can ensure that container images within your registry are patched as soon as the newest set of OS vulnerabilities are detected.

## Pricing

Continuous Patching operates under a consumption model. Each patch utilizes compute resources, which is charged per the default ACR Task pricing of $0.0001/second of task running. More information found under the [ACR pricing page](https://azure.microsoft.com/pricing/details/container-registry/?msockid=39cc5589db1c66a6375d41dcda9867d2).

## Preview Limitations

Continuous Patching is currently in public preview. The following limitations apply:

- Windows-based container images aren't supported.
- Only "OS-level" vulnerabilities that originate from system packages will be patched. This includes system packages in the container image managed by an OS package manager such as "apt” and "yum”. Vulnerabilities that originate from application packages, such as packages used by programming languages like Go, Python, and NodeJS are unable to be patched.
- End of Service Life (EOSL) images aren't supported by Continuous Patching. EOSL images refer to images where the underlying operating system is no longer offering updates, security patches, and technical support. Examples include images based on older operating system versions such as Debian 8 and Fedora 28. EOSL images are skipped from the patch despite having vulnerabilities - the recommended approach is to upgrade the underlying operating system of your image to a supported version.
- Multi-arch images won't be supported.
- A **100 image limit** is enforced for continuous patching
- Continuous Patching is incompatible with ABAC (Attribute Based Access Control) enabled registries and with repositories with PTC (Pull Through Cache) rules enabled.
- Azure Subscriptions on the "Free Trial" using free credits **aren't** supported since free trial accounts lack ACR Task access.

## Key Concepts

Because continuous patching in ACR creates a new image per patch, ACR relies on a tag convention to version and identify patched images. The two main approaches are incremental and floating.

### Incremental Tagging

**How It Works**:

Each new patch increments a numerical suffix (for example, `-1`, `-2`, etc.) on the original tag. For instance, if the base image is python:3.11, the first patch creates `python:3.11-1`, and a second patch on that same base tag creates `python:3.11-2`.

**Special Suffix Rules**:

- `-1` to `-999`: These are considered patch tags.
- `-x` where `x > 999`: These are not interpreted as patch tags; instead, that entire suffix is treated as part of the original tag. (Example: `ubuntu:jammy-20240530` is considered an original tag, not a patched one.) This means if you push a new tag ending in `-1` to `-999` by accident, Continuous Patching will treat it like a patched image. We recommend you to avoid pushing tags that you want patched with the suffix `-1` to `-999`. If `-999` versions of a patched image are hit, Continuous Patching will return an error.

### Floating Tagging

**How it works**:

A single mutable tag, `-patched`, will always reference the latest patched version of your image. For instance, if your base image tag is `python:3.11`, the first patch creates `python:3.11-patched`. With each subsequent patch, the `-patched` tag will automatically update to point to the most recent patched version.

[![Diagram showing concepts of how continuous patching works using tags.](media/continuous-patching-media/patching-timeline-example-1.png)](media/continuous-patching-media/patching-timeline-example-1.png#lightbox)

### Which Should I Use?

Incremental (**default**): Great for environments where auditability and rollbacks are critical, since each new patch is clearly identified with a unique tag.

Floating: Ideal if you prefer a single pointer to the latest patch for your CI/CD pipelines. Reduces complexity by removing the need to update references in downstream applications per patch, but sacrifices strict versioning, making it difficult to roll back.