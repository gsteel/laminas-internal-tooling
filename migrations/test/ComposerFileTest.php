<?php

declare(strict_types=1);

namespace Laminas\InternalTest\Migrations;

use Laminas\Internal\Migrations\ComposerFile;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use RuntimeException;

final class ComposerFileTest extends TestCase
{
    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function changePHPConstraintProvider(): iterable
    {
        yield 'No changes given identical version' => [
            <<<JSON
                {
                    "require": {
                        "php": ">= 6.0"
                    }
                }
                JSON,
            <<<JSON
                {
                    "require": {
                        "php": ">= 6.0"
                    }
                }
                JSON,
            '>= 6.0',
        ];

        yield 'Constraint can be changed' => [
            <<<JSON
                {
                    "require": {
                        "php": ">= 6.0"
                    }
                }
                JSON,
            <<<JSON
                {
                    "require": {
                        "php": "~8.5"
                    }
                }
                JSON,
            '~8.5',
        ];

        yield 'Constraint is set when not present' => [
            <<<JSON
                {
                    "require": {
                        "fred/lib": ">= 6.0"
                    }
                }
                JSON,
            <<<JSON
                {
                    "require": {
                        "fred/lib": ">= 6.0",
                        "php": "~8.5"
                    }
                }
                JSON,
            '~8.5',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $version
     */
    #[DataProvider('changePHPConstraintProvider')]
    public function testAlterationOfPHPConstraint(string $source, string $expect, string $version): void
    {
        $file     = TestHelper::writeToTempFile($source);
        $composer = new ComposerFile($file);
        $composer->setPhpVersionConstraint($version);
        $composer->write();
        self::assertJsonStringEqualsJsonFile($file, $expect);
        self::assertSame($version, $composer->phpVersionConstraint());
    }

    public function testExceptionThrownRetrievingPhpVersionWhenNotKnown(): void
    {
        $file     = TestHelper::writeToTempFile('{}');
        $composer = new ComposerFile($file);
        $this->expectException(RuntimeException::class);
        $composer->phpVersionConstraint();
    }

    /**
     * @return iterable<int, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     * }>
     */
    public static function minimumVersionProvider(): iterable
    {
        yield [
            '{"require":{"php":"^8.3.45"}}',
            '8.3',
        ];

        yield [
            '{"require":{"php":"~5.6 || ~7.1"}}',
            '5.6',
        ];

        yield [
            '{"require":{"php":"~7.1 || ~5.6"}}',
            '5.6',
        ];

        yield [
            '{"require":{"php":"8.6.0-dev"}}',
            '8.6',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     */
    #[DataProvider('minimumVersionProvider')]
    public function testMinimumPhpVersion(string $source, string $expect): void
    {
        $file     = TestHelper::writeToTempFile($source);
        $composer = new ComposerFile($file);

        self::assertSame($expect, $composer->minimumPHPVersionAsMinor());
    }

    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function platformProvider(): iterable
    {
        yield 'Is set when not present' => [
            '{}',
            '{"config":{"platform":{"php":"1.2.33"}}}',
            '1.2.33',
        ];

        yield 'Is mutated' => [
            '{"config":{"platform":{"php":"1.2.33"}}}',
            '{"config":{"platform":{"php":"4.0"}}}',
            '4.0',
        ];

        yield 'Identical' => [
            '{"config":{"platform":{"php":"4.0"}}}',
            '{"config":{"platform":{"php":"4.0"}}}',
            '4.0',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $newVersion
     */
    #[DataProvider('platformProvider')]
    public function testChangingPlatforms(string $source, string $expect, string $newVersion): void
    {
        $file     = TestHelper::writeToTempFile($source);
        $composer = new ComposerFile($file);
        $composer->setPlatform($newVersion);
        $composer->write();
        self::assertJsonStringEqualsJsonFile($file, $expect);
    }
}
