<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use Horde\Yaml\Document\Node\MapNode;
use Horde\Yaml\Document\Node\ScalarNode;
use Horde\Yaml\Document\YamlFileDumper;
use Horde\Yaml\Document\YamlFileLoader;
use Horde\Yaml\Document\YamlStream;
use Throwable;

use function is_string;

final class LaminasCIWorkflow
{
    private YamlStream $stream;
    private bool $isDirty = false;

    /**
     * @param non-empty-string $file
     * @throws Throwable
     */
    public function __construct(
        private readonly string $file,
    ) {
        $this->stream = (new YamlFileLoader())->load($this->file);
    }

    /** @return non-empty-string|null */
    public function name(): string|null
    {
        $document = $this->stream->getDocument();
        /** @var mixed $node */
        $node = $document['name'] ?? null;

        if (! $node instanceof ScalarNode) {
            return null;
        }

        $name = $node->getValue();

        return is_string($name) && $name !== '' ? $name : null;
    }

    private function fetchEnvNodeByKey(string $key): ScalarNode|null
    {
        $document = $this->stream->getDocument();

        if (! $document->offsetExists('env')) {
            return null;
        }

        $env = $document->getEntry('env');
        if ($env === null) {
            return null;
        }

        $env = $env->getValue();
        /** @var mixed $node */
        $node = $env instanceof MapNode ? $env[$key] : null;
        if (! $node instanceof ScalarNode) {
            return null;
        }

        return $node;
    }

    public function setDefaultPHPEnvironmentVariableIfPresent(string $version): void
    {
        $node = $this->fetchEnvNodeByKey('default_php');
        if ($node === null || $node->getValue() === null) {
            return;
        }

        $node->setValue($version);
        $this->isDirty = true;
    }

    public function setPhpExtensionsFromSpaceSeparatedEnvironmentVariable(string $env): void
    {
        $node = $this->fetchEnvNodeByKey('php_extensions');
        if ($node === null) {
            return;
        }

        $value = implode(',', explode(' ', $env));

        $node->setValue($value);
        $this->isDirty = true;
    }

    public function write(): void
    {
        if (! $this->isDirty) {
            return;
        }

        $writer = new YamlFileDumper();
        $writer->dump($this->stream, $this->file);
        $this->isDirty = false;
    }
}
