<?php

declare(strict_types=1);

namespace Laminas\InternalTest\Migrations;

use Laminas\Internal\Migrations\LaminasCIWorkflow;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class LaminasCIWorkflowTest extends TestCase
{
    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function defaultPHPEnvVarProvider(): iterable
    {
        yield 'When non-empty, file is updated with new default' => [
            <<<YAML
                yaml: sucks
                env:
                  default_php: Fred
                more_yaml: sucks more
                YAML,
            <<<YAML
                yaml: sucks
                env:
                  default_php: '6.0'
                more_yaml: 'sucks more'

                YAML,
            '6.0',
        ];

        yield 'When null, the file is unchanged' => [
            <<<YAML
                yaml: sucks
                env:
                  default_php:
                more_yaml: sucks more
                YAML,
            <<<YAML
                yaml: sucks
                env:
                  default_php:
                more_yaml: sucks more
                YAML,
            '6.0',
        ];

        yield 'When absent, file is unchanged' => [
            <<<YAML
                env:
                  super: secret
                  other: secret
                YAML,
            <<<YAML
                env:
                  super: secret
                  other: secret
                YAML,
            '6.0',
        ];

        yield 'Other env vars are not mutated' => [
            <<<YAML
                env:
                  super: secret
                  default_php: 5.3
                  other: secret
                YAML,
            <<<YAML
                env:
                  super: secret
                  default_php: '6.0'
                  other: secret

                YAML,
            '6.0',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $newVersion
     */
    #[DataProvider('defaultPHPEnvVarProvider')]
    public function testDefaultPHPEnvironmentVariable(string $source, string $expect, string $newVersion): void
    {
        $path = TestHelper::writeToTempFile($source);

        $workflow = new LaminasCIWorkflow($path);
        $workflow->setDefaultPHPEnvironmentVariableIfPresent($newVersion);
        $workflow->write();

        self::assertStringEqualsFile($path, $expect);
    }

    /**
     * @return iterable<string, array{
     *     0: non-empty-string,
     *     1: non-empty-string,
     *     2: non-empty-string,
     * }>
     */
    public static function extensionEnvVarProvider(): iterable
    {
        yield 'When non-empty, file is updated with new default' => [
            <<<YAML
                yaml: sucks
                env:
                  php_extensions: whatever
                more_yaml: sucks more
                YAML,
            <<<YAML
                yaml: sucks
                env:
                  php_extensions: 'pdo,intl,xdebug'
                more_yaml: 'sucks more'

                YAML,
            'pdo intl xdebug',
        ];

        yield 'When null, the extensions are still added' => [
            <<<YAML
                yaml: sucks
                env:
                  php_extensions:
                more_yaml: sucks more
                YAML,
            <<<YAML
                yaml: sucks
                env:
                  php_extensions: mbstring
                more_yaml: 'sucks more'

                YAML,
            'mbstring',
        ];

        yield 'When absent, file is unchanged' => [
            <<<YAML
                env:
                  super: secret
                  other: secret
                YAML,
            <<<YAML
                env:
                  super: secret
                  other: secret
                YAML,
            '6.0',
        ];

        yield 'Other env vars are not mutated' => [
            <<<YAML
                env:
                  super: secret
                  default_php: 5.3
                  php_extensions: fred
                  other: secret
                YAML,
            <<<YAML
                env:
                  super: secret
                  default_php: 5.3
                  php_extensions: mbstring
                  other: secret

                YAML,
            'mbstring',
        ];
    }

    /**
     * @param non-empty-string $source
     * @param non-empty-string $expect
     * @param non-empty-string $extensions
     */
    #[DataProvider('extensionEnvVarProvider')]
    public function testExtensionsCanBeUpdated(string $source, string $expect, string $extensions): void
    {
        $path = TestHelper::writeToTempFile($source);

        $workflow = new LaminasCIWorkflow($path);
        $workflow->setPhpExtensionsFromSpaceSeparatedEnvironmentVariable($extensions);
        $workflow->write();

        self::assertStringEqualsFile($path, $expect);
    }
}
