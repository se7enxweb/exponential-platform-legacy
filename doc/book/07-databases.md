# 7. Databases

Exponential Platform Legacy keeps one content repository in one database. The Symfony side reaches it through
Doctrine DBAL; the legacy kernel inside reaches the same database through its own driver layer (`eZDB`). Nobody
configures the legacy side's connection by hand: on every request and every bridged console command the legacy bridge
reads the Doctrine connection and injects it into the legacy kernel's `site.ini [DatabaseSettings]`. This chapter
explains that hand-over, how each release line writes the connection (`parameters.yml` on 2.5, `DATABASE_URL` from
3.x on), what MySQL/MariaDB, PostgreSQL and SQLite need on each line, which tables each line's installer creates,
and how to move a site from one engine to another.

[Previous: 6. Serving the site](06-serving-the-site.md) ·
[Next: 8. Configuration: YAML and INI](08-configuration.md) · [Contents](README.md)

## Contents of this chapter

- [7.1 One database, two drivers](#71-one-database-two-drivers)
- [7.2 How the bridge hands the connection to the legacy kernel](#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)
- [7.3 Writing the connection, line by line](#73-writing-the-connection-line-by-line)
- [7.4 MySQL and MariaDB](#74-mysql-and-mariadb)
- [7.5 PostgreSQL](#75-postgresql)
- [7.6 SQLite](#76-sqlite)
- [7.7 Oracle](#77-oracle)
- [7.8 Which tables the installer creates](#78-which-tables-the-installer-creates)
- [7.9 The version rows in ezsite_data](#79-the-version-rows-in-ezsite_data)
- [7.10 Moving a site to another engine](#710-moving-a-site-to-another-engine)
- [References](#references)

## 7.1 One database, two drivers

| | Symfony side | Legacy kernel (`ezpublish_legacy/`) |
|---|---|---|
| Library | Doctrine DBAL (2.13 on 2.5, 3.x and 4.6 installs; 3.10 on a 5.x install) | `lib/ezdb/classes/` of the legacy kernel (`eZMySQLiDB`, `eZPostgreSQLDB`, `eZSQLite3DB`) |
| Where its settings come from | `app/config/parameters.yml` (2.5) or `DATABASE_URL` (3.x, 4.6, 5.x) | injected by the bridge at kernel build time; the INI files carry no connection |
| Schema it expects | the platform kernel's schema (`ez*` tables on 2.5, 3.x and 4.6; `ibexa_*` tables on 5.x) | the legacy kernel's `ez*` schema |
| Writes | content repository, Doctrine entities of the project and bundles | content repository, plus the legacy-only tables (shop, workflow, collaboration, notifications, ...) |

Both sides read and write the same rows. A content item published in the platform's admin is the same
`ezcontentobject` row the legacy admin edits, which is the whole point of the distribution and also its main
operational rule: **back up, restore, upgrade and convert the database as one unit**, never one side alone.

The legacy kernel's driver aliases (`site.ini [DatabaseSettings] ImplementationAlias[]`) are the same as in
Exponential 6: `ezmysqli`, `mysqli`, `ezmysql` and `mysql` map to `eZMySQLiDB`; `ezpostgresql`, `postgresql` and
`pgsql` to `eZPostgreSQLDB`; `sqlite3` to `eZSQLite3DB` (verified in `settings/site.ini` of `se7enxweb/exponential`
v6.0.12 and v6.0.14). Chapter 9 of the Exponential 6 book describes each driver in depth; what this chapter adds is
how the platform's connection becomes those settings.

## 7.2 How the bridge hands the connection to the legacy kernel

The listener is `LegacyMapper\Configuration::onBuildKernel()` in the bridge (Composer package `se7enxweb/legacy-bridge`, repository [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge); priority 128 on the
`PRE_BUILD_LEGACY_KERNEL` event; the same code on the `v2.1.x`, `3.x`, `4.x` and `5.x` tags). It takes the
parameters of the platform's database connection and turns them into injected INI settings:

| Doctrine connection parameter | Injected legacy setting |
|---|---|
| `host` | `site.ini/DatabaseSettings/Server` |
| `port` | `site.ini/DatabaseSettings/Port` |
| `user` | `site.ini/DatabaseSettings/User` |
| `password` | `site.ini/DatabaseSettings/Password` |
| `dbname` | `site.ini/DatabaseSettings/Database` |
| `unix_socket` | `site.ini/DatabaseSettings/Socket` (`disabled` when the parameter is absent) |
| `driver` | `site.ini/DatabaseSettings/DatabaseImplementation`, through the map below |
| `path` (only when the driver is `pdo_sqlite`) | `site.ini/DatabaseSettings/Database` (the absolute path of the file) |

| Doctrine driver | Legacy implementation |
|---|---|
| `pdo_mysql` | `ezmysqli` |
| `pdo_pgsql` | `ezpostgresql` |
| `pdo_sqlite` | `sqlite3` |
| `oci8` | `ezoracle` (needs the `ezoracle` extension, see [7.7](#77-oracle)) |
| anything else | the kernel build fails: "Could not map database driver to Legacy Stack database implementation." |

Three consequences follow, and they explain most database trouble in this distribution:

1. **Injected settings win over INI files.** `eZINI` checks its injected settings before the values read from
   `settings/override/` or `settings/siteaccess/` (`lib/ezutils/classes/ezini.php`, `$injectedSettings`). A
   `[DatabaseSettings]` block in a legacy override is therefore ignored for every request and every console command
   that goes through the bridge. The overrides the distribution ships accordingly carry no connection: the
   `[DatabaseSettings]` block of master's `ezpublish_legacy/settings/override/site.ini.append.php` has
   `Charset=utf8mb4` and two commented SQLite lines; the one in `src/LegacySettings/override/site.ini.append.php` of
   the 4.6 line's recipe has `Charset=utf8mb4` only, and the 5 line's recipe adds the same two SQLite lines,
   commented out. Uncommenting them changes nothing on a bridged request.
2. **A legacy script started directly does not get the connection.** `php ezpublish_legacy/runcronjobs.php` or
   `cd ezpublish_legacy && php bin/php/ezcache.php` bypasses the bridge, so the legacy kernel falls back to the
   defaults of `settings/site.ini` and cannot reach the site's database. Run legacy scripts through the bridge:

   ```bash
   php bin/console ezpublish:legacy:script bin/php/ezcache.php --clear-all          # 2.5 line
   php bin/console exponential:legacy:script bin/php/ezcache.php --clear-all        # 3.x, 4.6, 5.x lines
   ```

   (`ezpublish:legacy:script` remains an alias on 3.x and later.) The only legacy script that is fine to run directly
   is `bin/php/ezpgenerateautoloads.php`, which does not touch the database.
3. **The driver must be one of the four mapped ones.** `mysqli://`, `pdo_oci` or a custom driver class in the
   Doctrine configuration stop the legacy kernel from building, on the web and on the console.

The same listener also injects `site.ini [FileSettings] VarDir` and `StorageDir` from the siteaccess's `var_dir` and
`storage_dir`, the anonymous user id, the image settings and, when `dfs_nfs_path` is set, the DFS cluster settings
(`file.ini [ClusteringSettings]`, `[eZDFSClusteringSettings]`, taken from the `dfs_database_*` parameters). The full
list is in [chapter 8](08-configuration.md#82-what-the-bridge-injects).

## 7.3 Writing the connection, line by line

### 2.5 line (master): `parameters.yml` and environment variables

`app/config/config.yml` builds the Doctrine connection `default` from parameters; `app/config/default_parameters.yml`
maps those parameters to environment variables, and `app/config/parameters.yml` (created from
`parameters.yml.dist` by `incenteev/composer-parameter-handler` during `composer install`) gives the fallbacks:

```yaml
# app/config/parameters.yml
parameters:
    env(SYMFONY_SECRET): <a long random string>
    env(DATABASE_DRIVER): pdo_mysql        # pdo_mysql, pdo_pgsql or pdo_sqlite
    env(DATABASE_HOST): localhost
    env(DATABASE_PORT): ~                  # ~ = the driver's default port
    env(DATABASE_NAME): exponential
    env(DATABASE_USER): exponential
    env(DATABASE_PASSWORD): <password>
    env(DATABASE_CHARSET): utf8mb4
    env(DATABASE_COLLATION): utf8mb4_unicode_520_ci   # used by MySQL only
```

Real environment variables of the same names (`DATABASE_HOST`, ...) win over these `env()` fallbacks at run time,
which is how containers and the PHP-FPM pool configure the site without editing the file.

For SQLite the connection uses `path`. `default_parameters.yml` sets
`database_path: '%kernel.project_dir%/var/data_%kernel.environment%.db'`, so with `DATABASE_DRIVER` set to
`pdo_sqlite` the file is `var/data_prod.db` in production and `var/data_dev.db` in development. To put it elsewhere,
set the environment variable `DATABASE_PATH`; `app/config/env/generic.php` copies it into `database_path` **at
container compile time**, so clear the Symfony cache after changing it.

### 3.x, 4.6 and 5.x lines: `DATABASE_URL`

From 3.x on, `config/packages/doctrine.yaml` has `doctrine.dbal.url: '%env(resolve:DATABASE_URL)%'`. Put the URL in
`.env.local` (never in the committed `.env`) or in the real environment:

```dotenv
# MySQL / MariaDB: give the server version, Doctrine needs it before it connects
DATABASE_URL="mysql://exponential:<password>@127.0.0.1:3306/exponential?serverVersion=mariadb-10.6.0&charset=utf8mb4"
# PostgreSQL
DATABASE_URL="pgsql://exponential:<password>@127.0.0.1:5432/exponential?serverVersion=16"
# SQLite: an absolute path, one file per environment
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_%kernel.environment%.db"
```

Doctrine turns the scheme into a driver (`mysql` to `pdo_mysql`, `pgsql` or `postgresql` to `pdo_pgsql`, `sqlite`
to `pdo_sqlite`) before the bridge sees the parameters, so the mapping of [7.2](#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)
works unchanged. The shipped `.env` files also contain `DATABASE_DRIVER`, `DATABASE_HOST` and friends (the 3.x `.env`
has them commented out); with the URL form they are not used for the connection. `DATABASE_CHARSET` and
`DATABASE_COLLATION` remain in use by the doctrine schema bundle for the table options it generates.

The shipped `.env` of the 3.x branch contains a working-looking demonstration URL with a user and password for a
database called `demo_platformlegacy`. Replace it in `.env.local`; never deploy with it.

**Special characters in the password.** The value is parsed as a URL, so a password containing `@`, `:`, `/`, `#`,
`?` or `%` must be percent-encoded (`@` becomes `%40`). Because of `resolve:`, Symfony also reads `%...%` as a
parameter reference, so write each `%` of an encoded character twice (`p%%40ss` for `p@ss`). The simplest way out
is a password of letters and digits only.

### Checking the connection on both sides

After writing the connection, check it from the Symfony side first and then through the bridge:

```bash
php bin/console --env=prod doctrine:query:sql "SELECT name, value FROM ezsite_data"       # 2.5, 3.x, 4.6
php bin/console --env=prod doctrine:query:sql "SELECT name, value FROM ibexa_site_data"   # 5
```

The command prints the rows of [7.9](#79-the-version-rows-in-ezsite_data), for example `ezpublish-version` with
its value, which proves that Doctrine reaches the database (3.x and later also know it as `dbal:run-sql`). Then
open `/legacy_admin/`: the legacy kernel is built with the injected connection, and a failure shows up as "Could not
map database driver" in the Symfony log or as a connection error in `ezpublish_legacy/var/log/error.log`.

What can go wrong:

- `SQLSTATE[HY000] [2002] No such file or directory` on MySQL: `localhost` makes PDO use the Unix socket. Write
  `127.0.0.1` to connect over TCP, or give the socket path (`unix_socket`, which the bridge also injects).
- `Access denied for user ...` although the password is right: an unencoded special character (above).
- The Symfony side works, a legacy script does not: the script was started without the bridge (point 2 of
  [7.2](#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)).

## 7.4 MySQL and MariaDB

Create the database with the character set and collation the schema bundle uses:

```sql
CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
CREATE USER 'exponential'@'localhost' IDENTIFIED BY '<password>';
GRANT ALL PRIVILEGES ON exponential.* TO 'exponential'@'localhost';
```

- The legacy override sets `Charset=utf8mb4`, so both sides talk to the server in the same character set.
- On the 2.5 line `config.yml` passes `%database_charset%` and `%database_collation%` to `ez_doctrine_schema` as
  table options; the comment there says to remove that block when the engine is not MySQL.
- On 3.x and later set `serverVersion` in `DATABASE_URL` (or `doctrine.dbal.server_version`); the shipped
  `doctrine.yaml` says so in capitals, because Doctrine otherwise has to connect just to find out.
- The installer creates the tables with InnoDB. The legacy kernel's own MySQL notes (strict mode, `utf8mb4`,
  backups with `--single-transaction`) apply unchanged: see chapter 9 of the Exponential 6 book.

## 7.5 PostgreSQL

```sql
CREATE USER exponential WITH PASSWORD '<password>';
CREATE DATABASE exponential OWNER exponential ENCODING 'UTF8';
\c exponential
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

**pgcrypto is needed by the legacy kernel, and nobody else creates it here.** The legacy PostgreSQL driver computes
MD5 values in SQL as `encode(digest(..., 'md5'), 'hex')` (`eZPostgreSQLDB::md5()`, in every 6.0.x release), and
`digest()` comes from the `pgcrypto` extension; the URL alias code uses it. The Exponential 6 installer creates the
extension, but in this distribution the platform's installer creates the database, and none of the platform kernels
does. Without it the platform side works and the legacy side fails with `function digest(text, unknown) does not
exist`. Create it once per database, as above (as the owner or a superuser; it is a trusted extension from
PostgreSQL 13 on); if the server lacks it, install the distribution's PostgreSQL contrib package first.

**Sequences.** Both kernels read the id of a new row from sequences named `<table>_<column>_seq` (for example
`ezcontentobject_id_seq`). A fresh install creates them with those names. A database that comes from eZ Publish 5.x
has the old names `<table>_s`; on the 2.5 line the platform kernel's `dbupdate-6.13.0-to-7.5.0.sql` renames them,
and since October 2026 the legacy kernel's 6.0 update files do the same, each rename only where the old name still
exists ([10.7](10-upgrading-between-lines.md#107-the-legacy-kernel-inside-every-line)). After loading rows with explicit
ids, move each sequence past the highest id, or the next insert fails with a duplicate key:

```sql
SELECT setval('ezcontentobject_id_seq', (SELECT max(id) FROM ezcontentobject));
```

Set the driver to `pdo_pgsql` (2.5) or use a `pgsql://` URL (3.x and later); the legacy kernel then runs on
`eZPostgreSQLDB`. One difference to MySQL matters on fresh installs: the PostgreSQL seed data of the 3.3 kernel
(`se7enxweb/ezplatform-kernel` v1.3.45, `data/postgresql/cleandata.sql`) creates no tables of its own, so the
legacy-only tables that the MySQL and SQLite seeds of that kernel add are missing on PostgreSQL. See
[7.8](#78-which-tables-the-installer-creates) for how to check and add them.

## 7.6 SQLite

Every line can install onto SQLite, but each does it differently, and on every line the SQLite file is opened twice:
once by PDO for the Symfony side and once by the legacy kernel's `eZSQLite3DB` with the injected absolute path.
Both PHP extensions, `pdo_sqlite` and `sqlite3`, must therefore be loaded (`php -m | grep -i sqlite`).

| Line | How the SQLite install works (verified in the code) | Command |
|---|---|---|
| 2.5 | `se7enxweb/ezpublish-kernel` (7.5.40 installed) registers the install type `exponential-oss` (`ExponentialOssInstaller`, a `CoreInstaller`). `CoreInstaller::importSchema()` switches to `SqliteDbPlatform` so that composite keys such as `PRIMARY KEY(id, version)` survive; the seed is the kernel's `data/sqlite/cleandata.sql`. | `php bin/console ezplatform:install exponential-oss` |
| 3.x | The project's own `App\Installer\ExponentialOssInstaller` (registered in `config/services.yaml` with the tag `ezplatform.installer`, type `exponential-oss`) reads the project's `data/sqlite/cleandata.sql` on SQLite; that seed starts with `PRAGMA journal_mode=WAL` and creates 73 legacy-only tables. The command is called `exponential:install` from kernel v1.3.45 on (with `ibexa:install` and `ezplatform:install` as aliases), `ibexa:install` before. | `php bin/console exponential:install exponential-oss` |
| 4.6 | The kernel package `se7enxweb/exponential-platform-dxp-core` ships `data/sqlite/cleandata.sql` and `data/sqlite/nglayouts_cleandata.sql`; the project's `ExponentialOssInstaller` (from the Flex recipe) adds the type `exponential-oss`. | `php bin/console exponential:install exponential-oss` |
| 5.x | As 4.6; in addition the kernel's `CoreInstaller` imports the Netgen Layouts schema and the legacy kernel's own `ezpublish_legacy/kernel/sql/sqlite/schema.sql` with every `CREATE TABLE` turned into `CREATE TABLE IF NOT EXISTS`. | `php bin/console exponential:install exponential-oss` |

After the install, the web server's user must be able to write the file **and the directory it is in** (SQLite
creates its journal or WAL file next to it):

```bash
chown <site user>:<web server group> var var/data_prod.db
chmod 664 var/data_prod.db && chmod 775 var
```

**Production.** The repository's own guides call SQLite a development, test and demonstration database for this
distribution, and that is the advice this book follows. The Exponential 6 kernel on its own runs SQLite as a
production database with queued writes and WAL (Exponential 6 book, chapter 9.2); here only one of the two
connections is that driver. The Symfony side writes through PDO with Doctrine's defaults and has none of the legacy
driver's write queueing, so two editors publishing at the same time can still meet "database is locked". Use
MySQL/MariaDB or PostgreSQL for anything with more than one writer, and keep the file on a local file system (never
NFS or CIFS).

## 7.7 Oracle

The bridge maps the Doctrine driver `oci8` to the legacy implementation `ezoracle`, which comes from the `ezoracle`
extension ([se7enxweb/ezoracle](https://github.com/se7enxweb/ezoracle)); the legacy kernel has no Oracle driver of its
own. The platform side is a different matter: none of the platform kernels of the four lines ships Oracle seed data
(their `data/` directories have `mysql`, `postgresql` and, from the Exponential forks, `sqlite` only), so there is no
supported way to install the platform onto Oracle. Treat Oracle as **not supported** for Exponential Platform Legacy;
for the legacy kernel alone see chapter 9.6 of the Exponential 6 book.

## 7.8 Which tables the installer creates

The legacy kernel needs tables the platform kernels stopped creating. How many are there after a fresh install
depends on the line:

| Line | Platform schema (`schema.yaml` of the kernel) | Legacy-only tables after `exponential-oss` / `clean` |
|---|---|---|
| 2.5 | 130 tables, the complete legacy schema (`ezbasket`, `ezcollab_*`, `ezorder`, `ezworkflow*`, `ezpdf_export`, `ezrss_export`, `ezsession`, `ezpending_actions`, `ezinfocollection`, ...) | all present |
| 3.x | 50 tables | MySQL and SQLite: added by the seed data (73 `CREATE TABLE` in kernel v1.3.45's MySQL and the project's SQLite seed). PostgreSQL: **missing** |
| 4.6 | 52 tables | **missing** on every engine (the 4.6 kernel's `CoreInstaller` imports no legacy schema; its MySQL seed creates no tables) |
| 5.x | 52 tables, renamed to `ibexa_*` | created from `ezpublish_legacy/kernel/sql/<engine>/` by the installer, `IF NOT EXISTS` |

A site **upgraded** from 2.5 keeps its legacy tables: the upstream 2.5 to 3.0 update file alters columns and rows but
drops no table (see [chapter 10](10-upgrading-between-lines.md)).

To find out what is missing, compare the table list of the database with the `CREATE TABLE` statements of the legacy
kernel's schema file for your engine: `ezpublish_legacy/kernel/sql/mysql/kernel_schema.sql` (118 tables in 6.0.14,
128 on `dev-main`), `ezpublish_legacy/kernel/sql/postgresql/kernel_schema.sql` or
`ezpublish_legacy/kernel/sql/sqlite/schema.sql`. On MySQL, one command lists the tables the legacy kernel expects and
the database lacks:

```bash
comm -23 \
  <(grep -oE '^CREATE TABLE [a-z0-9_]+' ezpublish_legacy/kernel/sql/mysql/kernel_schema.sql | awk '{print $3}' | sort -u) \
  <(mysql -N -u exponential -p exponential -e 'SHOW TABLES' | sort -u)
```

Expected output on a 2.5 install: nothing, or only the tables newer than the platform's schema (the `exp*` tables of
6.0.15). On a fresh 4.6 install: several dozen names, starting with `ezbasket`.

For columns as well as tables, the legacy kernel's own `ezsqldiff.php` compares the database with the reference
schema `share/db_schema.dba`. Give the reference first and the database second, as chapter 14.12 of the
Exponential 6 book does; it takes the credentials on the command line, so it can run without the bridge:

```bash
cd ezpublish_legacy
php bin/php/ezsqldiff.php --type=mysql --user=exponential --password=<password> share/db_schema.dba exponential
```

Its output is SQL, not a report: `CREATE TABLE` and `ADD` lines name what the legacy kernel misses; `DROP` lines name
what only the database has, which in this distribution includes every platform-only table and column (`ibexa_setting`,
`nglayouts_*`, `ezcontentclass_attribute.is_thumbnail`, ...). Read it, never run it as it is. On the 5 line, whose
platform tables carry `ibexa_*` names, both methods report every renamed table as missing; there, check only the
names the translator does not map ([10.6](10-upgrading-between-lines.md#106-from-33-to-46-and-from-46-to-5)).

The schema files use plain `CREATE TABLE`, so do not run them against an installed database as they are: take only
the statements for tables that are missing, review them, and run them on a copy first. Symptoms of missing tables
are SQL errors such as "Table ... doesn't exist" in `ezpublish_legacy/var/log/error.log` as soon as somebody uses the
legacy shop, workflows, collaboration, information collection, notifications, RSS or PDF export.

Exponential 6.0.15 adds tables of its own (the audit log `expaudit_*`, mail preferences `expmail_*`,
`expbookmark_folder`, `ezrss_export_opml_item`) through
`update/database/<engine>/6.0/dbupdate-6.0.0-6.0.15.sql` of the legacy kernel. Lines that install
`se7enxweb/exponential` from `dev-main` (4.6 and 5.x through their bridge) pick up the code that uses them on their
next update and need that file applied too; see [10.7](10-upgrading-between-lines.md#107-the-legacy-kernel-inside-every-line).
The order matters on a 4.6 install whose legacy-only tables are missing: the update file alters some of them
(`ezpdf_export`, `ezrss_export`, `ezcontentbrowsebookmark`) and stops when they do not exist. Create the missing
tables first, from the `kernel_schema.sql` of the legacy kernel you have installed; on `dev-main` that file already
contains the 6.0.15 tables and columns (128 `CREATE TABLE` statements against 118 in 6.0.14), so tables created
from it need no update file afterwards.

## 7.9 The version rows in ezsite_data

Both kernels record a version in `ezsite_data`, and on the 2.5 line they share the same row:

| Row | Written by |
|---|---|
| `ezpublish-version` | the legacy kernel's update files (`dbupdate-5.4.0-6.0.0.sql` sets `6.0.0`, `dbupdate-6.0.0-6.0.15.sql` sets `6.0.15stable`) **and** the 2.5 platform kernel's files in `vendor/se7enxweb/ezpublish-kernel/data/update/` (`dbupdate-5.4.0-to-6.13.0.sql` sets `6.13.0`, `dbupdate-6.13.0-to-7.5.0.sql` `7.5.0`, up to `dbupdate-7.5.6-to-7.5.7.sql` `7.5.7`) |
| `ezpublish-release` | the legacy kernel's update files |
| `ezplatform-release` | the platform's update files from 3.0 on (`ezplatform-2.5.latest-to-3.0.0.sql` writes `3.0.0`) |

So on 2.5 the value of `ezpublish-version` tells you which kernel's update file ran **last**, not which code runs:
`7.5.7` after the platform's file, `6.0.15stable` after the legacy kernel's. Read the installed versions from
Composer (`composer show se7enxweb/ezpublish-kernel se7enxweb/exponential`) instead. Apply the platform's files
first and the legacy kernel's last, so that the row ends at the legacy kernel's version, which is the one the legacy
kernel's own package manager (`ezpm.php`) reads.

The upstream 2.5 to 3.0 file **deletes** `ezpublish-version` (`DELETE FROM ezsite_data WHERE name IN
('ezpublish-version', 'ezplatform-release')`) and inserts only `ezplatform-release`. The legacy kernel's update files
use `UPDATE ... WHERE name='ezpublish-version'`, which then changes nothing. Note the value before you run the 3.0
file and put the row back afterwards, with the legacy kernel's version that the database had reached:

```sql
SELECT value FROM ezsite_data WHERE name = 'ezpublish-version';     -- before the 3.0 file, e.g. 6.0.15stable
INSERT INTO ezsite_data (name, value) VALUES ('ezpublish-version', '<that legacy version>');   -- after it
-- if the database never had a legacy update applied, insert 6.0.0 and run the 6.0.0 -> 6.0.15 file afterwards
```

## 7.10 Moving a site to another engine

The database is shared, so a conversion is one operation for both kernels. Back up first (database **and**
`ezpublish_legacy/var/<site>/storage`, which on 4.6 and 5.x is a link to `src/LegacyRoot/var/site/storage`), stop
writers (cron, editors), convert, then re-point the platform's connection; the legacy side follows automatically.

| From | To | Free tool | Notes |
|---|---|---|---|
| MySQL/MariaDB | PostgreSQL | [pgloader](https://pgloader.io/) | its main use case; cast `tinyint` to boolean only where the schema really uses booleans |
| SQLite | PostgreSQL | pgloader | native SQLite source |
| SQLite | MySQL/MariaDB | [sqlite3-to-mysql](https://github.com/techouse/sqlite3-to-mysql) | Python; check row counts afterwards |
| MySQL/MariaDB | SQLite | [mysql2sqlite](https://github.com/dumblob/mysql2sqlite) | dump with `--skip-extended-insert --compact` |
| PostgreSQL | SQLite | pgloader | `FROM postgresql:// INTO sqlite://` |

A safer alternative to converting the data with a generic tool is to install an empty site on the target engine with
the same release and then copy the rows table by table, because the target then has exactly the schema (keys,
sequences, composite primary keys) the installer produces for that engine.

After the switch:

```bash
# 1. new connection in parameters.yml (2.5) or DATABASE_URL (3.x and later)
php bin/console cache:clear --env=prod                         # the container holds the old connection
php bin/console ezpublish:legacy:script bin/php/ezcache.php --clear-all    # 2.5; exponential:legacy:script on 3.x+
php bin/console doctrine:schema:validate                       # Doctrine entities against the new database
php bin/console ezplatform:reindex                             # 2.5; exponential:reindex on 3.x and later
```

(There is no Doctrine migrations bundle on the 2.5 line; `doctrine:migrations:migrate` exists from 3.x on.) Check
the site, the platform admin and the legacy admin, then sequences: PostgreSQL sequences must be past the highest id of
each table, or the next insert fails with a duplicate key (the `setval` statement of [7.5](#75-postgresql)). A
conversion to PostgreSQL also needs the `pgcrypto` extension in the new database ([7.5](#75-postgresql)).

## References

In this repository:

- [`app/config/config.yml`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/app/config/config.yml), [`app/config/default_parameters.yml`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/app/config/default_parameters.yml),
  [`app/config/parameters.yml.dist`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/app/config/parameters.yml.dist), [`app/config/env/generic.php`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/app/config/env/generic.php) (2.5 line)
- [`ezpublish_legacy/settings/override/site.ini.append.php`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/ezpublish_legacy/settings/override/site.ini.append.php)
- Other lines: [3.x `config/packages/doctrine.yaml`](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/config/packages/doctrine.yaml),
  [3.x `src/Installer/ExponentialOssInstaller.php`](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/src/Installer/ExponentialOssInstaller.php),
  [3.x `data/sqlite/cleandata.sql`](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/data/sqlite/cleandata.sql)
- The bridge's connection mapping: `bundle/LegacyMapper/Configuration.php` in [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`)
- The 4.6 and 5.x project files come from the Flex recipes in [se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes)
- The 5.x table translation: [se7enxweb/sevenx_exponential_platform_v5_database_translator](https://github.com/se7enxweb/sevenx_exponential_platform_v5_database_translator)

The Exponential 6 book (the legacy kernel):

- [Chapter 9: Databases](https://github.com/se7enxweb/exponential/blob/main/doc/install/09-databases.md): every legacy driver,
  SQLite with WAL and queued writes, MySQL, PostgreSQL, Oracle, cross-engine notes
- [Chapter 11: Upgrading](https://github.com/se7enxweb/exponential/blob/main/doc/install/11-upgrading.md): the legacy kernel's update files
- [Chapter 14: Migrating from the 4.x line](https://github.com/se7enxweb/exponential/blob/main/doc/install/14-migrating-from-4x.md),
  section 14.12: comparing a database with the reference schema (`ezsqldiff.php`)

External:

- Symfony: [Doctrine configuration (DATABASE_URL)](https://symfony.com/doc/current/doctrine.html#configuring-the-database),
  [environment variables](https://symfony.com/doc/current/configuration.html#configuration-based-on-environment-variables)
- Doctrine DBAL: [connection configuration and URLs](https://www.doctrine-project.org/projects/doctrine-dbal/en/latest/reference/configuration.html)
- Upstream concepts: [Ibexa DXP database requirements](https://doc.ibexa.co/en/latest/getting_started/requirements/)
- PHP: [PDO](https://www.php.net/manual/en/book.pdo.php), [SQLite3](https://www.php.net/manual/en/book.sqlite3.php)
- MySQL: [utf8mb4](https://dev.mysql.com/doc/refman/8.4/en/charset-unicode-utf8mb4.html); PostgreSQL:
  [CREATE DATABASE](https://www.postgresql.org/docs/current/sql-createdatabase.html),
  [pgcrypto](https://www.postgresql.org/docs/current/pgcrypto.html),
  [sequence functions](https://www.postgresql.org/docs/current/functions-sequence.html); SQLite: [WAL](https://www.sqlite.org/wal.html)

[Previous: 6. Serving the site](06-serving-the-site.md) ·
[Next: 8. Configuration: YAML and INI](08-configuration.md) · [Contents](README.md)
