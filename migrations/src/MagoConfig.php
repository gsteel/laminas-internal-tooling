<?php

declare(strict_types=1);

namespace Laminas\Internal\Migrations;

use PhpCollective\Toml\Ast\Document;
use PhpCollective\Toml\Ast\KeyValue;
use PhpCollective\Toml\Ast\Value\StringValue;
use PhpCollective\Toml\Encoder\DocumentFormattingMode;
use PhpCollective\Toml\Encoder\EncoderOptions;
use PhpCollective\Toml\Toml;
use Throwable;

use function assert;
use function file_get_contents;
use function is_string;

final class MagoConfig
{
    private bool $isDirty = false;
    private Document $data;

    /** @throws Throwable */
    public function __construct(
        private readonly string $file,
    ) {
        $contents = file_get_contents($this->file);
        assert(is_string($contents), 'Failed to read Mago config file');

        $this->data = Toml::parse($contents, true);
    }

    /** @param non-empty-string $version */
    public function setPhpVersionWhenPresentTo(string $version): void
    {
        foreach ($this->data->items as $item) {
            if (! $item instanceof KeyValue) {
                continue;
            }

            if ($item->key->toString() !== 'php-version') {
                continue;
            }

            $value = $item->value;
            if (! $value instanceof StringValue) {
                return;
            }

            $value->value  = $version;
            $this->isDirty = true;

            return;
        }
    }

    /** @throws Throwable */
    public function write(): void
    {
        if (! $this->isDirty) {
            return;
        }

        Toml::encodeDocumentFile(
            $this->file,
            $this->data,
            new EncoderOptions(
                documentFormatting: DocumentFormattingMode::SourceAware,
            ),
        );
    }
}
