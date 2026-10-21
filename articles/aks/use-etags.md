---
layout: Conceptual
title: Enhancing Concurrency Control with Entity Tags (eTags) in Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-etags
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
description: Learn how to use eTags (Entity Tags) to enable concurrency control and avoid racing conditions or overwriting scenarios.
ms.topic: how-to
ms.date: 2024-06-10T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: aks, etag, concurrency-control
ms.subservice: aks-nodes
locale: en-us
document_id: a9eb76fe-4654-6f42-97ff-66bde865f9d7
document_version_independent_id: 591347d9-40db-2c4c-a113-46cbc1556c38
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-etags.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/use-etags
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-etags.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 38712ab6-c342-bb3b-d09b-03268904e28d
---

# Enhancing Concurrency Control with Entity Tags (eTags) in Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

To prevent conflicting requests in Azure Kubernetes Service (AKS), eTags (Entity Tags) serve as unique identifiers that enable concurrency control. When a request to the cluster is made, the system checks whether the provided eTag matches the latest version stored in the database. If there is a mismatch, the request fails early, ensuring that no unintended overwrites occur.

## Utilizing eTag Headers

There are two options for applying eTags through headers:

**`–-if-match`** Header: Ensures that the operation is performed only if the existing eTag matches the value provided in this header.

**`–-if-none-match`** Header: Ensures that the operation is performed only if none of the eTags matches the value provided in this header. This header type can only be empty or a `*`.

### Find existing ETags

You can do either a `LIST` or a `GET` call to your cluster or node pool to see the existing ETag. An ETag looks something like the following example:

```
"agentPoolProfiles": [
    {"eTag": "5e5ffdce-356b-431b-b050-81b45eef2a12"}
]
```

### What would modify existing ETags

ETags can exist at both the cluster and agent pool levels. Depending on the scope of the operations you are performing, you can pass in the corresponding eTag. When you perform a cluster-level operation, both the cluster-level eTag and agent pool eTag are updated. When you perform an agent pool operation, only the agent pool eTag is updated.

### Include ETags in operation headers

Headers are optional to use. The following examples show how to use `–-if-match` and `-–if-none-match` headers.

**Example 1**: The CLI command below deletes an existing cluster `MyManagedCluster` if the eTag matches with `yvjvt`

Suppose you want to delete an AKS cluster using its eTag. (For illustration, replace `"yvjvt"` with the actual eTag value you retrieved from the resource.)

```shell
az aks delete -g $RG_NAME -n $CLUSTER_NAME --if-match "yvjvt"
```

**Example 2**: The CLI command below creates a new cluster. If `*` is provided in the `–if-none-match` header, that means to validate the resource does not exist.

First, create a resource group:

```azurecli
export RANDOM_SUFFIX=$(head -c 3 /dev/urandom | xxd -p)
export RG_NAME="my-resource-group$RANDOM_SUFFIX"
export REGION="eastus2"

az group create --name $RG_NAME --location $REGION 
```

Then, create a new AKS cluster with a random suffix to ensure uniqueness:

```azurecli
export CLUSTER_NAME="my-managed-cluster$RANDOM_SUFFIX"

az aks create -g $RG_NAME -n $CLUSTER_NAME --location $REGION --if-none-match "*"
```

Results:

```output
{
  "aadProfile": null,
  "addonProfiles": null,
  "agentPoolProfiles": [
    {
      "eTag": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      ...
    }
  ],
  "apiServerAccessProfile": null,
  "autoScalerProfile": null,
  ...
  "name": "my-managed-clusterxxx",
  ...
  "provisioningState": "Succeeded",
  ...
  "resourceGroup": "my-resource-groupxxx",
  ...
}
```

### Configurations and Expected Behavior

The table below outlines the expected behavior of HTTP operations (PUT, PATCH, and DELETE) based on different eTag configurations and resource existence. They show how the presence of `--if-match` or `--if-none-match` headers affects the response status codes, ensuring concurrency control and preventing unintended modifications.

| **PUT** | **Resource does not exist** | **Resource exists** |
| --- | --- | --- |
| **`--if-match = ""`** | 201 – Created | 200 - Ok |
| **`--if-match = "*"`** | 412 - Precondition Failed | 200 - OK |
| **`--if-match = "xyz"`** | 412 - Precondition Failed | 200 - OK OR 412 - Precondition Failed |
| **`--if-none-match = "*"`** | 201 - Created | 412 - Precondition Failed |

| **PATCH** | **Resource does not exist** | **Resource exists** |
| --- | --- | --- |
| **`--if-match = ""`** | 404 - Not Found | 200 - OK |
| **`--if-match = "*"`** | 404 - Not Found | 200 - OK |
| **`--if-match = "xyz"`** | 404 - Not Found | 200 - OK OR 412 - Precondition Failed |

| **DELETE** | **Resource does not exist** | **Resource exists** |
| --- | --- | --- |
| **`--if-match = ""`** | 204 - No Content | 200 - OK |
| **`--if-match = "*"`** | 204 - No Content | 200 - OK |
| **`--if-match = "xyz"`** | 204 - No Content | 200 - OK OR 412 - Precondition Failed |

## Common Issues and Recommended Mitigations

### **Scenario 1**: `BadRequest` – `--if-none-match` header is not empty or not set to `*`

This fails the prevalidation checks. The `--if-none-match` header can only be empty or take a value of `*`.

### **Scenario 2**: `BadRequest` - `--if-match` header is not empty AND `--if-none-match` header is `*`

This fails the prevalidation checks. Both headers cannot be used at the same time.

### **Scenario 3**: `PreConditionFailed` - `--if-none-match` is `*` and the given resource already exists

The request is rejected if a `*` (wildcard of any) value is passed into `--if-none-match` header and the resource already exists.

### **Scenario 4**: `PreConditionFailed` - The value of `--if-match` header does not match the latest eTag value of the resource

The request is rejected if the header provided does not match with the eTag value. A new GET operation is needed to get the latest eTag on the resource and update the header value in the request.