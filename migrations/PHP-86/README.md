# Adding PHP 8.6 Support to Laminas & Mezzio Libraries

This migration is a collection of code and utilities to add PHP 8.6 support and remove PHP 8.2 support from Mezzio and Laminas libs.

It is "best effort" in that it automates away a number of repetitive tasks, but can't fix everything that might occur.

1. Updates supported PHP versions in `composer.json#require`
2. Updates `composer.json#config.platform.php`
3. Checks for `.laminas-ci.json` and ignores platform requirements on PHP 8.6
4. Checks GitHub workflows for an `env` key of `default_php` and updates that - this key is typically used for additional jobs that the matrix doesn't cover
5. Updates the PHP version in `mago.toml` if it exists
