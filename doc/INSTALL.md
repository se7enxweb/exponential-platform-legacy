# Exponential Platform Legacy: short installation guide

This is the quick start. It installs the **2.5 line** (this branch, `master`: Symfony 3.4, platform kernel
`se7enxweb/ezpublish-kernel ~7.5.33`, LegacyBridge 2.x, the Exponential 6 legacy kernel in `ezpublish_legacy/`) and
points to the chapter of [the book](book/README.md) that explains each step. For the 3.3, 4.6 and 5 lines, follow the
book's [chapter 4.13](book/04-installing.md#413-the-whole-install-per-line) instead.

## 1. Requirements

| | 2.5 line |
|---|---|
| PHP | `^7.1.3 \|\| ^8.1 \|\| ^8.2` (`composer.json`), with `curl`, `intl`, `mbstring`, `pdo` plus the PDO driver of your database, `xml`, `xsl`, `zip`, `fileinfo`, `gd` or `imagick`; for SQLite both `pdo_sqlite` and `sqlite3` |
| `memory_limit` | 256M at least; both kernels run in one process |
| `date.timezone` | set in `php.ini` |
| Database | MySQL 5.7+ / MariaDB 10.0+ (`utf8mb4`), PostgreSQL 9.5+, or SQLite 3.35+ for development and tests |
| Composer | 2.x |
| Asset build | Node.js 14 LTS and Yarn 1.22 (Webpack Encore 1.8.2 and webpack 4.46 do not build on Node.js 16 and later) |
| Web server | Exponential Velocity, Apache 2.4 or nginx with PHP-FPM ([book, chapter 6](book/06-serving-the-site.md)) |

Details: [chapter 2](book/02-requirements.md).

## 2. Get the code

```bash
composer create-project se7enxweb/exponential-platform-legacy:~2.5.0.3 exponential_website   # the v2.5.0.3 release
# or the branch head: se7enxweb/exponential-platform-legacy:dev-master  (also known as 2.5.x-dev)
cd exponential_website
```

Always give the version. Without one, Composer takes the newest stable tag, `v5.0.3`, which (by a release mistake)
contains this 2.5 line; for the 5 line use `:5.x-dev` or `:v5.0.2` ([chapter 10.1](book/10-upgrading-between-lines.md#101-the-release-lines)).
`2.5.0.x-dev`, used by older guides, matches nothing on Packagist. Use `--ignore-platform-reqs` only for a platform
requirement you have checked is irrelevant.

`composer install` runs the project's scripts: it builds `app/config/parameters.yml` from `parameters.yml.dist`
(asking for values unless `--no-interaction`), clears the cache, installs bundle assets, links the legacy kernel's
assets and the bundles' legacy extensions, regenerates the legacy autoloads, dumps the JS translations and the
Assetic assets, runs `yarn install` and the Encore build, and runs the security checker. Pass `--no-scripts` to do
these steps by hand (step 6). Chapter: [3](book/03-getting-the-code.md).

## 3. Configure

Edit `app/config/parameters.yml` (never commit it; it is in `.gitignore`):

```yaml
parameters:
    env(SYMFONY_SECRET): <output of: openssl rand -hex 32>
    env(DATABASE_DRIVER): pdo_mysql          # pdo_mysql, pdo_pgsql or pdo_sqlite
    env(DATABASE_HOST): localhost
    env(DATABASE_PORT): ~
    env(DATABASE_NAME): exponential
    env(DATABASE_USER): exponential
    env(DATABASE_PASSWORD): <password>
    env(DATABASE_CHARSET): utf8mb4
    env(DATABASE_COLLATION): utf8mb4_unicode_520_ci
```

Real environment variables of the same names override these values. For SQLite set `DATABASE_DRIVER` to
`pdo_sqlite`; the file is `var/data_<environment>.db` (`var/data_prod.db`, `var/data_dev.db`), or the path in the
environment variable `DATABASE_PATH`. The legacy kernel needs no database settings of its own: the bridge passes the
platform's connection to it ([chapter 7.2](book/07-databases.md#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)).

Optional settings, as environment variables (defaults in `app/config/default_parameters.yml`):

| Variable | Default | Meaning |
|---|---|---|
| `SEARCH_ENGINE` | `legacy` | `legacy` or `solr` (with `SOLR_DSN`, `SOLR_CORE`) |
| `CACHE_POOL` | `cache.tagaware.filesystem` | `cache.redis` or `cache.memcached` with `CACHE_DSN`; must be a real environment variable, because `app/config/env/generic.php` loads the pool's file at container compile time |
| `HTTPCACHE_PURGE_TYPE` | `local` | `local` (Symfony's proxy) or `http` for Varnish; compile time, like `CACHE_POOL` |
| `HTTPCACHE_PURGE_SERVER` | `http://localhost:80` | the Varnish address for `http` purging |
| `SYMFONY_ENV`, `SYMFONY_DEBUG` | `prod`, off | read by `web/app.php` |
| `SYMFONY_TRUSTED_PROXIES` | unset | comma-separated proxy addresses, read by `web/app.php` ([chapter 13.9](book/13-security-hardening.md#139-behind-a-proxy-trusted-proxies-on-both-sides)) |
| `MAILER_HOST`, `MAILER_USER`, `MAILER_PASSWORD`, `MAILER_TRANSPORT` | `127.0.0.1`, none, none, `smtp` | SwiftMailer |

Configuration in depth: [chapter 4.4](book/04-installing.md#44-configure-the-environment) and
[chapter 8](book/08-configuration.md).

## 4. Create the database and install

```bash
# MySQL / MariaDB
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
# PostgreSQL:  CREATE DATABASE exponential OWNER exponential ENCODING 'UTF8';
# SQLite:      nothing to create

php bin/console ezplatform:install clean              # or: ezplatform:install exponential-oss (needed for SQLite)
```

The installer drops and recreates its tables: run it only on an empty database. `exponential-oss` builds SQLite
tables with correct composite primary keys. The seed's administrator is `admin` / `publish`; change the password at
once. Chapters: [4.5](book/04-installing.md#45-run-the-platform-installer), [7](book/07-databases.md).

## 5. Permissions

```bash
sudo setfacl -R  -m u:www-data:rwX -m u:"$USER":rwX var web/var ezpublish_legacy/var
sudo setfacl -dR -m u:www-data:rwX -m u:"$USER":rwX var web/var ezpublish_legacy/var
```

Only these trees need to be writable (`web/var` is a link to `ezpublish_legacy/var`); keep the rest read-only for the
web server, and never `chmod -R 777`. For SQLite the database file and its directory must be writable too.
Chapter: [6.7](book/06-serving-the-site.md#67-file-permissions).

## 6. Legacy kernel, assets and caches

If Composer ran its scripts, most of this is done; run it after a `--no-scripts` install or when extensions change:

```bash
php bin/console assets:install --symlink --relative web
php bin/console ezpublish:legacy:assets_install --symlink --relative web       # web/design, extension, share, var
php bin/console ezpublish:legacybundles:install_extensions
(cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php --extension)       # legacy autoloads

nvm use 14 && yarn install && yarn encore production                          # web/assets/build, web/assets/ezplatform/build
node_modules/.bin/encore production --config-name app                         # the project's SCSS, web/assets/app
php bin/console bazinga:js-translation:dump web/assets --merge-domains
php bin/console assetic:dump --env=prod

php bin/console --env=prod cache:clear
php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --clear-all
```

There are no `ezpublish:legacy:clear-cache` or `ezpublish:legacy:generate-autoloads` commands; older guides that
use them are wrong. Run legacy scripts through `ezpublish:legacy:script`, so that they get the database settings, and
put Symfony's options (`--env`, `--siteaccess`) before the command name. The project's stylesheet is linked in Twig
with `{{ encore_entry_link_tags('index', null, 'app') }}`. Chapters: [5](book/05-the-legacy-kernel-inside.md),
[9.1](book/09-operations.md#91-caches-on-both-sides).

## 7. Serve the site

Point the web server at `web/`. Production must route to `web/app.php`, never to `web/app_dev.php`; use the rules in
[`doc/apache2/vhost.template`](apache2/vhost.template) or [`doc/nginx/`](nginx/), and see
[chapter 13.2](book/13-security-hardening.md#132-what-the-web-server-must-never-hand-out) for what the committed
`web/.htaccess` does. For a local test, `symfony serve --document-root=web` is enough.

| Address (siteaccess matching `URIElement: 1`) | What |
|---|---|
| `/` | the site (siteaccess `site`) |
| `/admin/` | the platform admin |
| `/legacy_admin/` | the legacy admin (`legacy_mode: true`); older guides say `/ezpublish_legacy/`, which does not exist |
| `/api/ezp/v2/` | REST API v2 |
| `/graphql` | GraphQL |

Chapter: [6](book/06-serving-the-site.md); Exponential Velocity is the recommended application server.

## 8. Cron

```cron
*/5 * * * *  cd /path/to/exponential_website && php bin/console ezplatform:cron:run --env=prod >> var/logs/cron-platform.log 2>&1
*/5 * * * *  cd /path/to/exponential_website && php bin/console --env=prod --siteaccess=legacy_admin ezpublish:legacy:script runcronjobs.php >> var/logs/cron-legacy.log 2>&1
*/2 * * * *  cd /path/to/exponential_website && php bin/console --env=prod --siteaccess=legacy_admin ezpublish:legacy:script runcronjobs.php frequent >> var/logs/cron-legacy.log 2>&1
```

Run the legacy cronjobs through the bridge; `php ezpublish_legacy/runcronjobs.php` on its own has no database
settings. Chapter: [9.2](book/09-operations.md#92-cron-on-both-sides).

## 9. Search, Solr and Varnish

- Rebuild the search index with `php bin/console ezplatform:reindex` (`--iteration-count=50`, `--subtree`, ...).
- Solr: the 2.5 line installs `se7enxweb/ezplatform-solr-search-engine` 1.7; create the core with Solr's own tools
  from the configuration `vendor/se7enxweb/ezplatform-solr-search-engine/bin/generate-solr-config.sh` produces, set
  `SEARCH_ENGINE=solr`, `SOLR_DSN`, `SOLR_CORE`, and reindex. There is no `ezplatform:solr:create-core` command.
- Varnish: sample VCL in [`doc/varnish/`](varnish/varnish.md); set `HTTPCACHE_PURGE_TYPE=http` and
  `HTTPCACHE_PURGE_SERVER`, and `SYMFONY_TRUSTED_PROXIES` to Varnish's address. Purge everything with
  `php bin/console fos:httpcache:invalidate:tag ez-all`.

Chapter: [9.4](book/09-operations.md#94-search) and [9.8](book/09-operations.md#98-performance).

## 10. Updating and troubleshooting

```bash
git pull --ff-only && composer install
php bin/console --env=prod cache:clear
php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --clear-all
```

The 2.5 line has no Doctrine migrations. Database updates, line changes and the legacy kernel's update files:
[chapter 10](book/10-upgrading-between-lines.md). Moving between database engines:
[chapter 7.10](book/07-databases.md#710-moving-a-site-to-another-engine). Symptoms and fixes:
[chapter 12](book/12-troubleshooting.md). Before going live: [chapter 13](book/13-security-hardening.md).

| Problem | First thing to check |
|---|---|
| Blank page or 500 | `var/logs/prod.log` (written only on `critical` entries), the PHP-FPM log, `ezpublish_legacy/var/log/error.log`; for a stack trace run once with `SYMFONY_ENV=dev SYMFONY_DEBUG=1` on a non-public host |
| "Connection refused" / "Unknown database" | the `DATABASE_*` values and that the server runs |
| Node/Yarn build fails | `node -v` must be 14 |
| Legacy class not found | regenerate the legacy autoloads (step 6) |
| Legacy extension not active | `ezpublish:legacybundles:install_extensions`, autoloads, legacy cache clear |
| `assetic:dump` fails or assets missing in prod | `php bin/console assetic:dump --env=prod --no-debug`, then `assets:install --symlink --relative web` |
| Old content after a deploy | both caches (step 6), then the HTTP cache |
