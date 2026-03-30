<?php

declare(strict_types=1);

namespace App\ExponentialPlatformLegacyInjectedSettings\EventSubscriber;

use eZ\Publish\Core\MVC\Legacy\Event\PreBuildKernelEvent;
use eZ\Publish\Core\MVC\Legacy\LegacyEvents;
use eZ\Publish\Core\MVC\Symfony\SiteAccess;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

/**
 * Injects INI settings into the legacy kernel at boot time.
 *
 * Supports both global and per-siteaccess settings, configured via
 * parameters in config/app/packages/legacy.yaml:
 *
 *   parameters:
 *     # Global — applied to every siteaccess
 *     app.legacy.injected_settings:
 *       'file.ini/SectionName/SettingName': value
 *     app.legacy.injected_merge_settings:
 *       'file.ini/SectionName/ArraySetting': [value1, value2]
 *
 *     # Per-siteaccess — applied only when the named siteaccess is active
 *     app.legacy.siteaccess_injected_settings:
 *       my_siteaccess:
 *         'file.ini/SectionName/SettingName': value
 *     app.legacy.siteaccess_injected_merge_settings:
 *       my_siteaccess:
 *         'file.ini/SectionName/ArraySetting': [value1, value2]
 *
 * injected_settings       -> eZINI::injectSettings()      (scalar overrides, highest priority)
 * injected_merge_settings -> eZINI::injectMergeSettings() (array merge)
 *
 * Per-siteaccess values take precedence over global values for the same key.
 */
final class LegacyInjectedSettingsSubscriber implements EventSubscriberInterface
{
    public function __construct(
        private readonly array $injectedSettings,
        private readonly array $injectedMergeSettings,
        private readonly array $siteaccessInjectedSettings,
        private readonly array $siteaccessInjectedMergeSettings,
        private readonly SiteAccess $siteAccess,
    ) {
    }

    public static function getSubscribedEvents(): array
    {
        // Priority 64: runs after the built-in LegacyMapper/Configuration (priority 128)
        // so our values layer on top via left-hand precedence of array union (+).
        return [
            LegacyEvents::PRE_BUILD_LEGACY_KERNEL => ['onPreBuildKernel', 64],
        ];
    }

    public function onPreBuildKernel(PreBuildKernelEvent $event): void
    {
        // Per-siteaccess values overlay globals (left-hand + wins).
        $saName = $this->siteAccess->name;

        $settings = ($this->siteaccessInjectedSettings[$saName] ?? []) + $this->injectedSettings;
        $mergeSettings = ($this->siteaccessInjectedMergeSettings[$saName] ?? []) + $this->injectedMergeSettings;

        if (!empty($settings)) {
            $event->getParameters()->set(
                'injected-settings',
                $settings + (array) $event->getParameters()->get('injected-settings'),
            );
        }

        if (!empty($mergeSettings)) {
            $event->getParameters()->set(
                'injected-merge-settings',
                $mergeSettings + (array) $event->getParameters()->get('injected-merge-settings'),
            );
        }
    }
}
