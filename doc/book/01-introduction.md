# 1. Introduction: what you are installing

This chapter explains what Exponential Platform Legacy is before you install it: one Symfony application that carries
two content engines, the Platform new stack and the Exponential 6 legacy kernel, joined by LegacyBridge and working on
one database. It introduces the four release lines that are maintained today (2.5, 3.x, 4.6.x and 5.x) with the facts
that decide every later step, such as the Symfony version, the PHP range, the web root and the install command, and it
explains how this book is organised and the words it uses. Read it once; the later chapters assume the vocabulary
introduced here.

[Contents](README.md) · Next: [2. Requirements](02-requirements.md)

---

## Contents of this chapter

1. [What Exponential Platform Legacy is](#11-what-exponential-platform-legacy-is)
2. [Two kernels, one application](#12-two-kernels-one-application)
3. [The family of products](#13-the-family-of-products)
4. [The release lines](#14-the-release-lines)
5. [Which line to choose](#15-which-line-to-choose)
6. [How to read this book](#16-how-to-read-this-book)
7. [Conventions](#17-conventions)
8. [Glossary](#18-glossary)
9. [References](#19-references)

---

## 1.1 What Exponential Platform Legacy is

Exponential Platform Legacy is an open source content management system and application framework in PHP. It is
distributed as a **project skeleton**: the Composer package `se7enxweb/exponential-platform-legacy` is not a library
you add to something else, it is the starting point of your own project. `composer create-project` copies it into a
new directory, installs everything it requires and leaves you with a Symfony application that you then configure,
install into a database and serve.

What makes it different from a plain Symfony content platform is that the application also contains the complete
**Exponential 6 legacy kernel**: the classic content engine with its TPL template language, its modules (content,
user, shop, workflow, setup and the rest), its INI settings, its cronjobs, its extensions and its own administration
interface. Both engines read and write the **same database**, so an article published in one is immediately there in
the other.

| | |
|---|---|
| Package | [`se7enxweb/exponential-platform-legacy`](https://packagist.org/packages/se7enxweb/exponential-platform-legacy) |
| Source | [github.com/se7enxweb/exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy) |
| Maintainer | [7x](https://se7enx.com) |
| Licence | GNU GPL, version 2 or later (`composer.json` of the 2.5 line: `GPL-2.0-or-later`; the 5.x skeleton says `(GPL-2.0-or-later or proprietary)`; the 3.x and 4.6.x skeletons carry the Symfony skeleton default `proprietary`, which describes your project, not the software) |
| Copyright | 1998 to 2026 7x; 1999 to 2020 Ibexa AS (formerly eZ Systems AS) for the upstream parts ([COPYRIGHT.md](../../COPYRIGHT.md)) |

> **A note on names.** The product grew out of systems with older names, and the code keeps that history on purpose:
> the directory `ezpublish_legacy/`, the console commands `ezpublish:legacy:script` and `ezplatform:install`, the
> bundle `EzPublishLegacyBundle`, the configuration key `ez_publish_legacy`, the Composer packages
> `se7enxweb/ezpublish-kernel` and `se7enxweb/ezplatform-kernel`. They are names of code, and this book writes them
> exactly as the code does. The products are called **Exponential** (the legacy kernel, version 6),
> **Exponential Platform Legacy** (this product), **Exponential Platform Nexus** (the Symfony-only platform) and
> **Exponential Velocity** (the application server). The old product names eZ Publish, eZ Platform and Ibexa appear
> only where this book identifies the upstream system a part was built from.

## 1.2 Two kernels, one application

Every request enters through one Symfony front controller (`web/app.php` on the 2.5 line, `public/index.php` from 3.x
on). Symfony decides which **siteaccess** the request belongs to, and the siteaccess decides which engine answers:

```
                         browser
                            |
              web server or Exponential Velocity
                            |
             Symfony front controller (app.php or index.php)
                            |
                  siteaccess matching (URIElement: 1)
                            |
        +-------------------+----------------------------+
        |                                                |
  siteaccess with legacy_mode: false              siteaccess with legacy_mode: true
  (site, admin, adminui)                          (legacy_admin, legacy_site)
        |                                                |
  Platform new stack                               LegacyBridge (EzPublishLegacyBundle)
  Symfony controllers, Twig,                        boots the Exponential 6 kernel in
  REST API, GraphQL, Admin UI                       ezpublish_legacy/ and hands it the
        |                                           request; TPL templates, modules,
        |                                           INI settings, legacy admin
        |                                                |
        +----------------> one database <----------------+
                     (connection defined once, in Symfony;
                      the bridge injects it into the legacy kernel)
```

What the bridge does, in the order it matters to an administrator:

1. **It installs the legacy kernel.** The Composer package `se7enxweb/exponential` (type `ezpublish-legacy`) is
   placed in `ezpublish_legacy/` by the installer plugin `se7enxweb/exponential-legacy-installer`; the directory name
   comes from `extra.ezpublish-legacy-dir` in `composer.json`.
2. **It boots the legacy kernel inside Symfony** for siteaccesses whose `ez_publish_legacy.system.<siteaccess>.legacy_mode`
   is `true`, and for legacy URLs that the Symfony router does not know (the bridge's fallback route).
3. **It injects settings.** Before the legacy kernel builds, the bridge writes the Doctrine connection (driver, host,
   port, user, password, database), the var and storage directories, the image settings, the anonymous user and
   cluster settings into the legacy INI system as *injected settings*. Injected settings take precedence over the INI
   files. That is why you configure the database once, in Symfony, and not again in `site.ini`
   ([chapter 5](05-the-legacy-kernel-inside.md) has the details).
4. **It provides console commands** to run legacy scripts with that configuration (`ezpublish:legacy:script`), to
   install legacy assets and extensions, and to prepare a project (`ezpublish:legacy:init`).

Two consequences to keep in mind from the start:

- There are **two administration interfaces**: the new-stack Admin UI (a React application) and the legacy admin (the
  classic Exponential administration, `admin3` design on the 2.5 line). Both work on the same content. The legacy
  admin is the complete one for legacy content classes, modules, workflows, roles and INI settings.
- There are **two sets of caches** and **two sets of settings**: Symfony's (`var/cache/`, YAML and environment
  variables) and the legacy kernel's (`ezpublish_legacy/var/<site>/cache/`, INI files). Operations always have to
  think of both ([chapter 5](05-the-legacy-kernel-inside.md), [chapter 9](09-operations.md)).

## 1.3 The family of products

| Product | What it is | Repository |
|---|---|---|
| **Exponential** (6.x) | The legacy kernel on its own: a complete CMS with its own front controller, setup wizard, kickstarter and console | [se7enxweb/exponential](https://github.com/se7enxweb/exponential) |
| **Exponential Platform Legacy** | This product: a Symfony skeleton with the Platform new stack plus the Exponential 6 kernel through LegacyBridge | [se7enxweb/exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy) |
| **Exponential Platform Nexus** | The Symfony platform without the legacy kernel | [se7enxweb/exponential-platform-nexus-starter](https://github.com/se7enxweb/exponential-platform-nexus-starter) |
| **LegacyBridge** | The Symfony bundle that runs the legacy kernel inside the platform | [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) |
| **Exponential Velocity** | The application server that serves PHP applications without a separate web server; the recommended way to serve Exponential at every stage | [se7enxweb/exponential-velocity](https://github.com/se7enxweb/exponential-velocity) |

Everything that concerns the legacy kernel alone (its INI settings, cronjobs, caches, datatypes, designs, extensions)
is documented in depth in **the Exponential 6 book**,
[Installing and running Exponential 6.0](https://github.com/se7enxweb/exponential/blob/main/doc/install/README.md).
This book links to its chapters wherever the legacy kernel behaves the same inside the platform, and explains what is
different when it runs behind the bridge.

## 1.4 The release lines

Each line is a branch of the repository with its own tags. The facts below are taken from each branch's
`composer.json`, from the Composer metadata of the packages it requires (as published on Packagist on 2026-10-05) and
from the configuration the skeleton or its Symfony Flex recipe installs.

| | **2.5** | **3.x** | **4.6.x** | **5.x** |
|---|---|---|---|---|
| Branch | `master` | `3.x` | `4.6.x` | `5.x` |
| Newest tag of the line | `v2.5.0.3` | `v3.3.44.7` | `v4.6.23.2` | `v5.0.2` (read [the note on v5.0.3](#the-tag-v503)) |
| Symfony | 3.4 LTS (`se7enxweb/symfony ^3.4.50`) | 5.4 LTS (`se7enxweb/symfony 5.4.x-dev`, `symfony/framework-bundle 5.4.*`) | 5.4 LTS (`extra.symfony.require ^5.3`; LegacyBridge 4 requires `^5.4`) | 7.4 (`se7enxweb/exponential-platform-dxp` and LegacyBridge 5 require `symfony/framework-bundle ^7.4`) |
| Platform new stack | `se7enxweb/ezpublish-kernel ~7.5.33` | `se7enxweb/oss ~3.3.0.0`, `se7enxweb/ezplatform-kernel ~1.3.43` | `se7enxweb/exponential-platform-dxp 4.6.x-LB-dev` | `se7enxweb/exponential-platform-dxp dev-5.x-LB` |
| Upstream it was built from | eZ Platform 2.5 | Ibexa OSS 3.3 | Ibexa DXP 4.6 (OSS) | Ibexa DXP 5.0 (OSS) |
| LegacyBridge (`se7enxweb/legacy-bridge`) | `^2.1` (2.1.x) | `^3.0.0.35` (3.0.0.x) | `^4.0.0.0` (4.0.0.x) | `^5.0.0.0` (5.0.x) |
| Legacy kernel (`se7enxweb/exponential`) | `^6.0.12`, required directly | `^6.0.12`, through the bridge | `dev-main`, through the bridge | `dev-main`, through the bridge |
| PHP in `composer.json` | `^7.1.3 \|\| ^8.1 \|\| ^8.2` | `^8.0` | `^7.4 \|\| ^8.0 ... \|\| ^8.5` | `>=8.3` |
| PHP that resolves in practice | **8.1 or later** (6.0.10 to 6.0.14 of the kernel declare `^8.1`) | **8.1 or later** (same kernel range) | **8.0 or later** (LegacyBridge 4 declares `^8.0`) | **8.4 or later** (LegacyBridge 5 declares `^8.4`) |
| Web root | `web/` | `public/` | `public/` (the recipe also links `web` to `public`) | `public/` |
| Front controller | `web/app.php` (and `web/app_dev.php`) | `public/index.php` | `public/index.php` (Symfony Runtime) | `public/index.php` (Symfony Runtime) |
| Console | `bin/console` | `bin/console` | `bin/console` | `bin/console` |
| Environment and secrets | `app/config/parameters.yml`, `SYMFONY_ENV`, `SYMFONY_DEBUG` | `.env`, `.env.local`, `APP_ENV`, `APP_SECRET` | the same | the same |
| Install command | `ezplatform:install clean` (or `exponential-oss`, with kernel 7.5.41 or later) | `exponential:install exponential-oss` | `exponential:install exponential-oss` | `exponential:install exponential-oss` |
| New-stack admin (siteaccess) | `/admin/` (`admin`) | `/adminui/` (`adminui`) | `/admin/` (`admin`, per the recipe) | `/admin/` (`admin`, per the recipe) |
| Legacy admin (siteaccess) | `/legacy_admin/` | `/legacy_admin/` | `/legacy_admin/` | `/legacy_admin/` |
| Netgen Layouts | no | no | `netgen/layouts-ibexa ^1.4` | `netgen/layouts-ibexa ^2.0` |
| Node.js for asset builds | 14 LTS | 18 LTS (`.nvmrc`) | 20 LTS | 20 LTS |
| Status | maintained | maintained | maintained | maintained, newest |

How the two PHP rows relate: Composer accepts a PHP version only if **every** package agrees. The skeleton's own
constraint is the widest statement; a required package can narrow it. On the 2.5 line the skeleton still lists
`^7.1.3`, but the legacy kernel releases it resolves to need PHP 8.1, so PHP 7 cannot install it. On the 5.x line the
skeleton says `>=8.3`, but every LegacyBridge 5 release needs 8.4. [Chapter 2](02-requirements.md) has the details.

The admin paths of 4.6.x and 5.x: the READMEs of both branches name `/adminui/`. The configuration their Flex recipe
installs (`config/packages/ibexa_admin_ui.yaml` and `config/packages/ibexa.yaml` in
[se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes)) defines the admin siteaccess as `admin` with
`URIElement: 1` matching, which puts it at `/admin/`. Check your installation with
`php bin/console debug:config ibexa siteaccess` ([chapter 4](04-installing.md#410-first-login)).

### The old branches

The branches `1.7` to `1.13`, `2.0` and `2.2` are the upstream history the project was forked from (package names
`ezsystems/ezplatform-legacy` and `emodric/ezplatform-legacy`, Symfony 2.8 or 3.4, PHP 5.6 or 7). They are kept for
reference and are not maintained; Packagist still lists them as `1.7.x-dev` to `2.2.x-dev`. The branches `2.5.0.0` to
`2.5.0.3` are snapshots of the 2.5 line at each release; use the tags instead.

### The tag v5.0.3

The tag `v5.0.3` (GitHub release of 2026-08-03, marked "Latest") points at a commit on `master`, the **2.5 line**: its
`composer.json` requires Symfony 3.4, `se7enxweb/ezpublish-kernel ~7.5.33` and LegacyBridge `^2.1`, and carries the
branch alias `dev-master: 2.5.x-dev`. Its release notes describe 5.x changes. Because it is the highest stable version
number, **Composer picks it whenever no version or a range such as `^5.0` is given**, and you get the 2.5 line under a
5.x number. Published tags are never moved, so the tag stays as it is. Always name the line explicitly when you create a
project ([chapter 3](03-getting-the-code.md#34-composer-create-project-per-line)).

## 1.5 Which line to choose

| Your situation | Line |
|---|---|
| A new project that should run on current PHP and Symfony for the longest time | **5.x** (PHP 8.4 or later) |
| A new project on PHP 8.0 to 8.3, with Netgen Layouts | **4.6.x** |
| You run an Ibexa OSS 3.3 style project, or want Symfony 5.4 without Netgen Layouts | **3.x** |
| You run a 2.5 style project (`app/`, `web/`, `parameters.yml`), or need the legacy kernel with the smallest new stack | **2.5** |
| You only need the legacy kernel, no Symfony stack at all | not this product: install [Exponential 6](https://github.com/se7enxweb/exponential/blob/main/doc/install/README.md) |
| You do not need the legacy kernel at all | not this product: Exponential Platform Nexus |

Moving an existing site between lines is the subject of [chapter 10](10-upgrading-between-lines.md); bringing a site in
from another system is [chapter 11](11-migrating-into.md).

## 1.6 How to read this book

| Part | Chapters | What they cover |
|---|---|---|
| Before you install | [1](01-introduction.md), [2](02-requirements.md), [3](03-getting-the-code.md) | What the product is, what it needs, how to get it |
| Installing | [4](04-installing.md), [5](05-the-legacy-kernel-inside.md), [6](06-serving-the-site.md) | The full install per line, the legacy kernel behind the bridge, serving the site |
| Running | [7](07-databases.md), [8](08-configuration.md), [9](09-operations.md) | Databases, configuration, daily operations |
| Changing | [10](10-upgrading-between-lines.md), [11](11-migrating-into.md) | Moving between lines, migrating sites in |
| When things go wrong | [12](12-troubleshooting.md), [13](13-security-hardening.md) | Troubleshooting, hardening for production |

Each chapter starts with a summary, lists its sections, numbers them (`4.3`, `4.3.1`) so they can be referred to, and
ends with a **References** section: documentation in this repository (relative links) and the official sources outside
it. Where a statement depends on the release line, the chapter says which line, usually in a table with one column per
line.

## 1.7 Conventions

- **Where commands run.** Every command is run from the **project root**: the directory that holds `composer.json`,
  `bin/` and `vendor/`. Commands for the legacy kernel are run through the Symfony console
  (`php bin/console ezpublish:legacy:script ...`) unless a chapter says otherwise.
- **Paths.** `web/` means the web root of the 2.5 line, `public/` the web root of the others. Where both apply the text
  says "the web root".
- **Placeholders.** `my_project`, `example.com`, `db_user`, `db_password` and `exponential` (the database name) stand
  for your own values.
- **Settings.** YAML settings are written with their full key path (`ez_publish_legacy.system.legacy_admin.legacy_mode`),
  INI settings as `file.ini [Section] Setting` (`site.ini [SiteAccessSettings] MatchOrder`), environment variables in
  capitals (`APP_ENV`).
- **Verified and derived.** What this book states was checked against the repository, the packages it requires or the
  upstream documentation. A configuration that the project does not ship and that this book derived from those sources
  is marked **derived**; something that could not be checked is marked **not verified**.
- **Root.** Commands that need root say so. Never run the application or its workers as root.

## 1.8 Glossary

| Term | Meaning |
|---|---|
| **Project root** | The directory created by `composer create-project`; holds `composer.json`, `bin/console`, `vendor/` |
| **Web root** | The directory the web server exposes: `web/` (2.5) or `public/` (3.x and later). Nothing above it is reachable by URL |
| **Front controller** | The one PHP script every dynamic request goes to: `web/app.php` or `public/index.php` |
| **New stack** | The Symfony part of the product: repository API, Twig, REST, GraphQL, Admin UI. Built from the upstream named in [1.4](#14-the-release-lines) |
| **Legacy kernel** | Exponential 6, installed in `ezpublish_legacy/`; runs TPL templates, modules, INI settings |
| **LegacyBridge** | `se7enxweb/legacy-bridge`, the bundle `EzPublishLegacyBundle` that boots the legacy kernel inside Symfony |
| **Siteaccess** | A named configuration scope (site, admin, legacy_admin ...) chosen per request, here by the first URL segment (`URIElement: 1`) |
| **`legacy_mode`** | Bridge setting per siteaccess: `true` hands URL aliases and modules to the legacy kernel |
| **Injected settings** | Values the bridge (or the project) writes into the legacy INI system at boot; they take precedence over INI files |
| **INI override** | A file `*.ini.append.php` in `ezpublish_legacy/settings/override/` or `settings/siteaccess/<name>/` that changes legacy settings |
| **Legacy extension** | A directory in `ezpublish_legacy/extension/` with settings, templates, modules or datatypes for the legacy kernel |
| **Install type** | The data set the platform installer loads: `clean`, `ibexa-oss`, `exponential-oss` |
| **Flex recipe** | Files Symfony Flex copies into a project when a package is installed; the 4.6.x and 5.x skeletons get most of their files this way |
| **Exponential Velocity** | The application server that accepts HTTP and HTTPS itself and runs PHP in persistent workers ([chapter 6](06-serving-the-site.md)) |

## 1.9 References

In this repository:

- [README.md](../../README.md) of the 2.5 line (`master`); the READMEs of the other lines are on their branches:
  [3.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/README.md),
  [4.6.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/4.6.x/README.md),
  [5.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/5.x/README.md)
- [composer.json](../../composer.json) of the 2.5 line, and on the branches
  [3.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/composer.json),
  [4.6.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/4.6.x/composer.json),
  [5.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/5.x/composer.json)
- [The short installation guide](../INSTALL.md) and [the contents page of this book](README.md)
- [doc/README.ezplatformlegacy.md](../README.ezplatformlegacy.md): the upstream README the project started from

External:

- The Exponential 6 book: [Installing and running Exponential 6.0](https://github.com/se7enxweb/exponential/blob/main/doc/install/README.md),
  in particular [1. Introduction](https://github.com/se7enxweb/exponential/blob/main/doc/install/01-introduction.md)
- LegacyBridge: [github.com/se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`)
- The Flex recipes of the 4.6.x and 5.x lines: [github.com/se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes)
  (`se7enxweb/exponential-platform-dxp/4.6.x-LB-dev` and `5.0`)
- Packagist: [se7enxweb/exponential-platform-legacy](https://packagist.org/packages/se7enxweb/exponential-platform-legacy),
  [se7enxweb/legacy-bridge](https://packagist.org/packages/se7enxweb/legacy-bridge),
  [se7enxweb/exponential](https://packagist.org/packages/se7enxweb/exponential)
- Symfony: [Symfony releases](https://symfony.com/releases), [the Symfony Flex documentation](https://symfony.com/doc/current/setup/flex.html),
  [the front controller](https://symfony.com/doc/current/configuration/front_controllers_and_kernel.html)
- Upstream concepts: [siteaccess](https://doc.ibexa.co/en/latest/multisite/siteaccess/siteaccess/) and
  [siteaccess matching](https://doc.ibexa.co/en/latest/multisite/siteaccess/siteaccess_matching/)
- Composer: [composer create-project](https://getcomposer.org/doc/03-cli.md#create-project),
  [version constraints](https://getcomposer.org/doc/articles/versions.md)

[Contents](README.md) · Next: [2. Requirements](02-requirements.md)
