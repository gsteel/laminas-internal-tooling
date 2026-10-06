<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use function assert;
use function file_get_contents;
use function file_put_contents;
use function preg_replace;

final readonly class PatchComposer
{
    /** @param non-empty-string $file */
    public function __construct(
        private string $file,
    ) {}

    /**
     * @param non-empty-string $platform
     * @param non-empty-string $phpConstraint
     */
    public function __invoke(string $platform, string $phpConstraint): void
    {
        $source = $this->read();
        $source = $this->platformUpdate($source, $platform);
        $source = $this->phpConstraints($source, $phpConstraint);

        $this->write($source);
    }

    /**
     * @param non-empty-string $data
     * @param non-empty-string $platform
     * @return non-empty-string
     */
    private function platformUpdate(string $data, string $platform): string
    {
        $result = preg_replace(
            '/("platform"\s*:\s*{.+)("php"\s*:\s*"8.[0-9]+.99")/mis',
            '$1"php": "' . $platform . '"',
            $data,
        );
        assert($result !== '' && $result !== null, 'Unexpected Result');

        return $result;
    }

    /**
     * @param non-empty-string $data
     * @param non-empty-string $target
     * @return non-empty-string
     */
    private function phpConstraints(string $data, string $target): string
    {
        $result = preg_replace(
            '/("require"\s*:\s*{.+)("php"\s*:\s*"[~0-9.><=|^\s]+")/mis',
            '$1"php": "' . $target . '"',
            $data,
        );
        assert($result !== '' && $result !== null, 'Unexpected result');

        return $result;
    }

    /** @return non-empty-string */
    private function read(): string
    {
        $contents = file_get_contents($this->file);
        assert(
            $contents !== false && $contents !== '',
            'composer.json could not be read or it is empty',
        );

        return $contents;
    }

    /** @param non-empty-string $data */
    private function write(string $data): void
    {
        file_put_contents($this->file, $data);
    }
}
