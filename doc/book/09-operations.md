# 9. Operations

Running an Exponential Platform Legacy site means running two kernels that share a database, a storage directory
and, partly, their caches. Most operational mistakes in this distribution come from treating one side as the whole
site: clearing Symfony's cache and expecting legacy templates to change, running a legacy cron script that cannot see
the database, backing up the database without the image storage. This chapter is the handbook for the daily and
weekly work: caches on both sides and the order to clear them in, cron on both sides, background workers, search,
images, logs, backups, performance and deploying a change, with the command for each release line.

[Previous: 8. Configuration: YAML and INI](08-configuration.md) ·
[Next: 10. Upgrading between release lines](10-upgrading-between-lines.md) · [Contents](README.md)

## Contents of this chapter

- [Conventions in this chapter](#conventions-in-this-chapter)
- [9.1 Caches on both sides](#91-caches-on-both-sides)
- [9.2 Cron on both sides](#92-cron-on-both-sides)
- [9.3 Background workers (Symfony Messenger)](#93-background-workers-symfony-messenger)
- [9.4 Search](#94-search)
- [9.5 Images](#95-images)
- [9.6 Logs](#96-logs)
- [9.7 Backups and restore](#97-backups-and-restore)
- [9.8 Performance](#98-performance)
- [9.9 Deploying a change](#99-deploying-a-change)
- [References](#references)

## Conventions in this chapter

Commands run in the project root as the user the web server runs PHP as (never as root, or root-owned cache files
appear that the web server cannot replace). `bin/console` is Symfony's console on every line. Where the name of a
bridge command differs per line, both are given:

| What | 2.5 line (master) | 3.x, 4.6, 5.x |
|---|---|---|
| Run a legacy script through the bridge | `ezpublish:legacy:script` | `exponential:legacy:script` (old name kept as alias) |
| Link legacy extensions of bundles | `ezpublish:legacybundles:install_extensions` | `exponential:legacy:install-extensions` |
| Link legacy assets into the web root | `ezpublish:legacy:assets_install` | `exponential:legacy:assets-install` |
| Platform install, reindex | `ezplatform:install`, `ezplatform:reindex` | `exponential:install`, `exponential:reindex` (3.x from kernel v1.3.45; `ibexa:*` before) |
| Platform cron | `ezplatform:cron:run` | `ibexa:cron:run` (`ezplatform:cron:run` is an alias on 3.x and 4.6) |

The old bridge names (`ezpublish:legacy:script` and the rest) work on **every** line and every bridge release, so
scripts that must run on more than one line, and the Composer scripts of the 5 line, use them. The new names exist
from bridge `v3.0.0.30` on 3.x (so in every release the line's `^3.0.0.35` allows), from `v4.0.0.2` on 4.6 (a 4.6 project still locked to bridge `v4.0.0.0` or
`v4.0.0.1` knows only the old ones) and in every 5.x release. `php bin/console list exponential` shows which you
have.

There are **no** `ezpublish:legacy:clear-cache` or `ezpublish:legacy:generate-autoloads` commands on any line,
although older documents of this repository use them; the bridge registers exactly six commands (`init`,
`configure`, `install-extensions`, `symlink`, `assets-install`, `script`).

Shell variables used below: `LS` is the bridge's script command for your line, for example
`LS="php bin/console --env=prod ezpublish:legacy:script"` on 2.5 and
`LS="php bin/console --env=prod exponential:legacy:script"` later.

Put Symfony's own options (`--env`, `--siteaccess`) **before** the command name. Everything after the script path is
handed to the legacy script unchanged (the bridge strips the arguments up to the script path and passes the rest on),
and a legacy script does not know `--env`. The bridge adds `--siteaccess=<name>` to the legacy script's arguments
itself when you give it to Symfony.

## 9.1 Caches on both sides

Chapter 5 lists the legacy caches and what clears them ([5.10](05-the-legacy-kernel-inside.md#510-legacy-caches)); the table below
adds the Symfony side and the HTTP cache.

| Cache | Where | Cleared by |
|---|---|---|
| Symfony container, routes, Twig | `var/cache/<env>/` | `bin/console cache:clear` |
| Platform persistence (SPI) cache | the `cache_pool` (filesystem by default; Redis or Memcached when configured) | `cache:clear` (bridge default `clear_all_spi_cache_on_symfony_clear_cache: true`), and every legacy content cache clear (`clear_all_spi_cache_from_legacy: true`) |
| HTTP cache | Symfony's reverse proxy (`var/cache/<env>/http_cache/`) or Varnish | content changes purge it; by hand `fos:httpcache:invalidate:path` / `:tag` |
| Legacy template, INI and translation caches | `ezpublish_legacy/var/cache/`, `ezpublish_legacy/var/site/cache/` | `cache:clear` (the bridge's `LegacyCachePurger` clears the tags `template,ini,i18n`), or `$LS bin/php/ezcache.php --clear-tag=template` etc. |
| Legacy content view cache, template blocks, images, ... | `ezpublish_legacy/var/site/cache/` | `$LS bin/php/ezcache.php --clear-id=content`, `--clear-all` |

**Why `cache:clear` is not enough.** The bridge's cache clearer handles only the legacy template, INI and i18n caches.
The legacy content view cache and template-block cache stay, so a legacy page can keep showing old output after a
deploy until those are cleared too.

**Why the legacy clear must go through the bridge.** `ezcache.php` started directly (`cd ezpublish_legacy && php
bin/php/ezcache.php ...`) runs without the injected database settings and fails on every cache that needs the
database, and its content clear does not reach the platform's persistence cache, because the bridge attaches that
purger only when it builds the kernel ([8.2](08-configuration.md#82-what-the-bridge-injects)).

A full clear, in the right order:

```bash
php bin/console cache:clear --env=prod
$LS bin/php/ezcache.php --clear-all
php bin/console fos:httpcache:invalidate:tag ez-all --env=prod   # only when Varnish or another proxy caches pages
```

Expected output of the second command starts with `Running script 'bin/php/ezcache.php' in eZ Publish legacy
context` (the bridge's own message, unchanged since upstream), followed by the legacy script's own output for each
cache it clears.

The third command purges every page from an external proxy: each response the platform caches carries the tag
`ez-all` (`TagHandler` of `ezplatform-http-cache` on 2.5, `ContentTagInterface::ALL_TAG` in `ibexa/http-cache` on 4.6),
so invalidating that tag empties the cache. `fos:httpcache:invalidate:path` takes a list of paths and has no `--all`
option, although older documents of this repository show one. Run `php bin/console list fos` to see which purge
commands your configuration registers.

What can go wrong:

- `cache:clear` as root, then the site answers 500: the new `var/cache/prod/` belongs to root. Fix the owner
  (`chown -R <site user> var/cache`) and clear again as the site user.
- `cache:clear` fails while building the legacy kernel ("Could not map database driver ..."): the Doctrine driver is
  not one of `pdo_mysql`, `pdo_pgsql`, `pdo_sqlite`, `oci8` ([7.2](07-databases.md#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)).
- If `ezpublish_legacy/var/autoload/ezp_extension.php` is missing, the bridge switches its configuration mapper off
  for the cache clear (it assumes an uninstalled site); regenerate the legacy autoloads first (below).

**Legacy autoloads** are not a cache but behave like one: after adding, removing or renaming a legacy extension or
class, regenerate them. The script does not need the database, so it may run directly:

```bash
(cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php --extension)    # what master's README uses
$LS bin/php/ezpgenerateautoloads.php                                          # what composer runs on 3.x and later
```

**Application cache pools.** On 2.5 the pool is chosen with the environment variable `CACHE_POOL`
(`cache.tagaware.filesystem` by default; `cache.redis` and `cache.memcached` load `app/config/cache_pool/<pool>.yml`,
with `CACHE_DSN` and `CACHE_NAMESPACE`); on 3.x and later the same names are used from `.env` and
`config/packages/cache_pool/`. Clear a single pool with `bin/console cache:pool:clear <pool>`.

From Exponential 6.0.15 the legacy kernel also has `bin/php/cache.php` and `bin/php/console` (the `exp:cache`
commands of the Exponential 6 book, chapter 10.6). They exist in `ezpublish_legacy/` only on installs whose kernel is
6.0.15 or newer; run them through the bridge as well.

## 9.2 Cron on both sides

Chapter 5 shows how a legacy script runs inside the bridge ([5.7](05-the-legacy-kernel-inside.md#57-running-legacy-scripts-through-the-console),
[5.8](05-the-legacy-kernel-inside.md#58-legacy-cronjobs)); this section is the schedule for both kernels.

Two schedulers exist, and they are independent:

| | Platform cron | Legacy cronjobs |
|---|---|---|
| Command | `ezplatform:cron:run` (2.5), `ibexa:cron:run` (3.x and later) | `runcronjobs.php` of the legacy kernel, through the bridge |
| What it runs | services tagged `ezplatform.cron.job` (2.5, 3.x) or `ibexa.cron.job` (4.6, 5.x) | the lists of the legacy `settings/cronjob.ini`: without a part name `[CronjobSettings] Scripts[]` (unpublish, RSS import, delayed search indexing, hide, internal draft cleanup); part `frequent` (notifications, workflows); part `infrequent` (basket cleanup, link check); extensions add their own |
| Shipped jobs | none in the packages these lines install (no service carries the tag) | the kernel's and the active extensions' scripts |

The platform cron therefore has nothing to do on a plain install; schedule it anyway, so that a bundle that adds a
job later works without a crontab change. The legacy cronjobs do real work and must run.

Run the legacy cronjobs **through the bridge**: the legacy INI of every line carries no database connection
([7.2](07-databases.md#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)), so `php
ezpublish_legacy/runcronjobs.php` started directly cannot reach the database. Older guides in this repository show
that direct form; do not copy it.

```cron
# crontab of the site user (crontab -e -u <site user>)
SHELL=/bin/bash
PROJECT=/var/www/exponential
# 2.5 line
*/5 * * * *  cd $PROJECT && php bin/console ezplatform:cron:run --env=prod >> var/logs/cron-platform.log 2>&1
*/5 * * * *  cd $PROJECT && php bin/console --env=prod --siteaccess=legacy_admin ezpublish:legacy:script runcronjobs.php >> var/logs/cron-legacy.log 2>&1
*/2 * * * *  cd $PROJECT && php bin/console --env=prod --siteaccess=legacy_admin ezpublish:legacy:script runcronjobs.php frequent >> var/logs/cron-legacy.log 2>&1
15 3 * * *   cd $PROJECT && php bin/console --env=prod --siteaccess=legacy_admin ezpublish:legacy:script runcronjobs.php infrequent >> var/logs/cron-legacy.log 2>&1
# 3.x, 4.6, 5.x: ibexa:cron:run and exponential:legacy:script, logs in var/log/
```

`--siteaccess` is Symfony's option; the bridge passes it on to the legacy script. Use a siteaccess whose legacy
settings know every extension with cronjobs (the legacy admin is the usual choice). Chapter 10.3 of the Exponential 6
book lists the legacy parts and what each script does; it applies unchanged.

What can go wrong: two overlapping runs of the same part. `runcronjobs.php` does not lock; if a part can run longer
than its interval, wrap the line in `flock -n var/cron-legacy.lock ...`.

## 9.3 Background workers (Symfony Messenger)

| Line | What is configured | Worker |
|---|---|---|
| 2.5 | no Messenger | none |
| 3.x | Symfony Messenger available; the branch's guide sets `MESSENGER_TRANSPORT_DSN=sync://` for SQLite | none needed unless you route messages to an asynchronous transport |
| 4.6 | `config/packages/messenger.yaml` with all transports commented out; `.env` has `MESSENGER_TRANSPORT_DSN=doctrine://default?auto_setup=0` | none needed until a transport is enabled |
| 5.x | `IbexaMessengerBundle` registered; its transport `ibexa.messenger.transport` defaults to `doctrine://ibexa.current?table_name=ibexa_messenger_messages&auto_setup=false` (the table comes with the installed schema) | `php bin/console messenger:consume ibexa.messenger.transport --time-limit=3600` under a process supervisor |

On 5.x run the worker as the site user, restart it after every deploy (`php bin/console messenger:stop-workers`; the
supervisor starts a fresh one) because a running worker keeps the old code, and check what is routed to it with
`php bin/console debug:messenger`. The legacy kernel does not use Messenger; its asynchronous work goes through its
own cronjobs.

## 9.4 Search

| | Platform | Legacy kernel |
|---|---|---|
| Engine choice | `SEARCH_ENGINE`: `legacy` (SQL, default) or `solr` | `site.ini [SearchSettings] SearchEngine` |
| 2.5 as shipped | `legacy` | the `ezplatformsearch` extension (package `netgen/ezplatformsearch`) is active and sets `SearchEngine=ezplatformsearch`: legacy searches and indexes through the platform's engine, so one index serves both |
| 3.x as shipped | `legacy` | legacy uses its own `ezsearch` engine. The branch does not require `netgen/ezplatformsearch`; up to tag `v3.3.44.7` the extension was nevertheless listed in the injected `ActiveExtensions` (`config/app/packages/legacy.yaml`) and in the legacy override, which commit `5ace002` of 5 October 2026 removed (released in `v3.3.44.8`). On an older copy, delete both entries or install the package |
| 4.6, 5.x as shipped | `legacy` | the package is installed but not activated by the recipe's injected `ActiveExtensions`: legacy uses its own `ezsearch` engine |

Rebuild the platform index with `ezplatform:reindex` (2.5) or `exponential:reindex` (later); options include
`--iteration-count`, `--content-ids`, `--subtree` and `--processes`. With legacy's own engine, the legacy index is
rebuilt with `$LS bin/php/updatesearchindex.php --clean`.

**Solr.** 2.5 installs `se7enxweb/ezplatform-solr-search-engine` 1.7 (Solr 6 or 7), 4.6 and 5.x `ibexa/solr`. There
is no console command to create a core on 2.5 (older guides of this repository name one that does not exist); create
it with Solr's own tools from the configuration the bundle ships:

```bash
vendor/se7enxweb/ezplatform-solr-search-engine/bin/generate-solr-config.sh --help        # 2.5
vendor/ibexa/solr/bin/generate-solr-config.sh --help                                      # 4.6, 5.x
```

Then set `SEARCH_ENGINE=solr`, `SOLR_DSN` and `SOLR_CORE` (2.5 defaults: `http://localhost:8983/solr`,
`collection1`), clear the cache and reindex. With `ezplatformsearch` active, legacy searches use Solr as well.

## 9.5 Images

The platform generates its variations into `<storage>/images/_aliases/<variation>/...` on first request, the legacy
kernel its aliases next to the original ([8.7](08-configuration.md#87-image-variations-and-image-aliases)). After
changing a variation:

```bash
php bin/console liip:imagine:cache:remove --filter=<variation> --env=prod    # platform files of that variation
$LS bin/php/ezcache.php --clear-id=imagealias                                # legacy alias files
```

Both regenerate on the next request. ImageMagick on the legacy side is configured by the platform's options and
injected; GD or ImageMagick on the platform side is LiipImagine's driver setting.

## 9.6 Logs

| Log | 2.5 | 3.x, 4.6, 5.x |
|---|---|---|
| Symfony / Monolog | `var/logs/<env>.log` (`LOG_PATH` overrides; in prod `fingers_crossed` at `critical`) | `var/log/<env>.log` |
| Legacy kernel, global | `ezpublish_legacy/var/log/error.log`, `warning.log`, ... | same |
| Legacy kernel, site var dir | `ezpublish_legacy/var/site/log/` | same |
| Your cron redirections | where the crontab puts them | same |
| Web server, PHP-FPM | their own directories | same |

The production Monolog handler of 2.5 writes nothing until an entry of level `critical` arrives, then writes the
buffered request; an `error` alone leaves no trace in `prod.log`. To see errors, lower `action_level` in
`app/config/config_prod.yml` temporarily or read the legacy and PHP-FPM logs. The legacy kernel rotates its own
logs (Exponential 6 book, chapter 10.10); Symfony's log is not rotated, so add a logrotate rule with `copytruncate`.

## 9.7 Backups and restore

A consistent backup has four parts, taken together:

| Part | Where |
|---|---|
| The database | one database for both kernels (`mysqldump --single-transaction`, `pg_dump`, or the SQLite file copied with `sqlite3 <file> ".backup <copy>"`) |
| Uploaded files | `ezpublish_legacy/var/site/storage/` (2.5, 3.x); on 4.6 and 5.x `src/LegacyRoot/var/site/storage/`, which `ezpublish_legacy/var/site/storage` links to. The web root's `var` is a link to `ezpublish_legacy/var`, so this one directory is the storage of both kernels |
| Configuration and secrets | `app/config/parameters.yml` (2.5) or `.env.local` (later), `config/jwt/` (3.x and later, REST JWT keys), the legacy overrides ([8.9](08-configuration.md#89-where-the-files-are-line-by-line)) |
| Code | the git checkout plus `composer.lock` |

Not needed: `var/cache/`, `ezpublish_legacy/var/cache/`, `ezpublish_legacy/var/site/cache/`, `var/sessions/`.

Restore in the reverse order, then clear both sides' caches (9.1) and reindex if the search index is outside the
database (Solr). Test a restore on another machine at least once; a backup that has never been restored is an
assumption.

## 9.8 Performance

In the order of their effect:

1. **Production environment.** 2.5 decides the environment from `SYMFONY_ENV` (default `prod`) in `web/app.php`;
   3.x and later from `APP_ENV`. Run `cache:warmup --env=prod` after each clear. Check that nothing forces `dev`:
   the `web/.htaccess` of releases `v2.5.0.1` to `v2.5.0.3` routes every request to `app_dev.php` (corrected on
   `master` in `fa091cd`, released in `v2.5.0.4`), the `public/.htaccess` of the 3.x releases up to `v3.3.44.7` sets `APP_ENV=dev`
   (corrected in `66f13e1`, released in `v3.3.44.8`), and the `public/.htaccess` the 4.6 and 5 recipes write still sets it
   ([13.4](13-security-hardening.md#134-debug-output-and-error-display)). A site in `dev` is several times slower,
   because Symfony checks every configuration file for changes and collects profiler data on each request.
   `curl -sI https://example.com/ | grep -i x-debug-token` prints nothing on a site in `prod`.
2. **HTTP cache.** On 2.5 `web/app.php` wraps the kernel in `AppCache` (Symfony's reverse proxy) unless
   `SYMFONY_HTTP_CACHE` says otherwise or the environment is `dev`; behind Varnish switch it off and set
   `HTTPCACHE_PURGE_TYPE=http` and `HTTPCACHE_PURGE_SERVER` (singular) to Varnish's address.
3. **OPcache** with enough memory for both kernels (`opcache.memory_consumption=256` or more, `max_accelerated_files`
   above the number of PHP files in `vendor/` and `ezpublish_legacy/`).
4. **Composer's class map**: `composer dump-autoload --optimize --classmap-authoritative` at deploy time.
5. **A shared cache pool** (Redis) once there is more than one web server.
6. **The legacy kernel's own caches**: view cache and template-block cache stay enabled (the bridge forces
   `ViewCaching=enabled` anyway).

**Exponential Velocity**, the application server recommended for the Exponential kernel, keeps PHP workers loaded
between requests; its Symfony preset (`--preset=symfony`, front controller `index.php`) is documented in the
[Velocity repository](https://github.com/se7enxweb/exponential-velocity/blob/main/COMPATIBILITY.md). How to serve
this distribution with it, and what the 2.5 line's `web/app.php` front controller needs, is in
[chapter 6](06-serving-the-site.md).

## 9.9 Deploying a change

The order matters: a page rendered by old code between a cache clear and a PHP reload is cached again and looks as if
the change had not worked.

```bash
git pull --ff-only
composer install --no-dev --optimize-autoloader      # runs the line's scripts: legacy links, assets, autoloads
php bin/console cache:clear --env=prod                # Symfony + legacy template/ini/i18n caches
# reload PHP: systemctl reload php-fpm (or your pool's unit); restart Velocity workers if Velocity serves the site;
# restart Messenger workers on 5.x (messenger:stop-workers)
$LS bin/php/ezcache.php --clear-id=content,template-block
php bin/console fos:httpcache:invalidate:tag ez-all --env=prod   # only when an external proxy caches pages
```

On 3.x and later add `php bin/console doctrine:migrations:migrate --no-interaction` when a release ships migrations.
When front-end files changed, rebuild the assets: on 2.5 with the steps the README lists
(`bazinga:js-translation:dump web/assets --merge-domains`, `assetic:dump`, `yarn encore production`), on 3.x with
`composer ibexa-assets` (`yarn install`, then `bin/console ibexa:encore:compile`; the script exists from commit
`21004ae` on (release `v3.3.44.8`), which the 3.x `Makefile` and deploy recipe call; in releases up to `v3.3.44.7` run the two commands by
hand).

Expected result of a deploy: `cache:clear` ends with `[OK] Cache for the "prod" environment (debug=false) was
successfully cleared.`, the legacy clear prints the bridge's `Running script ...` line and one line per cleared
cache, and the first page request after the reload is slow (the caches fill) while the following ones are not.

Under Velocity the reload step is a restart of the Velocity workers, because each worker inherits the classes its
parent loaded at warm-up and does not see changed PHP files until then. The Exponential 6 kernel's
`exp:velocity deploy` command performs the whole sequence for a legacy-kernel installation (Exponential 6 book,
chapter 10.6); whether it covers a Platform Legacy project's Symfony caches has not been verified, so use the steps
above for this distribution.

## References

In this repository: [`app/config/default_parameters.yml`](../../app/config/default_parameters.yml) (cache pool,
search, HTTP cache, log path), [`app/config/config_prod.yml`](../../app/config/config_prod.yml) (Monolog),
[`web/app.php`](../../web/app.php), [`composer.json`](../../composer.json) (scripts), [`README.md`](../../README.md).

The bridge: [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`), `bundle/Cache/LegacyCachePurger.php`,
`bundle/Cache/PersistenceCachePurger.php`, `bundle/Command/`.

The Exponential 6 book: [chapter 10, after installing](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md)
(cronjobs, caches, autoloads, logs, backups, performance), [chapter 9, databases](https://github.com/se7enxweb/exponential/blob/main/doc/install/09-databases.md),
[chapter 8, serving the site](https://github.com/se7enxweb/exponential/blob/main/doc/install/08-serving-the-site.md) (Velocity).

External: Symfony [cache](https://symfony.com/doc/current/cache.html),
[Messenger workers in production](https://symfony.com/doc/current/messenger.html#deploying-to-production),
[performance](https://symfony.com/doc/current/performance.html); PHP [OPcache](https://www.php.net/manual/en/book.opcache.php);
upstream concepts [persistence cache](https://doc.ibexa.co/en/latest/infrastructure_and_maintenance/cache/persistence_cache/),
[HTTP cache](https://doc.ibexa.co/en/latest/infrastructure_and_maintenance/cache/http_cache/http_cache/),
[Solr search engine](https://doc.ibexa.co/en/latest/search/search_engines/solr_search_engine/install_solr/),
[image variations](https://doc.ibexa.co/en/latest/content_management/images/images/).

[Previous: 8. Configuration: YAML and INI](08-configuration.md) ·
[Next: 10. Upgrading between release lines](10-upgrading-between-lines.md) · [Contents](README.md)
