# 8. Configuration: YAML and INI

An Exponential Platform Legacy site has two configuration systems that describe the same site: Symfony's YAML
(siteaccesses, `system` scopes, designs, image variations, languages) and the legacy kernel's INI files
(`site.ini`, `image.ini`, `design.ini` and the rest, in `settings/override/` and `settings/siteaccess/<name>/`).
Neither replaces the other. The legacy bridge copies a fixed set of values from YAML into the legacy kernel as
*injected settings*, which beat anything in the INI files; everything else each side reads from its own files. This
chapter lists exactly what is injected, says which side wins where, and goes through siteaccesses, `legacy_mode`,
designs and templates, image variations and languages on each release line.

[Previous: 7. Databases](07-databases.md) · [Next: 9. Operations](09-operations.md) · [Contents](README.md)

## Contents of this chapter

- [8.1 Two systems, one site](#81-two-systems-one-site)
- [8.2 What the bridge injects](#82-what-the-bridge-injects)
- [8.3 Which side wins](#83-which-side-wins)
- [8.4 Injecting your own legacy settings](#84-injecting-your-own-legacy-settings)
- [8.5 Siteaccesses and legacy_mode](#85-siteaccesses-and-legacy_mode)
- [8.6 Designs and templates on both sides](#86-designs-and-templates-on-both-sides)
- [8.7 Image variations and image aliases](#87-image-variations-and-image-aliases)
- [8.8 Languages](#88-languages)
- [8.9 Where the files are, line by line](#89-where-the-files-are-line-by-line)
- [References](#references)

## 8.1 Two systems, one site

| Concern | Symfony side (YAML) | Legacy kernel (INI) |
|---|---|---|
| Siteaccess list, groups, matching | `ezpublish.siteaccess` (2.5, 3.x) or `ibexa.siteaccess` (4.6, 5.x) | `site.ini [SiteAccessSettings]`, `[SiteSettings] SiteList[]`; the matched name comes from Symfony on web requests |
| Per-siteaccess settings | `system: { default, <group>, <siteaccess>, global }`, read in that order | `settings/siteaccess/<name>/*.ini.append.php`; global values in `settings/override/`, which is read last and wins over the siteaccess files |
| Database, var directory | Doctrine connection, `var_dir` | injected (chapter 7) |
| Templates | Twig, `ezdesign` design chains, `content_view` rules | TPL, `[DesignSettings] SiteDesign` and `AdditionalSiteDesignList[]`, `override.ini` |
| Images | `image_variations` | `image.ini [AliasSettings] AliasList[]` and one block per alias, partly injected |
| Languages | `languages: [...]` per siteaccess | `site.ini [RegionalSettings]` |
| Extensions | bundles in `AppKernel.php` (2.5) or `config/bundles.php` (3.x and later) | `site.ini [ExtensionSettings] ActiveExtensions[]`, partly injected |

The legacy INI resolution order inside the kernel is the one of Exponential 6: the defaults in `settings/*.ini`, the
extensions' settings, `settings/siteaccess/<name>/`, and `settings/override/` **last, so it wins** ([5.6](05-the-legacy-kernel-inside.md#56-ini-and-yaml-which-wins) and
[chapter 10.13 of the Exponential 6 book](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md#1013-extension-management) describe it).
What changes in this distribution is a layer above all of them: injected settings.

## 8.2 What the bridge injects

Chapter 5 introduces injected settings ([5.5](05-the-legacy-kernel-inside.md#55-injected-settings)) and the order of
precedence ([5.6](05-the-legacy-kernel-inside.md#56-ini-and-yaml-which-wins)); this section is the complete list, listener by
listener.

Every time the bridge builds the legacy kernel (each web request that reaches it and each bridged console command),
its listeners on `PRE_BUILD_LEGACY_KERNEL` put the following into the kernel's `injected-settings` and
`injected-merge-settings` parameters (`se7enxweb/legacy-bridge`, `bundle/LegacyMapper/*.php`, same on `v2.1.x`,
`3.x`, `4.x` and `5.x`):

| Listener | Setting | Value |
|---|---|---|
| `Configuration` | `site.ini [DatabaseSettings]` `Server`, `Port`, `User`, `Password`, `Database`, `Socket`, `DatabaseImplementation` | from the Doctrine connection ([7.2](07-databases.md#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)) |
| `Configuration` | `site.ini [FileSettings] VarDir`, `StorageDir` | the siteaccess's `var_dir` and `storage_dir` (`var_dir: var/site` in all shipped configurations) |
| `Configuration` | `site.ini [UserSettings] AnonymousUserID` | `anonymous_user_id` |
| `Configuration` | `site.ini [ContentSettings] ViewCaching` | always `enabled`, so that content cache purges reach the HTTP and persistence caches |
| `Configuration` | `site.ini [SiteSettings] IndexPage`, `DefaultPage` | `index_page` / `default_page`; with a `content.tree_root.location_id` also `[SiteAccessSettings] PathPrefix`, `PathPrefixExclude[]` and `logfile.ini [AccessLogFileSettings] PathPrefix` |
| `Configuration` | `image.ini [FileSettings]`, `[AliasSettings] AliasList[]`, one block per alias, `[ImageMagick]` | from `image_variations` and the ImageMagick options ([8.7](#87-image-variations-and-image-aliases)) |
| `Configuration` | `file.ini [ClusteringSettings] FileHandler=eZDFSFileHandler`, `[eZDFSClusteringSettings]` | only when the container has `dfs_nfs_path` (2.5: when the environment variable `DFS_NFS_PATH` is set, see `app/config/env/generic.php`) |
| `Session` | `site.ini [Session]` `CookieTimeout`, `CookiePath`, `CookieDomain`, `CookieSecure`, `CookieHttponly` | all `false`: the session cookie is Symfony's (`framework.session`) |
| `LegacyBundles` | `site.ini [ExtensionSettings] ActiveExtensions[]` (merged) | legacy extensions that Symfony bundles declare |
| `Security` | `site.ini [SiteAccessRules] Rules[]` (merged) | `access;disable`, `module;user/login`, `module;user/logout` on siteaccesses **without** `legacy_mode`, because sign-in belongs to Symfony there |
| `SiteAccess` | the siteaccess itself (name, match type, URI part) | the siteaccess Symfony matched |

Besides these, `Configuration` sets the form-token secret of the legacy `ezformtoken` extension to Symfony's
`kernel.secret` and its field name to Symfony's CSRF field, so a form built by one side validates on the other; it
also attaches the legacy cache events (`content/cache`, `content/class/cache`, ...) to the platform's HTTP-cache and
persistence-cache purgers.

## 8.3 Which side wins

1. **Injected beats INI.** `eZINI` returns an injected value before it looks at any file, and merges
   `injected-merge-settings` (arrays only) on top of what the files give. An injected scalar cannot be overridden
   in `settings/override/` or `settings/siteaccess/`.
2. **Later listeners beat earlier ones for the same key.** The bridge's listeners run at priority 128 and combine
   their arrays with `$new + $existing`; a project listener at a lower priority that does the same (the
   `LegacyInjectedSettingsSubscriber` of the 4.6 and 5.x recipes runs at 64) wins for every key it sets. For
   `injected-merge-settings` that means a project list for `site.ini/ExtensionSettings/ActiveExtensions`
   **replaces** the list the `LegacyBundles` listener computed, it is not appended to it.
3. **Everything not injected is pure INI.** Designs, override rules, languages, mail, search, workflow, cronjob
   parts, debug settings and the rest are read from the legacy kernel's files as in Exponential 6.
4. **Console runs follow the same rules only through the bridge.** `bin/console ezpublish:legacy:script ...`
   (3.x and later: `exponential:legacy:script`) builds the kernel through the CLI handler and applies the injected
   settings; a script started directly with `php ezpublish_legacy/...` sees the INI files only.

A practical consequence: to change something the bridge injects, change it in YAML (the variation, the `var_dir`,
the connection), clear the Symfony cache, then clear the legacy INI cache.

## 8.4 Injecting your own legacy settings

The 3.x branch and the 4.6 and 5.x recipes add a project-level injector so that legacy settings can live in YAML
next to the rest of the configuration:

| Line | Where | Implementation |
|---|---|---|
| 2.5 | not present; use the legacy INI files | |
| 3.x | `config/app/packages/legacy.yaml` | the bundle `src/ExponentialPlatformLegacyInjectedSettings/` |
| 4.6, 5.x | `config/packages/ez_publish_legacy.yaml` | `src/EventSubscriber/LegacyInjectedSettingsSubscriber.php` (priority 64) |

All of them read four parameters:

```yaml
parameters:
    app.legacy.injected_settings:                 # scalars, replace the INI value
        'site.ini/SiteSettings/DefaultAccess': legacy_site
        'site.ini/SiteAccessSettings/CheckValidity': 'false'
    app.legacy.injected_merge_settings:           # arrays, merged on top of the INI array
        'site.ini/ExtensionSettings/ActiveExtensions': [ezjscore, ezoe, eztags, ngsymfonytools, app]
    app.legacy.siteaccess_injected_settings:      # per siteaccess
        legacy_admin:
            'site.ini/DesignSettings/SiteDesign': admin3
    app.legacy.siteaccess_injected_merge_settings: {}
```

Keys are `<file>.ini/<Section>/<Setting>`. The 4.6 and 5.x recipes warn in their own comments that
`eZINI::injectSettings()` is static, so a per-siteaccess value injected in a long-running PHP process can stay in
effect for the next request on another siteaccess; they keep siteaccess-specific values in
`settings/siteaccess/<name>/` instead and leave the two per-siteaccess parameters empty. Do the same if the site runs
in persistent workers. The same recipes also inject `file.ini/ClusteringSettings/FileHandler: eZFSFileHandler` to keep
the plain file handler on single-server installs.

## 8.5 Siteaccesses and legacy_mode

The bridge's configuration root is `ez_publish_legacy` (`bundle/DependencyInjection/Configuration.php`):

| Key | Default | Meaning |
|---|---|---|
| `enabled` | `true` | the bridge as a whole |
| `root_dir` | the installed `ezpublish_legacy/` | where the legacy kernel is; must exist |
| `clear_all_spi_cache_on_symfony_clear_cache` | `true` | `cache:clear` also clears the platform's persistence (SPI) cache |
| `clear_all_spi_cache_from_legacy` | `true` | a legacy content-cache clear also clears the SPI cache |
| `legacy_aware_routes` | `[]` | Symfony route names (or prefixes) still allowed on a `legacy_mode` siteaccess |
| `system.<scope>.legacy_mode` | `false` | `true`: the legacy kernel handles URL aliases and modules for this siteaccess (the legacy admin) |
| `system.<scope>.templating.view_layout` | `@EzPublishLegacy/legacy_view_default_pagelayout.html.twig` | Twig page layout around a content view rendered by legacy |
| `system.<scope>.templating.module_layout` | none (legacy's own page layout) | Twig page layout around legacy modules |

What the lines ship:

| Line | Siteaccesses (`siteaccess.list`) | Matching | `legacy_mode: true` |
|---|---|---|---|
| 2.5 | `site`, `admin`, `legacy_admin` (group `site_group` = site, legacy_admin; `admin_group` = admin) | `URIElement: 1` (a `Map\Host` example for two host names is commented out) | `legacy_admin` |
| 3.x | `fh_eng`, `site`, `bold_eng`, `bold_ger`, `adminui`, `ngadminui`, `legacy_site`, `legacy_admin` | `URIElement: 1`, set per server environment in `config/app/server/dev/ezpublish_siteaccess.yaml` and `config/app/server/prod.yaml` (host maps commented out in both) | `legacy_admin`, `legacy_site` |
| 4.6, 5.x | `site`, `legacy_site`, `legacy_admin` (group `site_group`, in `ibexa.yaml`) and `admin` (group `admin_group`, in `ibexa_admin_ui.yaml`; the lists of both files are merged) | `URIElement: 1` | `legacy_admin`, `legacy_site` |

With `URIElement: 1` the first path segment names the siteaccess: the legacy admin of a 2.5, 4.6 or 5.x install is at
`/legacy_admin/`, the platform admin of 2.5, 4.6 and 5 at `/admin/`, and a path without a known siteaccess name goes to
`default_siteaccess` (`site`). Older documents of this repository give `/ezpublish_legacy/` as the legacy admin's
address; no shipped configuration matches that path, it was never a siteaccess. On a production site with its own
host names, replace `URIElement` with a `Map\Host` matcher (the commented examples show the form), so that the
admin siteaccesses are reachable only on their own host and can be protected there ([chapter 13](13-security-hardening.md#135-the-admin-siteaccesses)). A Symfony siteaccess that the legacy kernel should serve needs a matching legacy directory
`ezpublish_legacy/settings/siteaccess/<name>/` and its name in `site.ini [SiteSettings] SiteList[]` and
`[SiteAccessSettings] AvailableSiteAccessList[]` (master's override lists `site`, `admin`, `legacy_admin`; the 4.6
and 5.x recipes inject `site`, `legacy_site`, `legacy_admin`).

On web requests the legacy kernel does not match siteaccesses itself: the bridge hands it the name Symfony matched,
so `MatchOrder` and `HostMatchMapItems[]` in the legacy INI only matter for scripts started without the bridge.
Master's override contains a `HostMatchMapItems[]` map for two `*.alpha.se7enx.com` host names left over from a
development site; it is harmless on bridged requests and can be removed.

A siteaccess **without** `legacy_mode` still uses the legacy kernel as a fallback: when no Twig `content_view` rule
matches, the bridge's legacy view providers (priority 5 for locations, 4 for content) render the item with TPL, ahead
of the kernel's default templates (priority -1) and behind the configured Twig rules (priority 10). URLs that no
Symfony route claims fall through to the legacy kernel's module and URL-alias handling (`FallbackRouter`).

## 8.6 Designs and templates on both sides

| | Twig (Symfony side) | TPL (legacy kernel) |
|---|---|---|
| Design chain | `ezdesign.design_list` plus the siteaccess's `design:` | `site.ini [DesignSettings] SiteDesign` and `AdditionalSiteDesignList[]` |
| 2.5 as shipped | `site`: `sevenx_content_website_app_developer`, `sevenx_content_website_app_info`, `sevenx_content_website_app`, `fh`, `app`, `common`, `standard`; templates in `app/Resources/views/themes/<theme>/` | per legacy siteaccess INI |
| 3.x as shipped | as 2.5 plus `bold`, `ngadmin`, `ngadminui`; templates in `templates/themes/<theme>/` | injected per siteaccess: `site` uses `standard`, `legacy_site` `simple`, `legacy_admin` `admin3` with `admin2`, `admin`, `standard` |
| Page layout | `pagelayout` per siteaccess; around legacy output `templating.view_layout` / `module_layout` | `pagelayout.tpl` of the design chain |
| Overrides | `content_view` rules (`match:`) | `override.ini` |

Twig cannot include a TPL template and TPL cannot include Twig; they meet at the page layout. On 2.5 the `site`
siteaccess wraps legacy-rendered content in `themes/standard/pagelayout.html.twig`
(`ez_publish_legacy.system.site.templating.view_layout`). The 3.x branch ships the corresponding block for `fh_group`
commented out, so there the legacy kernel's own page layout is used.

Legacy design files are served from `web/design`, `web/extension`, `web/share` and `web/var` (`public/...` from 4.6
on): `ezpublish:legacy:assets_install` (3.x and later: `exponential:legacy:assets-install`) makes these links to
`ezpublish_legacy/`. Legacy extensions that live in bundles are linked into `ezpublish_legacy/extension/` by
`ezpublish:legacybundles:install_extensions` (`exponential:legacy:install-extensions`).

## 8.7 Image variations and image aliases

The two sides generate their own image files from the same original:

| | Platform (`image_variations`) | Legacy (`image.ini` aliases) |
|---|---|---|
| Generated by | LiipImagine, on the first request of a variation | `eZImageAliasHandler`, on first use in a template |
| File name | `<storage>/images/_aliases/<variation>/<path of original>` (`AliasDirectoryVariationPathGenerator`, the default on every line) | next to the original: `<name>_<alias>.<ext>` |
| Stored in the database | no | yes, in the image attribute's XML |

The bridge builds the legacy alias list **from the YAML variations**: `image.ini [AliasSettings] AliasList[]` is
injected as the list of `image_variations` names of the siteaccess, each alias gets `Reference` from the variation's
`reference` and `Filters[]` for every filter whose name also exists in the ImageMagick filter map; the
`[ImageMagick]` block (enabled flag, executable, pre and post parameters, filters) comes from the platform's
ImageMagick options. Because `AliasList[]` is injected, **an alias that exists only in a legacy `image.ini` is not
available to legacy templates**; templates that ask for it get no file. Define every alias the legacy templates use
as an `image_variations` entry with filters both sides understand, or inject the extra names yourself with
`app.legacy.injected_merge_settings` on 3.x and later.

A worked example. The `ezwebin` design's templates ask for `listitem`, `articlethumbnail`, `imagelarge` and
`gallerythumbnail` (`grep -rhoE "image_class=[a-z_]+" ezpublish_legacy/extension/ezwebin/design | sort -u`), none of
which is a default variation of the platform kernel (`reference`, `small`, `tiny`, `medium`, `large`, ...). Find the
names your designs use, then declare them for the siteaccesses the legacy kernel renders:

```yaml
# 2.5: app/config/ezplatform.yml; 3.x and later: the file holding the siteaccess configuration
ezpublish:            # `ibexa:` on 4.6 and 5.x
    system:
        site_group:
            image_variations:
                listitem:
                    reference: ~
                    filters:
                        geometry/scaledownonly: [130, 190]
                articlethumbnail:
                    reference: ~
                    filters:
                        geometry/scaledownonly: [170, 220]
```

Then clear the Symfony cache and the legacy INI cache ([chapter 9](09-operations.md#91-caches-on-both-sides)). What
can go wrong: a variation whose filter has no ImageMagick equivalent in the bridge's filter map is still listed as an
alias but gets no `Filters[]` on the legacy side, so the legacy file comes out unscaled; compare the two images once
after adding a variation. The sizes above are examples, not the values of any shipped design.

The 4.6 recipe's `ibexa.yaml` adds `original` and `reference` variations with `reference: ~` and empty filters in the
`default` scope and for `legacy_site` and `legacy_admin`, with the comment that a null built-in variation made
`getImageSettings()` fail when the legacy kernel was built. The 4.6 and 5.0 recipes also declare
`ibexa.site_access.config.default.imagemagick.pre_parameters` and `post_parameters` as empty container parameters,
because the bridge reads them and no 4.x/5.x configuration parser defines them.

Removing aliases: the legacy events `image/removeAliases`, `image/trashAliases` and `image/purgeAliases` are wired to
the platform's alias cleaner, so a legacy edit also clears the platform's variations of that image.

## 8.8 Languages

Languages are **not** injected. Keep the two lists in step by hand:

| Platform | Legacy |
|---|---|
| `system.<siteaccess>.languages: [eng-GB, ger-DE]` (prioritised list) | `site.ini [RegionalSettings] Locale`, `ContentObjectLocale`, `SiteLanguageList[]` |
| `translation_siteaccesses: [...]` | `[RegionalSettings] TranslationSA[]` |
| the admin group's list = languages editors can translate into | the legacy admin's `SiteLanguageList[]` and `ShowUntranslatedObjects` |

The bridge's `init_ini` defaults for `legacy_admin` set `ContentObjectLocale=eng-GB` and `SiteLanguageList[]=eng-GB`;
master's `admin_group` comment warns that the shipped content is `eng-GB` and that removing it from the list hides
content. Languages themselves (`ezcontent_language`) live in the shared database and can be added from either admin.

## 8.9 Where the files are, line by line

| | 2.5 (master) | 3.x | 4.6 | 5.x |
|---|---|---|---|---|
| Symfony configuration | `app/config/*.yml`, `parameters.yml` | `config/packages/`, `config/app/`, `.env.local` | `config/packages/` (Flex recipe), `.env.local` | as 4.6 |
| Main siteaccess file | `app/config/ezplatform.yml` | `config/app/packages/ezpublish_siteaccess.yaml` | `config/packages/ibexa.yaml` | `config/packages/ibexa.yaml` |
| Bridge configuration | `ez_publish_legacy:` in `ezplatform.yml` | in `ezpublish_siteaccess.yaml`, injected settings in `config/app/packages/legacy.yaml` | `config/packages/ez_publish_legacy.yaml` | same |
| Legacy global overrides | `ezpublish_legacy/settings/override/` (in git) | `ezpublish_legacy/settings/override/` | `src/LegacySettings/override/`, linked in by `bin/install-legacy-links` | same |
| Legacy siteaccess settings | `ezpublish_legacy/settings/siteaccess/legacy_admin/` (in git) | `ezpublish_legacy/settings/siteaccess/` | `src/ezpublish_legacy/app/settings/siteaccess/<name>/`, linked in | same |
| Project legacy extension | | | `src/ezpublish_legacy/app` linked as `ezpublish_legacy/extension/app` | same |

On 4.6 and 5.x, keep your changes in `src/`: `bin/install-legacy-links` runs on every `composer install` and
`composer update` and re-creates the links into `ezpublish_legacy/`, which Composer may replace.

## References

In this repository: [`app/config/ezplatform.yml`](../../app/config/ezplatform.yml), [`app/config/config.yml`](../../app/config/config.yml),
[`ezpublish_legacy/settings/`](../../ezpublish_legacy/settings/); on the 3.x branch
[`config/app/packages/legacy.yaml`](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/config/app/packages/legacy.yaml) and
[`config/app/packages/ezpublish_siteaccess.yaml`](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/config/app/packages/ezpublish_siteaccess.yaml);
the 4.6 and 5.x project files in [se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes)
(`se7enxweb/exponential-platform-dxp/4.6.x-LB-dev/` and `5.0/`).

The bridge: [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`) (`bundle/LegacyMapper/`,
`bundle/DependencyInjection/Configuration.php`, `bundle/Resources/config/view.yml`).

The Exponential 6 book: [chapter 10, after installing](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md)
(siteaccesses, multi-language sites), [chapter 15, migrating from the 5.x stack](https://github.com/se7enxweb/exponential/blob/main/doc/install/15-migrating-from-5x-legacy.md)
(YAML to INI, image variations and aliases, Twig and TPL), and the
[legacy bridge feature page](https://github.com/se7enxweb/exponential/blob/main/doc/features/6.0/legacy-bridge.md).

External: Symfony [configuration](https://symfony.com/doc/current/configuration.html) and
[service tags and event subscribers](https://symfony.com/doc/current/event_dispatcher.html); upstream concepts
[SiteAccess](https://doc.ibexa.co/en/latest/multisite/siteaccess/siteaccess/),
[image variations](https://doc.ibexa.co/en/latest/content_management/images/images/),
[languages](https://doc.ibexa.co/en/latest/multisite/languages/languages/) and
[design engine](https://doc.ibexa.co/en/latest/templating/design_engine/design_engine/).

[Previous: 7. Databases](07-databases.md) · [Next: 9. Operations](09-operations.md) · [Contents](README.md)
