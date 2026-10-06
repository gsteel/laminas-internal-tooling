<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use InvalidArgumentException;
use RuntimeException;
use Symfony\Component\Yaml\Yaml;
use Throwable;

use function assert;
use function file_exists;
use function file_get_contents;
use function glob;
use function is_array;
use function is_dir;
use function is_file;
use function is_string;
use function rtrim;
use function sprintf;

use const DIRECTORY_SEPARATOR;

final readonly class ProjectInformation
{
    /**
     * @param non-empty-string $projectDirectory
     * @param non-empty-string $composerFile
     * @param non-empty-string|null $laminasCiConfig
     * @param non-empty-string|null $laminasCiWorkflow
     * @param non-empty-string|null $magoConfiguration
     */
    public function __construct(
        public string $projectDirectory,
        public string $composerFile,
        public string|null $laminasCiConfig,
        public string|null $laminasCiWorkflow,
        public string|null $magoConfiguration,
    ) {}

    /** @throws Throwable */
    public static function fromDirectory(string $directory): self
    {
        if (! is_dir($directory)) {
            throw new InvalidArgumentException('Project directory must be a directory that actually exists');
        }

        $directory = rtrim($directory, DIRECTORY_SEPARATOR);

        if ($directory === '') {
            throw new InvalidArgumentException('Project directory should be non-empty');
        }

        return new self(
            $directory,
            self::assertFileExists($directory . '/composer.json'),
            self::fileExistsOrNull($directory . '/.laminas-ci.json'),
            self::findLaminasCIWorkflowInDirectory($directory . '/.github/workflows'),
            self::fileExistsOrNull($directory . '/mago.toml'),
        );
    }

    /**
     * @param non-empty-string $file
     * @return non-empty-string
     * @throws RuntimeException
     */
    private static function assertFileExists(string $file): string
    {
        if (! file_exists($file) || ! is_file($file)) {
            throw new RuntimeException(sprintf(
                'The file "%s" does not exist',
                $file,
            ));
        }

        return $file;
    }

    /**
     * @param non-empty-string $file
     * @return non-empty-string|null
     * @throws RuntimeException
     */
    private static function fileExistsOrNull(string $file): string|null
    {
        if (file_exists($file)) {
            if (! is_file($file)) {
                throw new RuntimeException(sprintf(
                    'The path "%s" is not a file',
                    $file,
                ));
            }

            return $file;
        }

        return null;
    }

    /**
     * @param non-empty-string $directory
     * @return non-empty-string|null
     * @throws Throwable
     */
    private static function findLaminasCIWorkflowInDirectory(string $directory): string|null
    {
        $files = self::glob(
            sprintf('%s/*.yml', $directory),
            sprintf('%s/*.yaml', $directory),
        );

        foreach ($files as $file) {
            $fileContents = file_get_contents($file);
            assert(is_string($fileContents), 'Failed to read file contents');

            /** @var mixed $yaml */
            $yaml = Yaml::parse($fileContents);
            if (! is_array($yaml)) {
                continue;
            }

            /** @var mixed $name */
            $name = $yaml['name'] ?? null;

            // The workflow name is probably the most consistent marker without inspecting the actual jobs and actions used.
            if ($name === 'Continuous Integration') {
                return $file;
            }
        }

        return null;
    }

    /**
     * @param non-empty-string ...$patterns
     * @return list<non-empty-string>
     */
    private static function glob(string ...$patterns): array
    {
        $result = [];

        foreach ($patterns as $pattern) {
            $files = glob($pattern);
            assert(is_array($files), 'Glob failed');
            $result = [...$result, ...$files];
        }

        return $result;
    }
}
