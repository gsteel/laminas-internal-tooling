<?php

declare(strict_types=1);

namespace Laminas\InternalTest\Migrations;

use Laminas\Internal\Migrations\LaminasCI;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class LaminasCITest extends TestCase
{
    /**
     * @return iterable<array-key, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     * }>
     */
    public static function enableBcCheckDataProvider(): iterable
    {
        yield [
            '{}',
            <<<JSON
                {
                    "backwardCompatibilityCheck": true
                }
                JSON,
        ];

        yield [
            <<<JSON
                {
                    "some-things": "foo"
                }
                JSON,
            <<<JSON
                {
                    "some-things": "foo",
                    "backwardCompatibilityCheck": true
                }
                JSON,
        ];

        yield [
            <<<JSON
                {
                    "some-things": "foo",
                    "backwardCompatibilityCheck": false,
                    "other-things": "foo"
                }
                JSON,
            <<<JSON
                {
                    "some-things": "foo",
                    "backwardCompatibilityCheck": true,
                    "other-things": "foo"
                }
                JSON,
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     */
    #[DataProvider('enableBcCheckDataProvider')]
    public function testEnableBcChecker(string $source, string $expect): void
    {
        $file = TestHelper::writeToTempFile($source);

        $object = new LaminasCI($file);
        $object->enableBcChecker();
        $object->write();

        self::assertStringEqualsFile($file, $expect);
    }

    /**
     * @return iterable<array-key, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function ignorePlatformReqsProvider(): iterable
    {
        yield [
            <<<JSON
                {}
                JSON,
            <<<JSON
                {
                    "ignore_php_platform_requirements": {
                        "8.6": true
                    }
                }
                JSON,
            '8.6',
        ];
        yield [
            <<<JSON
                {
                    "ignore_php_platform_requirements": {
                        "8.4": false,
                        "8.5": true
                    }
                }
                JSON,
            <<<JSON
                {
                    "ignore_php_platform_requirements": {
                        "8.6": true
                    }
                }
                JSON,
            '8.6',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $target
     */
    #[DataProvider('ignorePlatformReqsProvider')]
    public function testIgnorePlatformReqsOnlyOn(string $source, string $expect, string $target): void
    {
        $file = TestHelper::writeToTempFile($source);

        $object = new LaminasCI($file);
        $object->ignorePlatformReqsOnlyOn($target);
        $object->write();

        self::assertStringEqualsFile($file, $expect);
    }
}
