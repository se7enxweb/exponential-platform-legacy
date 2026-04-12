# Exponential Platform DXP v5 (Platform v5; Open Source; Starter Skeleton)
## Installation & Operations Guide

> **Platform v5 DXP** is the standard single-kernel release of Exponential Platform DXP. It runs the **Exponential Platform v5 OSS** new-stack kernel on **Symfony 7.4 LTS** with **PHP 8.3+**.
>
> This guide uses numbered **Git Save Points** throughout. Commit at each one so you can return to any working checkpoint without redoing completed work.
>
> This installation is straightforward for a modern Symfony project. Read it in full before starting.

---

> **Console Command Prefix Convention**
>
> All `bin/console` commands in this distribution support three name prefixes. Only `exponential:` is the canonical name going forward; the others are deprecated aliases that remain fully functional for backward compatibility:
>
> | **Preferred — use this** | Deprecated (functional) | Deprecated (functional) |
> |---|---|---|
> | `exponential:*` | `ibexa:*` | `ezplatform:*` / `ezpublish:*` |
>
> Commands in this guide use `exponential:*` where the rename has been applied. Commands not yet migrated retain their `ibexa:*` name (e.g. `ibexa:cron:run`, `ibexa:graphql:generate-schema`) — they are fully functional as-is. The `ezplatform:*` prefix does not exist in v5.

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
7. [File & Directory Permissions](#7-file--directory-permissions)
8. [Frontend Assets (Site CSS/JS)](#8-frontend-assets-site-cssjs)
9. [Admin UI Assets (Platform v5 Admin UI)](#9-admin-ui-assets-platform-v5-admin-ui)
10. [JWT Authentication (REST API)](#10-jwt-authentication-rest-api)
11. [GraphQL Schema](#11-graphql-schema)
12. [Search Index](#12-search-index)
13. [Image Variations](#13-image-variations)
14. [Cache Management](#14-cache-management)
15. [Day-to-Day Operations: Start / Stop / Restart](#15-day-to-day-operations-start--stop--restart)
16. [Updating the Codebase](#16-updating-the-codebase)
17. [Cron Jobs](#17-cron-jobs)
18. [Solr Search Engine (optional)](#18-solr-search-engine-optional)
19. [Varnish HTTP Cache (optional)](#19-varnish-http-cache-optional)
20. [Troubleshooting](#20-troubleshooting)
21. [Database Conversion](#21-database-conversion)
    - [21a. Any → SQLite](#21a-any--sqlite-go-to-sqlite)
    - [21b. SQLite → MySQL / MariaDB](#21b-sqlite--mysql--mariadb)
    - [21c. SQLite → PostgreSQL](#21c-sqlite--postgresql)
    - [21d. MySQL / MariaDB → PostgreSQL](#21d-mysql--mariadb--postgresql)
    - [21e. PostgreSQL → MySQL / MariaDB](#21e-postgresql--mysql--mariadb)
    - [21f. Any → Oracle (export only)](#21f-any--oracle-export-only)
    - [21g. Post-conversion checklist](#21g-post-conversion-checklist)
22. [Complete CLI Reference](#22-complete-cli-reference)

---

## 1. Requirements

### PHP

- **PHP 8.3+** (PHP 8.3 or 8.5 strongly recommended)
- Required extensions: `gd` or `imagick`, `curl`, `json`, `pdo_mysql` or `pdo_pgsql` or `pdo_sqlite`, `xsl`, `xml`, `intl`, `mbstring`, `opcache`, `ctype`, `iconv`
- For SQLite: `pdo_sqlite` + `sqlite3` PHP extensions (usually bundled with PHP; verify with `php -m | grep -i sqlite`)
- `memory_limit` ≥ 256M (512M recommended) — set in `php.ini` or `.htaccess`; restart the web server after changes
- `date.timezone` must be set in `php.ini` — see https://php.net/manual/en/timezones.php
- `max_execution_time` ≥ 120 (recommended 300 for CLI operations)

### Web Server

- **Apache 2.4** with `mod_rewrite`, `mod_deflate`, `mod_headers`, `mod_expires` enabled; run in `event` or `worker` mode with PHP-FPM _or_
- **Nginx 1.18+** with PHP-FPM

### Node.js & Yarn

- [Node.js](https://nodejs.org/en/download/) **20 LTS** — managed via [nvm](https://github.com/nvm-sh/nvm) (recommended on all platforms)
- [Yarn](https://classic.yarnpkg.com/en/docs/install) **1.22.x** — activated via [corepack](https://github.com/nodejs/corepack) `enable` after `nvm use 20`
- Do not use Node.js 18 or 22 — only 20 LTS is tested and supported for this release

Installing nvm + Node.js 20 LTS (all UNIX / macOS / BSD / WSL):

```bash
# Universal installer — works on Linux (all distros), macOS, BSD, WSL
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
source ~/.nvm/nvm.sh           # or restart your shell
nvm install 20
nvm use 20
corepack enable                # activates Yarn 1.22.x
```

| OS | Package manager install |
|---|---|
| Debian / Ubuntu / Mint / Pop!_OS | `apt install nodejs npm` then `npm i -g yarn` |
| RHEL / CentOS / AlmaLinux / Rocky | `dnf module enable nodejs:20 && dnf install nodejs` |
| Fedora | `dnf install nodejs` |
| openSUSE / SUSE SLES | `zypper install nodejs20` |
| Arch / Manjaro | `pacman -S nodejs npm` |
| FreeBSD | `pkg install node20` |
| macOS (Homebrew) | `brew install node@20` |
| Generic binary | nodejs.org/en/download |

### Composer

- [Composer](https://getcomposer.org/) **2.x** — run `composer self-update` to ensure you are on the latest 2.x release

```bash
# Universal installer (all UNIX / macOS / BSD)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --2          # install Composer v2
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
```

| OS | Package manager install |
|---|---|
| Debian / Ubuntu / Mint | `apt install composer` (may be older — prefer the installer above) |
| RHEL / AlmaLinux / Rocky | `dnf install composer` (EPEL required: `dnf install epel-release`) |
| Fedora | `dnf install composer` |
| openSUSE / SUSE | `zypper install php-composer2` |
| Arch / Manjaro | `pacman -S composer` |
| Slackware | SlackBuild at slackbuilds.org |
| FreeBSD | `pkg install php83-composer` (adjust PHP version) |
| macOS (Homebrew) | `brew install composer` |
| macOS (MacPorts) | `port install php-composer` |
| Generic | getcomposer.org/download |

### Database

- [MySQL](https://dev.mysql.com/downloads/) **8.0+** with `utf8mb4` character set and `utf8mb4_unicode_520_ci` collation _or_
- [MariaDB](https://mariadb.org/download/) **10.3+** (10.6+ recommended) _or_
- [PostgreSQL](https://www.postgresql.org/download/) **14+** _or_
- [SQLite](https://www.sqlite.org/download.html) **3.35+** — no server required; the `.db` file is created automatically on first install. Recommended for local development, testing, demos, and air-gapped deployments only. Requires the `pdo_sqlite` and `sqlite3` PHP extensions.

| OS | MySQL install | MariaDB install |
|---|---|---|
| Debian / Ubuntu / Mint | `apt install mysql-server` | `apt install mariadb-server` |
| RHEL / CentOS / AlmaLinux / Rocky | `dnf install mysql-server` | `dnf install mariadb-server` |
| Fedora | `dnf install community-mysql-server` | `dnf install mariadb-server` |
| Arch / Manjaro | `pacman -S mysql` or `pacman -S mariadb` | same |
| FreeBSD | `pkg install mysql80-server` | `pkg install mariadb1011-server` |
| macOS (Homebrew) | `brew install mysql` | `brew install mariadb` |
| Generic binary | dev.mysql.com/downloads | mariadb.org/download |

| OS | PostgreSQL install |
|---|---|
| Debian / Ubuntu / Mint | `apt install postgresql` |
| RHEL / CentOS / AlmaLinux / Rocky | `dnf install postgresql-server && postgresql-setup --initdb` |
| Fedora | `dnf install postgresql-server` |
| Arch / Manjaro | `pacman -S postgresql` |
| FreeBSD | `pkg install postgresql16-server` |
| macOS (Homebrew) | `brew install postgresql@16` |
| Generic | postgresql.org/download |

### Optional

- [Redis](https://redis.io/download/) **6+** — recommended for production caching and sessions
- [Solr](https://solr.apache.org/downloads.html) **8.11.x** — for advanced full-text search (default engine is legacy)
- [Varnish](https://varnish-cache.org/releases/) **6.0 or 7.1+** — for HTTP reverse-proxy caching
- [ImageMagick](https://imagemagick.org/script/download.php) — for advanced image processing (`IMAGEMAGICK_PATH` env var, default `/usr/bin`)

### Full Requirements Summary

| Component | Minimum | Recommended |
|---|---|---|
| PHP | 8.3 | 8.3 or 8.5 |
| Composer | 2.x | latest 2.x |
| Node.js | 20 LTS | 20 LTS (via nvm) |
| Yarn | 1.x | 1.22.22 (corepack) |
| MySQL | 8.0 | 8.0+ (utf8mb4) |
| MariaDB | 10.3 | 10.6+ |
| PostgreSQL | 14 | 16+ |
| SQLite | 3.35 | 3.39+ (dev/testing) |
| Redis | 6.0 | 7.x (optional) |
| Solr | 8.x | 8.11.x (optional) |
| Varnish | 6.0 | 7.1+ (optional) |
| Apache | 2.4 | 2.4 (event + PHP-FPM) |
| Nginx | 1.18 | 1.24+ |

---

## 2. Architecture Overview

Platform v5 DXP is a clean, single-kernel Symfony application.

```
Browser Request
      │
      ▼
   Web Server (Apache / Nginx)
      │
      ▼
  public/index.php (Symfony Entry Point)
      │
      ▼
  Symfony Kernel (Platform v5 OSS — Symfony 7.4 LTS)
      ├── Exponential Platform v5 Admin UI (/adminui/)
      ├── REST API v2 (/api/ezp/v2/)
      ├── GraphQL API (/graphql)
      └── Symfony/Twig site controllers (/)
```

### Siteaccesses

| Siteaccess | Purpose | URL |
|---|---|---|
| `site` | Twig front end | `/` (Symfony router) |
| `admin` | Platform v5 Admin UI | `/adminui/` |

### Key Directories

```
project-root/
├── src/
│   ├── Controller/            Symfony controllers for your site
│   ├── Entity/                Doctrine entities (if used)
│   └── Kernel.php             Application kernel
├── config/
│   ├── packages/              Bundle configuration (ibexa.yaml, security.yaml, etc.)
│   ├── routes/                Route definitions
│   └── services.yaml          Service definitions
├── templates/
│   └── themes/                Twig templates by siteaccess/theme
├── assets/
│   ├── js/                    Site JavaScript source
│   ├── scss/                  Site SCSS source
│   └── styles/                Additional stylesheets
├── public/                    Web root
│   ├── assets/                Built frontend assets (Webpack Encore output)
│   │   └── app/               Site assets (build/ for prod, build_dev/ for dev)
│   └── bundles/               Symfony public assets (symlinked by assets:install)
├── var/
│   ├── cache/                 Symfony application cache
│   ├── log/                   Application logs
│   └── data_<env>.db          SQLite database (if using SQLite)
└── vendor/                    PHP packages (composer-managed; not committed)
```

---

## 3. First-Time Installation

### 3a. Composer create-project (recommended)

```bash
composer create-project se7enxweb/exponential-platform-dxp-skeleton \
    my-project
cd my-project
```

Composer will:

1. Download all PHP packages
2. Run Symfony Flex recipes (including the `se7enxweb/exponential-platform-dxp` recipe)
3. Execute `post-install-cmd` scripts:
   - `assets:install` — publishes bundle `public/` assets to `public/bundles/`
   - `cache:clear` — warms up the initial cache

> 💾 **Git Save Point 1 — Project created**
> ```bash
> git init && git add -A
> git commit -m "chore(init): composer create-project exponential-platform-dxp dev-master"
> ```

Continue from Section 4.

### 3b. GitHub git clone (developers)

```bash
git clone git@github.com:se7enxweb/exponential-platform-dxp-skeleton.git
cd exponential-platform-dxp-skeleton
git checkout master
```

#### Step 1 — Install PHP dependencies

```bash
composer install --keep-vcs
```

This downloads all packages and runs `post-install-cmd` scripts (assets, cache).

> 💾 **Git Save Point 1 — Vendors installed**
> ```bash
> git add composer.lock && git commit -m "chore(install): lock vendor dependencies"
> ```

#### Step 2 — Configure environment

See Section 4.

#### Step 3 — Create the database

See Section 5.

#### Step 4 — Set permissions

See Section 7.

#### Step 5 — Build frontend assets

```bash
source ~/.nvm/nvm.sh && nvm use 20
yarn install
yarn dev
```

#### Step 6 — Build Admin UI assets

```bash
php bin/console assets:install --symlink --relative public
yarn ibexa:build
```

#### Step 7 — Generate JWT keypair

```bash
php bin/console lexik:jwt:generate-keypair
```

#### Step 8 — Generate GraphQL schema

```bash
php bin/console ibexa:graphql:generate-schema
```

#### Step 9 — Clear all caches

```bash
php bin/console cache:clear
```

#### Step 10 — Reindex search

```bash
php bin/console exponential:reindex
```

> 💾 **Git Save Point 2 — Installation complete**
> ```bash
> git add -A
> git commit -m "chore(install): platform v5 DXP install complete"
> ```

#### Step 11 — Start the dev server

```bash
symfony server:start
```

Access points after install:

| URL | Description |
|---|---|
| https://127.0.0.1:8000/ | Public site (Symfony/Twig) |
| https://127.0.0.1:8000/adminui/ | Platform v5 Admin UI (React) |
| https://127.0.0.1:8000/api/ezp/v2/ | REST API v2 |
| https://127.0.0.1:8000/graphql | GraphQL endpoint |

---

## 4. Environment Configuration (.env.local)

Never commit `.env.local`. It overrides `.env` with host-specific secrets.

```bash
cp .env .env.local
$EDITOR .env.local
```

### Minimum required variables

```bash
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

```bash
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

SQLite requires no database server. The `.db` file is created on disk automatically when you run the install command. It is the fastest way to get a local development environment running without installing MySQL or PostgreSQL.

```bash
# Replace (or override) the DATABASE_URL line in .env.local:
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_%kernel.environment%.db"

# Symfony's async messenger must use the synchronous transport with SQLite
# (the default doctrine transport requires a second DB connection that may not
#  be available on SQLite; sync:// avoids this entirely):
MESSENGER_TRANSPORT_DSN=sync://
```

**Notes:**

- The DB file path above evaluates to e.g. `var/data_dev.db` or `var/data_prod.db`.
- Do not set `DATABASE_DRIVER`, `DATABASE_HOST`, `DATABASE_PORT`, etc. when using the `DATABASE_URL` DSN form — they are only used when the URL is constructed from parts.
- The `pdo_sqlite` and `sqlite3` PHP extensions must be enabled. Verify: `php -m | grep -i sqlite`
- After install, make the DB file writable by the web server:
  ```bash
  chmod 664 var/data_dev.db
  chown $USER:www-data var/data_dev.db   # adjust group to your web server user
  ```
- Not recommended for production — SQLite does not support concurrent writes under load. Use MySQL/MariaDB or PostgreSQL for any multi-user or public-facing deployment.

See Section 5c for the full SQLite install walkthrough.

### Search engine

```bash
SEARCH_ENGINE=legacy       # default — uses the content search engine
# SEARCH_ENGINE=solr       # use Solr (see Section 18)
```

### HTTP cache

```bash
HTTPCACHE_PURGE_TYPE=local         # or "varnish" when using Varnish
HTTPCACHE_DEFAULT_TTL=86400
HTTPCACHE_PURGE_SERVER=http://localhost:80
# HTTPCACHE_VARNISH_INVALIDATE_TOKEN=<your-secret>
# TRUSTED_PROXIES=127.0.0.1
```

### Application cache backend

```bash
CACHE_POOL=cache.tagaware.filesystem   # default (filesystem)
# CACHE_POOL=cache.redis               # use Redis
# CACHE_DSN=redis://localhost:6379
```

### Mail

```bash
MAILER_DSN=null://null         # dev (suppress delivery)
# MAILER_DSN=smtp://localhost:25
```

### Other

```bash
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

-- PostgreSQL
psql -U postgres -c "CREATE DATABASE exponential ENCODING 'UTF8';"
```

### Import schema and demo data

```bash
php bin/console exponential:install exponential-oss
# Deprecated aliases (still work):
# php bin/console ibexa:install exponential-oss
# php bin/console ibexa:install exponential-oss
```

The demo data creates an administrator user:

- **Username:** `admin`
- **Password:** `publish`

Change the admin password immediately after installation via the Platform v5 Admin UI. This credential is publicly documented.

> 💾 **Git Save Point — Database provisioned**
> ```bash
> git commit --allow-empty -m "chore(install): database created and demo data imported"
> ```

### Run Doctrine migrations (on updates)

```bash
php bin/console doctrine:migration:migrate --allow-no-migration
```

### 5c. SQLite (zero-config database)

SQLite is the fastest way to spin up a local development or demo environment — no database server software required at all.

#### Step 1 — Verify PHP extensions

```bash
php -m | grep -i sqlite
# Expected output should include both:
#   SQLite3
#   pdo_sqlite
```

If either is missing, enable them in `php.ini` (e.g. `extension=pdo_sqlite` / `extension=sqlite3`) and restart your web server / PHP-FPM.

#### Step 2 — Configure `.env.local`

Replace (or add) the `DATABASE_URL` line and add the messenger transport:

```bash
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_%kernel.environment%.db"
MESSENGER_TRANSPORT_DSN=sync://
```

Remove or comment out any `DATABASE_DRIVER`, `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DATABASE_USER`, `DATABASE_PASSWORD` lines — they are not used when a full DSN is provided.

#### Step 3 — Run the install command

```bash
php bin/console exponential:install exponential-oss
```

This single command:

1. Creates the SQLite `.db` file at `var/data_<environment>.db` (e.g. `var/data_dev.db`)
2. Imports the seed content (content classes, content objects, users, roles)
3. Creates the Doctrine ORM tables

The default administrator credentials are:

- **Username:** `admin`
- **Password:** `publish`

Change the admin password immediately after installation.

#### Step 4 — Fix file permissions

The install command typically runs as your shell user. The web server needs write access to the `.db` file (SQLite writes to the file on every content edit):

```bash
chmod 664 var/data_dev.db
chown $USER:www-data var/data_dev.db   # replace www-data with your web server group
```

If you cannot use `chown` (e.g. shared hosting), `chmod 666` will also work but is less restrictive.

#### Step 5 — Clear caches

```bash
php bin/console cache:clear
```

#### SQLite limitations

| Limitation | Impact |
|---|---|
| No concurrent write transactions | Under heavy or concurrent load, writes queue up and can timeout. Use MySQL/MariaDB for production. |
| No replication or clustering | Cannot be used in multi-server (cluster) deployments |
| No FULLTEXT index | Full-text search falls back to LIKE queries |
| File-level locking | File must be on a local filesystem — NFS/CIFS mounts not supported |
| Single file, single host | DB file is local to the server that runs PHP |

> **TL;DR:** SQLite is ideal for local development, automated testing, demos, and air-gapped / offline environments. Use MySQL 8.0+, MariaDB 10.6+, or PostgreSQL 14+ for any public-facing or multi-user production deployment.

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

        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} -f [OR]
        RewriteCond %{REQUEST_FILENAME} -d
        RewriteRule ^ - [L]
        RewriteRule ^ /index.php [L]
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/exponential_error.log
    CustomLog ${APACHE_LOG_DIR}/exponential_access.log combined
</VirtualHost>
```

For HTTPS (recommended for production), add an SSL vhost or use [Certbot](https://certbot.eff.org/):

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

| OS | Install |
|---|---|
| Debian / Ubuntu / Mint | `curl -sS https://get.symfony.com/cli/installer \| bash` |
| RHEL / AlmaLinux / Rocky / Fedora | Universal installer above |
| Arch / Manjaro | `yay -S symfony-cli` — or the universal installer |
| macOS (Homebrew) | `brew install symfony-cli/tap/symfony-cli` |
| Generic binary | github.com/symfony-cli/symfony-cli/releases — pre-built binaries for Linux (amd64/arm64), macOS, Windows |

```bash
symfony server:start               # HTTPS dev server on https://127.0.0.1:8000
symfony server:start -d            # run in background
symfony server:stop                # stop background server
symfony server:log                 # tail server log
```

---

## 7. File & Directory Permissions

Replace `www-data` with your actual web server user (e.g. `apache`, `nginx`, `_www` on macOS).

```bash
# Symfony runtime directories
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var/
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var/

# Platform v5 public var directory (generated content, thumbnails)
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX public/var/
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX public/var/
```

If [setfacl](https://savannah.nongnu.org/projects/acl/) is unavailable, install the `acl` package first:

| OS | Install |
|---|---|
| Debian / Ubuntu / Mint / Pop!_OS | `apt install acl` |
| RHEL / CentOS / AlmaLinux / Rocky | `dnf install acl` |
| Fedora | `dnf install acl` |
| openSUSE / SUSE SLES | `zypper install acl` |
| Arch / Manjaro | `pacman -S acl` |
| FreeBSD | built in — mount filesystem with `-o acls` |
| macOS | ACLs are enabled by default; use `chmod +a` syntax instead |

If ACLs are not available on your filesystem (NFS, some BSD mounts, macOS APFS):

```bash
chown -R www-data:www-data var/ public/var/
chmod -R 775 var/ public/var/
```

> **Note for development:** If your CLI user and web server user differ, the ACL approach lets both write simultaneously. This avoids `Permission denied` errors when alternating between `php bin/console` (CLI) and web requests (`www-data`).

---

## 8. Frontend Assets (Site CSS/JS)

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

## 9. Admin UI Assets (Platform v5 Admin UI)

The Platform v5 Admin UI assets (React components, SCSS, icons) are built separately from the site frontend. They are not rebuilt automatically on `composer install` (no Node.js required on production servers) — deploy pre-built assets or build on demand.

### Prerequisites

The `var/encore/` directory must be populated by `assets:install` before any `ibexa:*` build can run. This happens automatically during `composer install`, but can be run manually:

```bash
php bin/console assets:install --symlink --relative public
```

This publishes bundle `public/` directories to `public/bundles/` and writes the `var/encore/ibexa.config.js`, `var/encore/ibexa.config.setup.js`, and `var/encore/ibexa.config.manager.js` loader files that tell webpack where each bundle's entry points are.

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

All `ibexa:*` scripts route through the project's `webpack.config.js` via `--config-name ibexa`. This ensures the `@ibexa-admin-ui` webpack alias points to `vendor/se7enxweb/admin-ui` (the correct fork) and all webpack configurations are applied for vendor SCSS compatibility.

### Dump JS translation assets (required for Admin UI i18n)

```bash
php bin/console bazinga:js-translation:dump public/assets --merge-domains
```

### What changes require an Admin UI asset rebuild

| Change | Rebuild needed |
|---|---|
| `composer update` pulled a new `se7enxweb/admin-ui` version | Yes — `yarn ibexa:build` |
| Any bundle's `Resources/public/` JS or SCSS | Yes — `yarn ibexa:build` |
| `webpack.config.js` or `ibexa.webpack.config.manager.js` | Yes — `yarn ibexa:build` |
| Admin richtext editor configuration | Yes — `yarn ibexa:build` |
| Translation strings changed | Yes — dump translations |

---

## 10. JWT Authentication (REST API)

JWT keypairs are required for the REST API to function. They are not included in the repository (they are git-ignored). Generate them on every fresh install:

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

Back up `config/jwt/private.pem` and `config/jwt/public.pem` securely. If they are lost, all existing tokens are invalidated and clients must re-authenticate.

---

## 11. GraphQL Schema

The GraphQL schema is auto-generated from the content type model. Regenerate it after any content type or field type changes:

```bash
php bin/console ibexa:graphql:generate-schema
```

Then clear the Symfony cache:

```bash
php bin/console cache:clear
```

The GraphQL endpoint is available at `/graphql` (or the URL configured in `config/packages/graphql.yaml`). The GraphiQL browser UI is available at `/graphql/explorer` when `APP_ENV=dev`.

---

## 12. Search Index

### Full reindex (rebuild from scratch)

Required after fresh install, after importing content, or after switching search engines:

```bash
php bin/console exponential:reindex
```

### Incremental reindex

```bash
php bin/console exponential:reindex --iteration-count=100
```

### Reindex a specific content type

```bash
php bin/console exponential:reindex --content-type=article
```

For Solr — force commit after indexing:

```bash
curl http://localhost:8983/solr/collection1/update?commit=true
```

---

## 13. Image Variations

Image variations are generated on demand by Liip Imagine when a content view requests a variation alias. Configuration lives in `config/packages/ibexa.yaml` under `ibexa.system.<siteaccess>.image_variations`.

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

## 14. Cache Management

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

### Nuclear option (development)

```bash
rm -rf var/cache/dev var/cache/prod
php bin/console cache:warmup --env=prod
```

---

## 15. Day-to-Day Operations: Start / Stop / Restart

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

# 4. Publish bundle public assets
php bin/console assets:install --symlink --relative public --env=prod

# 5. Rebuild Platform v5 Admin UI assets (if admin-ui bundle updated)
source ~/.nvm/nvm.sh && nvm use 20 && yarn ibexa:build

# 6. Rebuild frontend site assets (if theme/JS/CSS changed)
yarn build

# 7. Dump JS translations
php bin/console bazinga:js-translation:dump public/assets --merge-domains --env=prod

# 8. Clear & warm up caches
php bin/console cache:clear --env=prod
php bin/console cache:warmup --env=prod

# 9. Reindex search (if content model changed)
# php bin/console exponential:reindex --env=prod
```

> 💾 **Git Save Point — After each production deploy**
> ```bash
> git tag -a "deploy-$(date +%Y%m%d-%H%M)" -m "production deploy $(date)"
> git push origin --tags
> ```

---

## 16. Updating the Codebase

### Pull latest code and rebuild

```bash
git pull --rebase
composer install
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console cache:clear
```

### Update Composer packages

```bash
# Update all packages within constraints
composer update

# Update a single package
composer update se7enxweb/exponential-platform-dxp-core

# After update, always run:
php bin/console doctrine:migration:migrate --allow-no-migration
php bin/console cache:clear
php bin/console exponential:reindex   # if content model schema may have changed
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

---

## 17. Cron Jobs

Add to crontab (`crontab -e -u www-data`):

```bash
# Platform v5 cron runner (every 5 minutes)
*/5 * * * * /usr/bin/php /var/www/exponential/bin/console ibexa:cron:run --env=prod >> /var/log/exponential-cron.log 2>&1
```

---

## 18. Solr Search Engine (optional)

### Switch from legacy to Solr

1. Set `SEARCH_ENGINE=solr` and `SOLR_DSN`/`SOLR_CORE` in `.env.local`
2. Clear cache: `php bin/console cache:clear`
3. Provision the Solr core — use the Solr Admin HTTP API directly (no console command exists in v5):
   ```bash
   curl "http://localhost:8983/solr/admin/cores?action=CREATE&name=default&configSet=exponential"
   ```
4. Reindex all content:
   ```bash
   php bin/console exponential:reindex
   ```

### Switch back to legacy search

```bash
SEARCH_ENGINE=legacy
php bin/console cache:clear
```

---

## 19. Varnish HTTP Cache (optional)

1. Set env vars in `.env.local`:
   ```bash
   HTTPCACHE_PURGE_TYPE=varnish
   HTTPCACHE_PURGE_SERVER=http://127.0.0.1:6081
   HTTPCACHE_VARNISH_INVALIDATE_TOKEN=<your-secret>
   TRUSTED_PROXIES=127.0.0.1
   ```
2. Set `APP_HTTP_CACHE=0` in your web server vhost (let Varnish handle caching).
3. Load the Platform v5 Varnish VCL from `doc/varnish/` (if present) or refer to the upstream Ibexa DXP Varnish documentation.
4. Clear cache after any VCL change:
   ```bash
   php bin/console cache:clear
   php bin/console fos:httpcache:invalidate:path / --all
   ```

---

## 20. Troubleshooting

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
# Clear Symfony cache
php bin/console cache:clear

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
php bin/console exponential:reindex
```

### Permission denied on var/ or public/var/

```bash
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var/ public/var/
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var/ public/var/
```

### JWT authentication errors (REST API)

```bash
php bin/console lexik:jwt:generate-keypair --overwrite
php bin/console cache:clear
```

### `no such table: ibexa_section` (SQLite only)

The SQLite database was not initialized. Run the installer:

```bash
php bin/console exponential:install exponential-oss
```

If the DB file was created but is empty, delete it and re-run:

```bash
rm var/data_dev.db
php bin/console exponential:install exponential-oss
```

### `attempt to write a readonly database` (SQLite only)

The web server user cannot write the `.db` file (common when the install was run as `root` but the web server runs as `www-data`):

```bash
chmod 664 var/data_dev.db
chown $USER:www-data var/data_dev.db
```

---

## 21. Database Conversion

This section covers converting an existing, running Exponential Platform DXP application from one database engine to another using free and open-source tools only.

All tools listed below are either:
- distributed under OSI-approved open-source licences (MIT, GPL, BSD, Apache 2.0), or
- free CLI utilities included with the database server packages.

> **Before you start — backup everything.**
> ```bash
> # Backup the current DB (adjust for your engine — examples below)
> # Also backup var/ and your .env.local
> cp .env.local .env.local.bak
> ```

### Tool inventory

All tools are free and open-source. Download links and cross-platform install commands are provided for every tool.

#### `mysqldump` / `mysql` CLI

Bundled with every MySQL and MariaDB server package. Download: [dev.mysql.com/downloads/mysql](https://dev.mysql.com/downloads/mysql/)

| OS | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install default-mysql-client` |
| RHEL / AlmaLinux / Rocky | `dnf install mysql` |
| Fedora | `dnf install community-mysql` |
| Arch / Manjaro | `pacman -S mysql-clients` |
| FreeBSD | `pkg install mysql80-client` |
| macOS (Homebrew) | `brew install mysql-client` |

#### `pg_dump` / `psql`

Bundled with PostgreSQL server packages. Download: [postgresql.org/download](https://www.postgresql.org/download/)

| OS | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install postgresql-client` |
| RHEL / AlmaLinux / Rocky | `dnf install postgresql` |
| Arch / Manjaro | `pacman -S postgresql-libs` |
| FreeBSD | `pkg install postgresql16-client` |
| macOS (Homebrew) | `brew install libpq` |

#### `sqlite3` CLI

| OS | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install sqlite3` |
| RHEL / AlmaLinux / Rocky | `dnf install sqlite` |
| Arch / Manjaro | `pacman -S sqlite` |
| FreeBSD | `pkg install sqlite3` |
| macOS | pre-installed on all versions |

#### pgloader

Docs: [pgloader.io](https://pgloader.io/) · Source: [github.com/dimitri/pgloader](https://github.com/dimitri/pgloader) · Licence: PostgreSQL (BSD-like)

| OS | Install |
|---|---|
| Debian / Ubuntu / Mint | `apt install pgloader` |
| Fedora | `dnf install pgloader` |
| Arch / Manjaro | `yay -S pgloader` |
| FreeBSD | `pkg install pgloader` |
| macOS (Homebrew) | `brew install pgloader` |
| Docker (any OS) | `docker run --rm -it dimitri/pgloader:latest pgloader <args>` |

#### mysql2sqlite

Download: [github.com/dumblob/mysql2sqlite](https://github.com/dumblob/mysql2sqlite) · Licence: MIT · single shell script, no compiled dependencies.

```bash
# Works on any UNIX / macOS / BSD with bash + sqlite3
curl -LO https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite
chmod +x mysql2sqlite
```

#### sqlite3-to-mysql

Download: [github.com/techouse/sqlite3-to-mysql](https://github.com/techouse/sqlite3-to-mysql) · Licence: MIT · Python package, requires Python 3.8+.

```bash
pip install sqlite3-to-mysql
```

---

### 21a. Any → SQLite (go to SQLite)

#### From MySQL / MariaDB → SQLite

Use the [mysql2sqlite](https://github.com/dumblob/mysql2sqlite) shell script:

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

#### From PostgreSQL → SQLite

Use [pgloader](https://pgloader.io/):

```bash
# Create an empty target file
touch var/data_dev.db

# pgloader command file
cat > /tmp/pg_to_sqlite.load <<EOF
LOAD DATABASE
  FROM postgresql://db_user:db_pass@127.0.0.1/db_name
  INTO sqlite:///$(pwd)/var/data_dev.db

WITH include no drop, create tables, create indexes, reset sequences

SET work_mem TO '128MB', maintenance_work_mem TO '512MB';
EOF

pgloader /tmp/pg_to_sqlite.load
```

#### After migrating to SQLite — update .env.local

```bash
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_dev.db"
MESSENGER_TRANSPORT_DSN=sync://
```

Fix permissions and clear caches (see Section 5c steps 4–5).

---

### 21b. SQLite → MySQL / MariaDB

Create the target database first (see Section 5 — Database Setup).

#### Method 1 — sqlite3-to-mysql (Python, MIT)

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

#### After migrating — update .env.local

```bash
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

### 21c. SQLite → PostgreSQL

Use [pgloader](https://pgloader.io/):

```bash
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

#### After migrating — update .env.local

```bash
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

### 21d. MySQL / MariaDB → PostgreSQL

Use [pgloader](https://pgloader.io/) — this is its primary, most mature use-case:

```bash
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

CAST
  column type matching ~/enum/ to text,
  type tinyint to boolean using tinyint-to-boolean,
  type longtext to text, type mediumtext to text,
  type int with unsigned to bigint;
EOF

pgloader /tmp/mysql_to_pg.load
```

#### After migrating — update .env.local

```bash
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

### 21e. PostgreSQL → MySQL / MariaDB

#### Step 1 — Export each table as CSV from PostgreSQL

```bash
TARGET_DIR=/tmp/pg_csv_export
mkdir -p "$TARGET_DIR"

TABLES=$(psql -U pg_user -d exponential -t \
  -c "SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename;")

for TABLE in $TABLES; do
  TABLE=$(echo "$TABLE" | xargs)
  psql -U pg_user -d exponential \
    -c "\COPY \"$TABLE\" TO '$TARGET_DIR/$TABLE.csv' WITH (FORMAT csv, HEADER true, NULL '\\N');"
done
```

#### Step 2 — Create MySQL schema with pgloader (schema only)

```bash
cat > /tmp/schema_only.load <<'EOF'
LOAD DATABASE
  FROM      postgresql://pg_user:pg_pass@127.0.0.1/exponential
  INTO      mysql://db_user:db_pass@127.0.0.1/target_db

WITH include no drop, create tables, no data;
EOF
pgloader /tmp/schema_only.load
```

#### Step 3 — Import CSVs into MySQL

```bash
for CSV in "$TARGET_DIR"/*.csv; do
  TABLE=$(basename "$CSV" .csv)
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

#### After migrating — update .env.local

```bash
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

### 21f. Any → Oracle (export only)

Oracle XE (Express Edition) is free to use but not open-source. The recommended free/open-source path for Oracle targets is to use [ora2pg](https://github.com/darold/ora2pg) (GPL v3) for Oracle → PostgreSQL and then migrate from PostgreSQL to the desired target. Full Oracle migration is outside the scope of this guide.

---

### 21g. Post-conversion checklist

After any database engine switch, run through every item:

```bash
# 1. Update .env.local with the new DATABASE_URL or database vars
$EDITOR .env.local

# 2. Clear the Symfony container and cache (it caches the DBAL connection)
php bin/console cache:clear

# 3. Validate Doctrine entity mappings against the new DB
php bin/console doctrine:schema:validate

# 4. Run any pending Doctrine migrations
php bin/console doctrine:migration:migrate --allow-no-migration

# 5. Regenerate the search index against the new DB
php bin/console exponential:reindex

# 6. Smoke-test the site
curl -I http://localhost/
curl -I http://localhost/adminui/

# 7. If using SQLite as target — fix file permissions
# (skip for MySQL/PostgreSQL)
chmod 664 var/data_dev.db
chown "$USER":www-data var/data_dev.db
```

#### Common post-conversion issues

| Symptom | Cause | Fix |
|---|---|---|
| `SQLSTATE[42S02]: Base table not found` | Table not migrated | Run `doctrine:schema:validate` and check pgloader/mysql2sqlite log for errors |
| Binary/blob content garbled | Charset mismatch during export | Re-export with explicit `--default-character-set=utf8mb4` (mysqldump) or `CLIENT_ENCODING=UTF8` (psql) |
| Serialization failure (PostgreSQL) | Concurrent access during import | Import with `APP_ENV=dev` and no web traffic; use a maintenance window |
| Image variation 404s | `ezcontentobject_attribute` row count mismatch | Verify row counts between source and target; re-run data transfer for that table |
| `SQLite attempt to write a readonly database` | Web server user cannot write the .db file | `chmod 664 var/data_*.db && chown $USER:www-data var/data_*.db` |

> 💾 **Git Save Point — database conversion complete**
> ```bash
> git add .env.local.bak   # keep the backup of the old config as a reference
> git commit -m "chore(db): convert database from <source> to <target>"
> ```

---

## 22. Complete CLI Reference

A comprehensive reference of every CLI command used in day-to-day development, maintenance, and operations. For help on any command run `php bin/console help <command>`.

### 22.1 Symfony Core

```bash
# ── Discovery ──────────────────────────────────────────────────────────────
php bin/console list                             # list all registered commands
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

### 22.2 Doctrine / Migrations

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

### 22.3 Platform v5 — `exponential:` Commands

All commands below are canonical `exponential:*` names introduced in Platform v5. For migrated commands, `ibexa:*` remains a deprecated alias. The `ezplatform:*` prefix does **not** exist in v5. Use `exponential:*` for all new scripts and documentation.

---

#### `exponential:install` — Initial database install

Installs the Platform v5 schema and seed/demo data into an empty database. **Run once** on a fresh install; it will confirm before overwriting an existing schema.

```bash
php bin/console exponential:install exponential-oss   # recommended — Exponential OSS seed data
php bin/console exponential:install ibexa-oss         # upstream Ibexa OSS seed data (alternate)
php bin/console exponential:install exponential-oss --skip-indexing   # skip post-install reindex
php bin/console exponential:install exponential-oss --siteaccess=site # use specific siteaccess
```

| Option | Default | Description |
|---|---|---|
| `type` (arg) | `exponential-oss` | Install type: `exponential-oss` or `ibexa-oss` |
| `--skip-indexing` | off | Skip the automatic `exponential:reindex` run after install |
| `--siteaccess` | default | SiteAccess to use for seed-data operations |

> **When to use:** Initial setup only. After install, use migrations for all schema changes.
> **Deprecated alias:** `ibexa:install`

---

#### `exponential:reindex` — Rebuild search index

Rebuilds or refreshes the search engine index (Solr or Legacy search). Run after bulk content imports, schema changes, or when search results feel stale.

```bash
php bin/console exponential:reindex                             # full reindex of all content
php bin/console exponential:reindex --iteration-count=100      # process 100 content items per batch
php bin/console exponential:reindex --content-ids=2,34,68      # reindex specific content IDs
php bin/console exponential:reindex --content-type=article     # reindex one content type only
php bin/console exponential:reindex --subtree=45               # reindex a Location subtree
php bin/console exponential:reindex --since=yesterday          # reindex content modified since date
php bin/console exponential:reindex --no-purge                 # skip purge before reindex
php bin/console exponential:reindex --no-commit                # skip commit after reindex
php bin/console exponential:reindex --processes=4              # parallelise across N processes
php bin/console exponential:reindex --siteaccess=site          # use a specific siteaccess context
# Run without memory limit in production:
php -d memory_limit=-1 bin/console exponential:reindex --env=prod
```

> **When to use:** After `exponential:install`, after bulk content operations, after content type schema changes, after deploying to production, or during cron maintenance.
> **Deprecated alias:** `ibexa:reindex`

---

#### `exponential:check-urls` — Audit external URL links

Iterates over all content fields containing external URLs and checks whether each URL responds. Reports broken or unreachable links.

```bash
php bin/console exponential:check-urls                          # check all URLs (batches of 50)
php bin/console exponential:check-urls --iteration-count=100   # process 100 URLs per batch
php bin/console exponential:check-urls --user=editor           # run as a different platform user
```

| Option | Default | Description |
|---|---|---|
| `-c, --iteration-count` | `50` | URLs checked per memory-safe batch |
| `-u, --user` | `admin` | Platform username — needs `content: read, versionread` Role Policy |

> **When to use:** Periodic maintenance (e.g. weekly cron) to surface broken outbound links before users encounter them.
> **Deprecated alias:** `ibexa:check-urls`

---

#### `exponential:content:cleanup-versions` — Prune old content versions

Removes archived and/or draft versions of content items, keeping only the published version and a configurable number of recent historic versions. Frees database space on high-edit sites.

```bash
php bin/console exponential:content:cleanup-versions              # remove all archived+draft (keep config default)
php bin/console exponential:content:cleanup-versions --keep=3     # keep 3 most recent non-published versions
php bin/console exponential:content:cleanup-versions --status=archived   # only archived, not drafts
php bin/console exponential:content:cleanup-versions --status=draft      # only drafts
php bin/console exponential:content:cleanup-versions --keep=1 --excluded-content-types=user,form
```

| Option | Default | Description |
|---|---|---|
| `-t, --status` | `all` | Which versions to remove: `draft`, `archived`, `all` |
| `-k, --keep` | config default | How many recent versions (per content item) to keep |
| `-u, --user` | `admin` | Platform username — needs `content: remove, read, versionread` |
| `--excluded-content-types` | `user` | Comma-separated identifiers to skip |

> **When to use:** Scheduled maintenance cron (e.g. nightly) on sites with heavy editorial activity. Always test with `--keep=5` before using `--keep=1`.
> **Deprecated alias:** `ibexa:content:cleanup-versions`

---

#### `exponential:copy-subtree` — Copy a Location subtree

Copies an entire subtree of the content tree from one Location to another. Useful for duplicating site sections or seeding test fixtures.

```bash
php bin/console exponential:copy-subtree 42 2          # copy Location 42 under Location 2
php bin/console exponential:copy-subtree 42 2 --user=admin
```

| Argument | Description |
|---|---|
| `source-location-id` | Location ID of the subtree root to copy |
| `target-location-id` | Location ID of the destination parent |
| `-u, --user` | Platform username — needs `content: create, read` |

> **When to use:** One-off content structure duplication (staging → production seeding, site section copy). Not for bulk migrations — use Data Migration Bundle for that.
> **Deprecated alias:** `ibexa:copy-subtree`

---

#### `exponential:debug:config-resolver` — Inspect SiteAccess config values

Reads and prints resolved configuration values through the SiteAccess config resolver. Essential for debugging why a setting differs between siteaccesses.

```bash
php bin/console exponential:debug:config-resolver languages                       # resolved language list for default SA
php bin/console exponential:debug:config-resolver languages --siteaccess=fr       # for the 'fr' siteaccess
php bin/console exponential:debug:config-resolver http_cache.purge_servers        # cache purge server list
php bin/console exponential:debug:config-resolver languages --json                # machine-readable output
php bin/console exponential:debug:config-resolver languages --scope=fr            # alternative scope syntax
php bin/console exponential:debug:config-resolver design --namespace=ibexa.site_access.config
```

| Option | Description |
|---|---|
| `parameter` (arg) | Config resolver parameter name, e.g. `languages`, `http_cache.purge_servers` |
| `--json` | Output value only, single line JSON (for scripting/CI) |
| `--scope` | Alternative to `--siteaccess` for specifying scope |
| `--namespace` | Override namespace (default: `ibexa.site_access.config`) |
| `--siteaccess` | SiteAccess to resolve against |

> **Alias:** `exponential:debug:config`
> **When to use:** Anytime a per-siteaccess config value is behaving unexpectedly. Faster than reading resolved config YAML by hand.
> **Deprecated alias:** `ibexa:debug:config-resolver`

---

#### `exponential:delete-content-translation` — Delete a translation from a content item

Permanently removes a specific language translation from **all versions** of a content item. Cannot be undone.

```bash
php bin/console exponential:delete-content-translation 123 fre-FR   # delete French from content ID 123
php bin/console exponential:delete-content-translation 456 ger-DE --user=admin
```

| Argument | Description |
|---|---|
| `content-id` | Database ID of the Content object |
| `language-code` | Language code to remove, e.g. `fre-FR`, `ger-DE`, `pol-PL` |
| `-u, --user` | Needs `content: read, versionread, edit, remove, versionremove` |

> **When to use:** After discontinuing a language on a site and needing to clean up orphaned translations. Take a DB backup first.
> **Deprecated alias:** `ibexa:delete-content-translation`

---

#### `exponential:user:expire-password` — Force password expiry

Marks user passwords as expired so they are prompted to change at next login. Used to enforce a password rotation policy.

```bash
php bin/console exponential:user:expire-password --force                    # expire all users (dry-run without --force)
php bin/console exponential:user:expire-password --user-id=12 --force       # expire one specific user
php bin/console exponential:user:expire-password --user-id=12 --user-id=34 --force
php bin/console exponential:user:expire-password --iteration-count=200 --force   # process 200 per batch
php bin/console exponential:user:expire-password --password-ttl=60 --force       # set 60-day TTL on content type
```

| Option | Default | Description |
|---|---|---|
| `-u, --user-id` | all users | Specific User ID(s) to expire (repeatable) |
| `-f, --force` | off | Required to actually apply; without it, runs as dry-run |
| `-c, --iteration-count` | `50` | Users processed per batch |
| `-t, --password-ttl` | `90` | Days until password expires (also updates the content type) |

> **When to use:** After a security incident requiring forced password rotation, or when introducing a password TTL policy for the first time.
> **Deprecated alias:** `ibexa:user:expire-password`

---

#### `exponential:user:validate-password-hashes` — Audit password hash algorithms

Checks all user records and reports whether their stored password hashes use the currently configured (and therefore still secure) hashing algorithm. Flags any using deprecated algorithms.

```bash
php bin/console exponential:user:validate-password-hashes
php bin/console exponential:user:validate-password-hashes -v    # verbose — list every user checked
```

> **When to use:** After upgrading Platform or changing the `password_hash_type` config. Run before forcing a password expiry so you know the scope of accounts using outdated hash algorithms.
> **Deprecated alias:** `ibexa:user:validate-password-hashes`

---

#### `exponential:images:normalize-paths` — Fix image field storage paths

Corrects stored image file paths in the database to match the canonical hash-based path scheme. Required when migrating image storage or after importing content from older Platform versions that used flat paths.

```bash
php bin/console exponential:images:normalize-paths              # normalize all paths (with hashing)
php bin/console exponential:images:normalize-paths --no-hash    # normalize without renaming filenames to hashes
```

| Option | Description |
|---|---|
| `--no-hash` | Skip filename hashing — only fix directory structure |

> **When to use:** After a file storage migration (e.g. local → S3/DFS) or when image URLs in content are returning 404 due to path inconsistencies.
> **Deprecated alias:** `ibexa:images:normalize-paths`

---

#### `exponential:images:resize-original` — Batch-resize stored original images

Applies a named Liip Imagine filter to the **original** stored image files for a given content type / image field combination. Useful when a new image size policy requires retroactively processing previously uploaded originals.

```bash
# Resize all 'image' fields on 'banner' content type using the 'large' imagine filter:
php bin/console exponential:images:resize-original image banner --filter=large

# Process 10 images per batch (low memory environments):
php bin/console exponential:images:resize-original image banner --filter=large --iteration-count=10
```

| Argument / Option | Default | Description |
|---|---|---|
| `imageFieldIdentifier` (arg) | — | Field identifier of type `ibexa_image` |
| `contentTypeIdentifier` (arg) | — | Content type identifier |
| `-f, --filter` | required | Liip Imagine filter alias to apply |
| `-i, --iteration-count` | `25` | Images processed per memory-safe batch |
| `-u, --user` | `admin` | Needs `content: read, versionread, edit, publish` |

> **When to use:** When retroactively applying a new image policy (crop, max-width) to existing uploaded content. Run during off-peak hours — it is CPU/IO intensive.
> **Deprecated alias:** `ibexa:images:resize-original`

---

#### `exponential:urls:regenerate-aliases` — Rebuild URL aliases

Regenerates all autogenerated Location URL aliases from the current content URL pattern configuration. Also cleans up stale custom Location and global aliases from Legacy Storage.

```bash
php bin/console exponential:urls:regenerate-aliases                          # regenerate all (interactive confirm)
php bin/console exponential:urls:regenerate-aliases --force --no-interaction # non-interactive (cron/deploy safe)
php bin/console exponential:urls:regenerate-aliases --iteration-count=500    # 500 Locations per batch
php bin/console exponential:urls:regenerate-aliases --location-id=42         # one subtree root only
php bin/console exponential:urls:regenerate-aliases --location-id=42 --location-id=100
```

| Option | Default | Description |
|---|---|---|
| `-c, --iteration-count` | `1000` | Locations fetched and processed per batch |
| `--location-id` | all | Only regenerate aliases for specific Location IDs (repeatable) |
| `-f, --force` | off | Skip interactive confirmation (required with `--no-interaction`) |

> **When to use:** After changing URL name patterns in content type configuration, after a multilingual site migration, or when URL aliases are missing or duplicated.
> **Deprecated alias:** `ibexa:urls:regenerate-aliases`

---

#### `exponential:content-type-group:set-system` — Mark a content type group as system

Flags a Content Type Group as a system group (or unflags it). System groups are hidden from editors in the Admin UI, keeping the editorial interface clean.

```bash
php bin/console exponential:content-type-group:set-system Media --system       # mark as system group
php bin/console exponential:content-type-group:set-system Media --no-system    # unmark as system group
```

| Argument / Option | Description |
|---|---|
| `content-type-group-identifier` (arg) | Identifier of the Content Type Group |
| `--system` / `--no-system` | Set or unset the system flag |
| `-u, --user` | Platform username — needs `content: remove, read, versionread` |

> **When to use:** When adding a new internal content type group (e.g. `ConfigObjects`, `SystemPages`) that editors should not see or be able to modify in the Admin UI.
> **Deprecated alias:** `ibexa:content-type-group:set-system`

---

#### `exponential:timestamps:to-utc` — Convert date/datetime field values to UTC

Converts stored `ibexa_date` and `ibexa_datetime` field values from a source timezone to UTC. **One-time data migration** command for sites that were originally installed without UTC-enforced storage.

```bash
# Dry run first — always:
php bin/console exponential:timestamps:to-utc Europe/London --dry-run

# Convert all date and datetime fields from Europe/London to UTC:
php bin/console exponential:timestamps:to-utc Europe/London

# Convert only datetime fields in batches of 200, records from 2020 onwards:
php bin/console exponential:timestamps:to-utc Europe/London --mode=datetime --iteration-count=200 --from=2020-01-01
```

| Argument / Option | Default | Description |
|---|---|---|
| `timezone` (arg) | required | Source timezone, e.g. `Europe/London`, `America/New_York` |
| `--dry-run` | off | Preview only — no DB changes |
| `--mode` | `all` | Scope: `date`, `datetime`, or `all` |
| `--from` | — | Only process versions after this date |
| `--to` | — | Only process versions before this date |
| `--offset` | `0` | Record offset (resumes an interrupted run) |
| `--iteration-count` | `100` | Records updated per iteration |

> **When to use:** Only on legacy data migrations where the original install was timezone-unaware. Always take a full DB backup and run `--dry-run` first.
> **Deprecated alias:** `ibexa:timestamps:to-utc`

---

#### `exponential:content:remove-duplicate-fields` — Remove duplicate content fields

Removes duplicate field rows created by a known storage layer bug (IBX-5388). Safe to run on any installation — it only deletes verified duplicates, not legitimate data.

```bash
php bin/console exponential:content:remove-duplicate-fields                          # remove all duplicates
php bin/console exponential:content:remove-duplicate-fields --batch-size=5000        # smaller batches (less lock time)
php bin/console exponential:content:remove-duplicate-fields --max-iterations=10      # run only N batches then exit
php bin/console exponential:content:remove-duplicate-fields --batch-size=1000 --sleep=200  # sleep 200ms between batches
```

| Option | Default | Description |
|---|---|---|
| `-b, --batch-size` | `10000` | Number of field attribute rows processed per iteration |
| `-i, --max-iterations` | `-1` (unlimited) | Stop after this many iterations |
| `-s, --sleep` | `0` | Milliseconds to sleep between iterations (reduces DB pressure) |

> **When to use:** Run once after upgrading from a version affected by IBX-5388, or if admin queries are returning duplicated field values. Use `--sleep` and `--batch-size` on live production to spread load.
> **Deprecated alias:** `ibexa:content:remove-duplicate-fields`

---

#### `exponential:io:migrate-files` — Migrate binary files between IO handlers

Migrates stored binary files (images, PDFs, media) from one IO repository handler to another. Used when switching file storage backends (e.g. local filesystem → AWS S3 / DFS / NFS).

```bash
# List all configured IO handlers:
php bin/console exponential:io:migrate-files --list-io-handlers

# Dry run — check what would be moved:
php bin/console exponential:io:migrate-files --from=default_metadata,default_binarydata --to=dfs_metadata,dfs_binarydata --dry-run

# Live migration in batches of 50:
php bin/console exponential:io:migrate-files --from=default_metadata,default_binarydata --to=dfs_metadata,dfs_binarydata --bulk-count=50
```

| Option | Default | Description |
|---|---|---|
| `--from` | required | Source: `<metadata_handler>,<binarydata_handler>` |
| `--to` | required | Destination: `<metadata_handler>,<binarydata_handler>` |
| `--list-io-handlers` | — | Print all available handler identifiers and exit |
| `--bulk-count` | `100` | Files processed per batch |
| `--dry-run` | off | Preview only — no files moved |

> **When to use:** When migrating file storage infrastructure (local → S3/DFS/NFS). Always run `--dry-run` first and take a storage backup. Run `exponential:reindex` after migration to update search index references.
> **Deprecated alias:** `ibexa:io:migrate-files`

---

#### Other Platform commands (not yet migrated to `exponential:` prefix)

The following commands remain under legacy prefixes. They are fully functional — the rename has not been applied to them yet:

```bash
# ── Cron ───────────────────────────────────────────────────────────────────
php bin/console ibexa:cron:run                             # run Platform v5 cron scheduler
php bin/console ibexa:cron:run --quiet                     # suppress output (for crontab)

# ── GraphQL schema ─────────────────────────────────────────────────────────
php bin/console ibexa:graphql:generate-schema              # regenerate GraphQL schema from content model

# ── Solr (when using Solr search engine) ────────────────────────────────────
# No console command exists in v5 — provision cores via Solr Admin HTTP API:
# curl "http://localhost:8983/solr/admin/cores?action=CREATE&name=default&configSet=exponential"

# ── HTTP Cache ─────────────────────────────────────────────────────────────
php bin/console fos:httpcache:invalidate:path / --all      # purge all HTTP cache paths
php bin/console fos:httpcache:invalidate:tag <tag>         # purge by cache tag

# ── Admin UI JS Translations ───────────────────────────────────────────────
php bin/console bazinga:js-translation:dump public/assets --merge-domains

# ── Image Variation Cache ──────────────────────────────────────────────────
php bin/console liip:imagine:cache:remove                  # remove all cached variations
php bin/console liip:imagine:cache:remove --filter=small   # remove one variation filter alias

# ── Config Dump ────────────────────────────────────────────────────────────
php bin/console debug:config ibexa                         # dump full resolved platform config
```

### 22.4 Frontend / Asset Build (Yarn / Webpack Encore)

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
yarn ibexa:dev                         # build Platform v5 Admin UI — dev mode
yarn ibexa:build                       # build Platform v5 Admin UI — production
yarn ibexa:watch                       # watch Admin UI assets for changes

# ── Inspection ─────────────────────────────────────────────────────────────
yarn list                              # list installed packages and versions
```

### 22.5 Composer Maintenance

```bash
# ── Installing ─────────────────────────────────────────────────────────────
composer install                        # install from composer.lock
composer install --no-dev               # production (no dev dependencies)
composer install --no-dev -o            # production + optimised autoloader

# ── Updating ───────────────────────────────────────────────────────────────
composer update                         # update all within constraints
composer update se7enxweb/exponential-platform-dxp-core   # update one package
composer update --dry-run               # preview without applying

# ── Autoloader ─────────────────────────────────────────────────────────────
composer dump-autoload                  # regenerate autoloader
composer dump-autoload -o               # optimised (production) autoloader

# ── Info / Audit ───────────────────────────────────────────────────────────
composer show                           # list all installed packages
composer show se7enxweb/exponential-platform-dxp   # detail one package
composer outdated                       # list outdated packages
composer audit                          # check for security advisories
composer validate                       # validate composer.json / composer.lock
```

### 22.6 Symfony CLI

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

### 22.7 Git Workflow Shortcuts

```bash
# ── Branching ──────────────────────────────────────────────────────────────
git checkout -b feature/my-feature          # new feature branch off current
git checkout master                         # switch to the stable branch

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

For web server configuration templates see `doc/apache2/` and `doc/nginx/` (if present). For Docker-based development see `doc/docker/` and `compose.override.yaml` (if present).

---

Copyright © 1998 – 2026 7x (se7enx.com). All rights reserved unless otherwise noted.
Exponential Platform DXP is Open Source software released under the GNU GPL v2 or any later version.
