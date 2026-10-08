<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use function assert;
use function explode;
use function file_get_contents;
use function file_put_contents;
use function implode;
use function sprintf;
use function trim;

use const DIRECTORY_SEPARATOR;
use const PHP_EOL;

final readonly class GitIgnore
{
    public function __construct(
        private string $file,
    ) {}

    /** @return list<string> */
    private function getLines(): array
    {
        return explode(PHP_EOL, $this->read());
    }

    public function ignore(string $path): void
    {
        if ($this->isIgnored($path)) {
            return;
        }

        $content = sprintf(
            "%s\n%s\n",
            trim($this->read()),
            $path,
        );

        $this->write($content);
    }

    public function unignore(string $path): void
    {
        if (! $this->isIgnored($path)) {
            return;
        }

        $lines = $this->getLines();

        foreach ($lines as $index => $line) {
            if (! $this->matches($line, $path)) {
                continue;
            }

            unset($lines[$index]);
        }

        $content = implode(PHP_EOL, $lines);
        assert($content !== '', 'Expected non-empty content');

        $this->write($content);
    }

    private function isIgnored(string $path): bool
    {
        foreach ($this->getLines() as $line) {
            if ($this->matches($line, $path)) {
                return true;
            }
        }

        return false;
    }

    private function matches(string $line, string $ignore): bool
    {
        return trim(trim($line), DIRECTORY_SEPARATOR) === trim(trim($ignore), DIRECTORY_SEPARATOR);
    }

    /** @return non-empty-string */
    private function read(): string
    {
        $contents = file_get_contents($this->file);
        assert(
            $contents !== false && $contents !== '',
            'The file could not be read or it is empty',
        );

        return $contents;
    }

    /** @param non-empty-string $data */
    private function write(string $data): void
    {
        file_put_contents($this->file, $data);
    }
}
