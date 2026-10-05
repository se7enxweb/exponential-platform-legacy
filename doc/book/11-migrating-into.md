# 11. Migrating into Exponential Platform Legacy

Exponential Platform Legacy is a natural destination for three kinds of site: an eZ Publish 3.x or 4.x site that
should gain a Symfony stack without losing its legacy templates and extensions; an eZ Publish 5.x site, which already
runs both kernels and needs a maintained platform under them; and an eZ Platform or Ibexa site that wants the legacy
admin and the legacy kernel's features back. The old product names appear in this chapter only to identify the system
you migrate from. The Exponential 6 book already describes these migrations for the legacy kernel in four long
chapters (14 to 17); this chapter does not repeat them. It tells you which of them to read, which release line of
this distribution to aim for, and what is specific to arriving in a hybrid installation: the shared database has to
satisfy two kernels, the configuration lives in two places, and the content model must have a datatype on the legacy
side for every field type on the Symfony side.

[Previous: 10. Upgrading between release lines](10-upgrading-between-lines.md) ·
[Next: 12. Troubleshooting](12-troubleshooting.md) · [Contents](README.md)

## Contents of this chapter

- [11.1 Choose the target line](#111-choose-the-target-line)
- [11.2 What the Exponential 6 book covers](#112-what-the-exponential-6-book-covers)
- [11.3 From eZ Publish 3.x and 4.x](#113-from-ez-publish-3x-and-4x)
- [11.4 From eZ Publish 5.x](#114-from-ez-publish-5x)
- [11.5 From eZ Platform 1.x and 2.x](#115-from-ez-platform-1x-and-2x)
- [11.6 From eZ Platform 3.x and Ibexa 4.x or 5.x](#116-from-ez-platform-3x-and-ibexa-4x-or-5x)
- [11.7 What is specific to this distribution](#117-what-is-specific-to-this-distribution)
- [11.8 Checklist](#118-checklist)
- [References](#references)

## 11.1 Choose the target line

Arrive on the line that matches the platform generation of the source, then move up line by line with
[chapter 10](10-upgrading-between-lines.md) if you want a newer one. Every jump across a generation costs a schema
step; doing it inside a migration doubles the risk.

| Source | Arrive on | Why |
|---|---|---|
| eZ Publish 3.x, 4.x (legacy only) | 2.5 | the 2.5 platform schema is the complete legacy schema (130 tables), so nothing the legacy site uses is missing |
| eZ Publish 5.x (5.0 to 5.4, Symfony 2) | 2.5 | the database is the 5.4 schema; the 2.5 kernel ships the 5.4 to 7.5 update files |
| eZ Platform 1.x, 2.x | 2.5 | same kernel family (6.x, 7.5) and same `ezpublish:` configuration |
| eZ Platform 3.0 to 3.3 | 3.3 | same kernel family (`ezplatform-kernel` 1.x) |
| Ibexa 4.0 to 4.6 | 4.6 | same kernel family and `ibexa:` configuration |
| Ibexa 5.0 | 5 | `ibexa_*` table names, handled for the legacy kernel by the translator extension |

## 11.2 What the Exponential 6 book covers

Read the chapter for your source first. Everything it says about the **legacy kernel**, the **database** and the
**content** applies here unchanged; what it says about serving a legacy-only site does not, because here Symfony
serves the site ([chapter 6](06-serving-the-site.md)).

| Chapter of the Exponential 6 book | Use it for |
|---|---|
| [14. Migrating from the 4.x line](https://github.com/se7enxweb/exponential/blob/main/doc/install/14-migrating-from-4x.md) | taking stock, charset and table type, preflight queries, the legacy update files from 3.10 and 4.x to 5.4, the data repair scripts, files and cluster, settings and siteaccesses, porting extensions to PHP 8, users and passwords, verification |
| [15. Migrating from the 5.x legacy stack](https://github.com/se7enxweb/exponential/blob/main/doc/install/15-migrating-from-5x-legacy.md) | which 5.x variant you run, the shared database, YAML against INI, field types against datatypes, image variations and aliases, Twig and TPL, caches, cluster |
| [16. Migrating from eZ Platform and Ibexa](https://github.com/se7enxweb/exponential/blob/main/doc/install/16-migrating-from-ez-platform-and-ibexa.md) | the two destinations (Nexus, or the legacy kernel alone or as Platform Legacy), inventory, the database generation by generation, field types (16.6.3), RichText against XmlText, keeping a Symfony stack next to the legacy kernel (16.6.8) |
| [17. Migration reference](https://github.com/se7enxweb/exponential/blob/main/doc/install/17-migration-reference.md) | lookup tables: kernel tables, datatypes and field types, INI and YAML settings, TPL and Twig, password hashes, URL aliases and image paths, data checks |
| [11. Upgrading](https://github.com/se7enxweb/exponential/blob/main/doc/install/11-upgrading.md) | the legacy update chain and the 6.0.x update files |
| [13. Security hardening](https://github.com/se7enxweb/exponential/blob/main/doc/install/13-security-hardening.md) | the legacy kernel's side of sign-in, sessions, form tokens and headers |

## 11.3 From eZ Publish 3.x and 4.x

The legacy site keeps its kernel's world: its database, extensions and designs move into `ezpublish_legacy/`. What is
added is the platform's schema state on top.

1. **Bring the database to the 5.4 schema** with the legacy update chain and the repair scripts (Exponential 6 book,
   chapter 14.5). Do not skip the charset and table type preparation (14.5.2): the 2.5 platform kernel creates
   `utf8mb4` InnoDB tables and expects the same of the existing ones.
2. **Apply the 2.5 platform kernel's update files**, which ship in `vendor/se7enxweb/ezpublish-kernel/data/update/<engine>/`
   (`mysql`, `postgres`): `dbupdate-5.4.0-to-6.13.0.sql`, then `dbupdate-6.13.0-to-7.5.0.sql` (and
   `dbupdate-7.1.0-to-7.2.0-dfs.sql` on a DFS cluster database), then `dbupdate-7.5.2-to-7.5.3.sql`,
   `dbupdate-7.5.4-to-7.5.5.sql` and `dbupdate-7.5.6-to-7.5.7.sql`. The comment at the top of these files says they
   cover the platform kernel only; the bundles of the 2.5 line add their own tables during install.
3. **Apply the legacy kernel's 6.0 files last**: `update/database/<engine>/6.0/dbupdate-5.4.0-6.0.0.sql` and the
   6.0.0 to 6.0.15 file, so that `ezsite_data` ends on the legacy kernel's version ([7.9](07-databases.md#79-the-version-rows-in-ezsite_data)).
4. **Create the 2.5 project** ([chapter 4](04-installing.md)), point it at the migrated database **without** running
   the installer (the installer drops and recreates the tables it knows), and move the storage directory to
   `ezpublish_legacy/var/site/storage` (or the directory your `var_dir` names).
5. **Move the legacy configuration**: global overrides into `ezpublish_legacy/settings/override/`, siteaccess
   directories into `ezpublish_legacy/settings/siteaccess/`; remove `[DatabaseSettings]` connection values (the bridge
   injects them, [7.2](07-databases.md#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)).
6. **Declare the siteaccesses in YAML** with the same names, give the legacy ones `legacy_mode: true`, and add every
   image alias the legacy designs use as an `image_variations` entry ([8.7](08-configuration.md#87-image-variations-and-image-aliases)).
7. **Port your extensions to PHP 8** (Exponential 6 book, chapter 14.9) and activate them.
8. Clear both sides' caches, reindex, verify.

A legacy-only site that does not need the Symfony stack at all is better served by Exponential 6 alone; the hybrid
pays for itself only when you want Symfony controllers, REST v2, GraphQL or the platform admin.

## 11.4 From eZ Publish 5.x

An eZ Publish 5.x site already has the shape of this distribution: a Symfony 2 application with an `ezpublish_legacy/`
directory and the same shared database. Its database is the 5.4 schema (5.0 to 5.3 sites first need the legacy
chain to 5.4), so the database steps are 2 and 3 of [11.3](#113-from-ez-publish-3x-and-4x).

The configuration moves from the 5.x `ezpublish/config/ezpublish.yml` to `app/config/ezplatform.yml` of the 2.5 line;
the `ezpublish:` key, `siteaccess:`, `system:` scopes and `legacy_mode` keep their meaning, and the 5.x bridge's
options are the ones of [8.5](08-configuration.md#85-siteaccesses-and-legacy_mode). Bundles written for Symfony 2.3 to
2.8 need the Symfony 3.4 changes, Twig templates the platform 7.5 API. Chapter 15 of the Exponential 6 book is the
guide for everything on the legacy side.

## 11.5 From eZ Platform 1.x and 2.x

A site on eZ Platform 1.x or 2.x is the closest source, especially one that already runs the upstream legacy bridge:

| Upstream package | Exponential package |
|---|---|
| `ezsystems/ezplatform` (+ `ezsystems/legacy-bridge`) | this project, 2.5 line |
| `ezsystems/ezpublish-kernel` | `se7enxweb/ezpublish-kernel ~7.5.33` |
| `ezsystems/legacy-bridge` | `se7enxweb/legacy-bridge ^2.1` |
| `ezsystems/ezpublish-legacy` | `se7enxweb/exponential ^6.0.12`, installed into `ezpublish_legacy/` by `se7enxweb/exponential-legacy-installer` |

The forks declare the upstream names as replaced (Exponential 6 bc notes, "Package forks and command renames"), so
third-party packages that require the upstream names still install.

- **Database**: a 1.x site runs the kernel's 6.x update files up to `dbupdate-6.13.0-to-7.5.0.sql` and the 7.5.x
  ones; a 2.5 site is already there. Then the legacy kernel's 6.0 files.
- **Field types**: the legacy kernel needs a datatype for every field type in use. The 2.5 line ships the
  `ezrichtext` legacy extension (from `se7enxweb/richtext-datatype-bundle`, active in master's override) that shows
  RichText as raw XML in the legacy editor, and the bridge requires `se7enxweb/ezplatform-xmltext-fieldtype` so that
  the Symfony side can read XmlText. Field types without a legacy datatype (`ezimageasset`, the 2.5 `ezmatrix`,
  `ezcontentquery`, commercial ones) are listed with their remedy in chapter 16.6.3 of the Exponential 6 book.
- **A site without the legacy bridge** has no legacy settings or designs; start them from the shipped
  `ezpublish_legacy/settings/` of the 2.5 line and build the legacy admin siteaccess first, the public legacy
  templates later or never.

## 11.6 From eZ Platform 3.x and Ibexa 4.x or 5.x

These sources have dropped the legacy-only tables on fresh installs (their schemas have 50 or 52 tables), so the
legacy kernel finds its shop, workflow, collaboration and notification tables missing.

1. Migrate the platform side to the matching line (3.3, 4.6 or 5) as a platform upgrade of the same generation:
   package swap to the `se7enxweb` forks, the line's project layout, the configuration.
2. **Create the legacy-only tables** from `ezpublish_legacy/kernel/sql/<engine>/` as [7.8](07-databases.md#78-which-tables-the-installer-creates)
   explains (on 5, the installer of a fresh project does this itself; on a migrated 5 database do it by hand with
   `CREATE TABLE IF NOT EXISTS`).
3. **On a 5.0 database**, activate the translator extension first in `ActiveExtensions[]`
   ([10.6](10-upgrading-between-lines.md#106-from-33-to-46-and-from-46-to-5)). If the 5.0 database stores the new
   datatype identifiers (`ibexa_string` and the like), chapter 16.6.3 of the Exponential 6 book shows how to set
   them back; the translator also rewrites them in queries.
4. Check every field type against the legacy datatypes (chapter 16.6.3 of the Exponential 6 book) and decide for
   each one that has none.
5. Build the legacy siteaccesses (`legacy_admin` at least) and their settings, then the legacy cron.

Commercial features of the source product (page builder, forms, personalization and the like) have no counterpart in
either kernel of this distribution. Netgen Layouts, part of the 4.6 and 5 lines, is the page-building option on the
Symfony side; chapter 16.5.9 of the Exponential 6 book compares them.

## 11.7 What is specific to this distribution

- **Never run the installer against a migrated database.** `ezplatform:install` / `exponential:install` drop the
  tables they create before creating them ([chapter 4](04-installing.md)); they are for empty databases.
- **One database, both kernels.** Every repair, conversion and update step is applied once, to the shared database;
  test the result in both admins.
- **Connection settings only in Symfony.** Remove database credentials from the migrated legacy INI files; the bridge
  injects them and a forgotten copy only misleads.
- **Siteaccess names must match** on both sides, and the legacy ones need `legacy_mode: true`.
- **Image aliases come from YAML** ([8.7](08-configuration.md#87-image-variations-and-image-aliases)); legacy-only
  aliases in `image.ini` disappear unless declared as variations.
- **Run legacy scripts through the bridge**, including the repair scripts of chapter 14.5.6 of the Exponential 6
  book, once the database is behind the platform's connection.
- **Sign-in on the public side is Symfony's** on siteaccesses without `legacy_mode` ([8.2](08-configuration.md#82-what-the-bridge-injects));
  legacy password hashes are read by both kernels (Exponential 6 book, chapter 17).

## 11.8 Checklist

- [ ] Target line chosen from the source generation (11.1)
- [ ] Exponential 6 book chapter for the source read; inventory of datatypes, extensions, designs, siteaccesses taken
- [ ] Database converted to `utf8mb4`/InnoDB (MySQL), legacy chain to 5.4 applied where needed
- [ ] Platform update files of the target line applied, legacy kernel 6.0 files applied last
- [ ] Legacy-only tables present (7.8); translator active on 5
- [ ] Project of the target line created, installer **not** run against the data
- [ ] Storage directory moved; web root's `var` link points to it
- [ ] Legacy settings moved, connection values removed; siteaccesses declared in YAML with `legacy_mode`
- [ ] Image aliases of the legacy designs declared as variations
- [ ] Extensions ported and active; autoloads regenerated
- [ ] Caches cleared on both sides, search reindexed, cron running through the bridge
- [ ] Front end, platform admin and legacy admin verified; one edit and one publish from each admin

## References

The Exponential 6 book, chapters [14](https://github.com/se7enxweb/exponential/blob/main/doc/install/14-migrating-from-4x.md),
[15](https://github.com/se7enxweb/exponential/blob/main/doc/install/15-migrating-from-5x-legacy.md),
[16](https://github.com/se7enxweb/exponential/blob/main/doc/install/16-migrating-from-ez-platform-and-ibexa.md),
[17](https://github.com/se7enxweb/exponential/blob/main/doc/install/17-migration-reference.md),
[11](https://github.com/se7enxweb/exponential/blob/main/doc/install/11-upgrading.md) and
[13](https://github.com/se7enxweb/exponential/blob/main/doc/install/13-security-hardening.md); the
[package forks and command renames](https://github.com/se7enxweb/exponential/blob/main/doc/bc/6.0/platform-package-forks-and-command-renames.md) notes.

Repositories: [se7enxweb/ezpublish-kernel](https://github.com/se7enxweb/ezpublish-kernel) (`data/update/`),
[se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`),
[se7enxweb/exponential](https://github.com/se7enxweb/exponential) (`update/database/`, `kernel/sql/`),
[se7enxweb/NetgenRichTextDataTypeBundle](https://github.com/se7enxweb/NetgenRichTextDataTypeBundle) (Composer package `se7enxweb/richtext-datatype-bundle`),
[se7enxweb/ezplatform-xmltext-fieldtype](https://github.com/se7enxweb/ezplatform-xmltext-fieldtype).

Upstream: [Update from v1.13 and v2.x](https://doc.ibexa.co/en/2.5/update_and_migration/from_1.x_2.x/update_from_1.x_2.x/),
[Update database to v2.5](https://doc.ibexa.co/en/2.5/update_and_migration/from_1.x_2.x/update_db_to_2.5/),
[Ibexa update and migration](https://doc.ibexa.co/en/latest/update_and_migration/update_ibexa_dxp/),
[field type reference](https://doc.ibexa.co/en/latest/content_management/field_types/field_type_reference/field_type_reference/),
[SiteAccess](https://doc.ibexa.co/en/latest/multisite/siteaccess/siteaccess/).

[Previous: 10. Upgrading between release lines](10-upgrading-between-lines.md) ·
[Next: 12. Troubleshooting](12-troubleshooting.md) · [Contents](README.md)
