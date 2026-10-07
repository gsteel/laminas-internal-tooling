<?php

declare(strict_types=1);

$paths = [
    __DIR__ . '/../../../autoload.php',
    __DIR__ . '/../vendor/autoload.php',
];

$autoloader = null;
foreach ($paths as $file) {
    if (! file_exists($file)) {
        continue;
    }

    /** @var mixed $autoloader */
    $autoloader = require $file;
}

if ($autoloader === null) {
    throw new RuntimeException('Cannot determine autoloader');
}
