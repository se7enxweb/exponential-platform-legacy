# Exponential Platform Legacy v4.6.x (Platform v4) — LegacyBridge Edition
## Installation & Operations Guide

> **Platform v4 LegacyBridge (LB)** is the most technically advanced release of
> Exponential Platform Legacy. It runs **two fully-operational content kernels** in a single
> application: the Exponential (Legacy) 6.x kernel via LegacyBridge 4.x, alongside the
> Exponential Platform v4 OSS new stack (Symfony 5.4 LTS). Netgen Layouts 1.4+ and the
> Netgen Site bundle are included and active.
>
> This guide uses numbered **Git Save Points** throughout. Commit at each one so you can
> return to any working checkpoint without redoing completed work.
>
> This installation is longer and more involved than a standard Symfony project. Read it
> in full before starting.

---

## Table of Contents

1. [Requirements](#1-requirements)
2. [Architecture Overview](#2-architecture-overview)
3. [First-Time Installation](#3-first-time-installation)
   - [3a. Composer create-project (recommended)](#3a-composer-create-project-recommended)
   - [3b. GitHub git clone (developers)](#3b-github-git-clone-developers)
4. [Environment Configuration (.env.local)](#4-environment-configuration-envlocal)
   - [MySQL / MariaDB vars](#minimum-required-variables)
   - [PostgreSQL vars](#postgresql-alternative-to-mysql)
   - [SQLite vars](#sqlite-zero-config-alternative--dev--testing)
5. [Database Setup](#5-database-setup)
   - [5a. MySQL / MariaDB](#5-database-setup)
   - [5b. PostgreSQL](#5-database-setup)
   - [5c. SQLite (zero-config)](#5c-sqlite-zero-config-database)
6. [Web Server Setup](#6-web-server-setup)
   - [6a. Apache 2.4](#6a-apache-24)
   - [6b. Nginx](#6b-nginx)
   - [6c. Symfony CLI (development only)](#6c-symfony-cli-development-only)
7. [Legacy Symlinks (install-legacy-links)](#7-legacy-symlinks-install-legacy-links)
8. [File & Directory Permissions](#8-file--directory-permissions)
9. [Frontend Assets (Site CSS/JS)](#9-frontend-assets-site-cssjs)
10. [Admin UI Assets (Platform v4 Admin UI)](#10-admin-ui-assets-platform-v4-admin-ui)
11. [Legacy Kernel Setup](#11-legacy-kernel-setup)
12. [Netgen Layouts Setup](#12-netgen-layouts-setup)
13. [JWT Authentication (REST API)](#13-jwt-authentication-rest-api)
14. [Search Index](#14-search-index)
15. [Image Variations](#15-image-variations)
16. [Cache Management](#16-cache-management)
17. [Day-to-Day Operations: Start / Stop / Restart](#17-day-to-day-operations-start--stop--restart)
18. [Updating the Codebase](#18-updating-the-codebase)
19. [Cron Jobs](#19-cron-jobs)
20. [Solr Search Engine (optional)](#20-solr-search-engine-optional)
21. [Varnish HTTP Cache (optional)](#21-varnish-http-cache-optional)
22. [Troubleshooting](#22-troubleshooting)
23. [Database Conversion](#23-database-conversion)
    - [23a. Any → SQLite (go to SQLite)](#23a-any--sqlite-go-to-sqlite)
    - [23b. SQLite → MySQL / MariaDB](#23b-sqlite--mysql--mariadb)
    - [23c. SQLite → PostgreSQL](#23c-sqlite--postgresql)
    - [23d. MySQL / MariaDB → PostgreSQL](#23d-mysql--mariadb--postgresql)
    - [23e. PostgreSQL → MySQL / MariaDB](#23e-postgresql--mysql--mariadb)
    - [23f. Any → Oracle (export only)](#23f-any--oracle-export-only)
    - [23g. Post-conversion checklist](#23g-post-conversion-checklist)
24. [Complete CLI Reference](#24-complete-cli-reference)

---

## 1. Requirements

### PHP

- **PHP 8.0–8.5** (PHP 8.3 or 8.5 strongly recommended)
- Required extensions: `gd` or `imagick`, `curl`, `json`, `pdo_mysql` or `pdo_pgsql` or `pdo_sqlite`,
  `xsl`, `xml`, `intl`, `mbstring`, `opcache`, `ctype`, `iconv`
- For SQLite: `pdo_sqlite` + `sqlite3` PHP extensions (usually bundled with PHP; verify with `php -m | grep -i sqlite`)
- `memory_limit` ≥ 512M — the dual-kernel architecture uses more memory than a standard Symfony app.
  Set in `php.ini` or `.htaccess`; restart the web server after changes.
- `date.timezone` must be set in `php.ini` — see https://php.net/manual/en/timezones.php
- `max_execution_time` ≥ 120 (recommended 300 for CLI operations)

### Web Server

- **Apache 2.4** with `mod_rewrite`, `mod_deflate`, `mod_headers`, `mod_expires` enabled;
  run in `event` or `worker` mode with PHP-FPM (prefork also works but is not recommended)
  _or_
- **Nginx 1.18+** with PHP-FPM

### Node.js & Yarn

- **[Node.js](https://nodejs.org/en/download/) 20 LTS** — [download page](https://nodejs.org/en/download/) · managed via [nvm](https://github.com/nvm-sh/nvm) (recommended on all platforms)
- **[Yarn](https://classic.yarnpkg.com/en/docs/install) 1.22.x** — activated via [`corepack`](https://github.com/nodejs/corepack) `enable` after `nvm use 20`
- Do **not** use Node.js 18 or 22 — only 20 LTS is tested and supported for this release

**Installing nvm + Node.js 20 LTS (all UNIX / macOS / BSD / WSL):**

```bash
# Universal installer — works on Linux (all distros), macOS, BSD, WSL
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
source ~/.nvm/nvm.sh           # or restart your shell
nvm install 20
nvm use 20
corepack enable                # activates Yarn 1.22.x
```

> Alternatively, download a pre-built Node.js 20 LTS binary from
> [nodejs.org/en/download](https://nodejs.org/en/download/) for your platform
> (Linux x64/ARM, macOS, Windows).

| OS family | Package manager install |
|---|---|
| Debian / Ubuntu / Mint / Pop!_OS | `apt install nodejs npm` then `npm i -g yarn` |
| RHEL / CentOS / AlmaLinux / Rocky | `dnf module enable nodejs:20 && dnf install nodejs` |
| Fedora | `dnf install nodejs` |
| openSUSE / SUSE SLES | `zypper install nodejs20` |
| Arch / Manjaro | `pacman -S nodejs npm` |
| Slackware | SlackBuild at [slackbuilds.org](https://slackbuilds.org/repository/15.0/development/nodejs/) |
| FreeBSD | `pkg install node20` |
| OpenBSD | `pkg_add node` |
| macOS (Homebrew) | `brew install node@20` |
| macOS (MacPorts) | `port install nodejs20` |
| Generic binary | [nodejs.org/en/download](https://nodejs.org/en/download/) |

### Composer

- **[Composer](https://getcomposer.org)** 2.x — [download page](https://getcomposer.org/download/) · run `composer self-update` to ensure you are on the latest 2.x release

```bash
# Universal installer (all UNIX / macOS / BSD)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --2          # install Composer v2
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
```

| OS family | Package manager install |
|---|---|
| Debian / Ubuntu / Mint | `apt install composer` (may be older — prefer the installer above) |
| RHEL / AlmaLinux / Rocky | `dnf install composer` (EPEL required: `dnf install epel-release`) |
| Fedora | `dnf install composer` |
| openSUSE / SUSE | `zypper install php-composer2` |
| Arch / Manjaro | `pacman -S composer` |
| Slackware | SlackBuild at [slackbuilds.org](https://slackbuilds.org/repository/15.0/system/composer/) |
| FreeBSD | `pkg install php83-composer` (adjust PHP version) |
| macOS (Homebrew) | `brew install composer` |
| macOS (MacPorts) | `port install php-composer` |
| Generic | [getcomposer.org/download](https://getcomposer.org/download/) |

### Database

- **[MySQL](https://dev.mysql.com/downloads/) 8.0+** — [download page](https://dev.mysql.com/downloads/mysql/) with `utf8mb4` character set and `utf8mb4_unicode_520_ci` collation
  _or_
- **[MariaDB](https://mariadb.org/download/) 10.3+** — [download page](https://mariadb.org/download/) (10.6+ recommended)
  _or_
- **[PostgreSQL](https://www.postgresql.org/download/) 14+** — [download page](https://www.postgresql.org/download/)
  _or_
- **[SQLite](https://www.sqlite.org/download.html) 3.35+** — [download page](https://www.sqlite.org/download.html) · no server required; the `.db` file is created automatically on first install.
  Recommended for **local development, testing, demos, and air-gapped deployments** only.
  Requires the `pdo_sqlite` and `sqlite3` PHP extensions.

**Installing MySQL / MariaDB by OS:**

| OS family | MySQL | MariaDB |
|---|---|---|
| Debian / Ubuntu / Mint | `apt install mysql-server` | `apt install mariadb-server` |
| RHEL / CentOS / AlmaLinux / Rocky | `dnf install mysql-server` | `dnf install mariadb-server` |
| Fedora | `dnf install community-mysql-server` | `dnf install mariadb-server` |
| openSUSE / SUSE SLES | `zypper install mysql-community-server` | `zypper install mariadb` |
| Arch / Manjaro | `pacman -S mysql` or `pacman -S mariadb` | same |
| Slackware | [SlackBuilds.org/mariadb](https://slackbuilds.org/result/?search=mariadb) |
| FreeBSD | `pkg install mysql80-server` | `pkg install mariadb1011-server` |
| OpenBSD | `pkg_add mariadb-server` | same |
| macOS (Homebrew) | `brew install mysql` | `brew install mariadb` |
| macOS (MacPorts) | `port install mysql8` | `port install mariadb` |
| Generic binary | [dev.mysql.com/downloads](https://dev.mysql.com/downloads/mysql/) | [mariadb.org/download](https://mariadb.org/download/) |

**Installing PostgreSQL by OS:**

| OS family | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install postgresql` |
| RHEL / CentOS / AlmaLinux / Rocky | `dnf install postgresql-server && postgresql-setup --initdb` |
| Fedora | `dnf install postgresql-server` |
| openSUSE / SUSE SLES | `zypper install postgresql-server` |
| Arch / Manjaro | `pacman -S postgresql` |
| Slackware | [SlackBuilds.org/postgresql](https://slackbuilds.org/result/?search=postgresql) |
| FreeBSD | `pkg install postgresql16-server` |
| OpenBSD | `pkg_add postgresql-server` |
| macOS (Homebrew) | `brew install postgresql@16` |
| macOS (MacPorts) | `port install postgresql16-server` |
| Generic | [postgresql.org/download](https://www.postgresql.org/download/) |

### Optional

- **[Redis](https://redis.io/download/) 6+** — [download page](https://redis.io/download/) · recommended for production caching and sessions
- **[Solr](https://solr.apache.org/downloads.html) 7.7 or 8.11.1+** — [download page](https://solr.apache.org/downloads.html) · for advanced full-text search (default engine is `legacy`)
- **[Varnish](https://varnish-cache.org/releases/) 6.0 or 7.1+** — [download page](https://varnish-cache.org/releases/) · for HTTP reverse-proxy caching
- **[ImageMagick](https://imagemagick.org/script/download.php)** — [download page](https://imagemagick.org/script/download.php) · for advanced image processing (`IMAGEMAGICK_PATH` env var, default `/usr/bin`)

**Installing optional services by OS:**

| OS family | Redis | Solr | Varnish | ImageMagick |
|---|---|---|---|---|
| Debian / Ubuntu / Mint | `apt install redis` | [solr.apache.org](https://solr.apache.org/downloads.html) tarball | `apt install varnish` | `apt install imagemagick` |
| RHEL / AlmaLinux / Rocky | `dnf install redis` (EPEL) | tarball | `dnf install varnish` (EPEL) | `dnf install ImageMagick` |
| Fedora | `dnf install redis` | tarball | `dnf install varnish` | `dnf install ImageMagick` |
| openSUSE / SUSE | `zypper install redis` | tarball | `zypper install varnish` | `zypper install ImageMagick` |
| Arch / Manjaro | `pacman -S redis` | AUR: `solr` | AUR: `varnish` | `pacman -S imagemagick` |
| Slackware | [SlackBuilds](https://slackbuilds.org) | tarball | source | [SlackBuilds](https://slackbuilds.org) |
| FreeBSD | `pkg install redis` | `pkg install solr` | `pkg install varnish` | `pkg install ImageMagick7` |
| OpenBSD | `pkg_add redis` | tarball | `pkg_add varnish` | `pkg_add ImageMagick` |
| macOS (Homebrew) | `brew install redis` | `brew install solr` | `brew install varnish` | `brew install imagemagick` |
| macOS (MacPorts) | `port install redis` | tarball | source | `port install ImageMagick` |
| Generic download | [redis.io](https://redis.io/download/) | [solr.apache.org](https://solr.apache.org/downloads.html) | [varnish-cache.org](https://varnish-cache.org/releases/) | [imagemagick.org](https://imagemagick.org/script/download.php) |

### Full Requirements Summary

| Requirement | Minimum | Recommended |
|---|---|---|
| PHP | 8.0 | 8.3 or 8.5 |
| [Composer](https://getcomposer.org) | 2.x | latest 2.x |
| [Node.js](https://nodejs.org/en/download/) | 20 LTS | 20 LTS (via nvm) |
| [Yarn](https://classic.yarnpkg.com/en/docs/install) | 1.x | 1.22.22 (corepack) |
| [MySQL](https://dev.mysql.com/downloads/) | 8.0 | 8.0+ (utf8mb4) |
| [MariaDB](https://mariadb.org/download/) | 10.3 | 10.6+ |
| [PostgreSQL](https://www.postgresql.org/download/) | 14 | 16+ |
| [SQLite](https://www.sqlite.org/download.html) | 3.35 | 3.39+ (dev/testing) |
| [Redis](https://redis.io/download/) | 6.0 | 7.x (optional) |
| [Solr](https://solr.apache.org/downloads.html) | 7.7 | 8.11.x (optional) |
| [Varnish](https://varnish-cache.org/releases/) | 6.0 | 7.1+ (optional) |
| [Apache](https://httpd.apache.org/download.cgi) | 2.4 | 2.4 (event + PHP-FPM) |
| [Nginx](https://nginx.org/en/download.html) | 1.18 | 1.24+ |

---

## 2. Architecture Overview

Understanding the dual-kernel architecture is critical before installing.

```
Browser Request
      │
      ▼
   Web Server (Apache / Nginx)
      │
      ▼
  public/index.php (Symfony Entry Point)
      │
      ├─── Symfony Kernel (Platform v4 OSS — Symfony 5.4 LTS)
      │         ├── Exponential Platform v4 Admin UI (/adminui/)
      │         ├── REST API v2 (/api/ezp/v2/)
      │         ├── GraphQL API (/graphql)
      │         ├── Netgen Layouts 1.4+ (page building engine)
      │         └── Symfony/Twig site controllers
      │
      └─── LegacyBridge 4.x → Exponential (Legacy) 6.x Kernel
                ├── Legacy Admin UI (/legacy_admin/)
                ├── Legacy TPL template engine
                ├── Legacy modules (content, user, shop, etc.)
                ├── Legacy cronjobs
                └── Legacy extensions (app, ngadminui, ngsite, ngsymfonytools, etc.)
```

### Siteaccesses

| Siteaccess | Purpose | URL pattern |
|---|---|---|
| `site` | New-stack Twig front end | `/` (Symfony router) |
| `legacy_site` | Legacy TPL front end via LegacyBridge | `/` (legacy kernel) |
| `legacy_admin` | Legacy Admin UI | `/legacy_admin/` |
| `ngadminui` | Netgen Admin UI extension (delegated from legacy_admin) | internal |

Both `site` and `legacy_site` share the same database, content repository, and URL namespace.
The LegacyBridge intercepts requests and dispatches them to whichever kernel should handle them.

### Key Directories

```
project-root/
├── ezpublish_legacy/          Legacy kernel root (managed by LegacyBridge)
│   ├── extension/app/         → symlink to src/ezpublish_legacy/app (your app extension)
│   ├── settings/override/     → symlink to src/LegacySettings/override
│   ├── settings/siteaccess/
│   │   ├── legacy_admin/      → symlink to src/ezpublish_legacy/app/settings/siteaccess/legacy_admin/
│   │   ├── legacy_site/       → symlink to src/ezpublish_legacy/app/settings/siteaccess/legacy_site/
│   │   └── ngadminui/         → symlink to src/ezpublish_legacy/app/settings/siteaccess/ngadminui/
│   └── var/site/storage/      → symlink to src/LegacyRoot/var/site/storage (persistent uploads)
├── src/
│   ├── LegacyRoot/var/site/storage/   Persistent file storage (survives composer reinstalls)
│   ├── LegacySettings/override/       Global INI overrides (persists across reinstalls)
│   └── ezpublish_legacy/app/          Your legacy app extension + siteaccess settings
├── vendor/                    PHP packages (composer-managed; not committed)
├── node_modules/              Node packages (yarn-managed; not committed)
├── public/                    Web root
│   ├── assets/                Built frontend assets
│   └── bundles/               Symfony public assets (symlinked by assets:install)
└── var/                       Runtime cache, logs, sessions
```

---

## 3. First-Time Installation

### 3a. Composer create-project (recommended)

```bash
composer create-project se7enxweb/exponential-platform-legacy:4.6.x-dev my-project
cd my-project
```

Composer will:
1. Download all PHP packages
2. Run Symfony Flex recipes (including the `se7enxweb/exponential-platform-dxp:4.6.x-LB-dev` recipe)
3. Execute `post-install-cmd` scripts:
   - `php bin/install-legacy-links` — creates all symlinks wiring `src/` into `ezpublish_legacy/`
   - `assets:install` — publishes bundle `public/` assets to `public/bundles/`
   - `cache:clear` — warms up the initial cache

> 💾 **Git Save Point 1 — Project created**
> ```bash
> git init && git add -A
> git commit -m "chore(init): composer create-project exponential-platform-legacy 4.6.x-dev"
> ```

Continue from [Section 4](#4-environment-configuration-envlocal).

---

### 3b. GitHub git clone (developers)

```bash
git clone git@github.com:se7enxweb/exponential-platform-legacy.git
cd exponential-platform-legacy
git checkout 3.x
```

#### Step 1 — Install PHP dependencies

```bash
composer install --keep-vcs
```

This downloads all packages and runs `post-install-cmd` scripts (symlinks, assets, cache).

> 💾 **Git Save Point 1 — Vendors installed**
> ```bash
> git add composer.lock && git commit -m "chore(install): lock vendor dependencies"
> ```

#### Step 2 — Configure environment

See [Section 4](#4-environment-configuration-envlocal).

#### Step 3 — Create the database

See [Section 5](#5-database-setup).

#### Step 4 — Create legacy symlinks (if not already created by composer)

```bash
php bin/install-legacy-links
```

See [Section 7](#7-legacy-symlinks-install-legacy-links) for full details.

#### Step 5 — Set permissions

See [Section 8](#8-file--directory-permissions).

#### Step 6 — Build frontend assets

```bash
source ~/.nvm/nvm.sh && nvm use 20
yarn install
yarn dev
```

#### Step 7 — Build Admin UI assets

```bash
php bin/console assets:install --symlink --relative public
yarn ibexa:build
```

#### Step 8 — Generate JWT keypair

```bash
php bin/console lexik:jwt:generate-keypair
```

#### Step 9 — Regenerate legacy autoloads

```bash
php bin/console ezpublish:legacy:generate-autoloads
```

#### Step 10 — Generate GraphQL schema

```bash
php bin/console ezplatform:graphql:generate-schema
```

#### Step 11 — Clear all caches

```bash
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache
```

#### Step 12 — Reindex search

```bash
php bin/console ezplatform:reindex
```

> 💾 **Git Save Point 2 — Installation complete**
> ```bash
> git add -A
> git commit -m "chore(install): platform v4 LB install complete"
> ```

#### Step 13 — Start the dev server

```bash
symfony server:start
```

Access points after install:

| URL | What you get |
|---|---|
| `https://127.0.0.1:8000/` | Public site (hybrid Twig + Legacy TPL) |
| `https://127.0.0.1:8000/adminui/` | Platform v4 Admin UI (React) |
| `https://127.0.0.1:8000/legacy_admin/` | Legacy Admin UI (classic) |
| `https://127.0.0.1:8000/api/ezp/v2/` | REST API v2 |
| `https://127.0.0.1:8000/graphql` | GraphQL endpoint |

---

## 4. Environment Configuration (.env.local)

**Never commit `.env.local`.** It overrides `.env` with host-specific secrets.

```bash
cp .env .env.local
$EDITOR .env.local
```

### Minimum required variables

```dotenv
# Application
APP_ENV=prod             # or dev
APP_SECRET=<random-32-char-hex-string>

# Database — MySQL / MariaDB
DATABASE_DRIVER=pdo_mysql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=3306
DATABASE_NAME=your_db_name
DATABASE_USER=your_db_user
DATABASE_PASSWORD=your_db_password
DATABASE_CHARSET=utf8mb4
DATABASE_COLLATION=utf8mb4_unicode_520_ci
DATABASE_VERSION=mariadb-10.6.0    # e.g. mariadb-10.6.0, or 8.0 for MySQL

# DATABASE_URL is derived automatically from the vars above.
# You may also set it directly as a full DSN:
# DATABASE_URL="mysql://user:pass@127.0.0.1:3306/dbname?serverVersion=8.0&charset=utf8mb4"

# JWT (REST API authentication)
JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem
JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem
JWT_PASSPHRASE=<random-64-char-hex-string>
```

### PostgreSQL (alternative to MySQL)

```dotenv
DATABASE_DRIVER=pdo_pgsql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=5432
DATABASE_NAME=your_db_name
DATABASE_USER=your_db_user
DATABASE_PASSWORD=your_db_password
DATABASE_CHARSET=utf8
DATABASE_VERSION=16
```

### SQLite (zero-config alternative — dev / testing)

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
> - The DB file path above evaluates to e.g. `var/data_dev.db` or `var/data_prod.db`.
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

See [Section 5c](#5c-sqlite-zero-config-database) for the full SQLite install walkthrough.

### Search engine

```dotenv
SEARCH_ENGINE=legacy       # default — uses legacy kernel search
# SEARCH_ENGINE=solr       # use Solr (see Section 20)
```

### HTTP cache

```dotenv
HTTPCACHE_PURGE_TYPE=local         # or "varnish" when using Varnish
HTTPCACHE_DEFAULT_TTL=86400
HTTPCACHE_PURGE_SERVER=http://localhost:80
# HTTPCACHE_VARNISH_INVALIDATE_TOKEN=<your-secret>
# TRUSTED_PROXIES=127.0.0.1
```

### Application cache backend

```dotenv
CACHE_POOL=cache.tagaware.filesystem   # default (filesystem)
# CACHE_POOL=cache.redis               # use Redis
# CACHE_DSN=redis://localhost:6379
```

### Mail

```dotenv
MAILER_DSN=null://null         # dev (suppress delivery)
# MAILER_DSN=smtp://localhost:25
```

### Other

```dotenv
IMAGEMAGICK_PATH=/usr/bin      # path to ImageMagick binaries
CORS_ALLOW_ORIGIN='^https?://(localhost|127\.0\.0\.1)(:[0-9]+)?$'
SESSION_HANDLER_ID=session.handler.native_file
SESSION_SAVE_PATH=%kernel.project_dir%/var/sessions/%kernel.environment%
```

> 💾 **Git Save Point — Environment template**
> If you create a `.env.local.dist` with secrets redacted:
> ```bash
> cp .env.local .env.local.dist
> # Redact all passwords and secrets, then:
> git add .env.local.dist && git commit -m "docs: add .env.local.dist as environment reference"
> ```

---

## 5. Database Setup

### Create the database

```sql
-- MySQL / MariaDB
CREATE DATABASE exponential
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_520_ci;

-- Grant access
GRANT ALL PRIVILEGES ON exponential.* TO 'your_db_user'@'localhost' IDENTIFIED BY 'your_db_password';
FLUSH PRIVILEGES;
```

```bash
# PostgreSQL
psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8';"
```

### Import schema and demo data

```bash
php bin/console ibexa:install exponential-oss
# deprecated alias (still works): php bin/console ezplatform:install exponential-oss
```

The demo data creates an administrator user:
- **Username:** `admin`
- **Password:** `publish`

**Change the admin password immediately** after installation via the Legacy Admin or the
Platform v4 Admin UI. This credential is publicly documented.

> 💾 **Git Save Point — Database provisioned**
> ```bash
> git commit --allow-empty -m "chore(install): database created and demo data imported"
> ```

### Run Doctrine migrations (on updates)

```bash
php bin/console doctrine:migration:migrate --allow-no-migration
```

---

### 5c. SQLite (zero-config database)

SQLite is the fastest way to spin up a local development or demo environment — no database
server software required at all.

#### Step 1 — Verify PHP extensions

```bash
php -m | grep -i sqlite
# Expected output should include both:
#   SQLite3
#   pdo_sqlite
```

If either is missing, enable them in `php.ini` (e.g. `extension=pdo_sqlite` / `extension=sqlite3`)
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

#### Step 3 — Run the install command

```bash
php bin/console ibexa:install exponential-oss
```

This single command:
1. Creates the SQLite `.db` file at `var/data_<environment>.db` (e.g. `var/data_dev.db`)
2. Imports the seed content (content classes, content objects, users, roles)
3. Applies the Netgen Layouts schema automatically (no separate migration needed)
4. Creates the Doctrine ORM tables

The default administrator credentials are:
- **Username:** `admin`
- **Password:** `publish`

**Change the admin password immediately** after installation.

#### Step 4 — Fix file permissions

The install command typically runs as your shell user. The web server needs write access
to the `.db` file (SQLite writes to the file on every content edit):

```bash
chmod 664 var/data_dev.db
chown $USER:www-data var/data_dev.db   # replace www-data with your web server group
```

If you cannot use `chown` (e.g. shared hosting), `chmod 666` will also work but is less
restrictive.

#### Step 5 — Clear caches

```bash
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache
```

#### The Legacy kernel

The Exponential (Legacy) kernel and the Symfony new-stack **share the same `.db` file**
automatically. LegacyBridge reads the DBAL connection parameters (including the absolute
path to the `.db` file) and passes them to the legacy `eZDB` layer, so both kernels operate
on the same dataset with no additional configuration.

#### SQLite limitations

| Limitation | Impact |
|---|---|
| No concurrent write transactions | Under heavy or concurrent load, writes queue up and can timeout. Use MySQL/MariaDB for production. |
| No replication or clustering | Cannot be used in multi-server (cluster) deployments |
| No `FULLTEXT` index | Legacy kernel full-text search falls back to `LIKE` queries |
| File-level locking | File must be on a local filesystem — NFS/CIFS mounts not supported |
| Single file, single host | DB file is local to the server that runs PHP |

> **TL;DR:** SQLite is ideal for **local development, automated testing, demos, and
> air-gapped / offline environments**. Use MySQL 8.0+, MariaDB 10.6+, or PostgreSQL 14+
> for any public-facing or multi-user production deployment.

> 💾 **Git Save Point — SQLite install complete**
> ```bash
> git commit --allow-empty -m "chore(install): sqlite database provisioned for dev"
> ```

---

## 6. Web Server Setup

### 6a. Apache 2.4

Enable required modules:

```bash
a2enmod rewrite deflate headers expires
```

Example virtual host:

```apache
<VirtualHost *:80>
    ServerName exponential.local
    DocumentRoot /var/www/exponential/public
    DirectoryIndex index.php

    SetEnvIf Request_URI ".*" APP_ENV=prod
    SetEnv APP_DEBUG "0"
    SetEnv APP_HTTP_CACHE "1"

    <Directory /var/www/exponential/public>
        AllowOverride None
        Require all granted

        FallbackResource /index.php

        # Legacy kernel static assets
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} -f [OR]
        RewriteCond %{REQUEST_FILENAME} -d
        RewriteRule ^ - [L]
        RewriteRule ^ /index.php [L]
    </Directory>

    # Pass ezpublish_legacy/ static files directly
    Alias /var/site/storage /var/www/exponential/ezpublish_legacy/var/site/storage
    <Directory /var/www/exponential/ezpublish_legacy/var/site/storage>
        Require all granted
        Options -Indexes
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/exponential_error.log
    CustomLog ${APACHE_LOG_DIR}/exponential_access.log combined
</VirtualHost>
```

For HTTPS (recommended for production), add an SSL vhost or use [Certbot](https://certbot.eff.org):

```bash
certbot --apache -d exponential.local
```

### 6b. Nginx

```nginx
server {
    listen 80;
    server_name exponential.local;
    root /var/www/exponential/public;
    index index.php;

    location / {
        try_files $uri /index.php$is_args$args;
    }

    # Legacy kernel — var/site/storage static files
    location ~ ^/var/site/storage/ {
        root /var/www/exponential/ezpublish_legacy;
        try_files $uri =404;
        expires 30d;
        access_log off;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        fastcgi_param APP_ENV prod;
        fastcgi_param APP_DEBUG 0;
        fastcgi_param APP_HTTP_CACHE 1;
        internal;
    }

    location ~ \.php$ {
        return 404;
    }

    error_log /var/log/nginx/exponential_error.log;
    access_log /var/log/nginx/exponential_access.log;
}
```

```bash
nginx -t && systemctl reload nginx
```

### 6c. Symfony CLI (development only)

Download page: [symfony.com/download](https://symfony.com/download)

```bash
# Universal installer — Linux, macOS, BSD, WSL (all architectures)
curl -sS https://get.symfony.com/cli/installer | bash
# Then move to PATH:
mv ~/.symfony5/bin/symfony /usr/local/bin/symfony
# or add to your shell profile: export PATH="$HOME/.symfony5/bin:$PATH"
```

| OS family | Install |
|---|---|
| Debian / Ubuntu / Mint | `curl -sS https://get.symfony.com/cli/installer \| bash` — or `apt install symfony-cli` (if distro pkg available) |
| RHEL / AlmaLinux / Rocky / Fedora | `curl -sS https://get.symfony.com/cli/installer \| bash` |
| openSUSE / SUSE | `curl -sS https://get.symfony.com/cli/installer \| bash` |
| Arch / Manjaro | AUR: `yay -S symfony-cli` — or the universal installer |
| Slackware / BSD | Universal installer above |
| macOS (Homebrew) | `brew install symfony-cli/tap/symfony-cli` |
| macOS (MacPorts) | Universal installer above |
| Generic binary | [github.com/symfony-cli/symfony-cli/releases](https://github.com/symfony-cli/symfony-cli/releases) — pre-built binaries for Linux (amd64/arm64), macOS, Windows |

```bash
symfony server:start               # HTTPS dev server on https://127.0.0.1:8000
symfony server:start -d            # run in background
symfony server:stop                # stop background server
symfony server:log                 # tail server log
```

---

## 7. Legacy Symlinks (install-legacy-links)

This is one of the most important steps unique to the LegacyBridge edition. The
`bin/install-legacy-links` script wires your `src/` project files into the `ezpublish_legacy/`
directory tree so the legacy kernel can find them. It is run automatically by `composer install`
and `composer update`, but can also be run manually at any time.

```bash
php bin/install-legacy-links
```

### What it creates

| Symlink | Points to | Purpose |
|---|---|---|
| `ezpublish_legacy/extension/app` | `../../src/ezpublish_legacy/app` | Mounts your app legacy extension |
| `ezpublish_legacy/settings/override` | `../../src/LegacySettings/override` | Global INI override directory |
| `ezpublish_legacy/settings/siteaccess/ngadminui` | `../../../src/ezpublish_legacy/app/settings/siteaccess/ngadminui` | Netgen Admin UI siteaccess INI |
| `ezpublish_legacy/settings/siteaccess/legacy_site` | `../../../src/ezpublish_legacy/app/settings/siteaccess/legacy_site` | Legacy front-end siteaccess INI |
| `ezpublish_legacy/settings/siteaccess/legacy_admin` | `../../../src/ezpublish_legacy/app/settings/siteaccess/legacy_admin` | Legacy admin siteaccess INI |
| `ezpublish_legacy/var/site/storage` | `../../../src/LegacyRoot/var/site/storage` | Persistent uploaded content storage |

It also creates 7 per-file symlinks inside
`src/ezpublish_legacy/app/settings/siteaccess/legacy_admin/` that delegate most INI
configuration out to the `ngadminui/` siteaccess directory. These are required by the
Netgen Admin UI extension:

```
legacy_admin/content.ini.append.php            → ../ngadminui/content.ini.append.php
legacy_admin/contentstructuremenu.ini.append.php → ../ngadminui/contentstructuremenu.ini.append.php
legacy_admin/dashboard.ini.append.php           → ../ngadminui/dashboard.ini.append.php
legacy_admin/design.ini.append.php              → ../ngadminui/design.ini.append.php
legacy_admin/image.ini.append.php               → ../ngadminui/image.ini.append.php
legacy_admin/override.ini.append.php            → ../ngadminui/override.ini.append.php
legacy_admin/toolbar.ini.append.php             → ../ngadminui/toolbar.ini.append.php
```

> **Why doesn't the Flex recipe create these directly?**
> Symfony Flex delivers recipes as zip archives. Git symlinks (mode `120000`) are stripped
> by zip extraction. The install script was introduced specifically to work around this
> limitation — it is the correct, supported approach.

### Verify symlinks are in place

```bash
ls -la ezpublish_legacy/extension/ | grep app
ls -la ezpublish_legacy/settings/ | grep -E "override|siteaccess"
ls -la ezpublish_legacy/settings/siteaccess/
ls -la ezpublish_legacy/var/site/
```

---

## 8. File & Directory Permissions

Replace `www-data` with your actual web server user (e.g. `apache`, `nginx`, `_www` on macOS).

The LegacyBridge edition has **three writable directory trees** instead of one:

```bash
# Symfony runtime directories
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var/
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var/

# Platform v4 new-stack public var directory
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX public/var/
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX public/var/

# Legacy kernel writable directories (cache, compiled templates, logs)
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX ezpublish_legacy/var/
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX ezpublish_legacy/var/

# Persistent storage (survives composer reinstall via symlink)
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX src/LegacyRoot/var/site/storage/
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX src/LegacyRoot/var/site/storage/
```

If [`setfacl`](https://savannah.nongnu.org/projects/acl/) is unavailable, install the `acl` package first:

| OS family | Install `acl` |
|---|---|
| Debian / Ubuntu / Mint / Pop!_OS | `apt install acl` |
| RHEL / CentOS / AlmaLinux / Rocky | `dnf install acl` |
| Fedora | `dnf install acl` |
| openSUSE / SUSE SLES | `zypper install acl` |
| Arch / Manjaro | `pacman -S acl` |
| FreeBSD | built in — mount filesystem with `-o acls` |
| macOS | ACLs are enabled by default; use `chmod +a` syntax instead |
| Slackware | included in core — ensure filesystem is mounted with `acl` option |

If ACLs are not available on your filesystem (NFS, some BSD mounts, macOS APFS):

```bash
chown -R www-data:www-data var/ public/var/ ezpublish_legacy/var/ src/LegacyRoot/var/site/storage/
chmod -R 775 var/ public/var/ ezpublish_legacy/var/ src/LegacyRoot/var/site/storage/
```

> **Note for development:** If your CLI user and web server user differ, the ACL approach
> lets both write simultaneously. This avoids `Permission denied` errors when alternating
> between `php bin/console` (CLI) and web requests (`www-data`).

---

## 9. Frontend Assets (Site CSS/JS)

The project uses Webpack Encore + Yarn. Always activate Node.js 20 LTS first.

```bash
source ~/.nvm/nvm.sh && nvm use 20
corepack enable    # activates yarn 1.22.22 as declared in package.json
```

### Install Node dependencies (first time or after package.json changes)

```bash
yarn install
```

### Build for development (with source maps)

```bash
yarn dev
```

### Build for production (minified)

```bash
yarn build
```

### Watch mode (auto-rebuild on file change)

```bash
yarn watch
```

### What to rebuild after changes

| Changed files | Command |
|---|---|
| `assets/js/**`, `assets/scss/**`, `assets/styles/**` | `yarn dev` (or `yarn watch`) |
| `package.json` | `yarn install && yarn dev` |
| `webpack.config.js` | `yarn dev` |

> 💾 **Git Save Point — After theme asset changes**
> ```bash
> git add assets/ webpack.config.js package.json yarn.lock
> git commit -m "feat(theme): update site CSS/JS assets"
> ```

---

## 10. Admin UI Assets (Platform v4 Admin UI)

The Platform v4 Admin UI assets (React components, SCSS, icons) are built separately
from the site frontend. They are **not** rebuilt automatically on `composer install`
(no Node.js required on production servers) — deploy pre-built assets or build on demand.

### Prerequisites

The `var/encore/` directory must be populated by `assets:install` before any `ibexa:*`
build can run. This happens automatically during `composer install`, but can be run
manually:

```bash
php bin/console assets:install --symlink --relative public
```

This publishes bundle `public/` directories to `public/bundles/` and writes the
`var/encore/ibexa.config.js`, `var/encore/ibexa.config.setup.js`, and
`var/encore/ibexa.config.manager.js` loader files that tell webpack where each
bundle's entry points are.

### Build Admin UI assets — production

```bash
yarn ibexa:build
```

### Build Admin UI assets — development (with source maps)

```bash
yarn ibexa:dev
```

### Watch mode (auto-rebuild Admin UI assets on change)

```bash
yarn ibexa:watch
```

> All `ibexa:*` scripts route through the project's `webpack.config.js` via
> `--config-name ibexa`. This ensures the `@ibexa-admin-ui` webpack alias points
> to `vendor/se7enxweb/admin-ui` (the correct fork) and the sass-loader legacy
> API patch is applied for vendor SCSS compatibility.

### Dump JS translation assets (required for Admin UI i18n)

```bash
php bin/console bazinga:js-translation:dump public/assets --merge-domains
```

### What changes require an Admin UI asset rebuild

| Changed | Rebuild needed? |
|---|---|
| `composer update` pulled a new `se7enxweb/admin-ui` version | Yes — `yarn ibexa:build` |
| Any bundle's `Resources/public/` JS or SCSS | Yes — `yarn ibexa:build` |
| `webpack.config.js` or `ibexa.webpack.config.manager.js` | Yes — `yarn ibexa:build` |
| Admin richtext editor configuration | Yes — `yarn ibexa:build` |
| Translation strings changed | Yes — dump translations |

---

## 11. Legacy Kernel Setup

### Regenerate autoload arrays

Required after your first install and after adding or removing any legacy extension:

```bash
# Via Symfony console (recommended)
php bin/console ezpublish:legacy:generate-autoloads

# Or directly from inside the legacy directory
cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php && php bin/php/ezpgenerateautoloads.php --extension
cd ..
```

### Clear legacy cache

```bash
php bin/console ezpublish:legacy:clear-cache
```

### Active extensions

Extensions are activated in `src/LegacySettings/override/site.ini.append.php`:

```ini
[ExtensionSettings]
ActiveExtensions[]
ActiveExtensions[]=ngsymfonytools
ActiveExtensions[]=app
ActiveExtensions[]=ngsite
ActiveExtensions[]=sevenx_themes_simple
```

After adding or removing an extension entry, regenerate autoloads and clear cache:

```bash
php bin/console ezpublish:legacy:generate-autoloads
php bin/console ezpublish:legacy:clear-cache
```

### Legacy Admin UI access

The Legacy Admin is accessible at `/legacy_admin/` via the LegacyBridge.

Default credentials: **admin / publish** — change immediately after install.

To run a legacy script:

```bash
php bin/console ezpublish:legacy:script <script-name>
# Example:
php bin/console ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
```

---

## 12. Netgen Layouts Setup

This LegacyBridge edition includes Netgen Layouts 1.4+ and is the required foundation
for layout-driven page building on top of the Legacy kernel.

### Generate GraphQL schema (required by Netgen Layouts)

```bash
php bin/console ezplatform:graphql:generate-schema
```

Run this after any content type or field type changes.

### Clear Symfony cache after layout config changes

```bash
php bin/console cache:clear
```

### Netgen Layouts Admin UI

Netgen Layouts is accessible via the Platform v4 Admin UI at `/adminui/`.

### Creating your first layout

1. Go to `/adminui/` and log in as `admin`
2. Navigate to **Layouts** in the left menu
3. Create a new layout, assign it to URL conditions
4. Add blocks from the Block panel and map them to zones

> For full Netgen Layouts documentation see https://docs.netgen.io/projects/layouts/

---

## 13. JWT Authentication (REST API)

JWT keypairs are required for the REST API to function. They are **not** included in
the repository (they are git-ignored). Generate them on every fresh install:

```bash
php bin/console lexik:jwt:generate-keypair
# Writes:
#   config/jwt/private.pem
#   config/jwt/public.pem
```

On key rotation (renew without breaking existing tokens):

```bash
php bin/console lexik:jwt:generate-keypair --overwrite
php bin/console cache:clear
```

Back up `config/jwt/private.pem` and `config/jwt/public.pem` securely. If they are
lost, all existing tokens are invalidated and clients must re-authenticate.

---

## 14. Search Index

### Full reindex (rebuild from scratch)

Required after fresh install, after importing content, or after switching search engines:

```bash
php bin/console ezplatform:reindex
```

### Incremental reindex

```bash
php bin/console ezplatform:reindex --iteration-count=100
```

### Reindex a specific content type

```bash
php bin/console ezplatform:reindex --content-type=article
```

For Solr — force commit after indexing:

```bash
curl http://localhost:8983/solr/collection1/update?commit=true
```

---

## 15. Image Variations

Image variations are generated **on demand** by Liip Imagine when a content view
requests a variation alias. Configuration lives in `config/packages/ibexa.yaml` under
`ibexa.system.<siteaccess>.image_variations`.

### Clear generated variation cache

When variation configuration changes:

```bash
php bin/console liip:imagine:cache:remove
php bin/console liip:imagine:cache:remove --filter=small   # one alias only
php bin/console cache:clear
```

### Example variation configuration

```yaml
# config/packages/ibexa.yaml
ibexa:
    system:
        site_group:
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

## 16. Cache Management

### Clear Symfony application cache

```bash
php bin/console cache:clear                      # current APP_ENV
php bin/console cache:clear --env=prod           # production cache
```

### Warm up cache (production)

```bash
php bin/console cache:warmup --env=prod
```

### Clear a specific cache pool

```bash
php bin/console cache:pool:clear cache.redis
php bin/console cache:pool:clear cache.tagaware.filesystem
```

### Purge HTTP cache

```bash
php bin/console fos:httpcache:invalidate:path / --all
php bin/console fos:httpcache:invalidate:tag <tag>
```

### Clear legacy kernel cache

```bash
php bin/console ezpublish:legacy:clear-cache
```

### Clear everything at once (Symfony + Legacy)

```bash
php bin/console cache:clear && php bin/console ezpublish:legacy:clear-cache
```

### Nuclear option (development)

```bash
rm -rf var/cache/dev var/cache/prod
php bin/console cache:warmup --env=prod
```

---

## 17. Day-to-Day Operations: Start / Stop / Restart

### Apache

```bash
systemctl start apache2
systemctl stop apache2
systemctl restart apache2
systemctl reload apache2     # graceful reload (no dropped connections)
```

### Nginx

```bash
systemctl start nginx
systemctl stop nginx
systemctl reload nginx
nginx -s reload              # alternative graceful reload
```

### PHP-FPM

```bash
systemctl restart php8.3-fpm
systemctl reload php8.3-fpm  # graceful reload after config changes
```

### Redis (if used)

```bash
systemctl start redis
systemctl restart redis
```

### Symfony CLI dev server

```bash
symfony server:start -d      # start in background
symfony server:stop          # stop
symfony server:log           # view logs
symfony server:status        # show status + URL
```

### After deploying code changes (production checklist)

```bash
# 1. Pull code
git pull --rebase

# 2. Install/update vendors
composer install --no-dev -o

# 3. Run Doctrine migrations
php bin/console doctrine:migration:migrate --allow-no-migration --env=prod

# 4. Recreate legacy symlinks (in case new ones were added)
php bin/install-legacy-links

# 5. Publish bundle public assets
php bin/console assets:install --symlink --relative public --env=prod

# 6. Rebuild Platform v4 Admin UI assets (if admin-ui bundle updated)
source ~/.nvm/nvm.sh && nvm use 20 && yarn ibexa:build

# 7. Rebuild frontend site assets (if theme/JS/CSS changed)
yarn build

# 8. Dump JS translations
php bin/console bazinga:js-translation:dump public/assets --merge-domains --env=prod

# 9. Clear & warm up caches
php bin/console cache:clear --env=prod
php bin/console cache:warmup --env=prod
php bin/console ezpublish:legacy:clear-cache

# 10. Regenerate legacy autoloads (if extensions changed)
php bin/console ezpublish:legacy:generate-autoloads

# 11. Reindex search (if content model changed)
# php bin/console ezplatform:reindex --env=prod
```

> 💾 **Git Save Point — After each production deploy**
> ```bash
> git tag -a "deploy-$(date +%Y%m%d-%H%M)" -m "production deploy $(date)"
> git push origin --tags
> ```

---

## 18. Updating the Codebase

### Pull latest code and rebuild

```bash
git pull --rebase
composer install
php bin/install-legacy-links
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache
```

### Update Composer packages

```bash
# Update all packages within constraints
composer update

# Update a single package
composer update se7enxweb/legacy-bridge

# After update, always run:
php bin/install-legacy-links
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console cache:clear
php bin/console ezpublish:legacy:generate-autoloads
php bin/console ezpublish:legacy:clear-cache
php bin/console ezplatform:reindex   # if content model schema may have changed
```

> 💾 **Git Save Point — After composer update**
> ```bash
> git add composer.lock && git commit -m "chore(deps): composer update $(date +%Y-%m-%d)"
> ```

### Update Node packages

```bash
yarn upgrade
yarn dev
```

> 💾 **Git Save Point — After yarn upgrade**
> ```bash
> git add yarn.lock && git commit -m "chore(deps): yarn upgrade $(date +%Y-%m-%d)"
> ```

### Regenerate legacy autoloads (after adding/removing legacy extensions)

```bash
php bin/console ezpublish:legacy:generate-autoloads
# or from inside the legacy directory:
cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php && php bin/php/ezpgenerateautoloads.php --extension
```

---

## 19. Cron Jobs

Add to crontab (`crontab -e -u www-data`):

```cron
# Platform v4 cron runner (every 5 minutes)
*/5 * * * * /usr/bin/php /var/www/exponential/bin/console ezplatform:cron:run --env=prod >> /var/log/exponential-cron.log 2>&1

# Legacy kernel cron runner via LegacyBridge (every 5 minutes)
*/5 * * * * /usr/bin/php /var/www/exponential/ezpublish_legacy/runcronjobs.php --siteaccess legacy_admin >> /var/log/exponential-legacy-cron.log 2>&1

# Legacy kernel front-end cron (if legacy_site has cronjobs)
*/5 * * * * /usr/bin/php /var/www/exponential/ezpublish_legacy/runcronjobs.php --siteaccess legacy_site >> /var/log/exponential-legacy-site-cron.log 2>&1
```

---

## 20. Solr Search Engine (optional)

### Switch from legacy to Solr

1. Set `SEARCH_ENGINE=solr` and `SOLR_DSN`/`SOLR_CORE` in `.env.local`
2. Clear cache: `php bin/console cache:clear`
3. Provision the Solr core:
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

## 21. Varnish HTTP Cache (optional)

1. Set env vars in `.env.local`:
   ```dotenv
   HTTPCACHE_PURGE_TYPE=varnish
   HTTPCACHE_PURGE_SERVER=http://127.0.0.1:6081
   HTTPCACHE_VARNISH_INVALIDATE_TOKEN=<your-secret>
   TRUSTED_PROXIES=127.0.0.1
   ```
2. Set `APP_HTTP_CACHE=0` in your web server vhost (let Varnish handle caching).
3. Load the Platform v4 Varnish VCL from `doc/varnish/` (if present) or refer to the
   upstream LegacyBridge Varnish documentation.
4. Clear cache after any VCL change:
   ```bash
   php bin/console cache:clear
   php bin/console fos:httpcache:invalidate:path / --all
   ```

---

## 22. Troubleshooting

### White screen / 500 error

```bash
# Check Symfony logs
tail -f var/log/dev.log
tail -f var/log/prod.log

# Check web server logs
tail -f /var/log/apache2/error.log
tail -f /var/log/nginx/error.log

# Switch to dev mode temporarily for a stack trace
APP_ENV=dev php bin/console cache:clear
```

### "Class not found" after composer update

```bash
composer dump-autoload -o
php bin/console cache:clear
```

### Symlinks missing or broken

```bash
# Run the install script again — it is idempotent
php bin/install-legacy-links

# Verify
ls -la ezpublish_legacy/extension/app
ls -la ezpublish_legacy/settings/override
ls -la ezpublish_legacy/settings/siteaccess/legacy_site
ls -la ezpublish_legacy/settings/siteaccess/legacy_admin
ls -la ezpublish_legacy/settings/siteaccess/ngadminui
ls -la ezpublish_legacy/var/site/storage
```

### Assets not loading (404 on /bundles/ or /assets/)

```bash
# Reinstall public bundle assets
php bin/console assets:install --symlink --relative public

# Rebuild site frontend
yarn dev

# Rebuild Admin UI
yarn ibexa:build
```

### `yarn ibexa:build` fails with "Module not found"

```bash
# var/encore/ must be populated first
php bin/console assets:install --symlink --relative public
yarn ibexa:build
```

### Cache not clearing / stale content

```bash
# Clear both Symfony and Legacy caches
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache

# Nuclear option
rm -rf var/cache/dev var/cache/prod
php bin/console cache:warmup --env=prod
```

### Image variations missing / not regenerating

```bash
php bin/console liip:imagine:cache:remove
php bin/console cache:clear
# Variations regenerate on next request
```

### Search results outdated

```bash
php bin/console ezplatform:reindex
```

### Permission denied on var/, public/var/, or ezpublish_legacy/var/

```bash
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var/ public/var/ ezpublish_legacy/var/ src/LegacyRoot/var/site/storage/
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var/ public/var/ ezpublish_legacy/var/ src/LegacyRoot/var/site/storage/
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

# Reinstall public assets
php bin/console assets:install --symlink --relative public

# Recreate all symlinks
php bin/install-legacy-links

# Regenerate legacy autoload arrays
php bin/console ezpublish:legacy:generate-autoloads
cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php && php bin/php/ezpgenerateautoloads.php --extension && cd ..
```

### "Autoload arrays not found" in Legacy kernel

```bash
cd ezpublish_legacy
php bin/php/ezpgenerateautoloads.php
php bin/php/ezpgenerateautoloads.php --extension
cd ..
```

### ezpublish.api.repository ServiceNotFoundException

This means the `ezpublish.api.repository` service alias is missing. Verify
`config/services.yaml` contains:

```yaml
ezpublish.api.repository:
    alias: Ibexa\Contracts\Core\Repository\Repository
    public: true
```

### ngsymfonytools: "You have requested a non-existent service: templating"

The `templating` service was removed in Symfony 5.4. This means the installed version of
`se7enxweb/ngsymfonytools` is outdated. Ensure `composer.json` requires `^4.0.0.0`
and run `composer update se7enxweb/ngsymfonytools`.

---

## 23. Database Conversion

This section covers converting an **existing, running Exponential Platform Legacy application**
from one database engine to another using **free and open-source tools only**.

All tools listed below are either:
- distributed under OSI-approved open-source licences (MIT, GPL, BSD, Apache 2.0), or
- free CLI utilities included with the database server packages.

> **Before you start — backup everything.**
> ```bash
> # Backup the current DB (adjust for your engine — examples below)
> # Also backup var/, ezpublish_legacy/var/, and your .env.local
> cp .env.local .env.local.bak
> ```

---

### Tool inventory

All tools are free and open-source. Download links and cross-platform install commands are provided for every tool.

#### `mysqldump` / `mysql` CLI

Download: [dev.mysql.com/downloads/mysql](https://dev.mysql.com/downloads/mysql/) — bundled with every MySQL and MariaDB server package.

| OS family | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install default-mysql-client` |
| RHEL / AlmaLinux / Rocky | `dnf install mysql` |
| Fedora | `dnf install community-mysql` |
| openSUSE / SUSE | `zypper install mysql-client` |
| Arch / Manjaro | `pacman -S mysql-clients` |
| Slackware | included with MariaDB SlackBuild |
| FreeBSD | `pkg install mysql80-client` |
| OpenBSD | `pkg_add mariadb-client` |
| macOS (Homebrew) | `brew install mysql-client` — then `echo 'export PATH="$(brew --prefix mysql-client)/bin:$PATH"' >> ~/.zshrc` |
| macOS (MacPorts) | `port install mysql8` |
| Generic | [dev.mysql.com/downloads/mysql](https://dev.mysql.com/downloads/mysql/) |

#### `pg_dump` / `psql`

Download: [postgresql.org/download](https://www.postgresql.org/download/) — bundled with PostgreSQL server packages.

| OS family | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install postgresql-client` |
| RHEL / AlmaLinux / Rocky | `dnf install postgresql` |
| Fedora | `dnf install postgresql` |
| openSUSE / SUSE | `zypper install postgresql-client` |
| Arch / Manjaro | `pacman -S postgresql-libs` |
| Slackware | included with PostgreSQL SlackBuild |
| FreeBSD | `pkg install postgresql16-client` |
| OpenBSD | `pkg_add postgresql-client` |
| macOS (Homebrew) | `brew install libpq` — then `echo 'export PATH="$(brew --prefix libpq)/bin:$PATH"' >> ~/.zshrc` |
| macOS (MacPorts) | `port install postgresql16` |
| Generic | [postgresql.org/download](https://www.postgresql.org/download/) |

#### `sqlite3` CLI

Download: [sqlite.org/download.html](https://www.sqlite.org/download.html) — pre-built binaries for Linux, macOS, Windows.

| OS family | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install sqlite3` |
| RHEL / AlmaLinux / Rocky | `dnf install sqlite` |
| Fedora | `dnf install sqlite` |
| openSUSE / SUSE | `zypper install sqlite3` |
| Arch / Manjaro | `pacman -S sqlite` |
| Slackware | included in core |
| FreeBSD | `pkg install sqlite3` |
| OpenBSD | `pkg_add sqlite3` |
| macOS | pre-installed on all versions |
| Generic | [sqlite.org/download.html](https://www.sqlite.org/download.html) |

#### pgloader

Download / docs: [pgloader.io](https://pgloader.io) · source: [github.com/dimitri/pgloader](https://github.com/dimitri/pgloader) · Licence: PostgreSQL (BSD-like)

| OS family | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install pgloader` |
| RHEL / AlmaLinux / Rocky | build from source (see below) or use the Docker image |
| Fedora | `dnf install pgloader` |
| openSUSE / SUSE | build from source |
| Arch / Manjaro | AUR: `yay -S pgloader` |
| Slackware | build from source |
| FreeBSD | `pkg install pgloader` |
| macOS (Homebrew) | `brew install pgloader` |
| Docker (any OS) | `docker run --rm -it dimitri/pgloader:latest pgloader <args>` |
| Generic / source | `git clone https://github.com/dimitri/pgloader && cd pgloader && make pgloader` (requires SBCL) |

#### pgcopydb

Download: [github.com/dimitri/pgcopydb/releases](https://github.com/dimitri/pgcopydb/releases) · Licence: PostgreSQL (BSD-like)

| OS family | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install pgcopydb` (Debian 12+ / Ubuntu 22.04+) |
| RHEL / AlmaLinux / Rocky | pre-built RPM at [github.com/dimitri/pgcopydb/releases](https://github.com/dimitri/pgcopydb/releases) |
| Fedora | pre-built RPM from releases page |
| openSUSE / SUSE | build from source |
| Arch / Manjaro | AUR: `yay -S pgcopydb` |
| FreeBSD | build from source |
| macOS (Homebrew) | `brew install pgcopydb` |
| Docker (any OS) | `docker run --rm -it dimitri/pgcopydb pgcopydb <args>` |
| Generic binary | [github.com/dimitri/pgcopydb/releases](https://github.com/dimitri/pgcopydb/releases) |

#### mysql2sqlite

Download: [github.com/dumblob/mysql2sqlite](https://github.com/dumblob/mysql2sqlite) · Licence: MIT · single shell script, no compiled dependencies.

```bash
# Works on any UNIX / macOS / BSD with bash + sqlite3
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite
chmod +x mysql2sqlite
```

#### sqlite3-to-mysql

Download / docs: [github.com/techouse/sqlite3-to-mysql](https://github.com/techouse/sqlite3-to-mysql) · Licence: MIT · Python package, requires Python 3.8+.

| OS family | Install Python + tool |
|---|---|
| Debian / Ubuntu / Mint | `apt install python3 python3-pip && pip3 install sqlite3-to-mysql` |
| RHEL / AlmaLinux / Rocky | `dnf install python3 python3-pip && pip3 install sqlite3-to-mysql` |
| Fedora | `dnf install python3 && pip3 install sqlite3-to-mysql` |
| openSUSE / SUSE | `zypper install python3 python3-pip && pip3 install sqlite3-to-mysql` |
| Arch / Manjaro | `pacman -S python && pip install sqlite3-to-mysql` |
| Slackware | Python included in full install; `pip3 install sqlite3-to-mysql` |
| FreeBSD | `pkg install python3 && pip3 install sqlite3-to-mysql` |
| OpenBSD | `pkg_add python3 && pip3 install sqlite3-to-mysql` |
| macOS | Python pre-installed on macOS 12+; `pip3 install sqlite3-to-mysql` |
| Generic | [pypi.org/project/sqlite3-to-mysql](https://pypi.org/project/sqlite3-to-mysql/) |

#### pgslice (optional — large table partitioning)

Download: [github.com/ankane/pgslice](https://github.com/ankane/pgslice) · Licence: MIT · Ruby gem.

| OS family | Install Ruby + gem |
|---|---|
| Debian / Ubuntu / Mint | `apt install ruby && gem install pgslice` |
| RHEL / AlmaLinux / Rocky | `dnf install ruby && gem install pgslice` |
| Fedora | `dnf install ruby && gem install pgslice` |
| openSUSE / SUSE | `zypper install ruby && gem install pgslice` |
| Arch / Manjaro | `pacman -S ruby && gem install pgslice` |
| FreeBSD | `pkg install ruby && gem install pgslice` |
| macOS | Ruby pre-installed; `gem install pgslice` |
| Generic | [rubygems.org/gems/pgslice](https://rubygems.org/gems/pgslice) |

---

> [`pgloader`](https://pgloader.io) is the most capable single tool: it can load MySQL → PostgreSQL in one command
> and has a SQLite → PostgreSQL mode. Install it first; it covers most conversion paths.

---

**Quick install summary by OS family:**

```bash
# Debian / Ubuntu / Mint / Pop!_OS
apt install default-mysql-client postgresql-client sqlite3 pgloader pgcopydb python3-pip ruby
pip3 install sqlite3-to-mysql
gem install pgslice
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite && chmod +x mysql2sqlite

# RHEL / CentOS / AlmaLinux / Rocky Linux (EPEL required)
dnf install epel-release
dnf install mysql postgresql sqlite pgloader python3-pip ruby
pip3 install sqlite3-to-mysql
gem install pgslice
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite && chmod +x mysql2sqlite

# Fedora
dnf install community-mysql postgresql sqlite pgloader python3-pip ruby
pip3 install sqlite3-to-mysql
gem install pgslice
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite && chmod +x mysql2sqlite

# openSUSE / SUSE SLES
zypper install mysql-client postgresql-client sqlite3 python3-pip ruby
pip3 install sqlite3-to-mysql
gem install pgslice
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite && chmod +x mysql2sqlite
# pgloader: brew or Docker

# Arch Linux / Manjaro
pacman -S mysql-clients postgresql sqlite python ruby
pip install sqlite3-to-mysql
gem install pgslice
yay -S pgloader pgcopydb
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite && chmod +x mysql2sqlite

# macOS (Homebrew)
brew install mysql-client libpq pgloader pgcopydb python3 ruby sqlite3
pip3 install sqlite3-to-mysql
gem install pgslice
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite && chmod +x mysql2sqlite

# FreeBSD
pkg install mysql80-client postgresql16-client sqlite3 pgloader pgcopydb python3 ruby
pip3 install sqlite3-to-mysql
gem install pgslice
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite && chmod +x mysql2sqlite

# Docker (distro-agnostic)
docker pull dimitri/pgloader:latest
docker pull dimitri/pgcopydb:latest
```

---

### 23a. Any → SQLite (go to SQLite)

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
> converter. For large databases, consider exporting table-by-table.

For large datasets, dump table-by-table to avoid memory pressure:

```bash
# list tables
TABLES=$(mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e 'SHOW TABLES;' --batch --skip-column-names)

for TABLE in $TABLES; do
  mysqldump --no-tablespaces --skip-extended-insert --compact \
    -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" "$TABLE" \
    | ./mysql2sqlite - >> /tmp/dump.sql
done

sqlite3 var/data_dev.db < /tmp/dump.sql
```

#### From PostgreSQL → SQLite

Use [**pgloader**](https://pgloader.io) (PostgreSQL-licenced):

```bash
apt install pgloader          # Debian/Ubuntu
# or: brew install pgloader  # macOS

# Create an empty target file
touch var/data_dev.db

# pgloader command file (save as convert.load)
cat > /tmp/pg_to_sqlite.load <<'EOF'
LOAD DATABASE
  FROM postgresql://db_user:db_pass@127.0.0.1/db_name
  INTO sqlite:///{{ project_dir }}/var/data_dev.db

WITH include no drop, create tables, create indexes, reset sequences

SET work_mem TO '128MB', maintenance_work_mem TO '512MB';
EOF

# Replace {{ project_dir }} with the actual absolute path
sed -i "s|{{ project_dir }}|$(pwd)|g" /tmp/pg_to_sqlite.load

pgloader /tmp/pg_to_sqlite.load
```

#### After migrating to SQLite — update .env.local

```dotenv
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_dev.db"
MESSENGER_TRANSPORT_DSN=sync://
```

Fix permissions and clear caches (see [Section 5c](#5c-sqlite-zero-config-database) steps 4–5).

---

### 23b. SQLite → MySQL / MariaDB

Create the target database first (see [Section 5 — Database Setup](#5-database-setup)).

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

# --chunk 1000 inserts 1000 rows per batch — tune for your server
```

Verify the row counts match:

```bash
# SQLite side
sqlite3 var/data_dev.db "SELECT name, COUNT(*) FROM sqlite_master WHERE type='table' GROUP BY name ORDER BY name;"

# MySQL side
mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" \
  -e "SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema='$DATABASE_NAME' ORDER BY table_name;"
```

#### Method 2 — manual SQL dump + sed fixes

SQLite's `.dump` produces ANSI SQL that MySQL almost accepts; the main differences are
quoting style and type names:

```bash
# 1. Dump from SQLite
sqlite3 var/data_dev.db .dump > /tmp/sqlite_dump.sql

# 2. Strip SQLite-specific preamble that MySQL rejects
sed -i '/^PRAGMA/d; /^BEGIN TRANSACTION/d; /^COMMIT/d; /^CREATE UNIQUE INDEX/d' /tmp/sqlite_dump.sql

# 3. Convert double-quoted identifiers to backtick-quoted
sed -i 's/"\([a-zA-Z_][a-zA-Z0-9_]*\)"/`\1`/g' /tmp/sqlite_dump.sql

# 4. Map SQLite types to MySQL equivalents
sed -i 's/INTEGER PRIMARY KEY AUTOINCREMENT/INT NOT NULL AUTO_INCREMENT PRIMARY KEY/g' /tmp/sqlite_dump.sql
sed -i 's/ BOOLEAN/ TINYINT(1)/g; s/ DATETIME/ DATETIME/g' /tmp/sqlite_dump.sql

# 5. Import
mysql -u "$DATABASE_USER" -p"$DATABASE_PASSWORD" "$DATABASE_NAME" < /tmp/sqlite_dump.sql
```

> The sed approach is fragile on complex schemas. Prefer `sqlite3-to-mysql` for production
> data migrations.

#### After migrating — update .env.local

```dotenv
DATABASE_DRIVER=pdo_mysql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=3306
DATABASE_NAME=your_db_name
DATABASE_USER=your_db_user
DATABASE_PASSWORD=your_db_password
DATABASE_CHARSET=utf8mb4
DATABASE_COLLATION=utf8mb4_unicode_520_ci
DATABASE_VERSION=mariadb-10.6.0   # or MySQL version e.g. 8.0
# Remove or comment out DATABASE_URL and MESSENGER_TRANSPORT_DSN=sync://
```

---

### 23c. SQLite → PostgreSQL

Use [**pgloader**](https://pgloader.io) — it has native SQLite source support:

```bash
apt install pgloader

# Create the target database
psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8';"

# Write a pgloader command file
cat > /tmp/sqlite_to_pg.load <<EOF
LOAD DATABASE
  FROM sqlite:///$(pwd)/var/data_dev.db
  INTO postgresql://pg_user:pg_pass@127.0.0.1/exponential

WITH include no drop, create tables, create indexes, reset sequences;
EOF

pgloader /tmp/sqlite_to_pg.load
```

pgloader handles:
- Type mapping (INTEGER → bigint, TEXT → text, REAL → double precision)
- Index creation
- Sequence reset so `nextval()` picks up after the highest existing ID

#### After migrating — update .env.local

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

---

### 23d. MySQL / MariaDB → PostgreSQL

Use [**pgloader**](https://pgloader.io) — this is its primary, most mature use-case:

```bash
apt install pgloader

# Target DB
psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8';"

# pgloader command file
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

EXCLUDING TABLE NAMES MATCHING ~/session/  -- optional: skip session tables

CAST
  -- MySQL enums → text (PostgreSQL enum DDL is cumbersome)
  column type matching ~/enum/ to text,
  -- tinyint(1) → boolean
  type tinyint to boolean using tinyint-to-boolean,
  -- longtext / mediumtext → text
  type longtext to text, type mediumtext to text,
  -- unsigned int
  type int with unsigned to bigint;
EOF

pgloader /tmp/mysql_to_pg.load
```

Verify row counts:

```bash
# MySQL total rows
mysql -u db_user -pdb_pass source_db \
  -e "SELECT SUM(table_rows) FROM information_schema.tables WHERE table_schema='source_db';"

# PostgreSQL total rows (approximate)
psql -U pg_user exponential \
  -c "SELECT schemaname, tablename, n_live_tup AS rows FROM pg_stat_user_tables ORDER BY tablename;"
```

#### After migrating — update .env.local

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

---

### 23e. PostgreSQL → MySQL / MariaDB

There is no single widely-adopted tool for this direction; the most reliable free approach
is a **pg_dump CSV export + MySQL LOAD DATA** pipeline.

#### Step 1 — Export each table as CSV from PostgreSQL

```bash
TARGET_DIR=/tmp/pg_csv_export
mkdir -p "$TARGET_DIR"

# Get table list
TABLES=$(psql -U pg_user -d exponential -t \
  -c "SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename;")

for TABLE in $TABLES; do
  TABLE=$(echo "$TABLE" | xargs)  # trim whitespace
  psql -U pg_user -d exponential \
    -c "\COPY \"$TABLE\" TO '$TARGET_DIR/$TABLE.csv' WITH (FORMAT csv, HEADER true, NULL '\\N');"
done
```

#### Step 2 — DDL: dump structure from PostgreSQL, convert to MySQL

```bash
# Dump PostgreSQL DDL only
pg_dump -U pg_user --schema-only exponential > /tmp/pg_schema.sql

# pgloader can convert schema only (no data) into MySQL dialect:
cat > /tmp/schema_only.load <<'EOF'
LOAD DATABASE
  FROM      postgresql://pg_user:pg_pass@127.0.0.1/exponential
  INTO      mysql://db_user:db_pass@127.0.0.1/target_db

WITH include no drop, create tables, no data;
EOF

pgloader /tmp/schema_only.load
```

> **Note**: pgloader's MySQL target support is less mature than its PostgreSQL target.
> Inspect the generated schema and fix any `bytea`, `jsonb`, `array`, or custom-type columns
> manually.

#### Step 3 — Import CSVs into MySQL

```bash
for CSV in "$TARGET_DIR"/*.csv; do
  TABLE=$(basename "$CSV" .csv)
  # MySQL LOAD DATA requires the file to be on the server or use LOCAL keyword
  mysql --local-infile=1 \
    -u db_user -pdb_pass target_db \
    -e "LOAD DATA LOCAL INFILE '$CSV'
        INTO TABLE \`$TABLE\`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '\"'
        LINES TERMINATED BY '\n'
        IGNORE 1 ROWS;"
done
```

> Grant `local_infile` on the server if needed:
> ```sql
> SET GLOBAL local_infile = 1;
> ```

#### After migrating — update .env.local

```dotenv
DATABASE_DRIVER=pdo_mysql
DATABASE_HOST=127.0.0.1
DATABASE_PORT=3306
DATABASE_NAME=target_db
DATABASE_USER=db_user
DATABASE_PASSWORD=db_pass
DATABASE_CHARSET=utf8mb4
DATABASE_COLLATION=utf8mb4_unicode_520_ci
DATABASE_VERSION=mariadb-10.6.0
```

---

### 23f. Any → Oracle (export only)

Oracle XE (Express Edition) is free to use but **not open-source**. The recommended
free/open-source path for Oracle targets is to use **SQLcl** (Oracle free CLI tool) or
Doctrine Migrations to re-create the schema, then bulk-import data via SQL\*Loader or
an intermediary CSV. Full Oracle migration is outside the scope of this guide.

For teams moving **from** Oracle to MySQL/PostgreSQL the recommended approach is:
1. Export via [**ora2pg**](https://github.com/darold/ora2pg) (GPL v3) — the industry-standard
   open-source Oracle-to-PostgreSQL migration tool.
2. Then follow the PostgreSQL → MySQL path above if MySQL is the target.

```bash
apt install ora2pg

# Minimal ora2pg config (~/.ora2pg.conf or /etc/ora2pg/ora2pg.conf)
cat > /tmp/ora2pg.conf <<'EOF'
ORACLE_DSN  dbi:Oracle:host=oracle_host;sid=ORCL
ORACLE_USER system
ORACLE_PWD  password
SCHEMA      YOUR_SCHEMA
TYPE        TABLE, INSERT, SEQUENCE, INDEX, CONSTRAINT
OUT_FILE    /tmp/ora_export.sql
QUOTE_STRING_WITH_DOLLAR 0
EOF

ora2pg -c /tmp/ora2pg.conf
psql -U pg_user exponential < /tmp/ora_export.sql
```

---

### 23g. Post-conversion checklist

After any database engine switch, run through every item:

```bash
# 1. Update .env.local with the new DATABASE_URL or database vars
$EDITOR .env.local

# 2. Clear the Symfony container and cache (it caches the DBAL connection)
php bin/console cache:clear

# 3. Clear the legacy kernel cache (it reads DB config from its own ini cache)
php bin/console ezpublish:legacy:clear-cache

# 4. Validate Doctrine entity mappings against the new DB
php bin/console doctrine:schema:validate

# 5. Run any pending Doctrine migrations
php bin/console doctrine:migration:migrate --allow-no-migration

# 6. Re-run the legacy autoload generator (safe to run again; it regenerates the array)
php bin/console ezpublish:legacy:generate-autoloads

# 7. Regenerate the search index against the new DB
php bin/console ezplatform:reindex

# 8. Smoke-test the site
curl -I http://localhost/
curl -I http://localhost/adminui/
curl -I http://localhost/legacy_admin/

# 9. If using SQLite as target — fix file permissions
# (skip for MySQL/PostgreSQL)
chmod 664 var/data_dev.db
chown "$USER":www-data var/data_dev.db
```

#### Common post-conversion issues

| Symptom | Cause | Fix |
|---|---|---|
| `SQLSTATE[42S02]: Base table not found` | Table created in source but not migrated | Run `doctrine:schema:validate` and check pgloader/mysql2sqlite log for errors |
| Binary/blob content garbled | Charset mismatch during export | Re-export with explicit `--default-character-set=utf8mb4` (mysqldump) or `CLIENT_ENCODING=UTF8` (psql) |
| `Serialization failure` (PostgreSQL) | Concurrent access during import | Import with `APP_ENV=dev` and no web traffic; use a maintenance window |
| Image variation 404s | `ezcontentobject_attribute` row count mismatch | Verify row counts between source and target; re-run data transfer for that table |
| Legacy Admin 500 after conversion | Legacy kernel ini cache has old DB type | `php bin/console ezpublish:legacy:clear-cache` then reload |
| SQLite `attempt to write a readonly database` | Web server user cannot write the `.db` file | `chmod 664 var/data_*.db && chown $USER:www-data var/data_*.db` |

> 💾 **Git Save Point — database conversion complete**
> ```bash
> git add .env.local.bak   # keep the backup of the old config as a reference
> git commit -m "chore(db): convert database from <source> to <target>"
> ```

---

## 24. Complete CLI Reference

A comprehensive reference of every CLI command used in day-to-day development, maintenance,
and operations. For help on any command run `php bin/console help <command>`.

---

### 24.1 Symfony Core

```bash
# ── Discovery ──────────────────────────────────────────────────────────────
php bin/console list                             # list all registered commands
php bin/console list ez                          # list all ez* commands
php bin/console list ezpublish                   # list LegacyBridge commands
php bin/console help <command>                   # detailed help for any command

# ── Cache ──────────────────────────────────────────────────────────────────
php bin/console cache:clear                      # clear current APP_ENV cache
php bin/console cache:clear --env=prod           # clear production cache
php bin/console cache:warmup --env=prod          # warm up production cache
php bin/console cache:pool:clear cache.redis     # clear a named cache pool
php bin/console cache:pool:list                  # list all registered cache pools

# ── Assets ─────────────────────────────────────────────────────────────────
php bin/console assets:install --symlink --relative public   # publish bundle assets

# ── Routing ────────────────────────────────────────────────────────────────
php bin/console debug:router                     # list all routes
php bin/console debug:router <route-name>        # detail one route
php bin/console router:match /path/to/page       # which route matches a URL

# ── Container / Services ───────────────────────────────────────────────────
php bin/console debug:container                  # list all service IDs
php bin/console debug:container <service-id>     # show service definition
php bin/console debug:autowiring                 # list autowireable types
php bin/console debug:config <bundle>            # dump resolved bundle config
php bin/console debug:event-dispatcher           # list all registered listeners

# ── Twig ───────────────────────────────────────────────────────────────────
php bin/console debug:twig                       # list Twig extensions/filters/functions
php bin/console lint:twig templates/             # lint all Twig templates

# ── YAML / Config ──────────────────────────────────────────────────────────
php bin/console lint:yaml config/                # lint all YAML config files
php bin/console debug:config framework           # dump framework bundle config

# ── Messenger (async queues) ───────────────────────────────────────────────
php bin/console messenger:consume                # consume messages from queue
php bin/console messenger:consume --limit=10     # consume then exit
php bin/console messenger:stop-workers           # signal all workers to stop

# ── JWT ────────────────────────────────────────────────────────────────────
php bin/console lexik:jwt:generate-keypair               # generate RSA keypair
php bin/console lexik:jwt:generate-keypair --overwrite   # rotate keypair
```

---

### 24.2 Doctrine / Migrations

```bash
# ── Migrations ─────────────────────────────────────────────────────────────
php bin/console doctrine:migration:migrate --allow-no-migration   # run pending migrations
php bin/console doctrine:migration:migrate --dry-run              # preview SQL only
php bin/console doctrine:migration:status                         # show pending/applied status
php bin/console doctrine:migration:diff                           # generate migration from entity diff
php bin/console doctrine:migration:execute --up <version>         # run one migration up
php bin/console doctrine:migration:execute --down <version>       # roll back one migration
php bin/console doctrine:migration:latest                         # show latest version number
php bin/console doctrine:migration:list                           # list all versions

# ── Schema ─────────────────────────────────────────────────────────────────
php bin/console doctrine:schema:validate                          # validate entity ↔ DB schema
php bin/console doctrine:schema:update --dump-sql                 # preview schema changes

# ── Database ───────────────────────────────────────────────────────────────
php bin/console doctrine:database:create                          # create the database
php bin/console doctrine:database:drop --force                    # drop the database (DESTRUCTIVE)
```

---

### 24.3 Platform v4 New Stack

```bash
# ── Installation ───────────────────────────────────────────────────────────
php bin/console ibexa:install exponential-oss             # schema + demo data (Exponential OSS type)
php bin/console ibexa:install ibexa-oss                   # schema + demo data (upstream Ibexa OSS type)
# Deprecated command alias — both types still work via it:
# php bin/console ezplatform:install exponential-oss

# ── Search / Reindex ───────────────────────────────────────────────────────
php bin/console ezplatform:reindex                         # full reindex
php bin/console ezplatform:reindex --iteration-count=100   # incremental
php bin/console ezplatform:reindex --content-type=article  # one content type
php bin/console ezplatform:solr:create-core --cores=default  # provision Solr core

# ── Content Repository ─────────────────────────────────────────────────────
php bin/console ezplatform:content:cleanup-drafts          # remove stale drafts
php bin/console ezplatform:content:cleanup-versions --keep=3  # keep last N per content

# ── Cron ───────────────────────────────────────────────────────────────────
php bin/console ezplatform:cron:run                        # run Platform v4 cron scheduler
php bin/console ezplatform:cron:run --quiet                # suppress output (use in crontab)

# ── GraphQL ────────────────────────────────────────────────────────────────
php bin/console ezplatform:graphql:generate-schema         # regenerate from content model

# ── HTTP Cache ─────────────────────────────────────────────────────────────
php bin/console fos:httpcache:invalidate:path / --all      # purge all HTTP cache paths
php bin/console fos:httpcache:invalidate:tag <tag>         # purge by cache tag

# ── JS Translations (Admin UI i18n) ────────────────────────────────────────
php bin/console bazinga:js-translation:dump public/assets --merge-domains

# ── Image Variations ───────────────────────────────────────────────────────
php bin/console liip:imagine:cache:remove                  # remove all cached variations
php bin/console liip:imagine:cache:remove --filter=small   # remove one variation alias

# ── Config Inspection ──────────────────────────────────────────────────────
php bin/console ezplatform:debug:dump-info                 # dump platform environment info
php bin/console debug:config ibexa                         # dump full resolved platform config
```

---

### 24.4 Exponential (Legacy) Kernel & LegacyBridge

```bash
# ── Cache ──────────────────────────────────────────────────────────────────
# Clears legacy template cache, ini cache, content object cache, override cache
php bin/console ezpublish:legacy:clear-cache

# ── Autoloads ──────────────────────────────────────────────────────────────
# Regenerate legacy autoload arrays — required after adding/removing extensions
php bin/console ezpublish:legacy:generate-autoloads

# From inside the legacy directory (also regenerates extension autoloads)
cd ezpublish_legacy
php bin/php/ezpgenerateautoloads.php
php bin/php/ezpgenerateautoloads.php --extension
cd ..

# ── Script Runner ──────────────────────────────────────────────────────────
# Run any legacy script (import scripts, one-off maintenance)
php bin/console ezpublish:legacy:script <script-name>

# ── Cronjobs (direct — bypass Symfony, use in crontab) ─────────────────────
php ezpublish_legacy/runcronjobs.php --siteaccess legacy_admin
php ezpublish_legacy/runcronjobs.php --siteaccess legacy_site

# ── Legacy Symlinks (LegacyBridge edition specific) ────────────────────────
php bin/install-legacy-links     # Create/verify all src/ → ezpublish_legacy/ symlinks

# ── Legacy Console (native CLI — direct access to legacy internals) ─────────
php ezpublish_legacy/bin/php/ezcli.php list
php ezpublish_legacy/bin/php/ezcli.php content search --query="lorem"

# ── Legacy Admin URLs ──────────────────────────────────────────────────────
# /legacy_admin/          — Legacy Admin UI via LegacyBridge
# /legacy_admin/index.php — alternative entry point
```

---

### 24.5 Frontend / Asset Build (Yarn / Webpack Encore)

```bash
# ── Node version ───────────────────────────────────────────────────────────
source ~/.nvm/nvm.sh && nvm use 20     # activate Node.js 20 LTS
corepack enable                        # activates yarn 1.22.22

# ── Package management ─────────────────────────────────────────────────────
yarn install                           # install / sync all Node dependencies
yarn upgrade                           # upgrade packages within semver constraints
yarn add <package>                     # add a new dependency
yarn remove <package>                  # remove a dependency

# ── Site asset builds ──────────────────────────────────────────────────────
yarn dev                               # build with source maps (development)
yarn build                             # build minified (production)
yarn watch                             # watch mode — auto-rebuild on source change

# ── Admin UI asset builds ──────────────────────────────────────────────────
yarn ibexa:dev                         # build Platform v4 Admin UI — dev mode
yarn ibexa:build                       # build Platform v4 Admin UI — production
yarn ibexa:watch                       # watch Admin UI assets for changes

# ── Inspection ─────────────────────────────────────────────────────────────
yarn list                              # list installed packages and versions
```

---

### 24.6 Composer Maintenance

```bash
# ── Installing ─────────────────────────────────────────────────────────────
composer install                        # install from composer.lock
composer install --no-dev               # production (no dev dependencies)
composer install --no-dev -o            # production + optimised autoloader

# ── Updating ───────────────────────────────────────────────────────────────
composer update                         # update all within constraints
composer update se7enxweb/legacy-bridge # update one package
composer update --dry-run               # preview without applying

# ── Autoloader ─────────────────────────────────────────────────────────────
composer dump-autoload                  # regenerate autoloader
composer dump-autoload -o               # optimised (production) autoloader

# ── Scripts ────────────────────────────────────────────────────────────────
composer run-script project-scripts     # run all defined post-install scripts

# ── Info / Audit ───────────────────────────────────────────────────────────
composer show                           # list all installed packages
composer show se7enxweb/legacy-bridge   # detail one package
composer outdated                       # list outdated packages
composer audit                          # check for security advisories
composer validate                       # validate composer.json / composer.lock
```

---

### 24.7 Symfony CLI

```bash
symfony server:start                    # start HTTPS dev server (https://127.0.0.1:8000)
symfony server:start -d                 # start in background daemon mode
symfony server:stop                     # stop background server
symfony server:log                      # tail server access/error log
symfony server:status                   # show server status + URL

symfony check:requirements              # verify PHP + extension requirements
symfony check:security                  # audit composer.lock for known CVEs
symfony local:php:list                  # list PHP versions available via Symfony CLI
symfony php bin/console <cmd>           # run console through Symfony CLI's PHP version
```

---

### 24.8 Git Workflow Shortcuts

```bash
# ── Branching ──────────────────────────────────────────────────────────────
git checkout -b feature/my-feature          # new feature branch off current
git checkout 3.x                            # switch to the stable branch

# ── Save Points ────────────────────────────────────────────────────────────
git add -A && git commit -m "chore: <description>"
git stash                                   # save uncommitted work temporarily
git stash pop                               # restore stashed work

# ── Tags (deploy markers) ──────────────────────────────────────────────────
git tag -a "deploy-$(date +%Y%m%d-%H%M)" -m "deploy $(date)"
git push origin --tags

# ── Useful inspection ──────────────────────────────────────────────────────
git log --oneline -20                       # last 20 commits
git diff HEAD                               # uncommitted changes
git status                                  # working tree status
```

---

*For web server configuration templates see `doc/apache2/` and `doc/nginx/` (if present).*
*For Docker-based development see `doc/docker/` and `compose.override.yaml` (if present).*
*For deployment automation see `deploy.php` and `deploy/` (if present).*

---

*Copyright &copy; 1998 – 2026 7x (se7enx.com). All rights reserved unless otherwise noted.*
*Exponential Platform Legacy is Open Source software released under the GNU GPL v2 or any later version.*
