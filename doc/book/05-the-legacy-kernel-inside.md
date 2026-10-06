# 5. The legacy kernel inside

This chapter explains how the Exponential 6 legacy kernel lives inside Exponential Platform Legacy and how you work with
it day to day: what LegacyBridge does on every request, which siteaccesses hand their requests to the legacy kernel,
where the legacy files are on disk on each line (and which of them are links into `src/`), the bridge's configuration
keys, the *injected settings* that let YAML set legacy INI values, the question "INI or YAML, which wins?", running
legacy scripts and cronjobs through the Symfony console, autoloads, the legacy caches and legacy extensions. Wherever
the legacy kernel behaves exactly as it does on its own, this chapter links to the matching chapter of the Exponential 6
book instead of repeating it, and explains only what is different behind the bridge.

[Previous: 4. Installing](04-installing.md) · [Next: 6. Serving the site](06-serving-the-site.md) · [Contents](README.md)

---

## Contents of this chapter

1. [What the bridge does on a request](#51-what-the-bridge-does-on-a-request)
2. [Which siteaccesses run the legacy kernel](#52-which-siteaccesses-run-the-legacy-kernel)
3. [Where the legacy files live](#53-where-the-legacy-files-live)
4. [The bridge's configuration](#54-the-bridges-configuration)
5. [Injected settings](#55-injected-settings)
6. [INI and YAML: which wins](#56-ini-and-yaml-which-wins)
7. [Running legacy scripts through the console](#57-running-legacy-scripts-through-the-console)
8. [Legacy cronjobs](#58-legacy-cronjobs)
9. [Autoloads](#59-autoloads)
10. [Legacy caches](#510-legacy-caches)
11. [Legacy extensions](#511-legacy-extensions)
12. [The legacy admin](#512-the-legacy-admin)
13. [References](#513-references)

---

## 5.1 What the bridge does on a request

LegacyBridge is the Symfony bundle `eZ\Bundle\EzPublishLegacyBundle\EzPublishLegacyBundle` from the Composer package
`se7enxweb/legacy-bridge` (repository [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge)). For a
request that the legacy kernel should answer, it does this:

1. **Symfony matches the siteaccess** (`URIElement: 1` on every line: the first segment of the path).
2. **The bridge decides who answers.** If the siteaccess has `legacy_mode: true`, URL aliases and module URLs go to the
   legacy kernel. With `legacy_mode: false` Symfony routes first, and only URLs that no Symfony route claims fall
   through to the legacy kernel (the bridge's `FallbackRouter`).
3. **The legacy kernel is built** from `ezpublish_legacy/`. Just before that the bridge fires its pre-build event, and
   every listener adds *injected settings* (section 5.5): the bridge's own mapper puts in the database connection, the
   var and storage directories, image settings, the anonymous user and cluster settings; the project adds its own.
4. **The legacy kernel runs** its usual request: siteaccess settings, modules, TPL templates, permissions.
5. **The response goes back through Symfony**, optionally wrapped in a Twig page layout
   (`ez_publish_legacy.system.<siteaccess>.templating.module_layout` or `view_layout`).

The same build happens for console commands that need the legacy kernel (`ezpublish:legacy:script`, the cache purger
during `cache:clear`), so scripts see the same settings as web requests.

The most important consequence: **the legacy kernel has no configuration of its own for anything the bridge injects.**
The database is defined in Symfony (`parameters.yml` or `DATABASE_URL`), never in `site.ini`.

## 5.2 Which siteaccesses run the legacy kernel

| Line | Siteaccesses (from the shipped configuration) | `legacy_mode: true` | Where it is set |
|---|---|---|---|
| 2.5 | `site`, `admin`, `legacy_admin` | `legacy_admin` (`site` is set to `false`) | `ez_publish_legacy.system` in `app/config/ezplatform.yml` |
| 3.x | `fh_eng`, `site`, `bold_eng`, `bold_ger`, `adminui`, `ngadminui`, `legacy_site`, `legacy_admin` | `legacy_admin`, `legacy_site` | `config/app/packages/ezpublish_siteaccess.yaml` |
| 4.6.x, 5.x | `site`, `legacy_site`, `legacy_admin` (and `admin` for the Admin UI) | `legacy_site`, `legacy_admin` | `config/packages/ez_publish_legacy.yaml` from the recipe |

Every siteaccess must exist on **both** sides: in the Symfony siteaccess list and in the legacy kernel's
`site.ini [SiteSettings] SiteList` and `[SiteAccessSettings] AvailableSiteAccessList`. On 2.5 the legacy lists are in
`ezpublish_legacy/settings/override/site.ini.append.php`; on 3.x, 4.6.x and 5.x they are injected from YAML
(`app.legacy.injected_merge_settings`, section 5.5). When you add a siteaccess, add it in both places and create its
legacy settings directory `ezpublish_legacy/settings/siteaccess/<name>/` (on 4.6.x and 5.x under `src/`, section 5.3).

How siteaccesses work in the legacy kernel itself (matching, designs, languages, `RelatedSiteAccessList`):
[the Exponential 6 book, 10.2 Siteaccesses and site addresses](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md#102-siteaccesses-and-site-addresses).
Behind the bridge, the legacy `MatchOrder` does not route requests; Symfony's matcher does.

## 5.3 Where the legacy files live

`ezpublish_legacy/` is installed by Composer (the package `se7enxweb/exponential`) and is not committed; a
`composer install` may replace it. Your own legacy files must therefore live where Composer does not overwrite them.
Each line solves that differently.

### 5.3.1 The 2.5 line: settings committed inside ezpublish_legacy/

The 2.5 repository commits a handful of files *inside* the otherwise ignored directory:
`ezpublish_legacy/settings/override/site.ini.append.php` and the ten files in
`ezpublish_legacy/settings/siteaccess/legacy_admin/`. The Composer installer leaves existing files in place, so these
survive an install; but keep a copy of anything you add there, and prefer an extension (section 5.11) for templates
and designs.

### 5.3.2 The 3.x line: an app bundle that carries an extension

On 3.x the class `App\AppBundle` (`src/AppBundle.php`) is a Symfony bundle whose directory is `src/`. LegacyBridge's
`ezpublish:legacybundles:install_extensions` links every directory below `<bundle>/ezpublish_legacy/` into
`ezpublish_legacy/extension/`, so `src/ezpublish_legacy/app/` becomes the legacy extension `app`. It carries the
project's designs, the siteaccess settings (`settings/siteaccess/legacy_admin/`, `ngadminui/`) and global settings.
The Composer script `installIniSettings` of LegacyBridge 3 also copies the bridge's starter INI files into
`ezpublish_legacy/settings/` without overwriting existing ones.

### 5.3.3 The 4.6.x and 5.x lines: links into src/

`bin/install-legacy-links` (from the recipe, run by Composer on every install and update) replaces parts of
`ezpublish_legacy/` with relative symbolic links into `src/`:

| Link in `ezpublish_legacy/` | Points to | What lives there |
|---|---|---|
| `extension/app` | `src/ezpublish_legacy/app` | your legacy extension: designs, templates, extension settings |
| `settings/override` | `src/LegacySettings/override` | global legacy INI overrides |
| `settings/siteaccess/legacy_site`, `legacy_admin`, `ngadminui` (the slots 1.2 and 1.4 make no link for `site`) | `src/ezpublish_legacy/app/settings/siteaccess/<name>` | per-siteaccess INI files |
| `var/site/storage` | `src/LegacyRoot/var/site/storage` | uploaded files, so they survive a reinstall of the kernel |

It also links seven INI files of `legacy_admin` (`content`, `contentstructuremenu`, `dashboard`, `design`, `image`,
`override`, `toolbar`) to the same files of `ngadminui`, because a Flex recipe cannot carry symbolic links. The script
replaces existing links and **skips** a path that is a real file or directory, printing
`SKIP (real path exists, not a symlink)`. If a link is missing after an update, look for that line.

Check the links:

```bash
php bin/install-legacy-links
# Linked: ezpublish_legacy/extension/app -> ../../src/ezpublish_legacy/app
# ...
# Done: 13 link(s) created.        (6 directories and 7 INI files, in the slots 1.2 and 1.4)
find ezpublish_legacy -maxdepth 3 -type l -ls
```

Edit the files under `src/`, commit them, and never edit through the link targets in `vendor/`.

### 5.3.4 In the web root

`ezpublish:legacy:assets_install --symlink --relative <webroot>` links `design/`, `extension/`, `share/` and `var/` of
`ezpublish_legacy/` into the web root and copies the wrapper scripts `index_rest.php` and `index_cluster.php` there.
That is how legacy stylesheets, images and uploaded files become reachable by URL. It also means that `public/var`
(or `web/var`) **is** `ezpublish_legacy/var`, caches and logs included; only the rewrite rules of the web server decide
which files under it are handed out ([chapter 6](06-serving-the-site.md#62-what-the-web-root-may-hand-out)).

## 5.4 The bridge's configuration

The semantic configuration of LegacyBridge (`bundle/DependencyInjection/Configuration.php`, the same keys in releases
2.1 to 5.0):

```yaml
ez_publish_legacy:
    enabled: true                                     # false switches the bridge off entirely
    root_dir: '%kernel.project_dir%/ezpublish_legacy' # must exist; the default comes from the bundle
    clear_all_spi_cache_on_symfony_clear_cache: true  # cache:clear also clears the repository (SPI) cache
    clear_all_spi_cache_from_legacy: true             # a legacy "clear all caches" also clears the SPI cache
    legacy_aware_routes: []                           # Symfony routes allowed in legacy_mode (prefixes allowed)
    system:
        legacy_admin:                                 # any siteaccess or siteaccess group
            legacy_mode: true                         # the legacy kernel handles URL aliases and modules
            templating:
                view_layout: 'themes/standard/pagelayout.html.twig'   # Twig layout around legacy content views
                module_layout: ~                      # Twig layout around legacy module output; ~ = the legacy pagelayout
```

The 2.5 configuration uses `view_layout` for `site` (`themes/standard/pagelayout.html.twig`) and `legacy_mode` for both
`site` (`false`) and `legacy_admin` (`true`). The bridge's own [README](https://github.com/se7enxweb/LegacyBridge/blob/master/README.md) and
[INSTALL](https://github.com/se7enxweb/LegacyBridge/blob/master/INSTALL.md) are the references.

## 5.5 Injected settings

`eZINI::injectSettings()` lets code set an INI value at run time, as if it were in a file, without writing any file.
`eZINI::injectMergeSettings()` adds values to an array setting. LegacyBridge uses both before the legacy kernel builds.

### 5.5.1 What the bridge injects

From `bundle/LegacyMapper/Configuration.php`:

| Injected key | From |
|---|---|
| `site.ini [DatabaseSettings] Server`, `Port`, `User`, `Password`, `Database`, `Socket`, `DatabaseImplementation` | the Doctrine connection of the repository; the driver is mapped (`pdo_mysql` to `ezmysqli`, `pdo_pgsql` to `ezpostgresql`, `oci8` to `ezoracle`, `pdo_sqlite` to `sqlite3`); for SQLite `Database` is the file's full path |
| `site.ini [FileSettings] VarDir`, `StorageDir` | the siteaccess's `var_dir` and `storage_dir` (`var/site` in the shipped configuration) |
| `image.ini` temporary, published and versioned image directories, ImageMagick settings, `AliasSettings` and filters | the new stack's image configuration and its image variations |
| `site.ini [SiteAccessSettings] PathPrefix`, `PathPrefixExclude`, `[SiteSettings] IndexPage`, `DefaultPage` | the siteaccess's content tree root (multisite) |
| `site.ini [UserSettings] AnonymousUserID` | the new stack's `anonymous_user_id` |
| `site.ini [ContentSettings] ViewCaching=enabled` | always: the bridge needs the view cache on so that purges work |
| `file.ini [ClusteringSettings]` and `[eZDFSClusteringSettings]` | the DFS parameters (`dfs_nfs_path`, `dfs_database_*`) when they are set |

A Doctrine driver that is not in the map stops the legacy kernel with `Could not map database driver to Legacy Stack
database implementation`.

### 5.5.2 What the project injects (3.x, 4.6.x, 5.x)

From 3.x on, the project adds its own injected settings from YAML parameters, through a small subscriber to the same
pre-build event (`src/ExponentialPlatformLegacyInjectedSettings/` on 3.x, `src/EventSubscriber/LegacyInjectedSettingsSubscriber.php`
from the 4.6.x and 5.x recipe). The keys are `file.ini/Section/Setting`:

```yaml
# config/packages/ez_publish_legacy.yaml (4.6.x, 5.x) or config/app/packages/legacy.yaml (3.x)
parameters:
    app.legacy.injected_settings:                    # scalar values; replace the INI value
        'site.ini/SiteSettings/DefaultAccess': legacy_site
        'site.ini/SiteAccessSettings/CheckValidity': 'false'
        'file.ini/ClusteringSettings/FileHandler': eZFSFileHandler
    app.legacy.injected_merge_settings:              # arrays; appended to the INI value
        'site.ini/ExtensionSettings/ActiveExtensions':
            - ezjscore
            - ezoe
            - app
    app.legacy.siteaccess_injected_settings: {}      # per siteaccess; see the warning below
    app.legacy.siteaccess_injected_merge_settings: {}
```

Annotations:

- **Values are strings.** INI values are text: write `'false'`, `'1'`, `enabled`, not YAML booleans.
- **Arrays merge.** `injected_merge_settings` appends to what the INI files say; it cannot remove an entry. To replace a
  whole list, inject it with `injected_settings`.
- **Per-siteaccess injection leaks on 4.6.x and 5.x.** The recipe's own comment warns that `eZINI::injectSettings()` is
  global for the process: a value injected for one siteaccess stays for every siteaccess the same PHP process serves
  later. The recipe therefore leaves both per-siteaccess parameters empty and puts siteaccess-specific values in
  `settings/siteaccess/<name>/*.ini.append.php`. The 3.x configuration does use per-siteaccess injection (designs per
  siteaccess); with persistent workers ([chapter 6](06-serving-the-site.md)) prefer INI files there too.
- **After a change**, clear the Symfony cache (the parameters are compiled into the container) and the legacy INI
  cache: `php bin/console cache:clear` does both (section 5.10).

## 5.6 INI and YAML: which wins

| A value is set ... | ... and also ... | The legacy kernel uses |
|---|---|---|
| injected by the bridge (database, var dir, images) | in an INI file | **the injected value** |
| in `app.legacy.injected_settings` | in an INI file | **the injected value** |
| in `app.legacy.injected_merge_settings` | in an INI file as an array | **the INI array plus the injected entries** |
| only in INI files | | the usual INI override order (below) |

Between the bridge's own injections and the project's, **the project wins** for a key both set. Both are listeners to
the same pre-build event, and each puts its own array *in front of* the injected settings collected so far
(`$mine + $existing`; PHP's `+` keeps the left side's keys), so the listener that runs last wins. The bridge's mapper
listens with priority 128 and runs first; the project's subscriber (3.x bundle, 4.6.x and 5.x recipe) listens with
priority 64 and runs after it. That is what lets the 4.6.x and 5.x recipe replace the `eZDFSFileHandler` the mapper
always injects with `'file.ini/ClusteringSettings/FileHandler': eZFSFileHandler`, as its own comment explains. It also
means a careless project entry for `site.ini/DatabaseSettings/...` would override the database the new stack uses:
never inject database settings yourself.

Among the INI files the legacy kernel's normal rules apply: the shipped defaults in `settings/`, then extension
settings, then siteaccess settings, and **`settings/override/` last, so it wins over all others**. When two extensions
set the same value, the one earlier in `ActiveExtensions[]` wins. The Exponential 6 book explains the order and its
traps: [10.13 Extension management](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md#1013-extension-management).
The 5.x installation guide up to `v5.0.2` lists the order the other way round (siteaccess files as the most specific;
corrected in commit `c85428c`, released in `v5.0.3.1`); the legacy kernel's `eZINI` reads `settings/override/` last.

And YAML itself? The new stack does not read INI files. A setting that both kernels need (languages, image variations,
the var directory) is configured in YAML and reaches the legacy kernel only where the bridge injects it (section 5.5.1).
Everything else is configured twice, once per kernel; [chapter 8](08-configuration.md) lists the pairs.

To see which value the legacy kernel ends up with, use the legacy admin: *Setup*, *Ini settings* shows the effective
values per file and siteaccess. `eZINI` records injected values under the placeholder path `injected`
(`eZINI::INJECTED_PATH`), which is what you see where a value has no file.

## 5.7 Running legacy scripts through the console

Legacy scripts (`bin/php/*.php`, `extension/*/bin/php/*.php`, `runcronjobs.php`) need the database and the other
injected settings. Run them through the bridge, which builds the legacy kernel exactly as for a web request:

```bash
php bin/console [Symfony options] ezpublish:legacy:script <path relative to ezpublish_legacy/> [legacy options]
```

```bash
php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --clear-all
php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --clear-tag=template
php bin/console --env=prod ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
php bin/console --env=prod --siteaccess=legacy_admin ezpublish:legacy:script bin/php/updatesearchindex.php
php bin/console ezpublish:legacy:script bin/php/ezcache.php --legacy-help     # the script's own help
```

Annotations:

- The path is relative to the legacy root, not to the project root (`bin/php/ezcache.php`, not
  `ezpublish_legacy/bin/php/ezcache.php`).
- Everything after the script path is handed to the legacy script unchanged. The bridge's command accepts any option
  without complaint (it ignores validation errors), so a mistake there is reported by the legacy script, not by Symfony.
- `--siteaccess=<name>` sets the Symfony siteaccess; the bridge then starts the legacy kernel with the same siteaccess
  and also appends `--siteaccess=<name>` to the script's arguments, so both kernels agree.
- `--env=prod` decides which Symfony configuration (and therefore which database) the script sees.
- `--legacy-help` shows the legacy script's help; `--help` shows the Symfony command's.
- The canonical name is `exponential:legacy:script` on LegacyBridge 3, on 4 from 4.0.0.2 and on 5, with
  `ezpublish:legacy:script` as its alias; LegacyBridge 2 and 4.0.0.0 to 4.0.0.1 have only `ezpublish:legacy:script`.
  That spelling therefore works on every line.

### 5.7.1 Where Symfony's options go

Write `--env`, `--siteaccess` and `--no-debug` **before** the command name. Symfony's console finds its options
anywhere on the command line, so `--env=prod` after the script path does select the `prod` configuration; but the
bridge also passes it on to the legacy script, and what happens then depends on how that script reads its options:

| Script | `--env=prod` after the script path |
|---|---|
| `bin/php/ezcache.php`, `updatesearchindex.php` and the other scripts that read their options with `eZScript::getOptions()` | the script stops before doing anything: ``bin/php/ezcache.php: invalid option `--env'`` |
| `bin/php/ezpgenerateautoloads.php` (reads its options with `ezcConsoleInput`) | it prints that the option does not exist, then its help text, and generates nothing |
| `runcronjobs.php` | works: it reads its own few options by hand and silently skips the ones it does not know |

```text
$ php bin/console ezpublish:legacy:script bin/php/ezcache.php --clear-all --env=prod     # wrong place
Running script 'bin/php/ezcache.php' in eZ Publish legacy context
bin/php/ezcache.php: invalid option `--env'
$ php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --clear-all     # right place
Running script 'bin/php/ezcache.php' in eZ Publish legacy context
Clearing All cache:
```

The same rule holds on every line, because the bridge's command and the legacy option parser are the same in every
LegacyBridge release. A cron line that has worked for years with `--env=prod` at the end of a `runcronjobs.php` call is
therefore not proof that the same habit works for other scripts.

**Why not `php ezpublish_legacy/bin/php/ezcache.php` directly?** Started that way, the legacy kernel reads only its INI
files. It gets no injected database settings, so on a skeleton without `[DatabaseSettings]` in its INI files it cannot
connect, or connects to a different database than the site uses if old values are still there. The guides of the
tags up to `v2.5.0.3`, `v3.3.44.7` and `v4.6.23.2` show direct calls in a few places (`runcronjobs.php`, `ezcli.php`;
the branch guides run the cronjobs through the bridge since 5 October 2026, and so do those of `v3.3.44.8`,
`v4.6.23.3` and `v5.0.3.1`); prefer the bridge in every case. The legacy
scripts themselves, their options and what they do: [the Exponential 6 book, chapter 10](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md).

Run the console as the site's user, not as root: files the scripts create (caches, logs, generated images) must
belong to the user the web server or Velocity's workers run as, or the site cannot rewrite them later.

## 5.8 Legacy cronjobs

Legacy cronjobs (`runcronjobs.php` with its parts: the default part, `frequent`, `infrequent` and those extensions add)
keep the search index, notifications, workflows and clean-up going. Run them through the bridge:

```cron
# as the site's user; adjust paths and the PHP binary
*/5 * * * *  cd /var/www/my_project && php bin/console --env=prod --siteaccess=legacy_admin ezpublish:legacy:script runcronjobs.php >> var/log/cron-legacy.log 2>&1
*/1 * * * *  cd /var/www/my_project && php bin/console --env=prod --siteaccess=legacy_admin ezpublish:legacy:script runcronjobs.php frequent >> var/log/cron-legacy.log 2>&1
```

The options stand before the command name, as section 5.7.1 recommends. `runcronjobs.php` would tolerate them at the
end, but keeping one habit for every legacy script avoids the case where a copied line breaks another script. Write the
output to a log rather than to `/dev/null`: a cronjob that fails every five minutes is otherwise invisible. The log
directory is `var/logs/` on 2.5 and `var/log/` from 3.x on.

The new stack has its own scheduler (`ezplatform:cron:run` on 2.5, from `se7enxweb/ezplatform-cron`; on the other lines
`php bin/console list cron` shows its name);
schedule both. Which legacy parts exist, how long they run and how to keep them from overlapping:
[the Exponential 6 book, 10.3 Cronjobs](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md#103-cronjobs).
The full schedule for both kernels is in [chapter 9](09-operations.md).

> **Not verified for this book:** running `runcronjobs.php` through `ezpublish:legacy:script` was checked against the
> source of the bridge's command (it includes any script relative to the legacy root and passes the options on) and of
> `runcronjobs.php` in the kernel releases the lines install (it reads `-s`/`--siteaccess <name>`, `--debug`, `--quiet`
> and a few others by hand and skips unknown options), not run on a live installation of each line. If a part
> misbehaves, run it once by hand with `--debug` at the end of the line and read `ezpublish_legacy/var/site/log/`:
>
> ```bash
> php bin/console --env=prod --siteaccess=legacy_admin ezpublish:legacy:script runcronjobs.php frequent --debug
> ```

## 5.9 Autoloads

The legacy kernel finds its classes through generated autoload arrays (`ezpublish_legacy/autoload/` and
`ezpublish_legacy/var/autoload/`). Regenerate them whenever an extension is added, removed, renamed or gains classes:

```bash
php bin/console --env=prod ezpublish:legacy:script bin/php/ezpgenerateautoloads.php          # extensions (the default)
```

The Composer scripts of every line run this after each `composer install` and `update`. A class that "is not found"
right after adding an extension almost always means this step was skipped. The details of the autoload generator
(`-e`, `-k`, `.autoloadignore`): [the Exponential 6 book, 10.7 Class autoloads](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md#107-class-autoloads).

## 5.10 Legacy caches

The legacy kernel keeps its caches below its var directory, `ezpublish_legacy/var/site/cache/` with the shipped
`var_dir: var/site`. What clears what:

| Command | Clears |
|---|---|
| `php bin/console cache:clear` | the Symfony cache (`var/cache/<env>/`); through LegacyBridge's `LegacyCachePurger` also the legacy **template, INI and i18n** caches; with `clear_all_spi_cache_on_symfony_clear_cache` the repository cache |
| `php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --clear-all` | every legacy cache: the content view cache, template blocks, compiled templates, INI and translation caches and the rest (`--list-ids` names them) |
| `... ezcache.php --clear-tag=content` / `--clear-id=<id>` | one group or one cache |
| `... ezcache.php --list-tags` / `--list-ids` | what exists |
| the legacy admin, *Setup*, *Caches* | the same as `ezcache.php`, from the browser |

After a deploy, clear both, Symfony first. After a change to `.tpl` files in production, `--clear-tag=template` and
`--clear-id=content` are usually enough. If a page still shows the old output, remember the HTTP cache in front of
both (Symfony's HTTP cache in `prod`, or Varnish): [chapter 9](09-operations.md). The legacy caches themselves are
described in [the Exponential 6 book, 10.6 Caches](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md#106-caches).

## 5.11 Legacy extensions

A legacy extension is a directory in `ezpublish_legacy/extension/` that the legacy kernel loads when it is listed in
`site.ini [ExtensionSettings] ActiveExtensions[]`. Three ways to add one, best first:

| Way | How | Survives `composer install` |
|---|---|---|
| A Composer package of type `ezpublish-legacy-extension` | `composer require <vendor>/<extension>`; the legacy installer plugin places it in `ezpublish_legacy/extension/` | yes |
| Inside a Symfony bundle, in `<bundle>/ezpublish_legacy/<name>/` | `ezpublish:legacybundles:install_extensions --relative` links it (this is how `src/ezpublish_legacy/app` becomes `app` on 3.x) | yes |
| Copied by hand into `ezpublish_legacy/extension/` | only for a test | **no** |

Then activate it. On 2.5 add it to `ezpublish_legacy/settings/override/site.ini.append.php`; on 3.x and later add it to
`app.legacy.injected_merge_settings` under `'site.ini/ExtensionSettings/ActiveExtensions'` (section 5.5.2), or to the
override file in `src/LegacySettings/override/` (4.6.x, 5.x). Finally regenerate the autoloads (section 5.9) and clear
the caches (section 5.10).

The opposite mistake is as common: an extension listed in `ActiveExtensions[]` that is not installed. The legacy
kernel skips it without an error page, but its settings, templates and search engine are missing, and the debug output
names it. The 3.x configuration had exactly this with `ezplatformsearch`, which the line does not install; the branch
removed it from `config/app/packages/legacy.yaml` and from the legacy override file (commit `5ace002`, released in
`v3.3.44.8`). On a project created from `v3.3.44.7`, remove the entry yourself, or install `netgen/ezplatformsearch`
if you want the legacy search to use the platform's engine ([chapter 9](09-operations.md#94-search)). To find such an
entry, compare what is installed (`ls ezpublish_legacy/extension/`) with what is active (*Setup*, *Extensions* in the
legacy admin, or *Setup*, *Ini settings* for `site.ini [ExtensionSettings] ActiveExtensions`).

```bash
composer require se7enxweb/<extension>                                  # example
$EDITOR config/packages/ez_publish_legacy.yaml                          # add it to ActiveExtensions
php bin/console --env=prod ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
php bin/console --env=prod cache:clear
php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --clear-all
```

If the extension brings database tables, install them as its documentation says. Which extensions exist, their order
and the traps of ordering: [the Exponential 6 book, 10.13](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md#1013-extension-management).

## 5.12 The legacy admin

The legacy admin is the siteaccess `legacy_admin`, reached at `/legacy_admin/` on every line. It runs entirely in the
legacy kernel (`legacy_mode: true`) with the design chain set in its siteaccess settings: `admin3`, `admin2`, `admin`,
`standard`, `base` on 2.5 (`ezpublish_legacy/settings/siteaccess/legacy_admin/site.ini.append.php`), `admin3`,
`admin2`, `admin`, `standard` on 3.x (injected per siteaccess from `config/app/packages/legacy.yaml`). It requires a login (`RequireUserLogin=true`) and opens the dashboard
(`DefaultPage=content/dashboard`).

What it is for, compared with the Admin UI:

| Task | Legacy admin | Admin UI |
|---|---|---|
| Edit content, move, translate | yes | yes |
| Content classes with legacy datatypes, class groups | yes | content types of the new stack |
| Roles and policies of legacy modules | yes | the new stack's policies |
| Workflows, triggers, collaboration, the webshop | yes | no |
| INI settings, caches, system information, extensions | yes (*Setup*) | partly (system information) |
| Netgen Layouts (4.6.x, 5.x) | no | yes |

Both write the same tables; there is nothing to synchronise. Keep in mind that a content type created in one
interface uses that kernel's field types: a field type without a matching legacy datatype (or the reverse)
cannot be edited, and may not display, on the other side. [Chapter 8](08-configuration.md) covers the mapping.

## 5.13 References

In this repository:

- [app/config/ezplatform.yml](../../app/config/ezplatform.yml) (siteaccesses, `ez_publish_legacy`) and
  [ezpublish_legacy/settings/](../../ezpublish_legacy/settings/) of the 2.5 line
- On 3.x: [config/app/packages/legacy.yaml](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/config/app/packages/legacy.yaml),
  [config/app/packages/ezpublish_siteaccess.yaml](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/config/app/packages/ezpublish_siteaccess.yaml),
  [the injected settings bundle](https://github.com/se7enxweb/exponential-platform-legacy/tree/3.x/src/ExponentialPlatformLegacyInjectedSettings)
- 4.6.x and 5.x recipe: [bin/install-legacy-links](https://github.com/se7enxweb/sevenx-recipes/blob/master/se7enxweb/exponential-platform-dxp/1.4/bin/install-legacy-links),
  [config/packages/ez_publish_legacy.yaml](https://github.com/se7enxweb/sevenx-recipes/blob/master/se7enxweb/exponential-platform-dxp/1.4/config/packages/ez_publish_legacy.yaml)

External:

- LegacyBridge: [repository](https://github.com/se7enxweb/LegacyBridge),
  [configuration tree](https://github.com/se7enxweb/LegacyBridge/blob/master/bundle/DependencyInjection/Configuration.php),
  [LegacyMapper](https://github.com/se7enxweb/LegacyBridge/blob/master/bundle/LegacyMapper/Configuration.php),
  [commands](https://github.com/se7enxweb/LegacyBridge/tree/master/bundle/Command)
- The Exponential 6 book: [10. After installing](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md)
  (siteaccesses, cronjobs, caches, autoloads, extensions),
  [15. Migrating from the 5.x legacy stack](https://github.com/se7enxweb/exponential/blob/main/doc/install/15-migrating-from-5x-legacy.md)
  (the same bridge architecture seen from the other side)
- Upstream concepts: [siteaccess matching](https://doc.ibexa.co/en/latest/multisite/siteaccess/siteaccess_matching/),
  [repository configuration](https://doc.ibexa.co/en/latest/administration/configuration/repository_configuration/)
- Symfony: [the console](https://symfony.com/doc/current/console.html), [cache clearers](https://symfony.com/doc/current/reference/dic_tags.html#kernel-cache-clearer)

[Previous: 4. Installing](04-installing.md) · [Next: 6. Serving the site](06-serving-the-site.md) · [Contents](README.md)
