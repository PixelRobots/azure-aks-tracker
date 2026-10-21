---
layout: Conceptual
title: Download the OSM client Library - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-binary
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Download and configure the Open Service Mesh (OSM) client library
ms.topic: concept-article
ms.subservice: aks-networking
ms.custom: linux-related-content
ms.date: 2024-09-25T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
zone_pivot_groups: client-operating-system
locale: en-us
document_id: 1e5429fc-78bd-76bb-078d-9ac7fbf8fd28
document_version_independent_id: 6456150f-2431-0c91-c850-eb8fe55a3cfe
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/open-service-mesh-binary.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/open-service-mesh-binary
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/open-service-mesh-binary.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a3dede83-da25-ec6c-f20f-ce2560dcbb04
---

# Download the OSM client Library - Azure Kubernetes Service | Microsoft Learn

This article shows how to download the OSM client library to operate and configure the OSM add-on for Azure Kubernetes Service (AKS) and how to configure the binary for your environment.

Important

Starting on **September 30, 2027**, Azure Kubernetes Service (AKS) no longer supports the Open Service Mesh (OSM) add-on. The upstream [Open Service Mesh project](https://www.cncf.io/projects/open-service-mesh/) has been retired.

If your cluster uses the OSM add-on, migrate to the Istio add-on before the end-of-support date. This retirement notice applies only to the managed OSM add-on and doesn't address open-source or self-managed service mesh installations. For migration steps, see [Migration guidance from the OSM add-on to the Istio add-on](open-service-mesh-istio-migration-guidance). To stay informed about AKS announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Based on the version of Kubernetes your cluster is running, the OSM add-on installs a different version of OSM.

| Kubernetes version | OSM version installed |
| --- | --- |
| 1.24.0 or greater | 1.2.5 |
| Between 1.23.5 and 1.24.0 | 1.1.3 |
| Below 1.23.5 | 1.0.0 |

Older versions of OSM might not be available for install or actively supported if the corresponding AKS version reached end of life. Check the [AKS Kubernetes release calendar](supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions) for information on AKS version support windows.

::: zone pivot="client-operating-system-linux"

## Download and install the Open Service Mesh (OSM) client binary

In a bash-based shell on Linux or [Windows Subsystem for Linux](/en-us/windows/wsl/install-win10), use `curl` to download the OSM release and then extract with `tar` as follows:

```bash
# Specify the OSM version that will be leveraged throughout these instructions
OSM_VERSION=v1.2.0

curl -sL "https://github.com/openservicemesh/osm/releases/download/$OSM_VERSION/osm-$OSM_VERSION-linux-amd64.tar.gz" | tar -vxzf -
```

The `osm` client binary runs on your client machine and allows you to manage OSM in your AKS cluster. Use the following commands to install the OSM `osm` client binary in a bash-based shell on Linux or [Windows Subsystem for Linux](/en-us/windows/wsl/install-win10). These commands copy the `osm` client binary to the standard user program location in your `PATH`.

```bash
sudo mv ./linux-amd64/osm /usr/local/bin/osm
sudo chmod +x /usr/local/bin/osm
```

You can verify the `osm` client library has been correctly added to your path and its version number with the following command.

```bash
osm version
```

::: zone-end

::: zone pivot="client-operating-system-macos"

## Download and install the Open Service Mesh (OSM) client binary

In a bash-based shell, use `curl` to download the OSM release and then extract with `tar` as follows:

```bash
# Specify the OSM version that will be leveraged throughout these instructions
OSM_VERSION=v1.2.0

curl -sL "https://github.com/openservicemesh/osm/releases/download/$OSM_VERSION/osm-$OSM_VERSION-darwin-amd64.tar.gz" | tar -vxzf -
```

The `osm` client binary runs on your client machine and allows you to manage OSM in your AKS cluster. Use the following commands to install the OSM `osm` client binary in a bash-based shell. These commands copy the `osm` client binary to the standard user program location in your `PATH`.

```bash
sudo mv ./darwin-amd64/osm /usr/local/bin/osm
sudo chmod +x /usr/local/bin/osm
```

You can verify the `osm` client library has been correctly added to your path and its version number with the following command.

```bash
osm version
```

::: zone-end

::: zone pivot="client-operating-system-windows"

## Download and install the Open Service Mesh (OSM) client binary

In a PowerShell-based shell on Windows, use `Invoke-WebRequest` to download the OSM release and then extract with `Expand-Archive` as follows:

```powershell
# Specify the OSM version that will be leveraged throughout these instructions
$OSM_VERSION="v1.2.0"

[Net.ServicePointManager]::SecurityProtocol = "tls12"
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -URI "https://github.com/openservicemesh/osm/releases/download/$OSM_VERSION/osm-$OSM_VERSION-windows-amd64.zip" -OutFile "osm-$OSM_VERSION.zip"
Expand-Archive -Path "osm-$OSM_VERSION.zip" -DestinationPath .
```

The `osm` client binary runs on your client machine and allows you to manage the OSM controller in your AKS cluster. Use the following commands to install the OSM `osm` client binary in a PowerShell-based shell on Windows. These commands copy the `osm` client binary to an OSM folder and then make it available both immediately (in current shell) and permanently (across shell restarts) via your `PATH`. You don't need elevated (Admin) privileges to run these commands and you don't need to restart your shell.

```powershell
# Copy osm.exe to C:\OSM
New-Item -ItemType Directory -Force -Path "C:\OSM"
Move-Item -Path .\windows-amd64\osm.exe -Destination "C:\OSM\"

# Add C:\OSM to PATH.
# Make the new PATH permanently available for the current User
$USER_PATH = [environment]::GetEnvironmentVariable("PATH", "User") + ";C:\OSM\"
[environment]::SetEnvironmentVariable("PATH", $USER_PATH, "User")
# Make the new PATH immediately available in the current shell
$env:PATH += ";C:\OSM\"
```

::: zone-end

Warning

Don't attempt to install OSM from the binary using `osm install`. This will result in an installation of OSM that isn't integrated as an add-on for AKS.

## Configure OSM CLI variables with an OSM\_CONFIG file

Users can override the default OSM CLI configuration to enhance the add-on experience. This can be done by creating a config file, similar to `kubeconfig`. The config file can be either created at `$HOME/.osm/config.yaml`, or at a different path that is exported using the `OSM_CONFIG` environment variable.

The file must contain the following YAML formatted content:

```yaml
install:
  kind: managed
  distribution: AKS
  namespace: kube-system
```

If the file isn't created at `$HOME/.osm/config.yaml`, remember to set the `OSM_CONFIG` environment variable to point to the path where the config file is created.

After setting OSM\_CONFIG, the output of the `osm env` command should be the following:

```console
$ osm env
---
install:
  kind: managed
  distribution: AKS
  namespace: kube-system
```