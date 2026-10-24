<?php

namespace App;

use Symfony\Bundle\FrameworkBundle\Kernel\MicroKernelTrait;
use Symfony\Component\HttpKernel\Kernel as BaseKernel;

class Kernel extends BaseKernel
{
    use MicroKernelTrait;

    /**
     * Bundles that are registered only when their package is installed.
     *
     * Netgen Layouts 2 and its Content Browser need PHP 8.4, while the project runs on PHP 8.3 and later.
     * They are therefore not in the project's composer.json; on PHP 8.4 or later they are added with
     * `composer require netgen/layouts-ibexa:^2.0 netgen/layouts-standard:^2.0` (see INSTALL.md), and their
     * lines in config/bundles.php then take effect. Every other bundle in config/bundles.php is required:
     * a missing one still stops the kernel, as before.
     */
    private const OPTIONAL_BUNDLE_PREFIXES = [
        'Netgen\\Bundle\\LayoutsBundle\\',
        'Netgen\\Bundle\\LayoutsAdminBundle\\',
        'Netgen\\Bundle\\LayoutsDebugBundle\\',
        'Netgen\\Bundle\\LayoutsIbexaBundle\\',
        'Netgen\\Bundle\\LayoutsStandardBundle\\',
        'Netgen\\Bundle\\LayoutsUIBundle\\',
        'Netgen\\Bundle\\ContentBrowserBundle\\',
        'Netgen\\Bundle\\ContentBrowserIbexaBundle\\',
        'Netgen\\Bundle\\ContentBrowserUIBundle\\',
    ];

    public function registerBundles(): iterable
    {
        $contents = require $this->getBundlesPath();
        foreach ($contents as $class => $envs) {
            if (!($envs[$this->environment] ?? $envs['all'] ?? false)) {
                continue;
            }
            if (self::isOptionalBundle($class) && !class_exists($class)) {
                continue;
            }

            yield new $class();
        }
    }

    public static function isOptionalBundle(string $class): bool
    {
        foreach (self::OPTIONAL_BUNDLE_PREFIXES as $prefix) {
            if (str_starts_with($class, $prefix)) {
                return true;
            }
        }

        return false;
    }
}
