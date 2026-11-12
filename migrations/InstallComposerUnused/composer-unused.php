<?php

/**
 * Example configuration for composer-unused
 */

declare(strict_types=1);

use ComposerUnused\ComposerUnused\Configuration\Configuration;
use ComposerUnused\ComposerUnused\Configuration\NamedFilter;
use Webmozart\Glob\Glob;

return static function (Configuration $config): Configuration {
    // Example: Declare an extension as used when it is discovered as unused:
    // $config->addNamedFilter(NamedFilter::fromString('ext-pcntl'));

    // Example: Declare a composer dependency as used when it is discovered as unused:
    // $config->addNamedFilter(NamedFilter::fromString('some/dependency'));

    // Ignore unused `mago` dependency. No symbols are used from this dep because composer is just the delivery mechanism
    $config->addNamedFilter(NamedFilter::fromString('carthage-software/mago'));

    // Example: Scan additional directories not listed in the composer autoloader
    // $config->setAdditionalFilesFor('some/dependency', [
    //     ...Glob::glob(__DIR__ . '/bin/*.php'),
    //     ...Glob::glob(__DIR__ . '/config/**/*.php'),
    //     __DIR__ . '/some-specific-file.php',
    // ]);

    return $config;
};
