---
title: Wrtiting a service spec
description: Writing a service spec for Formance API.
sidebar_pos: 2
---

This guide will show you how to, step by step, write a service spec for Formance API.

Let's pretend we are writing a service spec for a new service dedicated to managing KYC (Know Your Customer) data. The service will be called `kyc`.

Users of the service will be able to:
- Create a new customer profile
- Add KYC fields to the profile
- Update KYC fields
- Delete KYC fields
- Delete the customer profile
- List and get customer profiles

## Prerequisites

Before you start, make sure you have followed the [setup guide](./setup.md) to install the Typespec compiler and clone the repository.

## Bootstrapping the service

First, let's create a new directory for the service:

```bash
cd formance-api-def
mkdir kyc
```

Next, edit the `main.tsp` file to import the new service:

```typespec
import "./ledger";
import "./payments";
import "./reconciliation";
// ...
import "./kyc"; // [!code ++]
```

Now, create the file `formance-api-def/kyc/main.tsp`, with the following content:

```typespec
// kyc/main.tsp
import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;
```

In Typespec, services are defined with namespaces annotated with the `@service` annotation. We also need to specify the service title in the annotation. In addition, we must provide a server URL for the service. The server URL is mandatory to generate the OpenAPI specification. Because we don't know what will be the customer's URL, we use 'localhost'. Finally, we will also provide a base path for the service. Per the Formance API standard, the base path will be `/api/kyc`.

Let's create a namespace for the `kyc` service:

```typespec
using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

@service ({ title: "KYC Formance API" }) // [!code ++:4]
@server("http://localhost", "Default localhost endpoint")
@route("/api/kyc")
namespace KYC;
```

### Inspecting the generated OpenAPI specification

To generate the OpenAPI specification, run the following command in the `formance-api-def` directory:

```bash
tsp compile .
```

The OpenAPI specification will be generated in the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You can inspect the file to see the generated OpenAPI specification.

You should see the following content:

```yaml
openapi: 3.0.0
info:
  title: KYC Formance API
  version: 0.0.0
tags: []
paths: {}
components: {}
servers:
  - url: http://localhost
    description: Default localhost endpoint
    variables: {}
```

## Adding the `info` endpoint

The `info` endpoint is a mandatory endpoint for all services. It provides information about the service version and the service itself. Let's add the `info` endpoint to the `kyc` service:

```typespec
// kyc/main.tsp
namespace KYC;

model ServerInfo { // [!code ++:3]
  version: string;
}

@route("/_info") // [!code ++:3]
@FormanceApiStd.operation
op info(): ServerInfo;
```

In the code above, we define a model `ServerInfo` with a single field `version`. This model is used as the response for the `info` endpoint. The `info` endpoint is annotated with the `@FormanceApiStd.operation` annotation, which is a custom annotation that automatically compute and add the `operationId`, and all the SpeakEasy extensions in the OpenAPI file.

The `@route` annotation specifies the path for the endpoint. The path is concatenated with the base path of the service, so the full path for the `info` endpoint will be `/api/kyc/_info`.

### Inspecting the generated OpenAPI specification

Let's compile the service again to generate the OpenAPI specification:

```bash
tsp compile .
```

Now, inspect the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You should see the following paths and components:

```yaml
# KYC-openapi.yaml
paths:
  /api/kyc/_info:
    get:
      operationId: _info
      parameters: []
      responses:
        '200':
          description: The request has succeeded.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ServerInfo'
      x-speakeasy-name-override: info
      x-speakeasy-errors:
        statusCodes:
          - default
      x-speakeasy-retries:
        strategy: backoff
        backoff:
          initialInterval: 500
          maxInterval: 60000
          maxElapsedTime: 3600000
          exponent: 1.5
        statusCodes:
          - 5XX
        retryConnectionErrors: true
components:
  schemas:
    ServerInfo:
      type: object
      required:
        - version
      properties:
        version:
          type: string
```

## Adding the customer profile resource

### Defining the customer profile model

The customer profile resource will be the main resource of the `kyc` service. Let's add the customer profile resource to the service.

First, create the file `formance-api-def/kyc/customer.tsp` with the following content:

```typespec
// kyc/customer.tsp

// By setting the file namespace to KYC, the OpenAPI generator 
// will include the content of this file in the KYC service.
namespace KYC;

model CustomerProfile {
  id: string;
  name: string;
  email: string;
  phone: string;
  kycFields: Record<string>;
}
```

In the code above, we define a model `CustomerProfile` with the following fields:
- `id`: The unique identifier of the customer profile.
- `name`: The name of the customer.
- `email`: The email of the customer.
- `phone`: The phone number of the customer.
- `kycFields`: A map of KYC fields associated with the customer profile.

Then, import the `customer.tsp` file in the `kyc/main.tsp` file:

```typespec
// kyc/main.tsp
import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";
import "./customer.tsp"; // [!code ++]

using TypeSpec.Http;
using TypeSpec.Rest;
using FormanceApiStd;

// Redacted
```

### Adding the customer profile create endpoint

Let's add the `create` endpoint to the `kyc` service. The `create` endpoint will allow users to create a new customer profile. To better organize SDKs and enhance the developer experience, we group endpoints by resource and version. In this case, we will group the endpoints under the `CustomerV1` interface.

An interface is a Typepec construct that groups operations together. When annotated with the `@Speakeasy.group` annotation, all the embedded operations will be grouped together within the SDKs.

In the `customer.tsp` file, add the following code:

```typespec
// kyc/customer.tsp
import "@typespec/http"; // [!code ++:4]
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";

using TypeSpec.Http; // [!code ++:3]
using TypeSpec.Rest;
using FormanceApiStd;

namespace KYC;

model CustomerProfile {
  id: string;
  name: string;
  email: string;
  phone: string;
  kycFields: Record<string>;
}

@Speakeasy.group("CustomerV1") // [!code ++:7]
@route("/customers")
interface CustomerV1 {

  @FormanceApiStd.operation
  op create(name: string, email: string, phone: string): CustomerProfile;
}
```

### Inspecting the generated OpenAPI specification

Compile the service to generate the OpenAPI specification:

```bash
tsp compile .
```

Inspect the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You should see the following operation:

```yaml
/api/kyc/customers:
  post: # [!code highlight]
    operationId: CustomerV1_create # [!code highlight]
    parameters: []
    responses:
      '200':
        description: The request has succeeded.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CustomerProfile' # [!code highlight]
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              name:
                type: string
              email:
                type: string
              phone:
                type: string
            required:
              - name
              - email
              - phone
    x-speakeasy-group: CustomerV1 # [!code highlight]
    x-speakeasy-name-override: create # [!code highlight]
    x-speakeasy-errors:
      statusCodes:
        - default
    x-speakeasy-retries:
      strategy: backoff
      backoff:
        initialInterval: 500
        maxInterval: 60000
        maxElapsedTime: 3600000
        exponent: 1.5
      statusCodes:
        - 5XX
      retryConnectionErrors: true
```

Note the following:
- because the `create` operation takes a request body, the HTTP verb is set to `POST` automatically.
- the `operationId` is `CustomerV1_create` and has been automatically generated by concatenating the Speakeasy group name and the operation name.
- the `x-speakeasy-group` extension specifies the group name.
- the `x-speakeasy-name-override` extension specifies the operation name and is the same as the operation name in the Typespec file.

## Making the customer profile operation compliant with the Formance API standard

In this sectiom, we will make the `create` operation compliant with the Formance API standard. The Formance API standard defines a set of conventions and best practices for designing APIs. It includes guidelines for response formatting, error handling, authorization and pagination.

### Response formatting

#### Wrap the response data in a `FormanceResponse` object

The Formance API standard requires that all responses include a `data` field that contains the response data. The `data` field should be an object or an array of objects.

The `FormanceApiStd` module provides a helper model `FormanceResponse<T>` that can be used to wrap the response data. The `FormanceResponse<T>` model has the following fields:

```typespec
model FormanceResponse<T> {
  data: T;
}
```

To make the `create` operation compliant with the Formance API standard, we need to wrap the response data in a `FormanceResponse<CustomerProfile>` object.

In the `customer.tsp` file, modify the `create` operation as follows:

```typespec
// kyc/customer.tsp
@Speakeasy.group("CustomerV1")
@route("/customers")
interface CustomerV1 {

  @FormanceApiStd.operation
  op create(name: string, email: string, phone: string): CustomerProfile; // [!code --]
  op create(name: string, email: string, phone: string): FormanceResponse<CustomerProfile>; // [!code ++]
}
```

Recompile the service to generate the OpenAPI specification:

```bash
tsp compile .
```

Inspect the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You should see the following response schema:

```yaml
responses:
  '200':
    description: The request has succeeded.
    content:
      application/json:
        schema:
          type: object
          required:
            - data
          properties:
            data:
              $ref: '#/components/schemas/CustomerProfile'
```

#### Set the response status code to 201

The Formance API standard requires that the response status code for successful creation operations be set to `201 Created`. To set the response status code to `201`, add the `@statusCode` annotation to the response type:

```typespec
// kyc/customer.tsp
@Speakeasy.group("CustomerV1")
@route("/customers")
interface CustomerV1 {

  @FormanceApiStd.operation
  op create(name: string, email: string, phone: string): FormanceResponse<CustomerProfile>; // [!code --]
  op create(name: string, email: string, phone: string): { // [!code ++:4]
    @statusCode _: 201,
    ...FormanceResponse<CustomerProfile>
  };
}
```

Recompile the service to generate the OpenAPI specification:

```bash
tsp compile .
```

Inspect the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You should see the following response status code:

```yaml
responses:
  '201': # [!code highlight:2]
    description: The request has succeeded and a new resource has been created as a result.
    content:
      application/json:
        schema:
          type: object
          required:
            - data
          properties:
            data:
              $ref: '#/components/schemas/CustomerProfile'
```

### Error handling

A common way to handle errors in the Formance API is to return an error object in the response body, regardless of the actual HTTP status code. The error object should contain an error code, a message, and optionally additional details.

First, create the error model in the a new file `formance-api-def/kyc/error.tsp`:

```typespec
// kyc/error.tsp

namespace KYC; // Don't forger this to make sure the error model is included in the KYC service.

enum KYCErrorCode {
  INVALID_REQUEST,
  DUPLICATE_CUSTOMER,
  INTERNAL_ERROR,
};

@error
model KYCError {
  code: KYCErrorCode;
  message: string;
  details?: string;
};
```

Then, import the `error.tsp` file in the `kyc/customer.tsp` file:

```typespec
// kyc/customer.tsp
import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";
import "./error.tsp"; // [!code ++]
```

Next, modify the `create` operation to return the error model in case of an error:

```typespec
// kyc/customer.tsp
@Speakeasy.group("CustomerV1")
@route("/customers")
interface CustomerV1 {

  @FormanceApiStd.operation
  op create(name: string, email: string, phone: string): {
    @statusCode _: 201,
    ...FormanceResponse<CustomerProfile>,
  }; // [!code --]
  } | KYCError;  // [!code ++]
}
```

Recompile the service to generate the OpenAPI specification:

```bash
tsp compile .
```

Inspect the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You should see the following response status code:

```yaml
responses:
  '201':
    description: The request has succeeded and a new resource has been created as a result.
    content:
      application/json:
        schema:
          type: object
          required:
            - data
          properties:
            data:
              $ref: '#/components/schemas/CustomerProfile'
  default: # [!code highlight:6]
    description: An unexpected error response.
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/KYCError'
```

### Authorization

The Formance API standard requires that all endpoints be protected by a scoped OAuth access token. The access token is passed in the `Authorization` header of the HTTP request.

Because the Formance stack uses the `auth` service to get the access token, most of the configuration has been done for you in the `FormanceApiStd` module. You only need to define your service scopes.

To define the service scopes and the authorization rules, create a new file `formance-api-def/kyc/auth.tsp`:

```typespec
import "../oauth.tsp";

alias KYCRead = FormanceOAuth<["kyc:read"]>;
alias KYCWrite = FormanceOAuth<["kyc:write"]>;
```

Then, import the `auth.tsp` file in the `kyc/customer.tsp` file:

```typespec
// kyc/customer.tsp
import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";
import "./error.tsp";
import "./auth.tsp"; // [!code ++]
```

Next, add the `KYCWrite` alias to the `create` operation to require the `kyc:write` scope:

```typespec
// kyc/customer.tsp

@Speakeasy.group("CustomerV1")
@route("/customers")
interface CustomerV1 {

  @useAuth(KYCWrite) // [!code ++]
  @FormanceApiStd.operation
  op create(name: string, email: string, phone: string): {
    @statusCode _: 201,
    ...FormanceResponse<CustomerProfile>,
  } | KYCError;
}
```

Recompile the service to generate the OpenAPI specification:

```bash
tsp compile .
```

Inspect the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You should see the following security definition:

```yaml
/api/kyc/customers:
  post:
    operationId: CustomerV1_create
    parameters: []
    responses:
      '201':
        description: The request has succeeded and a new resource has been created as a result.
        content:
          application/json:
            schema:
              type: object
              required:
                - data
              properties:
                data:
                  $ref: '#/components/schemas/CustomerProfile'
      default:
        description: An unexpected error response.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/KYCError'
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              name:
                type: string
              email:
                type: string
              phone:
                type: string
            required:
              - name
              - email
              - phone
    security: # [!code highlight:3]
      - FormanceOAuth:
          - kyc:write
    x-speakeasy-group: CustomerV1
    x-speakeasy-name-override: create
    x-speakeasy-errors:
      statusCodes:
        - default
    x-speakeasy-retries:
      strategy: backoff
      backoff:
        initialInterval: 500
        maxInterval: 60000
        maxElapsedTime: 3600000
        exponent: 1.5
      statusCodes:
        - 5XX
      retryConnectionErrors: true

# [...]
components:
  # [...]
  securitySchemes: # [!code highlight:8]
    FormanceOAuth:
      type: oauth2
      flows:
        clientCredentials:
          tokenUrl: /api/auth/oauth/token
          scopes:
            kyc:write: ''
```

Now, let's add the remaining endpoints for the `kyc` service.

## Adding the customer profile `get` and `delete` endpoints

Now that we setup errors, authorization and response formatting, let's add the `get` and `delete` endpoints for the customer profile.

In the `customer.tsp` file, add the following code:

```typespec
// kyc/customer.tsp

@Speakeasy.group("CustomerV1")
@route("/customers")
interface CustomerV1 {
  
  @useAuth(KYCWrite)
  @FormanceApiStd.operation
  op create(name: string, email: string, phone: string): {
    @statusCode _: 201,
    ...FormanceResponse<CustomerProfile>,
  } | KYCError;

  @useAuth(KYCRead) // [!code ++:8]
  @FormanceApiStd.operation
  op get(@path id: string): FormanceResponse<CustomerProfile> | KYCError;

  @useAuth(KYCWrite)
  @FormanceApiStd.operation
  @delete
  op delete(@path id: string): void | KYCError;
}
```

The `get` and `delete` operations are similar to the `create` operation. The `get` operation retrieves a customer profile by its `id`, and the `delete` operation deletes a customer profile by its `id`.

The only difference is that we used two new annotations:
- The `@delete` annotation specifies that the operation should use the `DELETE` HTTP verb.
- The `@path` annotation specifies that the `id` parameter is a path parameter. Note that we didn't specify a route for the `get` and `delete` operations. The route is inherited from the interface and the path parameters are automatically added to the route.

Recompile the service to generate the OpenAPI specification:

```bash
tsp compile .
```

Inspect the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You should see the following operations:

```yaml
/api/kyc/customers/{id}:
  get:
    operationId: CustomerV1_get
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: string
    responses:
      '200':
        description: The request has succeeded.
        content:
          application/json:
            schema:
              type: object
              required:
                - data
              properties:
                data:
                  $ref: '#/components/schemas/CustomerProfile'
      default:
        description: An unexpected error response.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/KYCError'
    security:
      - FormanceOAuth:
          - kyc:read
    x-speakeasy-group: CustomerV1
    x-speakeasy-name-override: get
    x-speakeasy-errors:
      statusCodes:
        - default
    x-speakeasy-retries:
      strategy: backoff
      backoff:
        initialInterval: 500
        maxInterval: 60000
        maxElapsedTime: 3600000
        exponent: 1.5
      statusCodes:
        - 5XX
      retryConnectionErrors: true
  delete:
    operationId: CustomerV1_delete
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: string
    responses:
      '204':
        description: 'There is no content to send for this request, but the headers may be useful. '
      default:
        description: An unexpected error response.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/KYCError'
    security:
      - FormanceOAuth:
          - kyc:write
    x-speakeasy-group: CustomerV1
    x-speakeasy-name-override: delete
    x-speakeasy-errors:
      statusCodes:
        - default
    x-speakeasy-retries:
      strategy: backoff
      backoff:
        initialInterval: 500
        maxInterval: 60000
        maxElapsedTime: 3600000
        exponent: 1.5
      statusCodes:
        - 5XX
      retryConnectionErrors: true
```

## Adding the `list` endpoint

The `list` endpoint allows users to list all customer profiles. Here, we want to return a paginated list of customer profiles. 

The `FormanceApiStd` module provides:
- the `@paginated` annotation that automatically adds the SpeakEasy pagination parameters to the operation.
- the `PaginatedResponse<T>` model that wraps the response data and includes pagination information.

In the `customer.tsp` file, add the following code:

```typespec
@Speakeasy.group("CustomerV1")
@route("/customers")
interface CustomerV1 {
  
  // [...]

  @useAuth(KYCRead) // [!code ++:4]
  @FormanceApiStd.operation
  @paginated
  op list(@query cursor?: string): PaginatedResponse<CustomerProfile> | KYCError;
}
```

The `list` operation is similar to the other operations. The only difference is that we used the `@paginated` annotation to add pagination parameters to the operation. 

The `cursor` parameter is used to paginate the results. When using the `@pagination` annotation, the `cursor` parameter becomes mandatory and must be an optional string.

Recompile the service to generate the OpenAPI specification:

```bash
tsp compile .
```

Inspect the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You should see the following operation:

```yaml
get:
  operationId: CustomerV1_list
  parameters:
    - name: cursor # [!code highlight:5]
      in: query
      required: false
      schema:
        type: string
  responses:
    '200':
      description: The request has succeeded.
      content:
        application/json:
          schema: # [!code highlight:16]
            type: object
            required:
              - cursor
            properties:
              cursor:
                type: object
                properties:
                  next:
                    type: string
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/CustomerProfile'
                required:
                  - data
    default:
      description: An unexpected error response.
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/KYCError'
  security:
    - FormanceOAuth:
        - kyc:read
  x-speakeasy-pagination: # [!code highlight:9]
    type: cursor
    inputs:
      - name: cursor
        in: parameters
        type: cursor
    outputs:
      nextCursor: $.cursor.next
      results: $.cursor.data
  x-speakeasy-group: CustomerV1
  x-speakeasy-name-override: list
  x-speakeasy-errors:
    statusCodes:
      - default
  x-speakeasy-retries:
    strategy: backoff
    backoff:
      initialInterval: 500
      maxInterval: 60000
      maxElapsedTime: 3600000
      exponent: 1.5
    statusCodes:
      - 5XX
    retryConnectionErrors: true
```

## Add the `updateField` operation

The `updateField` operation allows users to update a KYC field of a customer profile. The operation takes the `id` of the customer profile and an array of operations that must be applied to the KYC fields.

There are two kind of operations that can be applied to the KYC fields:
- `set`: Set the value of a field. It creates the field if it doesn't exist.
- `delete`: Delete a field by name

First, we will model the field operations.

In the `customer.tsp` file, add the following code:

```typespec
// kyc/customer.tsp

namespace KYC;

model CustomerProfile {
  id: string;
  name: string;
  email: string;
  phone: string;
  kycFields: Record<string>;
}

model SetFieldOperation { // [!code ++:16]
  kind: "set";
  field: string;
  value: string;
}

model DeleteFieldOperation {
  kind: "delete";
  field: string;
}

@discriminator("kind")
union FieldOperation {
  set: SetFieldOperation;
  delete: DeleteFieldOperation;
}
``` 

The `SetFieldOperation` model represents a `set` operation that sets the value of a field. It has the following fields:
- `kind`: The operation kind, which is set to `"set"`.
- `field`: The name of the field to set.
- `value`: The value to set.

The `DeleteFieldOperation` model represents a `delete` operation that deletes a field. It has the following fields:
- `kind`: The operation kind, which is set to `"delete"`.
- `field`: The name of the field to delete.

The `FieldOperation` union represents a union of the `SetFieldOperation` and `DeleteFieldOperation` models. It is annotated with the `@discriminator` annotation to specify the discriminator field.

As an example, here is how you can update the `kycFields` of a customer profile:

```json
[
  { "kind": "set", "field": "address", "value": "123 Main St" },
  { "kind": "delete", "field": "fraud_flag" }
]
```

Next, add the `updateField` operation to the `CustomerV1` interface:

```typespec
// kyc/customer.tsp

@Speakeasy.group("CustomerV1")
@route("/customers")
interface CustomerV1 {
  
  // [...]

  @useAuth(KYCWrite) // [!code ++:4]
  @route("/{id}/fields")
  @FormanceApiStd.operation
  op updateField(@path id: string, @bodyRoot operations: FieldOperation[]): void | KYCError;
}
```

The `updateField` operation takes the `id` of the customer profile and an array of `FieldOperation` objects. The `FieldOperation` objects represent the operations to apply to the KYC fields of the customer profile.

The `@bodyRoot` annotation specifies that the `operations` parameter is the root of the request body. This means that the request body should be an array of `FieldOperation` objects. If the `@bodyRoot` annotation is not specified, the request body should be an object with a `operations` field containing the array of `FieldOperation` objects.

Recompile the service to generate the OpenAPI specification:

```bash
tsp compile .
```

Inspect the `tsp-output/@typespec/openapi3/KYC-openapi.yaml` file. You should see the following operation:

```yaml
/api/kyc/customers/{id}/fields:
  post:
    operationId: CustomerV1_updateField
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: string
    responses:
      '204':
        description: 'There is no content to send for this request, but the headers may be useful. '
      default:
        description: An unexpected error response.
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/KYCError'
    requestBody:
      required: true
      content:
        application/json:
          schema: # [!code highlight:4]
            type: array
            items:
              $ref: '#/components/schemas/FieldOperation'
    security:
      - FormanceOAuth:
          - kyc:write
    x-speakeasy-group: CustomerV1
    x-speakeasy-name-override: updateField
    x-speakeasy-errors:
      statusCodes:
        - default
    x-speakeasy-retries:
      strategy: backoff
      backoff:
        initialInterval: 500
        maxInterval: 60000
        maxElapsedTime: 3600000
        exponent: 1.5
      statusCodes:
        - 5XX
      retryConnectionErrors: true

# [...]
components:
  # [...]
  schemas:
    # [...]
    DeleteFieldOperation:
      type: object
      required:
        - kind
        - field
      properties:
        kind:
          type: string
          enum:
            - delete
        field:
          type: string
    FieldOperation:
      anyOf:
        - $ref: '#/components/schemas/SetFieldOperation'
        - $ref: '#/components/schemas/DeleteFieldOperation'
      discriminator:
        propertyName: kind
        mapping:
          set: '#/components/schemas/SetFieldOperation'
          delete: '#/components/schemas/DeleteFieldOperation'
    # [...]
    SetFieldOperation:
      type: object
      required:
        - kind
        - field
        - value
      properties:
        kind:
          type: string
          enum:
            - set
        field:
          type: string
        value:
          type: string
```

## Complete customer spec

Here is the complete `customer.tsp` file:

```typespec
import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi";
import "@formance/api-std";
import "./error.tsp";
import "./auth.tsp";

using TypeSpec.Http; 
using TypeSpec.Rest;
using FormanceApiStd;

namespace KYC;

model CustomerProfile {
  id: string;
  name: string;
  email: string;
  phone: string;
  kycFields: Record<string>;
}

model SetFieldOperation {
  kind: "set";
  field: string;
  value: string;
}

model DeleteFieldOperation {
  kind: "delete";
  field: string;
}

@discriminator("kind")
union FieldOperation {
  set: SetFieldOperation;
  delete: DeleteFieldOperation;
}

@Speakeasy.group("CustomerV1")
@route("/customers")
interface CustomerV1 {
  @useAuth(KYCWrite)
  @FormanceApiStd.operation
  op create(name: string, email: string, phone: string): { 
    @statusCode _: 201,
    ...FormanceResponse<CustomerProfile>
  } | KYCError;

  @useAuth(KYCRead)
  @FormanceApiStd.operation
  op get(@path id: string): FormanceResponse<CustomerProfile> | KYCError;

  @useAuth(KYCWrite)
  @FormanceApiStd.operation
  @delete
  op delete(@path id: string): void | KYCError;

  @useAuth(KYCRead)
  @FormanceApiStd.operation
  @paginated
  op list(@query cursor?: string): PaginatedResponse<CustomerProfile> | KYCError;

  @useAuth(KYCWrite)
  @route("/{id}/fields")
  @FormanceApiStd.operation
  op updateField(@path id: string, @bodyRoot operations: FieldOperation[]): void | KYCError;
}
```

## Conclusion

In this guide, we have shown you how to write a service spec for a KYC service in the Formance API. We have covered the following topics:
- Bootstrapping the service
- Adding the `info` endpoint
- Defining the customer profile model
- Adding the `create`, `get`, `delete`, `list`, and `updateField` endpoints
- Making the operations compliant with the Formance API standard
- Advanced operation modeling with unions and discriminators