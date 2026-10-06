<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use Symfony\Component\Yaml\Yaml;
use Throwable;

use function array_key_exists;
use function assert;
use function file_get_contents;
use function file_put_contents;
use function is_array;
use function is_string;

final class LaminasCIWorkflow
{
    /** @var array<array-key, mixed> */
    private array $data;
    private bool $isDirty = false;

    /**
     * @param non-empty-string $file
     * @throws Throwable
     */
    public function __construct(
        private readonly string $file,
    ) {
        $contents = file_get_contents($this->file);
        assert(is_string($contents) && $contents !== '', 'Empty or unreadable workflow file');

        /** @var mixed $data */
        $data = Yaml::parse($contents);
        assert(is_array($data), 'Expected YAML to parse to an array');

        $this->data = $data;
    }

    public function setDefaultPHPEnvironmentVariableIfPresent(string $version): void
    {
        if (! array_key_exists('env', $this->data)) {
            return;
        }

        if (! is_array($this->data['env'])) {
            return;
        }

        if (! array_key_exists('default_php', $this->data['env']) || $this->data['env']['default_php'] === null) {
            return;
        }

        $this->data['env']['default_php'] = $version;
        $this->isDirty                    = true;
    }

    public function write(): void
    {
        if (! $this->isDirty) {
            return;
        }

        file_put_contents(
            $this->file,
            Yaml::dump(
                $this->data,
                10,
                2,
                Yaml::DUMP_NULL_AS_EMPTY,
            ),
        );

        $this->isDirty = false;
    }
}
