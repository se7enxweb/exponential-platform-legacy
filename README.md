# Exponential Platform Legacy 1.1.0.x aka (Platform v3)

[![PHP](https://img.shields.io/badge/PHP-8.0%20→%208.4-8892BF?logo=php&logoColor=white)](https://php.net)
[![Symfony](https://img.shields.io/badge/Symfony-5.4%20LTS-000000?logo=symfony&logoColor=white)](https://symfony.com)
[![eZ Platform](https://img.shields.io/badge/eZ%20Platform-3.3%20OSS-orange)](https://github.com/ezsystems)
[![LegacyBridge](https://img.shields.io/badge/LegacyBridge-3.x-green)](https://github.com/se7enxweb/legacy-bridge)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/gpl-2.0)
[![GitHub issues](https://img.shields.io/github/issues/se7enxweb/exponential-platform-legacy)](https://github.com/se7enxweb/exponential-platform-legacy/issues)
[![GitHub stars](https://img.shields.io/github/stars/se7enxweb/exponential-platform-legacy?style=social)](https://github.com/se7enxweb/exponential-platform-legacy)

> **Exponential Platform Legacy** is a hybrid-kernel open-source Digital Experience Platform (DXP/CMS) built on the **eZ Publish Legacy 5.x kernel** bridged to Symfony 5.4 LTS via the eZ LegacyBridge. It is the pure platform release — no Netgen Suite, no nglayouts. It runs the proven eZ Publish Legacy kernel with full PHP 8.x compatibility, sitting alongside the eZ Platform 3.3 new-stack layer in a single application.

---

## Table of Contents

1. [Project Notice](#exponential-platform-legacy-project-notice--20250812)
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
15. [What is eZ Platform?](#what-is-ez-platform)
16. [What is Ibexa DXP OSS?](#what-is-ibexa-dxp-oss)
17. [License](#license)

---

## Exponential Platform Legacy Project Notice : 2025.08.12

"Please Note: This project is not associated with the original eZ Publish software or its original developer, eZ Systems or Ibexa".

> This is an independent, community-driven continuation of the platform. The Exponential Platform Legacy codebase is stewarded and evolved by [7x (se7enx.com)](https://se7enx.com) and the open-source community of developers and integrators who have relied on it for decades.

---

## Exponential Platform Legacy Project Status

**Exponential Platform Legacy has made it beyond it's end of life in 2021 and survived. Current releases are primarily aimed at easing the requirements to support current versions of the PHP language like PHP 8.2, 8.3, 8.4 and beyond php9**

The platform is under active maintenance and targeted improvement. The 1.1.0.x (Platform v3) release line is the current stable series, also known as **Platform v3** — the first release to successfully bridge eZ Publish Legacy 5.x to Symfony 5.4 LTS with full PHP 8.x support. Ongoing work focuses on:

- Continued PHP 8.x compatibility (8.2, 8.3, 8.4 tested and supported)
- eZ Publish Legacy kernel patches for PHP 8.x runtime compatibility
- LegacyBridge maintenance for Symfony 5.4 LTS alignment
- Dependency upgrades across Composer and Yarn package ecosystems
- Security patches and vulnerability triage
- Documentation and developer experience improvements

---

## Who is 7x

[7x](https://se7enx.com) is the North American corporation driving The Continued General Use, Support, Development, Hosting, Design of Exponential Platform Legacy Enterprise Open Source Content Management System in 2025.

7x has been in busines supporting Exponential Platform Website Customers and Projects for over 24 years. 7x took over leadership of the project and it's development, support, adoption and community growth in 2023.

7x represents a serious company leading the open source community based effort to improve Exponential Platform and it's available community resources to help users continue to adopt and use the platform to deliver the very best in web applications websites and headless applications in the cloud.

Previously before 2022, 7x was called Brookins Consulting who was the outspoken leader in the active Exponential Platform Community and it's Portals for the past 24 years.

**7x offers:**
- Commercial support subscriptions for Exponential Platform Legacy deployments
- Hosting on the Exponential Platform cloud infrastructure (`exponential.earth`)
- Custom development, migrations, upgrades, and training
- Community stewardship via [share.exponential.earth](https://share.exponential.earth)

---

## What is Exponential Platform Legacy?

### The Hybrid Kernel Architecture

Exponential Platform Legacy runs **two content kernels in the same request cycle**:

- **Legacy Kernel** — eZ Publish Legacy 5.x — the classic, battle-hardened PHP content engine with its native template system, modules, cronjob framework, roles, workflows, and full content model. This is the primary kernel in this release.
- **New Stack** — eZ Platform 3.3 OSS (Symfony 5.4) — accessed via the LegacyBridge, providing REST API, GraphQL, Symfony controllers, and the eZ Platform Admin UI alongside the legacy admin.

Both kernels share the same database, content repository, and web server entry point. Legacy content is rendered through native eZ Publish Legacy templates (`.tpl`) and Symfony Twig templates simultaneously. The bridge makes incremental migration possible — or simply lets you keep running the proven legacy stack indefinitely.

> **This is the pure platform release — Platform v3.** It does not include the Netgen Suite (no Netgen Layouts, no nglayouts, no ngsite bundle). If you need Netgen Layouts-driven page building on top of this stack, see the Exponential Platform Nexus release which builds on this foundation.

### Recent improvements to Exponential Platform Legacy

Exponential Platform Legacy (the application of interest) delivered to users worldwide by a web server (PHP built-in, Apache, Nginx, lighttpd, Among others).

With PHP we require composer to install Exponential Platform Legacy software and no other software required to run the application. This is an incredible improvement to the kernel (core) of Exponential Platform Legacy.

Exponential Platform Legacy 1.1.0.x (Platform v3) Releases run the **eZ Publish Legacy 5.x kernel + LegacyBridge 3.x + eZ Platform 3.3 OSS + Symfony 5.4 LTS** — providing the classic eZ Publish experience with modern PHP 8.x runtime support. Platform v3 is the foundational release on which the Nexus (Netgen) variant is built.

### What does Exponential Platform Legacy provide for end users building websites?

Exponential Platform Legacy is a professional PHP application framework with advanced CMS (content management system) functionality. As a CMS its most notable feature is its fully customizable and extendable content model. It is also suitable as a platform for general PHP development, allowing you to develop professional Internet applications, fast.

Standard CMS functionality, like news publishing and forums is built in and ready for you to use. Its stand-alone libraries can be used for cross-platform, secure, database independent PHP projects.

Exponential Platform Legacy is database, platform and browser independent. Because it is browser based it can be used and updated from anywhere as long as you have access to the Internet.

(Referred to as `legacy kernel` or `LegacyBridge stack` in eZ Platform 3.x / Ibexa OSS terminology)

---

## Technology Stack

| Layer | Technology |
|---|---|
| **Language** | PHP 8.0 → 8.4 |
| **Framework** | Symfony 5.4 LTS |
| **CMS Core (legacy)** | eZ Publish Legacy 5.x (`ezpublish_legacy/`) |
| **CMS Core (new stack)** | eZ Platform 3.3 OSS (`se7enxweb/oss ~3.3`) |
| **Bridge** | LegacyBridge 3.x (`se7enxweb/legacy-bridge`) |
| **ORM** | Doctrine ORM 2.x |
| **Template Engine** | eZ Publish TPL (legacy) + Twig 3.x (new stack) |
| **Frontend Build** | Webpack Encore + Yarn 1.x + Node.js 18 |
| **Search** | Legacy search (default) · Solr 7.7 / 8.x (optional) |
| **HTTP Cache** | Symfony HttpCache (default) · Varnish 6/7 (optional) |
| **App Cache** | Filesystem (default) · Redis 6+ (optional) |
| **Database** | MySQL 8.0+ · MariaDB 10.3+ · PostgreSQL 14+ |
| **API** | REST API v2 · GraphQL (schema auto-generated) · JWT auth |
| **Admin UI (legacy)** | eZ Publish Legacy Admin (`/ezpublish_legacy/` design) |
| **Admin UI (new stack)** | eZ Platform Admin UI (`/adminui/`) |
| **Dependency Mgmt** | Composer 2.x · Yarn 1.x |

> **Not included in this release:** Netgen Layouts, Netgen Site bundle, nglayouts, ngsite CLI commands.

---

## Requirements

- PHP
- (Optional) Web server. Used to deliver the website to the end user.
- (Required) Database server. Used to store website content (and application information)
- Composer. Used to download Exponential Platform Legacy software packages for installation, also notebly installs the required Zeta Components php libraries.
- Computer to run the PHP website application.

### What version of PHP is required

Exponential Platform Legacy supports PHP 7.4 -> 8.4 please use the latest version of PHP available on your OS.

### Full Requirements Summary

| Requirement | Minimum | Recommended |
|---|---|---|
| PHP | 8.0 | 8.3 or 8.4 |
| Composer | 2.x | latest 2.x |
| Node.js | 18 | 18 LTS (via nvm) |
| Yarn | 1.x | 1.22.x |
| MySQL | 8.0 | 8.0+ (utf8mb4) |
| MariaDB | 10.3 | 10.6+ |
| PostgreSQL | 14 | 16+ |
| Redis | 6.0 | 7.x (optional) |
| Solr | 7.7 | 8.11.x (optional) |
| Varnish | 6.0 | 7.1+ (optional) |
| Apache | 2.4 | 2.4 (event + PHP-FPM) |
| Nginx | 1.18 | 1.24+ |

---

## Quick Start

```bash
# 1. Clone
git clone git@github.com:se7enxweb/exponential-platform-legacy.git
cd exponential-platform-legacy

# 2. Install PHP dependencies
composer install

# 3. Configure environment
cp .env .env.local
# Edit: DATABASE_HOST, DATABASE_NAME, DATABASE_USER, DATABASE_PASSWORD, APP_SECRET, APP_ENV

# 4. Create database and import demo data
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
php bin/console ezplatform:install ibexa-oss

# 5. Set permissions
setfacl -R -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var
setfacl -dR -m u:www-data:rwX -m g:www-data:rwX var public/var ezpublish_legacy/var

# 6. Build frontend assets
nvm use && yarn install && yarn build:dev

# 7. Build Admin UI assets
yarn ez

# 8. Clear all caches (Symfony + Legacy kernel)
php bin/console cache:clear
php bin/console ezpublish:legacy:clear-cache

# 9. Start
symfony server:start
# → https://127.0.0.1:8000                  (site / hybrid-kernel frontend)
# → https://127.0.0.1:8000/adminui/         (eZ Platform Admin UI — admin / publish)
# → https://127.0.0.1:8000/ezpublish_legacy/ (Legacy Admin — admin / publish)
```

> See [doc/INSTALL.md](doc/INSTALL.md) for the complete step-by-step guide with git save-points, server configuration, Solr, Varnish, and production deployment.

---

## Main Exponential Platform Legacy features

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
- Template engine (eZ Publish TPL for legacy + Twig 3.x for new stack)
- A headless CRUD REST API
- Database abstraction layer supporting MySQL, SQLite, Postgres and Oracle
- MVC architecture
- Support for the latest Image and Video File Formats (webp, webm, png, jpeg, etc)
- Support for highly available and scalable configurations (multi-server clusters)
- XML handling and parsing library
- SOAP communication library
- Localisation and internationalisation libraries
- Several other reusable libraries
- SDK (software development kit) and full documentation
- plugin API with thousands of open-source extensions available, including:
    - content rating and commenting
    - advanced search engine
    - wysiwyg rich-text editor
    - in-site content editing
    - content geolocation

### Additional capabilities in the 1.1.0.x (Platform v3) series

- **Hybrid Kernel** — eZ Publish Legacy 5.x runs alongside eZ Platform 3.3 OSS in a single application via LegacyBridge 3.x
- **GraphQL API** — auto-generated schema per content model via `ezplatform:graphql:generate-schema`
- **JWT Authentication** — REST API secured by RSA keypairs (`lexik/jwt-authentication-bundle`)
- **eZ Platform Admin UI** — React-powered editorial interface at `/adminui/` alongside the classic Legacy Admin
- **eZ Publish Legacy Admin** — the original, feature-complete administration interface for legacy content types, modules, and workflows
- **Webpack Encore** — modern asset pipeline with HMR dev server and production minification
- **Design Engine** — `@ezdesign` Twig namespace with theme fallback chain (theme → standard) for clean template inheritance
- **Multi-siteaccess** — run multiple sites, languages, or environments from a single codebase and database
- **Docker / Compose** — `compose.override.yaml` and `doc/docker/` for containerised development environments
- **Deployer** — `deploy.php` + `deploy/` for zero-downtime production deployments via PHP Deployer

---

## Installation

Read [doc/INSTALL.md](doc/INSTALL.md) or go to [exponential.doc.exponential.one/display/DEVELOPER/Step%2b1_%2bInstallation.html](https://exponential.doc.exponential.earth/display/DEVELOPER/Step%2b1_%2bInstallation.html)

The installation guide covers:
- First-time install (git clone or `composer create-project`)
- Environment configuration (`.env.local` reference)
- Database creation and demo data import
- Web server setup (Apache 2.4, Nginx, Symfony CLI)
- File & directory permissions (including `ezpublish_legacy/var/`)
- Frontend asset build (Webpack Encore / Yarn)
- Admin UI asset build
- Search index initialisation
- Cache management (Symfony cache + Legacy kernel cache)
- Day-to-day operations (start / stop / restart / deploy)
- Cron job setup (eZ Platform cron + Legacy cron runner)
- Solr search engine integration
- Varnish HTTP cache integration
- Troubleshooting

---

## Key CLI Commands Reference

A quick reference for the most frequently used Symfony, eZ Platform, and eZ Publish Legacy console commands. For full documentation see [doc/INSTALL.md](doc/INSTALL.md).

### Symfony Core

```bash
php bin/console list                                # list all registered commands
php bin/console help <command>                      # help for a specific command
php bin/console cache:clear                         # clear application cache
php bin/console cache:clear --env=prod              # clear production cache
php bin/console cache:warmup --env=prod             # warm up prod cache after deploy
php bin/console cache:pool:clear cache.redis        # clear a specific cache pool
php bin/console debug:router                        # list all routes
php bin/console debug:container                     # list all service IDs
php bin/console debug:config <bundle>               # dump resolved bundle config
php bin/console debug:event-dispatcher              # list all event listeners
php bin/console assets:install --symlink --relative public   # publish bundle public/ assets
php bin/console messenger:consume                   # consume async message queue
```

### Doctrine / Migrations

```bash
php bin/console doctrine:migration:migrate --allow-no-migration   # run pending migrations
php bin/console doctrine:migration:status                          # show migration status
php bin/console doctrine:migration:diff                            # generate a new migration
php bin/console doctrine:schema:validate                           # validate entity mappings
```

### eZ Platform / Ibexa OSS (new stack)

```bash
php bin/console ezplatform:install ibexa-oss        # fresh install with demo data (options: clean, ibexa-oss)
php bin/console ezplatform:reindex                  # rebuild search index (full)
php bin/console ezplatform:reindex --iteration-count=50   # incremental reindex
php bin/console ezplatform:cron:run                 # run the eZ Platform cron scheduler
php bin/console ezplatform:graphql:generate-schema  # regenerate GraphQL schema
php bin/console ezplatform:solr:create-core --cores=default   # set up Solr core
php bin/console bazinga:js-translation:dump public/assets --merge-domains  # JS i18n
php bin/console fos:httpcache:invalidate:path / --all   # purge HTTP cache paths
php bin/console lexik:jwt:generate-keypair          # generate RSA keypair for REST API auth
```

### eZ Publish Legacy kernel (LegacyBridge)

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

# Legacy console (eZ Publish CLI — direct access to legacy internals)
php ezpublish_legacy/bin/php/ezcli.php <command>
```

### Legacy Admin & Site Modes

| URL | Purpose |
|---|---|
| `/adminui/` | eZ Platform Admin UI (new stack, React) |
| `/ezpublish_legacy/index.php` | Legacy Admin interface (classic eZ Publish) |
| `/` | Public site (hybrid-kernel Twig + Legacy TPL) |
| `/api/ezp/v2/` | REST API v2 |

### Frontend / Asset Build (Yarn / Webpack)

```bash
nvm use                       # activate Node.js 18 (reads .nvmrc)
yarn install                  # install / update Node dependencies
yarn build:dev                # build site assets with source maps
yarn build:prod               # build site assets minified for production
yarn watch                    # watch mode — auto-rebuild on change
yarn start                    # dev server with HMR
yarn ez                       # build Admin UI assets (webpack.config.ez.js)
```

### Makefile Shortcuts

Run `make` or `make help` to list all available targets.

```bash
# ── Discovery ──────────────────────────────────────────────────────────────
make help                     # list all available make targets
make php-version              # print the PHP version required by the project

# ── Full builds ────────────────────────────────────────────────────────────
make build                    # vendor + migrations + reindex + assets + cache (dev)
APP_ENV=prod make build       # production equivalent of make build
make refresh                  # git pull --rebase + full rebuild (dev)
APP_ENV=prod make refresh     # production equivalent of make refresh

# ── Dependencies ───────────────────────────────────────────────────────────
make vendor                   # composer install (--no-dev -o in prod)

# ── Assets ─────────────────────────────────────────────────────────────────
make assets                   # build site frontend assets (dev)
make assets-prod              # build site frontend assets (prod, minified)
make assets-watch             # watch mode — auto-rebuild on change
make ibexa-assets             # build eZ Platform Admin UI assets

# ── Cache ──────────────────────────────────────────────────────────────────
make clear-cache              # cache:clear (default: APP_ENV=dev)
make clear-all-cache          # cache:clear + pool:clear (incl. Redis)

# ── Database / Search ──────────────────────────────────────────────────────
make migrations               # doctrine:migration:migrate --allow-no-migration
make reindex                  # ezplatform:reindex (full search reindex)

# ── Content ────────────────────────────────────────────────────────────────
make images                   # generate image variations (i30, i160, i320…)
make graphql-schema           # ezplatform:graphql:generate-schema

# ── Code update ────────────────────────────────────────────────────────────
make update-code              # git stash → pull --rebase → stash pop
```

### Symfony CLI Dev Server

```bash
symfony server:start          # start HTTPS dev server (https://127.0.0.1:8000)
symfony server:start -d       # start in background
symfony server:stop           # stop background server
symfony server:log            # tail server log
```

---

## Issue tracker

Submitting bugs, improvements and stories is possible on [https://github.com/se7enxweb/exponential-platfom-legacy/issues](https://github.com/se7enxweb/exponential-platfom-legacy/issues)

If you discover a [security issue](SECURITY.md), please responsibly report such issues via email to security@exponential.one

---

## Where to get more help

Exponential Platform documentation: [exponential.doc.exponential.one/display/DEVELOPER/Docuemntation.html](https://exponential.doc.exponential.earth/display/DEVELOPER/Documentation.html)

Exponential Platform Community forums: [share.exponential.one/forums](https://share.exponential.one/forums) and [share.exponential.one/forums/exponential-platform](https://share.se7enx.com/forums/exponential-platform)

Exponential Platform Legacy Project Website: [exponential.one](https://platform.exponential.one)

Support Exponential Platform! Project extension support Website: [support.exponential.earth](https://support.exponential.earth)

Share Exponential! Telegram Community Support Chat
[https://t.me/exponentialcms](https://t.me/exponentialcms)

| Resource | URL |
|---|---|
| Platform Website | [platform.exponential.earth](https://platform.exponential.earth) |
| Documentation Hub | [doc.exponential.earth](https://doc.exponential.earth) |
| x.Doc (legacy docs) | [exponential.doc.exponential.earth](https://exponential.doc.exponential.earth) |
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

## How to contribute new features and bugfixes into Exponential Platform Legacy

Everyone is encouraged to [contribute](CONTRIBUTING.md) to the development of new features and bugfixes for Exponential Platform Legacy.

**Getting started as a contributor:**

1. **Fork** the repository on GitHub: [github.com/se7enxweb/exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy)
2. **Clone** your fork and create a feature branch: `git checkout -b feature/my-improvement`
3. **Install** the full dev stack per [doc/INSTALL.md](doc/INSTALL.md) (`APP_ENV=dev`)
4. **Make** your changes — follow coding standards in [CONTRIBUTING.md](CONTRIBUTING.md)
5. **Test** with `php bin/phpunit` and verify no regressions
6. **Push** your branch and open a **Pull Request** against the `1.1.0.x` branch
7. **Participate** in the review — maintainers will give feedback promptly

Bug reports, feature requests, and discussion are all welcome via the [issue tracker](https://github.com/se7enxweb/exponential-platform-legacy/issues) and [GitHub Discussions](https://github.com/se7enxweb/exponential-platform-legacy/discussions).

---

## Donate and make a support subscription.
## Help fund Exponential Platform Legacy!

You can support this project and it's community by making a donation of what ever size donation you feel willing to give to the project.

If we have helped you and you would like to support the project with a subscription of financial support you may. This is what helps us deliver more new features and improvements to the software. Support Exponential Platform Legacy with a subscription today!

A wide range of donation options avaialble at [sponsor.se7enx.com](https://sponsor.se7enx.com), [paypal.com/paypalme/7xweb](https://www.paypal.com/paypalme/7xweb) and [github.com/sponsors/se7enxweb](https://github.com/sponsors/se7enxweb)

Every contribution — from a one-time thank-you donation to an ongoing support subscription — goes directly toward:
- Maintaining PHP compatibility as new versions release
- Patching the eZ Publish Legacy kernel for PHP 8.x and beyond
- Writing documentation and tutorials
- Running the community infrastructure (forums, chat, docs portal)
- Triaging and fixing security vulnerabilities
- Funding new features voted on by the community

---

## What is eZ Platform?

Exponential Platform is based on the successfull product, eZ Platform, is a highly extensible, pure Content Managment Platform built upon the ideals core to Symfony. It provides the same flexible content model at it's core like Exponential Platform, and has a growing amount of additional features outside the traditional CMS scope provided by means of "Bundles" extending it.

It is built on top of the full Symfony Framework, giving developers access to "standard" tools for rapid web & application development.

eZ Platform in some users view suffered a slow road to a stable datatype compatability with existing custom implementations of Exponential Platform. Today all of these conserns are now gone with a solid choice left leaving both Exponential Platform and eZ Platform as serious contenders to be carefully considered. [Netgen's Media Website Core software](https://github.com/netgen/media-site) represents a much more modern eZ Platform core powered by Ibexa OSS. If your going to choose; Choose wisely.

Further reading on: [https://ezplatform.com/](http://web.archive.org/web/20200328165348/https://ezplatform.com/)

---

## What is Ibexa DXP OSS?

Ibexa DXP OSS, the rebranded and evolved successor of eZ Platform, is a modern and highly extensible Digital Experience Platform built on the robust Symfony framework. Staying true to the foundational principles of Exponential Platform, it retains the flexible content model at its core while expanding its capabilities to include a broad spectrum of features that go beyond traditional CMS functionality. These features are delivered through "Bundles," providing developers with powerful tools for creating advanced web and digital solutions.

Built on top of Symfony, Ibexa DXP OSS offers developers access to standardized tools for efficient and scalable web and application development. Its architecture supports rapid innovation while ensuring compatibility with modern development standards.

Ibexa DXP OSS has matured into a robust and versatile platform, serving as a serious option for organizations seeking a cutting-edge CMS solution. For those looking to build modern web experiences, tools like Netgen's Media Website Core further enhance Ibexa OSS, showcasing its potential as a flexible and future-ready platform.

If you're making a choice, choose with care—and consider the power and flexibility of Ibexa DXP OSS.

Further reading: [ibexa.co](https://ibexa.co/)

Documentation for Ibexa DXP: [doc.ibexa.co/en/latest/](https://doc.ibexa.co/en/latest/)

Ibexa DXP Developer Portal: [developers.ibexa.co](https://developers.ibexa.co/)

---

## License

Exponential Platform Legacy is GNU GPL licensed.

You can choose between the GNU GPL and the Ibexa Professional License. The GNU GPL gives you the right to use, modify and redistribute Exponential Platform Legacy under certain conditions. The GNU GPL license is distributed with the software, see the file LICENSE. It is also available at http://www.gnu.org/licenses/gpl.txt

Using Exponential Platform Legacy under the terms of the GNU GPL is free of charge.

---

*Copyright &copy; 1998 – 2026 7x (Brookins Consulting / se7enx.com). All rights reserved unless otherwise noted.*  
*Exponential Platform Legacy is Open Source software released under the GNU GPL v2 or any later version.*
