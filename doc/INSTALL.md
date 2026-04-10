# Exponential Platform Legacy 2.5.0.x — Installation Guide

This guide covers a full installation of **Exponential Platform Legacy 2.5.0.x** (`se7enxweb/exponential-platform-legacy ~2.5.0.x`).

The stack runs **two content kernels in a single application**: the Exponential (Legacy) 6.x kernel (`ezpublish_legacy/`) bridged to **Symfony 3.4 LTS** via LegacyBridge 2.x, alongside the eZ Platform 2.5 new-stack layer. The web document root is `web/` (Symfony 3.4 convention). Administration is available through both the eZ Platform 2.5 Admin UI at `/admin/` and the classic Legacy Admin at `/ezpublish_legacy/`.

---

## Table of Contents

1. [Requirements](#1-requirements)
2. [First-Time Installation](#2-first-time-installation)
3. [Environment Configuration](#3-environment-configuration)
4. [Database Setup](#4-database-setup)
   - [4a. MySQL / MariaDB](#4-database-setup)
   - [4b. PostgreSQL](#4-database-setup)
   - [4c. SQLite (zero-config)](#4c-sqlite-zero-config-database)
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
18. [Database Conversion](#18-database-conversion)
    - [18a. Any → SQLite](#18a-any--sqlite-go-to-sqlite)
    - [18b. SQLite → MySQL / MariaDB](#18b-sqlite--mysql--mariadb)
    - [18c. SQLite → PostgreSQL](#18c-sqlite--postgresql)
    - [18d. MySQL / MariaDB → PostgreSQL](#18d-mysql--mariadb--postgresql)
    - [18e. Oracle → MySQL / MariaDB / PostgreSQL / SQLite](#18e-oracle--mysql--mariadb--postgresql--sqlite)
    - [18f. MySQL / MariaDB / PostgreSQL / SQLite → Oracle](#18f-mysql--mariadb--postgresql--sqlite--oracle)
    - [18g. Post-conversion checklist](#18g-post-conversion-checklist)

---

## 1. Requirements

### Server-Side

| Requirement | Minimum | Recommended |
|---|---|---|
| PHP | 7.1.3 | 8.2 (tested through 8.2) |
| PHP extensions | `curl`, `intl`, `mbstring`, `pdo`, `pdo_mysql` or `pdo_pgsql` or `pdo_sqlite`, `xml`, `zip`, `fileinfo`, `imagick` or `gd`, `xsl` | All above + `opcache`, `redis`; for SQLite add `pdo_sqlite` + `sqlite3` |
| `memory_limit` | 256M | 512M — the dual-kernel architecture uses more memory than a standard Symfony app |
| `date.timezone` | Must be set in `php.ini` | See https://php.net/manual/en/timezones.php |
| Composer | 2.x | Latest 2.x |
| Database | MySQL 5.7+ | MariaDB 10.6 LTS |
| | MariaDB 10.0+ | |
| | PostgreSQL 9.5+ | PostgreSQL 14+ |
| | **SQLite 3.35+** (zero-config; dev/testing only) | 3.39+ |
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

### SQLite (zero-config alternative — dev / testing)

SQLite requires **no database server**. The `.db` file is created on disk automatically when you run the install command. It is the fastest way to get a local development environment running without installing MySQL or PostgreSQL.

In `app/config/parameters.yml`, replace (or add) the database parameters:

```yaml
parameters:
    env(DATABASE_DRIVER): pdo_sqlite
    env(DATABASE_PATH): "%kernel.root_dir%/../var/data_%kernel.environment%.db"
    # Remove or comment out DATABASE_HOST, DATABASE_PORT, DATABASE_NAME,
    # DATABASE_USER, DATABASE_PASSWORD, DATABASE_CHARSET, DATABASE_COLLATION
    # — they are not used when DATABASE_DRIVER is pdo_sqlite.
```

> **Notes:**
> - The DB file path above evaluates to e.g. `var/data_dev.db` or `var/data_prod.db`.
> - The `pdo_sqlite` and `sqlite3` PHP extensions must be enabled. Verify: `php -m | grep -i sqlite`
> - After install, make the DB file writable by the web server:
>   ```bash
>   chmod 664 var/data_dev.db
>   chown $USER:www-data var/data_dev.db   # adjust group to your web server user
>   ```
> - **Not recommended for production** — SQLite does not support concurrent writes under load.
>   Use MySQL/MariaDB or PostgreSQL for any multi-user or public-facing deployment.

See [Section 4c](#4c-sqlite-zero-config-database) for the full SQLite install walkthrough.

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

## 4c. SQLite (zero-config database)

SQLite is the fastest way to spin up a local development or demo environment — no database server software required at all.

### Step 1 — Verify PHP extensions

```bash
php -m | grep -i sqlite
# Expected output should include both:
#   SQLite3
#   pdo_sqlite
```

If either is missing, enable them in `php.ini` (e.g. `extension=pdo_sqlite` / `extension=sqlite3`) and restart your web server / PHP-FPM.

### Step 2 — Configure `app/config/parameters.yml`

Replace (or add) the database parameters section:

```yaml
parameters:
    env(DATABASE_DRIVER): pdo_sqlite
    env(DATABASE_PATH): "%kernel.root_dir%/../var/data_%kernel.environment%.db"
```

Remove or comment out any `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DATABASE_USER`, `DATABASE_PASSWORD` entries — they are not used when a SQLite path is configured.

### Step 3 — Run the install command

```bash
php bin/console ezplatform:install exponential-oss
```

This single command:
1. Creates the SQLite `.db` file at `var/data_<environment>.db` (e.g. `var/data_dev.db`)
2. Generates the schema using `SqliteDbPlatform` to ensure composite `PRIMARY KEY(id, version)` DDL is correct for tables such as `ezcontentobject_attribute`
3. Imports the seed content (content classes, content objects, users, roles)
4. Creates the Doctrine ORM tables

The default administrator credentials are:
- **Username:** `admin`
- **Password:** `publish`

**Change the admin password immediately** after installation.

### Step 4 — Fix file permissions

The install command runs as your shell user. The web server needs write access to the `.db` file:

```bash
chmod 664 var/data_dev.db
chown $USER:www-data var/data_dev.db   # replace www-data with your web server group
```

### Step 5 — Clear caches

```bash
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache
```

### The Legacy kernel and SQLite

The Exponential (Legacy) kernel and the Symfony new-stack **share the same `.db` file** automatically. LegacyBridge reads the DBAL connection parameters (including the absolute path to the `.db` file) and passes them to the legacy `eZDB` layer, so both kernels operate on the same dataset with no additional configuration.

### SQLite limitations

| Limitation | Impact |
|---|---|
| No concurrent write transactions | Under heavy or concurrent load, writes queue up and can timeout. Use MySQL/MariaDB for production. |
| No replication or clustering | Cannot be used in multi-server (cluster) deployments |
| No `FULLTEXT` index | Legacy kernel full-text search falls back to `LIKE` queries |
| File-level locking | File must be on a local filesystem — NFS/CIFS mounts not supported |
| Single file, single host | DB file is local to the server that runs PHP |

> **TL;DR:** SQLite is ideal for **local development, automated testing, demos, and air-gapped / offline environments**. Use MySQL 5.7+, MariaDB 10.0+, or PostgreSQL 9.5+ for any public-facing or multi-user production deployment.

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

---

## 18. Database Conversion

This section covers converting an **existing, running Exponential Platform Legacy application** from one database engine to another using **free and open-source tools only**.

All tools listed below are distributed under OSI-approved open-source licences (MIT, GPL, BSD, Apache 2.0) or are free CLI utilities included with the database server packages.

> **Before you start — backup everything.**
> ```bash
> # MySQL / MariaDB
> mysqldump -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" > /tmp/backup_$(date +%Y%m%d).sql
> # PostgreSQL
> pg_dump -U pg_user exponential > /tmp/backup_$(date +%Y%m%d).sql
> # SQLite
> cp var/data_dev.db var/data_dev.db.bak_$(date +%Y%m%d)
> # Oracle (requires Oracle exp/expdp — run as oracle DBA user)
> expdp system/syspass@ORCLPDB SCHEMAS=your_schema DUMPFILE=backup_$(date +%Y%m%d).dmp LOGFILE=backup_$(date +%Y%m%d).log
> # Also backup var/, ezpublish_legacy/var/, and your parameters.yml
> cp app/config/parameters.yml app/config/parameters.yml.bak
> ```

---

### Tool inventory

All tools are free and open-source.

#### `mysqldump` / `mysql` CLI
Bundled with every MySQL and MariaDB server package.
- Debian/Ubuntu: `apt install default-mysql-client`
- RHEL/AlmaLinux: `dnf install mysql`
- macOS (Homebrew): `brew install mysql-client`
- Generic: [dev.mysql.com/downloads/mysql](https://dev.mysql.com/downloads/mysql/)

#### `pg_dump` / `psql`
Bundled with PostgreSQL server packages.
- Debian/Ubuntu: `apt install postgresql-client`
- RHEL/AlmaLinux: `dnf install postgresql`
- macOS (Homebrew): `brew install libpq`
- Generic: [postgresql.org/download](https://www.postgresql.org/download/)

#### `sqlite3` CLI
Pre-installed on macOS; available in all Linux package managers.
- Debian/Ubuntu: `apt install sqlite3`
- RHEL/AlmaLinux: `dnf install sqlite`
- Generic: [sqlite.org/download.html](https://www.sqlite.org/download.html)

#### [pgloader](https://pgloader.io)
Licence: PostgreSQL (BSD-like). The most capable single tool — handles MySQL → PostgreSQL and SQLite → PostgreSQL natively.
- Debian/Ubuntu: `apt install pgloader`
- Fedora: `dnf install pgloader`
- macOS (Homebrew): `brew install pgloader`
- Docker: `docker run --rm -it dimitri/pgloader:latest pgloader <args>`
- Source: [github.com/dimitri/pgloader](https://github.com/dimitri/pgloader)

#### [mysql2sqlite](https://github.com/dumblob/mysql2sqlite)
Licence: MIT. Single shell script, no compiled dependencies.
```bash
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite
chmod +x mysql2sqlite
```

#### [sqlite3-to-mysql](https://github.com/techouse/sqlite3-to-mysql)
Licence: MIT. Python package.
```bash
pip3 install sqlite3-to-mysql
```

#### [ora2pg](https://ora2pg.darold.net)
Licence: GPL v2. The standard free tool for migrating Oracle schemas and data to PostgreSQL (and MySQL). Written in Perl.
- Debian/Ubuntu: `apt install ora2pg` (or install via CPAN)
- RHEL/AlmaLinux: `dnf install perl-ora2pg` (EPEL) or via CPAN
- macOS (Homebrew): `brew install ora2pg` (unofficial) or via CPAN
- CPAN install: `cpan install Ora2Pg` (requires `DBD::Oracle` — needs Oracle Instant Client)
- Docker: `docker run --rm -v $(pwd):/data georgmoser/ora2pg ora2pg -c /data/ora2pg.conf`
- Source: [github.com/darold/ora2pg](https://github.com/darold/ora2pg)
- Docs: [ora2pg.darold.net](https://ora2pg.darold.net)

> **Note:** `ora2pg` requires the Oracle Instant Client libraries and `DBD::Oracle` Perl module to connect to the source Oracle instance. Oracle Instant Client Basic Lite is free to download from [oracle.com/database/technologies/instant-client](https://www.oracle.com/database/technologies/instant-client/downloads/version-121-downloads.html).

#### [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/)
Licence: Free (proprietary Oracle). Oracle's free Java-based CLI — used for importing data *into* Oracle when Oracle XE or a full Oracle server is the target. Requires Java 11+.
```bash
# Install Oracle XE (free developer edition) — the fastest way to get a target Oracle DB:
# Debian/Ubuntu: download .deb from oracle.com/database/technologies/xe-downloads.html
# RHEL/AlmaLinux: download .rpm from the same page
# Docker: docker run -d -p 1521:1521 -e ORACLE_PWD=Secret123 container-registry.oracle.com/database/express:21.3.0-xe
```

---

### 18a. Any → SQLite (go to SQLite)

#### From MySQL / MariaDB → SQLite

Use the [**mysql2sqlite**](https://github.com/dumblob/mysql2sqlite) shell script (MIT licence, no dependencies beyond `bash` and `sqlite3`):

```bash
# 1. Get the script
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite
chmod +x mysql2sqlite

# 2. Dump the MySQL database through the converter and pipe into SQLite
mysqldump --no-tablespaces --skip-extended-insert --compact \
  -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" \
  -h "$DATABASE_HOST" "$DATABASE_NAME" \
  | ./mysql2sqlite - | sqlite3 var/data_dev.db
```

> `--skip-extended-insert` produces one `INSERT` per row — slower but required by the
> converter. For large databases, dump table-by-table:

```bash
TABLES=$(mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" \
  -e 'SHOW TABLES;' --batch --skip-column-names)
for TABLE in $TABLES; do
  mysqldump --no-tablespaces --skip-extended-insert --compact \
    -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" "$TABLE" \
    | ./mysql2sqlite - >> /tmp/dump.sql
done
sqlite3 var/data_dev.db < /tmp/dump.sql
```

#### From PostgreSQL → SQLite

Use [**pgloader**](https://pgloader.io) (PostgreSQL-licenced):

```bash
touch var/data_dev.db

cat > /tmp/pg_to_sqlite.load <<EOF
LOAD DATABASE
  FROM postgresql://db_user:db_pass@127.0.0.1/db_name
  INTO sqlite:///$(pwd)/var/data_dev.db

WITH include no drop, create tables, create indexes, reset sequences

SET work_mem TO '128MB', maintenance_work_mem TO '512MB';
EOF

pgloader /tmp/pg_to_sqlite.load
```

#### After migrating to SQLite — update `app/config/parameters.yml`

```yaml
parameters:
    env(DATABASE_DRIVER): pdo_sqlite
    env(DATABASE_PATH): "%kernel.root_dir%/../var/data_dev.db"
```

Fix permissions and clear caches (see [Section 4c](#4c-sqlite-zero-config-database) steps 4–5).

---

### 18b. SQLite → MySQL / MariaDB

Create the target database first (see [Section 4](#4-database-setup)).

#### Method 1 — [sqlite3-to-mysql](https://github.com/techouse/sqlite3-to-mysql) (Python, MIT)

```bash
pip3 install sqlite3-to-mysql

sqlite3mysql \
  --sqlite-file var/data_dev.db \
  --mysql-database "$DATABASE_NAME" \
  --mysql-user "$DATABASE_USER" \
  --mysql-password "$DATABASE_PASSWORD" \
  --mysql-host "$DATABASE_HOST" \
  --mysql-port 3306 \
  --chunk 1000
```

Verify row counts match:
```bash
# SQLite
sqlite3 var/data_dev.db "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
# MySQL
mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" \
  -e "SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema='$DATABASE_NAME' ORDER BY table_name;"
```

#### Method 2 — manual SQL dump + sed fixes

```bash
# 1. Dump from SQLite
sqlite3 var/data_dev.db .dump > /tmp/sqlite_dump.sql

# 2. Strip SQLite-specific preamble
sed -i '/^PRAGMA/d; /^BEGIN TRANSACTION/d; /^COMMIT/d; /^CREATE UNIQUE INDEX/d' /tmp/sqlite_dump.sql

# 3. Convert double-quoted identifiers to backtick-quoted
sed -i 's/"\([a-zA-Z_][a-zA-Z0-9_]*\)"/`\1`/g' /tmp/sqlite_dump.sql

# 4. Map SQLite types to MySQL equivalents
sed -i 's/INTEGER PRIMARY KEY AUTOINCREMENT/INT NOT NULL AUTO_INCREMENT PRIMARY KEY/g' /tmp/sqlite_dump.sql
sed -i 's/ BOOLEAN/ TINYINT(1)/g' /tmp/sqlite_dump.sql

# 5. Import
mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" < /tmp/sqlite_dump.sql
```

#### After migrating — update `app/config/parameters.yml`

```yaml
parameters:
    env(DATABASE_DRIVER): pdo_mysql
    env(DATABASE_HOST): 127.0.0.1
    env(DATABASE_PORT): 3306
    env(DATABASE_NAME): your_db_name
    env(DATABASE_USER): your_db_user
    env(DATABASE_PASSWORD): your_db_password
    env(DATABASE_CHARSET): utf8mb4
    env(DATABASE_COLLATION): utf8mb4_unicode_520_ci
```

---

### 18c. SQLite → PostgreSQL

Use [**pgloader**](https://pgloader.io) — it has native SQLite source support:

```bash
psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8';"

cat > /tmp/sqlite_to_pg.load <<EOF
LOAD DATABASE
  FROM sqlite:///$(pwd)/var/data_dev.db
  INTO postgresql://pg_user:pg_pass@127.0.0.1/exponential

WITH include no drop, create tables, create indexes, reset sequences;
EOF

pgloader /tmp/sqlite_to_pg.load
```

pgloader handles type mapping (INTEGER → bigint, TEXT → text, REAL → double precision), index creation, and sequence reset.

#### After migrating — update `app/config/parameters.yml`

```yaml
parameters:
    env(DATABASE_DRIVER): pdo_pgsql
    env(DATABASE_HOST): 127.0.0.1
    env(DATABASE_PORT): 5432
    env(DATABASE_NAME): exponential
    env(DATABASE_USER): pg_user
    env(DATABASE_PASSWORD): pg_pass
```

---

### 18d. MySQL / MariaDB → PostgreSQL

Use [**pgloader**](https://pgloader.io) — this is its primary, most mature use-case:

```bash
psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8';"

cat > /tmp/mysql_to_pg.load <<'EOF'
LOAD DATABASE
  FROM      mysql://db_user:db_pass@127.0.0.1/source_db
  INTO      postgresql://pg_user:pg_pass@127.0.0.1/exponential

WITH include no drop,
     create tables,
     create indexes,
     reset sequences,
     foreign keys

SET work_mem TO '128MB'

CAST
  column type matching ~/enum/ to text,
  type tinyint to boolean using tinyint-to-boolean,
  type longtext to text, type mediumtext to text,
  type int with unsigned to bigint;
EOF

pgloader /tmp/mysql_to_pg.load
```

#### After migrating — update `app/config/parameters.yml`

```yaml
parameters:
    env(DATABASE_DRIVER): pdo_pgsql
    env(DATABASE_HOST): 127.0.0.1
    env(DATABASE_PORT): 5432
    env(DATABASE_NAME): exponential
    env(DATABASE_USER): pg_user
    env(DATABASE_PASSWORD): pg_pass
```

---

### 18e. Oracle → MySQL / MariaDB / PostgreSQL / SQLite

The primary free tool for migrating **out of Oracle** is [**ora2pg**](https://ora2pg.darold.net) (GPL v2). It connects to Oracle via Perl's `DBD::Oracle` driver and exports schema + data in a format compatible with PostgreSQL, MySQL, or plain SQL.

> **Prerequisite:** Install Oracle Instant Client Basic Lite (free) and the `DBD::Oracle` Perl module. See the Tool Inventory above for installation notes.

#### Oracle → PostgreSQL

```bash
# 1. Generate an ora2pg config file
ora2pg --init_project /tmp/ora2pg_project
cd /tmp/ora2pg_project

# 2. Edit ora2pg.conf — set at minimum:
#   ORACLE_DSN    dbi:Oracle:host=oracle_host;sid=ORCL;port=1521
#   ORACLE_USER   your_oracle_user
#   ORACLE_PWD    your_oracle_password
#   SCHEMA        YOUR_SCHEMA
#   PG_DSN        dbi:Pg:dbname=exponential;host=127.0.0.1;port=5432
#   PG_USER       pg_user
#   PG_PWD        pg_pass

# 3. Create the target PostgreSQL database
psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8';"

# 4. Export schema (table structures, sequences, indexes, constraints)
ora2pg -c ora2pg.conf -t TABLE    -o schema_tables.sql
ora2pg -c ora2pg.conf -t SEQUENCE -o schema_sequences.sql
ora2pg -c ora2pg.conf -t INDEX    -o schema_indexes.sql
ora2pg -c ora2pg.conf -t TRIGGER  -o schema_triggers.sql

# 5. Export data
ora2pg -c ora2pg.conf -t COPY -o data.sql

# 6. Import into PostgreSQL in order: sequences → tables → data → indexes → triggers
psql -U pg_user exponential < schema_sequences.sql
psql -U pg_user exponential < schema_tables.sql
psql -U pg_user exponential < data.sql
psql -U pg_user exponential < schema_indexes.sql
psql -U pg_user exponential < schema_triggers.sql
```

ora2pg automatically maps Oracle types: `NUMBER(n,0)` → `integer`/`bigint`, `NUMBER(n,m)` → `numeric(n,m)`, `VARCHAR2` → `varchar`, `CLOB` → `text`, `BLOB` → `bytea`, `DATE` → `timestamp`.

Update `app/config/parameters.yml`:
```yaml
parameters:
    env(DATABASE_DRIVER): pdo_pgsql
    env(DATABASE_HOST): 127.0.0.1
    env(DATABASE_PORT): 5432
    env(DATABASE_NAME): exponential
    env(DATABASE_USER): pg_user
    env(DATABASE_PASSWORD): pg_pass
```

#### Oracle → MySQL / MariaDB

```bash
# 1. Use ora2pg with TYPE=MYSQL_INSERT to produce MySQL-compatible INSERT statements
#    (Edit ora2pg.conf and set:  EXPORT_TYPE INSERT  and  PG_DSN  to your MySQL DSN)

# 2. Alternatively: export to plain SQL INSERTs and pipe through sed fixes:
ora2pg -c ora2pg.conf -t COPY  -o /tmp/ora_data.sql
ora2pg -c ora2pg.conf -t TABLE -o /tmp/ora_schema.sql

# Fix Oracle-isms for MySQL:
sed -i 's/ BOOLEAN/ TINYINT(1)/g; s/BYTEA/LONGBLOB/g; s/"\([a-zA-Z_][a-zA-Z0-9_]*\)"/`\1`/g' /tmp/ora_schema.sql
sed -i 's/ BOOLEAN/ TINYINT(1)/g; s/BYTEA/LONGBLOB/g; s/"\([a-zA-Z_][a-zA-Z0-9_]*\)"/`\1`/g' /tmp/ora_data.sql

# 3. Create the MySQL database and import
mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" -e "CREATE DATABASE \`$DATABASE_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" < /tmp/ora_schema.sql
mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" < /tmp/ora_data.sql
```

Update `app/config/parameters.yml`:
```yaml
parameters:
    env(DATABASE_DRIVER): pdo_mysql
    env(DATABASE_HOST): 127.0.0.1
    env(DATABASE_PORT): 3306
    env(DATABASE_NAME): your_db_name
    env(DATABASE_USER): your_db_user
    env(DATABASE_PASSWORD): your_db_password
    env(DATABASE_CHARSET): utf8mb4
    env(DATABASE_COLLATION): utf8mb4_unicode_520_ci
```

#### Oracle → SQLite

Migrate via PostgreSQL as an intermediate step:

```bash
# 1. Migrate Oracle → PostgreSQL (see above)
# 2. Then migrate PostgreSQL → SQLite using pgloader (see Section 18c for the reverse,
#    run pgloader FROM postgresql:// INTO sqlite://)

cat > /tmp/pg_to_sqlite.load <<EOF
LOAD DATABASE
  FROM postgresql://pg_user:pg_pass@127.0.0.1/exponential
  INTO sqlite:///$(pwd)/var/data_dev.db

WITH include no drop, create tables, create indexes, reset sequences

SET work_mem TO '128MB';
EOF

pgloader /tmp/pg_to_sqlite.load
```

Update `app/config/parameters.yml` as shown in [Section 18a](#18a-any--sqlite-go-to-sqlite).

---

### 18f. MySQL / MariaDB / PostgreSQL / SQLite → Oracle

Migrating **into Oracle** uses Oracle's own free tools: **Oracle XE** (free developer edition) as the target instance and **SQLcl** or **SQL*Plus** for importing. There is no single free tool equivalent to `ora2pg` in the reverse direction, but the process is straightforward for each source.

> **Target Oracle instance:** Oracle Database XE (Express Edition) is free for development and testing — download the `.deb`/`.rpm` from [oracle.com/database/technologies/xe-downloads.html](https://www.oracle.com/database/technologies/xe-downloads.html) or run via Docker:
> ```bash
> docker run -d -p 1521:1521 -p 5500:5500 \
>   -e ORACLE_PWD=Secret123 \
>   --name oracle-xe \
>   container-registry.oracle.com/database/express:21.3.0-xe
> ```

#### MySQL / MariaDB → Oracle

```bash
# 1. Dump from MySQL to SQL
mysqldump --no-tablespaces --skip-extended-insert --compatible=ansi \
  --default-character-set=utf8 \
  -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" \
  > /tmp/mysql_dump.sql

# 2. Convert MySQL-isms to Oracle SQL:
#   - Remove backtick quotes → double-quotes (Oracle uses ANSI quoting)
#   - Remove AUTO_INCREMENT → use Oracle SEQUENCE + TRIGGER or GENERATED ALWAYS AS IDENTITY
#   - Replace TINYINT(1) with NUMBER(1)
#   - Replace TEXT/LONGTEXT with CLOB, LONGBLOB with BLOB
#   - Remove ENGINE=..., CHARSET=..., COLLATE=... table options

sed -e 's/`/"/g' \
    -e 's/ AUTO_INCREMENT//g' \
    -e 's/ TINYINT(1)/ NUMBER(1)/g' \
    -e 's/ BIGINT( *[0-9]*)/ NUMBER(19)/g' \
    -e 's/ INT( *[0-9]*)/ NUMBER(10)/g' \
    -e 's/ SMALLINT/ NUMBER(5)/g' \
    -e 's/ LONGTEXT/ CLOB/g; s/ MEDIUMTEXT/ CLOB/g; s/ TEXT( *[0-9]*)/ CLOB/g' \
    -e 's/ LONGBLOB/ BLOB/g; s/ MEDIUMBLOB/ BLOB/g' \
    -e '/ENGINE=\|DEFAULT CHARSET=\|COLLATE=/d' \
    /tmp/mysql_dump.sql > /tmp/oracle_dump.sql

# 3. Import into Oracle via SQLcl (free) or SQL*Plus:
# SQLcl:   sql system/Secret123@//localhost:1521/XEPDB1 @/tmp/oracle_dump.sql
# SQL*Plus: sqlplus system/Secret123@//localhost:1521/XEPDB1 @/tmp/oracle_dump.sql
sql system/Secret123@//localhost:1521/XEPDB1 @/tmp/oracle_dump.sql
```

Update `app/config/parameters.yml`:
```yaml
parameters:
    env(DATABASE_DRIVER): oci8       # or pdo_oci — requires PHP oci8 extension
    env(DATABASE_HOST): 127.0.0.1
    env(DATABASE_PORT): 1521
    env(DATABASE_NAME): XEPDB1       # Oracle service name / SID
    env(DATABASE_USER): your_oracle_user
    env(DATABASE_PASSWORD): your_oracle_password
```

> **PHP Oracle extension:** The `oci8` or `pdo_oci` PHP extension must be enabled. Both require Oracle Instant Client. Install: `pecl install oci8` then add `extension=oci8.so` to `php.ini`.

#### PostgreSQL → Oracle

```bash
# 1. Dump from PostgreSQL as plain SQL INSERT statements
pg_dump --inserts --no-privileges --no-owner \
  -U pg_user exponential > /tmp/pg_dump.sql

# 2. Convert PostgreSQL-isms to Oracle SQL:
sed -e 's/boolean/NUMBER(1)/gi' \
    -e 's/ true\b/ 1/gi; s/ false\b/ 0/gi' \
    -e 's/ SERIAL / NUMBER(10) GENERATED ALWAYS AS IDENTITY /gi' \
    -e 's/ BIGSERIAL / NUMBER(19) GENERATED ALWAYS AS IDENTITY /gi' \
    -e 's/ TEXT\b/ CLOB/gi; s/ BYTEA\b/ BLOB/gi' \
    -e '/^SET /d; /^SELECT pg_catalog/d' \
    /tmp/pg_dump.sql > /tmp/oracle_pg_dump.sql

# 3. Import via SQLcl
sql system/Secret123@//localhost:1521/XEPDB1 @/tmp/oracle_pg_dump.sql
```

Update `app/config/parameters.yml` as shown in the MySQL → Oracle section above.

#### SQLite → Oracle

```bash
# 1. Dump SQLite to SQL
sqlite3 var/data_dev.db .dump > /tmp/sqlite_dump.sql

# 2. Convert to Oracle SQL:
sed -e 's/"\([a-zA-Z_][a-zA-Z0-9_]*\)"/"\1"/g' \
    -e 's/INTEGER PRIMARY KEY AUTOINCREMENT/NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY/g' \
    -e 's/ BOOLEAN/ NUMBER(1)/gi' \
    -e 's/ TEXT\b/ CLOB/gi; s/ BLOB\b/ BLOB/gi' \
    -e '/^PRAGMA/d; /^BEGIN TRANSACTION/d; /^COMMIT/d' \
    /tmp/sqlite_dump.sql > /tmp/oracle_sqlite_dump.sql

# 3. Import via SQLcl
sql system/Secret123@//localhost:1521/XEPDB1 @/tmp/oracle_sqlite_dump.sql
```

Update `app/config/parameters.yml` as shown in the MySQL → Oracle section above.

#### Oracle limitations for Exponential Platform Legacy

| Topic | Detail |
|---|---|
| PHP extension | Requires `oci8` or `pdo_oci` — not enabled by default; needs Oracle Instant Client |
| Doctrine DBAL | Oracle dialect supported via `Doctrine\DBAL\Platforms\OraclePlatform` |
| Legacy kernel | eZ Publish legacy has limited Oracle driver support — verify `ezpublish_legacy/lib/ezdb/classes/ezoracledb.php` is present |
| Identifier length | Oracle 12.1 and earlier limit identifiers to 30 characters; 12.2+ supports 128 chars |
| `DUAL` table | Some legacy queries may need `FROM DUAL` added for Oracle compatibility |
| Case sensitivity | Oracle stores unquoted identifiers in UPPERCASE; always use quoted identifiers in SQL |
| Free tier | Oracle XE is limited to 2 CPU threads, 2 GB RAM, 12 GB user data — sufficient for development |

---

### 18g. Post-conversion checklist

After any database engine switch, run through every item:

```bash
# 1. Update app/config/parameters.yml with new database driver + credentials

# 2. Clear the Symfony container and cache (it caches the DBAL connection)
php bin/console cache:clear

# 3. Clear the legacy kernel cache (reads DB config from its own ini cache)
php bin/console ezpublish:legacy:clear-cache

# 4. Validate Doctrine entity mappings against the new DB
php bin/console doctrine:schema:validate

# 5. Run any pending Doctrine migrations
php bin/console doctrine:migration:migrate --allow-no-migration

# 6. Re-run the legacy autoload generator (safe to run again)
php bin/console ezpublish:legacy:generate-autoloads

# 7. Regenerate the search index against the new DB
php bin/console ezplatform:reindex

# 8. Smoke-test the site
curl -I http://localhost/
curl -I http://localhost/admin/
curl -I http://localhost/ezpublish_legacy/

# 9. If using SQLite as target — fix file permissions
chmod 664 var/data_dev.db
chown "$USER":www-data var/data_dev.db
```

#### Common post-conversion issues

| Symptom | Cause | Fix |
|---|---|---|
| `Base table not found` | Table not migrated | Check pgloader / mysql2sqlite log for errors; re-run missing table |
| Binary/blob content garbled | Charset mismatch during export | Re-export with `--default-character-set=utf8mb4` (mysqldump) or `CLIENT_ENCODING=UTF8` (psql) |
| Image variation 404s | `ezcontentobject_attribute` row count mismatch | Verify row counts; re-run data transfer for that table |
| Legacy Admin 500 after conversion | Legacy kernel ini cache has old DB type | `php bin/console ezpublish:legacy:clear-cache` then reload |
| SQLite `attempt to write a readonly database` | Web server user cannot write the `.db` file | `chmod 664 var/data_*.db && chown $USER:www-data var/data_*.db` |




And at: https://exponential.doc.exponential.earth/display/DEVELOPER/Installation%2bGuide%2bfor%2bUnix-Based%2bSystems.html