# Dev Container Features

> This repo provides [dev container Features](https://containers.dev/implementors/features/), hosted for free on GitHub Container Registry.

## Contents

This repository contains a _collection_ of dev container Features.
Please take a closer look at the detailed instructions for the individual features:

- [Infisical CLI](src/infisical-cli)
- [Terraform State management using Git](src/terraform-backend-git)

## Repo and Feature Structure

Similar to the [`devcontainers/features`](https://github.com/devcontainers/features) repo, this repository has a `src` folder.
Each Feature has its own sub-folder, containing at least a `devcontainer-feature.json` and an entrypoint script `install.sh`. 

```
├── src
│   ├── infisical-cli
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── terraform-backend-git
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
|   ├── ...
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
├── test
│   ├── __global
│   │   ├── all_the_clis.sh
│   │   └── scenarios.json
│   ├── infisical-cli
│   │   ├── scenarios.json
│   │   └── test.sh
│   ├── terraform-backend-git
│   │   ├── scenarios.json
│   │   └── test.sh
|   ├── ...
│   │   └── test.sh
...
```

- [`src`](src) - A collection of subfolders, each declaring a Feature. Each subfolder contains at least a
  `devcontainer-feature.json` and an `install.sh` script.
- [`test`](test) - Mirroring `src`, a folder-per-feature with at least a `test.sh` script. The
  [devcontainer CLI](https://github.com/devcontainers/cli) will execute
  [these tests in CI](https://github.com/skriptfabrik/devcontainer-features/tree/main/.github/workflows/test.yaml).
