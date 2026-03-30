# INSTALL — Exponential Platform Location Children Twig Helper Bundle

This guide covers installation and registration of `se7enxweb/exponential-platform-location-children-twig-helper` in an Exponential Platform Legacy (eZ Platform / Ibexa OSS) project.

---

## Table of Contents

1. [Requirements](#requirements)
2. [Installation — Embedded (default)](#installation--embedded-default)
3. [Installation — Standalone Composer Package](#installation--standalone-composer-package)
4. [Bundle Registration](#bundle-registration)
5. [Service Wiring Verification](#service-wiring-verification)
6. [Verify the Twig Function](#verify-the-twig-function)
7. [Troubleshooting](#troubleshooting)

---

## Requirements

- PHP ≥ 8.0
- Symfony ^5.4 or ^6.x
- eZ Platform Kernel ^1.3 or Ibexa OSS ^2.0
- Twig ^3.0

---

## Installation — Embedded (default)

In **Exponential Platform Legacy**, this bundle ships inside `src/ExponentialPlatformLocationChildrenTwigHelper/` and is covered by the app's global `App\` PSR-4 autoload (`src/`). No additional Composer step is needed.

**Step 1 — Register the bundle** in `config/bundles.php`:

```php
App\ExponentialPlatformLocationChildrenTwigHelper\ExponentialPlatformLocationChildrenTwigHelperBundle::class => ['all' => true],
```

**Step 2 — Clear the cache:**

```bash
php bin/console cache:clear
# or
make clear-cache
```

That's it. The `ez_location_children()` Twig function is now available in all templates.

---

## Installation — Standalone Composer Package

> This section applies when the bundle is extracted to its own repository and published to Packagist as `se7enxweb/exponential-platform-location-children-twig-helper`.

**Step 1 — Require the package:**

```bash
composer require se7enxweb/exponential-platform-location-children-twig-helper
```

**Step 2 — Register the bundle** in `config/bundles.php`:

```php
Se7enxweb\ExponentialPlatformLocationChildrenTwigHelper\ExponentialPlatformLocationChildrenTwigHelperBundle::class => ['all' => true],
```

**Step 3 — Clear the cache:**

```bash
php bin/console cache:clear
```

---

## Bundle Registration

The bundle class is:

```
App\ExponentialPlatformLocationChildrenTwigHelper\ExponentialPlatformLocationChildrenTwigHelperBundle
```

Add to `config/bundles.php`:

```php
return [
    // ... existing bundles ...
    App\ExponentialPlatformLocationChildrenTwigHelper\ExponentialPlatformLocationChildrenTwigHelperBundle::class => ['all' => true],
];
```

The DependencyInjection extension (`ExponentialPlatformLocationChildrenTwigHelperExtension`) automatically loads `Resources/config/services.yaml`, registering the Twig extension with the correct eZ Platform service arguments and `twig.extension` tag.

---

## Service Wiring Verification

The bundle wires:

| Constructor arg | eZ Platform service |
|---|---|
| `$searchService` | `@ezpublish.api.service.search` |
| `$locationService` | `@ezpublish.api.service.location` |

Verify registration with:

```bash
php bin/console debug:container App\\ExponentialPlatformLocationChildrenTwigHelper\\Twig\\LocationChildrenExtension
```

Verify the Twig function is registered:

```bash
php bin/console debug:twig | grep ez_location_children
```

---

## Verify the Twig Function

In any Twig template that has access to a `location` variable:

```twig
{% set children = ez_location_children(location) %}
{{ children|length }} children found.
```

Or test from the Symfony profiler Twig panel — `ez_location_children` will appear in the registered functions list.

---

## Troubleshooting

### `Unknown function "ez_location_children"`

- Confirm the bundle is registered in `config/bundles.php`.
- Run `php bin/console cache:clear`.
- Check `php bin/console debug:twig | grep ez_location_children`.

### Service not found / argument injection error

- Confirm `ezpublish.api.service.search` and `ezpublish.api.service.location` exist:
  ```bash
  php bin/console debug:container ezpublish.api.service.search
  php bin/console debug:container ezpublish.api.service.location
  ```
- These are provided by `EzPublishCoreBundle`. Ensure it is registered and the Symfony container is rebuilt.

### No results returned

- Verify the `Location` object passed to `ez_location_children()` has children published in the current siteaccess.
- Check siteaccess language configuration — content in other languages may be filtered by the search criteria.
- Increase the limit: `ez_location_children(location, 200)`.

---

## Support

For professional support, consulting, or a support subscription:

- **Support subscriptions:** [se7enx.com/support](https://se7enx.com/support)
- **Contact 7x:** [se7enx.com/contact](https://se7enx.com/contact)
- **GitHub Issues:** [github.com/se7enxweb/exponential-platform-legacy/issues](https://github.com/se7enxweb/exponential-platform-legacy/issues)

---

Copyright &copy; 1998 &ndash; 2026 7x / se7enxweb. Licensed under the GNU GPL v2 or any later version.
