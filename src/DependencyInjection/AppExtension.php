<?php

declare(strict_types=1);

namespace App\DependencyInjection;

use Symfony\Component\Config\Resource\FileResource;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Extension\PrependExtensionInterface;
use Symfony\Component\Finder\Finder;
use Symfony\Component\HttpKernel\DependencyInjection\Extension;
use Symfony\Component\Yaml\Yaml;

use function file_get_contents;

final class AppExtension extends Extension implements PrependExtensionInterface
{
    private const PREPEND_EXTENSION_ALIASES = [
        'ibexa' => 'ezpublish',
        'platform' => 'ezpublish',
    ];

    public function load(array $configs, ContainerBuilder $container): void
    {
        $configuration = new Configuration();
        $config = $this->processConfiguration($configuration, $configs);
    }

    public function prepend(ContainerBuilder $container): void
    {
        foreach ((new Finder())->in(__DIR__ . '/../../config/app/prepends')->directories() as $directory) {
            $extensionName = self::PREPEND_EXTENSION_ALIASES[$directory->getBasename()] ?? $directory->getBasename();

            foreach ((new Finder())->files()->in($directory->getPathname()) as $file) {
                /** @var array<string, mixed> $config */
                $config = Yaml::parse((string) file_get_contents($file->getPathname()));
                $container->prependExtensionConfig($extensionName, $config);
                $container->addResource(new FileResource($file->getPathname()));
            }
        }
    }
}
