# Exponential Platform Legacy 2.5.0.x (Stable; Open Source; Starter Skeleton)

[![PHP](https://img.shields.io/badge/PHP-7.1.3%20→%208.2-8892BF?logo=php&logoColor=white)](https://php.net)
[![Symfony](https://img.shields.io/badge/Symfony-3.4%20LTS-000000?logo=symfony&logoColor=white)](https://symfony.com)
[![Platform](https://img.shields.io/badge/Platform-2.5%20OSS-orange)](https://github.com/se7enxweb)
[![LegacyBridge](https://img.shields.io/badge/LegacyBridge-2.x-green)](https://github.com/se7enxweb/legacy-bridge)
[![License: GPL v2 (or any later version)](https://img.shields.io/badge/License-GPL%20v2%20(or%20any%20later%20version)-blue.svg)](https://www.gnu.org/licenses/gpl-2.0)
[![GitHub issues](https://img.shields.io/github/issues/se7enxweb/exponential-platform-legacy)](https://github.com/se7enxweb/exponential-platform-legacy/issues)
[![GitHub stars](https://img.shields.io/github/stars/se7enxweb/exponential-platform-legacy?style=social)](https://github.com/se7enxweb/exponential-platform-legacy)

> **Exponential Platform Legacy** is a hybrid-kernel open-source Digital Experience Platform (DXP/CMS) built on the **Exponential (Legacy) 6.x kernel** bridged to Symfony 3.4 LTS via LegacyBridge 2.x. This is the **2.5.0.x** skeleton release — pairing the proven Legacy kernel with the eZ Platform 2.5 new stack, with PHP 7.1.3 through 8.2 compatibility running in a single application.

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

> "Please Note: This project is not associated with the original eZ Publish software or its original developer, eZ Systems or Ibexa."

This is an independent, 7x + community-driven continuation of the platform. The Exponential Platform Legacy codebase is stewarded and evolved by [7x (se7enx.com)](https://se7enx.com) and the open-source community of developers and integrators who have relied on it for decades.

---

## Exponential Platform Legacy Project Status

**Exponential Platform Legacy has made it beyond its end of life in 2021 and survived. Current releases are primarily aimed at easing the requirements to support current versions of the PHP language like PHP 8.1, 8.2, and beyond.**

The platform is under active maintenance and targeted improvement. The **2.5.0.x** release line is based on the eZ Platform 2.5 kernel (`se7enxweb/ezpublish-kernel ~7.5.33`) bridged to Symfony 3.4 LTS via LegacyBridge 2.x. Ongoing work focuses on:

- Continued PHP 8.x compatibility (8.1 and 8.2 tested and supported)
- Exponential (Legacy) kernel patches for PHP 8.x runtime compatibility
- LegacyBridge 2.x compatibility maintenance for Symfony 3.4 LTS alignment
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
- **New Stack** — eZ Platform 2.5 (Symfony 3.4 LTS) — accessed via LegacyBridge 2.x, providing REST API v2, GraphQL, Symfony controllers, and the Platform 2.5 Admin UI alongside the legacy admin.

Both kernels share the same database, content repository, and web server entry point. Legacy content is rendered through native Exponential (Legacy) templates (`.tpl`) and Symfony Twig templates simultaneously. The bridge makes incremental migration possible — or simply lets you keep running the proven legacy stack indefinitely.

> **This is the 2.5.0.x LegacyBridge release** — using LegacyBridge 2.x for Symfony 3.4 LTS compatibility. For the latest Symfony 5.4 LTS + Netgen Layouts experience, see the 4.6.x release.

### What Does Exponential Platform Legacy Provide for End Users Building Websites?

Exponential Platform Legacy is a professional PHP application framework with advanced CMS (content management system) functionality. As a CMS, its most notable feature is its fully customizable and extendable content model. It is also suitable as a platform for general PHP development, allowing you to develop professional Internet applications, fast.

Standard CMS functionality, like news publishing and forums, is built in and ready for you to use. Its stand-alone libraries can be used for cross-platform, secure, database independent PHP projects.

Exponential Platform Legacy is database, platform and browser independent. Because it is browser based it can be used and updated from anywhere as long as you have access to the Internet.

---

## Technology Stack

| Layer | Technology |
|---|---|
| **Language** | PHP 7.1.3 → 8.2 |
| **Framework** | Symfony 3.4 LTS |
| **CMS Core (legacy)** | Exponential (Legacy) 6.x (`ezpublish_legacy/`) |
| **CMS Core (new stack)** | eZ Platform 2.5 (`se7enxweb/ezpublish-kernel ~7.5.33`) |
| **Bridge** | LegacyBridge 2.x (`se7enxweb/legacy-bridge`) |
| **ORM** | Doctrine ORM 2.x |
| **Template Engine** | Legacy TPL (legacy kernel) + Twig 2.x (new stack) |
| **Frontend Build** | Webpack Encore 1.8.2 + Yarn 1.x + Node.js 14 LTS |
| **Search** | Legacy search (default) · Solr 6.x / 7.x (optional) |
| **HTTP Cache** | Symfony HttpCache (default) · Varnish 5/6 (optional) |
| **App Cache** | Filesystem (default) · Redis 4+ (optional) |
| **Database** | MySQL 5.7+ · MariaDB 10.0+ · PostgreSQL 9.5+ |
| **API** | REST API v2 · GraphQL ^1.0 |
| **Admin UI (legacy)** | Exponential (Legacy) Admin (`/ezpublish_legacy/`) |
| **Admin UI (new stack)** | eZ Platform 2.5 Admin UI (`/admin/`) |
| **Dependency Mgmt** | Composer 2.x · Yarn 1.x |

---

## Requirements

- PHP 7.1.3+ or 8.1 / 8.2 (8.2 recommended)
- A web server: Apache 2.4 or Nginx 1.18+
- A database server: MySQL 5.7+, MariaDB 10.0+, or PostgreSQL 9.5+
- Composer 2.x
- Node.js 14 LTS (via nvm recommended)
- Yarn 1.22.x

### Full Requirements Summary

| Requirement | Minimum | Recommended |
|---|---|---|
| PHP | 7.1.3 | 8.2 |
| Composer | 2.x | latest 2.x |
| Node.js | 12 | 14 LTS (via nvm) |
| Yarn | 1.x | 1.22.x |
| MySQL | 5.7 | 8.0+ (utf8mb4) |
| MariaDB | 10.0 | 10.6+ |
| PostgreSQL | 9.5 | 14+ |
| Redis | 4.0 | 6.x (optional) |
| Solr | 6.x | 7.7.x (optional) |
| Varnish | 5.0 | 6.x (optional) |
| Apache | 2.4 | 2.4 (event + PHP-FPM) |
| Nginx | 1.18 | 1.24+ |

---

## Quick Start

```bash
# 1. Create project
composer create-project se7enxweb/exponential-platform-legacy:2.5.0.x-dev exponential_website
cd exponential_website

# 2. Configure environment
cp app/config/parameters.yml.dist app/config/parameters.yml
# Edit app/config/parameters.yml: set database_host, database_name, database_user,
#   database_password, and secret (generate: php -r "echo bin2hex(random_bytes(32));")

# 3. Create database
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"

# 4. Install Platform database content
php bin/console ezplatform:install clean

# 5. Set permissions
setfacl -R -m u:www-data:rwX -m g:www-data:rwX var web/var ezpublish_legacy/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var web/var ezpublish_legacy/var

# 6. Install legacy bundle assets and generate autoloads
php bin/console assets:install --symlink --relative web
php bin/console ezpublish:legacybundles:install_extensions
php bin/console ezpublish:legacy:generate-autoloads

# 7. Build frontend assets
nvm use 14 && yarn install && yarn encore production

# 8. Dump JS translations and assetic assets
php bin/console bazinga:js-translation:dump web/assets --merge-domains
php bin/console assetic:dump

# 9. Clear all caches (Symfony + Legacy kernel)
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache

# 10. Start
symfony server:start
# → http://127.0.0.1:8000                    (site / hybrid-kernel frontend)
# → http://127.0.0.1:8000/admin/             (eZ Platform 2.5 Admin UI — admin / publish)
# → http://127.0.0.1:8000/ezpublish_legacy/  (Legacy Admin — admin / publish)
```

> See [doc/INSTALL.md](doc/INSTALL.md) for the complete step-by-step guide with server configuration, Solr, Varnish, and production deployment.

---

## Main Exponential Platform Legacy Features

- User defined content classes and objects
- Version control
- Advanced multi-lingual support
- Built-in search engine
- Separation of content and presentation layer
- Fine-grained role-based permissions system
- Content approval and scheduled publication
- Multi-site support
- Multimedia support with automatic image conversion and scaling
- RSS feeds
- Contact forms
- Built-in webshop
- Flexible workflow management system
- Full support for Unicode
- Template engine (Legacy TPL for legacy kernel + Twig 2.x for new stack)
- A headless CRUD REST API v2
- Database abstraction layer supporting MySQL, MariaDB, PostgreSQL, and Oracle
- MVC architecture
- Support for the latest image and video file formats (webp, webm, png, jpeg, etc.)
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

---

## Installation

Create a new project using Composer:

```bash
composer create-project se7enxweb/exponential-platform-legacy:2.5.0.x-dev exponential_website
```

The installation guide covers environment configuration, database setup, web server configuration, asset builds, legacy bundle setup, search indexing, cron jobs, Solr, Varnish, and production deployment.

See **[doc/INSTALL.md](doc/INSTALL.md)** for the complete step-by-step guide.

---

## Key CLI Commands Reference

### Symfony Core

```bash
php bin/console list                                         # list all registered commands
php bin/console help <command>                               # help for a specific command
php bin/console cache:clear                                  # clear application cache
php bin/console cache:clear --env=prod                       # clear production cache
php bin/console cache:warmup --env=prod                      # warm up prod cache after deploy
php bin/console debug:router                                 # list all routes
php bin/console debug:container                              # list all service IDs
php bin/console debug:config <bundle>                        # dump resolved bundle config
php bin/console assets:install --symlink --relative web      # publish bundle assets into web/
```

### Doctrine / Migrations

```bash
php bin/console doctrine:migration:migrate --allow-no-migration   # run pending migrations
php bin/console doctrine:migration:status                          # show migration status
php bin/console doctrine:migration:diff                            # generate a new migration
php bin/console doctrine:schema:validate                           # validate entity mappings
```

### eZ Platform 2.5 (new stack)

```bash
php bin/console ezplatform:install clean                     # fresh install (no demo content)
php bin/console ezplatform:reindex                           # rebuild search index (full)
php bin/console ezplatform:reindex --iteration-count=50      # incremental reindex
php bin/console ezplatform:cron:run                          # run the Platform cron scheduler
php bin/console ezplatform:graphql:generate-schema           # regenerate GraphQL schema
php bin/console bazinga:js-translation:dump web/assets --merge-domains   # JS i18n
php bin/console fos:httpcache:invalidate:path / --all        # purge HTTP cache paths
php bin/console assetic:dump                                 # dump assetic assets
```

### Exponential (Legacy) Kernel (LegacyBridge)

```bash
# Clear legacy kernel caches (template / ini / content / override)
php bin/console ezpublish:legacy:clear-cache

# Install assets from Symfony bundles into ezpublish_legacy extensions
php bin/console ezpublish:legacybundles:install_extensions

# Regenerate legacy autoload arrays (required after adding/removing extensions)
php bin/console ezpublish:legacy:generate-autoloads

# Run legacy cronjobs (use in crontab targeting legacy_admin siteaccess)
php ezpublish_legacy/runcronjobs.php --siteaccess legacy_admin

# Legacy console (direct access to legacy internals)
php ezpublish_legacy/bin/php/ezcli.php <command>
```

### Admin & Site URLs

| URL | Purpose |
|---|---|
| `/admin/` | eZ Platform 2.5 Admin UI (new stack) |
| `/ezpublish_legacy/` | Legacy Admin interface (classic) |
| `/` | Public site (hybrid-kernel Twig + Legacy TPL) |
| `/api/ezp/v2/` | REST API v2 |
| `/graphql` | GraphQL endpoint |

### Frontend / Asset Build (Yarn / Webpack Encore)

Activate Node.js 14 LTS via nvm before running any Yarn commands:

```bash
nvm use 14              # activate Node.js 14 LTS (required)
```

```bash
yarn install              # install / update Node dependencies
yarn encore dev           # build all assets with source maps — dev mode
yarn encore production    # build all assets minified for production
yarn encore dev-server    # watch mode — auto-rebuild on change with HMR
```

---

## Issue Tracker

Submitting bugs, improvements and stories is possible on
[https://github.com/se7enxweb/exponential-platform-legacy/issues](https://github.com/se7enxweb/exponential-platform-legacy/issues)

If you discover a security issue, please responsibly report it via email to security@exponential.one

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

1. **Fork** the repository on GitHub: [github.com/se7enxweb/exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy)
2. **Clone** your fork and create a feature branch: `git checkout -b feature/my-improvement`
3. **Install** the full dev stack per [doc/INSTALL.md](doc/INSTALL.md) (`APP_ENV=dev`)
4. **Make** your changes — follow coding standards in [CONTRIBUTING.md](CONTRIBUTING.md)
5. **Test** with `php bin/phpunit` and verify no regressions
6. **Push** your branch and open a **Pull Request** against the `master` branch
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

Copyright (C) 1999-2020 Ibexa AS (formerly eZ Systems AS). All rights reserved.

## LICENSE

This source code is available separately under the following license:

GNU General Public License, version 2.
Grants a copyleft open source license with ABSOLUTELY NO WARRANTY. For the full GPL license text, please see:
https://www.gnu.org/licenses/old-licenses/gpl-2.0.html

---

*Copyright &copy; 1998 – 2026 7x (se7enx.com). All rights reserved unless otherwise noted.*  
*Exponential Platform Legacy is Open Source software released under the GNU GPL v2 or any later version.*
