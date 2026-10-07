# Install Stand-Alone Rector

This migration installs rector to `./tools/rector` in the project and ensures that the tools directory is `export-ignore`d.

Once installed, you can freely update `/tools/rector/rector.php` to suit project needs.

A GitHub workflow file is installed in `.github/workflows/rector.yml` and it should use the project default for PHP and the relevant extensions providing these have been configured in the main `Makefile`.
