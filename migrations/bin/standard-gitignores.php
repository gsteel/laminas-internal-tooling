<?php

declare(strict_types=1);

use Laminas\Internal\Migrations\GitIgnore;
use Laminas\Internal\Migrations\ProjectInformation;

require __DIR__ . '/../autoloader.php';

/** @var mixed $rootDirectory */
$rootDirectory = $argv[1] ?? null;
if (
    ! is_string($rootDirectory)
    || $rootDirectory === ''
    || ! is_dir($rootDirectory)
) {
    throw new RuntimeException('Pass a single argument representing the root directory of the target library');
}

$project  = ProjectInformation::fromDirectory($rootDirectory);
$ignore   = new GitIgnore($project->gitIgnore);
$toIgnore = [
    '/.phpunit.cache',
    '/docs/html/',
    '/doc/html/',
    '/laminas-mkdoc-theme.tgz',
    '/laminas-mkdoc-theme/',
    '/phpunit.xml',
    '/vendor/',
    '/documentation-theme/',
    '.markdownlint.json',
];

foreach ($toIgnore as $item) {
    $ignore->ignore($item);
}
