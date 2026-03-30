# Exponential Platform — Location Children Twig Helper Bundle

A lightweight Symfony bundle for [Exponential Platform Legacy](https://github.com/se7enxweb/exponential-platform-legacy) (eZ Platform / Ibexa OSS) that exposes a single Twig function, `ez_location_children()`, for fetching and rendering direct child `Location` objects directly in templates.

Developed and maintained by **7x / se7enxweb** — the team behind [Exponential Platform](https://exponential.earth) and [se7enx.com](https://se7enx.com).

---

## Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Configuration](#configuration)
6. [Support & Contact](#support--contact)
7. [License & Copyright](#license--copyright)

---

## Overview

This bundle wraps the eZ Platform `SearchService` and `LocationService` to expose a convenient Twig helper:

```twig
{% set children = ez_location_children(location) %}
{% set children = ez_location_children(location, 100) %}
```

Results are sorted by **priority ascending**, then **name ascending**. The optional second argument controls the result limit (default: `50`).

### Why this bundle?

eZ Platform templates often need to list child items of a given location — menus, subfolder listings, nested content trees. The native approach requires a controller action and a dedicated template variable. This bundle lets you call it inline in any Twig template that already has access to a `Location` object, without any controller boilerplate.

---

## Requirements

| Dependency | Version |
|---|---|
| PHP | ≥ 8.0 |
| Symfony | ^5.4 \|\| ^6.x |
| eZ Platform Kernel / Ibexa OSS | ^1.3 \|\| ^2.0 |
| Twig | ^3.0 |

---

## Installation

See [doc/INSTALL.md](doc/INSTALL.md) for full installation instructions.

**Quick start (already embedded in Exponential Platform Legacy):**

The bundle is included in the `src/` directory of [exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy). Register it in `config/bundles.php`:

```php
App\ExponentialPlatformLocationChildrenTwigHelper\ExponentialPlatformLocationChildrenTwigHelperBundle::class => ['all' => true],
```

No further configuration is needed — Symfony's autowiring and autoconfigure handle service registration automatically.

---

## Usage

### Basic — list children of the current location

```twig
{% set children = ez_location_children(location) %}
{% for child in children %}
    <li>
        <a href="{{ path('ez_urlalias', { locationId: child.id }) }}">
            {{ ez_content_name(ez_content(child.contentId)) }}
        </a>
    </li>
{% endfor %}
```

### With custom limit

```twig
{% set children = ez_location_children(location, 100) %}
```

### With a specific location by ID

```twig
{% set rootLocation = ez_location(2) %}
{% set topItems = ez_location_children(rootLocation, 10) %}
```

### Arguments

| Argument | Type | Default | Description |
|---|---|---|---|
| `location` | `Location` | required | The parent location object |
| `limit` | `int` | `50` | Maximum number of children to return |

### Return value

Returns an array of `\eZ\Publish\API\Repository\Values\Content\Location` objects, sorted by **priority asc → name asc**.

---

## Configuration

No configuration is required. The bundle registers its services automatically via the DependencyInjection extension, which wires `ezpublish.api.service.search` and `ezpublish.api.service.location` into the Twig extension.

The effective service definition (loaded from `Resources/config/services.yaml`):

```yaml
services:
    App\ExponentialPlatformLocationChildrenTwigHelper\Twig\LocationChildrenExtension:
        arguments:
            $searchService:  '@ezpublish.api.service.search'
            $locationService: '@ezpublish.api.service.location'
        tags:
            - { name: twig.extension }
```

---

## The Exponential Platform Project

This bundle is part of the **Exponential Platform** ecosystem — a hybrid-kernel open-source DXP built on eZ Platform / Ibexa OSS, PHP & Symfony.

| Resource | URL |
|---|---|
| Exponential Platform | [exponential.earth](https://exponential.earth) |
| Platform Legacy repo | [github.com/se7enxweb/exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy) |
| Platform documentation | [doc.exponential.earth](https://doc.exponential.earth) |
| se7enxweb on GitHub | [github.com/se7enxweb](https://github.com/se7enxweb) |
| 7x / se7enx.com | [se7enx.com](https://se7enx.com) |

---

## Support & Contact

**Need help or a support subscription?**

7x provides professional support, consulting, and custom development for Exponential Platform and eZ Platform / Ibexa OSS projects.

| Support channel | URL |
|---|---|
| Purchase a support subscription | [se7enx.com/support](https://se7enx.com/support) |
| Contact 7x directly | [se7enx.com/contact](https://se7enx.com/contact) |
| GitHub Issues (community) | [github.com/se7enxweb/exponential-platform-legacy/issues](https://github.com/se7enxweb/exponential-platform-legacy/issues) |
| GitHub Discussions | [github.com/se7enxweb/exponential-platform-legacy/discussions](https://github.com/se7enxweb/exponential-platform-legacy/discussions) |

---

## License & Copyright

Copyright &copy; 1998 &ndash; 2026 **7x / se7enxweb**. All rights reserved (unless otherwise noted).

This bundle is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version**.

This program is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY**; without even the implied warranty of **MERCHANTABILITY** or **FITNESS FOR A PARTICULAR PURPOSE**. See the [LICENSE.md](LICENSE.md) file or the [GNU General Public License](https://www.gnu.org/licenses/gpl-2.0.html) for full details.
