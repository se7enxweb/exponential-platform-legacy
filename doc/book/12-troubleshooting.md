# 12. Troubleshooting

This chapter is organised by symptom. Each entry names the cause, as found in the code of this repository, the bridge
or the kernels, and the fix. Most problems of a hybrid installation have one of five causes: the wrong version was
installed, a command was run on one side only, a legacy script was started without the bridge, the two
configurations disagree, or a table one kernel needs is missing. Start with [12.1](#121-start-here); it finds the
side that fails before you start changing things.

[Previous: 11. Migrating into Exponential Platform Legacy](11-migrating-into.md) ·
[Next: 13. Security hardening](13-security-hardening.md) · [Contents](README.md)

## Contents of this chapter

- [12.1 Start here](#121-start-here)
- [12.2 Getting the code](#122-getting-the-code)
- [12.3 Console commands](#123-console-commands)
- [12.4 Database](#124-database)
- [12.5 Pages, admin and templates](#125-pages-admin-and-templates)
- [12.6 Images](#126-images)
- [12.7 Caches and changes that do not show](#127-caches-and-changes-that-do-not-show)
- [12.8 Cron and search](#128-cron-and-search)
- [12.9 Upgrades](#129-upgrades)
- [12.10 Getting help](#1210-getting-help)
- [References](#references)

## 12.1 Start here

1. **Which side fails?** A Symfony error page or an entry in the Symfony log points to the platform; a page with the
   legacy design but missing parts, or an entry in `ezpublish_legacy/var/log/error.log` or
   `ezpublish_legacy/var/site/log/`, to the legacy kernel. The legacy admin (`/legacy_admin/` on 2.5, 4.6 and 5)
   runs entirely in the legacy kernel; the platform admin (`/admin/` on 2.5, 4.6 and 5) entirely in Symfony.
2. **Read the logs** ([9.6](09-operations.md#96-logs)). On 2.5 the production log writes only when a `critical`
   entry occurs (`fingers_crossed`), so an empty `var/logs/prod.log` does not mean there was no error; read the
   PHP-FPM log and the legacy logs too.
3. **Reproduce on the console** with the same environment: `php bin/console --env=prod debug:config ez_publish_legacy`,
   `php bin/console --env=prod debug:container --parameter=kernel.secret` (to see that the container builds at all).
4. **Check the versions** ([10.2](10-upgrading-between-lines.md#102-which-line-do-you-run)) before searching for a bug.

## 12.2 Getting the code

| Symptom | Cause | Fix |
|---|---|---|
| `composer create-project se7enxweb/exponential-platform-legacy my-site` gives a project with `app/`, `web/` and Symfony 3.4 although you wanted the 5 line | the newest stable tag, `v5.0.3`, points to a `master` commit with the 2.5 line's `composer.json` ([10.1](10-upgrading-between-lines.md#101-the-release-lines)) | always give the version: `:5.x-dev`, `:v5.0.2`, `:4.6.x-dev`, `:3.x-dev`, `:v2.5.0.3` or `:dev-master` |
| `Could not find package se7enxweb/exponential-platform-legacy with version 2.5.0.x-dev` | older guides use `2.5.0.x-dev`; Packagist has `dev-master` (aliased `2.5.x-dev`), `2.5.0.0-dev` to `2.5.0.3-dev` and the tags | use `:dev-master`, `:2.5.x-dev` or `:v2.5.0.3` |
| Composer refuses the platform (PHP version, extension) | the line's `php` constraint ([10.1](10-upgrading-between-lines.md#101-the-release-lines)); on 5 the bridge needs PHP 8.4 although the skeleton says `>=8.3` | run the PHP version the line needs; use `--ignore-platform-reqs` only for a requirement you have checked |
| The legacy directory `ezpublish_legacy/` is empty or missing | Composer plugins disabled, so `se7enxweb/exponential-legacy-installer` did not run | allow the plugin (`config.allow-plugins` lists it in every line's `composer.json`) and run `composer install` again |
| 4.6 or 5: `ezpublish_legacy/extension/app` or `settings/override` missing | `bin/install-legacy-links` did not run (Flex cannot ship symlinks) | `php bin/install-legacy-links`; it is safe to run again |

## 12.3 Console commands

| Symptom | Cause | Fix |
|---|---|---|
| `Command "ezpublish:legacy:clear-cache" is not defined` (or `ezpublish:legacy:generate-autoloads`) | these commands do not exist on any line; older guides of this repository name them | caches: `bin/console ezpublish:legacy:script bin/php/ezcache.php --clear-all` (3.x and later `exponential:legacy:script`); autoloads: `bin/php/ezpgenerateautoloads.php` ([9.1](09-operations.md#91-caches-on-both-sides)) |
| `Command "ezplatform:solr:create-core" is not defined` | no such command on 2.5 | create the core with Solr's tools from the bundle's `bin/generate-solr-config.sh` ([9.4](09-operations.md#94-search)) |
| `Command "doctrine:migration:migrate" is not defined` on 2.5 | the 2.5 line has no Doctrine migrations bundle | nothing to migrate; skip the step |
| `fos:httpcache:invalidate:path / --all`: `The "--all" option does not exist` | the command takes paths only | purge all with `fos:httpcache:invalidate:tag ez-all` ([9.1](09-operations.md#91-caches-on-both-sides)) |
| `exponential:install` not defined on 3.x | kernel older than v1.3.45 | `ibexa:install exponential-oss`, or update the kernel |
| A legacy script stops with ``<script>: invalid option `--env'`` | Symfony's option was placed after the script path and handed to the legacy script | put `--env` and `--siteaccess` before the command name ([conventions of chapter 9](09-operations.md#conventions-in-this-chapter)) |
| 4.6: `There are no commands defined in the "exponential:legacy" namespace` | the project is locked to bridge `v4.0.0.0` or `v4.0.0.1`, which have only the `ezpublish:*` names | use `ezpublish:legacy:script` and the other old names, which every release has, or `composer update se7enxweb/legacy-bridge` ([conventions of chapter 9](09-operations.md#conventions-in-this-chapter)) |

## 12.4 Database

| Symptom | Cause | Fix |
|---|---|---|
| `Could not map database driver to Legacy Stack database implementation. Expected one of 'pdo_mysql', 'pdo_pgsql', 'oci8', 'pdo_sqlite', got '...'` | the Doctrine driver is not one of the four the bridge maps | use one of them ([7.2](07-databases.md#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)) |
| Legacy cron or a legacy script fails to connect, or connects to the wrong database, while the site works | the script was started directly (`php ezpublish_legacy/runcronjobs.php`), so it never got the injected connection | run it through the bridge ([9.2](09-operations.md#92-cron-on-both-sides)) |
| Changing `[DatabaseSettings]` in a legacy INI file has no effect | injected settings beat INI files | change the platform's connection ([7.3](07-databases.md#73-writing-the-connection-line-by-line)) |
| Legacy SQL errors such as `Table '...ezbasket' doesn't exist`, `...ezworkflow...`, `...ezcollab_item...` on a fresh 3.x (PostgreSQL), 4.6 or migrated install | the platform installer did not create the legacy-only tables | create the missing ones from `ezpublish_legacy/kernel/sql/<engine>/` ([7.8](07-databases.md#78-which-tables-the-installer-creates)) |
| 5: legacy kernel errors with `table not found` / `Unknown column` on its first query | the translator extension is not active or not first in `ActiveExtensions[]` | add `sevenx_exponential_platform_v5_database_translator` as the first entry ([10.6](10-upgrading-between-lines.md#106-from-33-to-46-and-from-46-to-5)) |
| PostgreSQL: legacy pages fail with `function digest(text, unknown) does not exist`; the platform side works | the `pgcrypto` extension is missing; the legacy driver needs it and no platform installer creates it | `CREATE EXTENSION IF NOT EXISTS pgcrypto;` in the site's database ([7.5](07-databases.md#75-postgresql)) |
| PostgreSQL: `relation "..._id_seq" does not exist`, or `duplicate key value violates unique constraint ..._pkey` on insert | the sequences still have the 5.x names (`<table>_s`), or stand behind the highest id after an import | apply the current 6.0 update files, which rename them; move a sequence on with `setval` ([7.5](07-databases.md#75-postgresql)) |
| Moving content to the trash fails with `Unknown column 'trashed'` | a database from 5.x that never got `ezcontentobject_trash.trashed` | the current legacy 6.0 update files add it where missing ([10.7](10-upgrading-between-lines.md#107-the-legacy-kernel-inside-every-line)) |
| Users can sign in once after a migration, then never again | `ezuser.password_hash` is still `varchar(50)`, and the bcrypt hash written at the first sign-in is cut | widen it to 255 (the current 6.0 update files do); affected users reset their password |
| SQLite: `attempt to write a readonly database` | the web server user cannot write the file or its directory | owner and mode on both ([7.6](07-databases.md#76-sqlite)) |
| SQLite: `database is locked` under concurrent editing | two writers; the Symfony side has no write queueing | MySQL/MariaDB or PostgreSQL for multi-user sites ([7.6](07-databases.md#76-sqlite)) |
| SQLite: the database file changes when you change the environment | `database_path` / the URL contain `%kernel.environment%` (`data_dev.db`, `data_prod.db`) | run console commands with the same `--env` as the web server, or set a fixed path |

## 12.5 Pages, admin and templates

| Symptom | Cause | Fix |
|---|---|---|
| `/ezpublish_legacy/` gives 404 | older guides give it as the legacy admin; no configuration matches that path | `/legacy_admin/` with `URIElement` matching, or your host map ([8.5](08-configuration.md#85-siteaccesses-and-legacy_mode)) |
| A legacy siteaccess renders with Symfony instead of legacy, or the legacy admin redirects to the Symfony login | `legacy_mode` not set for that siteaccess | `ez_publish_legacy.system.<siteaccess>.legacy_mode: true` |
| Legacy `user/login` is refused on the public siteaccess | the bridge disables legacy `user/login` and `user/logout` without `legacy_mode` | sign in through Symfony's `/login` there; that is intended |
| A legacy siteaccess shows the default design / wrong settings | no `ezpublish_legacy/settings/siteaccess/<name>/` for the Symfony siteaccess name, or the name missing from `SiteList[]` / `AvailableSiteAccessList[]` | create the directory, list the name ([8.5](08-configuration.md#85-siteaccesses-and-legacy_mode)) |
| A content type is rendered with the legacy TPL template inside the Twig page layout | no Twig `content_view` rule matches, the bridge's legacy view provider took over | add a `content_view` rule, or accept the fallback; it is how the hybrid works ([8.5](08-configuration.md#85-siteaccesses-and-legacy_mode)) |
| Legacy designs' CSS and images give 404 | `web/design`, `web/extension`, `web/share`, `web/var` (`public/...`) are not links to `ezpublish_legacy/` | `bin/console ezpublish:legacy:assets_install --symlink --relative web` (3.x and later `exponential:legacy:assets-install ... public`) |
| `assets_install` prints `Skipping: The folder ".../var" already exists and seems to contain content!` | a real directory is in the way of the link | move its content into `ezpublish_legacy/var/`, then run again (or with `--force` if it is empty) |
| 3.x: legacy search fails or the legacy debug output complains about the extension `ezplatformsearch` | releases up to `v3.3.44.7` list it in the injected `ActiveExtensions` and the legacy override, but the branch does not require `netgen/ezplatformsearch` (removed on the branch in `5ace002`) | remove both entries, or install the package ([9.4](09-operations.md#94-search)) |
| Every page on 2.5 shows the Symfony debug toolbar, stack traces, or is slow | the `web/.htaccess` of releases `v2.5.0.1` to `v2.5.0.3` (and `v5.0.3`) sends all requests to `app_dev.php` (corrected on `master` in `fa091cd`) | route to `app.php` ([13.2](13-security-hardening.md#132-what-the-web-server-must-never-hand-out)) |
| 3.x, 4.6 or 5: the site runs in `dev` although `.env.local` says `APP_ENV=prod` | `public/.htaccess` sets `APP_ENV=dev` with `SetEnvIf`, and a server variable beats `.env.local` (3.x releases up to `v3.3.44.7`, corrected in `66f13e1`; the 4.6 and 5 recipes still write it) | comment the `SetEnvIf ... APP_ENV=dev` line out ([13.4](13-security-hardening.md#134-debug-output-and-error-display)) |
| 2.5: `app_dev.php` answers `You are not allowed to access this file` | from `d924ceb` on it refuses every client that is not local, and any request with `X-Forwarded-For` | use it on the machine itself, or set `SYMFONY_DEV_ALLOW_REMOTE=1` on a development server (never in production) |
| Behind a TLS proxy, links and redirects use `http://` | trusted proxies not configured on one of the two sides | [13.9](13-security-hardening.md#139-behind-a-proxy-trusted-proxies-on-both-sides) |

## 12.6 Images

| Symptom | Cause | Fix |
|---|---|---|
| Legacy templates show no image for an alias that exists in the legacy `image.ini` | the bridge injects `AliasList[]` from the YAML variations | declare the alias as an `image_variations` entry ([8.7](08-configuration.md#87-image-variations-and-image-aliases)) |
| 4.6: an error from `LegacyMapper\Configuration::getImageSettings()` while the legacy kernel builds (also during `cache:clear`) | the built-in variations `original`/`reference` are null in the 4.6 kernel's defaults | add them with `reference: ~` and empty `filters` as the 4.6 recipe's `ibexa.yaml` does |
| 5: `You have requested a non-existent parameter "ibexa.site_access.config.default.imagemagick.pre_parameters"` | the bridge reads it, no 5.x parser defines it (the 4.6 kernel still does) | declare it and `post_parameters` as empty parameters, as the 5 recipe's `ez_publish_legacy.yaml` does ([8.7](08-configuration.md#87-image-variations-and-image-aliases)) |
| A changed variation still shows the old size | generated files are kept | `liip:imagine:cache:remove --filter=<name>` and the legacy `--clear-id=imagealias` ([9.5](09-operations.md#95-images)) |

## 12.7 Caches and changes that do not show

| Symptom | Cause | Fix |
|---|---|---|
| A legacy template change does not show after `cache:clear` | `cache:clear` clears only the legacy template, INI and i18n caches; the content view and template-block caches stay | `$LS bin/php/ezcache.php --clear-id=content,template-block` ([9.1](09-operations.md#91-caches-on-both-sides)) |
| A changed YAML value the bridge injects (variation, var_dir, connection) has no effect in legacy | the legacy INI cache holds the old merged settings | `cache:clear`, which also clears the legacy INI cache |
| The site answers 500 after a `cache:clear` | it ran as root; the web server cannot replace root's cache files | fix the owner of `var/cache/`, clear again as the site user |
| `cache:clear` leaves the legacy settings unmapped | `ezpublish_legacy/var/autoload/ezp_extension.php` missing; the bridge then treats the site as not installed and switches its configuration mapper off | regenerate the legacy autoloads first |
| A page changed but visitors see the old one | the HTTP cache (AppCache or Varnish) kept it | `fos:httpcache:invalidate:tag ez-all`, check that purge type and purge server are set ([9.8](09-operations.md#98-performance)) |

## 12.8 Cron and search

| Symptom | Cause | Fix |
|---|---|---|
| Notifications, workflows, delayed indexing never happen | the legacy cronjobs do not run, or run directly without the database | crontab through the bridge with all parts ([9.2](09-operations.md#92-cron-on-both-sides)) |
| `ezplatform:cron:run` / `ibexa:cron:run` runs but does nothing | no cron job is registered in the shipped packages | expected ([9.2](09-operations.md#92-cron-on-both-sides)) |
| Legacy search finds different results than the platform's | legacy uses its own `ezsearch` engine (4.6, 5, or 2.5 without `ezplatformsearch`) | reindex both, or let legacy use the platform's engine with `ezplatformsearch` ([9.4](09-operations.md#94-search)) |

## 12.9 Upgrades

| Symptom | Cause | Fix |
|---|---|---|
| After the 2.5 to 3.0 SQL, legacy update files report success but change nothing | the 3.0 file deleted the `ezpublish-version` row | insert it back ([7.9](07-databases.md#79-the-version-rows-in-ezsite_data)) |
| `Duplicate column name 'is_thumbnail'` | the 2.5 to 3.0 file ran before | skip it; the step is done |
| `Duplicate column name` from the legacy 6.0.0 to 6.0.15 file | it ran before (it is not written to run twice) | apply only the statements whose objects are missing ([10.7](10-upgrading-between-lines.md#107-the-legacy-kernel-inside-every-line)) |
| A MySQL update file stops on its first line with `Unknown system variable 'storage_engine'` | an old copy of the file; MySQL 5.7.5 and MariaDB 12.0 removed that variable | take the current files of `se7enxweb/exponential`, which say `SET default_storage_engine` ([11.3](11-migrating-into.md#113-from-ez-publish-3x-and-4x)) |
| 4.6: the legacy 6.0.0 to 6.0.15 file stops with `Table '...ezpdf_export' doesn't exist` | the legacy-only tables were never created on this line | create them first ([7.8](07-databases.md#78-which-tables-the-installer-creates)), then run the file |
| `ezpublish-version` says `7.5.7` although the legacy kernel is 6.0.x | on 2.5 the platform kernel's update files write the same row | apply the legacy file last, read versions from Composer ([7.9](07-databases.md#79-the-version-rows-in-ezsite_data)) |

## 12.10 Getting help

Collect: the line and versions ([10.2](10-upgrading-between-lines.md#102-which-line-do-you-run)), the PHP version,
the database and its version, the exact command or URL, the last lines of the Symfony log, of
`ezpublish_legacy/var/log/error.log` and of the PHP-FPM log. Report bugs on the
[issue tracker](https://github.com/se7enxweb/exponential-platform-legacy/issues), ask in
[Discussions](https://github.com/se7enxweb/exponential-platform-legacy/discussions), and report security issues as
[`SECURITY.md`](../../SECURITY.md) says, not in public. Remove passwords, secrets and personal data from what you
post.

## References

The bridge: [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`) (`bundle/LegacyMapper/Configuration.php`,
`bundle/Cache/LegacyCachePurger.php`, `bundle/Command/LegacyWrapperInstallCommand.php`); in this repository
[`web/.htaccess`](../../web/.htaccess), [`app/config/config_prod.yml`](../../app/config/config_prod.yml); the recipes in
[se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes).

The Exponential 6 book: [chapter 12, troubleshooting](https://github.com/se7enxweb/exponential/blob/main/doc/install/12-troubleshooting.md)
for the legacy kernel's own symptoms (permissions, debug output, databases, signing in).

External: Symfony [logging](https://symfony.com/doc/current/logging.html),
[Composer troubleshooting](https://getcomposer.org/doc/articles/troubleshooting.md).

[Previous: 11. Migrating into Exponential Platform Legacy](11-migrating-into.md) ·
[Next: 13. Security hardening](13-security-hardening.md) · [Contents](README.md)
