<?php

declare(strict_types=1);

namespace Laminas\InternalTest\Migrations;

use Laminas\Internal\Migrations\GitAttributes;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class GitAttributesTest extends TestCase
{
    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function dataProvider(): iterable
    {
        yield 'Leading slashes normalised, ignore already there' => [
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            'thing1',
        ];

        yield 'Ignore already there' => [
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            '/thing1',
        ];

        yield 'Ignore already there, slash mismatch' => [
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            '/thing2',
        ];

        yield 'Adding an item to be ignored' => [
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore
                thing4 export-ignore

                TXT,
            'thing4',
        ];

        yield 'Adding an item to be ignored, preserves leading slash' => [
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore
                /thing4 export-ignore

                TXT,
            '/thing4',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $ignore
     */
    #[DataProvider('dataProvider')]
    public function testResultOfIgnoringThings(string $source, string $expect, string $ignore): void
    {
        $file       = TestHelper::writeToTempFile($source);
        $attributes = new GitAttributes($file);
        $attributes->ignore($ignore);
        self::assertStringEqualsFile($file, $expect);
    }

    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function unignoreProvider(): iterable
    {
        yield 'Leading slashes normalised, removed successfully' => [
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            <<<TXT
                # A Comment
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            'thing1',
        ];

        yield 'Matching slashes, removed successfully' => [
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            <<<TXT
                # A Comment
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            '/thing1',
        ];

        yield 'Slash mismatch, removed successfully' => [
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            <<<TXT
                # A Comment
                /thing1 export-ignore

                /thing/thing3 export-ignore

                TXT,
            '/thing2',
        ];

        yield 'Not currently ignored' => [
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            <<<TXT
                # A Comment
                /thing1 export-ignore
                thing2 export-ignore

                /thing/thing3 export-ignore

                TXT,
            'thing4',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $ignore
     */
    #[DataProvider('unignoreProvider')]
    public function testResultOfUnIgnoringThings(string $source, string $expect, string $ignore): void
    {
        $file       = TestHelper::writeToTempFile($source);
        $attributes = new GitAttributes($file);
        $attributes->unignore($ignore);
        self::assertStringEqualsFile($file, $expect);
    }
}
