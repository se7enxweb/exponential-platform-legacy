<?php

declare(strict_types=1);

namespace App\ExponentialPlatformLegacyInjectedSettings\DependencyInjection;

use Symfony\Component\Config\FileLocator;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Extension\Extension;
use Symfony\Component\DependencyInjection\Loader\YamlFileLoader;

final class ExponentialPlatformLegacyInjectedSettingsExtension extends Extension
{
    public function load(array $configs, ContainerBuilder $container): void
    {
        // Ensure parameters exist with empty defaults so the bundle boots
        // even when legacy.yaml defines no overrides.
        if (!$container->hasParameter('app.legacy.injected_settings')) {
            $container->setParameter('app.legacy.injected_settings', []);
        }
        if (!$container->hasParameter('app.legacy.injected_merge_settings')) {
            $container->setParameter('app.legacy.injected_merge_settings', []);
        }
        if (!$container->hasParameter('app.legacy.siteaccess_injected_settings')) {
            $container->setParameter('app.legacy.siteaccess_injected_settings', []);
        }
        if (!$container->hasParameter('app.legacy.siteaccess_injected_merge_settings')) {
            $container->setParameter('app.legacy.siteaccess_injected_merge_settings', []);
        }

        $loader = new YamlFileLoader(
            $container,
            new FileLocator(__DIR__ . '/../Resources/config')
        );
        $loader->load('services.yaml');
    }
}
