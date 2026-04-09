# Exponential Platform Legacy 2.5.0.x — Installation Guide

This guide covers a full installation of **Exponential Platform Legacy 2.5.0.x** (`se7enxweb/exponential-platform-legacy ~2.5.0.x`).

The stack runs **two content kernels in a single application**: the Exponential (Legacy) 6.x kernel (`ezpublish_legacy/`) bridged to **Symfony 3.4 LTS** via LegacyBridge 2.x, alongside the eZ Platform 2.5 new-stack layer. The web document root is `web/` (Symfony 3.4 convention). Administration is available through both the eZ Platform 2.5 Admin UI at `/admin/` and the classic Legacy Admin at `/ezpublish_legacy/`.

---

## Table of Contents

1. [Requirements](#1-requirements)
2. [First-Time Installation](#2-first-time-installation)
3. [Environment Configuration](#3-environment-configuration)
4. [Database Setup](#4-database-setup)
5. [Web Server Setup](#5-web-server-setup)
6. [File and Directory Permissions](#6-file-and-directory-permissions)
7. [Legacy Bundle Assets and Autoloads](#7-legacy-bundle-assets-and-autoloads)
8. [Frontend Asset Build](#8-frontend-asset-build)
9. [JS Translations and Assetic Assets](#9-js-translations-and-assetic-assets)
10. [Search Index](#10-search-index)
11. [Cache Management](#11-cache-management)
12. [Day-to-Day Operations](#12-day-to-day-operations)
13. [Updating the Codebase](#13-updating-the-codebase)
14. [Cron Jobs](#14-cron-jobs)
15. [Solr Search (Optional)](#15-solr-search-optional)
16. [Varnish HTTP Cache (Optional)](#16-varnish-http-cache-optional)
17. [Troubleshooting](#17-troubleshooting)

---

## 1. Requirements

### Server-Side

| Requirement | Minimum | Recommended |
|---|---|---|
| PHP | 7.1.3 | 8.2 (tested through 8.2) |
| PHP extensions | `curl`, `intl`, `mbstring`, `pdo`, `pdo_mysql` or `pdo_pgsql`, `xml`, `zip`, `fileinfo`, `imagick` or `gd`, `xsl` | All above + `opcache`, `redis` |
| `memory_limit` | 256M | 512M — the dual-kernel architecture uses more memory than a standard Symfony app |
| `date.timezone` | Must be set in `php.ini` | See https://php.net/manual/en/timezones.php |
| Composer | 2.x | Latest 2.x |
| Database | MySQL 5.7+ | MariaDB 10.6 LTS |
| | MariaDB 10.0+ | |
| | PostgreSQL 9.5+ | PostgreSQL 14+ |
| Web server | Apache 2.4 or Nginx 1.18+ | Apache 2.4 (event + PHP-FPM) |

### Client-Side (asset build — not required on production)

| Requirement | Version |
|---|---|
| Node.js | **14 LTS** (v14.x) — do **not** use Node 16+ with Webpack Encore 1.8.2 |
| Yarn | 1.22.x (classic) |
| nvm (recommended) | any |

> **Note:** This release uses Webpack Encore 1.8.2 and webpack 4.46.0, which are compatible with Node.js 12–14 LTS. Node 16+ may cause webpack build errors with this combination. Use Node 14 LTS for all asset builds.

---

## 2. First-Time Installation

### Option A — Composer create-project (recommended)

```bash
composer create-project se7enxweb/exponential-platform-legacy:2.5.0.x-dev my_project --ignore-platform-reqs;
cd my_project
```

> **Note:** For the short term future the composer argument '--ignore-platform-reqs' is required to install the software via composer package dependencies successfully. This limitation will soon be removed in the future as we continue to update requirements within the composer package definition files for each package repostiory (tedious detail oriented work).

If prompted for `parameters.yml` values during `composer install`, provide your database credentials and a unique `secret` string. You can also skip and configure manually in step 3.

### Option B — Clone from GitHub

```bash
git clone https://github.com/se7enxweb/exponential-platform-legacy.git my_project
cd my_project
git checkout master
composer install
```

> **Note:** For the short term future the composer argument '--ignore-platform-reqs' is required to install the software via composer package dependencies successfully. This limitation will soon be removed in the future as we continue to update requirements within the composer package definition files for each package repostiory (tedious detail oriented work).

### Option C — Clone to a specific directory

```bash
git clone -b master https://github.com/se7enxweb/exponential-platform-legacy.git /path/to/docroot
cd /path/to/docroot
composer install --keep-vcs --ignore-platform-reqs;
```
> **Note:** For the short term future the composer argument '--ignore-platform-reqs' is required to install the software via composer package dependencies successfully. This limitation will soon be removed in the future as we continue to update requirements within the composer package definition files for each package repostiory (tedious detail oriented work).

After `composer install` the following composer scripts run automatically:
- `EzPublishLegacyBundle::installAssets` — links legacy kernel assets
- `EzPublishLegacyBundle::installLegacyBundlesExtensions` — enables bundle extensions in the legacy layer
- `EzPublishLegacyBundle::generateAutoloads` — builds the legacy autoload arrays
- `EzPlatformEncoreBundle::compileAssets` — runs `yarn install && yarn encore production`
- `bazinga:js-translation:dump web/assets --merge-domains`
- `assetic:dump`

If you prefer to run these steps manually (see Sections 7–9) rather than waiting for composer scripts, pass `--no-scripts` to `composer install`.

---

## 3. Environment Configuration

### parameters.yml (primary configuration file)

Symfony 3.4 uses `app/config/parameters.yml` (not `.env.local`). Composer generates this file from `app/config/parameters.yml.dist` on first install. To configure manually:

```bash
cp app/config/parameters.yml.dist app/config/parameters.yml
```

Open `app/config/parameters.yml` and set the following:

### Database

```yaml
parameters:
    env(DATABASE_DRIVER): pdo_mysql         # pdo_mysql or pdo_pgsql
    env(DATABASE_HOST): localhost
    env(DATABASE_PORT): ~                   # null = default port (3306 for MySQL, 5432 for PostgreSQL)
    env(DATABASE_NAME): exponential
    env(DATABASE_USER): db_user
    env(DATABASE_PASSWORD): db_password
    env(DATABASE_CHARSET): utf8mb4
    env(DATABASE_COLLATION): utf8mb4_unicode_520_ci
```

### Application Secret

```yaml
    env(SYMFONY_SECRET): <generate a random 64-char hex string>
```

Generate a secret:
```bash
php -r "echo bin2hex(random_bytes(32)) . PHP_EOL;"
```

### Cache Pool

```yaml
    env(CACHE_POOL): cache.app               # default filesystem cache
    # For Redis: set to cache.redis and configure app/config/cache_pool/cache.redis.yml
```

### Search Engine

```yaml
    env(SEARCH_ENGINE): legacy               # "legacy" (default) or "solr"
```

### Purge Type (HTTP Cache)

```yaml
    env(PURGE_TYPE): local                   # "local" (default) or "http" (for Varnish)
```

### Mailer (optional)

```yaml
    env(MAILER_HOST): localhost
    env(MAILER_USER): ~
    env(MAILER_PASSWORD): ~
    env(MAILER_TRANSPORT): smtp
```

---

## 4. Database Setup

### Create the database and user (MySQL / MariaDB)

```sql
CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
CREATE USER 'db_user'@'localhost' IDENTIFIED BY 'db_password';
GRANT ALL PRIVILEGES ON exponential.* TO 'db_user'@'localhost';
FLUSH PRIVILEGES;
```

### Create the database and user (PostgreSQL)

```sql
CREATE USER db_user WITH PASSWORD 'db_password';
CREATE DATABASE exponential OWNER db_user ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';
```

### Run Doctrine migrations

```bash
php bin/console doctrine:migration:migrate --allow-no-migration
```

### Install Platform schema and seed data

```bash
# Install clean schema (no demo content):
php bin/console ezplatform:install clean

# Or use the Composer script shortcut:
composer ezplatform-install
```

The `ezplatform-install` composer script runs `ezplatform:install clean` followed by `ezplatform:graphql:generate-schema`.

---

## 5. Web Server Setup

This release uses `web/` as the document root (Symfony 3.4 convention).

### Option A — Symfony CLI (development only)

```bash
symfony serve --port=8080 --document-root=web
```

Access the site at `http://localhost:8080/`, Admin UI at `http://localhost:8080/admin/`, and Legacy Admin at `http://localhost:8080/ezpublish_legacy/`.

### Option B — Apache 2.4

Enable the required modules:

```bash
a2enmod rewrite headers deflate expires
```

Create a virtual host:

```apache
<VirtualHost *:80>
    ServerName exponential.local
    DocumentRoot /path/to/my_project/web

    <Directory /path/to/my_project/web>
        AllowOverride All
        Require all granted
        Options -MultiViews
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/exponential_error.log
    CustomLog ${APACHE_LOG_DIR}/exponential_access.log combined
</VirtualHost>
```

The provided `web/.htaccess` handles Symfony's front controller routing (`app.php`) automatically.

For production, set `SYMFONY_ENV=prod` in the Apache environment, or rename/alias `app.php` as appropriate.

### Option C — Nginx

```nginx
server {
    listen 80;
    server_name exponential.local;
    root /path/to/my_project/web;

    location / {
        try_files $uri /app.php$is_args$args;
    }

    location ~ ^/(app|app_dev)\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        internal;
    }

    location ~ \.php$ {
        return 404;
    }

    error_log /var/log/nginx/exponential_error.log;
    access_log /var/log/nginx/exponential_access.log;
}
```

For production, point `try_files` to `/app.php` and disable `app_dev.php` access entirely.

---

## 6. File and Directory Permissions

Three directories must be writable by the web server: `var/`, `web/var/`, and `ezpublish_legacy/var/`.

```bash
# If web server user is www-data and your user is $USER:
sudo setfacl -R  -m u:www-data:rwX -m u:"$USER":rwX var/ web/var/ ezpublish_legacy/var/
sudo setfacl -dR -m u:www-data:rwX -m u:"$USER":rwX var/ web/var/ ezpublish_legacy/var/
```

If ACLs are not available:

```bash
chmod -R 777 var/ web/var/ ezpublish_legacy/var/
```

> **Only these three directories need to be writable.** Do not make the entire project tree writable.

Also ensure the legacy `settings/` directory is readable (not writable) by the web server:

```bash
chmod -R 755 ezpublish_legacy/settings/
```

---

## 7. Legacy Bundle Assets and Autoloads

These steps set up the Exponential (Legacy) kernel extensions and its autoload cache. If you ran `composer install` without `--no-scripts`, these have already been done automatically. Run them manually if you add or remove legacy extensions, or after a fresh clone.

```bash
# Publish Symfony bundle assets into web/
php bin/console assets:install --symlink --relative web

# Install Symfony bundle assets into the legacy kernel extensions directory
php bin/console ezpublish:legacybundles:install_extensions

# Regenerate the legacy kernel autoload arrays
# (required after adding, removing, or renaming legacy extensions)
php bin/console ezpublish:legacy:generate-autoloads
```

To regenerate legacy autoloads directly from inside the legacy directory (fallback):

```bash
cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php
```

---

## 8. Frontend Asset Build

### Activate Node.js 14 LTS

```bash
nvm use 14
```

If nvm is not installed:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
source ~/.nvm/nvm.sh
nvm install 14
nvm use 14
```

### Install Node dependencies

```bash
yarn install
```

### Build assets

```bash
# Development build (includes source maps, unminified):
yarn encore dev

# Production build (minified, no source maps):
yarn encore production

# Watch mode — auto-rebuilds on file changes (development only):
yarn encore dev-server
```

After a successful build, compiled site assets appear under `web/assets/build/` and Admin UI encore assets under `web/assets/ezplatform/build/`.

---

## 9. JS Translations and Assetic Assets

Dump the JavaScript translation catalogue so Admin UI and front-end strings are available:

```bash
php bin/console bazinga:js-translation:dump web/assets --merge-domains
```

Dump Assetic assets (required in `prod` environment and for legacy kernel CSS/JS):

```bash
# Development (includes source maps):
php bin/console assetic:dump

# Production:
php bin/console assetic:dump --env=prod
```

---

## 10. Search Index

### Built-in Legacy Search (no Solr required)

No extra setup needed for the default legacy search engine.

### Build the search index

```bash
# Full reindex — may take several minutes on large content trees:
php bin/console ezplatform:reindex

# Incremental — process N objects per iteration:
php bin/console ezplatform:reindex --iteration-count=50
```

See [Section 15](#15-solr-search-optional) for Solr configuration.

---

## 11. Cache Management

### Clear caches

```bash
# Clear Symfony application cache:
php bin/console cache:clear

# Clear production cache:
php bin/console cache:clear --env=prod

# Warm up production cache:
php bin/console cache:warmup --env=prod

# Clear Exponential (Legacy) kernel caches (templates, ini, content, override):
php bin/console ezpublish:legacy:clear-cache
```

> Always clear **both** Symfony and Legacy caches after upgrading or changing configuration.

### Redis (optional, recommended for production)

Configure `app/config/cache_pool/cache.redis.yml` and set `env(CACHE_POOL): cache.redis` in `parameters.yml`.

---

## 12. Day-to-Day Operations

### Useful commands after every deploy

```bash
php bin/console cache:clear --env=prod
php bin/console cache:warmup --env=prod
php bin/console assets:install --symlink --relative web
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console ezpublish:legacy:clear-cache
php bin/console bazinga:js-translation:dump web/assets --merge-domains
php bin/console assetic:dump --env=prod
```

### Check site health

```bash
php bin/console about                   # environment summary
php bin/console debug:router            # verify route registration
php bin/console debug:container         # verify service wiring
```

---

## 13. Updating the Codebase

```bash
# Pull the latest master changes:
git pull origin master

# Update PHP dependencies:
composer install

# Run any new database migrations:
php bin/console doctrine:migration:migrate --allow-no-migration

# Reinstall legacy extensions and regenerate autoloads:
php bin/console ezpublish:legacybundles:install_extensions
php bin/console ezpublish:legacy:generate-autoloads

# Rebuild assets (Node 14):
nvm use 14 && yarn install && yarn encore production

# Dump JS translations and assetic assets:
php bin/console bazinga:js-translation:dump web/assets --merge-domains
php bin/console assetic:dump --env=prod

# Clear all caches:
php bin/console cache:clear --env=prod
php bin/console ezpublish:legacy:clear-cache
```

---

## 14. Cron Jobs

Add both the Platform cron scheduler and the Legacy cron runner to your web server user's crontab:

```cron
# Exponential Platform 2.5 (new-stack) cron
* * * * * /usr/bin/php /path/to/my_project/bin/console ezplatform:cron:run >> /path/to/my_project/var/log/cron.log 2>&1

# Exponential (Legacy) kernel cron (runs legacy cronjob scripts)
* * * * * /usr/bin/php /path/to/my_project/ezpublish_legacy/runcronjobs.php --siteaccess legacy_admin >> /path/to/my_project/var/log/legacy_cron.log 2>&1
```

The Platform cron fires scheduled tasks (content expiry, notifications, scheduled publication). The Legacy cron handles legacy-specific cronjob scripts (search indexing for legacy search, notification digests, etc.).

---

## 15. Solr Search (Optional)

Exponential Platform Legacy 2.5.0.x includes `se7enxweb/ezplatform-solr-search-engine ^1.6`, which is compatible with **Solr 6.x and 7.7.x**.

### Install and start Solr 7.7

```bash
wget https://archive.apache.org/dist/lucene/solr/7.7.3/solr-7.7.3.tgz
tar xzf solr-7.7.3.tgz
cd solr-7.7.3
bin/solr start
```

### Configure the search engine

In `app/config/parameters.yml`, set:

```yaml
    env(SEARCH_ENGINE): solr
    env(SOLR_DSN): http://localhost:8983/solr
    env(SOLR_CORE): collection1
```

### Create the Solr core

```bash
php bin/console ezplatform:solr:create-core --cores=collection1
```

### Index all content

```bash
php bin/console ezplatform:reindex
```

---

## 16. Varnish HTTP Cache (Optional)

For high-traffic sites, configure Varnish as a reverse proxy HTTP cache.

Sample Varnish VCL is provided in `doc/varnish/`. Adjust the backend host and port to match your setup.

Enable the Varnish cache in `parameters.yml`:

```yaml
    env(PURGE_TYPE): http
    env(HTTPCACHE_PURGE_SERVERS): http://127.0.0.1:6081
```

Set the trusted proxies in `app/config/config.yml`:

```yaml
framework:
    trusted_proxies: '127.0.0.1'
```

Purge all cached content:

```bash
php bin/console fos:httpcache:invalidate:path / --all
```

---

## 17. Troubleshooting

### Blank page / HTTP 500 with no output

Open `web/app_dev.php` in your browser to enable Symfony's debug mode with full stack traces, or enable `APP_DEBUG=1` by setting it in your environment. Tail the logs:

```bash
tail -f var/logs/dev.log
tail -f var/logs/prod.log
```

### "Connection refused" or "Unknown database"

Verify `DATABASE_*` values in `app/config/parameters.yml` and that MySQL / MariaDB / PostgreSQL is running:

```bash
mysql -u db_user -pdb_password -h localhost exponential
```

### Composer install fails interactively

If prompted for parameters during install and you want to set them manually:

```bash
composer install --no-interaction
cp app/config/parameters.yml.dist app/config/parameters.yml
# then edit app/config/parameters.yml
```

### Node / Yarn build fails

Check you are running **Node.js 14 LTS**:

```bash
node -v    # must be v14.x
nvm use 14 && yarn encore production
```

### "Class not found" or autoload errors in legacy kernel

Regenerate the legacy autoload arrays:

```bash
php bin/console ezpublish:legacy:generate-autoloads
```

### Legacy extensions not activating

Run:

```bash
php bin/console ezpublish:legacybundles:install_extensions
php bin/console ezpublish:legacy:generate-autoloads
php bin/console ezpublish:legacy:clear-cache
```

### "No such file or directory" for `var/` or `web/var/` or `ezpublish_legacy/var/`

```bash
mkdir -p var web/var ezpublish_legacy/var
chmod -R 777 var web/var ezpublish_legacy/var
```

### Cache not updating after deploy

```bash
php bin/console cache:clear --env=prod
php bin/console cache:warmup --env=prod
php bin/console ezpublish:legacy:clear-cache
```

### assetic:dump fails or assets are missing in production

```bash
php bin/console assetic:dump --env=prod --no-debug
php bin/console assets:install --symlink --relative web
```

---

*For questions not covered here, see the [Where to Get More Help](../README.md#where-to-get-more-help) section of the main README.*




And at: https://exponential.doc.exponential.earth/display/DEVELOPER/Installation%2bGuide%2bfor%2bUnix-Based%2bSystems.html