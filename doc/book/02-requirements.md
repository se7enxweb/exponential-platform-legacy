# 2. Requirements

This chapter lists what a server needs before Exponential Platform Legacy can be installed on it, per release line:
the PHP versions that really resolve (which are narrower than some `composer.json` files suggest), the PHP extensions
and `php.ini` settings, the databases, Composer, Node.js and Yarn for the asset build, the optional services (Redis,
Solr, Varnish) and what serving the site needs, with Exponential Velocity or a traditional web server. It ends with a
checklist you can run on a fresh machine.

[Previous: 1. Introduction](01-introduction.md) · [Next: 3. Getting the code](03-getting-the-code.md) ·
[Contents](README.md)

---

## Contents of this chapter

1. [The short version](#21-the-short-version)
2. [PHP versions per line](#22-php-versions-per-line)
3. [PHP extensions](#23-php-extensions)
4. [php.ini settings](#24-phpini-settings)
5. [Databases](#25-databases)
6. [Composer](#26-composer)
7. [Node.js and Yarn](#27-nodejs-and-yarn)
8. [Serving the site](#28-serving-the-site)
9. [Optional services](#29-optional-services)
10. [Operating systems and sizing](#210-operating-systems-and-sizing)
11. [A checklist for a fresh server](#211-a-checklist-for-a-fresh-server)
12. [References](#212-references)

---

## 2.1 The short version

| | **2.5** | **3.x** | **4.6.x** | **5.x** |
|---|---|---|---|---|
| PHP | 8.1 or later (tested 8.1 and 8.2) | 8.1 or later | 8.0 or later | 8.4 or later |
| `memory_limit` (project docs) | 256M, 512M recommended | 256M | 512M | 256M, 512M recommended |
| MySQL / MariaDB | MySQL 5.7+ / MariaDB 10.0+ | MySQL 8.0+ / MariaDB 10.3+ | MySQL 8.0+ / MariaDB 10.3+ | MySQL 8.0+ / MariaDB 10.3+ |
| PostgreSQL | 9.5+ | 14+ | 14+ | 14+ |
| SQLite | 3.35+ (development, tests) | 3.35+ | 3.35+ | 3.35+ |
| Composer | 2.x | 2.x | 2.x | 2.x |
| Node.js / Yarn (asset build only) | 14 LTS / 1.22 | 18 LTS / 1.22 | 20 LTS / 1.22 | 20 LTS / 1.22 (`v5.0.2`); 24 LTS / 1.22 (`v5.0.3.1`, branch) |
| Serving | Exponential Velocity (PHP 8.1+), or Apache 2.4 / nginx 1.18+ with PHP-FPM | the same | the same (Velocity needs PHP 8.1+) | the same |

The database versions and memory figures are those each line's README and installation guide state; the PHP floors
come from the Composer metadata (section 2.2). Databases are covered in depth in [chapter 7](07-databases.md).

## 2.2 PHP versions per line

Composer installs a project only if the running PHP satisfies the `php` constraint of **every** package. The skeleton
states the widest range; required packages narrow it.

| Line | Skeleton `composer.json` | Narrowed by | Floor in practice |
|---|---|---|---|
| 2.5 | `^7.1.3 \|\| ^8.1 \|\| ^8.2` | `se7enxweb/exponential ^6.0.12`: the releases it allows, 6.0.12 to 6.0.14, declare `^8.1 \|\| ... \|\| ^8.8` | **8.1** |
| 3.x | `^8.0` | the same kernel range, through LegacyBridge 3 (`se7enxweb/exponential ^6.0.12`) | **8.1** |
| 4.6.x | `^7.4 \|\| ^8.0 \|\| ... \|\| ^8.5` | LegacyBridge 4 (`php ^8.0`); the kernel's `dev-main` declares `^8.0 ...` | **8.0** |
| 5.x | `>=8.3` | LegacyBridge 5 (`php ^8.4`, every release from 5.0.0.0 to 5.0.10) | **8.4** |

Notes:

- `^8.1` in Composer means 8.1 up to, but not including, 9.0, so the constraint itself does not stop PHP 8.3 or 8.5 on
  the 2.5 line. The installation guide published with `v2.5.0.3` says "tested through 8.2", the README recommends 8.3.
  Treat 8.1 and 8.2 as tested and newer versions as accepted.
- The installation guide published with `v2.5.0.3` added `--ignore-platform-reqs` to every Composer command; the
  current short guide on `master` ([doc/INSTALL.md](../INSTALL.md)) no longer does. That switch skips the PHP and
  extension checks entirely, so Composer can then install packages your PHP cannot run, and the failure only shows up
  later as a fatal error in a request. Use it only after you checked the requirements yourself, never to get around a
  PHP version that is too old.
- Exponential Velocity needs PHP 8.1 or later (its `composer.json`: `php >=8.1`), so on 4.6.x with PHP 8.0 you serve
  the site with Apache or nginx ([chapter 6](06-serving-the-site.md)).
- The legacy kernel's own view of PHP versions, including what changed between 8.0 and 8.5, is in the Exponential 6
  book, [2. Requirements](https://github.com/se7enxweb/exponential/blob/main/doc/install/02-requirements.md).

Check the PHP that the command line and the web server use; they are often different binaries:

```bash
php -v                                   # the CLI that runs composer and bin/console
command -v php                           # which binary that is
php --ini                                # which php.ini files the CLI reads
php-fpm -v                               # the FPM side, if you use PHP-FPM (the name varies: php-fpm8.3, ...)
```

A typical result on a server prepared for the 4.6.x line, and how to read it:

```text
$ php -v
PHP 8.3.12 (cli) (built: Sep 24 2026 10:12:44) (NTS)       <- 8.3: fine for 2.5, 3.x and 4.6.x, too old for 5.x
$ php --ini
Loaded Configuration File:         /etc/php/8.3/cli/php.ini <- the CLI's file; FPM reads /etc/php/8.3/fpm/php.ini
```

What goes wrong when the floor is missed: Composer stops before it installs anything, with a message such as
`se7enxweb/legacy-bridge v5.0.10 requires php ^8.4 -> your php version (8.3.12) does not satisfy that requirement`.
That is the check working as intended; install a newer PHP (or choose an older line) rather than overriding it.

## 2.3 PHP extensions

The 3.x, 4.6.x and 5.x skeletons declare their extensions in `composer.json`, so Composer refuses to install without
them. The 2.5 skeleton does not; its README lists them instead.

| Extension | 2.5 | 3.x | 4.6.x | 5.x | Why |
|---|---|---|---|---|---|
| `ctype`, `iconv` | yes | `ext-ctype`, `ext-iconv` | the same | the same | Symfony and string handling |
| `curl` | yes | `ext-curl` | `ext-curl` | `ext-curl` | HTTP clients, Solr, purge requests |
| `gd` or `imagick` | yes | `ext-gd` | `ext-gd` | `ext-gd` | image variations (ImageMagick binary optional, see 2.9) |
| `intl` | yes | `ext-intl` | `ext-intl` | `ext-intl` | locales, Symfony Intl |
| `json` | built in | `ext-json` | `ext-json` | `ext-json` | always present since PHP 8.0 |
| `mbstring` | yes | `ext-mbstring` | `ext-mbstring` | `ext-mbstring` | multibyte strings, both kernels |
| `xml`, `xsl` | yes | `ext-xml`, `ext-xsl` | the same | the same | XML text and rich text conversion |
| `pdo` with `pdo_mysql`, `pdo_pgsql` or `pdo_sqlite` | yes | yes | yes | yes | Doctrine DBAL connection |
| `mysqli` | for MySQL / MariaDB | the same | the same | the same | the legacy kernel's MySQL driver (`ezmysqli`), which the bridge selects for `pdo_mysql` |
| `pgsql` | for PostgreSQL | the same | the same | the same | the legacy kernel's PostgreSQL driver (`ezpostgresql`) |
| `sqlite3` | for SQLite | the same | the same | the same | the legacy kernel's SQLite driver (`sqlite3`) |
| `zip`, `fileinfo` | yes | recommended | recommended | recommended | packages, uploads, MIME detection |
| `opcache` | recommended | listed by the guide | listed | listed | performance |
| `redis` | optional | listed by the 3.x guide | optional | optional | Redis cache pool and sessions |
| `pcntl`, `posix`, `sockets`, `openssl` | for Velocity | the same | the same | the same | Velocity forks and manages workers, uses a zygote socket and terminates TLS |

Why both PDO and the native drivers: the new stack talks to the database through Doctrine DBAL (PDO), the legacy kernel
through its own drivers. LegacyBridge maps the Doctrine driver to the legacy implementation when it injects the
connection (`pdo_mysql` to `ezmysqli`, `pdo_pgsql` to `ezpostgresql`, `oci8` to `ezoracle`, `pdo_sqlite` to
`sqlite3`; `bundle/LegacyMapper/Configuration.php` of LegacyBridge). The PHP extension behind each legacy driver must
therefore be loaded too. According to the 5.x installation guide, the extension
`sevenx_exponential_platform_v5_database_translator` (active first in the list) registers `QueryTranslator*` drivers
as `ImplementationAlias` for those names, so the legacy kernel uses them instead ([chapter 5](05-the-legacy-kernel-inside.md)).

```bash
php -m | grep -i -E '^(ctype|curl|gd|imagick|iconv|intl|json|mbstring|xml|xsl|pdo_mysql|mysqli|pdo_pgsql|pgsql|pdo_sqlite|sqlite3|zip|fileinfo|opcache|pcntl|posix|sockets|openssl)$'
```

## 2.4 php.ini settings

| Setting | Value | Why |
|---|---|---|
| `memory_limit` | 256M at least; 512M for 4.6.x and for imports | both kernels are loaded in one process; the 4.6.x guide asks for 512M |
| `date.timezone` | set, for example `Europe/Berlin` | both kernels read it; an unset value produces warnings |
| `max_execution_time` | 90 to 120 for web requests, 300 or more for the CLI | the guides name 90 (3.x) and 120 (4.6.x, 5.x) |
| `upload_max_filesize`, `post_max_size` | your largest upload | the shipped Apache and nginx examples allow 48 MB request bodies |
| `opcache.enable` | `1` | performance; for Velocity see [chapter 6](06-serving-the-site.md) |
| `realpath_cache_size` | 4096K or more | Symfony recommends it for the many files of a full stack |
| `display_errors` | `Off` on production | errors belong in the log; on 2.5 `web/app.php` switches display off itself when debugging is off (commit `7605f57`, released in `v2.5.0.4`), while `v2.5.0.3` and earlier switched it **on** for every request |

The CLI and the web server may read different `php.ini` files (`php --ini` shows the CLI's). Set the values for both.
Exponential Velocity is a third place. Its workers are started by the PHP **CLI**, so they read the CLI's `php.ini`,
not PHP-FPM's. On top of that, the engine's compatibility layer reports and enforces some `ini` values of its own
(`Q.compat.ini`); its `--preset=symfony` sets `upload_max_filesize` to 10M and `post_max_size` to 12M, and a preset is
applied after the configuration file, so it wins over values you wrote there. Chapter 6
([6.3.3](06-serving-the-site.md#633-two-ways-to-run-a-symfony-application)) therefore writes the compatibility
settings into the configuration file instead of using the preset.
The legacy kernel's checks of `php.ini` are described in the Exponential 6 book,
[2. Requirements](https://github.com/se7enxweb/exponential/blob/main/doc/install/02-requirements.md).

## 2.5 Databases

| Database | 2.5 | 3.x, 4.6.x, 5.x | Notes |
|---|---|---|---|
| MySQL | 5.7 or later (8.0 recommended) | 8.0 or later | character set `utf8mb4`, collation `utf8mb4_unicode_520_ci` |
| MariaDB | 10.0 or later (10.6 recommended) | 10.3 or later (10.6 recommended) | the same character set and collation |
| PostgreSQL | 9.5 or later (14 recommended) | 14 or later (16 recommended) | `UTF8` encoding |
| SQLite | 3.35 or later | 3.35 or later | no server; development, tests, demos and air-gapped setups according to the project's guides |
| Oracle | documented for conversion only | not documented | the bridge maps `oci8` to the legacy `ezoracle` driver; not verified for this book |

One database serves both kernels. Create it empty; the installer in [chapter 4](04-installing.md) fills it. Engine
choice, tuning, backups and conversion between engines are the subject of [chapter 7](07-databases.md).

## 2.6 Composer

Composer 2 is required by every line. Install it as [getcomposer.org](https://getcomposer.org/download/) describes,
verify the installer's checksum as shown there, and keep it current with `composer self-update`. The project needs
access to [Packagist](https://packagist.org) and GitHub during the install. A complete install downloads several
hundred megabytes; set `COMPOSER_MEMORY_LIMIT=-1` (or `2G`, as the 2.5 line's `.env` does) if Composer runs out of
memory.

## 2.7 Node.js and Yarn

Node.js and Yarn are needed only where the front-end assets are built: on a build machine or in CI, not on a
production server that receives built assets.

| Line | Node.js | Yarn | What the guide says |
|---|---|---|---|
| 2.5 | 14 LTS | 1.22 (classic) | Webpack Encore 1.8.2 with webpack 4.46 needs Node 12 to 14; Node 16 or later breaks the build |
| 3.x | 18 LTS | 1.22 | the project has `.nvmrc` with `v18`, so `nvm use` picks it |
| 4.6.x | 20 LTS | 1.22, through `corepack enable` | "only 20 LTS is tested" |
| 5.x, release `v5.0.2` | 20 LTS | 1.22, through `corepack enable` | the same |
| 5.x, branch since 2026-08-03, release `v5.0.3.1` | 24 LTS | 1.22.22, `npm install -g yarn@1.22.22`; `package.json` names `"packageManager": "yarn@1.22.22"` | "a version jump": only 24 LTS is tested for the branch's new `package.json` (Encore 5, Sass 1.77, CKEditor 5 v48; commit `27ff2ca`, released in `v5.0.3.1`) |

[nvm](https://github.com/nvm-sh/nvm) lets one machine keep several Node versions, which is useful when you build more
than one line:

```bash
nvm install 20 && nvm install 24        # once
nvm use 20 && node -v                   # v20.x.y: the 4.6.x build, the v5.0.2 build
nvm use 24 && node -v                   # v24.x.y: the 5.x branch build
```

The wrong Node version rarely announces itself clearly. On 2.5, webpack 4 under Node 17 or later (OpenSSL 3) stops
with `error:0308010C:digital envelope routines::unsupported`; on the newer lines a Node that is too old usually fails
while Yarn installs packages, with `The engine "node" is incompatible with this module`. Check `node -v` first whenever
an asset build fails.

## 2.8 Serving the site

| Way | Needs | Chapter |
|---|---|---|
| **Exponential Velocity** (recommended) | PHP 8.1 or later with `sockets` (required by the engine's `composer.json`), `pcntl` and `posix` (workers), `openssl` (HTTPS); for the CGI mode also `php-cgi` of the same PHP version; container images exist for PHP 8.2 to 8.5 | [6.3](06-serving-the-site.md#63-exponential-velocity) |
| Apache 2.4 | `mod_rewrite`, `mod_env`, recommended `mod_setenvif`, `mod_expires`, `mod_headers`, `mod_deflate`; PHP-FPM through `mod_proxy_fcgi` (event or worker MPM) or `mod_php` (prefork) | [6.5](06-serving-the-site.md#65-apache-24) |
| nginx | 1.18 or later, PHP-FPM | [6.6](06-serving-the-site.md#66-nginx) |
| Symfony CLI | development only (`symfony server:start`) | [6.4](06-serving-the-site.md#64-the-symfony-cli-development-only) |

## 2.9 Optional services

| Service | 2.5 | 3.x, 4.6.x | 5.x | Used for |
|---|---|---|---|---|
| Redis | 4.0 or later | 6.0 or later | 6.0 or later | cache pool, sessions |
| Memcached | supported by a cache pool file | the same | the same | cache pool |
| Solr | 6.x or 7.7 | 7.7 or 8.11 | 8.11 | search engine instead of the default `legacy` engine |
| Varnish | 5.1 or later, 6.0 LTS recommended, with the `xkey` module | 6.0 or 7.1+ | 6.0 or 7.1+ | HTTP cache in front of the application |
| ImageMagick | optional | `IMAGEMAGICK_PATH`, default `/usr/bin` | the same | image conversion for both kernels |

## 2.10 Operating systems and sizing

The project documents Linux, the BSDs and macOS (the installation guides of 3.x, 4.6.x and 5.x list package commands
for Debian, Ubuntu, Red Hat Enterprise Linux and its rebuilds, Fedora, openSUSE, Arch, FreeBSD, OpenBSD and macOS).
Windows is usable through WSL2; the Docker blueprints warn about slow file access on Docker for Mac and Windows.

Sizing depends on traffic and content; as a starting point for one site:

| | Small site, development | Production, one server |
|---|---|---|
| CPU | 2 cores | 4 cores or more |
| Memory | 4 GB (database, PHP, asset build) | 8 GB or more; PHP's share is `memory_limit` times the number of PHP workers |
| Disk | 5 GB (vendor, node_modules, caches) | content storage plus caches plus backups |

## 2.11 A checklist for a fresh server

```bash
php -v                                        # 2.2: the floor for your line
php -m                                        # 2.3: the extensions
php -i | grep -E 'memory_limit|date.timezone|max_execution_time|upload_max_filesize|post_max_size'
composer --version                            # 2.6: Composer 2.x
mysql --version || psql --version || sqlite3 --version   # 2.5
node -v && yarn -v                            # 2.7, only on the build machine
```

What a server that passes looks like, for the 4.6.x line with MariaDB, and what each line checks:

```text
PHP 8.3.12 (cli) ...                         >= the floor of 2.2 (8.0 for 4.6.x)
ctype curl gd iconv intl json mbstring ...   every extension of 2.3, including mysqli next to pdo_mysql
memory_limit => 512M => 512M                 2.4; the CLI value (FPM's may differ)
date.timezone => Europe/Berlin               set, not "no value"
Composer version 2.8.x ...                   2.x
mysql  Ver 15.1 Distrib 10.11.x-MariaDB      2.5: MariaDB 10.3 or later
v20.18.x / 1.22.22                           2.7: Node 20, Yarn classic
```

The two failures this list catches most often are a missing `mysqli` (or `pgsql`, `sqlite3`) next to the PDO driver,
which lets the new stack work while the legacy kernel fails with a database error, and a `date.timezone` that is set
for the CLI but not for PHP-FPM, which shows warnings only on the web.

## 2.12 References

In this repository:

- [README.md, Requirements](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/README.md#requirements) and [doc/INSTALL.md](../INSTALL.md) of the 2.5 line; the
  installation guides of the other lines:
  [3.x doc/INSTALL.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/doc/INSTALL.md),
  [4.6.x INSTALL.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/4.6.x/INSTALL.md),
  [5.x INSTALL.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/5.x/INSTALL.md)
- [doc/apache2/Readme.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/apache2/Readme.md), [doc/nginx/Readme.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/nginx/Readme.md),
  [doc/varnish/varnish.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/varnish/varnish.md)

External:

- The Exponential 6 book: [2. Requirements](https://github.com/se7enxweb/exponential/blob/main/doc/install/02-requirements.md)
- PHP: [supported versions](https://www.php.net/supported-versions.php), [php.ini directives](https://www.php.net/manual/en/ini.list.php),
  [time zones](https://www.php.net/manual/en/timezones.php), [OPcache](https://www.php.net/manual/en/book.opcache.php)
- Symfony: [technical requirements](https://symfony.com/doc/current/setup.html#technical-requirements),
  [performance](https://symfony.com/doc/current/performance.html)
- Composer: [download](https://getcomposer.org/download/), [platform packages](https://getcomposer.org/doc/01-basic-usage.md#platform-packages),
  [`--ignore-platform-reqs`](https://getcomposer.org/doc/03-cli.md#install-i)
- Upstream requirements for comparison: [Ibexa DXP requirements](https://doc.ibexa.co/en/latest/getting_started/requirements/)
- Exponential Velocity: [requirements](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/requirements.md)
- Node.js: [nvm](https://github.com/nvm-sh/nvm), [corepack](https://github.com/nodejs/corepack)

[Previous: 1. Introduction](01-introduction.md) · [Next: 3. Getting the code](03-getting-the-code.md) ·
[Contents](README.md)
