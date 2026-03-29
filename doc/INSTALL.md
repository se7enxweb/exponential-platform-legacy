# Exponential Platform Nexus 1.1.0.x — Installation & Operations Guide

---

## Table of Contents

1. [Requirements](#1-requirements)
2. [First-Time Installation](#2-first-time-installation)
   - [2a. GitHub (git clone)](#2a-github-git-clone)
   - [2b. Composer create-project](#2b-composer-create-project)
3. [Environment Configuration (.env.local)](#3-environment-configuration-envlocal)
4. [Database Setup](#4-database-setup)
5. [Web Server Setup](#5-web-server-setup)
   - [5a. Apache 2.4](#5a-apache-24)
   - [5b. Nginx](#5b-nginx)
   - [5c. Symfony CLI (development only)](#5c-symfony-cli-development-only)
6. [File & Directory Permissions](#6-file--directory-permissions)
7. [Frontend Assets (Site CSS/JS)](#7-frontend-assets-site-cssjs)
8. [Backend/Admin Assets (eZ Platform Admin UI)](#8-backendadmin-assets-ez-platform-admin-ui)
9. [Search Index](#9-search-index)
10. [Image Variations](#10-image-variations)
11. [Cache Management](#11-cache-management)
12. [Day-to-Day Operations: Start / Stop / Restart](#12-day-to-day-operations-start--stop--restart)
13. [Updating the Codebase](#13-updating-the-codebase)
14. [Cron Jobs](#14-cron-jobs)
15. [Solr Search Engine (optional)](#15-solr-search-engine-optional)
16. [Varnish HTTP Cache (optional)](#16-varnish-http-cache-optional)
17. [Troubleshooting](#17-troubleshooting)

---

## 1. Requirements

### PHP

- **PHP 8.0–8.3** (PHP 8.2 or 8.3 strongly recommended)
- Required extensions: `gd` or `imagick`, `redis`, `curl`, `json`, `pdo_mysql` or `pdo_pgsql`, `xsl`, `xml`, `intl`, `mbstring`, `opcache`
- `memory_limit` ≥ 256M (set in `php.ini` or `.htaccess`; restart web server after changes)
- `date.timezone` must be set in `php.ini` or `.htaccess` — see https://php.net/manual/en/timezones.php
- `max_execution_time` ≥ 90 (recommended 300 for CLI)

### Web Server

- **Apache 2.4** with `mod_rewrite`, `mod_deflate` enabled; run in `event` or `worker` mode with PHP-FPM
  (prefork mode also works but is not recommended for performance)  
  _or_
- **Nginx 1.18+** with PHP-FPM

### Node.js & Yarn

- **Node.js 18** (managed via [nvm](https://github.com/nvm-sh/nvm); `.nvmrc` is present in the project root)
- **Yarn 1.x** (`npm install -g yarn`)

### Composer

- **Composer 2.x** — `composer self-update` to ensure you are on the latest 2.x release

### Database

- **MySQL 8.0+** with `utf8mb4` character set and `utf8mb4_unicode_520_ci` collation  
  _or_
- **MariaDB 10.3+**  
  _or_
- **PostgreSQL 14+**

### Optional

- **Redis 6+** — recommended for production caching and sessions
- **Solr 7.7 or 8.11.1+** — for advanced full-text search (default engine is `legacy`)
- **Varnish 6.0 or 7.1+** with [`varnish-modules`](https://github.com/varnish/varnish-modules) — for HTTP reverse-proxy caching
- **ImageMagick** — for advanced image processing (`IMAGEMAGICK_PATH` env var, default `/usr/bin`)

---

## 2. First-Time Installation

### 2a. GitHub (git clone)

```bash
# Clone the repository
git clone git@github.com:se7enxweb/exponential-platform-nexus.git
cd exponential-platform-nexus

# Check out the correct branch
git checkout 1.1.0.x

# Install PHP dependencies
composer install --keep-vcs

# Copy and edit environment file (see Section 3)
cp .env .env.local
$EDITOR .env.local

# Create the database (see Section 4)
# mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"

# Set permissions (see Section 6)
setfacl -R -m u:www-data:rwX -m g:www-data:rwX var public/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var public/var

# Import schema and demo data (see Section 4)
php bin/console ibexa:install netgen-media

# Generate JWT keys (required for REST API authentication)
php bin/console lexik:jwt:generate-keypair

# Build frontend assets (see Section 7)
nvm use
yarn install
yarn build:dev

# Build admin UI assets (see Section 8)
composer ez-assets   # or: yarn ez   (see Section 8 for details)

# Dump JS translation assets used by Admin UI
php bin/console bazinga:js-translation:dump public/assets --merge-domains

# Generate GraphQL schema
php bin/console ezplatform:graphql:generate-schema

# Clear cache
php bin/console cache:clear
```

Or, using the Makefile shortcut (runs all of the above after vendor install):

```bash
make build          # dev
APP_ENV=prod make build    # production
```

### 2b. Composer create-project

```bash
mkdir exponential-platform-nexus
cd exponential-platform-nexus
composer create-project se7enxweb/exponential-platform-nexus:~1.1.0.1 .
```

Then follow the environment configuration, database, assets and permission steps from §2a above.

---

## 3. Environment Configuration (.env.local)

**Never commit `.env.local`.** It overrides `.env` with host-specific secrets.

Create: `cp .env .env.local`

Minimum required changes:

```dotenv
# Application
APP_ENV=prod            # or dev
APP_SECRET=<random-32-char-string>

# Database (MySQL/MariaDB example)
DATABASE_URL="mysql://db_user:db_pass@127.0.0.1:3306/exponential?serverVersion=8.0&charset=utf8mb4"

# Database (PostgreSQL example)
# DATABASE_URL="postgresql://db_user:db_pass@127.0.0.1:5432/exponential?serverVersion=16&charset=utf8"

# Search engine: "legacy" (default) or "solr"
SEARCH_ENGINE=legacy

# HTTP cache
HTTPCACHE_PURGE_TYPE=local       # or "varnish" when using Varnish
HTTPCACHE_DEFAULT_TTL=86400
HTTPCACHE_PURGE_SERVER=http://localhost:80

# Cache backend: "cache.tagaware.filesystem" (default), "cache.redis", "cache.memcached"
CACHE_POOL=cache.tagaware.filesystem
```

For **Redis** caching:

```dotenv
CACHE_POOL=cache.redis
CACHE_DSN=redis://localhost:6379
```

For **Solr** search:

```dotenv
SEARCH_ENGINE=solr
SOLR_DSN=http://localhost:8983/solr
SOLR_CORE=collection1
```

For **Varnish**:

```dotenv
HTTPCACHE_PURGE_TYPE=varnish
HTTPCACHE_PURGE_SERVER=http://127.0.0.1:6081
HTTPCACHE_VARNISH_INVALIDATE_TOKEN=<secret-token>
```

Other common variables:

```dotenv
MAILER_DSN=smtp://localhost:25
SENTRY_DSN=                 # optional: Sentry error reporting
SERVER_ENVIRONMENT=dev      # controls which config/app/server/<value>/ files are loaded
IMAGEMAGICK_PATH=/usr/bin   # path to ImageMagick binaries
```

---

## 4. Database Setup

### Create the database

```sql
CREATE DATABASE exponential
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_520_ci;
```

### Import schema and demo data

```bash
php bin/console ibexa:install media-site-legacy
```

The demo data creates an administrator user: **username** `admin`, **password** `publish`. Change this immediately after installation.

### Run Doctrine migrations (on updates)

```bash
php bin/console doctrine:migration:migrate --allow-no-migration
# or via Makefile:
make migrations
```

---

## 5. Web Server Setup

### 5a. Apache 2.4

Enable required modules:

```bash
a2enmod rewrite deflate headers expires
```

Use the provided virtual host template as a starting point:

```bash
cp doc/apache2/media-site-vhost.conf /etc/apache2/sites-available/exponential.conf
# Edit ServerName, DocumentRoot and log paths, then:
a2ensite exponential
systemctl reload apache2
```

Key directives (inside `<VirtualHost>`):

```apache
DocumentRoot /var/www/exponential-platform-nexus/public

# Production environment
SetEnvIf Request_URI ".*" APP_ENV=prod
SetEnv APP_DEBUG "0"
SetEnv APP_HTTP_CACHE "1"    # disable when using Varnish

<Directory /var/www/exponential-platform-nexus/public>
    AllowOverride None
    Require all granted
</Directory>
```

> See `doc/apache2/media-site-vhost.conf` for the full rewrite rule set (image paths, asset paths, `index.php` routing).
> Use `doc/apache2/media-site.conf` if you prefer to keep rewrite rules in `.htaccess`.

### 5b. Nginx

Use the provided template:

```bash
cp doc/nginx/media-site.conf /etc/nginx/sites-available/exponential.conf
# Edit server_name, root and fastcgi_pass (PHP-FPM socket/host), then:
ln -s /etc/nginx/sites-available/exponential.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

Key directives:

```nginx
root /var/www/exponential-platform-nexus/public;

location ~ ^/index\.php(/|$) {
    fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    fastcgi_param APP_ENV prod;
    fastcgi_param APP_DEBUG 0;
    fastcgi_param APP_HTTP_CACHE 1;
    include fastcgi_params;
}
```

> See `doc/nginx/media-site.conf` and `doc/nginx/ibexa_params.d/` for the full configuration including image variation rewrite rules.

### 5c. Symfony CLI (development only)

```bash
symfony server:start          # starts HTTPS dev server on https://127.0.0.1:8000
symfony server:start -d       # run in background (daemon)
symfony server:stop           # stop the background server
symfony server:log            # tail the server log
```

---

## 6. File & Directory Permissions

Replace `www-data` with your actual web server user (e.g. `apache`, `nginx`, `_www` on macOS):

```bash
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var public/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var public/var
```

If `setfacl` is unavailable, use `chmod`/`chown`:

```bash
chown -R www-data:www-data var public/var
chmod -R 775 var public/var
```

Refer to the [Symfony file permissions guide](https://symfony.com/doc/5.4/setup/file_permissions.html) for full details.

---

## 7. Frontend Assets (Site CSS/JS)

The project uses Webpack Encore + Yarn. The Ibexa Admin UI webpack config is kept **separate** in `webpack.config.ez.js` / `ez.webpack.config.js` — the site's own `webpack.config.js` / `webpack.config.default.js` is used here.

### Install Node dependencies (first time or after `package.json` changes)

```bash
nvm use           # activates Node 18 per .nvmrc
yarn install
```

### Build for development (with source maps)

```bash
yarn build:dev
# or:
make assets
```

### Build for production (minified)

```bash
yarn build:prod
# or:
APP_ENV=prod make assets-prod
```

### Watch mode (auto-rebuild on file change during development)

```bash
yarn watch
# or:
make assets-watch
```

### Dev server (HMR / hot module replacement)

```bash
yarn start     # or: yarn server
```

### Per-siteaccess builds

When working on a specific siteaccess design only:

```bash
yarn site:dev   <config-name>
yarn site:prod  <config-name>
yarn site:watch <config-name>
```

### What to rebuild after changes

| Changed files | Command |
|---|---|
| `assets/js/**`, `assets/scss/**` | `yarn build:dev` (or `yarn watch`) |
| `package.json` | `yarn install && yarn build:dev` |
| `webpack.config.js`, `webpack.config.default.js` | `yarn build:dev` |

---

## 8. Backend/Admin Assets (eZ Platform Admin UI)

The Admin UI assets are **not** rebuilt automatically on `composer install` or `composer update` (intentional — no Node.js needed on production servers). Deploy pre-built assets or build them on demand.

### Build Admin UI assets

```bash
nvm use
composer ez-assets
# or equivalently:
yarn ez
# or via Makefile:
make ibexa-assets
```

This runs Webpack using `webpack.config.ez.js` and outputs to `public/assets/ezplatform/build/`.
It does not generate Bazinga JS translation assets; dump those separately:

```bash
php bin/console bazinga:js-translation:dump public/assets --merge-domains
```

### What changes require an Admin UI asset rebuild

| Changed | Rebuild needed? |
|---|---|
| `ez.webpack.config.js` or `ez.webpack.config.manager.js` | Yes |
| Any bundle's `Resources/public/` JS or CSS | Yes (`composer ez-assets`) |
| Admin richtext editor configuration | Yes |
| `composer update` pulled a new admin-ui / richtext bundle version | Yes |

### Re-enabling automatic Admin UI asset building on Composer (optional)

Add to the `symfony-scripts` section of `composer.json`:

```json
"@php bin/console bazinga:js-translation:dump public/assets --merge-domains",
"yarn install",
"yarn ez"
```

> **Note:** `yarn ez` uses the renamed `webpack.config.ez.js` — do not rename it back.

### Install Symfony public assets (bundle `public/` directories → `public/bundles/`)

This is run automatically by `composer install`/`update`, but can be run manually:

```bash
php bin/console assets:install --symlink --relative public
```

---

## 9. Search Index

### Reindex (rebuild from scratch)

Required after fresh install, after importing content, or after switching search engines.

```bash
php bin/console ezplatform:reindex
# or:
make reindex
```

### Refresh index (incremental update)

```bash
php bin/console ezplatform:reindex --iteration-count=100
```

For Solr only — force a commit after indexing:

```bash
curl http://localhost:8983/solr/collection1/update?commit=true
```

---

## 10. Image Variations

Generate pre-sized image variations to avoid on-demand generation load:

```bash
php bin/console ngsite:content:generate-image-variations \
    --variations=i30,i160,i320,i480,nglayouts_app_preview,ngcb_thumbnail
# or:
make images
```

Limit to a subtree or content type:

```bash
php bin/console ngsite:content:generate-image-variations \
    --variations=i320,i480 \
    --subtree=/1/2/ \
    --content-type=ng_image
```

List all options:

```bash
php bin/console ngsite:content:generate-image-variations --help
```

---

## 11. Cache Management

### Clear Symfony application cache

```bash
php bin/console cache:clear                    # clears current APP_ENV
php bin/console cache:clear --env=prod         # clears prod cache
# or:
make clear-cache
APP_ENV=prod make clear-cache
```

### Warm up cache (production)

```bash
php bin/console cache:warmup --env=prod
```

### Clear cache pool (Redis, filesystem, etc.)

```bash
php bin/console cache:pool:clear cache.redis   # or cache.tagaware.filesystem
# or:
make clear-all-cache
```

### Purge HTTP cache (Varnish/local)

```bash
php bin/console fos:httpcache:invalidate:path / --all
```

### Clear legacy kernel cache

```bash
php bin/console ezpublish:legacy:clear-cache
```

---

## 12. Day-to-Day Operations: Start / Stop / Restart

### Apache

```bash
systemctl start apache2
systemctl stop apache2
systemctl restart apache2
systemctl reload apache2    # graceful reload (no dropped connections)
```

### Nginx

```bash
systemctl start nginx
systemctl stop nginx
systemctl reload nginx      # graceful reload
nginx -s reload             # alternative graceful reload
```

### PHP-FPM

```bash
systemctl restart php8.2-fpm
systemctl reload php8.2-fpm     # graceful reload (for config changes)
```

### Redis (if used)

```bash
systemctl start redis
systemctl restart redis
```

### Symfony CLI dev server

```bash
symfony server:start -d         # start in background
symfony server:stop             # stop
symfony server:log              # view logs
```

### After deploying code changes (production checklist)

```bash
# 1. Pull code
git pull --rebase

# 2. Install/update vendors
composer install --no-dev -o

# 3. Run migrations
php bin/console doctrine:migration:migrate --allow-no-migration --env=prod

# 4. Install public assets (bundle Resources/public → public/bundles/)
php bin/console assets:install --symlink --relative public --env=prod

# 5. Rebuild Admin UI assets (if admin-ui bundle updated)
nvm use && yarn ez

# 6. Rebuild frontend assets (if theme/JS/CSS changed)
nvm use && yarn build:prod

# 7. Clear & warm up cache
php bin/console cache:clear --env=prod
php bin/console cache:warmup --env=prod

# 8. Reindex if content model changed
# php bin/console ezplatform:reindex --env=prod
```

Or as a single Makefile command:

```bash
make refresh        # git pull + full build (dev)
APP_ENV=prod make refresh    # git pull + full build (prod)
```

---

## 13. Updating the Codebase

### Pull latest code and rebuild

```bash
git pull --rebase
composer install
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console cache:clear
# or all-in-one:
make refresh
```

### Update Composer packages

```bash
# Update all packages within constraints
composer update

# Update a single package
composer update se7enxweb/site-bundle

# After update, always run:
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console cache:clear
php bin/console ezplatform:reindex   # if search engine schema may have changed
```

### Update Node packages

```bash
yarn upgrade           # update within semver constraints
yarn build:dev         # rebuild after update
```

---

## 14. Cron Jobs

Add the following to crontab (`crontab -e -u www-data`):

```cron
# eZ Platform / Exponential Platform cron runner (every 5 minutes)
*/5 * * * * /usr/bin/php /var/www/exponential-platform-nexus/bin/console ezplatform:cron:run --env=prod >> /var/log/exponential-cron.log 2>&1

# Legacy cron runner (if using LegacyBridge)
*/5 * * * * /usr/bin/php /var/www/exponential-platform-nexus/runcronjobs.php --siteaccess legacy_admin >> /var/log/exponential-legacy-cron.log 2>&1
```

---

## 15. Solr Search Engine (optional)

### Switch from legacy to Solr

1. Set `SEARCH_ENGINE=solr` and `SOLR_DSN`/`SOLR_CORE` in `.env.local`
2. Clear cache: `php bin/console cache:clear`
3. Set up the Solr core with the eZ Platform schema:
   ```bash
   php bin/console ezplatform:solr:create-core --cores=default
   ```
4. Reindex all content:
   ```bash
   php bin/console ezplatform:reindex
   ```

### Switch back to legacy search

```dotenv
SEARCH_ENGINE=legacy
```

```bash
php bin/console cache:clear
```

---

## 16. Varnish HTTP Cache (optional)

1. Set env vars (see §3):
   ```dotenv
   HTTPCACHE_PURGE_TYPE=varnish
   HTTPCACHE_PURGE_SERVER=http://127.0.0.1:6081
   HTTPCACHE_VARNISH_INVALIDATE_TOKEN=<your-secret>
   TRUSTED_PROXIES=127.0.0.1
   ```
2. Set `APP_HTTP_CACHE=0` in your web server vhost (let Varnish handle caching).
3. Load the eZ Platform Varnish VCL — see Ibexa/eZ Platform documentation for the appropriate `.vcl` file for eZ Platform 3.3.

---

## 17. Troubleshooting

### White screen / 500 error

```bash
# Check Symfony logs
tail -f var/log/dev.log
tail -f var/log/prod.log

# Check PHP-FPM / Apache / Nginx error logs
tail -f /var/log/apache2/error.log
tail -f /var/log/nginx/error.log

# Switch to dev mode temporarily
APP_ENV=dev php bin/console cache:clear
```

### "Class not found" after composer update

```bash
composer dump-autoload -o
php bin/console cache:clear
```

### Assets not loading (404 on `/bundles/` or `/assets/`)

```bash
# Reinstall public assets
php bin/console assets:install --symlink --relative public

# Rebuild frontend
yarn build:dev

# Rebuild Admin UI
yarn ez
```

### Cache not clearing / stale content

```bash
# Nuclear option: delete cache directory
rm -rf var/cache/dev var/cache/prod

# Then warm up
php bin/console cache:warmup --env=prod
```

If using Redis:

```bash
php bin/console cache:pool:clear cache.redis
```

### Image variations missing

```bash
php bin/console ngsite:content:generate-image-variations \
    --variations=i30,i160,i320,i480
```

### Search results outdated

```bash
php bin/console ezplatform:reindex
```

### Permission denied writing to `var/` or `public/var/`

```bash
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var public/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var public/var
```

### JWT authentication errors (REST API)

```bash
php bin/console lexik:jwt:generate-keypair --overwrite
php bin/console cache:clear
```

### Legacy bridge errors

```bash
php bin/console ezpublish:legacy:clear-cache
php bin/console assets:install --symlink --relative public
```

Check legacy autoloads:

```bash
composer run-script project-scripts
```

---

*For additional context, see [doc/netgen/INSTALL.md](netgen/INSTALL.md) and the Apache/Nginx server config templates in `doc/apache2/` and `doc/nginx/`.*

