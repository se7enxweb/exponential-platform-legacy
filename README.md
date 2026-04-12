# Exponential Platform DXP v5 (Stable; Platform v5; Open Source; Starter Skeleton)

[![PHP](https://img.shields.io/badge/PHP-8.3%2B-8892BF?logo=php&logoColor=white)](https://php.net)
[![Symfony](https://img.shields.io/badge/Symfony-7.4%20LTS-000000?logo=symfony&logoColor=white)](https://symfony.com)
[![Platform](https://img.shields.io/badge/Platform-5.0%20OSS-orange)](https://github.com/se7enxweb)
[![License: GPL v2 (or any later version)](https://img.shields.io/badge/License-GPL%20v2%20(or%20any%20later%20version)-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
[![GitHub issues](https://img.shields.io/github/issues/se7enxweb/exponential-platform-dxp-skeleton)](https://github.com/se7enxweb/exponential-platform-dxp-skeleton/issues)
[![GitHub stars](https://img.shields.io/github/stars/se7enxweb/exponential-platform-dxp-skeleton?style=social)](https://github.com/se7enxweb/exponential-platform-dxp-skeleton)

> **Exponential Platform DXP** is an open-source Digital Experience Platform (DXP/CMS) built on **Symfony 7.4 LTS** with **PHP 8.3+**. This is the **DXP v5 Starter Skeleton** — the ready-to-deploy project template for Exponential Platform DXP v5.

This is a website skeleton for Exponential Platform DXP (Stable; Platform v5; Open Source). No LegacyBridge, no classic legacy kernel — just the clean, forward-only Symfony 7.4 LTS new stack running the full Exponential Platform v5 OSS DXP content engine.

---

## Table of Contents

1. [Project Notice](#exponential-platform-dxp-project-notice)
2. [Project Status](#exponential-platform-dxp-project-status)
3. [Who is 7x](#who-is-7x)
4. [What is Exponential Platform DXP?](#what-is-exponential-platform-dxp)
5. [Technology Stack](#technology-stack)
6. [Requirements](#requirements)
7. [Quick Start](#quick-start)
8. [Main Features](#main-exponential-platform-dxp-features)
9. [Installation](#installation)
10. [Key CLI Commands Reference](#key-cli-commands-reference)
11. [Issue Tracker](#issue-tracker)
12. [Where to Get More Help](#where-to-get-more-help)
13. [How to Contribute](#how-to-contribute-new-features-and-bugfixes-into-exponential-platform-dxp)
14. [Donate & Support](#donate-and-make-a-support-subscription)
15. [Copyright](#copyright)
16. [License](#license)

---

## Exponential Platform DXP Project Notice

> "Please Note: This project is not associated with the original eZ Publish software or its original developer, eZ Systems."

This is an independent, 7x + community-driven continuation of the platform. The Exponential Platform DXP codebase is stewarded and evolved by [7x (se7enx.com)](https://se7enx.com) and the open-source community of developers and integrators who have relied on it for decades.

---

## Exponential Platform DXP Project Status

**Exponential Platform DXP has made it beyond its end of life in 2021 and survived. The Platform v5 (5.0.x) release line is the new-stack, forward-only release targeting Symfony 7.4 LTS and PHP 8.3+.**

The platform is under active development and targeted improvement. The **5.0.x (Platform v5)** release series is the current active development branch. This is the pure single-kernel release and the first major version series to run exclusively on Symfony 7.4 LTS with full PHP 8.3+ support. Ongoing work focuses on:

- Symfony 7.4 LTS new-stack kernel development and stabilisation
- PHP 8.3 and 8.5 full compatibility and testing
- REST API v2, GraphQL, and JWT authentication on Symfony 7.4 LTS
- Dependency upgrades across Composer and Yarn package ecosystems
- Security patches and vulnerability triage
- Documentation and developer experience improvements

---

## Who is 7x

[7x](https://se7enx.com) is the North American corporation driving the continued general use, support, development, hosting, and design of Exponential Platform DXP Enterprise Open Source Content Management System.

7x has been in business supporting Exponential Platform website customers and projects for over 24 years. 7x took over leadership of the project and its development, support, adoption and community growth in 2023.

7x represents a serious company leading the open source community-based effort to improve Exponential Platform and its available community resources to help users continue to adopt and use the platform to deliver the very best in web applications, websites and headless applications in the cloud.

Previously before 2022, 7x was called Brookins Consulting — the outspoken leader in the active Exponential Platform Community and its portals for over 24 years.

**7x offers:**
- Commercial support subscriptions for Exponential Platform DXP deployments
- Hosting on the Exponential Platform cloud infrastructure (`exponential.earth`)
- Custom development, migrations, upgrades, and training
- Community stewardship via [share.exponential.earth](https://share.exponential.earth)

---

## What is Exponential Platform DXP?

### The Platform v5 Single-Kernel Architecture

Exponential Platform DXP v5 runs a single, modern content kernel:

- **New Stack — Exponential Platform v5 OSS (Symfony 7.4 LTS)** — the full Platform v5 content engine providing REST API v2, GraphQL, Symfony controllers, the Platform v5 Admin UI, and first-class Twig template rendering.

The Platform v5 architecture is straightforward: one Symfony application, one kernel, one web entry point. There is no legacy bridge, no secondary kernel, and no dual-admin complexity. Content is rendered through Symfony Twig templates with full access to the Platform v5 content API.

### Recent Improvements to Exponential Platform DXP

Exponential Platform DXP v5 (5.0.x) releases run the Exponential Platform v5 OSS new-stack kernel on **Symfony 7.4 LTS** with **PHP 8.3+** — delivering the modern DXP experience on a fully supported, long-term-stable runtime.

### What Does Exponential Platform DXP Provide for End Users Building Websites?

Exponential Platform DXP is a professional PHP application framework with advanced CMS (content management system) functionality. As a CMS, its most notable feature is its fully customizable and extendable content model. It is also suitable as a platform for general PHP development, allowing you to develop professional Internet applications, fast.

Standard CMS functionality, like news publishing and content management, is built in and ready for you to use. Its stand-alone libraries can be used for cross-platform, secure, database independent PHP projects.

Exponential Platform DXP is database, platform and browser independent. Because it is browser based it can be used and updated from anywhere as long as you have access to the Internet.

---

## Technology Stack

| Component | Value |
|---|---|
| Language | PHP 8.3+ |
| Framework | Symfony 7.4 LTS |
| CMS Core | Exponential Platform v5 OSS |
| ORM / DBAL | Doctrine ORM 2.x + DBAL 3.x |
| Template Engine | Twig 3.x |
| Frontend Build | Webpack Encore + Yarn 1.x + Node.js 20 LTS |
| Search | Legacy search (default) · Solr 8.x (optional) |
| HTTP Cache | Symfony HttpCache (default) · Varnish 6/7 (optional) |
| App Cache | Filesystem (default) · Redis 6+ (optional) |
| Database | MySQL 8.0+ · MariaDB 10.3+ · PostgreSQL 14+ · SQLite 3.35+ (dev/testing) |
| API | REST API v2 · GraphQL (schema auto-generated) · JWT auth |
| Admin UI | Platform v5 Admin UI (/adminui/) |
| Dependency Mgmt | Composer 2.x · Yarn 1.x |

---

## Requirements

- PHP 8.3+ (PHP 8.3 or 8.5 recommended)
- A web server: Apache 2.4 or Nginx 1.18+
- A database server: MySQL 8.0+, MariaDB 10.3+, PostgreSQL 14+, or SQLite 3.35+ (dev/testing)
- Composer 2.x
- Node.js 20 LTS (via nvm recommended)
- Yarn 1.22.x

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
| SQLite | 3.35 | 3.39+ (dev/testing only) |
| Redis | 6.0 | 7.x (optional) |
| Solr | 8.x | 8.11.x (optional) |
| Varnish | 6.0 | 7.1+ (optional) |
| Apache | 2.4 | 2.4 (event + PHP-FPM) |
| Nginx | 1.18 | 1.24+ |

---

## Quick Start

```bash
# 1. Create project from the DXP skeleton
composer create-project se7enxweb/exponential-platform-dxp-skeleton \
    exponential_website
cd exponential_website

# 2. Configure environment
cp .env .env.local
# MySQL/MariaDB: edit DATABASE_HOST, DATABASE_NAME, DATABASE_USER, DATABASE_PASSWORD, APP_SECRET, APP_ENV
# SQLite (zero-config): set DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_%kernel.environment%.db"
#                        and MESSENGER_TRANSPORT_DSN=sync://

# 3. Create database and import demo data
# MySQL/MariaDB:
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
php bin/console exponential:install --no-interaction exponential-oss

# SQLite (no separate server needed — the .db file is created automatically):
php bin/console exponential:install --no-interaction exponential-oss

# 4. Set permissions
setfacl -R  -m u:www-data:rwX -m g:www-data:rwX var/
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var/

# 5. Build frontend assets
source ~/.nvm/nvm.sh && nvm use 20
yarn install && yarn build

# 6. Publish bundle assets and build Admin UI
php bin/console assets:install --symlink --relative public
yarn ibexa:build

# 7. Generate JWT keypair (REST API)
php bin/console lexik:jwt:generate-keypair

# 8. Clear cache
php bin/console cache:clear

# 9. Start
symfony server:start
# → https://127.0.0.1:8000              (public site — Symfony/Twig)
# → https://127.0.0.1:8000/adminui/     (Platform v5 Admin UI — admin / publish)
# → https://127.0.0.1:8000/api/ezp/v2/  (REST API v2)
# → https://127.0.0.1:8000/graphql      (GraphQL)
```

See [INSTALL.md](INSTALL.md) for the complete step-by-step guide.

---

## Main Exponential Platform DXP Features

- User defined content classes and objects
- Version control
- Advanced multi-lingual support
- Built in search engine
- Separation of content and presentation layer
- Fine grained role based permissions system
- Content approval and scheduled publication
- Multi-site and multi-siteaccess support
- Multimedia support with automatic image conversion and scaling
- RSS feeds
- Contact forms
- Flexible workflow management system
- Full support for Unicode
- Template engine (Twig 3.x for the Platform v5 new stack)
- A headless CRUD REST API
- Database abstraction layer supporting MySQL, MariaDB, SQLite 3.35+, PostgreSQL, and Oracle
- MVC architecture
- Support for the latest image and video file formats (webp, webm, png, jpeg, etc.)
- Support for highly available and scalable configurations (multi-server clusters)
- XML handling and parsing library
- SOAP communication library
- Localisation and internationalisation libraries
- Several other reusable libraries
- SDK (software development kit) and full documentation
- Plugin API with thousands of open-source extensions available

### Additional Capabilities in the v5 (Platform v5) Series

- **Single-Kernel Architecture** — Exponential Platform v5 OSS runs on Symfony 7.4 LTS with no legacy bridge overhead
- **GraphQL API** — auto-generated schema per content model via `ibexa:graphql:generate-schema`
- **JWT Authentication** — REST API secured by RSA keypairs (`lexik/jwt-authentication-bundle`)
- **Platform v5 Admin UI** — React-powered editorial interface at `/adminui/`
- **Webpack Encore** — modern asset pipeline with HMR dev server and production minification
- **Design Engine** — `@ezdesign` Twig namespace with theme fallback chain for clean template inheritance
- **Multi-siteaccess** — run multiple sites, languages, or environments from a single codebase and database
- **SQLite database support** — zero-config alternative to MySQL/MariaDB for local development, testing, air-gapped deployments, and demo environments
- **DBAL 3.x** — Doctrine DBAL 3.x with `instanceof`-based platform detection (no deprecated `getName()` calls)

---

## Installation

Create a new project using Composer:

```bash
composer create-project se7enxweb/exponential-platform-dxp-skeleton exponential_website
```

The installation guide covers:

- First-time install (`composer create-project` or `git clone`)
- Environment configuration (`.env.local` reference)
- Database creation and demo data import (MySQL/MariaDB, PostgreSQL, SQLite)
- Web server setup (Apache 2.4, Nginx, Symfony CLI)
- File & directory permissions
- Frontend asset build (Webpack Encore / Yarn)
- Admin UI asset build
- JWT keypair generation
- GraphQL schema generation
- Search index initialisation
- Cache management
- Day-to-day operations (start / stop / restart / deploy)
- Cron job setup
- Solr search engine integration (optional)
- Varnish HTTP cache integration (optional)
- Troubleshooting
- Database conversion (MySQL ↔ PostgreSQL ↔ SQLite)

See [INSTALL.md](INSTALL.md) for the complete step-by-step guide.

Learn more about our open source products — [Exponential Platform DXP](https://platform.exponential.earth/).

---

## Key CLI Commands Reference

A quick reference for the most frequently used Symfony, Platform v5, and Admin UI console commands.

> **Command Prefix Convention:** Commands using the `exponential:` prefix are canonical in this distribution. The old `ibexa:*` name works as a deprecated alias for migrated commands. The `ezplatform:*` / `ezpublish:*` prefixes do **not** exist in Platform v5. Commands not yet migrated retain their `ibexa:*` name.

### Symfony Core

```bash
php bin/console list                                          # list all registered commands
php bin/console help <command>                                # help for a specific command
php bin/console cache:clear                                   # clear application cache
php bin/console cache:clear --env=prod                        # clear production cache
php bin/console cache:warmup --env=prod                       # warm up prod cache after deploy
php bin/console cache:pool:clear cache.redis                  # clear a specific cache pool
php bin/console debug:router                                  # list all routes
php bin/console debug:container                               # list all service IDs
php bin/console debug:config <bundle>                         # dump resolved bundle config
php bin/console debug:event-dispatcher                        # list all event listeners
php bin/console assets:install --symlink --relative public    # publish bundle public/ assets
php bin/console messenger:consume                             # consume async message queue
```

### Doctrine / Migrations

```bash
php bin/console doctrine:migration:migrate --allow-no-migration   # run pending migrations
php bin/console doctrine:migration:status                          # show migration status
php bin/console doctrine:migration:diff                            # generate a new migration
php bin/console doctrine:schema:validate                           # validate entity mappings
```

### Exponential Platform v5 (new stack)

> **Command Prefix Convention:** `exponential:*` is canonical. `ibexa:*` is a deprecated alias for migrated commands. The `ezplatform:*` prefix does **not** exist in Platform v5.

```bash
php bin/console exponential:install exponential-oss           # fresh install with demo data
php bin/console exponential:reindex                           # rebuild search index (full)
php bin/console exponential:reindex --iteration-count=50      # incremental reindex
php bin/console ibexa:cron:run                                # run the Platform v5 cron scheduler
php bin/console ibexa:graphql:generate-schema                 # regenerate GraphQL schema from content model
# Solr: no console command in v5 — provision cores via Solr Admin HTTP API
php bin/console bazinga:js-translation:dump public/assets --merge-domains   # JS i18n
php bin/console fos:httpcache:invalidate:path / --all         # purge HTTP cache paths
php bin/console lexik:jwt:generate-keypair                    # generate RSA keypair for REST API auth
```

### Admin UI & Site access points

| URL | Description |
|---|---|
| `/adminui/` | Platform v5 Admin UI (new stack, React) |
| `/` | Public site (Symfony/Twig controllers) |
| `/api/ezp/v2/` | REST API v2 |
| `/graphql` | GraphQL endpoint |

### Frontend / Asset Build (Yarn / Webpack Encore)

Activate Node.js 20 LTS via nvm before running any Yarn commands:

```bash
source ~/.nvm/nvm.sh && nvm use 20    # activate Node.js 20 LTS (required)
corepack enable                        # activates Yarn 1.22.22 as declared in package.json

yarn install            # install / update Node dependencies
yarn dev                # build all assets with source maps — dev mode
yarn build              # build all assets minified for production
yarn watch              # watch mode — auto-rebuild site assets on change
yarn ibexa:dev          # build Platform v5 Admin UI assets — dev mode
yarn ibexa:watch        # watch mode — auto-rebuild Admin UI assets on change
yarn ibexa:build        # build Platform v5 Admin UI assets — production
```

All `ibexa:*` scripts build through `webpack.config.js` using `--config-name ibexa`, which applies the required `@ibexa-admin-ui` alias and configuration.

See [INSTALL.md](INSTALL.md) for the complete step-by-step guide with server configuration, Solr, Varnish, and production deployment.

---

## Issue Tracker

Submitting bugs, improvements and stories is possible on https://github.com/se7enxweb/exponential-platform-dxp-skeleton/issues

If you discover a security issue, please responsibly report such issues via email to [security@exponential.one](mailto:security@exponential.one)

---

## Where to Get More Help

| Resource | URL |
|---|---|
| Platform Website | platform.exponential.earth |
| Documentation Hub | doc.exponential.earth |
| Community Forums | share.exponential.earth |
| GitHub Organisation | github.com/se7enxweb |
| This Repository | github.com/se7enxweb/exponential-platform-dxp-skeleton |
| DXP Metapackage | github.com/se7enxweb/exponential-platform-dxp |
| Issue Tracker | [Issues](https://github.com/se7enxweb/exponential-platform-dxp/issues) |
| Discussions | [Discussions](https://github.com/se7enxweb/exponential-platform-dxp/discussions) |
| Telegram Chat | t.me/exponentialcms |
| Discord | discord.gg/exponential |
| 7x Corporate | se7enx.com |
| Support Subscriptions | support.exponential.earth |
| Sponsor 7x | sponsor.se7enx.com |

---

## How to Contribute New Features and Bugfixes into Exponential Platform DXP

Everyone is encouraged to contribute to the development of new features and bugfixes for Exponential Platform DXP.

Getting started as a contributor:

1. Fork the repository on GitHub: [github.com/se7enxweb/exponential-platform-dxp-skeleton](https://github.com/se7enxweb/exponential-platform-dxp-skeleton)
2. Clone your fork and create a feature branch: `git checkout -b feature/my-improvement`
3. Install the full dev stack per [INSTALL.md](INSTALL.md) (`APP_ENV=dev`)
4. Make your changes — follow coding standards in `CONTRIBUTING.md`
5. Test with `php bin/phpunit` and verify no regressions
6. Push your branch and open a Pull Request against the `master` branch
7. Participate in the review — maintainers will give feedback promptly

Bug reports, feature requests, and discussion are all welcome via the [issue tracker](https://github.com/se7enxweb/exponential-platform-dxp-skeleton/issues) and [GitHub Discussions](https://github.com/se7enxweb/exponential-platform-dxp-skeleton/discussions).

---

## Donate and Make a Support Subscription

### Help Fund Exponential Platform DXP!

You can support this project and its community by making a donation of whatever size you feel willing to give to the project.

If we have helped you and you would like to support the project with a subscription of financial support you may. This is what helps us deliver more new features and improvements to the software. Support Exponential Platform DXP with a subscription today!

A wide range of donation options available at [sponsor.se7enx.com](https://sponsor.se7enx.com/), [paypal.com/paypalme/7xweb](https://www.paypal.com/paypalme/7xweb) and [github.com/sponsors/se7enxweb](https://github.com/sponsors/se7enxweb)

Every contribution — from a one-time thank-you donation to an ongoing support subscription — goes directly toward:

- Maintaining PHP compatibility as new versions release
- Patching the Platform v5 kernel for PHP 8.x and beyond
- Writing documentation and tutorials
- Running the community infrastructure (forums, chat, docs portal)
- Triaging and fixing security vulnerabilities
- Funding new features voted on by the community

---

## COPYRIGHT

Copyright (C) 1998-2026 7x (formerly Brookins Consulting). All rights reserved.

Copyright (C) 1999-2025 Ibexa AS (formerly eZ Systems AS). All rights reserved.

## LICENSE

This source code is available separately under the following licenses:

A - Ibexa Business Use License Agreement (Ibexa BUL),
version 2.4 or later versions (as license terms may be updated from time to time)
Ibexa BUL is granted by having a valid Ibexa DXP (formerly eZ Platform Enterprise) subscription,
as described at: https://www.ibexa.co/product
For the full Ibexa BUL license text, please see:
https://www.ibexa.co/software-information/licenses-and-agreements (latest version applies)

AND

B - GNU General Public License, version 2
Grants an copyleft open source license with ABSOLUTELY NO WARRANTY. For the full GPL license text, please see:
https://www.gnu.org/licenses/old-licenses/gpl-2.0.html

Copyright © 1998 – 2026 7x (se7enx.com). All rights reserved unless otherwise noted.
Exponential Platform DXP is Open Source software released under the GNU GPL v2 or any later version.
