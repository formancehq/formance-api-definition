# Formance Typespec API standards

This repository contains the standards for the Formance Typespec API.

It is composed of decorators, types, linter rules, and other tools to help you write and maintain your API.

## Getting started

To get started, you need to create a Typespec project. You can do this by running the following command:

```bash
tsp init
```

:::note
You can install the `tsp` CLI by following the instructions at https://typespec.io/docs
:::

Then, install the Formance Typespec API standards from the Github NPM registry:

```bash
npm install @formance/typespec-api-std
```

## Usage

To use the Formance Typespec API standards, you need to import the decorators and types from the package:

```typespec
import "@formance/api-std";

using FormanceApiStd;

@Speakeasy.group
interface Users {
  @Speakeasy.autoGroup
  op get(): User[];
  
  @Speakeasy.autoGroup
  @paginated
  op list(cursor?: string): PaginatedResponse<User>;
}
```

## Reference

### Decorators

#### `@Speakeasy.group`

This decorator is used to define a group of operations. It is used to group related operations together. 

It can be applied on interfaces or namespaces.

#### `@Speakeasy.autoGroup`

This decorator is used to automatically compute the operation name and group name based on the operation name and the `@Speakeasy.group` decorators in the name hierarchy. It can be applied on operations only.

In addition to the name and group, it also adds Speakeasy metadata to generate working SDKs, which are error management strategies and retries configuration.

#### `@paginated`

This decorator is used to define a paginated operation. It will check that the operation input and output are correctly defined for pagination and it will add the necessary Speakeseasy metadata to generate working SDKs.

The decorator expects the operation:
- to return a response with a `cursor.next` and a `cursor.data` field. This can be easily achieved by using the `PaginatedResponse` type.
- to accept an optional `cursor` parameter.

### Types

#### `PaginatedResponse<T>`
A generic type that represents a paginated response. It has the following structure:

```typespec
model PaginatedResponse<T> {
  cursor: {
    next?: string;
    data: T[];
  };
}
```
