# Exponential Platform Legacy 1.1.0.x aka (Platform v3) — Installation & Operations Guide

> **Platform v3** is the foundational pure-platform release: eZ Publish Legacy 5.x + LegacyBridge 3.x +
> eZ Platform 3.3 OSS + Symfony 5.4 LTS. No Netgen packages are included.
> This guide uses numbered **Git Save Points** so developers can commit working checkpoints
> throughout the installation process and roll back to any known-good state.

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
18. [Complete CLI Reference](#18-complete-cli-reference)

---

## 1. Requirements

### PHP

- **PHP 8.0–8.4** (PHP 8.3 or 8.4 strongly recommended)
- Required extensions: `gd` or `imagick`, `redis`, `curl`, `json`, `pdo_mysql` or `pdo_pgsql`,
  `xsl`, `xml`, `intl`, `mbstring`, `opcache`
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

- **Composer 2.x** — run `composer self-update` to ensure you are on the latest 2.x release

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

Follow each step in order. Save points are marked — commit at each one so you can return to any
working state without redoing completed work.

#### Step 1 — Clone the repository

```bash
git clone git@github.com:se7enxweb/exponential-platform-legacy.git
cd exponential-platform-legacy

# Check out the Platform v3 branch
git checkout 1.1.0.x
```

#### Step 2 — Install PHP dependencies

```bash
composer install --keep-vcs
```

This downloads all packages from Packagist / GitHub into `vendor/`. It also runs Symfony's
`post-install-cmd` scripts (asset install, cache warm-up on first run).

> 💾 **Git Save Point 1 — Vendors installed**
> The `vendor/` directory is git-ignored, but `composer.lock` records the exact resolved versions.
> Commit `composer.lock` if it changed during install:
> ```bash
> git add composer.lock && git commit -m "chore(install): lock vendor dependencies at install"
> ```

#### Step 3 — Configure environment

```bash
# Copy the template; never commit .env.local
cp .env .env.local
$EDITOR .env.local
# Required: DATABASE_URL, APP_SECRET, APP_ENV
# See Section 3 for the full .env.local reference
```

#### Step 4 — Create the database

```bash
# MySQL / MariaDB
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"

# PostgreSQL
# psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8';"
```

#### Step 5 — Import schema and demo data

```bash
php bin/console ezplatform:install ibexa-oss
```

The demo data creates an administrator user: **username** `admin`, **password** `publish`.
**Change this immediately after installation** via the Legacy Admin or the eZ Platform Admin UI.

> 💾 **Git Save Point 2 — Database provisioned**
> ```bash
> git add .env.local.dist 2>/dev/null; git commit -m "chore(install): database created and demo data imported"
> ```
> If you export a database dump, store it in `doc/` or a private archive for rollback reference.

#### Step 6 — Generate JWT keypair (required for REST API)

```bash
php bin/console lexik:jwt:generate-keypair
# Keys are written to config/jwt/private.pem and config/jwt/public.pem
# These are git-ignored; back them up separately for production
```

#### Step 7 — Set file & directory permissions

```bash
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
```

See [Section 6](#6-file--directory-permissions) for full details and fallback if `setfacl` is
unavailable.

#### Step 8 — Build frontend assets

```bash
nvm use                # activate Node 18 per .nvmrc
yarn install           # install Node dependencies
yarn build:dev         # build site CSS/JS with source maps
```

> 💾 **Git Save Point 3 — Frontend assets built (dev)**
> ```bash
> git add yarn.lock && git commit -m "chore(install): yarn.lock updated, dev assets built"
> ```

#### Step 9 — Build Admin UI assets

```bash
yarn ez
# or: composer ez-assets
# or: make ibexa-assets
```

```bash
# Dump JS translation assets used by the Admin UI
php bin/console bazinga:js-translation:dump public/assets --merge-domains
```

#### Step 10 — Generate GraphQL schema

```bash
php bin/console ezplatform:graphql:generate-schema
```

#### Step 11 — Clear all caches

```bash
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache
# or: make clear-cache
```

#### Step 12 — Reindex search

```bash
php bin/console ezplatform:reindex
# or: make reindex
```

> 💾 **Git Save Point 4 — Installation complete & verified**
> At this point the site should be accessible. Test it, then commit the final state:
> ```bash
> git add -A
> git commit -m "chore(install): platform v3 install complete - assets, jwt, cache cleared, search indexed"
> ```

#### Step 13 — Start the dev server (development only)

```bash
symfony server:start
```

Access points after install:

| URL | What you get |
|---|---|
| `https://127.0.0.1:8000/` | Public site (hybrid Twig + Legacy TPL) |
| `https://127.0.0.1:8000/adminui/` | eZ Platform Admin UI (new stack, React) |
| `https://127.0.0.1:8000/ezpublish_legacy/` | Legacy Admin (classic eZ Publish) |
| `https://127.0.0.1:8000/api/ezp/v2/` | REST API v2 |

---

Or, using the Makefile shortcut (runs all of the above after vendor install):

```bash
make build            # dev (steps 2-12 in one command)
APP_ENV=prod make build   # production equivalent
```

### 2b. Composer create-project

```bash
mkdir exponential-platform-legacy && cd exponential-platform-legacy
composer create-project se7enxweb/exponential-platform-legacy:~1.1.0.1 .
```

Then follow the environment configuration, database, assets and permission steps from §2a above
(starting at Step 3).

---

## 3. Environment Configuration (.env.local)

**Never commit `.env.local`.** It overrides `.env` with host-specific secrets.

Create: `cp .env .env.local`

Minimum required changes:

```dotenv
# Application
APP_ENV=prod            # or dev
APP_SECRET=<random-32-char-string>

# Database — individual vars (MySQL/MariaDB example)
DATABASE_DRIVER=pdo_mysql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=3306
DATABASE_NAME=your_db_name
DATABASE_USER=your_db_user
DATABASE_PASSWORD=your_db_password
DATABASE_CHARSET=utf8mb4
DATABASE_COLLATION=utf8mb4_unicode_520_ci
DATABASE_VERSION=mariadb-10.x   # e.g. mariadb-10.6.0, or 8.0 for MySQL

# DATABASE_URL is derived automatically from the vars above.
# You may also set it directly as a DSN if preferred:
# DATABASE_URL="mysql://your_db_user:your_db_password@127.0.0.1:3306/your_db_name?serverVersion=8.0&charset=utf8mb4"

# Database — PostgreSQL example (use instead of MySQL vars above)
# DATABASE_DRIVER=pdo_pgsql
# DATABASE_HOST=127.0.0.1
# DATABASE_PORT=5432
# DATABASE_NAME=your_db_name
# DATABASE_USER=your_db_user
# DATABASE_PASSWORD=your_db_password
# DATABASE_CHARSET=utf8
# DATABASE_VERSION=16

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
HTTPCACHE_VARNISH_INVALIDATE_TOKEN=<your-secret>
TRUSTED_PROXIES=127.0.0.1
```

Other common variables:

```dotenv
MAILER_DSN=smtp://localhost:25
SENTRY_DSN=                 # optional: Sentry error reporting
SERVER_ENVIRONMENT=dev      # controls which config/app/server/<value>/ files are loaded
IMAGEMAGICK_PATH=/usr/bin   # path to ImageMagick binaries
```

> 💾 **Git Save Point — Environment template**
> If you create a `.env.local.dist` documenting site-specific variables (with values redacted),
> commit it as a reference for other developers:
> ```bash
> cp .env.local .env.local.dist
> # Redact all secrets, then:
> git add .env.local.dist && git commit -m "docs: add .env.local.dist as environment reference template"
> ```

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
php bin/console ezplatform:install ibexa-oss
```

The demo data creates an administrator user: **username** `admin`, **password** `publish`.
Change this immediately after installation.

### Run Doctrine migrations (on updates)

```bash
php bin/console doctrine:migration:migrate --allow-no-migration
# or via Makefile:
make migrations
```

> 💾 **Git Save Point — After each migration run**
> ```bash
> git add migrations/ && git commit -m "feat(db): run doctrine migrations YYYY-MM-DD"
> ```

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
DocumentRoot /var/www/exponential-platform-legacy/public

# Production environment
SetEnvIf Request_URI ".*" APP_ENV=prod
SetEnv APP_DEBUG "0"
SetEnv APP_HTTP_CACHE "1"    # set to "0" when using Varnish

<Directory /var/www/exponential-platform-legacy/public>
    AllowOverride None
    Require all granted
</Directory>
```

> See `doc/apache2/media-site-vhost.conf` for the full rewrite rule set (image paths, asset paths,
> `index.php` routing).
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
root /var/www/exponential-platform-legacy/public;

location ~ ^/index\.php(/|$) {
    fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    fastcgi_param APP_ENV prod;
    fastcgi_param APP_DEBUG 0;
    fastcgi_param APP_HTTP_CACHE 1;
    include fastcgi_params;
}
```

> See `doc/nginx/media-site.conf` for the full configuration including legacy kernel pass-through
> and image variation rewrite rules.

### 5c. Symfony CLI (development only)

```bash
symfony server:start          # starts HTTPS dev server on https://127.0.0.1:8000
symfony server:start -d       # run in background (daemon)
symfony server:stop           # stop the background server
symfony server:log            # tail the server log
```

---

## 6. File & Directory Permissions

Replace `www-data` with your actual web server user (e.g. `apache`, `nginx`, `_www` on macOS).
The `ezpublish_legacy/var/` directory must also be writable — it stores legacy cache, log files,
compiled templates, and uploaded content objects.

```bash
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
```

If `setfacl` is unavailable (e.g. some hosting environments), fall back to `chmod`/`chown`:

```bash
chown -R www-data:www-data var public/var ezpublish_legacy/var
chmod -R 775 var public/var ezpublish_legacy/var
```

Refer to the [Symfony file permissions guide](https://symfony.com/doc/5.4/setup/file_permissions.html)
for full details.

> **Note for development:** If your CLI user and web server user are different, the ACL approach
> allows both to write. This avoids `Permission denied` errors when alternating between
> `php bin/console` (CLI user) and web requests (www-data).

---

## 7. Frontend Assets (Site CSS/JS)

The project uses Webpack Encore + Yarn. The eZ Platform Admin UI webpack config is kept
**separate** in `webpack.config.ez.js` / `ez.webpack.config.js` — the site's own
`webpack.config.js` / `webpack.config.default.js` controls the site theme assets.

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

### What to rebuild after changes

| Changed files | Command |
|---|---|
| `assets/js/**`, `assets/sass/**`, `assets/styles/**` | `yarn build:dev` (or `yarn watch`) |
| `package.json` | `yarn install && yarn build:dev` |
| `webpack.config.js`, `webpack.config.default.js` | `yarn build:dev` |

> 💾 **Git Save Point — After theme asset changes**
> ```bash
> git add assets/ webpack.config.js package.json yarn.lock
> git commit -m "feat(theme): update site CSS/JS assets"
> ```

---

## 8. Backend/Admin Assets (eZ Platform Admin UI)

The Admin UI assets are **not** rebuilt automatically on `composer install` or `composer update`
(intentional — no Node.js needed on production servers). Deploy pre-built assets or build on demand.

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

Image variations in eZ Platform 3.3 OSS (Platform v3) are generated **on demand** by Liip Imagine
when a content view requests a variation alias. The variation configuration lives in
`config/packages/ezplatform.yml` under `ezplatform.system.<siteaccess>.image_variations`.

### Clear generated image variation cache

When variation configuration changes, remove the cached files so they are regenerated fresh:

```bash
# Remove all generated variation files for the default storage
rm -rf public/var/storage/images/
# Then clear Symfony cache so the configuration is reloaded
php bin/console cache:clear
```

Or via Liip Imagine directly:

```bash
php bin/console liip:imagine:cache:remove --filter=<variation_alias>
# Clear all cached variations (all filters):
php bin/console liip:imagine:cache:remove
```

### List configured variation aliases

```bash
php bin/console debug:config ezplatform | grep -A5 image_variations
```

### eZ Platform variation configuration reference (ezplatform.yml)

```yaml
ezplatform:
    system:
        default:
            image_variations:
                small:
                    reference: ~
                    filters:
                        - { name: geometry/scaledownonly, params: [160, 120] }
                medium:
                    reference: ~
                    filters:
                        - { name: geometry/scaledownonly, params: [480, 360] }
                large:
                    reference: ~
                    filters:
                        - { name: geometry/scaledownonly, params: [960, 720] }
```

After adding or changing variations, clear cache and let them regenerate on next request:

```bash
php bin/console cache:clear
php bin/console liip:imagine:cache:remove
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

### Clear all caches (Symfony + Legacy) in one shot

```bash
php bin/console cache:clear && php bin/console ezpublish:legacy:clear-cache
# or:
make clear-cache
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
systemctl restart php8.3-fpm
systemctl reload php8.3-fpm     # graceful reload (for config changes)
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
php bin/console ezpublish:legacy:clear-cache
php bin/console cache:warmup --env=prod

# 8. Reindex if content model changed
# php bin/console ezplatform:reindex --env=prod
```

Or as a single Makefile command:

```bash
make refresh              # git pull + full build (dev)
APP_ENV=prod make refresh     # git pull + full build (prod)
```

> 💾 **Git Save Point — After each production deploy**
> ```bash
> git tag -a "deploy-$(date +%Y%m%d-%H%M)" -m "production deploy YYYY-MM-DD HH:MM"
> git push origin --tags
> ```

---

## 13. Updating the Codebase

### Pull latest code and rebuild

```bash
git pull --rebase
composer install
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache
# or all-in-one:
make refresh
```

### Update Composer packages

```bash
# Update all packages within constraints
composer update

# Update a single package
composer update se7enxweb/legacy-bridge

# After update, always run:
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console cache:clear
php bin/console ezplatform:reindex   # if search engine schema may have changed
```

> 💾 **Git Save Point — After composer update**
> ```bash
> git add composer.lock && git commit -m "chore(deps): composer update YYYY-MM-DD"
> ```

### Update Node packages

```bash
yarn upgrade           # update within semver constraints
yarn build:dev         # rebuild after update
```

> 💾 **Git Save Point — After yarn upgrade**
> ```bash
> git add yarn.lock && git commit -m "chore(deps): yarn upgrade YYYY-MM-DD"
> ```

### Regenerate legacy autoloads (after adding/removing legacy extensions)

```bash
php bin/console ezpublish:legacy:generate-autoloads
# or from inside the legacy directory:
cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php
```

---

## 14. Cron Jobs

Add the following to crontab (`crontab -e -u www-data`):

```cron
# eZ Platform / Exponential Platform cron runner (every 5 minutes)
*/5 * * * * /usr/bin/php /var/www/exponential-platform-legacy/bin/console ezplatform:cron:run --env=prod >> /var/log/exponential-cron.log 2>&1

# eZ Publish Legacy cron runner — via LegacyBridge (if using legacy cronjobs)
*/5 * * * * /usr/bin/php /var/www/exponential-platform-legacy/ezpublish_legacy/runcronjobs.php --siteaccess legacy_admin >> /var/log/exponential-legacy-cron.log 2>&1
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
3. Load the eZ Platform Varnish VCL — see the Ibexa / eZ Platform 3.3 documentation for the
   appropriate `.vcl` file. A starting-point VCL template is in `doc/varnish/`.

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
# Nuclear option: delete cache directories
rm -rf var/cache/dev var/cache/prod

# Then warm up
php bin/console cache:warmup --env=prod
```

If using Redis:

```bash
php bin/console cache:pool:clear cache.redis
```

### Image variations missing / not regenerating

```bash
php bin/console liip:imagine:cache:remove
php bin/console cache:clear
# Variations will regenerate on next request
```

### Search results outdated

```bash
php bin/console ezplatform:reindex
```

### Permission denied writing to `var/`, `public/var/`, or `ezpublish_legacy/var/`

```bash
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
```

### JWT authentication errors (REST API)

```bash
php bin/console lexik:jwt:generate-keypair --overwrite
php bin/console cache:clear
```

### Legacy bridge / legacy kernel errors

```bash
# Clear legacy template, ini, content, and override caches
php bin/console ezpublish:legacy:clear-cache

# Reinstall public assets (bundle symlinks into public/bundles/)
php bin/console assets:install --symlink --relative public

# Regenerate legacy autoload arrays
php bin/console ezpublish:legacy:generate-autoloads
# or from legacy dir:
cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php
```

### "Autoload arrays not found" in Legacy kernel

```bash
cd ezpublish_legacy
php bin/php/ezpgenerateautoloads.php
php bin/php/ezpgenerateautoloads.php --extension
```

---

## 18. Complete CLI Reference

A comprehensive reference of every CLI command used in day-to-day development, maintenance, and
operations on Exponential Platform Legacy (Platform v3). For context on any command run
`php bin/console help <command>`.

---

### 18.1 Symfony Core

```bash
# ── Discovery ──────────────────────────────────────────────────────────────
php bin/console list                                # list all registered commands
php bin/console list ez                             # list all eZ commands
php bin/console list ezpublish                      # list all Legacy/LegacyBridge cmds
php bin/console help <command>                      # detailed help for any command

# ── Cache ──────────────────────────────────────────────────────────────────
php bin/console cache:clear                         # clear app cache (current env)
php bin/console cache:clear --env=prod              # clear prod cache
php bin/console cache:warmup                        # warm up current-env cache
php bin/console cache:warmup --env=prod             # warm up prod cache
php bin/console cache:pool:clear cache.redis        # clear a named cache pool
php bin/console cache:pool:clear cache.tagaware.filesystem
php bin/console cache:pool:list                     # list all registered cache pools

# ── Assets ─────────────────────────────────────────────────────────────────
php bin/console assets:install --symlink --relative public  # publish bundle assets

# ── Routing ────────────────────────────────────────────────────────────────
php bin/console debug:router                        # list all routes
php bin/console debug:router <route-name>           # detail one route
php bin/console router:match /path/to/page          # which route matches a URL

# ── Container / Services ───────────────────────────────────────────────────
php bin/console debug:container                     # list all service IDs
php bin/console debug:container <service-id>        # show service definition
php bin/console debug:autowiring                    # list autowireable types
php bin/console debug:config <bundle>               # dump resolved bundle config
php bin/console debug:event-dispatcher              # list all registered listeners
php bin/console debug:event-dispatcher <event>      # listeners for one event

# ── Twig ───────────────────────────────────────────────────────────────────
php bin/console debug:twig                          # list all Twig extensions/filters/fns
php bin/console lint:twig templates/                # lint all Twig files

# ── YAML / Config ──────────────────────────────────────────────────────────
php bin/console lint:yaml config/                   # lint all YAML files
php bin/console debug:config framework              # dump framework bundle config

# ── Messenger (async queues) ───────────────────────────────────────────────
php bin/console messenger:consume                   # consume messages from queue
php bin/console messenger:consume --limit=10        # consume then exit
php bin/console messenger:stop-workers              # signal all workers to stop

# ── Secrets ────────────────────────────────────────────────────────────────
php bin/console secrets:generate-keys              # generate vault keys
php bin/console secrets:set DATABASE_URL           # set a secret value

# ── Maintenance ────────────────────────────────────────────────────────────
php bin/console server:dump                         # dump registered services (Xdebug)
```

---

### 18.2 Doctrine / Migrations

```bash
# ── Migrations ─────────────────────────────────────────────────────────────
php bin/console doctrine:migration:migrate --allow-no-migration   # run pending migrations
php bin/console doctrine:migration:migrate --dry-run              # preview SQL only
php bin/console doctrine:migration:status                          # show pending/applied status
php bin/console doctrine:migration:diff                            # generate migration from entity diff
php bin/console doctrine:migration:execute --up <version>         # run one migration up
php bin/console doctrine:migration:execute --down <version>       # roll back one migration
php bin/console doctrine:migration:latest                          # show latest version number
php bin/console doctrine:migration:list                            # list all migration versions

# ── Schema ─────────────────────────────────────────────────────────────────
php bin/console doctrine:schema:validate                           # validate entity ↔ DB schema
php bin/console doctrine:schema:update --dump-sql                 # preview schema changes
php bin/console doctrine:schema:create --dump-sql                 # preview full CREATE SQL

# ── Database ───────────────────────────────────────────────────────────────
php bin/console doctrine:database:create                          # create the database
php bin/console doctrine:database:drop --force                    # drop the database (DESTRUCTIVE)
php bin/console doctrine:fixtures:load                            # load data fixtures (dev only)
```

---

### 18.3 eZ Platform / Ibexa OSS New Stack

```bash
# ── Installation ───────────────────────────────────────────────────────────
php bin/console ezplatform:install ibexa-oss        # install schema + demo data (options: clean, ibexa-oss)

# ── Search / Reindex ───────────────────────────────────────────────────────
php bin/console ezplatform:reindex                  # full reindex (all content)
php bin/console ezplatform:reindex --iteration-count=100   # incremental reindex
php bin/console ezplatform:reindex --content-type=article  # reindex one content type
php bin/console ezplatform:solr:create-core --cores=default  # provision Solr core

# ── Content Repository ─────────────────────────────────────────────────────
php bin/console ezplatform:content:cleanup-drafts   # remove stale draft versions
php bin/console ezplatform:content:cleanup-versions --keep=3  # keep last N versions

# ── Cron ───────────────────────────────────────────────────────────────────
php bin/console ezplatform:cron:run                 # run eZ Platform cron scheduler
php bin/console ezplatform:cron:run --quiet         # cron (suppress output for crontab)

# ── GraphQL ────────────────────────────────────────────────────────────────
php bin/console ezplatform:graphql:generate-schema  # regenerate GraphQL schema from content model

# ── HTTP Cache ─────────────────────────────────────────────────────────────
php bin/console fos:httpcache:invalidate:path / --all   # purge all HTTP cache paths
php bin/console fos:httpcache:invalidate:tag <tag>      # purge by cache tag

# ── JS Translations (Admin UI) ─────────────────────────────────────────────
php bin/console bazinga:js-translation:dump public/assets --merge-domains

# ── Image Variations ───────────────────────────────────────────────────────
php bin/console liip:imagine:cache:remove                 # remove all cached variations
php bin/console liip:imagine:cache:remove --filter=small  # remove one variation alias

# ── SiteAccess / Config ────────────────────────────────────────────────────
php bin/console ezplatform:debug:dump-info          # dump eZ Platform environment info
php bin/console debug:config ezplatform             # dump full resolved eZ config
```

---

### 18.4 eZ Publish Legacy Kernel & LegacyBridge

These commands are provided by the LegacyBridge (`se7enxweb/legacy-bridge`) and bridge Symfony
console commands to the eZ Publish Legacy kernel internals.

```bash
# ── Cache ──────────────────────────────────────────────────────────────────
# Clears legacy template cache, ini cache, content object cache, override cache
php bin/console ezpublish:legacy:clear-cache

# ── Autoloads ──────────────────────────────────────────────────────────────
# Regenerate legacy autoload arrays — required after adding/removing legacy extensions
php bin/console ezpublish:legacy:generate-autoloads

# ── Script Runner ──────────────────────────────────────────────────────────
# Run any legacy script (import scripts, one-off maintenance scripts)
php bin/console ezpublish:legacy:script <script-name>

# ── Cronjobs (direct — bypass Symfony, use in crontab) ────────────────────
php ezpublish_legacy/runcronjobs.php --siteaccess legacy_admin
php ezpublish_legacy/runcronjobs.php --siteaccess ezwebin_site

# ── Legacy Autoload Generator (raw PHP — run from inside legacy dir) ───────
cd ezpublish_legacy
php bin/php/ezpgenerateautoloads.php              # core & lib autoloads
php bin/php/ezpgenerateautoloads.php --extension  # extension autoloads

# ── Legacy Console (eZ Publish native CLI) ─────────────────────────────────
php ezpublish_legacy/bin/php/ezcli.php content search --query="lorem"
php ezpublish_legacy/bin/php/ezcli.php list                # list legacy commands

# ── Legacy Admin URL ───────────────────────────────────────────────────────
# /ezpublish_legacy/index.php     — admin via LegacyBridge (preferred)
# /ezpublish_legacy/               — alternative legacy admin entry point
```

---

### 18.5 JWT Authentication (REST API)

```bash
# Generate RSA keypair (initial setup or rotation)
php bin/console lexik:jwt:generate-keypair
# → writes config/jwt/private.pem  and  config/jwt/public.pem

# Overwrite existing keypair (key rotation)
php bin/console lexik:jwt:generate-keypair --overwrite

# After key rotation, clear cache and restart workers
php bin/console cache:clear
```

---

### 18.6 Frontend / Asset Build (Yarn / Webpack Encore)

```bash
# ── Node version ───────────────────────────────────────────────────────────
nvm use                       # activate Node.js 18 per .nvmrc
nvm install                   # install + activate Node from .nvmrc if missing

# ── Package management ─────────────────────────────────────────────────────
yarn install                  # install / sync all Node dependencies
yarn upgrade                  # upgrade packages within semver constraints
yarn add <package>            # add a new dependency
yarn remove <package>         # remove a dependency

# ── Site asset builds ──────────────────────────────────────────────────────
yarn build:dev                # build with source maps (development)
yarn build:prod               # build minified (production)
yarn watch                    # watch mode — auto-rebuild on source change
yarn start                    # dev HMR server

# ── Admin UI asset build ───────────────────────────────────────────────────
yarn ez                       # build eZ Platform Admin UI (webpack.config.ez.js)

# ── Inspection ─────────────────────────────────────────────────────────────
yarn list                     # list installed packages and versions
```

---

### 18.7 Makefile Shortcuts

These targets are wrappers around the commands above, defined in `Makefile`. Run `make` or `make help` to list all targets with descriptions.

> **Environment variable:** prefix any target with `APP_ENV=prod` to run in production mode. Default is `dev`.

```bash
# ── Discovery ──────────────────────────────────────────────────────────────
make help                     # list all available make targets with descriptions
make php-version              # print the PHP version required by the project

# ── Full builds ────────────────────────────────────────────────────────────
make build                    # vendor + migrations + reindex + assets + GraphQL schema + cache:clear (dev)
APP_ENV=prod make build       # production equivalent (--no-dev composer, minified assets)
make refresh                  # git stash → pull --rebase → stash pop → full build (dev)
APP_ENV=prod make refresh     # production equivalent of make refresh

# ── Dependencies ───────────────────────────────────────────────────────────
make vendor                   # composer install (adds --no-dev -o when APP_ENV=prod)

# ── Assets ─────────────────────────────────────────────────────────────────
make assets                   # yarn install + build:dev (site frontend, dev)
make assets-prod              # yarn install + build:prod (site frontend, minified)
make assets-watch             # yarn install + watch — auto-rebuild on file change
make ibexa-assets             # composer ibexa-assets (Admin UI assets)

# ── Cache ──────────────────────────────────────────────────────────────────
make clear-cache              # bin/console cache:clear (respects APP_ENV)
make clear-all-cache          # cache:clear + cache:pool:clear (incl. Redis / CACHE_POOL)

# ── Database / Search ──────────────────────────────────────────────────────
make migrations               # doctrine:migration:migrate --allow-no-migration
make reindex                  # ezplatform:reindex (recreate/refresh search index)

# ── Content ────────────────────────────────────────────────────────────────
make images                   # ngsite:content:generate-image-variations (i30,i160,i320,i480…)
make graphql-schema           # ezplatform:graphql:generate-schema

# ── Code update ────────────────────────────────────────────────────────────
make update-code              # git stash → pull --rebase → stash pop (safe update)
```

---

### 18.8 Symfony CLI (Dev Server & Tools)

```bash
symfony server:start          # start HTTPS dev server (https://127.0.0.1:8000)
symfony server:start -d       # start in background daemon mode
symfony server:stop           # stop background server
symfony server:log            # tail server access/error log
symfony server:status         # show server status + URL

symfony check:requirements    # verify PHP + extension requirements
symfony check:security        # audit composer.lock for known CVEs
symfony local:php:list        # list PHP versions available via Symfony CLI
symfony php bin/console <cmd> # run console through Symfony CLI's PHP version
```

---

### 18.9 Composer Maintenance

```bash
# ── Installing ─────────────────────────────────────────────────────────────
composer install                         # install from composer.lock
composer install --no-dev                # production install (no dev dependencies)
composer install --no-dev -o             # production + optimised autoloader

# ── Updating ───────────────────────────────────────────────────────────────
composer update                          # update all within constraints
composer update se7enxweb/legacy-bridge  # update one package
composer update --dry-run                # preview without applying

# ── Autoloader ─────────────────────────────────────────────────────────────
composer dump-autoload                   # regenerate autoloader
composer dump-autoload -o                # optimised (production) autoloader

# ── Scripts ────────────────────────────────────────────────────────────────
composer run-script project-scripts      # run all defined post-install scripts
composer ez-assets                       # run webpack Admin UI asset build script

# ── Info / Audit ───────────────────────────────────────────────────────────
composer show                            # list all installed packages
composer show se7enxweb/oss              # detail one package
composer outdated                        # list outdated packages
composer audit                           # check for security advisories
composer validate                        # validate composer.json / composer.lock
```

---

### 18.10 Git Workflow Shortcuts (developer reference)

```bash
# ── Branching ──────────────────────────────────────────────────────────────
git checkout -b feature/my-feature       # new feature branch off current
git checkout 1.1.0.x                     # switch to the stable branch

# ── Save Points ────────────────────────────────────────────────────────────
git add -A && git commit -m "chore: <description>"   # commit all changes
git stash                                # save uncommitted work temporarily
git stash pop                            # restore stashed work

# ── Tags (deploy markers) ──────────────────────────────────────────────────
git tag -a "deploy-$(date +%Y%m%d-%H%M)" -m "deploy YYYY-MM-DD"
git push origin --tags

# ── Useful inspection ──────────────────────────────────────────────────────
git log --oneline -20                    # last 20 commits
git diff HEAD                            # uncommitted changes
git status                               # working tree status
```

---

*For web server configuration templates see `doc/apache2/` and `doc/nginx/`.*
*For Docker-based development see `doc/docker/` and `compose.override.yaml`.*
*For deployment automation see `deploy.php` and `deploy/`.*
