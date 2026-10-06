<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use JsonException;

use function assert;
use function file_get_contents;
use function file_put_contents;
use function is_string;
use function json_decode;
use function json_encode;

use const JSON_PRETTY_PRINT;
use const JSON_THROW_ON_ERROR;

final class LaminasCI
{
    /**
     * @var array{
     *     ignore_php_platform_requirements?: array<string, bool>,
     *     backwardCompatibilityCheck?: bool,
     * }
     */
    private array $data;

    /**
     * @param non-empty-string $file
     * @throws JsonException
     */
    public function __construct(
        private readonly string $file,
    ) {
        /** @mago-expect analysis:mixed-property-type-coercion(1) */
        $contents = file_get_contents($this->file);
        assert(is_string($contents), 'File could not be read');

        $this->data = json_decode(
            json: $contents,
            associative: true,
            flags: JSON_THROW_ON_ERROR,
        );
    }

    /** @param non-empty-string $php */
    public function ignorePlatformReqsOnlyOn(string $php): void
    {
        $this->data['ignore_php_platform_requirements'] = [
            $php => true,
        ];
    }

    public function enableBcChecker(): void
    {
        $this->data['backwardCompatibilityCheck'] = true;
    }

    /** @throws JsonException */
    public function write(): void
    {
        file_put_contents(
            $this->file,
            json_encode(
                $this->data,
                JSON_THROW_ON_ERROR | JSON_PRETTY_PRINT,
            ),
        );
    }
}
