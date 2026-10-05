# `laminas/internal-tooling`

This is a dev dependency for PHP repositories in the [Laminas](https://getlaminas.org/) and [Mezzio](https://docs.mezzio.dev/mezzio/) ecosystems.

It is not intended for external use.

## Install

```bash
composer require laminas/internal-tooling
```

### Features

#### Mago Configuration

Provides a default configuration for [Mago](https://mago.carthage.software) which projects should extend for consistent coding standards via `mago fmt` and sane defaults for static analysis.

To make use of Mago, create a `mago.toml` in the root directory that extends the configuration shipped here:

```toml
#:schema https://mago.carthage.software/1.51.0/schema.json

extends = "vendor/laminas/internal-tooling/mago/defaults.toml"

# ... customised per-project rules and configuration follows
```
