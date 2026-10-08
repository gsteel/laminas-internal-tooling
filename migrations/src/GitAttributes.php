<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use function assert;
use function count;
use function explode;
use function file_get_contents;
use function file_put_contents;
use function implode;
use function ltrim;
use function sprintf;
use function str_starts_with;
use function trim;

use const DIRECTORY_SEPARATOR;
use const PHP_EOL;

final readonly class GitAttributes
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
        if ($this->isExportIgnored($path)) {
            return;
        }

        $content = sprintf(
            "%s\n%s export-ignore\n",
            trim($this->read()),
            $path,
        );

        $this->write($content);
    }

    public function unignore(string $path): void
    {
        $unmodifiedLines = $this->getLines();
        $lines           = $unmodifiedLines;

        foreach ($lines as $index => $line) {
            if (! $this->isExportIgnoreLine($line)) {
                continue;
            }

            $result = str_starts_with(
                ltrim(trim($line), DIRECTORY_SEPARATOR),
                ltrim(trim($path), DIRECTORY_SEPARATOR),
            );

            if (! $result) {
                continue;
            }

            unset($lines[$index]);
        }

        if (count($unmodifiedLines) === count($lines)) {
            return;
        }

        $data = implode(PHP_EOL, $lines);
        assert($data !== '', 'We should not have an empty file here');

        $this->write($data);
    }

    private function isExportIgnored(string $path): bool
    {
        foreach ($this->getLines() as $line) {
            if (! $this->isExportIgnoreLine($line)) {
                continue;
            }

            $result = str_starts_with(
                ltrim(trim($line), DIRECTORY_SEPARATOR),
                ltrim(trim($path), DIRECTORY_SEPARATOR),
            );

            if ($result) {
                return true;
            }
        }

        return false;
    }

    private function isExportIgnoreLine(string $line): bool
    {
        return (bool) preg_match('/\s+export-ignore\s*$/i', $line);
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
