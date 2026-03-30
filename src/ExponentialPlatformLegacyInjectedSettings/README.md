# Exponential Platform — Legacy Injected Settings Bundle

A Symfony bundle for [Exponential Platform Legacy](https://github.com/se7enxweb/exponential-platform-legacy) (eZ Platform / Ibexa OSS) that injects legacy INI settings and merge-settings into the eZ Publish legacy kernel at boot time, configured entirely via YAML.

This provides the same capability as the `injected_settings` / `injected_merge_settings` keys of the `netgen_site_legacy` bundle, without requiring that bundle to be installed.

Developed and maintained by **7x / se7enxweb** — the team behind [Exponential Platform](https://exponential.earth) and [se7enx.com](https://se7enx.com).

---

## Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [How It Works](#how-it-works)
6. [Support & Contact](#support--contact)
7. [License & Copyright](#license--copyright)

---

## Overview

The eZ Publish legacy kernel supports two injection mechanisms applied before the kernel boots:

| Mechanism | Effect |
|---|---|
| `injected-settings` | Scalar overrides — highest priority, replaces any matching INI value |
| `injected-merge-settings` | Array merge — appended to existing array INI values |

This bundle subscribes to `LegacyEvents::PRE_BUILD_LEGACY_KERNEL` at priority **64** (after the core `LegacyMapper/Configuration` at 128) and pushes values from two Symfony container parameters into the kernel event:

- `app.legacy.injected_settings`
- `app.legacy.injected_merge_settings`

Both parameters are defined in `config/app/packages/legacy.yaml` and are entirely optional — the bundle boots cleanly when neither is set.

---

## Requirements

| Dependency | Version |
|---|---|
| PHP | ≥ 8.1 |
| Symfony Framework Bundle | ^5.4 \|\| ^6.0 |
| se7enxweb/legacy-bridge | * |
| Exponential Platform Legacy | compatible release |

---

## Installation

See [doc/INSTALL.md](doc/INSTALL.md) for detailed installation and registration steps.

---

## Configuration

See [doc/USAGE.md](doc/USAGE.md) for full configuration reference and examples.

---

## How It Works

1. The `ExponentialPlatformLegacyInjectedSettingsExtension` registers default empty values for both parameters so the bundle never fails if `legacy.yaml` omits them.
2. `LegacyInjectedSettingsSubscriber::onPreBuildKernel()` fires on every legacy kernel boot, reads the two parameters, and merges them into the `PreBuildKernelEvent` parameter bag using the same array-union pattern as the core mappers.
3. The legacy kernel's `eZINI::injectSettings()` and `eZINI::injectMergeSettings()` then apply them before any INI file is read.

---

## Support & Contact

- Issues: https://github.com/se7enxweb/exponential-platform-legacy/issues
- Web: https://exponential.earth
- Developer: https://se7enx.com

---

## License & Copyright

Copyright (C) 1998-2026 7x / se7enxweb — https://se7enx.com

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

See [LICENSE.md](LICENSE.md) for the full license text.
