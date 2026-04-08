# Exponential Platform Legacy v4.6.x (Stable; Open Source; Starter Skelton)

[![PHP](https://img.shields.io/badge/PHP-8.0%20→%208.5-8892BF?logo=php&logoColor=white)](https://php.net)
[![Symfony](https://img.shields.io/badge/Symfony-5.4%20LTS-000000?logo=symfony&logoColor=white)](https://symfony.com)
[![Platform](https://img.shields.io/badge/Platform-4.6%20OSS-orange)](https://github.com/se7enxweb)
[![LegacyBridge](https://img.shields.io/badge/LegacyBridge-4.x-green)](https://github.com/se7enxweb/legacy-bridge)
[![Netgen Layouts](https://img.shields.io/badge/Netgen%20Layouts-1.4+-blue)](https://github.com/netgen/layouts-core)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/gpl-2.0)
[![GitHub issues](https://img.shields.io/github/issues/se7enxweb/exponential-platform-legacy)](https://github.com/se7enxweb/exponential-platform-legacy/issues)
[![GitHub stars](https://img.shields.io/github/stars/se7enxweb/exponential-platform-legacy?style=social)](https://github.com/se7enxweb/exponential-platform-legacy)

> **Exponential Platform Legacy** is a hybrid-kernel open-source Digital Experience Platform (DXP/CMS) built on the **Exponential (Legacy) 6.x kernel** bridged to Symfony 5.4 LTS via LegacyBridge 4.x. This is the **LegacyBridge (LB)** skeleton release — featuring Netgen Layouts 1.4+ alongside the proven Legacy kernel, with full PHP 8.x compatibility and the Platform v4 new-stack layer running in a single application.

This is a website skeleton for Exponential Platform Legacy (Stable; Open Source).

---

## Table of Contents

1. [Project Notice](#exponential-platform-legacy-project-notice)
2. [Project Status](#exponential-platform-legacy-project-status)
3. [Who is 7x](#who-is-7x)
4. [What is Exponential Platform Legacy?](#what-is-exponential-platform-legacy)
5. [Technology Stack](#technology-stack)
6. [Requirements](#requirements)
7. [Quick Start](#quick-start)
8. [Main Features](#main-exponential-platform-legacy-features)
9. [Installation](#installation)
10. [Key CLI Commands Reference](#key-cli-commands-reference)
11. [Issue Tracker](#issue-tracker)
12. [Where to Get More Help](#where-to-get-more-help)
13. [How to Contribute](#how-to-contribute-new-features-and-bugfixes-into-exponential-platform-legacy)
14. [Donate & Support](#donate-and-make-a-support-subscription)
15. [Copyright](#copyright)
16. [License](#license)

---

## Exponential Platform Legacy Project Notice

> "Please Note: This project is not associated with the original eZ Publish software or its original developer, eZ Systems."

This is an independent, 7x + community-driven continuation of the platform. The Exponential Platform Legacy codebase is stewarded and evolved by [7x (se7enx.com)](https://se7enx.com) and the open-source community of developers and integrators who have relied on it for decades.

---

## Exponential Platform Legacy Project Status

**Exponential Platform Legacy has made it beyond its end of life in 2021 and survived. Current releases are primarily aimed at easing the requirements to support current versions of the PHP language like PHP 8.2, 8.3, 8.4, 8.5, 8.6 and beyond.**

The platform is under active maintenance and targeted improvement. The **4.6.x (Platform v4)** release line is the current last stable verion series of the platform v4 Distrobution. This is first LegacyBridge release to successfully bridge Exponential 6.x (Legacy) to Symfony 5.4 LTS with full PHP 8.x support and Netgen Layouts 1.4+ integration. Ongoing work focuses on:

- Continued PHP 8.x compatibility (8.2, 8.3, 8.4, 8.5.4 tested and supported)
- Exponential (Legacy) kernel patches for PHP 8.x runtime compatibility
- LegacyBridge 4.x compatibility maintenance for Symfony 5.4 LTS alignment
- Netgen Layouts 1.4+ integration and improvements
- Dependency upgrades across Composer and Yarn package ecosystems
- Security patches and vulnerability triage
- Documentation and developer experience improvements

---

## Who is 7x

[7x](https://se7enx.com) is the North American corporation driving the continued general use, support, development, hosting, and design of Exponential Platform Legacy Enterprise Open Source Content Management System.

7x has been in business supporting Exponential Platform website customers and projects for over 24 years. 7x took over leadership of the project and its development, support, adoption and community growth in 2023.

7x represents a serious company leading the open source community-based effort to improve Exponential Platform and its available community resources to help users continue to adopt and use the platform to deliver the very best in web applications, websites and headless applications in the cloud.

Previously before 2022, 7x was called Brookins Consulting — the outspoken leader in the active Exponential Platform Community and its portals for over 24 years.

**7x offers:**
- Commercial support subscriptions for Exponential Platform Legacy deployments
- Hosting on the Exponential Platform cloud infrastructure (`exponential.earth`)
- Custom development, migrations, upgrades, and training
- Community stewardship via [share.exponential.earth](https://share.exponential.earth)

---

## What is Exponential Platform Legacy?

### The Hybrid Kernel Architecture

Exponential Platform Legacy runs **two content kernels in the same request cycle**:

- **Legacy Kernel** — Exponential (Legacy) 6.x — the classic, battle-hardened PHP content engine with its native template system, modules, cronjob framework, roles, workflows, and full content model. This is the primary kernel in this release.
- **New Stack** — Exponential Platform v4 OSS (Symfony 5.4) — accessed via LegacyBridge 4.x, providing REST API, GraphQL, Symfony controllers, Netgen Layouts 1.4+ page building, and the Platform v4 Admin UI alongside the legacy admin.

Both kernels share the same database, content repository, and web server entry point. Legacy content is rendered through native Exponential (Legacy) templates (`.tpl`) and Symfony Twig templates simultaneously. The bridge makes incremental migration possible — or simply lets you keep running the proven legacy stack indefinitely.

> **This is the LegacyBridge (LB) release — Platform v4.** It includes Netgen Layouts 1.4+ and the Netgen Site bundle for advanced layout-driven page building on top of this stack.

### Recent Improvements to Exponential Platform Legacy

Exponential Platform Legacy 4.6.x (Platform v4) releases run the **Exponential (Legacy) 6.x kernel + LegacyBridge 4.x + Exponential Platform v4 OSS + Symfony 5.4 LTS + Netgen Layouts 1.4+** — providing the classic eZ Publish experience with modern PHP 8.x runtime support.

### What Does Exponential Platform Legacy Provide for End Users Building Websites?

Exponential Platform Legacy is a professional PHP application framework with advanced CMS (content management system) functionality. As a CMS, its most notable feature is its fully customizable and extendable content model. It is also suitable as a platform for general PHP development, allowing you to develop professional Internet applications, fast.

Standard CMS functionality, like news publishing and forums, is built in and ready for you to use. Its stand-alone libraries can be used for cross-platform, secure, database independent PHP projects.

Exponential Platform Legacy is database, platform and browser independent. Because it is browser based it can be used and updated from anywhere as long as you have access to the Internet.

---

## Technology Stack

| Layer | Technology |
|---|---|
| **Language** | PHP 8.0 → 8.5 |
| **Framework** | Symfony 5.4 LTS |
| **CMS Core (legacy)** | Exponential (Legacy) 6.x (`ezpublish_legacy/`) |
| **CMS Core (new stack)** | Exponential Platform v4 OSS |
| **Bridge** | LegacyBridge 4.x (`se7enxweb/legacy-bridge`) |
| **Page Builder** | Netgen Layouts 1.4+ |
| **ORM** | Doctrine ORM 2.x |
| **Template Engine** | Legacy TPL (legacy) + Twig 3.x (new stack) |
| **Frontend Build** | Webpack Encore + Yarn 1.x + Node.js 20 LTS |
| **Search** | Legacy search (default) · Solr 7.7 / 8.x (optional) |
| **HTTP Cache** | Symfony HttpCache (default) · Varnish 6/7 (optional) |
| **App Cache** | Filesystem (default) · Redis 6+ (optional) |
| **Database** | MySQL 8.0+ · MariaDB 10.3+ · PostgreSQL 14+ · SQLite 3.x (dev / testing) |
| **API** | REST API v2 · GraphQL (schema auto-generated) · JWT auth |
| **Admin UI (legacy)** | Exponential (Legacy) Admin (`/ezpublish_legacy/` design) |
| **Admin UI (new stack)** | Platform v4 Admin UI (`/adminui/`) |
| **Dependency Mgmt** | Composer 2.x · Yarn 1.x |

---

## Requirements

- PHP 8.0+ (8.2, 8.3, or 8.5 recommended)
- A web server: Apache 2.4 or Nginx 1.18+
- A database server: MySQL 8.0+, MariaDB 10.3+, PostgreSQL 14+, or SQLite 3.x (dev/testing)
- Composer 2.x
- Node.js 20 LTS (via nvm recommended)
- Yarn 1.22.x

### Full Requirements Summary

| Requirement | Minimum | Recommended |
|---|---|---|
| PHP | 8.0 | 8.3 or 8.5 |
| Composer | 2.x | latest 2.x |
| Node.js | 18 | 20 LTS (via nvm) |
| Yarn | 1.x | 1.22.x |
| MySQL | 8.0 | 8.0+ (utf8mb4) |
| MariaDB | 10.3 | 10.6+ |
| PostgreSQL | 14 | 16+ |
| SQLite | 3.x | 3.35+ (dev/testing only) |
| Redis | 6.0 | 7.x (optional) |
| Solr | 7.7 | 8.11.x (optional) |
| Varnish | 6.0 | 7.1+ (optional) |
| Apache | 2.4 | 2.4 (event + PHP-FPM) |
| Nginx | 1.18 | 1.24+ |

---

## Quick Start

```bash
# 1. Create project
composer create-project se7enxweb/exponential-platform-legacy:4.6.x-dev exponential_website
cd exponential_website

# 2. Configure environment
cp .env .env.local
# MySQL/MariaDB: edit DATABASE_HOST, DATABASE_NAME, DATABASE_USER, DATABASE_PASSWORD, APP_SECRET, APP_ENV
# SQLite (zero-config): set DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_%kernel.environment%.db"
#                        and MESSENGER_TRANSPORT_DSN=sync://

# 3. Create database and import demo data
# MySQL/MariaDB:
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
# SQLite (no separate server needed — the .db file is created automatically):
php bin/console ibexa:install --no-interaction

# 4. Set permissions
setfacl -R -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var

# 5. Build frontend assets
nvm use 20 && yarn install && yarn build;

# 6. Build Admin UI assets
yarn ez

# 7. Clear all caches (Symfony + Legacy kernel)
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache

# 8. Start
symfony server:start
# → https://127.0.0.1:8000                  (site / hybrid-kernel frontend)
# → https://127.0.0.1:8000/adminui/         (Platform v4 Admin UI — admin / publish)
# → https://127.0.0.1:8000/ezpublish_legacy/ (Legacy Admin — admin / publish)
```

> See [INSTALL.md](INSTALL.md) for the complete step-by-step guide with server configuration, Solr, Varnish, and production deployment.

---

## Main Exponential Platform Legacy Features

- User defined content classes and objects
- Version control
- Advanced multi-lingual support
- Built in search engine
- Separation of content and presentation layer
- Fine grained role based permissions system
- Content approval and scheduled publication
- Multi-site support
- Multimedia support with automatic image conversion and scaling
- RSS feeds
- Contact forms
- Built in webshop
- Flexible workflow management system
- Full support for Unicode
- Template engine (Legacy TPL for legacy kernel + Twig 3.x for new stack)
- A headless CRUD REST API
- Database abstraction layer supporting MySQL, MariaDB, SQLite 3.x, PostgreSQL, and Oracle
- MVC architecture
- Support for the latest image and video file formats (webp, webm, png, jpeg, etc)
- Support for highly available and scalable configurations (multi-server clusters)
- XML handling and parsing library
- SOAP communication library
- Localisation and internationalisation libraries
- Several other reusable libraries
- SDK (software development kit) and full documentation
- Plugin API with thousands of open-source extensions available, including:
    - Content rating and commenting
    - Advanced search engine
    - WYSIWYG rich-text editor
    - In-site content editing
    - Content geolocation
    - Netgen Layouts 1.4+ page-building engine (included in this LB release)

### Additional Capabilities in the 4.6.x (Platform v4) Series

- **Hybrid Kernel** — Exponential (Legacy) 6.x runs alongside Exponential Platform v4 OSS in a single application via LegacyBridge 4.x
- **Netgen Layouts 1.4+** — advanced layout-driven page building engine included in this LB release
- **GraphQL API** — auto-generated schema per content model via `ezplatform:graphql:generate-schema`
- **JWT Authentication** — REST API secured by RSA keypairs (`lexik/jwt-authentication-bundle`)
- **Platform v4 Admin UI** — React-powered editorial interface at `/adminui/` alongside the classic Legacy Admin
- **Exponential (Legacy) Admin** — the original, feature-complete administration interface for legacy content types, modules, and workflows
- **Webpack Encore** — modern asset pipeline with HMR dev server and production minification
- **Design Engine** — `@ezdesign` Twig namespace with theme fallback chain (theme → standard) for clean template inheritance
- **Multi-siteaccess** — run multiple sites, languages, or environments from a single codebase and database
- **SQLite database support** — zero-config alternative to MySQL/MariaDB for local development, testing, air-gapped deployments, and demo environments; both the Symfony new-stack and the Exponential (Legacy) kernel share the same `.db` file automatically via LegacyBridge

---

## Installation

Create a new project using Composer:

```bash
composer create-project se7enxweb/exponential-platform-legacy:4.6.x-dev exponential_website
```

The installation guide covers:
- First-time install (`composer create-project`)
- Environment configuration (`.env.local` reference)
- Database creation and demo data import
- Web server setup (Apache 2.4, Nginx, Symfony CLI)
- File & directory permissions (including `ezpublish_legacy/var/`)
- Frontend asset build (Webpack Encore / Yarn)
- Admin UI asset build
- Search index initialisation
- Cache management (Symfony cache + Legacy kernel cache)
- Day-to-day operations (start / stop / restart / deploy)
- Cron job setup (Platform v4 cron + Legacy cron runner)
- Solr search engine integration
- Varnish HTTP cache integration
- Troubleshooting

Learn more about our open source products — [Exponential Platform Legacy](https://platform.exponential.earth).

---

## Key CLI Commands Reference

A quick reference for the most frequently used Symfony, Platform v4, and Exponential (Legacy) console commands.

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

### Exponential Platform v4 (new stack)

```bash
php bin/console ezplatform:install exponential-oss            # fresh install with demo data
php bin/console ezplatform:reindex                            # rebuild search index (full)
php bin/console ezplatform:reindex --iteration-count=50       # incremental reindex
php bin/console ezplatform:cron:run                           # run the Platform v4 cron scheduler
php bin/console ezplatform:graphql:generate-schema            # regenerate GraphQL schema
php bin/console ezplatform:solr:create-core --cores=default   # set up Solr core
php bin/console bazinga:js-translation:dump public/assets --merge-domains   # JS i18n
php bin/console fos:httpcache:invalidate:path / --all         # purge HTTP cache paths
php bin/console lexik:jwt:generate-keypair                    # generate RSA keypair for REST API auth
```

### Exponential (Legacy) Kernel (LegacyBridge)

```bash
# Clear legacy kernel caches (template / ini / content / override)
php bin/console ezpublish:legacy:clear-cache

# Regenerate legacy autoload arrays (required after adding/removing legacy extensions)
php bin/console ezpublish:legacy:generate-autoloads

# Run a legacy script (e.g. cronjob scripts, import scripts)
php bin/console ezpublish:legacy:script <script-name>

# Run legacy cronjobs directly (bypass Symfony, use in crontab)
php ezpublish_legacy/runcronjobs.php --siteaccess legacy_admin

# Regenerate legacy autoloads from inside the legacy directory
cd ezpublish_legacy && php bin/php/ezpgenerateautoloads.php

# Legacy console (direct access to legacy internals)
php ezpublish_legacy/bin/php/ezcli.php <command>
```

### Legacy Admin & Site Modes

| URL | Purpose |
|---|---|
| `/adminui/` | Platform v4 Admin UI (new stack, React) |
| `/ezpublish_legacy/index.php` | Legacy Admin interface (classic) |
| `/` | Public site (hybrid-kernel Twig + Legacy TPL) |
| `/api/ezp/v2/` | REST API v2 |

### Frontend / Asset Build (Yarn / Webpack)

Activate Node.js 20 LTS via nvm before running any Yarn commands:

```bash
nvm use 20              # activate Node.js 20 LTS (required)
```

```bash
yarn install            # install / update Node dependencies
yarn dev                # build all assets with source maps — dev mode
yarn build              # build all assets minified for production
yarn watch              # watch mode — auto-rebuild site assets on change
yarn ibexa:dev          # build Platform v4 Admin UI assets — dev mode
yarn ibexa:watch        # watch mode — auto-rebuild Admin UI assets on change
yarn ibexa:build        # build Platform v4 Admin UI assets — production
```

> All `ibexa:*` scripts build through `webpack.config.js` using `--config-name ibexa`,
> which applies the required `@ibexa-admin-ui` alias and sass-loader compatibility patch.

---

## Issue Tracker

Submitting bugs, improvements and stories is possible on [https://github.com/se7enxweb/exponential-platform-legacy/issues](https://github.com/se7enxweb/exponential-platform-legacy/issues)

If you discover a [security issue](SECURITY.md), please responsibly report such issues via email to security@exponential.one

---

## Where to Get More Help

| Resource | URL |
|---|---|
| Platform Website | [platform.exponential.earth](https://platform.exponential.earth) |
| Documentation Hub | [doc.exponential.earth](https://doc.exponential.earth) |
| Community Forums | [share.exponential.earth](https://share.exponential.earth) |
| GitHub Organisation | [github.com/se7enxweb](https://github.com/se7enxweb) |
| This Repository | [github.com/se7enxweb/exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy) |
| Issue Tracker | [Issues](https://github.com/se7enxweb/exponential-platform-legacy/issues) |
| Discussions | [Discussions](https://github.com/se7enxweb/exponential-platform-legacy/discussions) |
| Telegram Chat | [t.me/exponentialcms](https://t.me/exponentialcms) |
| Discord | [discord.gg/exponential](https://discord.gg/exponential) |
| 7x Corporate | [se7enx.com](https://se7enx.com) |
| Support Subscriptions | [support.exponential.earth](https://support.exponential.earth) |
| Sponsor 7x | [sponsor.se7enx.com](https://sponsor.se7enx.com) |

---

## How to Contribute New Features and Bugfixes into Exponential Platform Legacy

Everyone is encouraged to [contribute](CONTRIBUTING.md) to the development of new features and bugfixes for Exponential Platform Legacy.

**Getting started as a contributor:**

1. **Fork** the repository on GitHub: [github.com/se7enxweb/exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy)
2. **Clone** your fork and create a feature branch: `git checkout -b feature/my-improvement`
3. **Install** the full dev stack per [INSTALL.md](INSTALL.md) (`APP_ENV=dev`)
4. **Make** your changes — follow coding standards in [CONTRIBUTING.md](CONTRIBUTING.md)
5. **Test** with `php bin/phpunit` and verify no regressions
6. **Push** your branch and open a **Pull Request** against the `3.x` branch
7. **Participate** in the review — maintainers will give feedback promptly

Bug reports, feature requests, and discussion are all welcome via the [issue tracker](https://github.com/se7enxweb/exponential-platform-legacy/issues) and [GitHub Discussions](https://github.com/se7enxweb/exponential-platform-legacy/discussions).

---

## Donate and Make a Support Subscription

### Help Fund Exponential Platform Legacy!

You can support this project and its community by making a donation of whatever size you feel willing to give to the project.

If we have helped you and you would like to support the project with a subscription of financial support you may. This is what helps us deliver more new features and improvements to the software. Support Exponential Platform Legacy with a subscription today!

A wide range of donation options available at [sponsor.se7enx.com](https://sponsor.se7enx.com), [paypal.com/paypalme/7xweb](https://www.paypal.com/paypalme/7xweb) and [github.com/sponsors/se7enxweb](https://github.com/sponsors/se7enxweb)

Every contribution — from a one-time thank-you donation to an ongoing support subscription — goes directly toward:
- Maintaining PHP compatibility as new versions release
- Patching the Exponential (Legacy) kernel for PHP 8.x and beyond
- Writing documentation and tutorials
- Running the community infrastructure (forums, chat, docs portal)
- Triaging and fixing security vulnerabilities
- Funding new features voted on by the community

---

## COPYRIGHT
Copyright (C) 1998 - 2026 7x. All rights reserved.

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

---

*Copyright &copy; 1998 – 2026 7x (se7enx.com). All rights reserved unless otherwise noted.*  
*Exponential Platform Legacy is Open Source software released under the GNU GPL v2 or any later version.*
