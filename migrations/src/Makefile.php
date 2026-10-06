<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use function assert;
use function file_get_contents;
use function file_put_contents;
use function preg_replace;

final readonly class Makefile
{
    public function __construct(
        private string $file,
    ) {}

    public function updatePHPVersionTo(string $version): void
    {
        $source  = $this->read();
        $pattern = '/(PHP_VERSION\s*[:?=]+)\s*[0-9.]+/';
        if ((bool) preg_match($pattern, $source) === false) {
            return;
        }

        $result = preg_replace(
            $pattern,
            '$1 ' . $version,
            $source,
        );
        assert($result !== '' && $result !== null, 'Unexpected Result');

        $this->write($result);
    }

    /** @return non-empty-string */
    private function read(): string
    {
        $contents = file_get_contents($this->file);
        assert(
            $contents !== false && $contents !== '',
            'Failed to read the project Makefile',
        );

        return $contents;
    }

    /** @param non-empty-string $data */
    private function write(string $data): void
    {
        file_put_contents($this->file, $data);
    }
}
