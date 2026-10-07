<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use Composer\Semver\VersionParser;
use JsonException;
use RuntimeException;
use Throwable;

use function array_slice;
use function assert;
use function count;
use function explode;
use function file_get_contents;
use function file_put_contents;
use function implode;
use function json_decode;
use function json_encode;

use const JSON_PRETTY_PRINT;
use const JSON_THROW_ON_ERROR;

final class ComposerFile
{
    /**
     * @var array{
     *     config?: array{
     *         platform?: array{
     *             php?: non-empty-string,
     *         },
     *     },
     *     require: array{
     *         php?: non-empty-string,
     *     },
     * }
     */
    private array $data;
    private bool $dirty = false;

    /**
     * @param non-empty-string $file
     * @throws JsonException
     */
    public function __construct(
        private readonly string $file,
    ) {
        /** @mago-expect analysis:mixed-property-type-coercion(1) */
        $this->data = json_decode(
            $this->read(),
            true,
        );
    }

    /**
     * @return non-empty-string
     * @throws Throwable
     */
    public function minimumPHPVersionAsMinor(): string
    {
        $parser      = new VersionParser();
        $constraints = $parser->parseConstraints($this->phpVersionConstraint());
        $minimum     = $constraints->getLowerBound()->getVersion();
        $parts       = explode('.', $minimum);
        assert(count($parts) >= 2, 'Expected at least 2 elements');
        $minor = implode('.', array_slice($parts, 0, 2));
        assert($minor !== '', 'Expected a non-empty-string');

        return $minor;
    }

    /**
     * @return non-empty-string
     * @throws RuntimeException
     */
    public function phpVersionConstraint(): string
    {
        $version = $this->data['require']['php'] ?? null;
        if ($version === null) {
            throw new RuntimeException('This composer file does not declare a PHP version constraint');
        }

        return $version;
    }

    /** @param non-empty-string $constraint */
    public function setPhpVersionConstraint(string $constraint): void
    {
        if (($this->data['require']['php'] ?? null) === $constraint) {
            return;
        }

        $this->data['require']['php'] = $constraint;
        $this->dirty                  = true;
    }

    /** @param non-empty-string $version */
    public function setPlatform(string $version): void
    {
        $this->data['config']             ??= [];
        $this->data['config']['platform'] ??= [];
        if (($this->data['config']['platform']['php'] ?? null) === $version) {
            return;
        }

        $this->data['config']['platform']['php'] = $version;
        $this->dirty                             = true;
    }

    /**
     * @return non-empty-string
     * @throws JsonException
     */
    private function read(): string
    {
        $contents = file_get_contents($this->file);
        assert(
            $contents !== false && $contents !== '',
            'The file could not be read or it is empty',
        );

        return $contents;
    }

    /** @throws JsonException */
    public function write(): void
    {
        if (! $this->dirty) {
            return;
        }

        file_put_contents(
            $this->file,
            json_encode(
                $this->data,
                JSON_THROW_ON_ERROR | JSON_PRETTY_PRINT,
            ),
        );
    }
}
