<?php

declare(strict_types=1);

namespace Laminas\InternalTest\Migrations;

use Laminas\Internal\Migrations\GitIgnore;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class GitIgnoreTest extends TestCase
{
    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function addIgnoreProvider(): iterable
    {
        yield 'Happy Path, adding' => [
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            <<<TXT
                /vendor/
                some-file.txt
                myfile.txt

                TXT,
            'myfile.txt',
        ];

        yield 'Already there' => [
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            'some-file.txt',
        ];

        yield 'Already there, with leading slash' => [
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            '/some-file.txt',
        ];

        yield 'Already there, leading slash in source' => [
            <<<TXT
                /vendor/
                /some-file.txt

                TXT,
            <<<TXT
                /vendor/
                /some-file.txt

                TXT,
            'some-file.txt',
        ];

        yield 'Already there, directory slashes' => [
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            'vendor',
        ];

        yield 'Already there, directory arg with slashes' => [
            <<<TXT
                vendor
                /some-file.txt

                TXT,
            <<<TXT
                vendor
                /some-file.txt

                TXT,
            '/vendor/',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $toIgnore
     */
    #[DataProvider('addIgnoreProvider')]
    public function testAddingIgnores(string $source, string $expect, string $toIgnore): void
    {
        $file   = TestHelper::writeToTempFile($source);
        $ignore = new GitIgnore($file);
        $ignore->ignore($toIgnore);

        self::assertStringEqualsFile($file, $expect);
    }

    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function removeIgnoreProvider(): iterable
    {
        yield 'Happy Path, removing' => [
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            <<<TXT
                /vendor/

                TXT,
            'some-file.txt',
        ];

        yield 'Remove file, slash in source' => [
            <<<TXT
                /vendor/
                /some-file.txt

                TXT,
            <<<TXT
                /vendor/

                TXT,
            'some-file.txt',
        ];

        yield 'Remove file, slash in argument' => [
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            <<<TXT
                /vendor/

                TXT,
            '/some-file.txt',
        ];

        yield 'Not ignored' => [
            <<<TXT
                /vendor/
                /some-file.txt

                TXT,
            <<<TXT
                /vendor/
                /some-file.txt

                TXT,
            'bingbong.txt',
        ];

        yield 'Remove directory, slashes in source' => [
            <<<TXT
                /vendor/
                some-file.txt

                TXT,
            <<<TXT
                some-file.txt

                TXT,
            'vendor',
        ];

        yield 'Remove directory, arg with slashes' => [
            <<<TXT
                vendor
                /some-file.txt

                TXT,
            <<<TXT
                /some-file.txt

                TXT,
            '/vendor/',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $toIgnore
     */
    #[DataProvider('removeIgnoreProvider')]
    public function testRemovingIgnores(string $source, string $expect, string $toIgnore): void
    {
        $file   = TestHelper::writeToTempFile($source);
        $ignore = new GitIgnore($file);
        $ignore->unignore($toIgnore);

        self::assertStringEqualsFile($file, $expect);
    }
}
