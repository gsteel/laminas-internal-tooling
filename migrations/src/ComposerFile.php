<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use Composer\Semver\VersionParser;

use function array_slice;
use function assert;
use function count;
use function explode;
use function file_get_contents;
use function implode;
use function json_decode;

final readonly class ComposerFile
{
    /**
     * @var array{
     *     require: array{
     *         php: non-empty-string,
     *     }
     * }
     */
    private array $data;

    /** @param non-empty-string $file */
    public function __construct(
        private string $file,
    ) {
        /** @mago-expect analysis:mixed-property-type-coercion(1) */
        $this->data = json_decode(
            $this->read(),
            true,
        );
    }

    /** @return non-empty-string */
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

    /** @return non-empty-string */
    public function phpVersionConstraint(): string
    {
        return $this->data['require']['php'];
    }

    /** @return non-empty-string */
    private function read(): string
    {
        $contents = file_get_contents($this->file);
        assert(
            $contents !== false && $contents !== '',
            'The file could not be read or it is empty',
        );

        return $contents;
    }
}
