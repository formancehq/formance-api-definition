---
title: Setup
sidebar_position: 1
---

# Setup

First, install the globally the typespec compiler:

```bash
pnpm install -g @typespec/compiler
```

:::info
This repository uses `pnpm` as package manager. If you don't have it installed, you can install it globally with `npm install -g pnpm`.
:::

Then, clone the repository and install the dependencies:

```bash
git clone git@github.com:formancehq/formance-api-definition.git
cd formance-api-definition
pnpm install
```

To compile the API specification, run:

```bash
cd formance-api-def
tsp compile .
```

:::info
We recommend that you install the [VSCode extension](https://marketplace.visualstudio.com/items?itemName=typespec.typespec-vscode) to have a better experience with the API specification edition.
:::

