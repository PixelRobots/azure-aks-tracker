---
layout: Conceptual
title: Configure Networking on Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/configure-networking
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
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
manager: kumud
description: Learn how to configure and manage networking on Azure Linux using `systemd-networkd`, including DHCP and static IP setup, interface management, and network troubleshooting.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 4c00c8dd-372d-43ab-81dc-c6eced2e051b
document_version_independent_id: e1b6b2d9-2c45-b525-9cc3-e9990038aec0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/configure-networking.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/configure-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/configure-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: a6f000d9-9357-14aa-91d3-4803e43f6bec
---

# Configure Networking on Azure Linux | Microsoft Learn

Azure Linux uses [`systemd-networkd`](https://www.freedesktop.org/software/systemd/man/systemd-networkd.html) as its default network management service. `systemd-networkd` is a lightweight system service that configures and manages network interfaces declaratively through configuration files.

This article shows you how to manage the `systemd-networkd` service, where to place network configuration files, how to define common interface configurations such as DHCP and static IP, and how to monitor and troubleshoot network state on an Azure Linux system.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Prerequisites

- An Azure Linux system that you can authenticate to with shell access.
- A user account with `sudo` privileges, which is required to manage system services and edit network configuration files under `/etc/systemd/network/`.

## Capabilities of `systemd-networkd`

You can use `systemd-networkd` on Azure Linux virtual machines (VMs) to perform the following networking tasks:

- Configure network interfaces with DHCP or static IP addresses.
- Manage multiple network interface cards (NICs) on a single host.
- Configure advanced networking features such as VLANs, bridges, and bonded interfaces.
- Integrate with the DHCP and DNS services that the Azure platform provides.

## Manage the `systemd-networkd` service

Use `systemctl` to start, stop, restart, and check the status of the `systemd-networkd` service.

### Start the `systemd-networkd` service

Start the `systemd-networkd` service using the following command:

```bash
sudo systemctl start systemd-networkd
```

### Stop the `systemd-networkd` service

Note

This action shuts down all networking within the VM, immediately terminating the active SSH session and leaving the VM completely unreachable by any standard means, aside from access through the serial console.

Stop the `systemd-networkd` service using the following command:

```bash
sudo systemctl stop systemd-networkd
```

### Restart the `systemd-networkd` service

Restart the `systemd-networkd` service, for example after you change a configuration file, using the following command:

```bash
sudo systemctl restart systemd-networkd
```

### Check the service status

Check the `systemd-networkd` service status and view its most recent log entries using the following command:

```bash
sudo systemctl status systemd-networkd
```

The output shows whether the service is loaded, active, and enabled at boot, along with the most recent log lines that the service produced.

### View service logs

View the full log history for the `systemd-networkd` service using the following command:

```bash
journalctl -u systemd-networkd
```

The output includes every log line that the service has emitted since the system started, which helps you diagnose issues such as failed interface configuration or DHCP problems.

## Network configuration files

`systemd-networkd` reads its configuration from drop-in files in two well-known directories. Each file uses a specific extension that determines what kind of configuration it provides.

The following table describes the directories and file types that `systemd-networkd` uses:

| File or directory | Purpose |
| --- | --- |
| `/etc/systemd/network/` | Directory for custom network configurations that you create. |
| `/lib/systemd/network/` | Directory for default network configurations that are installed by packages. |
| `.network` files | Define interface behavior, such as DHCP, static IP, gateway, and DNS. |
| `.netdev` files | Define virtual devices, such as bonds, bridges, and VLANs. |
| `.link` files | Define hardware link properties, such as renaming NICs and setting the MTU. |

Place your custom configuration files in `/etc/systemd/network/`. Files in `/etc/systemd/network/` take precedence over files with the same name in `/lib/systemd/network/`.

The following sections provide example network configuration files (`.network` files) for common scenarios on Azure Linux VMs.

### Example: Configure a primary NIC with DHCP

The following example `.network` file configures the primary network interface (`eth0`) to obtain its IP address from a DHCP server:

```ini
[Match]
Name=eth0

[Network]
DHCP=yes
```

This is the typical configuration for an Azure Linux VM, where the primary network interface receives its IP address dynamically from the Azure DHCP service.

Save the file with a `.network` extension under `/etc/systemd/network/`, for example as `/etc/systemd/network/10-eth0.network`, and then restart `systemd-networkd` to apply the change.

### Example: configure a secondary NIC with a static IP

The following example `.network` file configures a secondary network interface (`eth1`) with a static IP address, gateway, and DNS server. Replace `<IP_ADDRESS>`, `<CIDR>`, `<GATEWAY_IP>`, and `<DNS_IP>` with values that match your network:

```ini
[Match]
Name=eth1

[Network]
Address=<IP_ADDRESS>/<CIDR>
Gateway=<GATEWAY_IP>
DNS=<DNS_IP>
```

Save the file with a `.network` extension under `/etc/systemd/network/`, for example as `/etc/systemd/network/20-eth1.network`, and then restart `systemd-networkd` to apply the change.

## Monitor and troubleshoot networking

Use the `networkctl` and `ip` commands to inspect the current state of your network interfaces and verify that your configuration is correctly applied.

### List all known network interfaces

List every network interface that `systemd-networkd` knows about, along with its type, operational state, and configuration state using the following command:

```bash
networkctl list
```

### Show details for a specific network interface

Show detailed status information for a specific interface using the following command. Replace `<INTERFACE>` with the name of the interface that you want to inspect, such as `eth0`:

```bash
networkctl status <INTERFACE>
```

The output includes the interface's IP addresses, gateway, DNS servers, and the configuration file that's currently applied to it.

### Discover other `networkctl` commands

See every subcommand and option that `networkctl` supports using the following command:

```bash
networkctl --help
```

### Verify IP addresses and routes

Use the `ip` commands to verify that the expected IP addresses and routes are configured on the system.

#### List all assigned IP addresses

List every IP address that's assigned to each network interface, using the following command:

```bash
ip addr
```

#### List all routes

List every route in the system's routing table using the following command:

```bash
ip route
```