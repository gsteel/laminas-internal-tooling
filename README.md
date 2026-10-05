# `laminas/internal-tooling`

This is a dev dependency for PHP repositories in the [Laminas](https://getlaminas.org/) and [Mezzio](https://docs.mezzio.dev/mezzio/) ecosystems.

It is not intended for external use.

## Install

```bash
composer require laminas/internal-tooling
```

### Features

#### Out-of-the-box `Makefile`

Create a Makefile in the project root with the following contents, after installing this dependency via composer:

```makefile
# ./Makefile
include vendor/laminas/internal-tooling/Makefile
```

Now, running `make` should list a number of useful targets for general QA work on Laminas and Mezzio libraries.

#### Markdown Linting

With the provided `Makefile`, running `make docs-lint` will check all Markdown files in the root directory, and in the `./docs` subdirectory against the [markdownlint](https://github.com/DavidAnson/markdownlint-cli2) rules used in CI.
This target is also appended to the `qa` make target.

#### Mago Configuration

Provides a default configuration for [Mago](https://mago.carthage.software) which projects should extend for consistent coding standards via `mago fmt` and sane defaults for static analysis.

To make use of Mago, create a `mago.toml` in the root directory that extends the configuration shipped here:

```toml
#:schema https://mago.carthage.software/1.51.0/schema.json

extends = "vendor/laminas/internal-tooling/mago/defaults.toml"

# ... customised per-project rules and configuration follows
```

There are a number of `make` targets available for running Mago's suite of tools.
`make qa` will run the formatter in check mode, the linter and the analyser.
