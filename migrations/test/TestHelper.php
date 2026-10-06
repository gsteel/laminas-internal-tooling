<?php

declare(strict_types=1);

namespace Laminas\InternalTest\Migrations;

use PHPUnit\Framework\TestCase;

use function assert;
use function file_put_contents;
use function sys_get_temp_dir;
use function tempnam;

final readonly class TestHelper
{
    /**
     * Write the given contents to a new temp file and return the file path
     *
     * @param non-empty-string $contents
     * @return non-empty-string
     */
    public static function writeToTempFile(string $contents): string
    {
        $file = tempnam(sys_get_temp_dir(), 'test_');
        TestCase::assertIsString($file);
        assert($file !== '', 'Path should not be empty');
        file_put_contents($file, $contents);
        TestCase::assertStringEqualsFile($file, $contents);

        return $file;
    }
}
