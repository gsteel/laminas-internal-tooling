<?php

declare(strict_types=1);

namespace Laminas\InternalTest\Migrations;

use Laminas\Internal\Migrations\PatchComposer;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

use function file_get_contents;

final class PatchComposerTest extends TestCase
{
    /**
     * @return iterable<array-key, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     *     3: non-empty-string,
     * }>
     */
    public static function dataProvider(): iterable
    {
        yield [
            <<<JSON
                {
                    "name": "laminas/whatever",
                    "config": {
                        "sort-packages": true,
                        "platform": {
                            "foo": "bar",
                            "php": "8.2.99",
                            "baz": "bat"
                        }
                    },
                    "require": {
                        "before/before": "^1.51.2",
                        "php": "~8.2 || ~8.3 || ~8.4 || ~8.5",
                        "after/after": "^1.51.2"
                    }
                }
                JSON,
            <<<JSON
                {
                    "name": "laminas/whatever",
                    "config": {
                        "sort-packages": true,
                        "platform": {
                            "foo": "bar",
                            "php": "8.3.99",
                            "baz": "bat"
                        }
                    },
                    "require": {
                        "before/before": "^1.51.2",
                        "php": "~8.3 || ~8.4 || ~8.5 || ~8.6",
                        "after/after": "^1.51.2"
                    }
                }
                JSON,
            '8.3.99',
            '~8.3 || ~8.4 || ~8.5 || ~8.6',
        ];
        yield [
            <<<JSON
                {
                    "name": "laminas/whatever",
                    "config": {
                        "sort-packages": true,
                        "platform": {
                            "php": "8.0.99"
                        }
                    },
                    "require": {
                        "php": "~8.0 || ~8.1 || ~8.2 || ~8.3 || ~8.4",
                        "after/after": "^1.51.2"
                    }
                }
                JSON,
            <<<JSON
                {
                    "name": "laminas/whatever",
                    "config": {
                        "sort-packages": true,
                        "platform": {
                            "php": "8.9.99"
                        }
                    },
                    "require": {
                        "php": ">= 8.9",
                        "after/after": "^1.51.2"
                    }
                }
                JSON,
            '8.9.99',
            '>= 8.9',
        ];
        yield [
            <<<JSON
                {
                    "name": "laminas/whatever",
                    "config": {
                        "sort-packages": true,
                        "platform": {
                            "php": "8.0.99"
                        }
                    },
                    "require": {
                        "php": ">= 7.4",
                        "after/after": "^1.51.2"
                    }
                }
                JSON,
            <<<JSON
                {
                    "name": "laminas/whatever",
                    "config": {
                        "sort-packages": true,
                        "platform": {
                            "php": "8.9.99"
                        }
                    },
                    "require": {
                        "php": "< 5.6",
                        "after/after": "^1.51.2"
                    }
                }
                JSON,
            '8.9.99',
            '< 5.6',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $platform
     * @param non-empty-string $phpConstraints
     */
    #[DataProvider('dataProvider')]
    public function testExpectedBehaviour(
        string $source,
        string $expect,
        string $platform,
        string $phpConstraints,
    ): void {
        $path = TestHelper::writeToTempFile($source);

        (new PatchComposer($path))->__invoke($platform, $phpConstraints);

        self::assertEquals(file_get_contents($path), $expect);
    }
}
