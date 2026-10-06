# `laminas/internal-tooling`

This is a dev dependency for PHP repositories in the [Laminas](https://getlaminas.org/) and [Mezzio](https://docs.mezzio.dev/mezzio/) ecosystems.

It is not intended for external use.

## Install

```bash
composer require laminas/internal-tooling
```

Next, copy the shipped `Makefile` template to the root of the project with:

```bash
cp vendor/laminas/internal-tooling/templates/MakefileTemplate.mk ./Makefile
```

The template will need some adjustment depending on the project.

## Requirements

Pretty much everything runs in Docker, so you will need docker installed and running on the host machine for the make targets to work.

Other host machine dependencies include:

- `xpath` Some targets shell out to `xpath` to inspect XML configuration files
- `find` Used in some situations to discover files in the working tree
- `git` Used to fetch the documentation theme when building docs

## Features

### Out-of-the-box `Makefile`

Create a Makefile in the project root with the following contents, after installing this dependency via composer:

```makefile
# ./Makefile
include vendor/laminas/internal-tooling/Makefile
```

Now, running `make` should list a number of useful targets for general QA work on Laminas and Mezzio libraries.

Most tools that perform QA checks that can be detected as being installed are added to the `qa` target, so issuing `make qa` will run everything in series.

### Markdown Linting

With the provided `Makefile`, running `make docs-lint` will check all Markdown files in the root directory, and in the `./docs` subdirectory against the [markdownlint](https://github.com/DavidAnson/markdownlint-cli2) rules used in CI.
This target is also appended to the `qa` make target.

### Markdown Link Checker

When a `./docs` directory exists, `make qa` will automatically invoke the target `docs-check-links`, which will in turn run a link checker over all the Markdown files in `./docs`

### Documentation Builder

The `docs-build` target will fetch the documentation theme repository, build a `mkdocs` image and build the static docs directory as per Laminas conventions so that you can eyeball the built docs locally before pushing.

### Mago Configuration

Provides a default configuration for [Mago](https://mago.carthage.software) which projects should extend for consistent coding standards via `mago fmt` and sane defaults for static analysis.

To make use of Mago, create a `mago.toml` in the root directory that extends the configuration shipped here:

```toml
#:schema https://mago.carthage.software/1.51.0/schema.json

extends = "vendor/laminas/internal-tooling/mago/defaults.toml"

# ... customised per-project rules and configuration follows
```

There are a number of `make` targets available for running Mago's suite of tools.
`make qa` will run the formatter in check mode, the linter and the analyser.

### PHP Code Sniffer Make Targets

- `make phpcs` Runs PHP_CodeSniffer coding standards checks
- `make phpcbf` Runs PHP_CodeSniffer's fixers

### Psalm Make Targets

- `make psalm` Run Psalm SA checks
- `make psalm-update-baseline` Update the Psalm baseline
- `make psalm-set-baseline` Expand the Psalm baseline with new issues
- `make psalm-clear-cache` Clears the Psalm cache

### PHPUnit Make Targets

- `make test`

## Migrations

Migrations represent small units of automation for common or one-off maintenance tasks for Laminas Repos.

### PHP 8.6 Migration

```bash
make migrate-to-php86
```

For more information about this migration [see the README](migrations/PHP-86/README.md).
