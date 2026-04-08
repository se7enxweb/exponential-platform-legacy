# Exponential Platform Legacy v3.x (Platform v3) — Installation & Operations Guide

> **Platform v3** is the foundational pure-platform release: Exponential (Legacy) 6.x kernel +
> LegacyBridge 3.x + Exponential Platform 3.3 OSS + Symfony 5.4 LTS. No Netgen packages are
> included. See the v4 LegacyBridge (LB) release for Netgen Layouts 1.4+ integration.
>
> This guide uses numbered **Git Save Points** so developers can commit working checkpoints
> throughout the installation process and roll back to any known-good state.
>
> This installation is more involved than a standard Symfony project. Read it in full before starting.

---

## Table of Contents

1. [Requirements](#1-requirements)
2. [Architecture Overview](#2-architecture-overview)
3. [First-Time Installation](#3-first-time-installation)
   - [3a. Composer create-project (recommended)](#3a-composer-create-project-recommended)
   - [3b. GitHub git clone (developers)](#3b-github-git-clone-developers)
4. [Environment Configuration (.env.local)](#4-environment-configuration-envlocal)
5. [Database Setup](#5-database-setup)
   - [5a. MySQL / MariaDB](#5a-mysql--mariadb)
   - [5b. PostgreSQL](#5b-postgresql)
6. [Web Server Setup](#6-web-server-setup)
   - [6a. Apache 2.4](#6a-apache-24)
   - [6b. Nginx](#6b-nginx)
   - [6c. Symfony CLI (development only)](#6c-symfony-cli-development-only)
7. [File & Directory Permissions](#7-file--directory-permissions)
8. [Frontend Assets (Site CSS/JS)](#8-frontend-assets-site-cssjs)
9. [Admin UI Assets (Exponential Platform Admin UI)](#9-admin-ui-assets-exponential-platform-admin-ui)
10. [JWT Authentication (REST API)](#10-jwt-authentication-rest-api)
11. [Search Index](#11-search-index)
12. [Image Variations](#12-image-variations)
13. [Cache Management](#13-cache-management)
14. [Day-to-Day Operations: Start / Stop / Restart](#14-day-to-day-operations-start--stop--restart)
15. [Updating the Codebase](#15-updating-the-codebase)
16. [Cron Jobs](#16-cron-jobs)
17. [Solr Search Engine (optional)](#17-solr-search-engine-optional)
18. [Varnish HTTP Cache (optional)](#18-varnish-http-cache-optional)
19. [Docker Development Environment (optional)](#19-docker-development-environment-optional)
20. [Deployer — Zero-Downtime Production Deploys (optional)](#20-deployer--zero-downtime-production-deploys-optional)
21. [Troubleshooting](#21-troubleshooting)
22. [Database Conversion](#22-database-conversion)
    - [22a. MySQL / MariaDB → PostgreSQL](#22a-mysql--mariadb--postgresql)
    - [22b. PostgreSQL → MySQL / MariaDB](#22b-postgresql--mysql--mariadb)
    - [22c. Post-conversion checklist](#22c-post-conversion-checklist)
    - [22d. Any → SQLite (go to SQLite)](#22d-any--sqlite-go-to-sqlite)
    - [22e. SQLite → MySQL / MariaDB](#22e-sqlite--mysql--mariadb)
    - [22f. SQLite → PostgreSQL](#22f-sqlite--postgresql)
    - [22g. SQLite → Oracle](#22g-sqlite--oracle)
    - [22h. Oracle → SQLite](#22h-oracle--sqlite)
    - [22i. MySQL / MariaDB → Oracle](#22i-mysql--mariadb--oracle)
    - [22j. Oracle → MySQL / MariaDB](#22j-oracle--mysql--mariadb)
    - [22k. PostgreSQL → Oracle](#22k-postgresql--oracle)
    - [22l. Oracle → PostgreSQL](#22l-oracle--postgresql)
23. [Complete CLI Reference](#23-complete-cli-reference)

---

## 1. Requirements

### PHP

- **PHP 8.0–8.5** (PHP 8.3 or 8.5 strongly recommended)
- Required extensions: `gd` or `imagick`, `redis`, `curl`, `json`, `pdo_mysql` or `pdo_pgsql` or `pdo_sqlite`,
  `xsl`, `xml`, `intl`, `mbstring`, `opcache`, `ctype`, `iconv`
- For SQLite: `pdo_sqlite` + `sqlite3` extensions (usually bundled with PHP; verify with `php -m | grep -i sqlite`)
- `memory_limit` ≥ 256M (set in `php.ini` or `.htaccess`; restart web server after changes)
- `date.timezone` must be set in `php.ini` or `.htaccess` — see https://php.net/manual/en/timezones.php
- `max_execution_time` ≥ 90 (recommended 300 for CLI)

### Web Server

- **Apache 2.4** with `mod_rewrite`, `mod_deflate`, `mod_headers`, `mod_expires` enabled;
  run in `event` or `worker` mode with PHP-FPM (prefork mode also works but is not recommended)
  _or_
- **Nginx 1.18+** with PHP-FPM

### Node.js & Yarn

- **[Node.js](https://nodejs.org/en/download/) 18 LTS** — managed via [nvm](https://github.com/nvm-sh/nvm) (recommended on all platforms); `.nvmrc` is present in the project root
- **[Yarn](https://classic.yarnpkg.com/en/docs/install) 1.22.x** — `npm install -g yarn`

**Installing nvm + Node.js 18 LTS (all UNIX / macOS / BSD / WSL):**

```bash
# Universal installer — works on Linux (all distros), macOS, BSD, WSL
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
source ~/.nvm/nvm.sh           # or restart your shell
nvm install 18
nvm use 18
npm install -g yarn
```

**Platform-specific Node.js 18 LTS install options:**

| Platform | Method | Command |
|---|---|---|
| All UNIX/macOS/BSD/WSL | nvm (recommended) | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh \| bash && nvm install 18` |
| Ubuntu / Debian | NodeSource apt repo | `curl -fsSL https://deb.nodesource.com/setup_18.x \| sudo -E bash - && sudo apt install -y nodejs` |
| RHEL / CentOS / Rocky / Alma | NodeSource rpm repo | `curl -fsSL https://rpm.nodesource.com/setup_18.x \| sudo bash - && sudo yum install -y nodejs` |
| Fedora | dnf | `sudo dnf install nodejs` |
| Arch / Manjaro | pacman | `sudo pacman -S nodejs npm` |
| macOS (Homebrew) | brew | `brew install node@18 && brew link node@18 --force` |
| macOS (MacPorts) | port | `sudo port install nodejs18` |
| FreeBSD | pkg | `sudo pkg install node18 npm-node18` |
| OpenBSD | pkg_add | `doas pkg_add node` |
| Alpine Linux | apk | `apk add nodejs npm` |
| Windows WSL2 | nvm (in WSL) | Same as "All UNIX" row above |

### Composer

- **Composer 2.x** — run `composer self-update` to ensure you are on the latest 2.x release

### Database

- **MySQL 8.0+** with `utf8mb4` character set and `utf8mb4_unicode_520_ci` collation
  _or_
- **MariaDB 10.3+**
  _or_
- **PostgreSQL 14+**
  _or_
- **SQLite 3.35+** — no server required; the `.db` file is created automatically on first install.
  Recommended for **local development, testing, demos, and air-gapped deployments** only.
  Requires `pdo_sqlite` and `sqlite3` PHP extensions.

### Optional

- **Redis 6+** — recommended for production caching and sessions
- **Solr 7.7 or 8.11.x** — for advanced full-text search (default engine is `legacy`)
- **Varnish 6.0 or 7.1+** with [`varnish-modules`](https://github.com/varnish/varnish-modules) — for HTTP reverse-proxy caching
- **ImageMagick** — for advanced image processing (`IMAGEMAGICK_PATH` env var, default `/usr/bin`)
- **Docker + Docker Compose** — for containerised development (`doc/docker/`)
- **PHP Deployer** — for zero-downtime production deployment (`deploy.php`)

---

## 2. Architecture Overview

Platform v3 runs **two fully-operational content kernels** in a single application:

```
Browser Request
      │
      ▼
  Symfony 5.4 LTS (front controller: public/index.php)
      │
      ├── LegacyBridge 3.x ──► Exponential (Legacy) 6.x Kernel
      │                              Legacy TPL templates
      │                              Legacy modules / workflows
      │                              Legacy Admin (/ezpublish_legacy/)
      │
      └── Exponential Platform 3.3 OSS New Stack
                 Symfony Controllers / Twig templates
                 REST API v2 (/api/ezp/v2/)
                 GraphQL API
                 Platform Admin UI (/adminui/)
                 Netgen Layouts (NOT included in Platform v3)
```

**Both kernels share the same database.** Doctrine ORM (new stack) and the Legacy database abstraction layer both connect to the same MySQL/MariaDB/PostgreSQL database. The Legacy kernel writes to `ezpublish_legacy/var/` for cache and compiled templates; the new stack uses `var/` for Symfony cache.

**Key version differences from Platform v4 (LB release):**
- Platform v3 uses **Node.js 18 LTS** (v4 uses Node.js 20 LTS)
- Platform v3 uses **LegacyBridge 3.x** (v4 uses LegacyBridge 4.x)
- Platform v3 runs **eZ Platform / Exponential Platform 3.3 OSS** (v4 runs Platform 4 OSS)
- Platform v3 does **not include Netgen Layouts** (v4 includes Netgen Layouts 1.4+)
- Platform v3 install command: `ezplatform:install exponential-oss` (v4: `ibexa:install exponential-oss`)
- Platform v3 `memory_limit` ≥ 256M (v4 ≥ 512M due to dual-kernel overhead)

---

## 3. First-Time Installation

### 3a. Composer create-project (recommended)

```bash
composer create-project se7enxweb/exponential-platform-legacy:3.x-dev exponential_website
cd exponential_website
```

Then continue at [Step 3 — Environment Configuration](#4-environment-configuration-envlocal).

### 3b. GitHub git clone (developers)

Follow each step in order. Save points are marked — commit at each one so you can return to any
working state without redoing completed work.

#### Step 1 — Clone the repository

```bash
git clone git@github.com:se7enxweb/exponential-platform-legacy.git
cd exponential-platform-legacy

# Check out the Platform v3 branch
git checkout 3.x
```

#### Step 2 — Install PHP dependencies

```bash
composer install --keep-vcs
```

This downloads all packages from Packagist / GitHub into `vendor/`. It also runs Symfony's
`post-install-cmd` scripts (asset install, autoload regeneration).

> 💾 **Git Save Point 1 — Vendors installed**
> ```bash
> git add composer.lock && git commit -m "chore(install): lock vendor dependencies at install"
> ```

#### Step 3 — Configure environment

```bash
cp .env .env.local
$EDITOR .env.local
# Required: DATABASE_URL (or individual DATABASE_* vars), APP_SECRET, APP_ENV
# See Section 4 for the full .env.local reference
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
php bin/console ezplatform:install exponential-oss
```

The demo data creates an administrator user: **username** `admin`, **password** `publish`.
**Change this immediately after installation** via the Legacy Admin or the Exponential Platform Admin UI.

> 💾 **Git Save Point 2 — Database provisioned**
> ```bash
> git commit -m "chore(install): database created and demo data imported"
> ```

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

See [Section 7](#7-file--directory-permissions) for full details.

#### Step 8 — Build frontend assets

```bash
nvm use           # activate Node 18 per .nvmrc
yarn install      # install Node dependencies
yarn build:dev    # build site CSS/JS with source maps
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
> ```bash
> git commit -m "chore(install): platform v3 install complete — assets, jwt, cache cleared, search indexed"
> ```

#### Step 13 — Start the dev server (development only)

```bash
symfony server:start
```

Access points after install:

| URL | What you get |
|---|---|
| `https://127.0.0.1:8000/` | Public site (hybrid Twig + Legacy TPL) |
| `https://127.0.0.1:8000/adminui/` | Exponential Platform Admin UI (new stack, React) |
| `https://127.0.0.1:8000/ezpublish_legacy/` | Legacy Admin (classic) |
| `https://127.0.0.1:8000/api/ezp/v2/` | REST API v2 |

Or use the Makefile shortcut (runs all steps above after vendor install):

```bash
make build            # dev (steps 2–12 in one command)
APP_ENV=prod make build   # production equivalent
```

---

## 4. Environment Configuration (.env.local)

**Never commit `.env.local`.** It overrides `.env` with host-specific secrets.

Create: `cp .env .env.local`

### Minimum required variables

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

# You may also set it directly as a DSN if preferred:
# DATABASE_URL="mysql://your_db_user:your_db_password@127.0.0.1:3306/your_db_name?serverVersion=8.0&charset=utf8mb4"
```

### PostgreSQL alternative to MySQL

```dotenv
DATABASE_DRIVER=pdo_pgsql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=5432
DATABASE_NAME=your_db_name
DATABASE_USER=your_db_user
DATABASE_PASSWORD=your_db_password
DATABASE_CHARSET=utf8
DATABASE_VERSION=16
# DATABASE_URL="pgsql://your_db_user:your_db_password@127.0.0.1:5432/your_db_name?serverVersion=16"
```

### SQLite (zero-config — dev / testing)

SQLite requires **no database server**. The `.db` file is created on disk automatically
when you run the install command. It is the fastest way to get a local development
environment running without installing MySQL or PostgreSQL.

```dotenv
# Replace (or override) the DATABASE_URL line in .env.local:
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_%kernel.environment%.db"

# Symfony's async messenger must use the synchronous transport with SQLite
# (the default doctrine transport requires a second DB connection that may not
#  be available on SQLite; sync:// avoids this entirely):
MESSENGER_TRANSPORT_DSN=sync://
```

> **Notes:**
> - The DB file path evaluates to e.g. `var/data_dev.db` or `var/data_prod.db`.
> - Do **not** set `DATABASE_DRIVER`, `DATABASE_HOST`, `DATABASE_PORT`, etc. when using the
>   `DATABASE_URL` DSN form — they are only used when the URL is constructed from parts.
> - The `pdo_sqlite` and `sqlite3` PHP extensions must be enabled. Verify: `php -m | grep -i sqlite`
> - After install, make the DB file writable by the web server:
>   ```bash
>   chmod 664 var/data_dev.db
>   chown $USER:www-data var/data_dev.db   # adjust group to your web server user
>   ```
> - **Not recommended for production** — SQLite does not support concurrent writes under load.
>   Use MySQL/MariaDB or PostgreSQL for any multi-user or public-facing deployment.

### Search, cache, and HTTP cache

```dotenv
# Search engine: "legacy" (default) or "solr"
SEARCH_ENGINE=legacy

# HTTP cache
HTTPCACHE_PURGE_TYPE=local       # or "varnish" when using Varnish
HTTPCACHE_DEFAULT_TTL=86400
HTTPCACHE_PURGE_SERVER=http://localhost:80

# Cache backend: "cache.tagaware.filesystem" (default), "cache.redis", "cache.memcached"
CACHE_POOL=cache.tagaware.filesystem
```

### Redis caching

```dotenv
CACHE_POOL=cache.redis
CACHE_DSN=redis://localhost:6379
```

### Solr search

```dotenv
SEARCH_ENGINE=solr
SOLR_DSN=http://localhost:8983/solr
SOLR_CORE=collection1
```

### Varnish HTTP cache

```dotenv
HTTPCACHE_PURGE_TYPE=varnish
HTTPCACHE_PURGE_SERVER=http://127.0.0.1:6081
HTTPCACHE_VARNISH_INVALIDATE_TOKEN=<your-secret>
TRUSTED_PROXIES=127.0.0.1
```

### Other common variables

```dotenv
MAILER_DSN=smtp://localhost:25
SENTRY_DSN=                     # optional: Sentry error reporting
SERVER_ENVIRONMENT=dev           # controls config/app/server/<value>/ overrides
IMAGEMAGICK_PATH=/usr/bin        # path to ImageMagick binaries
MESSENGER_TRANSPORT_DSN=doctrine://default?auto_setup=0
```

> 💾 **Git Save Point — Environment template**
> Create a `.env.local.dist` with secrets redacted as a reference for other developers:
> ```bash
> cp .env.local .env.local.dist
> # Redact all secrets, then:
> git add .env.local.dist && git commit -m "docs: add .env.local.dist as environment reference"
> ```

---

## 5. Database Setup

### 5a. MySQL / MariaDB

#### Create the database

```sql
CREATE DATABASE exponential
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_520_ci;
```

Or from the shell:

```bash
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
```

#### Import schema and demo data

```bash
php bin/console ezplatform:install exponential-oss
```

Available installer types:
- `exponential-oss` — full schema + demo content (recommended for first install)
- `clean` — schema only, no demo content

The demo data creates: **username** `admin`, **password** `publish`. Change this immediately.

### 5b. PostgreSQL

#### Create the database

```bash
sudo -u postgres psql -c "CREATE DATABASE exponential ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8' TEMPLATE template0;"
```

Set `DATABASE_DRIVER=pdo_pgsql` and the PostgreSQL vars in `.env.local` (see Section 4), then:

```bash
php bin/console ezplatform:install exponential-oss
```

### 5c. SQLite (dev/testing)

SQLite requires no server. The database file is created automatically by the installer.

#### Step 1 — Verify PHP extensions

```bash
php -m | grep -i sqlite
# Expected output should include both:
#   SQLite3
#   pdo_sqlite
```

If either is missing, enable them in `php.ini` (e.g. `extension=pdo_sqlite` and `extension=sqlite3`)
and restart your web server / PHP-FPM.

#### Step 2 — Configure `.env.local`

Replace (or add) the `DATABASE_URL` line and add the messenger transport:

```dotenv
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_%kernel.environment%.db"
MESSENGER_TRANSPORT_DSN=sync://
```

Remove or comment out any `DATABASE_DRIVER`, `DATABASE_HOST`, `DATABASE_PORT`,
`DATABASE_NAME`, `DATABASE_USER`, `DATABASE_PASSWORD` lines — they are not used
when a full DSN is provided.

#### Step 3 — Run the installer

```bash
php bin/console ezplatform:install exponential-oss
```

This single command:
1. Creates the SQLite `.db` file at `var/data_<environment>.db` (e.g. `var/data_dev.db`)
2. Imports the Exponential OSS schema (156 queries from `data/sqlite/cleandata.sql`)
3. Seeds demo content — creates content types, content objects, users, roles
4. Creates the Doctrine ORM tables

Default administrator credentials: **username** `admin` / **password** `publish`.
**Change the admin password immediately** after installation.

#### Step 4 — Fix file permissions

```bash
chmod 664 var/data_dev.db
chown $USER:www-data var/data_dev.db   # replace www-data with your web server group
```

#### Step 5 — Clear caches

```bash
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache
```

#### SQLite limitations

| Limitation | Impact |
|---|---|
| No concurrent write transactions | Under heavy or concurrent load, writes queue and can timeout. Use MySQL/MariaDB for production. |
| No replication or clustering | Cannot be used in multi-server (cluster) deployments |
| No `FULLTEXT` index | Legacy kernel full-text search falls back to `LIKE` queries |
| File-level locking | File must be on a local filesystem — NFS/CIFS mounts not supported |

> **TL;DR:** SQLite is ideal for **local development, automated testing, and demos**.
> Use MySQL 8.0+, MariaDB 10.3+, or PostgreSQL 14+ for any public-facing production deployment.

> 💾 **Git Save Point — SQLite install complete**
> ```bash
> git commit --allow-empty -m "chore(install): sqlite database provisioned for dev"
> ```

### Run Doctrine migrations (on updates)

```bash
php bin/console doctrine:migration:migrate --allow-no-migration
# or via Makefile:
make migrations
```

> 💾 **Git Save Point — After each migration run**
> ```bash
> git add migrations/ && git commit -m "feat(db): run doctrine migrations $(date +%Y-%m-%d)"
> ```

---

## 6. Web Server Setup

### 6a. Apache 2.4

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
DocumentRoot /var/www/exponential_website/public

SetEnvIf Request_URI ".*" APP_ENV=prod
SetEnv APP_DEBUG "0"
SetEnv APP_HTTP_CACHE "1"    # set to "0" when using Varnish

<Directory /var/www/exponential_website/public>
    AllowOverride None
    Require all granted
</Directory>
```

> See `doc/apache2/media-site-vhost.conf` for the full rewrite rule set.

### 6b. Nginx

Use the provided template:

```bash
cp doc/nginx/media-site.conf /etc/nginx/sites-available/exponential.conf
# Edit server_name, root, fastcgi_pass (PHP-FPM socket/host), then:
ln -s /etc/nginx/sites-available/exponential.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

Key directives:

```nginx
root /var/www/exponential_website/public;

location ~ ^/index\.php(/|$) {
    fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    fastcgi_param APP_ENV prod;
    fastcgi_param APP_DEBUG 0;
    fastcgi_param APP_HTTP_CACHE 1;
    include fastcgi_params;
}
```

> See `doc/nginx/media-site.conf` for the full configuration including legacy kernel pass-through.

### 6c. Symfony CLI (development only)

```bash
symfony server:start          # starts HTTPS dev server on https://127.0.0.1:8000
symfony server:start -d       # run in background (daemon)
symfony server:stop           # stop the background server
symfony server:log            # tail server log
symfony server:status         # show server status + URL
```

---

## 7. File & Directory Permissions

Replace `www-data` with your actual web server user (e.g. `apache`, `nginx`, `_www` on macOS).
The `ezpublish_legacy/var/` directory must also be writable — it stores legacy cache, log files,
compiled templates, and uploaded content objects.

```bash
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
```

If `setfacl` is unavailable, fall back to `chmod`/`chown`:

```bash
chown -R www-data:www-data var public/var ezpublish_legacy/var
chmod -R 775 var public/var ezpublish_legacy/var
```

> **Note for development:** If your CLI user and web server user are different, the ACL approach
> allows both to write. This avoids `Permission denied` errors when alternating between
> `php bin/console` (CLI user) and web requests (www-data).

Refer to the [Symfony file permissions guide](https://symfony.com/doc/5.4/setup/file_permissions.html) for full details.

---

## 8. Frontend Assets (Site CSS/JS)

The project uses Webpack Encore + Yarn. The Exponential Platform Admin UI webpack config is kept
separate in `webpack.config.ez.js` — the site's own `webpack.config.js` controls the site theme assets.

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

## 9. Admin UI Assets (Exponential Platform Admin UI)

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

Dump JS translation assets separately:

```bash
php bin/console bazinga:js-translation:dump public/assets --merge-domains
```

### Install Symfony public assets (bundle `public/` directories → `public/bundles/`)

```bash
php bin/console assets:install --symlink --relative public
```

This is run automatically by `composer install`/`update`, but can be run manually when needed.

---

## 10. JWT Authentication (REST API)

```bash
# Generate RSA keypair (initial setup)
php bin/console lexik:jwt:generate-keypair
# → writes config/jwt/private.pem  and  config/jwt/public.pem (git-ignored — back up separately)

# Overwrite existing keypair (key rotation)
php bin/console lexik:jwt:generate-keypair --overwrite

# After key rotation, clear cache
php bin/console cache:clear
```

---

## 11. Search Index

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

## 12. Image Variations

Image variations in Platform v3 are generated **on demand** by Liip Imagine when a content view
requests a variation alias. Configuration lives in `config/packages/ezplatform.yml` under
`ezplatform.system.<siteaccess>.image_variations`.

### Clear generated image variation cache

```bash
php bin/console liip:imagine:cache:remove
php bin/console liip:imagine:cache:remove --filter=<variation_alias>
# Then clear Symfony cache so image configuration reloads:
php bin/console cache:clear
```

You can also remove cached files directly:

```bash
rm -rf public/var/storage/images/
php bin/console cache:clear
```

### List configured variation aliases

```bash
php bin/console debug:config ezplatform | grep -A5 image_variations
```

### Sample variation configuration (config/packages/ezplatform.yml)

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

---

## 13. Cache Management

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
php bin/console cache:pool:list                # list all registered cache pools
# or:
make clear-all-cache
```

### Purge HTTP cache (Varnish/local)

```bash
php bin/console fos:httpcache:invalidate:path / --all
php bin/console fos:httpcache:invalidate:tag <tag>
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

## 14. Day-to-Day Operations: Start / Stop / Restart

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
nginx -s reload             # alternative
```

### PHP-FPM

```bash
systemctl restart php8.3-fpm
systemctl reload php8.3-fpm     # graceful (for `php.ini` changes)
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
symfony server:status           # show URL + status
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

# 7. Dump JS translations
php bin/console bazinga:js-translation:dump public/assets --merge-domains

# 8. Clear & warm up cache
php bin/console cache:clear --env=prod
php bin/console ezpublish:legacy:clear-cache
php bin/console cache:warmup --env=prod

# 9. Reindex if content model changed
# php bin/console ezplatform:reindex --env=prod
```

Or using the Makefile:

```bash
make refresh              # git pull + full build (dev)
APP_ENV=prod make refresh # git pull + full build (prod)
```

> 💾 **Git Save Point — After each production deploy**
> ```bash
> git tag -a "deploy-$(date +%Y%m%d-%H%M)" -m "production deploy $(date +%Y-%m-%d)"
> git push origin --tags
> ```

---

## 15. Updating the Codebase

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
composer update                             # update all within constraints
composer update se7enxweb/legacy-bridge     # update a single package

# After update, always run:
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console cache:clear
php bin/console ezplatform:reindex          # if search engine schema may have changed
```

> 💾 **Git Save Point — After composer update**
> ```bash
> git add composer.lock && git commit -m "chore(deps): composer update $(date +%Y-%m-%d)"
> ```

### Update Node packages

```bash
yarn upgrade           # update within semver constraints
yarn build:dev         # rebuild after update
```

### Regenerate legacy autoloads (after adding/removing legacy extensions)

```bash
php bin/console ezpublish:legacy:generate-autoloads
# or from inside the legacy directory:
cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php
```

---

## 16. Cron Jobs

Add the following to crontab (`crontab -e -u www-data`):

```cron
# Exponential Platform cron runner (every 5 minutes)
*/5 * * * * /usr/bin/php /var/www/exponential_website/bin/console ezplatform:cron:run --env=prod >> /var/log/exponential-cron.log 2>&1

# Exponential (Legacy) cron runner — via LegacyBridge (if using legacy cronjobs)
*/5 * * * * /usr/bin/php /var/www/exponential_website/ezpublish_legacy/runcronjobs.php --siteaccess legacy_admin >> /var/log/exponential-legacy-cron.log 2>&1
```

---

## 17. Solr Search Engine (optional)

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

## 18. Varnish HTTP Cache (optional)

1. Set env vars (see Section 4):
   ```dotenv
   HTTPCACHE_PURGE_TYPE=varnish
   HTTPCACHE_PURGE_SERVER=http://127.0.0.1:6081
   HTTPCACHE_VARNISH_INVALIDATE_TOKEN=<your-secret>
   TRUSTED_PROXIES=127.0.0.1
   ```
2. Set `APP_HTTP_CACHE=0` in your web server vhost (let Varnish handle caching).
3. Load the eZ Platform Varnish VCL — a starting-point VCL template is in `doc/varnish/`.
   Refer to the eZ Platform 3.3 documentation for the appropriate `.vcl` file.

---

## 19. Docker Development Environment (optional)

A Docker-based development environment is provided in `doc/docker/`. It uses Docker Compose to run
PHP-FPM, Nginx, MySQL, Redis, and Mailhog in a local stack.

```bash
# Start the Docker dev environment
docker compose -f compose.yaml -f compose.override.yaml up -d

# Stop it
docker compose down

# Run a console command inside the container
docker compose exec php php bin/console cache:clear

# Access the running site
# → http://localhost:8080
```

See `doc/docker/README.md` for full configuration options, environment variables, and troubleshooting.

---

## 20. Deployer — Zero-Downtime Production Deploys (optional)

The project includes a [PHP Deployer](https://deployer.org/) configuration (`deploy.php`) for
zero-downtime production deployments. Deployer manages symlinks and maintains release directories
so each deploy is atomic.

```bash
# Deploy to the production server
vendor/bin/dep deploy production

# List available tasks
vendor/bin/dep list

# Roll back to the previous release
vendor/bin/dep rollback production
```

See `deploy.php` and `deploy/` for server configuration and customisation. The `deploy.php` file
defines servers, shared files, shared directories, and writable paths.

---

## 21. Troubleshooting

### White screen / 500 error

```bash
tail -f var/log/dev.log
tail -f var/log/prod.log
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
php bin/console assets:install --symlink --relative public
yarn build:dev
yarn ez
```

### Cache not clearing / stale content

```bash
# Nuclear option: delete cache directories
rm -rf var/cache/dev var/cache/prod
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
php bin/console ezpublish:legacy:clear-cache
php bin/console assets:install --symlink --relative public
php bin/console ezpublish:legacy:generate-autoloads
```

### "Autoload arrays not found" in Legacy kernel

```bash
cd ezpublish_legacy
php bin/php/ezpgenerateautoloads.php
php bin/php/ezpgenerateautoloads.php --extension
```

---

## 22. Database Conversion

This section covers converting between the supported database engines for Platform v3.
All conversions require a full content freeze during migration and a verification pass afterward.

### 22a. MySQL / MariaDB → PostgreSQL

**Tools needed:** [`pgloader`](https://pgloader.io/) — the standard FOSS tool for MySQL → PostgreSQL migration.

**Installing pgloader (cross-platform):**

| Platform | Method | Command |
|---|---|---|
| Ubuntu / Debian | apt | `sudo apt install pgloader` |
| RHEL / CentOS / Rocky / Alma | dnf | `sudo dnf install pgloader` |
| Fedora | dnf | `sudo dnf install pgloader` |
| Arch / Manjaro | pacman | `sudo pacman -S pgloader` |
| macOS (Homebrew) | brew | `brew install pgloader` |
| FreeBSD | pkg | `sudo pkg install pgloader` |
| All platforms | Docker | `docker run --rm -it dimitri/pgloader pgloader ...` |
| Source | GitHub | [github.com/dimitri/pgloader](https://github.com/dimitri/pgloader) |

**Migration steps:**

```bash
# 1. Create the target PostgreSQL database
sudo -u postgres psql -c "CREATE DATABASE exponential_pg ENCODING 'UTF8' TEMPLATE template0;"

# 2. Create pgloader configuration (exponential.load)
cat > exponential.load << 'EOF'
LOAD DATABASE
    FROM    mysql://db_user:db_pass@127.0.0.1:3306/exponential
    INTO    pgsql://pg_user:pg_pass@127.0.0.1:5432/exponential_pg

WITH include drop, create tables, create indexes, reset sequences,
     workers = 4, concurrency = 1,
     multiple readers per thread, rows per range = 50000

SET PostgreSQL PARAMETERS
    maintenance_work_mem to '128MB',
    work_mem to '12MB'

CAST type tinyint to smallint using integer-to-string to string-to-int,
     type datetime to timestamptz using zero-dates-to-null,
     type date to date using zero-dates-to-null

EXCLUDING TABLE NAMES MATCHING 'ezsearch_object_word_link'
;
EOF

# 3. Run pgloader
pgloader exponential.load

# 4. Update .env.local to use PostgreSQL
# DATABASE_DRIVER=pdo_pgsql
# DATABASE_HOST=127.0.0.1
# DATABASE_PORT=5432
# DATABASE_NAME=exponential_pg
# etc.

# 5. Clear Symfony cache
php bin/console cache:clear --env=prod

# 6. Reindex search
php bin/console ezplatform:reindex
```

### 22b. PostgreSQL → MySQL / MariaDB

**Tools needed:**
- [`pg_dump`](https://www.postgresql.org/docs/current/app-pgdump.html) (bundled with PostgreSQL client tools)
- [`pgloader`](https://pgloader.io/) (for automated schema + data conversion)

**Installing PostgreSQL client tools (for `pg_dump`):**

| Platform | Command |
|---|---|
| Ubuntu / Debian | `sudo apt install postgresql-client` |
| RHEL / CentOS / Rocky | `sudo dnf install postgresql` |
| macOS (Homebrew) | `brew install libpq && brew link --force libpq` |
| FreeBSD | `sudo pkg install postgresql16-client` |
| Alpine | `apk add postgresql16-client` |
| All platforms | [postgresql.org/download](https://www.postgresql.org/download/) |

**Migration steps using pgloader:**

```bash
# 1. Create target MySQL database
mysql -u root -p -e "CREATE DATABASE exponential_my CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"

# 2. Create pgloader configuration (pg-to-mysql.load)
cat > pg-to-mysql.load << 'EOF'
LOAD DATABASE
    FROM    pgsql://pg_user:pg_pass@127.0.0.1:5432/exponential
    INTO    mysql://db_user:db_pass@127.0.0.1:3306/exponential_my

WITH include drop, create tables, create indexes, reset sequences
;
EOF

pgloader pg-to-mysql.load

# 3. Update .env.local to use MySQL/MariaDB and clear cache
php bin/console cache:clear --env=prod
php bin/console ezplatform:reindex
```

### 22c. Post-conversion checklist

After any database engine change:

- [ ] Update `DATABASE_URL` (or individual `DATABASE_*` vars) in `.env.local`
- [ ] Run `php bin/console cache:clear --env=prod`
- [ ] Run `php bin/console ezpublish:legacy:clear-cache`
- [ ] Run `php bin/console doctrine:schema:validate`
- [ ] Run `php bin/console doctrine:migration:migrate --allow-no-migration`
- [ ] Run `php bin/console ezplatform:reindex`
- [ ] Test the Legacy Admin: log in, browse content, publish a test item
- [ ] Test the public site: browse several pages, check images load
- [ ] Test REST API: `curl https://your-site.com/api/ezp/v2/ -H "Accept: application/json"`
- [ ] Verify user login works in the admin interface
- [ ] Check the Symfony log for errors: `tail -100 var/log/prod.log`
- [ ] If SQLite target — verify file permissions: `ls -la var/data_*.db`

---

### 22d. Any → SQLite (go to SQLite)

Use this path to migrate an existing MySQL/MariaDB or PostgreSQL database **into SQLite**
for local development, testing, or air-gapped demos.

> ⚠️ **SQLite is dev/testing only.** See [Section 5c](#5c-sqlite-devtesting) for full limitations.

#### From MySQL / MariaDB → SQLite

Use the [**mysql2sqlite**](https://github.com/dumblob/mysql2sqlite) shell script (MIT licence,
no dependencies beyond `bash` and `sqlite3`):

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

> `--skip-extended-insert` produces one `INSERT` per row — slower but required by the converter.
> For large databases, dump table-by-table:

```bash
TABLES=$(mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" -h "$DATABASE_HOST" "$DATABASE_NAME" \
  -e 'SHOW TABLES;' --batch --skip-column-names)

for TABLE in $TABLES; do
  mysqldump --no-tablespaces --skip-extended-insert --compact \
    -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" -h "$DATABASE_HOST" "$DATABASE_NAME" "$TABLE" \
    | ./mysql2sqlite - >> /tmp/dump.sql
done

sqlite3 var/data_dev.db < /tmp/dump.sql
```

#### From PostgreSQL → SQLite

Use [**pgloader**](https://pgloader.io) (PostgreSQL-licenced):

```bash
apt install pgloader          # Debian/Ubuntu
# brew install pgloader       # macOS

# Create an empty target file
touch var/data_dev.db

# Write a pgloader command file
cat > /tmp/pg_to_sqlite.load << EOF
LOAD DATABASE
  FROM postgresql://db_user:db_pass@127.0.0.1/db_name
  INTO sqlite:///$(pwd)/var/data_dev.db

WITH include no drop, create tables, create indexes, reset sequences;
EOF

pgloader /tmp/pg_to_sqlite.load
```

#### After migrating to SQLite — update `.env.local`

```dotenv
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_dev.db"
MESSENGER_TRANSPORT_DSN=sync://
```

Fix permissions and clear caches (see [Section 5c](#5c-sqlite-devtesting) steps 4–5).

---

### 22e. SQLite → MySQL / MariaDB

Create the target database first (see [Section 5a](#5a-mysql--mariadb)).

#### Method 1 — [sqlite3-to-mysql](https://github.com/techouse/sqlite3-to-mysql) (Python, MIT)

```bash
pip install sqlite3-to-mysql

sqlite3mysql \
  --sqlite-file var/data_dev.db \
  --mysql-database "$DATABASE_NAME" \
  --mysql-user "$DATABASE_USER" \
  --mysql-password "$DATABASE_PASSWORD" \
  --mysql-host "$DATABASE_HOST" \
  --mysql-port 3306 \
  --chunk 1000
```

**Installing sqlite3-to-mysql:**

| Platform | Command |
|---|---|
| Debian / Ubuntu / Mint | `apt install python3 python3-pip && pip3 install sqlite3-to-mysql` |
| RHEL / AlmaLinux / Rocky | `dnf install python3 python3-pip && pip3 install sqlite3-to-mysql` |
| Fedora | `dnf install python3 && pip3 install sqlite3-to-mysql` |
| Arch / Manjaro | `pacman -S python && pip install sqlite3-to-mysql` |
| macOS | `pip3 install sqlite3-to-mysql` |
| FreeBSD | `pkg install python3 && pip3 install sqlite3-to-mysql` |
| Generic | [pypi.org/project/sqlite3-to-mysql](https://pypi.org/project/sqlite3-to-mysql/) |

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

> The sed approach is fragile on complex schemas. Prefer `sqlite3-to-mysql` for production migrations.

#### After migrating — update `.env.local`

```dotenv
DATABASE_DRIVER=pdo_mysql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=3306
DATABASE_NAME=your_db_name
DATABASE_USER=your_db_user
DATABASE_PASSWORD=your_db_password
DATABASE_CHARSET=utf8mb4
DATABASE_COLLATION=utf8mb4_unicode_520_ci
DATABASE_VERSION=mariadb-10.x   # or 8.0 for MySQL
# Remove DATABASE_URL=sqlite:// and MESSENGER_TRANSPORT_DSN=sync://
```

---

### 22f. SQLite → PostgreSQL

Use [**pgloader**](https://pgloader.io) — it has native SQLite source support:

```bash
apt install pgloader   # Debian/Ubuntu; brew install pgloader for macOS

# Create the target database
psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8' TEMPLATE template0;"

# Write a pgloader command file
cat > /tmp/sqlite_to_pg.load << EOF
LOAD DATABASE
  FROM sqlite:///$(pwd)/var/data_dev.db
  INTO postgresql://pg_user:pg_pass@127.0.0.1/exponential

WITH include no drop, create tables, create indexes, reset sequences;
EOF

pgloader /tmp/sqlite_to_pg.load
```

pgloader handles type mapping (INTEGER → bigint, TEXT → text, REAL → double precision),
index creation, and sequence reset so `nextval()` picks up after the highest existing ID.

**Installing pgloader:**

| Platform | Command |
|---|---|
| Debian / Ubuntu / Mint | `apt install pgloader` |
| Fedora | `dnf install pgloader` |
| Arch / Manjaro | AUR: `yay -S pgloader` |
| macOS (Homebrew) | `brew install pgloader` |
| FreeBSD | `pkg install pgloader` |
| Docker (any OS) | `docker run --rm -it dimitri/pgloader pgloader <args>` |
| From source | `git clone https://github.com/dimitri/pgloader && cd pgloader && make pgloader` |

#### After migrating — update `.env.local`

```dotenv
DATABASE_DRIVER=pdo_pgsql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=5432
DATABASE_NAME=exponential
DATABASE_USER=pg_user
DATABASE_PASSWORD=pg_pass
DATABASE_CHARSET=utf8
DATABASE_VERSION=16
# Remove DATABASE_URL=sqlite:// and MESSENGER_TRANSPORT_DSN=sync://
```

Then run the post-conversion checklist ([Section 22c](#22c-post-conversion-checklist)).

---

### 22g. SQLite → Oracle

Oracle XE (Express Edition) is free to use for development. The recommended FOSS path
is to export SQLite via its `.dump` command, then load into Oracle using **SQLcl** (Oracle’s
free CLI) or a JDBC-based tool.

#### Method — CSV export + Oracle SQLcl import

```bash
# 1. Export each table from SQLite as CSV
mkdir -p /tmp/sqlite_csv
sqlite3 -header -csv var/data_dev.db .dump   # schema reference

TABLES=$(sqlite3 var/data_dev.db "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;")
for TABLE in $TABLES; do
  sqlite3 -header -csv var/data_dev.db "SELECT * FROM \"$TABLE\";" > /tmp/sqlite_csv/$TABLE.csv
done

# 2. Create the schema in Oracle (use Doctrine schema:create or a manual DDL)
# Oracle XE free download: https://www.oracle.com/database/technologies/xe-downloads.html
# SQLcl free download: https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/

# 3. Load each CSV with SQLcl
for CSV in /tmp/sqlite_csv/*.csv; do
  TABLE=$(basename "$CSV" .csv)
  sql -s oracle_user/oracle_pass@localhost:1521/XEPDB1 <<EOF
    SET FEEDBACK OFF
    LOAD DATA INFILE '$CSV'
    APPEND INTO TABLE "$TABLE"
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    FIRST ROW IS HEADER;
EOF
done
```

**Installing SQLcl:**

| Platform | Command / Download |
|---|---|
| All platforms | [oracle.com/database/sqldeveloper/technologies/sqlcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/) — zip download, Java 11+ required |
| Homebrew (macOS) | `brew install --cask sqlcl` |
| Debian / Ubuntu | Download the zip; `unzip sqlcl-*.zip -d /opt/sqlcl && ln -s /opt/sqlcl/bin/sql /usr/local/bin/sql` |

> Oracle requires `pdo_oci` or `oci8` PHP extensions. Set `DATABASE_URL` as:
> ```dotenv
> DATABASE_URL="oci8://oracle_user:oracle_pass@localhost:1521/XEPDB1"
> ```
> There is no `pdo_oracle`; use `oci8` driver in Doctrine: `DATABASE_DRIVER=oci8`.

---

### 22h. Oracle → SQLite

Export from Oracle using **ora2pg** (GPL v3, the industry-standard Oracle → FOSS migration tool)
or **SQLcl CSV export**, then load into SQLite.

#### Method 1 — ora2pg (Oracle → SQL dump → SQLite)

```bash
apt install ora2pg   # Debian/Ubuntu; see ora2pg docs for other platforms
# ora2pg: https://github.com/darold/ora2pg

# Minimal ora2pg config
cat > /tmp/ora2pg.conf << 'EOF'
ORACLE_DSN  dbi:Oracle:host=oracle_host;sid=ORCL
ORACLE_USER system
ORACLE_PWD  password
SCHEMA      YOUR_SCHEMA
TYPE        TABLE, INSERT, SEQUENCE, INDEX, CONSTRAINT
OUT_FILE    /tmp/ora_export.sql
QUOTE_STRING_WITH_DOLLAR 0
EOF

ora2pg -c /tmp/ora2pg.conf

# The output SQL is PostgreSQL dialect; convert to SQLite via pgloader:
touch var/data_dev.db

# Load into PostgreSQL first, then use the SQLite -> PostgreSQL path in reverse:
# (or pipe the DDL through sed to strip PostgreSQL-specific syntax and import directly)
sqlite3 var/data_dev.db < /tmp/ora_export.sql
```

#### Method 2 — SQLcl CSV export → SQLite

```bash
# 1. Export all tables as CSV from Oracle using SQLcl
mkdir -p /tmp/ora_csv
# In SQLcl for each table:
# SET MARKUP CSV ON
# SPOOL /tmp/ora_csv/table_name.csv
# SELECT * FROM table_name;
# SPOOL OFF

# 2. Create schema in SQLite via Doctrine or manual DDL
php bin/console doctrine:schema:create --env=dev   # with DATABASE_URL=sqlite://...

# 3. Import CSVs into SQLite
for CSV in /tmp/ora_csv/*.csv; do
  TABLE=$(basename "$CSV" .csv)
  sqlite3 var/data_dev.db << EOF
.mode csv
.import '$CSV' '$TABLE'
EOF
done
```

#### After migrating — update `.env.local`

```dotenv
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_dev.db"
MESSENGER_TRANSPORT_DSN=sync://
```

Fix permissions and clear caches (see [Section 5c](#5c-sqlite-devtesting) steps 4–5).
Then run the post-conversion checklist ([Section 22c](#22c-post-conversion-checklist)).

---

### 22i. MySQL / MariaDB → Oracle

The recommended FOSS approach is **ora2pg in reverse** (it can read MySQL and write Oracle-compatible
SQL), or a **mysqldump → SQLcl** pipeline.

#### Method — CSV export + Oracle SQLcl import

```bash
# 1. Export all tables from MySQL as CSV
TABLES=$(mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" -h "$DATABASE_HOST" "$DATABASE_NAME" \
  -e 'SHOW TABLES;' --batch --skip-column-names)

mkdir -p /tmp/mysql_csv
for TABLE in $TABLES; do
  mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" -h "$DATABASE_HOST" "$DATABASE_NAME" \
    -e "SELECT * FROM \`$TABLE\`" --batch | sed 's/\t/,/g' > /tmp/mysql_csv/$TABLE.csv
done

# 2. Create the schema in Oracle
# Option A: generate from Doctrine (requires pdo_oci / oci8 in .env.local)
php bin/console doctrine:schema:create
# Option B: use ora2pg with MySQL source to generate Oracle DDL
ora2pg -t TABLE -c /tmp/ora2pg_mysql.conf   # see ora2pg docs for MYSQL_DSN option

# 3. Load CSVs with SQLcl
# SQLcl download: https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/
for CSV in /tmp/mysql_csv/*.csv; do
  TABLE=$(basename "$CSV" .csv)
  sql oracle_user/oracle_pass@localhost:1521/XEPDB1 @/tmp/load_$TABLE.sql
  # or use LOAD DATA via SQLcl's built-in CSV loader
done
```

**Installing ora2pg:**

| Platform | Command |
|---|---|
| Debian / Ubuntu / Mint | `apt install ora2pg` |
| RHEL / AlmaLinux / Rocky | `dnf install ora2pg` (EPEL) or from source |
| macOS (Homebrew) | `brew install ora2pg` |
| Arch / Manjaro | AUR: `yay -S ora2pg` |
| All platforms (Perl / CPAN) | `cpan install Ora2Pg` |
| Source | [github.com/darold/ora2pg](https://github.com/darold/ora2pg) |

#### After migrating — update `.env.local`

```dotenv
# Oracle requires the oci8 Doctrine driver (not pdo_oci):
DATABASE_URL="oci8://oracle_user:oracle_pass@localhost:1521/XEPDB1"
```

> Doctrine requires the `oci8` PHP extension. Install it via PECL:
> `pecl install oci8` (requires Oracle Instant Client headers).

---

### 22j. Oracle → MySQL / MariaDB

Use **ora2pg** (GPL v3) — it was built specifically for this direction and generates
MySQL-compatible output when `MYSQL_DSN` is configured as the target.

```bash
apt install ora2pg

# ora2pg config targeting MySQL
cat > /tmp/ora2pg_to_mysql.conf << 'EOF'
ORACLE_DSN  dbi:Oracle:host=oracle_host;sid=ORCL
ORACLE_USER system
ORACLE_PWD  password
SCHEMA      YOUR_SCHEMA
TYPE        TABLE, INSERT, SEQUENCE, INDEX, CONSTRAINT
OUT_FILE    /tmp/ora_to_mysql.sql
MYSQL_DSN   dbi:mysql:host=127.0.0.1;database=exponential
MYSQL_USER  db_user
MYSQL_PWD   db_pass
EOF

ora2pg -c /tmp/ora2pg_to_mysql.conf

# Import
mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" < /tmp/ora_to_mysql.sql
```

Verify row counts match before switching the application:

```bash
# Oracle counts (via SQLcl)
echo "SELECT COUNT(*) FROM table_name;" | sql oracle_user/oracle_pass@localhost:1521/XEPDB1

# MySQL counts
mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" \
  -e "SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema='$DATABASE_NAME';"
```

#### After migrating — update `.env.local`

```dotenv
DATABASE_DRIVER=pdo_mysql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=3306
DATABASE_NAME=your_db_name
DATABASE_USER=your_db_user
DATABASE_PASSWORD=your_db_password
DATABASE_CHARSET=utf8mb4
DATABASE_COLLATION=utf8mb4_unicode_520_ci
DATABASE_VERSION=mariadb-10.x   # or 8.0 for MySQL
```

Then run the post-conversion checklist ([Section 22c](#22c-post-conversion-checklist)).

---

### 22k. PostgreSQL → Oracle

Use **ora2pg** (it supports PostgreSQL as a source in addition to Oracle):

```bash
apt install ora2pg

# ora2pg config with PostgreSQL source
cat > /tmp/pg_to_oracle.conf << 'EOF'
PG_DSN      dbi:Pg:host=127.0.0.1;database=exponential
PG_USER     pg_user
PG_PWD      pg_pass
SCHEMA      public
TYPE        TABLE, INSERT, SEQUENCE, INDEX, CONSTRAINT
OUT_FILE    /tmp/pg_to_oracle.sql
QUOTE_STRING_WITH_DOLLAR 0
EOF

ora2pg -c /tmp/pg_to_oracle.conf

# Load into Oracle with SQLcl
sql oracle_user/oracle_pass@localhost:1521/XEPDB1 @/tmp/pg_to_oracle.sql
```

#### After migrating — update `.env.local`

```dotenv
DATABASE_URL="oci8://oracle_user:oracle_pass@localhost:1521/XEPDB1"
```

---

### 22l. Oracle → PostgreSQL

**ora2pg** is the industry-standard tool for this path — its primary, most-tested use-case:

```bash
apt install ora2pg

# Create target PostgreSQL database
psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8' TEMPLATE template0;"

# ora2pg config
cat > /tmp/ora_to_pg.conf << 'EOF'
ORACLE_DSN  dbi:Oracle:host=oracle_host;sid=ORCL
ORACLE_USER system
ORACLE_PWD  password
SCHEMA      YOUR_SCHEMA
TYPE        TABLE, INSERT, SEQUENCE, INDEX, CONSTRAINT
OUT_FILE    /tmp/ora_to_pg.sql
QUOTE_STRING_WITH_DOLLAR 0
EOF

ora2pg -c /tmp/ora_to_pg.conf

# Import into PostgreSQL
psql -U pg_user exponential < /tmp/ora_to_pg.sql
```

For large schemas use pgloader as a follow-up validator:

```bash
# Reset sequences (ora2pg may not always set them correctly)
psql -U pg_user exponential -c "
  SELECT 'SELECT setval(''' || sequence_name || ''', (SELECT MAX(id) FROM ' || replace(sequence_name, '_id_seq', '') || '));'
  FROM information_schema.sequences WHERE sequence_schema = 'public';
" | psql -U pg_user exponential
```

#### After migrating — update `.env.local`

```dotenv
DATABASE_DRIVER=pdo_pgsql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=5432
DATABASE_NAME=exponential
DATABASE_USER=pg_user
DATABASE_PASSWORD=pg_pass
DATABASE_CHARSET=utf8
DATABASE_VERSION=16
```

Then run the post-conversion checklist ([Section 22c](#22c-post-conversion-checklist)).

---

## 23. Complete CLI Reference

A comprehensive reference of every CLI command used in day-to-day development, maintenance, and
operations on Exponential Platform Legacy (Platform v3).

---

### 23.1 Symfony Core

```bash
# ── Discovery ──────────────────────────────────────────────────────────────
php bin/console list                                # list all registered commands
php bin/console list ez                             # list all eZ commands
php bin/console list ezpublish                      # list all Legacy/LegacyBridge commands
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

# ── Twig ───────────────────────────────────────────────────────────────────
php bin/console debug:twig                          # list all Twig functions/filters
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
```

---

### 23.2 Doctrine / Migrations

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
php bin/console doctrine:schema:validate                           # validate entity <-> DB schema
php bin/console doctrine:schema:update --dump-sql                 # preview schema changes
php bin/console doctrine:schema:create --dump-sql                 # preview full CREATE SQL

# ── Database ───────────────────────────────────────────────────────────────
php bin/console doctrine:database:create                          # create the database
php bin/console doctrine:database:drop --force                    # drop the database (DESTRUCTIVE)
```

---

### 23.3 Exponential Platform v3 (new stack)

```bash
# ── Installation ───────────────────────────────────────────────────────────
php bin/console ezplatform:install exponential-oss   # install schema + demo data
php bin/console ezplatform:install clean             # schema only, no demo content

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
php bin/console ezplatform:graphql:generate-schema  # regenerate GraphQL schema

# ── HTTP Cache ─────────────────────────────────────────────────────────────
php bin/console fos:httpcache:invalidate:path / --all   # purge all HTTP cache paths
php bin/console fos:httpcache:invalidate:tag <tag>      # purge by cache tag

# ── JS Translations (Admin UI) ─────────────────────────────────────────────
php bin/console bazinga:js-translation:dump public/assets --merge-domains

# ── Image Variations ───────────────────────────────────────────────────────
php bin/console liip:imagine:cache:remove                 # remove all cached variations
php bin/console liip:imagine:cache:remove --filter=small  # remove one variation alias

# ── Config Debug ───────────────────────────────────────────────────────────
php bin/console debug:config ezplatform             # dump full resolved eZ config
php bin/console ezplatform:debug:dump-info          # dump eZ Platform environment info
```

---

### 23.4 Exponential (Legacy) Kernel & LegacyBridge

```bash
# ── Cache ──────────────────────────────────────────────────────────────────
php bin/console ezpublish:legacy:clear-cache

# ── Autoloads ──────────────────────────────────────────────────────────────
php bin/console ezpublish:legacy:generate-autoloads

# ── Script Runner ──────────────────────────────────────────────────────────
php bin/console ezpublish:legacy:script <script-name>

# ── Cronjobs (direct — bypass Symfony, use in crontab) ────────────────────
php ezpublish_legacy/runcronjobs.php --siteaccess legacy_admin
php ezpublish_legacy/runcronjobs.php --siteaccess ezwebin_site

# ── Legacy Autoload Generator (from inside legacy dir) ─────────────────────
cd ezpublish_legacy
php bin/php/ezpgenerateautoloads.php              # core & lib autoloads
php bin/php/ezpgenerateautoloads.php --extension  # extension autoloads

# ── Legacy Console (eZ Publish native CLI) ─────────────────────────────────
php ezpublish_legacy/bin/php/ezcli.php content search --query="lorem"
php ezpublish_legacy/bin/php/ezcli.php list
```

---

### 23.5 JWT Authentication (REST API)

```bash
php bin/console lexik:jwt:generate-keypair             # generate RSA keypair
php bin/console lexik:jwt:generate-keypair --overwrite  # rotate keys
php bin/console cache:clear                            # clear cache after rotation
```

---

### 23.6 Frontend / Asset Build (Yarn / Webpack Encore)

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
yarn ez                       # build Exponential Platform Admin UI (webpack.config.ez.js)
```

---

### 23.7 Makefile Shortcuts

Run `make` or `make help` to list all targets. Prefix any target with `APP_ENV=prod` for production.

```bash
make help                     # list all available make targets
make php-version              # print PHP version required

make build                    # vendor + migrations + reindex + assets + cache (dev)
APP_ENV=prod make build       # production build

make refresh                  # git stash -> pull --rebase -> stash pop -> full build
APP_ENV=prod make refresh     # production refresh

make vendor                   # composer install (--no-dev -o in prod)

make assets                   # yarn install + build:dev
make assets-prod              # yarn install + build:prod
make assets-watch             # watch mode
make ibexa-assets             # Admin UI assets

make clear-cache              # cache:clear
make clear-all-cache          # cache:clear + cache:pool:clear

make migrations               # doctrine:migration:migrate --allow-no-migration
make reindex                  # ezplatform:reindex

make images                   # generate image variations
make graphql-schema           # ezplatform:graphql:generate-schema

make update-code              # git stash -> pull --rebase -> stash pop
```

---

### 23.8 Symfony CLI (Dev Server & Tools)

```bash
symfony server:start          # start HTTPS dev server (https://127.0.0.1:8000)
symfony server:start -d       # start in background daemon mode
symfony server:stop           # stop background server
symfony server:log            # tail server access/error log
symfony server:status         # show server status + URL

symfony check:requirements    # verify PHP + extension requirements
```

---

*Copyright &copy; 1998 – 2026 7x (se7enx.com). All rights reserved unless otherwise noted.*
*Exponential Platform Legacy is Open Source software released under the GNU GPL v2 or any later version.*
