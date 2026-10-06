<?php

declare(strict_types=1);

namespace Laminas\InternalTest\Migrations;

use Laminas\Internal\Migrations\Makefile;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class MakefileTest extends TestCase
{
    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function phpVersionProvider(): iterable
    {
        yield 'Found amongst other content' => [
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                PHP_VERSION := 8.2
                OTHER = "BAZ"
                Makefile,
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                PHP_VERSION := 8.3
                OTHER = "BAZ"
                Makefile,
            '8.3',
        ];

        yield 'Found, no whitespace' => [
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                PHP_VERSION:=8.2
                OTHER = "BAZ"
                Makefile,
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                PHP_VERSION:= 8.3
                OTHER = "BAZ"
                Makefile,
            '8.3',
        ];

        yield 'Found, conditional assignment' => [
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                PHP_VERSION ?= 8.2
                OTHER = "BAZ"
                Makefile,
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                PHP_VERSION ?= 8.3
                OTHER = "BAZ"
                Makefile,
            '8.3',
        ];

        yield 'Found, regular assignment' => [
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                PHP_VERSION=8.2
                OTHER = "BAZ"
                Makefile,
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                PHP_VERSION= 8.3
                OTHER = "BAZ"
                Makefile,
            '8.3',
        ];

        yield 'Not there' => [
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                OTHER = "BAZ"
                Makefile,
            <<<Makefile
                # Some Comment
                FOO ?= BAR
                OTHER = "BAZ"
                Makefile,
            '8.3',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $newVersion
     */
    #[DataProvider('phpVersionProvider')]
    public function testPHPVersionReplacement(string $source, string $expect, string $newVersion): void
    {
        $path     = TestHelper::writeToTempFile($source);
        $makefile = new Makefile($path);
        $makefile->updatePHPVersionTo($newVersion);
        self::assertStringEqualsFile($path, $expect);
    }
}
