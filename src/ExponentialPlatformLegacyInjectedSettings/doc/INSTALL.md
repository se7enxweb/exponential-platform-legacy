# INSTALL — Exponential Platform Legacy Injected Settings Bundle

This guide covers installation and registration of `se7enxweb/exponential-platform-legacy-injected-settings` in an Exponential Platform Legacy (eZ Platform / Ibexa OSS) project.

---

## Table of Contents

1. [Requirements](#requirements)
2. [Installation — Embedded (default)](#installation--embedded-default)
3. [Bundle Registration](#bundle-registration)
4. [Parameter Definition](#parameter-definition)
5. [Remove Manual Service Wiring](#remove-manual-service-wiring)
6. [Cache Clear](#cache-clear)
7. [Verify](#verify)
8. [Troubleshooting](#troubleshooting)

---

## Requirements

- PHP ≥ 8.1
- Symfony `^5.4` or `^6.0`
- `se7enxweb/legacy-bridge` installed and enabled
- Exponential Platform Legacy project

---

## Installation — Embedded (default)

This bundle ships inside the `src/` directory of the Exponential Platform Legacy project. No Composer installation step is required — it is autoloaded via the project's root `composer.json` PSR-4 entry for `App\\`.

---

## Bundle Registration

Add the bundle to `config/bundles.php`:

```php
App\ExponentialPlatformLegacyInjectedSettings\ExponentialPlatformLegacyInjectedSettingsBundle::class => ['all' => true],
```

---

## Parameter Definition

Add the following to `config/app/packages/legacy.yaml`. Both keys are optional; omit either if not needed.

```yaml
parameters:
    app.legacy.injected_settings:
        # Format: 'file.ini/Section/Setting': value
        # These are scalar overrides — highest priority, replace any matching INI value.
        # 'site.ini/SiteSettings/DefaultAccess': site

    app.legacy.injected_merge_settings:
        # Format: 'file.ini/Section/ArraySetting': [value1, value2, ...]
        # These are array merges — appended to existing array INI values.
        # 'site.ini/ExtensionSettings/ActiveExtensions': [app, ezjscore]
```

See [USAGE.md](USAGE.md) for full examples.

---

## Remove Manual Service Wiring

If you previously wired `App\EventSubscriber\LegacyInjectedSettingsSubscriber` manually in `config/app/services.yaml`, remove that entry — the bundle now handles it automatically.

---

## Cache Clear

```bash
php bin/console cache:clear --env=dev
```

---

## Verify

Check the subscriber is registered:

```bash
php bin/console debug:event-dispatcher ezpublish.legacy.build_legacy_kernel_web
```

You should see `LegacyInjectedSettingsSubscriber::onPreBuildKernel` listed at priority 64.

Check a parameter is being applied:

```bash
php bin/console debug:container --parameters | grep app.legacy
```

---

## Troubleshooting

**`app.legacy.injected_settings` parameter not found**
Ensure `legacy.yaml` defines the `parameters:` block. The bundle sets empty defaults, but an explicit definition is safer.

**Settings not taking effect**
Verify the INI key format is exactly `file.ini/SectionName/SettingName` — the slash-separated triple is required. Also confirm the legacy kernel cache is cleared: `php bin/console cache:clear`.

**Subscriber not fired**
Confirm the bundle is registered in `bundles.php` and that `se7enxweb/legacy-bridge` is active.
