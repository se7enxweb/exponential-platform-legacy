# 10. Upgrading between release lines

Exponential Platform Legacy has four maintained release lines, one per platform generation: 2.5 (branch `master`),
3.3 (`3.x`), 4.6 (`4.6.x`) and 5 (`5.x`). Within a line you update with Composer; between lines the Symfony
framework, the platform kernel, the bridge, the project layout and, from 4.6 to 5, the database's table names change.
The legacy kernel inside stays the same product (Exponential 6.0) on every line, which is what makes a step-by-step
move possible: your content, your legacy designs and your legacy extensions travel with you. This chapter gives the
facts of each line, the general method, and each step (2.5 to 3.3, 3.3 to 4.6, 4.6 to 5) with the database files and
configuration changes involved, verified against the branches, the tags and the bridge source, and says plainly
where the upstream documentation has to be followed instead.

[Previous: 9. Operations](09-operations.md) ·
[Next: 11. Migrating into Exponential Platform Legacy](11-migrating-into.md) · [Contents](README.md)

## Contents of this chapter

- [10.1 The release lines](#101-the-release-lines)
- [10.2 Which line do you run?](#102-which-line-do-you-run)
- [10.3 Updating within a line](#103-updating-within-a-line)
- [10.4 The method for a line change](#104-the-method-for-a-line-change)
- [10.5 From 2.5 to 3.3](#105-from-25-to-33)
- [10.6 From 3.3 to 4.6, and from 4.6 to 5](#106-from-33-to-46-and-from-46-to-5)
- [10.7 The legacy kernel inside every line](#107-the-legacy-kernel-inside-every-line)
- [10.8 Verify and roll back](#108-verify-and-roll-back)
- [References](#references)

## 10.1 The release lines

| | 2.5 | 3.3 | 4.6 | 5 |
|---|---|---|---|---|
| Branch | `master` | `3.x` | `4.6.x` | `5.x` |
| Tags | `v2.5.0.0` to `v2.5.0.3` | `v3.0.0.0` to `v3.0.0.14`, `v3.3.44.0` to `v3.3.44.7` | `v4.6.23.0` to `v4.6.23.2` | `v5.0.0` to `v5.0.2` (and see the note on `v5.0.3`) |
| Composer constraint for a new project | `dev-master` (alias `2.5.x-dev`) or `v2.5.0.3` | `3.x-dev` or `v3.3.44.7` | `4.6.x-dev` or `v4.6.23.2` | `5.x-dev` or `v5.0.2` |
| PHP (`composer.json`) | `^7.1.3 \|\| ^8.1 \|\| ^8.2` | `^8.0` | `^7.4` to `^8.5` (the bridge `^4.0.0.0` itself needs `^8.0`) | `>=8.3` (the bridge `^5.0.0.0` needs `^8.4`, so 8.4 in practice) |
| Symfony | 3.4 (`se7enxweb/symfony ^3.4.50`) | 5.4 | 5.4 | 7.x (`symfony/runtime ^7.3`; the bridge requires `symfony/framework-bundle ^7.4`) |
| Platform kernel | `se7enxweb/ezpublish-kernel ~7.5.33` | `se7enxweb/ezplatform-kernel ~1.3.43`, `se7enxweb/oss ~3.3.0.0` | `se7enxweb/exponential-platform-dxp 4.6.x-LB-dev` (kernel `se7enxweb/exponential-platform-dxp-core`) | `se7enxweb/exponential-platform-dxp dev-5.x-LB` |
| Bridge (`se7enxweb/legacy-bridge`) | `^2.1` (`v2.1.10` to `v2.1.12`) | `^3.0.0.35` (to `v3.0.0.37`) | `^4.0.0.0` (`v4.0.0.0` to `v4.0.0.3`) | `^5.0.0.0` (`v5.0.0.0`, `v5.0.1` to `v5.0.10`) |
| Legacy kernel | `se7enxweb/exponential ^6.0.12` | `^6.0.12` (through the bridge) | `dev-main` (through the bridge) | `dev-main` (through the bridge) |
| Console | `bin/console` | `bin/console` | `bin/console` | `bin/console` |
| Configuration | `app/config/*.yml`, `parameters.yml` | `config/`, `.env`, `.env.local` | `config/` from the Flex recipe `4.6.x-LB-dev` | `config/` from the Flex recipe `5.0` |
| Web root | `web/` | `public/` | `public/` | `public/` |
| Page building | none | none | Netgen Layouts `^1.4` | Netgen Layouts `^2.0` |
| Table names | `ez*` | `ez*` | `ez*` | `ibexa_*`; the legacy kernel reads them through `sevenx_exponential_platform_v5_database_translator` |

The 4.6.x and 5.x branches of this repository hold only `composer.json`, the README and the install guide; the
project files (`config/`, `src/`, `bin/install-legacy-links`) are written by the Flex recipe in
[se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes) when Composer installs
`se7enxweb/exponential-platform-dxp`.

The older `1.x` and `2.0`/`2.2` branches are the upstream `ezsystems/ezplatform-legacy` history (Symfony 2.8, kernel
6.13 on `1.13`); they are not maintained and are not covered here.

**The tag `v5.0.3` is not on the 5.x line.** It was published on 2026-08-03 with release notes about 5.x fixes, but it
points to commit `8479bb7` on `master`, whose `composer.json` is the 2.5 line's (`se7enxweb/ezpublish-kernel
~7.5.33`, bridge `^2.1`). Packagist lists it as the newest stable version, so `composer create-project
se7enxweb/exponential-platform-legacy` **without a version** installs the 2.5 skeleton. Published tags are never moved
in this project, so the tag stays as it is. A constraint such as `^5.0` therefore currently resolves to `v5.0.3` and
installs 2.5. The maintainers plan a corrected release on the 5.x branch, `v5.0.3.1`, which sorts after `v5.0.3` and
will make `^5.0` resolve to the 5 line again; check `gh release list -R se7enxweb/exponential-platform-legacy` or
Packagist for it. Until it is published, always name the version or branch you want:

```bash
composer create-project se7enxweb/exponential-platform-legacy:5.x-dev my-site    # the 5 line, branch head
composer create-project se7enxweb/exponential-platform-legacy:v5.0.2 my-site     # the 5 line, newest 5.x tag
composer create-project se7enxweb/exponential-platform-legacy:~2.5.0.3 my-site   # the 2.5 line (v2.5.0.3)
```

Check the result before going on: `grep '"se7enxweb/legacy-bridge"' my-site/composer.json` must show `^5.0.0.0` for
the 5 line and `^2.1` for 2.5.

## 10.2 Which line do you run?

```bash
composer show se7enxweb/legacy-bridge | grep -E '^versions'
composer show se7enxweb/exponential | grep -E '^versions'
php bin/console --version
```

| `legacy-bridge` | Line |
|---|---|
| 2.1.x | 2.5 |
| 3.0.0.x | 3.3 |
| 4.x | 4.6 |
| 5.x | 5 |

The database says the same from the rows in `ezsite_data` ([7.9](07-databases.md#79-the-version-rows-in-ezsite_data)):
`ezplatform-release` exists from 3.0 on.

## 10.3 Updating within a line

Within a line, update the code with Composer against your project's lock file on a copy of the site first:

```bash
composer update --with-all-dependencies            # on staging; review the plan Composer prints
php bin/console cache:clear --env=prod
```

The line's Composer scripts then link the legacy kernel's assets and extensions and regenerate its autoloads
(2.5: `legacy-scripts`; 3.x and later: `auto-scripts` plus `project-scripts`, with `php bin/install-legacy-links` on
4.6 and 5). Afterwards apply the legacy kernel's database update if the kernel version moved ([10.7](#107-the-legacy-kernel-inside-every-line))
and clear both sides' caches ([9.1](09-operations.md#91-caches-on-both-sides)).

On the 2.5 line older documents of this repository recommend `--ignore-platform-reqs` for every install. Use it only
when Composer reports a platform requirement you have checked is irrelevant; it also hides real problems such as a
missing PHP extension.

## 10.4 The method for a line change

A line change replaces the Symfony project around the legacy kernel. In-place edits of an old skeleton tend to leave
half-converted configuration behind, so the dependable method is a **new project of the target line** into which the
site moves:

1. **Freeze and back up.** Stop cron and editors; back up the database, `ezpublish_legacy/var/site/storage`
   (`src/LegacyRoot/var/site/storage` on 4.6 and 5), the legacy overrides and your configuration ([9.7](09-operations.md#97-backups-and-restore)).
2. **Inventory your own code**: Symfony bundles and templates in `src/` and `app/Resources/views/` or `templates/`,
   legacy extensions in `ezpublish_legacy/extension/` that do not come from Composer, legacy designs, the legacy
   `settings/override/` and `settings/siteaccess/` files, and the siteaccess YAML.
3. **Bring the source to the last release of its line** (2.5: `v2.5.0.3`, kernel 7.5.x; 3.3: kernel 1.3.45) and the
   legacy kernel to its latest 6.0.x with its update files applied.
4. **Create the target project** from the target branch on a staging server, with a copy of the database.
5. **Apply the platform's database update files** for every step between the lines, in order (below).
6. **Move your code and configuration** across, converting the configuration format of each step.
7. **Move the storage directory** and run the line's Composer scripts so that the legacy links are recreated.
8. **Clear everything, reindex, verify** ([10.8](#108-verify-and-roll-back)); only then switch production.

Never skip a line: the platform's update files are written for one step at a time.

## 10.5 From 2.5 to 3.3

**Database.** The upstream update files live in the platform meta repository's `upgrade/db/` directory; the
Exponential fork [se7enxweb/exponential-platform](https://github.com/se7enxweb/exponential-platform) carries them on its
`master` branch, for MySQL and PostgreSQL:

| File | What it does |
|---|---|
| `upgrade/db/<engine>/ezplatform-2.5.latest-to-3.0.0.sql` | removes `ezpublish-version` and `ezplatform-release` from `ezsite_data` and inserts `ezplatform-release` `3.0.0`; widens `ezcontentclass_attribute.data_text1` to 255; adds `ezcontentclass_attribute.is_thumbnail`; adds `version` to `ezkeyword_attribute_link` and fills it; sets the default login pattern of `ezuser` fields |
| `upgrade/db/<engine>/ezplatform-3.2.0-to-3.3.0.sql` | creates `ibexa_setting` |
| `upgrade/db/<engine>/ezplatform-3.2.3-to-3.2.4.sql` | replaces the old `nospam@ez.no` addresses of the anonymous and admin users |

There are no files for 3.0 to 3.1 or 3.1 to 3.2. None of the files drops a table, so the legacy-only tables of a 2.5
database survive. Run them in this order on the copy:

```bash
mysql -u <user> -p <database> -e "SELECT value FROM ezsite_data WHERE name='ezpublish-version'"   # note it, e.g. 6.0.15stable
mysql -u <user> -p <database> < upgrade/db/mysql/ezplatform-2.5.latest-to-3.0.0.sql
mysql -u <user> -p <database> < upgrade/db/mysql/ezplatform-3.2.0-to-3.3.0.sql
mysql -u <user> -p <database> < upgrade/db/mysql/ezplatform-3.2.3-to-3.2.4.sql
mysql -u <user> -p <database> -e "INSERT INTO ezsite_data (name, value) VALUES ('ezpublish-version', '<the value you noted>')"
```

The first file deletes the `ezpublish-version` row; the last statement puts it back, so that the legacy kernel's own
update files (which use `UPDATE`) find it again ([7.9](07-databases.md#79-the-version-rows-in-ezsite_data)). If the
noted value was a platform version (`7.5.x`, written by the 2.5 kernel's update files), insert the legacy kernel
version the database really has instead, or `6.0.0` followed by the legacy kernel's `6.0.0-6.0.15` file
([10.7](#107-the-legacy-kernel-inside-every-line)).

Expected result: the three files run without errors, `SELECT * FROM ezsite_data` shows `ezplatform-release` `3.0.0`
and your `ezpublish-version` row, and the table `ibexa_setting` exists. The 3.0 file's `ALTER TABLE
ezcontentclass_attribute ADD COLUMN is_thumbnail` fails on a second run ("Duplicate column name"); a failure there
means the file has run before, not that the database is broken.

What can go wrong: on SQLite there are no upstream files. Apply the same changes by hand (they are few, see the
table) or move the site to MySQL or PostgreSQL first ([7.10](07-databases.md#710-moving-a-site-to-another-engine)).

**Configuration.** 2.5 and 3.x differ in layout:

| 2.5 | 3.x |
|---|---|
| `app/config/parameters.yml` (`env(DATABASE_*)`) | `.env.local`: `DATABASE_URL`, `APP_SECRET`, `APP_ENV` |
| `app/config/ezplatform.yml`, `ezpublish:` | `config/app/packages/ezpublish_siteaccess.yaml` (still `ezpublish:`) |
| `app/AppKernel.php` | `config/bundles.php` |
| `app/Resources/views/` | `templates/` |
| `web/` | `public/` |
| `ez_publish_legacy:` in `ezplatform.yml` | `ez_publish_legacy:` in the siteaccess file; injected legacy settings in `config/app/packages/legacy.yaml` |
| `SYMFONY_ENV`, `SYMFONY_DEBUG`, `SYMFONY_TRUSTED_PROXIES` read by `web/app.php` | `APP_ENV`, `APP_DEBUG`; trusted proxies from `TRUSTED_PROXIES` ([13.9](13-security-hardening.md#139-behind-a-proxy-trusted-proxies-on-both-sides)) |

Symfony-side code needs the 3.x changes of the bridge (Symfony 5 `TreeBuilder`, commands as services, `RequestEvent`
and `ResponseEvent`) and the platform's own 3.0 changes (the upstream overview lists them). Legacy extensions and
designs move unchanged.

**Commands** change names: `exponential:legacy:*` for the bridge, `exponential:install` and `exponential:reindex` for
the kernel from v1.3.45 on, `ibexa:cron:run` for cron; the 2.5 names stay as aliases.

Upstream reading: [Update from v2.5 to v3.3](https://doc.ibexa.co/en/3.3/update_and_migration/from_2.5/update_from_2.5/)
(eight steps; the database step uses the files above).

## 10.6 From 3.3 to 4.6, and from 4.6 to 5

These two steps follow the upstream update guides, which this distribution does not repeat in full. What is verified
here is what differs for Exponential Platform Legacy.

**3.3 to 4.6.**

- **Database.** Upstream runs `ibexa-3.3.latest-to-4.0.0.sql` and the 4.x update files from
  `vendor/ibexa/installer/upgrade/db/<engine>/` ([Update from v3.3 to v4.0](https://doc.ibexa.co/en/4.6/update_and_migration/from_3.3/to_4.0/)).
  That package is not part of the installs these lines produce (no `vendor/ibexa/installer` and no `ibexa-*.sql` file
  in a 4.6 or 5 install checked for this book), so obtain the files from the upstream release you migrate along and
  review them before running them. Table names stay `ez*`.
- **Netgen Layouts.** 4.6 brings Netgen Layouts 1.4, whose `nglayouts_*` tables do not exist in a 3.3 database. On a
  fresh 4.6 install on SQLite the kernel seed creates them (`data/sqlite/nglayouts_cleandata.sql`); on an upgraded
  database create them with Netgen Layouts' own migrations (see the Netgen Layouts upgrade documentation).
- **Project layout.** The 4.6 project comes from the Flex recipe: legacy overrides in `src/LegacySettings/override/`,
  siteaccess INI in `src/ezpublish_legacy/app/settings/siteaccess/`, storage in `src/LegacyRoot/var/site/storage`,
  all linked into `ezpublish_legacy/` by `bin/install-legacy-links`. Move your legacy settings there, not into
  `ezpublish_legacy/` directly.
- **Configuration keys** change from `ezpublish:` to `ibexa:`; the bridge's `ez_publish_legacy:` stays.
- **Bridge** `^4.0.0.0`, which installs the legacy kernel from `dev-main`.

**4.6 to 5.**

- **Database.** Upstream runs `ibexa-4.6.latest-to-5.0.0.sql` from `vendor/ibexa/installer/upgrade/db/<engine>/`,
  which renames many tables and columns (`ezcontentobject` to `ibexa_content`, `ezcontentclass` to
  `ibexa_content_type`, ...): [Update from v4.6 to v5.0](https://doc.ibexa.co/en/latest/update_and_migration/from_4.6/update_to_5.0/).
  The same caveat about `ibexa/installer` applies.
- **The legacy kernel on renamed tables.** The bridge `^5.0.0.0` requires
  `se7enxweb/sevenx_exponential_platform_v5_database_translator`, a legacy extension that subclasses the legacy MySQL,
  PostgreSQL and SQLite drivers and rewrites every query (95 table and column mappings, for example `ezuser` to
  `ibexa_user`, `ezsite_data` to `ibexa_site_data`). It works only when it is in `ActiveExtensions[]`, **first** in
  the list. The 5.0 recipe's `src/LegacySettings/override/site.ini.append.php` (sevenx-recipes `b4dd83a`) does not
  list it; add it yourself:

  ```ini
  [ExtensionSettings]
  ActiveExtensions[]
  ActiveExtensions[]=sevenx_exponential_platform_v5_database_translator
  ActiveExtensions[]=app
  ...
  ```

  Without it the legacy kernel fails with "table not found" errors on its first query.
- **Legacy-only tables.** The upstream script renames the platform's tables; the legacy-only tables keep their `ez*`
  names, and the translator leaves names it does not map alone.
- **PHP 8.4 and Symfony 7.** Custom Symfony code needs the Symfony 7 changes; PHP must be 8.4 because of the bridge.
- **Netgen Layouts 2.0** replaces 1.4 (upgrade per Netgen's documentation).

## 10.7 The legacy kernel inside every line

The legacy kernel's own database updates are those of Exponential 6 and apply on every line, after the platform's
files of a line change:

| From | File (in `ezpublish_legacy/update/database/<engine>/`) |
|---|---|
| 5.4 | `6.0/dbupdate-5.4.0-6.0.0.sql` (MySQL), `6.0/dbupdate-5.4-to-6.0.sql` (PostgreSQL) |
| any 6.0.x | `6.0/dbupdate-6.0.0-6.0.15.sql` (MySQL, PostgreSQL, SQLite), present from Exponential 6.0.15 |

The 6.0.15 file sets `ezpublish-version` to `6.0.15stable`, widens `ezuser.password_hash` to 255 characters and adds
the tables and columns of 6.0.15's features (`expaudit_*`, `expmail_*`, `expbookmark_folder`,
`ezrss_export_opml_item`, new columns on `ezpdf_export`, `ezrss_export` and `ezcontentbrowsebookmark`). Run it
**once**: its own comments say that the statements adding columns stop with an error on a second run. If a run
breaks off half way, compare the schema with the file and apply only the statements that are still missing. Lines 2.5 and 3.3 get 6.0.15 when it is tagged (they require `^6.0.12`); lines 4.6 and 5 track
`dev-main` and get its code with their next update, so they need the file as soon as they update.

On a 5 database apply the legacy file with care: it addresses the legacy table names (`ALTER TABLE ezuser ...`,
`UPDATE ezsite_data ...`), and a SQL client does not go through the translator. For each statement on a table the
5.0 schema renamed, use the new name from the translator's `classes/sql_rewriter.php` (for example `ibexa_user`,
`ibexa_site_data`); statements on legacy-only tables run as they are. This mapping has not been tested end to end for
this book; try it on a copy.

Chapter 11 of the Exponential 6 book explains the legacy kernel's update chain from 3.x and 4.x and what changed in
each 6.0.x release.

## 10.8 Verify and roll back

After each step, on staging:

```bash
php bin/console cache:clear --env=prod
$LS bin/php/ezcache.php --clear-all            # see 9.1 for LS
php bin/console exponential:reindex --env=prod  # ezplatform:reindex on 2.5
php bin/console doctrine:schema:validate --env=prod
```

Then open the front page, a content page of each content type, the platform admin, the legacy admin (`/legacy_admin/`
on 2.5, 4.6 and 5), edit and publish one item from each admin, upload an image, run the legacy cron parts by hand and
read `var/log*/` and `ezpublish_legacy/var/log/error.log`. Compare row counts of the main tables with the source.

Rollback is the backup of step 1: the platform's update files alter rows and drop no tables but cannot be undone by
another SQL file. Keep the old installation and its database untouched until the new one has run in production for a
while.

## References

In this repository: [`composer.json`](../../composer.json) of the 2.5 line; the other lines' `composer.json` on
[3.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/composer.json),
[4.6.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/4.6.x/composer.json),
[5.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/5.x/composer.json);
[releases](https://github.com/se7enxweb/exponential-platform-legacy/releases); [`UPGRADE.md`](../../UPGRADE.md).

Related repositories: [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`),
[se7enxweb/exponential-platform](https://github.com/se7enxweb/exponential-platform) (`upgrade/db/`),
[se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes),
[se7enxweb/sevenx_exponential_platform_v5_database_translator](https://github.com/se7enxweb/sevenx_exponential_platform_v5_database_translator).

The Exponential 6 book: [chapter 11, upgrading](https://github.com/se7enxweb/exponential/blob/main/doc/install/11-upgrading.md),
[chapter 16, migrating from eZ Platform and Ibexa](https://github.com/se7enxweb/exponential/blob/main/doc/install/16-migrating-from-ez-platform-and-ibexa.md),
and the [package forks and command renames](https://github.com/se7enxweb/exponential/blob/main/doc/bc/6.0/platform-package-forks-and-command-renames.md) notes.

Upstream: [Update from v2.5 to v3.3](https://doc.ibexa.co/en/3.3/update_and_migration/from_2.5/update_from_2.5/),
[Update from v3.3 to v4.0](https://doc.ibexa.co/en/4.6/update_and_migration/from_3.3/to_4.0/),
[Update from v4.6 to v5.0](https://doc.ibexa.co/en/latest/update_and_migration/from_4.6/update_to_5.0/);
Symfony [upgrading a major version](https://symfony.com/doc/current/setup/upgrade_major.html); Composer
[`create-project`](https://getcomposer.org/doc/03-cli.md#create-project).

[Previous: 9. Operations](09-operations.md) ·
[Next: 11. Migrating into Exponential Platform Legacy](11-migrating-into.md) · [Contents](README.md)
