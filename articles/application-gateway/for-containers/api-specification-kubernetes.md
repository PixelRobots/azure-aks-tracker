---
layout: Conceptual
title: Application Gateway for Containers API Specification for Kubernetes | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/api-specification-kubernetes
breadcrumb_path: /azure/bread/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/148/azure-application-gateway/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/8ae9bf04-8326-ec11-b6e6-000d3a4f0789?c=8d429912-8326-ec11-b6e6-000d3a4f0789
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
learn_banner_products:
- azure
manager: kumud
ms.reviewer: mbender
description: This article provides documentation for Application Gateway for Containers' API specification for Kubernetes.
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2026-09-11T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: 8d4cfd14-d33a-dfbb-10b6-b296414c48be
document_version_independent_id: 6a9f27a1-b5a8-4e9c-91a5-9411c5ba03f1
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/api-specification-kubernetes.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/api-specification-kubernetes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/api-specification-kubernetes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 072e93e0-1b9e-c104-03be-e787dc16c325
---

# Application Gateway for Containers API Specification for Kubernetes | Microsoft Learn

## Packages

Package v1 is the v1 version of the API.

### alb.networking.azure.io/v1

This document defines each of the resource types for `alb.networking.azure.io/v1`.

### Resource types

### AffinityType (`string` alias)

 (*Appears on:*SessionAffinity) 

AffinityType defines the affinity type for the Service

| Value | Description |
| --- | --- |
| "application-cookie" | AffinityTypeApplicationCookie is a session affinity type for an application cookie |
| "managed-cookie" | AffinityTypeManagedCookie is a session affinity type for a managed cookie |

### AlbConditionReason (`string` alias)

AlbConditionReason defines the set of reasons that explain why a particular condition type are raised by the Application Gateway for Containers resource.

| Value | Description |
| --- | --- |
| "Accepted" | AlbReasonAccepted indicates that the Application Gateway for Containers resource are accepted by the controller. |
| "Ready" | AlbReasonDeploymentReady indicates the Application Gateway for Containers resource deployment status. |
| "InProgress" | AlbReasonInProgress indicates whether the Application Gateway for Containers resource is in the process of being created, updated, or deleted. |

### AlbConditionType (`string` alias)

AlbConditionType is a type of condition associated with an Application Gateway for Containers resource. This type should be used with the AlbStatus.Conditions field.

| Value | Description |
| --- | --- |
| "Accepted" | AlbConditionTypeAccepted indicates whether the Application Gateway for Containers resource are accepted by the controller. |
| "Deployment" | AlbConditionTypeDeployment indicates the deployment status of the Application Gateway for Containers resource. |

### AlbSpec

 (*Appears on:*ApplicationLoadBalancer) 

AlbSpec defines the specifications for the Application Gateway for Containers resource.

| Field | Description |
| --- | --- |
| `associations`* []string * | Associations are subnet resource IDs the Application Gateway for Containers resource are associated with. |

### AlbStatus

 (*Appears on:*ApplicationLoadBalancer) 

AlbStatus defines the observed state of Application Gateway for Containers resource.

| Field | Description |
| --- | --- |
| `conditions`*[\[\]Kubernetes meta/v1.Condition](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Condition)* | *(Optional)*<br>Known condition types are:<br><br>- “Accepted”<br>- “Ready” |

### ApplicationLoadBalancer

ApplicationLoadBalancer is the schema for the Application Gateway for Containers resource.

| Field | Description |
| --- | --- |
| `metadata`*[Kubernetes meta/v1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#objectmeta-v1-meta)* | *(Optional)*<br>Object’s metadata.<br> Refer to the Kubernetes API documentation for the fields of the `metadata` field. |
| `spec`*AlbSpec* | Spec is the specifications for Application Gateway for Containers resource.<br><br><br>| `associations`* []string * | Associations are subnet resource IDs the Application Gateway for Containers resource are associated with. |<br>| --- | --- | |
| `status`*AlbStatus* | Status defines the current state of Application Gateway for Containers resource. |

### BackendLoadBalancingPolicy

BackendLoadBalancingPolicy represents the configuration for backend load balancing.

| Field | Description |
| --- | --- |
| `metadata`*[Kubernetes meta/v1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#objectmeta-v1-meta)* | *(Optional)*<br>Object’s metadata.<br> Refer to the Kubernetes API documentation for the fields of the `metadata` field. |
| `spec`*BackendLoadBalancingPolicySpec* | Spec is the BackendLoadBalancingPolicy specification.<br><br><br>| `targetRefs`*[]BackendLoadBalancingPolicyTargetRef* | TargetRefs identifies a list of API objects to apply policy to. |<br>| --- | --- |<br>| `loadBalancing`*LoadBalancingConfig* | *(Optional)*<br>LoadBalancing defines the schema for configuring Load Balancing options | |
| `status`*BackendLoadBalancingPolicyStatus* | Status defines the current state of BackendLoadBalancingPolicy. |

### BackendLoadBalancingPolicyConditionReason (`string` alias)

BackendLoadBalancingPolicyConditionReason defines the set of reasons that explain why a particular BackendLoadBalancingPolicy condition type is raised.

| Value | Description |
| --- | --- |
| "Accepted" | BackendLoadBalancingPolicyReasonAccepted is used to set the BackendLoadBalancingPolicyConditionReason to Accepted When the given BackendLoadBalancingPolicy is correctly configured |
| "Conflicted" | BackendLoadBalancingPolicyReasonConflicted is used when the target ref conflicts with a pre-existing policy target |
| "InvalidBackendLoadBalancingPolicy" | BackendLoadBalancingPolicyReasonInvalid is the reason when the BackendLoadBalancingPolicy isn’t Accepted |
| "InvalidGroup" | BackendLoadBalancingPolicyReasonInvalidGroup is used when the group is invalid |
| "InvalidKind" | BackendLoadBalancingPolicyReasonInvalidKind is used when the kind/group is invalid |
| "InvalidName" | BackendLoadBalancingPolicyReasonInvalidName is used when the name is invalid |
| "InvalidService" | BackendLoadBalancingPolicyReasonInvalidService is used when the Service is invalid |
| "NoTargetReference" | BackendLoadBalancingPolicyReasonNoTargetReference is used when there’s no target reference |
| "RefNotPermitted" | BackendLoadBalancingPolicyReasonRefNotPermitted is used when the ref isn’t permitted |
| "ResolvedRefs" | BackendLoadBalancingPolicyReasonResolvedRefs is used to set the BackendLoadBalancingPolicyConditionReason to ResolvedRefs when the given BackendLoadBalancingPolicy has correct references |

### BackendLoadBalancingPolicyConditionType (`string` alias)

BackendLoadBalancingPolicyConditionType is a type of condition associated with a BackendLoadBalancingPolicy. This type should be used with the BackendLoadBalancingPolicyStatus.Conditions field.

| Value | Description |
| --- | --- |
| "Accepted" | BackendLoadBalancingPolicyConditionAccepted is used to set the BackendLoadBalancingPolicyConditionType to Accepted |
| "ResolvedRefs" | BackendLoadBalancingPolicyConditionResolvedRefs is used to set the BackendLoadBalancingPolicyCondition to ResolvedRefs |

### BackendLoadBalancingPolicyPort

 (*Appears on:*BackendLoadBalancingPolicyTargetRef) 

BackendLoadBalancingPolicyPort defines the port configuration for the backend load balancing policy.

| Field | Description |
| --- | --- |
| `port`* int32 * | Port is the port to use for connection to the backend |

### BackendLoadBalancingPolicySpec

 (*Appears on:*BackendLoadBalancingPolicy, IngressBackendSettings) 

BackendLoadBalancingPolicySpec defines the specification for BackendLoadBalancingPolicy.

| Field | Description |
| --- | --- |
| `targetRefs`*[]BackendLoadBalancingPolicyTargetRef* | TargetRefs identifies a list of API objects to apply policy to. |
| `loadBalancing`*LoadBalancingConfig* | *(Optional)*<br>LoadBalancing defines the schema for configuring Load Balancing options |

### BackendLoadBalancingPolicyStatus

 (*Appears on:*BackendLoadBalancingPolicy) 

BackendLoadBalancingPolicyStatus defines the observed state of BackendLoadBalancingPolicy.

| Field | Description |
| --- | --- |
| `targets`*[]BackendLoadBalancingPolicyTargetStatus* |  |

### BackendLoadBalancingPolicyTargetRef

 (*Appears on:*BackendLoadBalancingPolicySpec) 

BackendLoadBalancingPolicyTargetRef defines the target reference and ports for the backend load balancing policy.

| Field | Description |
| --- | --- |
| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |
| `ports`*[]BackendLoadBalancingPolicyPort* | *(Optional)*<br>Ports specifies the list of ports on the target where the policy is applied. |

### BackendLoadBalancingPolicyTargetStatus

 (*Appears on:*BackendLoadBalancingPolicyStatus) 

BackendLoadBalancingPolicyTargetStatus defines the observed status for a target ref

| Field | Description |
| --- | --- |
| `targetRef`*CustomTargetRef* |  |
| `conditions`*[\[\]Kubernetes meta/v1.Condition](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Condition)* |  |

### BackendTLSPolicy

BackendTLSPolicy is the schema for the BackendTLSPolicies API.

| Field | Description |
| --- | --- |
| `metadata`*[Kubernetes meta/v1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#objectmeta-v1-meta)* | *(Optional)*<br>Object’s metadata.<br> Refer to the Kubernetes API documentation for the fields of the `metadata` field. |
| `spec`*BackendTLSPolicySpec* | Spec is the BackendTLSPolicy specification.<br><br><br>| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |<br>| --- | --- |<br>| `override`*BackendTLSPolicyConfig* | *(Optional)*<br>Override defines policy configuration that should override policy configuration attached below the targeted resource in the hierarchy.<br><br>Note: Override is currently not supported and result in a validation error. Support for Override will be added in a future release. |<br>| `default`*BackendTLSPolicyConfig* | *(Optional)*<br>Default defines default policy configuration for the targeted resource. | |
| `status`*BackendTLSPolicyStatus* | Status defines the current state of BackendTLSPolicy. |

### BackendTLSPolicyConfig

 (*Appears on:*BackendTLSPolicySpec) 

BackendTLSPolicyConfig defines the policy specification for the Backend TLS Policy.

| Field | Description |
| --- | --- |
| `CommonTLSPolicy`*CommonTLSPolicy* | (Members of `CommonTLSPolicy` are embedded into this type.) |
| `sni`* string * | *(Optional)*<br>Sni is the server name to use for the TLS connection to the backend. |
| `ports`*[]BackendTLSPolicyPort* | Ports specifies the list of ports where the policy is applied. |
| `clientCertificateRef`* Gateway API .SecretObjectReference * | *(Optional)*<br>ClientCertificateRef is the reference to the client certificate to use for the TLS connection to the backend. |

### BackendTLSPolicyPort

 (*Appears on:*BackendTLSPolicyConfig) 

BackendTLSPolicyPort defines the port to use for the TLS connection to the backend

| Field | Description |
| --- | --- |
| `port`* int * | Port is the port to use for the TLS connection to the backend |

### BackendTLSPolicySpec

 (*Appears on:*BackendTLSPolicy) 

BackendTLSPolicySpec defines the desired state of BackendTLSPolicy.

| Field | Description |
| --- | --- |
| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |
| `override`*BackendTLSPolicyConfig* | *(Optional)*<br>Override defines policy configuration that should override policy configuration attached below the targeted resource in the hierarchy.<br><br>Note: Override is currently not supported and result in a validation error. Support for Override will be added in a future release. |
| `default`*BackendTLSPolicyConfig* | *(Optional)*<br>Default defines default policy configuration for the targeted resource. |

### BackendTLSPolicyStatus

 (*Appears on:*BackendTLSPolicy) 

BackendTLSPolicyStatus defines the observed state of BackendTLSPolicy.

| Field | Description |
| --- | --- |
| `conditions`*[\[\]Kubernetes meta/v1.Condition](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Condition)* | *(Optional)*<br>Conditions describe the current conditions of the BackendTLSPolicy.<br><br>Implementations should prefer to express BackendTLSPolicy conditions using the `BackendTLSPolicyConditionType` and `BackendTLSPolicyConditionReason` constants so that operators and tools can converge on a common vocabulary to describe BackendTLSPolicy state.<br><br>Known condition types are:<br><br>- “Accepted”<br>- “ResolvedRefs” |

### CommonTLSPolicy

 (*Appears on:*BackendTLSPolicyConfig) 

CommonTLSPolicy is the schema for the CommonTLSPolicy API.

| Field | Description |
| --- | --- |
| `verify`*CommonTLSPolicyVerify* | *(Optional)*<br>Verify provides the options to verify the peer certificate. |

### CommonTLSPolicyVerify

 (*Appears on:*CommonTLSPolicy) 

CommonTLSPolicyVerify defines the schema for the CommonTLSPolicyVerify API.

| Field | Description |
| --- | --- |
| `caCertificateRef`* Gateway API .SecretObjectReference * | CaCertificateRef is the CA certificate used to verify peer certificate. |
| `subjectAltName`* string * | *(Optional)*<br>SubjectAltName is the subject alternative name used to verify peer certificate. |

### CustomTargetRef

 (*Appears on:*BackendLoadBalancingPolicyTargetRef, BackendLoadBalancingPolicyTargetStatus, BackendTLSPolicySpec, FrontendTLSPolicySpec, HealthCheckPolicySpec, PolicyRefStatus, RoutePolicySpec, WebApplicationFirewallPolicySpec) 

CustomTargetRef is a reference to a custom resource that isn’t part of the Kubernetes core API.

| Field | Description |
| --- | --- |
| `NamespacedPolicyTargetReference`* Gateway API .NamespacedPolicyTargetReference * | (Members of `NamespacedPolicyTargetReference` are embedded into this type.) |
| `sectionNames`* []string * | *(Optional)*<br>SectionNames is the name of the section within the target resource. When unspecified, this targetRef targets the entire resource. In the following resources, SectionNames is interpreted as the following:<br><br>- Gateway: Listener Name<br>- Service: Port Name<br><br><br>If a SectionNames is specified, but doesn’t exist on the targeted object, the Policy fails to attach, and the policy implementation will record a `ResolvedRefs` or similar Condition in the Policy’s status. |

### FrontendTLSPolicy

FrontendTLSPolicy is the schema for the FrontendTLSPolicy API

| Field | Description |
| --- | --- |
| `metadata`*[Kubernetes meta/v1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#objectmeta-v1-meta)* | *(Optional)*<br>Object’s metadata.<br> Refer to the Kubernetes API documentation for the fields of the `metadata` field. |
| `spec`*FrontendTLSPolicySpec* | Spec is the FrontendTLSPolicy specification.<br><br><br>| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |<br>| --- | --- |<br>| `default`*FrontendTLSPolicyConfig* | *(Optional)*<br>Default defines default policy configuration for the targeted resource. |<br>| `override`*FrontendTLSPolicyConfig* | *(Optional)*<br>Override defines policy configuration that should override policy configuration attached below the targeted resource in the hierarchy.<br><br>Note: Override is currently not supported and result in a validation error. Support for Override will be added in a future release. | |
| `status`*FrontendTLSPolicyStatus* | Status defines the current state of FrontendTLSPolicy. |

### FrontendTLSPolicyConfig

 (*Appears on:*FrontendTLSPolicySpec) 

FrontendTLSPolicyConfig defines the policy specification for the Frontend TLS Policy.

| Field | Description |
| --- | --- |
| `verify`*MTLSPolicyVerify* | *(Optional)*<br>Verify provides the options to verify the peer certificate. |
| `policyType`*PolicyType* | *(Optional)*<br>Type is the type of the policy. |

### FrontendTLSPolicySpec

 (*Appears on:*FrontendTLSPolicy) 

FrontendTLSPolicySpec defines the desired state of FrontendTLSPolicy

| Field | Description |
| --- | --- |
| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |
| `default`*FrontendTLSPolicyConfig* | *(Optional)*<br>Default defines default policy configuration for the targeted resource. |
| `override`*FrontendTLSPolicyConfig* | *(Optional)*<br>Override defines policy configuration that should override policy configuration attached below the targeted resource in the hierarchy.<br><br>Note: Override is currently not supported and result in a validation error. Support for Override will be added in a future release. |

### FrontendTLSPolicyStatus

 (*Appears on:*FrontendTLSPolicy) 

FrontendTLSPolicyStatus defines the observed state of FrontendTLSPolicy.

| Field | Description |
| --- | --- |
| `conditions`*[\[\]Kubernetes meta/v1.Condition](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Condition)* | *(Optional)*<br>Conditions describe the current conditions of the FrontendTLSPolicy.<br><br>Implementations should prefer to express FrontendTLSPolicy conditions using the `FrontendTLSPolicyConditionType` and `FrontendTLSPolicyConditionReason` constants so that operators and tools can converge on a common vocabulary to describe FrontendTLSPolicy state.<br><br>Known condition types are:<br><br>- “Accepted” |

### FrontendTLSPolicyType (`string` alias)

 (*Appears on:*PolicyType) 

FrontendTLSPolicyType is the type of the Frontend TLS Policy.

| Value | Description |
| --- | --- |
| "predefined" | PredefinedFrontendTLSPolicyType is the type of the predefined Frontend TLS Policy. |

### FrontendTLSPolicyTypeName (`string` alias)

 (*Appears on:*PolicyType) 

FrontendTLSPolicyTypeName is the name of the Frontend TLS Policy.

| Value | Description |
| --- | --- |
| "2023-06" | PredefinedPolicy202306 is the name of the predefined Frontend TLS Policy for the policy “2023-06”. |
| "2023-06-S" | PredefinedPolicy202306Strict is the name of the predefined Frontend TLS Policy for the policy “2023-06-S”. This is a strict version of the policy “2023-06”. |

### GRPCSpecifiers

 (*Appears on:*HealthCheckPolicyConfig) 

GRPCSpecifiers defines the schema for GRPC HealthCheck.

| Field | Description |
| --- | --- |
| `authority`* string * | *(Optional)*<br>Authority if present is used as the value of the Authority header in the health check. |
| `service`* string * | *(Optional)*<br>Service allows the configuration of a Health check registered under a different service name. |

### HTTPHeader

 (*Appears on:*HeaderFilter) 

HTTPHeader represents an HTTP Header name and value as defined by RFC 7230.

| Field | Description |
| --- | --- |
| `name`*HTTPHeaderName* | Name is the name of the HTTP Header to be matched. Name matching MUST be case insensitive. (See https://tools.ietf.org/html/rfc7230#section-3.2).<br><br>If multiple entries specify equivalent header names, the first entry with an equivalent name MUST be considered for a match. Subsequent entries with an equivalent header name MUST be ignored. Due to the case-insensitivity of header names, “foo” and “Foo” are considered equivalent. |
| `value`* string * | Value is the value of HTTP Header to be matched. |

### HTTPHeaderName (`string` alias)

 (*Appears on:*HTTPHeader) 

HTTPHeaderName is the name of an HTTP header.

Valid values include:

- “Authorization”
- “Set-Cookie”

Invalid values include:

- ”:method” - “:” is an invalid character. This means that HTTP/2 pseudo headers aren’t currently supported by this type.
- ”/invalid” - “/ ” is an invalid character

### HTTPMatch

 (*Appears on:*HTTPSpecifiers) 

HTTPMatch defines the HTTP matchers to use for HealthCheck checks.

| Field | Description |
| --- | --- |
| `body`* string * | *(Optional)*<br>Body defines the HTTP body matchers to use for HealthCheck checks. |
| `statusCodes`*[]StatusCodes* | *(Optional)*<br>StatusCodes defines the HTTP status code matchers to use for HealthCheck checks. |

### HTTPPathModifier

 (*Appears on:*Redirect, URLRewriteFilter) 

HTTPPathModifier defines configuration for path modifiers.

| Field | Description |
| --- | --- |
| `type`*HTTPPathModifierType* | Type defines the type of path modifier. More types may be added in a future release of the API.<br><br>Values may be added to this enum, implementations must ensure unknown values won’t cause a crash.<br><br>Unknown values here must result in the implementation setting the Accepted Condition for the rule to be false |
| `replaceFullPath`* string * | *(Optional)*<br>ReplaceFullPath specifies the value with which to replace the full path of a request during a rewrite or redirect. |
| `replacePrefixMatch`* string * | *(Optional)*<br>ReplacePrefixMatch specifies the value with which to replace the prefix match of a request during a rewrite or redirect. For example, a request to “/foo/bar” with a prefix match of “/foo” and a ReplacePrefixMatch of “/xyz” would be modified to “/xyz/bar”.<br><br>This matches the behavior of the PathPrefix match type. This matches full path elements. A path element refers to the list of labels in the path split by the `/` separator. When specified, a trailing `/` is ignored. For example, the paths `/abc`, `/abc/`, and `/abc/def` would all match the prefix `/abc`, but the path `/abcd` wouldn’t.<br><br>ReplacePrefixMatch is only compatible with a `PathPrefix` HTTPRouteMatch. Using any other HTTPRouteMatch type on the same HTTPRouteRule results in the implementation setting the Accepted Condition for the Route to `status: False`.<br><br><br>| Request Path | Prefix Match | Replace Prefix | Modified Path |<br>| --- | --- | --- | --- |<br>| /foo/bar | /foo | /xyz | /xyz/bar |<br>| /foo/bar | /foo | /xyz/ | /xyz/bar |<br>| /foo/bar | /foo/ | /xyz | /xyz/bar |<br>| /foo/bar | /foo/ | /xyz/ | /xyz/bar |<br>| /foo | /foo | /xyz | /xyz |<br>| /foo/ | /foo | /xyz | /xyz/ |<br>| /foo/bar | /foo |  | /bar |<br>| /foo/ | /foo |  | / |<br>| /foo | /foo |  | / |<br>| /foo/ | /foo | / | / |<br>| /foo | /foo | / | / | |
| --- | --- |

### HTTPPathModifierType (`string` alias)

 (*Appears on:*HTTPPathModifier) 

HTTPPathModifierType defines the type of path redirect or rewrite.

| Value | Description |
| --- | --- |
| "ReplaceFullPath" | FullPathHTTPPathModifier replaces the full path with the specified value. |
| "ReplacePrefixMatch" | PrefixMatchHTTPPathModifier replaces any prefix path with the substitution value. For example, a path with a prefix match of “/foo” and a ReplacePrefixMatch substitution of “/bar” replace “/foo” with “/bar” in matching requests.<br><br>This matches the behavior of the PathPrefix match type. This matches full path elements. A path element refers to the list of labels in the path split by the `/` separator. When specified, a trailing `/` is ignored. For example, the paths `/abc`, `/abc/`, and `/abc/def` would all match the prefix `/abc`, but the path `/abcd` wouldn’t. |

### HTTPSpecifiers

 (*Appears on:*HealthCheckPolicyConfig) 

HTTPSpecifiers defines the schema for HTTP HealthCheck check specification.

| Field | Description |
| --- | --- |
| `host`* string * | *(Optional)*<br>Host is the host header value to use for HealthCheck checks. |
| `path`* string * | *(Optional)*<br>Path is the path to use for HealthCheck checks. |
| `match`*HTTPMatch* | *(Optional)*<br>Match defines the HTTP matchers to use for HealthCheck checks. |

### HeaderFilter

 (*Appears on:*IngressRewrites) 

HeaderFilter defines a filter that modifies the headers of an HTTP request or response. Only one action for a given header name is permitted. Filters specifying multiple actions of the same or different type for any one header name are invalid and rejected. Configuration to set or add multiple values for a header must use RFC 7230 header value formatting, separating each value with a comma.

| Field | Description |
| --- | --- |
| `set`*[]HTTPHeader* | *(Optional)*<br>Set overwrites the request with the given header (name, value) before the action.<br><br>Input: GET /foo HTTP/1.1 my-header: foo<br><br>Config: set: - name: “my-header” value: “bar”<br><br>Output: GET /foo HTTP/1.1 my-header: bar |
| `add`*[]HTTPHeader* | *(Optional)*<br>Add adds the given header(s) (name, value) to the request before the action. It appends to any existing values associated with the header name.<br><br>Input: GET /foo HTTP/1.1 my-header: foo<br><br>Config: add: - name: “my-header” value: “bar,baz”<br><br>Output: GET /foo HTTP/1.1 my-header: foo,bar,baz |
| `remove`* []string * | *(Optional)*<br>Remove the given header(s) from the HTTP request before the action. The value of Remove is a list of HTTP header names. Header names are case-insensitive (see [https://datatracker.ietf.org/doc/html/rfc2616#section-4.2)](https://datatracker.ietf.org/doc/html/rfc2616#section-4.2%29).<br><br>Input: GET /foo HTTP/1.1 my-header1: foo my-header2: bar my-header3: baz<br><br>Config: remove: [“my-header1”, “my-header3”]<br><br>Output: GET /foo HTTP/1.1 my-header2: bar |

### HeaderName (`string` alias)

HeaderName is the name of a header or query parameter.

### HealthCheckPolicy

HealthCheckPolicy is the schema for the HealthCheckPolicy API.

| Field | Description |
| --- | --- |
| `metadata`*[Kubernetes meta/v1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#objectmeta-v1-meta)* | *(Optional)*<br>Object’s metadata.<br> Refer to the Kubernetes API documentation for the fields of the `metadata` field. |
| `spec`*HealthCheckPolicySpec* | Spec is the HealthCheckPolicy specification.<br><br><br>| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |<br>| --- | --- |<br>| `override`*HealthCheckPolicyConfig* | *(Optional)*<br>Override defines policy configuration that should override policy configuration attached below the targeted resource in the hierarchy.<br><br>Note: Override is currently not supported and will result in a validation error. Support for Override will be added in a future release. |<br>| `default`*HealthCheckPolicyConfig* | *(Optional)*<br>Default defines default policy configuration for the targeted resource. | |
| `status`*HealthCheckPolicyStatus* | Status defines the current state of HealthCheckPolicy. |

### HealthCheckPolicyConditionReason (`string` alias)

HealthCheckPolicyConditionReason defines the set of reasons that explain why a particular HealthCheckPolicy condition type is raised.

| Value | Description |
| --- | --- |
| "BackendTLSPolicyNotFound" | BackendTLSPolicyConditionNotFound is used when the BackendTLSPolicy is not found for the service. |
| "Accepted" | HealthCheckPolicyReasonAccepted is used to set the HealthCheckPolicyConditionReason to Accepted. When the given HealthCheckPolicy is correctly configured. |
| "InvalidHealthCheckPolicy" | HealthCheckPolicyReasonInvalid is the reason when the HealthCheckPolicy isn’t Accepted. |
| "InvalidGroup" | HealthCheckPolicyReasonInvalidGroup is used when the group is invalid. |
| "InvalidKind" | HealthCheckPolicyReasonInvalidKind is used when the kind/group is invalid. |
| "InvalidName" | HealthCheckPolicyReasonInvalidName is used when the name is invalid. |
| "InvalidPort" | HealthCheckPolicyReasonInvalidPort is used when the port is invalid. |
| "InvalidService" | HealthCheckPolicyReasonInvalidService is used when the Service is invalid. |
| "NoTargetReference" | HealthCheckPolicyReasonNoTargetReference is used when there’s no target reference. |
| "OverrideNotSupported" | HealthCheckPolicyReasonOverrideNotSupported is used when the override isn’t supported. |
| "RefNotPermitted" | HealthCheckPolicyReasonRefNotPermitted is used when the ref isn’t permitted. |
| "ResolvedRefs" | HealthCheckPolicyReasonResolvedRefs is used when the targetRef was resolved successfully. |
| "SectionNamesNotPermitted" | HealthCheckPolicyReasonSectionNamesNotPermitted is used when the section names aren’t permitted. |
| "UnsupportedStatusCodes" | HealthCheckPolicyReasonUnsupportedStatusCodes is used when the HealthCheckPolicy match StatusCodes are not supported. |

### HealthCheckPolicyConditionType (`string` alias)

HealthCheckPolicyConditionType is a type of condition associated with a HealthCheckPolicy. This type should be used with the HealthCheckPolicyStatus.Conditions field.

| Value | Description |
| --- | --- |
| "Accepted" | HealthCheckPolicyConditionAccepted is used to set the HealthCheckPolicyConditionType to Accepted. |
| "ResolvedRefs" | HealthCheckPolicyConditionResolvedRefs is used to set the HealthCheckPolicyCondition to ResolvedRefs. |

### HealthCheckPolicyConfig

 (*Appears on:*HealthCheckPolicySpec) 

HealthCheckPolicyConfig defines the schema for HealthCheck check specification.

| Field | Description |
| --- | --- |
| `interval`*[Kubernetes meta/v1.Duration](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Duration)* | *(Optional)*<br>Interval is the number of seconds between HealthCheck checks. |
| `timeout`*[Kubernetes meta/v1.Duration](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Duration)* | *(Optional)*<br>Timeout is the number of seconds after which the HealthCheck check is considered failed. |
| `port`* int32 * | *(Optional)*<br>Port is the port to use for HealthCheck checks. |
| `unhealthyThreshold`* int32 * | *(Optional)*<br>UnhealthyThreshold is the number of consecutive failed HealthCheck checks. |
| `healthyThreshold`* int32 * | *(Optional)*<br>HealthyThreshold is the number of consecutive successful HealthCheck checks. |
| `useTLS`* bool * | *(Optional)*<br>UseTLS indicates whether health check should enforce TLS. By default, health check will use the same protocol as the service if the same port is used for health check. If the port is different, health check will be plaintext. |
| `http`*HTTPSpecifiers* | *(Optional)*<br>HTTP defines the HTTP constraint specification for the HealthCheck of a target resource. |
| `grpc`*GRPCSpecifiers* | GRPC configures a gRPC v1 HealthCheck (https://github.com/grpc/grpc-proto/blob/master/grpc/health/v1/health.proto) against the target resource. |

### HealthCheckPolicySpec

 (*Appears on:*HealthCheckPolicy) 

HealthCheckPolicySpec defines the desired state of HealthCheckPolicy.

| Field | Description |
| --- | --- |
| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |
| `override`*HealthCheckPolicyConfig* | *(Optional)*<br>Override defines policy configuration that should override policy configuration attached below the targeted resource in the hierarchy.<br><br>Note: Override is currently not supported and will result in a validation error. Support for Override will be added in a future release. |
| `default`*HealthCheckPolicyConfig* | *(Optional)*<br>Default defines default policy configuration for the targeted resource. |

### HealthCheckPolicyStatus

 (*Appears on:*HealthCheckPolicy) 

HealthCheckPolicyStatus defines the observed state of HealthCheckPolicy.

| Field | Description |
| --- | --- |
| `conditions`*[\[\]Kubernetes meta/v1.Condition](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Condition)* | *(Optional)*<br>Conditions describe the current conditions of the HealthCheckPolicy.<br><br>Implementations should prefer to express HealthCheckPolicy conditions using the `HealthCheckPolicyConditionType` and `HealthCheckPolicyConditionReason` constants so that operators and tools can converge on a common vocabulary to describe HealthCheckPolicy state.<br><br>Known condition types are:<br><br>- “Accepted” |

### IngressBackendPort

 (*Appears on:*IngressBackendSettings) 

IngressBackendPort describes a port on a backend. Only one of Name/Number should be defined.

| Field | Description |
| --- | --- |
| `port`* int32 * | *(Optional)*<br>Port indicates the port on the backend service |
| `name`* string * | *(Optional)*<br>Name must refer to a name on a port on the backend service |
| `protocol`*Protocol* | Protocol should be one of “HTTP”, “HTTPS” |

### IngressBackendSettingStatus

 (*Appears on:*IngressExtensionStatus) 

IngressBackendSettingStatus describes the state of a BackendSetting

| Field | Description |
| --- | --- |
| `service`* string * | Service identifies the BackendSetting this status describes |
| `validationErrors`* []string * | *(Optional)*<br>Errors are a list of errors relating to this setting |
| `valid`* bool * | Valid indicates that there are no validation errors present on this BackendSetting |

### IngressBackendSettings

 (*Appears on:*IngressExtensionSpec) 

IngressBackendSettings provides extended configuration options for a backend service

| Field | Description |
| --- | --- |
| `service`* string * | Service is the name of a backend service that this configuration applies to |
| `ports`*[]IngressBackendPort* | *(Optional)*<br>Ports can be used to indicate if the backend service is listening on HTTP or HTTPS |
| `trustedRootCertificate`* string * | *(Optional)*<br>TrustedRootCertificate can be used to supply a certificate for the gateway to trust when communicating to the backend on a port specified as https |
| `sessionAffinity`*SessionAffinity* | *(Optional)*<br>SessionAffinity allows client requests to be consistently given to the same backend |
| `timeouts`*IngressTimeouts* | *(Optional)*<br>Timeouts define a set of timeout parameters to be applied to an Ingress |
| `loadBalancingPolicySpec`*BackendLoadBalancingPolicySpec* | *(Optional)*<br>LoadBalancing defines the load balancing policy for the backend service |

### IngressExtension

IngressExtension is the schema for the IngressExtension API

| Field | Description |
| --- | --- |
| `metadata`*[Kubernetes meta/v1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#objectmeta-v1-meta)* | *(Optional)*<br>Object’s metadata.<br> Refer to the Kubernetes API documentation for the fields of the `metadata` field. |
| `spec`*IngressExtensionSpec* | Spec is the IngressExtension specification.<br><br><br>| `rules`*[]IngressRuleSetting* | *(Optional)*<br>Rules define the rules per host |<br>| --- | --- |<br>| `backendSettings`*[]IngressBackendSettings* | *(Optional)*<br>BackendSettings defines a set of configuration options for Ingress service backends | |
| `status`*IngressExtensionStatus* |  |

### IngressExtensionConditionReason (`string` alias)

IngressExtensionConditionReason defines the set of reasons that explain why a particular IngressExtension condition type is raised.

| Value | Description |
| --- | --- |
| "Accepted" | IngressExtensionReasonAccepted is used to set the IngressExtensionConditionAccepted to Accepted |
| "HasValidationErrors" | IngressExtensionReasonHasErrors indicates there are some validation errors |
| "NoValidationErrors" | IngressExtensionReasonNoErrors indicates there are no validation errors |
| "PartiallyAcceptedWithErrors" | IngressExtensionReasonPartiallyAccepted is used to set the IngressExtensionConditionAccepted to Accepted, but with nonfatal validation errors |

### IngressExtensionConditionType (`string` alias)

IngressExtensionConditionType is a type of condition associated with a IngressExtension. This type should be used with the IngressExtensionStatus.Conditions field.

| Value | Description |
| --- | --- |
| "Accepted" | IngressExtensionConditionAccepted indicates if the IngressExtension is accepted (reconciled) by the controller |
| "Errors" | IngressExtensionConditionErrors indicates if there are validation or build errors on the extension |

### IngressExtensionSpec

 (*Appears on:*IngressExtension) 

IngressExtensionSpec defines the desired configuration of IngressExtension

| Field | Description |
| --- | --- |
| `rules`*[]IngressRuleSetting* | *(Optional)*<br>Rules define the rules per host |
| `backendSettings`*[]IngressBackendSettings* | *(Optional)*<br>BackendSettings defines a set of configuration options for Ingress service backends |

### IngressExtensionStatus

 (*Appears on:*IngressExtension) 

IngressExtensionStatus describes the current state of the IngressExtension

| Field | Description |
| --- | --- |
| `rules`*[]IngressRuleStatus* | *(Optional)*<br>Rules have detailed status information regarding each Rule |
| `backendSettings`*[]IngressBackendSettingStatus* | *(Optional)*<br>BackendSettings has detailed status information regarding each BackendSettings |
| `conditions`*[\[\]Kubernetes meta/v1.Condition](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Condition)* | *(Optional)*<br>Conditions describe the current conditions of the IngressExtension. Known condition types are:<br><br>- “Accepted”<br>- “Errors” |

### IngressRewrites

 (*Appears on:*IngressRuleSetting) 

IngressRewrites provides the various rewrites supported on a rule

| Field | Description |
| --- | --- |
| `type`*RewriteType* | Type identifies the type of rewrite |
| `requestHeaderModifier`*HeaderFilter* | *(Optional)*<br>RequestHeaderModifier defines a schema that modifies request headers. |
| `responseHeaderModifier`*HeaderFilter* | *(Optional)*<br>RequestHeaderModifier defines a schema that modifies response headers. |
| `urlRewrite`*URLRewriteFilter* | *(Optional)*<br>URLRewrite defines a schema that modifies a request during forwarding. |

### IngressRuleSetting

 (*Appears on:*IngressExtensionSpec) 

IngressRuleSetting provides configuration options for rules

| Field | Description |
| --- | --- |
| `host`* string * | Host is used to match against Ingress rules with the same hostname in order to identify which rules affect these settings |
| `additionalHostnames`* []string * | *(Optional)*<br>AdditionalHostnames specifies more hostnames to listen on |
| `rewrites`*[]IngressRewrites* | *(Optional)*<br>Rewrites defines the rewrites for the rule |
| `requestRedirect`*Redirect* | *(Optional)*<br>RequestRedirect defines the redirect behavior for the rule |

### IngressRuleStatus

 (*Appears on:*IngressExtensionStatus) 

IngressRuleStatus describes the state of a rule

| Field | Description |
| --- | --- |
| `host`* string * | Host identifies the rule this status describes |
| `validationErrors`* []string * | *(Optional)*<br>Errors are a list of errors relating to this setting |
| `valid`* bool * | *(Optional)*<br>Valid indicates that there are no validation errors present on this rule |

### IngressTimeouts

 (*Appears on:*IngressBackendSettings) 

IngressTimeouts can be used to configure timeout properties for an Ingress

| Field | Description |
| --- | --- |
| `requestTimeout`*[Kubernetes meta/v1.Duration](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Duration)* | *(Optional)*<br>RequestTimeout defines the timeout used by the load balancer when forwarding requests to a backend service |

### LoadAwareConfig

 (*Appears on:*LoadBalancingConfig) 

LoadAwareConfig defines the configuration for load aware routing.

| Field | Description |
| --- | --- |
| `blackoutPeriod`*[Kubernetes meta/v1.Duration](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Duration)* | *(Optional)*<br>An endpoint must report load metrics continuously for at least this long before the endpoint metrics will be used to influence load balancing decisions. Takes effect both immediately after we establish a connection to an endpoint and after `metricExpirationPeriod` has elapsed. Default is 10 seconds. |
| `metricExpirationPeriod`*[Kubernetes meta/v1.Duration](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Duration)* | *(Optional)*<br>If the endpoint does not report load metrics for this duration, metrics will stop being used to influence load balancing decisions. Default is 3 minutes. |
| `errorUtilizationPenalty`* string * | *(Optional)*<br>The multiplier used to adjust endpoint weights with the error rated calculated based on the reported `rps_fractional` and `eps` load metrics. Must not be a negative value. Default is 1.0. |
| `namedMetrics`* []string * | *(Optional)*<br>A list of custom metrics reported by endpoints to be used for reporting utilization and influencing load balancing decisions. Utilization will be computed by taking the max of the values of metrics specified in this list. |

### LoadBalancingConfig

 (*Appears on:*BackendLoadBalancingPolicySpec) 

LoadBalancingConfig defines the configuration for load balancing.

| Field | Description |
| --- | --- |
| `strategy`*LoadBalancingStrategy* | *(Optional)*<br>Strategy defines the policy to use when load balancing traffic to the backend service. Default is round-robin. |
| `slowStart`*SlowStartConfig* | *(Optional)*<br>SlowStart defines the schema for Slow Start specification |
| `loadAware`*LoadAwareConfig* | *(Optional)*<br>LoadAware defines the schema for Load Aware Routing specification |

### LoadBalancingStrategy (`string` alias)

 (*Appears on:*LoadBalancingConfig) 

LoadBalancingStrategy defines the policy to use when balancing traffic across a service

| Value | Description |
| --- | --- |
| "least-request" | LoadBalancingLeastRequest is used to set the LoadBalancingStrategy to least-request |
| "load-aware" | LoadBalancingLoadAware is used to set the LoadBalancingStrategy to load-aware |
| "ring-hash" | LoadBalancingRingHash is used to set the LoadBalancingStrategy to ring-hash |
| "round-robin" | LoadBalancingRoundRobin is used to set the LoadBalancingStrategy to round-robin |

### MTLSPolicyVerify

 (*Appears on:*FrontendTLSPolicyConfig) 

MTLSPolicyVerify defines the schema for the MTLSPolicyVerify API.

| Field | Description |
| --- | --- |
| `caCertificateRef`* Gateway API .SecretObjectReference * | CaCertificateRef is the CA certificate used to verify peer certificate. |
| `subjectAltNames`* []string * | *(Optional)*<br>SubjectAltNames is the list of subject alternative names used to verify peer certificate. |

### PolicyConditionReason (`string` alias)

PolicyConditionReason is the type of reason used for different ALB related policy CRDs.

| Value | Description |
| --- | --- |
| "Accepted" |  |
| "Conflicted" |  |
| "Deployed" |  |
| "DeploymentFailed" |  |
| "Invalid" |  |
| "InvalidCertificateRef" |  |
| "InvalidGroup" |  |
| "InvalidKind" |  |
| "InvalidName" |  |
| "InvalidService" |  |
| "InvalidTargetReference" |  |
| "NoDeployment" |  |
| "NoTargetReference" |  |
| "OperationFailed" |  |
| "OverrideNotSupported" |  |
| "Pending" |  |
| "Programmed" |  |
| "ProgrammingFailed" |  |
| "RefNotPermitted" |  |
| "ResolvedRefs" |  |
| "SectionNamesNotPermitted" |  |

### PolicyConditionType (`string` alias)

PolicyConditionType is the type of conditions used for different ALB related policy CRDs.

| Value | Description |
| --- | --- |
| "Accepted" |  |
| "Deployment" |  |
| "Programmed" |  |
| "ResolvedRefs" |  |

### PolicyRefStatus

PolicyRefStatus defines the status of a single target reference for a policy that supports multiple target references.

| Field | Description |
| --- | --- |
| `targetRef`*CustomTargetRef* | TargetRef is the reference to the target object that this policy applied to |
| `conditions`*[\[\]Kubernetes meta/v1.Condition](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Condition)* | *(Optional)*<br>Conditions describe the current conditions of the policy as they relate to a particular targetRef. |

### PolicyType

 (*Appears on:*FrontendTLSPolicyConfig) 

PolicyType is the type of the policy.

| Field | Description |
| --- | --- |
| `name`*FrontendTLSPolicyTypeName* | Name is the name of the policy. |
| `type`*FrontendTLSPolicyType* | FrontendTLSPolicyType specifies the frontend TLS policy type |

### PortNumber (`int32` alias)

 (*Appears on:*Redirect) 

PortNumber defines a network port.

### PreciseHostname (`string` alias)

 (*Appears on:*Redirect, URLRewriteFilter) 

PreciseHostname is the fully qualified domain name of a network host. This matches the RFC 1123 definition of a hostname with one notable exception that numeric IP addresses aren’t allowed.

Per RFC1035 and RFC1123, a *label* must consist of lower case alphanumeric characters or ‘-’, and must start and end with an alphanumeric character. No other punctuation is allowed.

### Protocol (`string` alias)

 (*Appears on:*IngressBackendPort) 

Protocol defines the protocol used for certain properties. Valid Protocol values are:

- HTTP
- HTTPS
- TCP

| Value | Description |
| --- | --- |
| "HTTP" | ProtocolHTTP implies that the service uses HTTP. |
| "HTTPS" | ProtocolHTTPS implies that the service uses HTTPS. |
| "TCP" | ProtocolTCP implies that the service uses plain TCP. |

### Redirect

 (*Appears on:*IngressRuleSetting) 

Redirect defines a filter that redirects a request. This MUST NOT be used on the same rule that also has a URLRewriteFilter.

| Field | Description |
| --- | --- |
| `scheme`* string * | *(Optional)*<br>Scheme is the scheme to be used in the value of the `Location` header in the response. When empty, the scheme of the request is used. |
| `hostname`*PreciseHostname* | *(Optional)*<br>Hostname is the hostname to be used in the value of the `Location` header in the response. When empty, the hostname in the `Host` header of the request is used. |
| `path`*HTTPPathModifier* | *(Optional)*<br>Path defines parameters used to modify the path of the incoming request. The modified path is then used to construct the `Location` header. When empty, the request path is used as-is. |
| `port`*PortNumber* | *(Optional)*<br>Port is the port to be used in the value of the `Location` header in the response.<br><br>If no port is specified, the redirect port MUST be derived using the following rules:<br><br>- If redirect scheme is not-empty, the redirect port MUST be the well-known port associated with the redirect scheme. Specifically “http” to port 80 and “https” to port 443. If the redirect scheme doesn’t have a well-known port, the listener port of the Gateway SHOULD be used.<br>- If redirect scheme is empty, the redirect port MUST be the Gateway Listener port.<br><br><br>Implementations SHOULD NOT add the port number in the ‘Location’ header in the following cases:<br><br>- A Location header that uses HTTP (whether that is determined via the Listener protocol or the Scheme field) *and* use port 80.<br>- A Location header that uses HTTPS (whether that is determined via the Listener protocol or the Scheme field) *and* use port 443. |
| `statusCode`* int * | *(Optional)*<br>StatusCode is the HTTP status code to be used in response.<br><br>Values may be added to this enum, implementations must ensure that unknown values won’t cause a crash. |

### RewriteType (`string` alias)

 (*Appears on:*IngressRewrites) 

RewriteType identifies the rewrite type

| Value | Description |
| --- | --- |
| "RequestHeaderModifier" | RequestHeaderModifier can be used to add or remove an HTTP header from an HTTP request before it’s sent to the upstream target. |
| "ResponseHeaderModifier" | ResponseHeaderModifier can be used to add or remove an HTTP header from an HTTP response before it’s sent to the client. |
| "URLRewrite" | URLRewrite can be used to modify a request during forwarding. |

### RoutePolicy

RoutePolicy is the schema for the RoutePolicy API.

| Field | Description |
| --- | --- |
| `metadata`*[Kubernetes meta/v1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#objectmeta-v1-meta)* | *(Optional)*<br>Object’s metadata.<br> Refer to the Kubernetes API documentation for the fields of the `metadata` field. |
| `spec`*RoutePolicySpec* | Spec is the RoutePolicy specification.<br><br><br>| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |<br>| --- | --- |<br>| `override`*RoutePolicyConfig* | *(Optional)*<br>Override defines policy configuration that should override policy configuration attached below the targeted resource in the hierarchy.<br><br>Note: Override is currently not supported and result in a validation error. Support for Override will be added in a future release. |<br>| `default`*RoutePolicyConfig* | *(Optional)*<br>Default defines default policy configuration for the targeted resource. | |
| `status`*RoutePolicyStatus* | Status defines the current state of RoutePolicy. |

### RoutePolicyConditionReason (`string` alias)

RoutePolicyConditionReason defines the set of reasons that explain why a particular RoutePolicy condition type is raised.

| Value | Description |
| --- | --- |
| "Accepted" | RoutePolicyReasonAccepted is used to set the RoutePolicyConditionReason to Accepted When the given RoutePolicy is correctly configured |
| "AcceptedWithTimeoutConflict" | RoutePolicyReasonAcceptedWithTimeoutConflict is used to set the RoutePolicyConditionReason to AcceptedWithTimeoutConflict When the given RoutePolicy is correctly configured but has a timeout conflict with the target route |
| "InvalidRoutePolicy" | RoutePolicyReasonInvalid is the reason when the RoutePolicy isn’t Accepted |
| "InvalidGRPCRoute" | RoutePolicyReasonInvalidGRPCRoute is used when the GRPCRoute is invalid |
| "InvalidGroup" | RoutePolicyReasonInvalidGroup is used when the group is invalid |
| "InvalidHTTPRoute" | RoutePolicyReasonInvalidHTTPRoute is used when the HTTPRoute is invalid |
| "InvalidKind" | RoutePolicyReasonInvalidKind is used when the kind/group is invalid |
| "InvalidName" | RoutePolicyReasonInvalidName is used when the name is invalid |
| "NoTargetReference" | RoutePolicyReasonNoTargetReference is used when there’s no target reference |
| "OverrideNotSupported" | RoutePolicyReasonOverrideNotSupported is used when the override isn’t supported |
| "RefNotPermitted" | RoutePolicyReasonRefNotPermitted is used when the ref isn’t permitted |
| "SectionNamesNotPermitted" | RoutePolicyReasonSectionNamesNotPermitted is used when the section names aren’t permitted |

### RoutePolicyConditionType (`string` alias)

RoutePolicyConditionType is a type of condition associated with a RoutePolicy. This type should be used with the RoutePolicyStatus.Conditions field.

| Value | Description |
| --- | --- |
| "Accepted" | RoutePolicyConditionAccepted is used to set the RoutePolicyConditionType to Accepted |
| "ResolvedRefs" | RoutePolicyConditionResolvedRefs is used to set the RoutePolicyCondition to ResolvedRefs |

### RoutePolicyConfig

 (*Appears on:*RoutePolicySpec) 

RoutePolicyConfig defines the schema for RoutePolicy specification. This allows the specification of the following attributes: \* Timeouts \* Session Affinity

| Field | Description |
| --- | --- |
| `timeouts`*RouteTimeouts* | *(Optional)*<br>Custom Timeouts Timeout for the target resource. |
| `sessionAffinity`*SessionAffinity* | *(Optional)*<br>SessionAffinity defines the schema for Session Affinity specification |

### RoutePolicySpec

 (*Appears on:*RoutePolicy) 

RoutePolicySpec defines the desired state of RoutePolicy.

| Field | Description |
| --- | --- |
| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |
| `override`*RoutePolicyConfig* | *(Optional)*<br>Override defines policy configuration that should override policy configuration attached below the targeted resource in the hierarchy.<br><br>Note: Override is currently not supported and result in a validation error. Support for Override will be added in a future release. |
| `default`*RoutePolicyConfig* | *(Optional)*<br>Default defines default policy configuration for the targeted resource. |

### RoutePolicyStatus

 (*Appears on:*RoutePolicy) 

RoutePolicyStatus defines the observed state of RoutePolicy.

| Field | Description |
| --- | --- |
| `conditions`*[\[\]Kubernetes meta/v1.Condition](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Condition)* | *(Optional)*<br>Conditions describe the current conditions of the RoutePolicy.<br><br>Implementations should prefer to express RoutePolicy conditions using the `RoutePolicyConditionType` and `RoutePolicyConditionReason` constants so that operators and tools can converge on a common vocabulary to describe RoutePolicy state.<br><br>Known condition types are:<br><br>- “Accepted” |

### RouteTimeouts

 (*Appears on:*RoutePolicyConfig) 

RouteTimeouts defines the schema for Timeouts specification.

| Field | Description |
| --- | --- |
| `routeTimeout`*[Kubernetes meta/v1.Duration](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Duration)* | *(Optional)*<br>RouteTimeout is the timeout for the route. |

### SessionAffinity

 (*Appears on:*IngressBackendSettings, RoutePolicyConfig) 

SessionAffinity defines the schema for Session Affinity specification.

| Field | Description |
| --- | --- |
| `affinityType`*AffinityType* |  |
| `cookieName`* string * | *(Optional)* |
| `cookieDuration`*[Kubernetes meta/v1.Duration](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Duration)* | *(Optional)* |

### SlowStartConfig

 (*Appears on:*LoadBalancingConfig) 

SlowStartConfig defines the configuration for slow start.

| Field | Description |
| --- | --- |
| `window`*[Kubernetes meta/v1.Duration](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Duration)* | The duration of the slow start window. |
| `aggression`* string * | *(Optional)*<br>The speed of traffic increase over the slow start window, must be greater than 0.0. Defaults to 1.0 if unspecified. |
| `startWeightPercent`* uint32 * | *(Optional)*<br>The minimum or starting percentage of traffic to send to new endpoints. Defaults to 10% if unspecified. |

### StatusCodes

 (*Appears on:*HTTPMatch) 

StatusCodes defines the HTTP status code matchers to use for HealthCheck checks.

| Field | Description |
| --- | --- |
| `start`* int32 * | *(Optional)*<br>Start defines the start of the range of status codes to use for HealthCheck checks. This is inclusive. |
| `end`* int32 * | *(Optional)*<br>End defines the end of the range of status codes to use for HealthCheck checks. This is inclusive. |

### URLRewriteFilter

 (*Appears on:*IngressRewrites) 

URLRewriteFilter defines a filter that modifies a request during forwarding. At most one of these filters may be used on a rule. This MUST NOT be used on the same rule having an sslRedirect.

| Field | Description |
| --- | --- |
| `hostname`*PreciseHostname* | *(Optional)*<br>Hostname is the value to be used to replace the Host header value during forwarding. |
| `path`*HTTPPathModifier* | *(Optional)*<br>Path defines a path rewrite. |

### WebApplicationFirewallConfig

 (*Appears on:*WebApplicationFirewallPolicySpec) 

WebApplicationFirewallConfig defines the web application firewall policy configuration for the Application Gateway for Containers Security Policy child resource.

| Field | Description |
| --- | --- |
| `id`* string * |  |

### WebApplicationFirewallPolicy

WebApplicationFirewallPolicy is the schema for the Application Gateway for Containers Security Policy child resource.

| Field | Description |
| --- | --- |
| `metadata`*[Kubernetes meta/v1.ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#objectmeta-v1-meta)* | *(Optional)*<br>Object’s metadata.<br> Refer to the Kubernetes API documentation for the fields of the `metadata` field. |
| `spec`*WebApplicationFirewallPolicySpec* | Spec is the specifications for Application Gateway for Containers Security Policy child resource.<br><br><br>| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |<br>| --- | --- |<br>| `webApplicationFirewall`*WebApplicationFirewallConfig* | WebApplicationFirewallPolicy is used to specify a WebApplicationPolicy resource | |
| `status`*WebApplicationFirewallPolicyStatus* | Status defines the current state of Application Gateway for Containers Security Policy child resource. |

### WebApplicationFirewallPolicySpec

 (*Appears on:*WebApplicationFirewallPolicy) 

WebApplicationFirewallPolicySpec defines the desired state of WebApplicationFirewallPolicy.

| Field | Description |
| --- | --- |
| `targetRef`*CustomTargetRef* | TargetRef identifies an API object to apply policy to. |
| `webApplicationFirewall`*WebApplicationFirewallConfig* | WebApplicationFirewallPolicy is used to specify a WebApplicationPolicy resource |

### WebApplicationFirewallPolicyStatus

 (*Appears on:*WebApplicationFirewallPolicy) 

WebApplicationFirewallPolicyStatus defines the observed state of Application Gateway for Containers Security Policy child resource.

| Field | Description |
| --- | --- |
| `conditions`*[\[\]Kubernetes meta/v1.Condition](https://pkg.go.dev/k8s.io/apimachinery/pkg/apis/meta/v1#Condition)* | *(Optional)*<br>Known condition types are:<br><br>- “Accepted”<br>- “Deployment”<br>- “ResolvedRefs”<br>- “Programmed” |