# Exponential Platform Legacy v5 — Full Legacy Bridge (Stable; Open Source; Starter Skeleton)

[![PHP](https://img.shields.io/badge/PHP-8.3%2B-8892BF?logo=php&logoColor=white)](https://php.net)
[![Symfony](https://img.shields.io/badge/Symfony-7.4%20LTS-000000?logo=symfony&logoColor=white)](https://symfony.com)
[![Platform](https://img.shields.io/badge/Platform-5.0%20OSS-orange)](https://github.com/se7enxweb)
[![License: GPL v2 (or any later version)](https://img.shields.io/badge/License-GPL%20v2%20(or%20any%20later%20version)-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
[![GitHub issues](https://img.shields.io/github/issues/se7enxweb/exponential-platform-legacy)](https://github.com/se7enxweb/exponential-platform-legacy/issues)
[![GitHub stars](https://img.shields.io/github/stars/se7enxweb/exponential-platform-legacy?style=social)](https://github.com/se7enxweb/exponential-platform-legacy)

> **Exponential Platform Legacy** is an open-source Digital Experience Platform (DXP/CMS) built on **Symfony 7.4 LTS** with **PHP 8.3+** — and ships with the **full Legacy Bridge enabled by default**, giving you the complete classic eZ Publish legacy kernel, legacy admin interface, and all legacy siteaccesses running live out of the box inside a modern Symfony 7.4 LTS application.

This is the **DXP v5 Starter Skeleton** with **full Legacy Bridge support by default** — the recommended starting point for all new Exponential Platform Legacy v5 projects. The Legacy Bridge provides a complete, production-quality classic legacy kernel running in parallel with the modern Platform v5 OSS stack, with no friction between the two.

---

## Table of Contents

1. [Project Notice](#exponential-platform-legacy-project-notice)
2. [Project Status](#exponential-platform-legacy-project-status)
3. [Who is 7x](#who-is-7x)
4. [What is Exponential Platform Legacy?](#what-is-exponential-platform-legacy)
5. [Legacy Bridge — Architecture & Default Siteaccess URLs](#legacy-bridge--architecture--default-siteaccess-urls)
6. [Technology Stack](#technology-stack)
7. [Requirements](#requirements)
8. [Quick Start](#quick-start)
9. [Main Features](#main-exponential-platform-legacy-features)
10. [Installation](#installation)
11. [Key CLI Commands Reference](#key-cli-commands-reference)
12. [Issue Tracker](#issue-tracker)
13. [Where to Get More Help](#where-to-get-more-help)
14. [How to Contribute](#how-to-contribute-new-features-and-bugfixes-into-exponential-platform-legacy)
15. [Donate & Support](#donate-and-make-a-support-subscription)
16. [Copyright](#copyright)
17. [License](#license)

---

## Exponential Platform Legacy Project Notice

> "Please Note: This project is not associated with the original eZ Publish software or its original developer, eZ Systems."

This is an independent, 7x + community-driven continuation of the platform. The Exponential Platform Legacy codebase is stewarded and evolved by [7x (se7enx.com)](https://se7enx.com) and the open-source community of developers and integrators who have relied on it for decades.

---

## Exponential Platform Legacy Project Status

**Exponential Platform Legacy has made it beyond its end of life in 2021 and survived. The Platform v5 (5.0.x) release line is the new-stack, forward thinking release targeting Symfony 7.4 LTS and PHP 8.3+.**

The platform is under active development and targeted improvement. The **5.0.x (Platform v5)** release series is the current active development branch. This is the pure single-kernel release and the first major version series to run exclusively on Symfony 7.4 LTS with full PHP 8.3+ support. Ongoing work focuses on:

- Symfony 7.4 LTS new-stack kernel development and stabilisation
- PHP 8.3 and 8.5 full compatibility and testing
- REST API v2, GraphQL, and JWT authentication on Symfony 7.4 LTS
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

### The Platform v5 Dual-Kernel Architecture (Legacy Bridge)

Exponential Platform Legacy v5 runs two complementary content kernels in a single Symfony application:

- **New Stack — Exponential Platform v5 OSS (Symfony 7.4 LTS)** — the full Platform v5 content engine providing REST API v2, GraphQL, Symfony controllers, the Platform v5 Admin UI, and first-class Twig template rendering for the `site` siteaccess.
- **Legacy Kernel — via Legacy Bridge (`se7enxweb/legacy-bridge`)** — the classic eZ Publish legacy kernel running inside Symfony, served through the `legacy_site` and `legacy_admin` siteaccesses. The legacy kernel uses its own template engine (eZ Publish templates), its own routing (eZ Publish URI-based system module routing), its own admin interface, and the full library of legacy extensions you already have. It is live, fully functional, and reachable at dedicated URI-prefix siteaccesses out of the box.

The Legacy Bridge is what makes this skeleton uniquely valuable for teams running (or migrating) long-established eZ Publish-based sites: you get the full modern Symfony 7.4 LTS HTTPS stack, REST API, GraphQL, Platform v5 Admin UI, and Twig front-end — all running alongside a fully working legacy kernel with your existing legacy designs, templates, extensions, and content URLs. No legacy functionality is lost.

### Recent Improvements to Exponential Platform Legacy

Exponential Platform Legacy v5 (5.0.x) releases run the Exponential Platform v5 OSS new-stack kernel on **Symfony 7.4 LTS** with **PHP 8.3+** — while simultaneously shipping the full **Legacy Bridge by default**, making this the most capable single-project starting point available for the platform. Key improvements in recent releases include:

- Symfony 7.4 LTS new-stack kernel with Legacy Bridge on PHP 8.3+
- `QueryTranslator*` database driver family — MySQL/MariaDB, PostgreSQL, and SQLite all supported in legacy kernel via a clean extension (`sevenx_exponential_platform_v5_database_translator`) installed by default
- Full multi-database support in the legacy kernel: run on MySQL 8.0, MariaDB 10.6, PostgreSQL 14+, or SQLite 3.35+ (dev/testing)
- PHP 8.3 and 8.5 full compatibility and testing across both kernels
- REST API v2, GraphQL, and JWT authentication on the Platform v5 new stack
- Dependency upgrades across Composer and Yarn package ecosystems
- Security patches and vulnerability triage

### What Does Exponential Platform Legacy Provide for End Users Building Websites?

Exponential Platform Legacy is a professional PHP application framework with advanced CMS (content management system) functionality. As a CMS, its most notable feature is its fully customizable and extendable content model. It is also suitable as a platform for general PHP development, allowing you to develop professional Internet applications, fast.

Standard CMS functionality, like news publishing and content management, is built in and ready for you to use. Its stand-alone libraries can be used for cross-platform, secure, database independent PHP projects.

Exponential Platform Legacy is database, platform and browser independent. Because it is browser based it can be used and updated from anywhere as long as you have access to the Internet.

---

## Legacy Bridge — Architecture & Default Siteaccess URLs

The Legacy Bridge is the centrepiece of this project. It is installed, configured, and running **by default** when you create a project from this skeleton. No post-install steps are required to activate it — the legacy kernel boots automatically for all requests to the `legacy_site` and `legacy_admin` siteaccesses.

### Dual-Kernel Architecture at a Glance

```
Browser Request
      │
      ▼
   Web Server (Apache / Nginx)
      │
      ▼
  public/index.php  ──  Symfony Kernel (Platform v5 OSS — Symfony 7.4 LTS)
      │
      ├── URI: /adminui/**           → Platform v5 Admin UI (React)       ← siteaccess: admin
      ├── URI: /api/ezp/v2/**        → REST API v2                         ← siteaccess: admin
      ├── URI: /graphql              → GraphQL API                         ← siteaccess: admin
      │
      ├── URI: /legacy_admin/**      → Legacy Bridge → Legacy Kernel       ← siteaccess: legacy_admin
      │                                  Legacy Admin Interface (full UI)
      │
      ├── URI: /legacy_site/**       → Legacy Bridge → Legacy Kernel       ← siteaccess: legacy_site
      │                                  Classic eZ Publish Front End
      │
      └── URI: /**                   → Platform v5 Twig Front End          ← siteaccess: site
                                         Symfony controllers + Twig templates
```

The Legacy Bridge (`se7enxweb/legacy-bridge`) is the package that boots the classic eZ Publish legacy kernel inside Symfony. The legacy kernel handles all requests routed to `legacy_site` and `legacy_admin` siteaccesses using standard eZ Publish URI-based module/view routing.

### Default Legacy Siteaccess URLs

All of the following URLs work out of the box after a fresh install with no additional configuration.

> Replace `http://localhost` with your actual domain or Symfony CLI dev server address (e.g. `https://127.0.0.1:8000`).

#### Platform v5 Admin UI & API

| URL | Description |
|---|---|
| `http://localhost/adminui/` | **Platform v5 Admin UI** — React editorial interface (admin / publish) |
| `http://localhost/api/ezp/v2/` | **REST API v2** — full content API (JWT-authenticated) |
| `http://localhost/graphql` | **GraphQL** — auto-generated content schema |
| `http://localhost/graphql/explorer` | GraphiQL browser explorer (APP_ENV=dev only) |

#### Legacy Site Frontend (`/legacy_site/`)

| URL | Description |
|---|---|
| `http://localhost/legacy_site/` | Legacy site home page (default siteaccess) |
| `http://localhost/legacy_site/user/login` | Legacy login form |
| `http://localhost/legacy_site/user/logout` | Log out of legacy session |
| `http://localhost/legacy_site/user/register` | New user registration |
| `http://localhost/legacy_site/user/forgotpassword` | Password recovery (sends reset email) |
| `http://localhost/legacy_site/user/activation` | Account activation (token from email) |
| `http://localhost/legacy_site/user/password` | Change password (authenticated) |
| `http://localhost/legacy_site/user/preferences` | User profile preferences |
| `http://localhost/legacy_site/content/view/full/2` | View content node 2 (root node) |
| `http://localhost/legacy_site/content/view/full/{nodeId}` | View any content node by Location ID |
| `http://localhost/legacy_site/content/download/{contentId}/{attributeId}` | Download binary file attribute |
| `http://localhost/legacy_site/content/imagepreview/{contentId}/{attributeId}` | Preview an image attribute |
| `http://localhost/legacy_site/content/search` | Simple keyword search |
| `http://localhost/legacy_site/content/advancedsearch` | Advanced search with filters |
| `http://localhost/legacy_site/search/searchResult` | Search results display |
| `http://localhost/legacy_site/rss/feed/1` | RSS 2.0 feed (feed ID 1) |
| `http://localhost/legacy_site/bookmark/list` | Bookmarks list (authenticated) |
| `http://localhost/legacy_site/bookmark/add` | Add a bookmark (authenticated) |
| `http://localhost/legacy_site/notification/settings` | Notification preferences (authenticated) |
| `http://localhost/legacy_site/collaboration/inbox` | Collaboration inbox (authenticated) |
| `http://localhost/legacy_site/ezinfo/about` | Platform system information page |
| `http://localhost/legacy_site/ezinfo/copyright` | Platform copyright / license notice |
| `http://localhost/legacy_site/ezinfo/credits` | Credits and contributors |
| `http://localhost/legacy_site/ezinfo/changelog` | Platform changelog summary |
| `http://localhost/legacy_site/layout/set/{layoutName}` | Switch the active page layout |
| `http://localhost/legacy_site/shop/basket` | Shopping basket (if shop extension active) |
| `http://localhost/legacy_site/shop/vieworder/{orderId}` | View a placed order (shop) |

#### Legacy Admin Interface (`/legacy_admin/`)

| URL | Description |
|---|---|
| `http://localhost/legacy_admin/` | **Legacy Admin dashboard** (login required) |
| `http://localhost/legacy_admin/user/login` | Legacy admin login form |
| `http://localhost/legacy_admin/user/logout` | Log out from legacy admin |
| `http://localhost/legacy_admin/content/dashboard` | Admin content dashboard |
| `http://localhost/legacy_admin/content/browse` | Browse content tree |
| `http://localhost/legacy_admin/content/view/full/2` | View/edit root content node |
| `http://localhost/legacy_admin/content/search` | Admin keyword search |
| `http://localhost/legacy_admin/content/advancedsearch` | Admin advanced search with filters |
| `http://localhost/legacy_admin/content/trash` | Trash / recycle bin |
| `http://localhost/legacy_admin/content/pendinglist` | Content awaiting approval |
| `http://localhost/legacy_admin/content/collectedinfo` | Collected information (forms) |
| `http://localhost/legacy_admin/class/grouplist` | Content type group list |
| `http://localhost/legacy_admin/class/list` | Content types (classes) in a group |
| `http://localhost/legacy_admin/class/view/{classId}` | View a content type definition |
| `http://localhost/legacy_admin/class/edit/{classId}` | Edit a content type definition |
| `http://localhost/legacy_admin/class/copy/{classId}` | Duplicate a content type |
| `http://localhost/legacy_admin/role/list` | Roles overview |
| `http://localhost/legacy_admin/role/view/{roleId}` | View a role's policies |
| `http://localhost/legacy_admin/role/edit/{roleId}` | Edit role policies |
| `http://localhost/legacy_admin/section/list` | Content sections list |
| `http://localhost/legacy_admin/section/view/{sectionId}` | View a section's content |
| `http://localhost/legacy_admin/user/list` | User / user group list |
| `http://localhost/legacy_admin/user/view/{userId}` | View user profile |
| `http://localhost/legacy_admin/state/groups` | Content object state groups |
| `http://localhost/legacy_admin/state/view/{groupId}` | View content states in a group |
| `http://localhost/legacy_admin/workflow/grouplist` | Workflow groups |
| `http://localhost/legacy_admin/workflow/list/{groupId}` | Workflows in a group |
| `http://localhost/legacy_admin/workflow/view/{workflowId}` | View a workflow |
| `http://localhost/legacy_admin/trigger/list` | Workflow trigger list |
| `http://localhost/legacy_admin/trigger/edit/{triggerId}` | Edit a workflow trigger |
| `http://localhost/legacy_admin/settings/list` | INI settings browser (site.ini overrides) |
| `http://localhost/legacy_admin/settings/edit` | Edit global INI settings |
| `http://localhost/legacy_admin/settings/download` | Download settings as archive |
| `http://localhost/legacy_admin/design/index` | Design management |
| `http://localhost/legacy_admin/package/repository` | Extension/package repository |
| `http://localhost/legacy_admin/setup/index` | Setup wizard (initial configuration) |
| `http://localhost/legacy_admin/notification/settings` | Notification preferences (admin) |
| `http://localhost/legacy_admin/collaboration/inbox` | Collaboration inbox (admin) |

### Default Credentials

After `composer create-project` and database install:

| Credential | Value |
|---|---|
| Legacy admin username | `admin` |
| Legacy admin password | `publish` |
| Platform v5 Admin UI login | same `admin` / `publish` credentials |

**Change the admin password immediately after your first login.**

### Legacy Bridge Key Files & Packages

| Component | Location / Package |
|---|---|
| Legacy Bridge bundle | `se7enxweb/legacy-bridge` (Composer) |
| Legacy kernel root | `ezpublish_legacy/` (project root after install) |
| Bridge configuration | `config/packages/ez_publish_legacy.yaml` |
| Legacy INI override | `src/LegacySettings/override/site.ini.append.php` |
| Extensions | `ezpublish_legacy/extension/` |
| Legacy var dir | `ezpublish_legacy/var/site/` |
| Settings siteaccess dir | `ezpublish_legacy/settings/siteaccess/` |
| Database translator ext | `ezpublish_legacy/extension/sevenx_exponential_platform_v5_database_translator/` |

For a complete walkthrough of Legacy Bridge installation, configuration, URL routing, extensions, siteaccess customisation, CLI commands, legacy cache management, and going live, see [INSTALL.md](INSTALL.md).

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
| SQLite | 3.35 | 3.39+ (dev/testing) |
| Redis | 6.0 | 7.x (optional) |
| Solr | 8.x | 8.11.x (optional) |
| Varnish | 6.0 | 7.1+ (optional) |
| Apache | 2.4 | 2.4 (event + PHP-FPM) |
| Nginx | 1.18 | 1.24+ |

---

## Quick Start

```bash
# 1. Create project from the DXP skeleton (includes Legacy Bridge by default)
composer create-project se7enxweb/exponential-platform-legacy \
    exponential_website
cd exponential_website

# 2. Configure environment
cp .env .env.local
# MySQL/MariaDB: edit DATABASE_HOST, DATABASE_NAME, DATABASE_USER, DATABASE_PASSWORD, APP_SECRET, APP_ENV
# SQLite (zero-config dev): set DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_%kernel.environment%.db"
#                            and MESSENGER_TRANSPORT_DSN=sync://

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

# 6. Publish bundle assets, install legacy extension symlinks, and build Admin UI
php bin/console assets:install --symlink --relative public
php bin/console ezpublish:legacy:assets_install --symlink --relative public
php bin/console ezpublish:legacybundles:install_extensions --relative
php bin/console ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
yarn ibexa:build

# 7. Generate JWT keypair (REST API)
php bin/console lexik:jwt:generate-keypair

# 8. Clear cache
php bin/console cache:clear

# 9. Start
symfony server:start
```

After install, all of the following are live and ready to use:

| URL | Description |
|---|---|
| `https://127.0.0.1:8000/` | Symfony/Twig public site (`site` siteaccess) |
| `https://127.0.0.1:8000/legacy_site/` | **Legacy site front end** (`legacy_site` siteaccess) |
| `https://127.0.0.1:8000/legacy_site/user/login` | Legacy user login |
| `https://127.0.0.1:8000/legacy_site/ezinfo/about` | Legacy system info |
| `https://127.0.0.1:8000/legacy_admin/` | **Legacy Admin interface** (`legacy_admin` siteaccess) |
| `https://127.0.0.1:8000/legacy_admin/content/dashboard` | Legacy admin content dashboard |
| `https://127.0.0.1:8000/adminui/` | **Platform v5 Admin UI** (React) |
| `https://127.0.0.1:8000/api/ezp/v2/` | REST API v2 |
| `https://127.0.0.1:8000/graphql` | GraphQL endpoint |

Default credentials: `admin` / `publish` (change immediately after first login).

See [INSTALL.md](INSTALL.md) for the complete step-by-step guide including Legacy Bridge setup, siteaccess configuration, legacy extensions, and production deployment.

---

## Main Exponential Platform Legacy Features

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

- **Full Legacy Bridge by Default** — the `se7enxweb/legacy-bridge` package is included and configured at project creation; the classic eZ Publish legacy kernel starts alongside Symfony 7.4 LTS with zero extra setup
- **Legacy Admin Interface** — the classic editorial back end at `/legacy_admin/` is fully operational; all legacy content, class, role, workflow, and settings administration screens work out of the box
- **Three-Siteaccess Architecture** — `site` (Symfony/Twig new stack), `legacy_site` (classic eZ Publish front end), and `legacy_admin` (classic eZ Publish admin) all run from a single application and single database
- **QueryTranslator Database Translator** — multi-database legacy kernel support: MySQL 8.0, MariaDB 10.6, PostgreSQL 14+, and SQLite 3.35+ (dev/testing) via the `sevenx_exponential_platform_v5_database_translator` extension
- **Single-Kernel Host Architecture** — Exponential Platform v5 OSS runs on Symfony 7.4 LTS as the outer container; the legacy kernel is encapsulated within it through the Bridge
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
composer create-project se7enxweb/exponential-platform-legacy exponential_website
```

The `se7enxweb/legacy-bridge` package and all Legacy Bridge configuration are included automatically. After `composer create-project` completes, the legacy bridge is installed, legacy extension symlinks are created, and autoloads are generated — no manual steps needed.

The installation guide covers:

- First-time install (`composer create-project` or `git clone`)
- Environment configuration (`.env.local` reference)
- Database creation and demo data import (MySQL/MariaDB, PostgreSQL, SQLite)
- **Legacy Bridge configuration and siteaccess setup**
- **Legacy extension management and autoload generation**
- **Legacy admin and legacy site access point walkthrough**
- **Legacy template/design customisation getting started**
- **Legacy INI settings — override file structure**
- Web server setup (Apache 2.4, Nginx, Symfony CLI)
- File & directory permissions
- Frontend asset build (Webpack Encore / Yarn)
- Admin UI asset build
- JWT keypair generation
- GraphQL schema generation
- Search index initialisation
- Cache management (Symfony cache + Legacy cache)
- Day-to-day operations (start / stop / restart / deploy)
- Legacy Bridge production deployment checklist
- Cron job setup
- Solr search engine integration (optional)
- Varnish HTTP cache integration (optional)
- Troubleshooting (new-stack and legacy-specific)
- Database conversion (MySQL ↔ PostgreSQL ↔ SQLite)

See [INSTALL.md](INSTALL.md) for the complete step-by-step guide.

Learn more about our open source products — [Exponential Platform Legacy](https://platform.exponential.earth/).

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
| `/legacy_site/` | **Legacy site front end** (classic eZ Publish, `legacy_site` siteaccess) |
| `/legacy_site/user/login` | Legacy user login |
| `/legacy_site/user/logout` | Legacy user logout |
| `/legacy_site/content/view/full/{nodeId}` | View any content node |
| `/legacy_site/content/search` | Legacy search |
| `/legacy_site/ezinfo/about` | Platform system info |
| `/legacy_admin/` | **Legacy Admin interface** (classic eZ Publish admin, `legacy_admin` siteaccess) |
| `/legacy_admin/content/dashboard` | Legacy admin dashboard |
| `/legacy_admin/class/grouplist` | Legacy content type editor |
| `/legacy_admin/role/list` | Legacy role/policy management |
| `/adminui/` | Platform v5 Admin UI (new stack, React) |
| `/` | Public Symfony/Twig site (`site` siteaccess) |
| `/api/ezp/v2/` | REST API v2 |
| `/graphql` | GraphQL endpoint |

See the [Legacy Bridge — Architecture & Default Siteaccess URLs](#legacy-bridge--architecture--default-siteaccess-urls) section above for the complete URL reference.

### Legacy Bridge CLI Commands

```bash
# Publish legacy bundle assets to public/bundles/
php bin/console ezpublish:legacy:assets_install --symlink --relative public

# Install legacy extension symlinks from all registered bundles
php bin/console ezpublish:legacybundles:install_extensions --relative

# Regenerate legacy autoloads (required after adding/removing extensions or classes)
php bin/console ezpublish:legacy:script bin/php/ezpgenerateautoloads.php

# Run the legacy content crawler / maintenance script
php bin/console ezpublish:legacy:script bin/php/ezmaintenance.php

# Check legacy kernel status
php bin/console ezpublish:legacy:script bin/php/ezsiteinstaller.php

# Run any legacy PHP script through the bridge kernel
php bin/console ezpublish:legacy:script <path/to/script.php> [-- [legacy-args]]

# Dump legacy INI settings as resolved through the siteaccess config resolver
php bin/console exponential:debug:config-resolver languages --siteaccess=legacy_site
php bin/console exponential:debug:config-resolver languages --siteaccess=legacy_admin
```

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

Submitting bugs, improvements and stories is possible on https://github.com/se7enxweb/exponential-platform-legacy/issues

If you discover a security issue, please responsibly report such issues via email to [security@exponential.one](mailto:security@exponential.one)

---

## Where to Get More Help

| Resource | URL |
|---|---|
| Platform Website | platform.exponential.earth |
| Documentation Hub | doc.exponential.earth |
| Community Forums | share.exponential.earth |
| GitHub Organisation | github.com/se7enxweb |
| This Repository | github.com/se7enxweb/exponential-platform-legacy |
| DXP Metapackage | github.com/se7enxweb/exponential-platform-legacy |
| Issue Tracker | [Issues](https://github.com/se7enxweb/exponential-platform-legacy/issues) |
| Discussions | [Discussions](https://github.com/se7enxweb/exponential-platform-legacy/discussions) |
| Telegram Chat | t.me/exponentialcms |
| Discord | discord.gg/exponential |
| 7x Corporate | se7enx.com |
| Support Subscriptions | support.exponential.earth |
| Sponsor 7x | sponsor.se7enx.com |

---

## How to Contribute New Features and Bugfixes into Exponential Platform Legacy

Everyone is encouraged to contribute to the development of new features and bugfixes for Exponential Platform Legacy.

Getting started as a contributor:

1. Fork the repository on GitHub: [github.com/se7enxweb/exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy)
2. Clone your fork and create a feature branch: `git checkout -b feature/my-improvement`
3. Install the full dev stack per [INSTALL.md](INSTALL.md) (`APP_ENV=dev`)
4. Make your changes — follow coding standards in `CONTRIBUTING.md`
5. Test with `php bin/phpunit` and verify no regressions
6. Push your branch and open a Pull Request against the `master` branch
7. Participate in the review — maintainers will give feedback promptly

Bug reports, feature requests, and discussion are all welcome via the [issue tracker](https://github.com/se7enxweb/exponential-platform-legacy/issues) and [GitHub Discussions](https://github.com/se7enxweb/exponential-platform-legacy/discussions).

---

## Donate and Make a Support Subscription

### Help Fund Exponential Platform Legacy!

You can support this project and its community by making a donation of whatever size you feel willing to give to the project.

If we have helped you and you would like to support the project with a subscription of financial support you may. This is what helps us deliver more new features and improvements to the software. Support Exponential Platform Legacy with a subscription today!

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
Exponential Platform Legacy is Open Source software released under the GNU GPL v2 or any later version.
