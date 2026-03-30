# USAGE — Exponential Platform Legacy Injected Settings Bundle

---

## Table of Contents

1. [Configuration Overview](#configuration-overview)
2. [injected_settings — Scalar Overrides](#injected_settings--scalar-overrides)
3. [injected_merge_settings — Array Merge](#injected_merge_settings--array-merge)
4. [Full Example](#full-example)
5. [Key Format Reference](#key-format-reference)
6. [Common Settings Reference](#common-settings-reference)
7. [Precedence & Priority Notes](#precedence--priority-notes)

---

## Configuration Overview

Both injection types are configured as Symfony container parameters in `config/app/packages/legacy.yaml`:

```yaml
parameters:
    app.legacy.injected_settings:       # scalar overrides
        'file.ini/Section/Setting': value

    app.legacy.injected_merge_settings: # array merges
        'file.ini/Section/ArraySetting':
            - value1
            - value2
```

The bundle subscriber fires at priority **64** on `LegacyEvents::PRE_BUILD_LEGACY_KERNEL`, after the core `LegacyMapper/Configuration` (priority 128), so your values take precedence over the built-in mappings.

---

## injected_settings — Scalar Overrides

Use `injected_settings` for any single-value INI setting. These are applied via `eZINI::injectSettings()` and override everything — INI files, override files, and built-in mappers.

```yaml
parameters:
    app.legacy.injected_settings:
        'site.ini/SiteSettings/DefaultAccess': site
        'site.ini/SiteAccessSettings/CheckValidity': 'false'
        'site.ini/SiteAccessSettings/ForceVirtualHost': 'true'
        'site.ini/DesignSettings/SiteDesign': standard
        'site.ini/DesignSettings/DesignLocationCache': enabled
        'site.ini/UserSettings/LogoutRedirect': /
        'site.ini/DatabaseSettings/Charset': utf8mb4
        'site.ini/Session/SessionNameHandler': custom
        'content.ini/ClassGroupIDs/Media': 2
        'content.ini/ClassGroupIDs/Users': 3
```

> **Note:** Boolean-like settings in the legacy INI system use the strings `"true"` / `"false"` / `"enabled"` / `"disabled"` — not YAML booleans.

---

## injected_merge_settings — Array Merge

Use `injected_merge_settings` for array-type INI settings. These are applied via `eZINI::injectMergeSettings()` and are merged with existing array values.

```yaml
parameters:
    app.legacy.injected_merge_settings:
        'site.ini/ExtensionSettings/ActiveExtensions':
            - app
            - ngsymfonytools
            - ezrichtext
            - ezplatformsearch
            - ezjscore
            - ezoe
        'site.ini/SiteSettings/SiteList':
            - site
            - admin
            - legacy_admin
        'site.ini/SiteAccessSettings/AvailableSiteAccessList':
            - site
            - admin
            - legacy_admin
        'site.ini/SiteAccessRules/Rules':
            - 'access;disable'
            - 'module;user/register'
            - 'module;user/activate'
```

---

## Full Example

```yaml
# config/app/packages/legacy.yaml

parameters:
    app.legacy.injected_settings:
        'site.ini/SiteSettings/DefaultAccess': site
        'site.ini/SiteSettings/RootNodeDepth': 1
        'site.ini/SiteAccessSettings/CheckValidity': 'false'
        'site.ini/SiteAccessSettings/ForceVirtualHost': 'true'
        'site.ini/SiteAccessSettings/RemoveSiteAccessIfDefaultAccess': enabled
        'site.ini/DesignSettings/SiteDesign': standard
        'site.ini/DesignSettings/DesignLocationCache': enabled
        'site.ini/DatabaseSettings/Charset': utf8mb4
        'site.ini/Session/SessionNameHandler': custom
        'site.ini/UserSettings/LogoutRedirect': /
        'content.ini/ClassGroupIDs/Media': 2
        'content.ini/ClassGroupIDs/Users': 3
        'content.ini/ClassGroupIDs/Setup': -1

    app.legacy.injected_merge_settings:
        'site.ini/ExtensionSettings/ActiveExtensions':
            - app
            - ngsymfonytools
            - ezrichtext
            - ezplatformsearch
            - ezjscore
            - ezoe
        'site.ini/SiteSettings/SiteList':
            - site
            - admin
            - legacy_admin
        'site.ini/SiteAccessSettings/AvailableSiteAccessList':
            - site
            - admin
            - legacy_admin
        'site.ini/SiteAccessRules/Rules':
            - 'access;disable'
            - 'module;user/register'
            - 'module;user/activate'
            - 'module;user/success'
            - 'module;user/forgotpassword'
            - 'module;ezinfo/about'
            - 'module;content/advancedsearch'
```

---

## Key Format Reference

```
'<ini-filename>/<SectionName>/<SettingName>'
```

| Part | Example |
|---|---|
| INI filename | `site.ini`, `content.ini`, `image.ini`, `ezoe.ini` |
| Section name | `SiteSettings`, `ExtensionSettings`, `DesignSettings` |
| Setting name | `DefaultAccess`, `ActiveExtensions`, `SiteDesign` |

Full example key: `'site.ini/ExtensionSettings/ActiveExtensions'`

---

## Common Settings Reference

| Key | Type | Example Value |
|---|---|---|
| `site.ini/SiteSettings/DefaultAccess` | scalar | `site` |
| `site.ini/SiteSettings/RootNodeDepth` | scalar | `1` |
| `site.ini/SiteSettings/SiteList` | merge | `[site, admin]` |
| `site.ini/SiteAccessSettings/CheckValidity` | scalar | `'false'` |
| `site.ini/SiteAccessSettings/ForceVirtualHost` | scalar | `'true'` |
| `site.ini/SiteAccessSettings/AvailableSiteAccessList` | merge | `[site, admin]` |
| `site.ini/SiteAccessSettings/RemoveSiteAccessIfDefaultAccess` | scalar | `enabled` |
| `site.ini/SiteAccessRules/Rules` | merge | `['access;disable', ...]` |
| `site.ini/ExtensionSettings/ActiveExtensions` | merge | `[app, ezjscore]` |
| `site.ini/DesignSettings/SiteDesign` | scalar | `standard` |
| `site.ini/DesignSettings/DesignLocationCache` | scalar | `enabled` |
| `site.ini/DatabaseSettings/Charset` | scalar | `utf8mb4` |
| `site.ini/Session/SessionNameHandler` | scalar | `custom` |
| `site.ini/UserSettings/LogoutRedirect` | scalar | `/` |
| `content.ini/ClassGroupIDs/Media` | scalar | `2` |
| `content.ini/ClassGroupIDs/Users` | scalar | `3` |

---

## Precedence & Priority Notes

- `injected_settings` has the **highest** priority — it overrides INI files, override files, and the built-in `LegacyMapper/Configuration` mappings.
- `injected_merge_settings` **merges** into existing array values. Later subscribers can still add more entries.
- The subscriber fires at **priority 64**. If you need to run before or after another subscriber, adjust the priority constant in `LegacyInjectedSettingsSubscriber::getSubscribedEvents()`.
- The left-hand `+` (array union) operator means your values win over any previously set values for the same key in the event parameter bag.
