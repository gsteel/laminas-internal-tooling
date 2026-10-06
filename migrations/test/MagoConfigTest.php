<?php

declare(strict_types=1);

namespace Laminas\InternalTest\Migrations;

use Laminas\Internal\Migrations\MagoConfig;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class MagoConfigTest extends TestCase
{
    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function configProvider(): iterable
    {
        yield 'Changes existing version, preserving comments etc' => [
            <<<TOML
                # Some Comments
                version = "1.0"
                php-version = "8.0.1"

                [analyzer]
                some-stuff = "fred"
                TOML,
            <<<TOML
                # Some Comments
                version = "1.0"
                php-version = "8.2.0"

                [analyzer]
                some-stuff = "fred"
                TOML,
            '8.2.0',
        ];

        yield 'Skips setting version when not present' => [
            <<<TOML
                # Some Comments
                [analyzer]
                some-stuff = "fred"
                TOML,
            <<<TOML
                # Some Comments
                [analyzer]
                some-stuff = "fred"
                TOML,
            '8.2.0',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $newVersion
     */
    #[DataProvider('configProvider')]
    public function testPHPVersionIsChanged(string $source, string $expect, string $newVersion): void
    {
        $path = TestHelper::writeToTempFile($source);

        $mago = new MagoConfig($path);
        $mago->setPhpVersionWhenPresentTo($newVersion);
        $mago->write();

        self::assertStringEqualsFile($path, $expect);
    }
}
