# 4. Installing

This chapter takes a project created in [chapter 3](03-getting-the-code.md) to a working installation, line by line:
creating the database, writing the environment (`parameters.yml` on 2.5, `.env.local` from 3.x on), running the
platform installer that creates the schema and the initial content for both kernels, wiring up the legacy side (links,
assets, extensions, autoloads), the REST keys and GraphQL schema, the front-end build, permissions and caches, and the
first login to both administration interfaces. It also explains why the platform installer, not the legacy setup
wizard, is the installer of this product. Each section has a table or a block per line; section 4.13 repeats the whole
sequence per line as one script to copy.

[Previous: 3. Getting the code](03-getting-the-code.md) · [Next: 5. The legacy kernel inside](05-the-legacy-kernel-inside.md) ·
[Contents](README.md)

---

## Contents of this chapter

1. [The steps at a glance](#41-the-steps-at-a-glance)
2. [Before you start](#42-before-you-start)
3. [Create the database](#43-create-the-database)
4. [Configure the environment](#44-configure-the-environment)
5. [Run the platform installer](#45-run-the-platform-installer)
6. [Wire up the legacy kernel](#46-wire-up-the-legacy-kernel)
7. [REST keys and the GraphQL schema](#47-rest-keys-and-the-graphql-schema)
8. [Build the front-end assets](#48-build-the-front-end-assets)
9. [Permissions and caches](#49-permissions-and-caches)
10. [First login](#410-first-login)
11. [Platform installer or legacy setup wizard?](#411-platform-installer-or-legacy-setup-wizard)
12. [Verify the installation](#412-verify-the-installation)
13. [The whole install per line](#413-the-whole-install-per-line)
14. [References](#414-references)

---

## 4.1 The steps at a glance

| Step | 2.5 | 3.x | 4.6.x | 5.x |
|---|---|---|---|---|
| Environment file | `app/config/parameters.yml` | `.env.local` | `.env.local` | `.env.local` |
| Database connection | `env(DATABASE_*)` parameters | `DATABASE_URL` | `DATABASE_URL` | `DATABASE_URL` |
| Installer | `ezplatform:install clean` | `exponential:install exponential-oss` | `exponential:install exponential-oss` | `exponential:install exponential-oss` |
| Legacy links | not used | not used | `php bin/install-legacy-links` | `php bin/install-legacy-links` |
| Legacy assets into the web root | `ScriptHandler::installAssets` (Composer) | `ezpublish:legacy:assets_install` | the same | the same |
| Legacy autoloads | `ezpublish:legacy:script bin/php/ezpgenerateautoloads.php` | the same | the same | the same |
| REST keys (JWT) | not used | `lexik:jwt:generate-keypair` | the same | the same |
| Front-end build | `yarn encore production` | `yarn build:prod`, `yarn ez` | `yarn build`, `yarn ibexa:build` | the same as 4.6.x |
| Writable directories | `var/`, `web/var/`, `ezpublish_legacy/var/` | `var/`, `public/var/`, `ezpublish_legacy/var/` | the same plus `src/LegacyRoot/var/site/storage/` | the same as 4.6.x |

The Composer scripts of every line already ran most of the wiring during `create-project` (chapter 3,
[3.4](03-getting-the-code.md#34-composer-create-project-per-line)). Running those steps again is harmless; this chapter
lists them so that you can repeat them after a `--no-scripts` install, after adding an extension or when something is
missing.

## 4.2 Before you start

- The code is in place and `composer install` (or `create-project`) finished without errors.
- The PHP that runs `bin/console` is the one you checked in [chapter 2](02-requirements.md).
- **Know which environment the console uses.** On 2.5 `bin/console` defaults to `dev` (`SYMFONY_ENV`, else `dev`),
  while `web/app.php` defaults to `prod`. From 3.x on both read `APP_ENV` from the environment or `.env.local`. Run
  production commands with `--env=prod` or set the variable. The environment decides which configuration, and on 2.5
  which SQLite file (`var/data_<env>.db`), a command uses, so a `dev` command against a `prod` site writes to the
  wrong place without any error.
- **Where Symfony's options go.** Write `--env` (and `--siteaccess`) **before** the command name:
  `php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --clear-all`. Symfony would also find them
  after the script path, but there the bridge passes them on to the legacy script, and most legacy scripts reject an
  option they do not know (chapter 5, [5.7](05-the-legacy-kernel-inside.md#57-running-legacy-scripts-through-the-console)).
- To see every command your installation has, use `php bin/console list` and, for one area,
  `php bin/console list ezpublish` or `php bin/console list exponential`. Command names in this chapter were checked
  against the source of each line; `list` is the authority for your installation.

## 4.3 Create the database

Create an empty database and a user that owns it. The installer creates the tables.

**MySQL 8.0 or MariaDB:**

```sql
CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
CREATE USER 'db_user'@'localhost' IDENTIFIED BY 'db_password';
GRANT ALL PRIVILEGES ON exponential.* TO 'db_user'@'localhost';
```

`CREATE USER` and `GRANT` are separate statements: MySQL 8.0 no longer accepts `GRANT ... IDENTIFIED BY`, which the
4.6.x and 5.x installation guides of `v4.6.23.2` and `v5.0.2` still show (corrected in `v4.6.23.3`, commit `71fec70`,
and in `v5.0.3.1`, commit `58287e0`).

**PostgreSQL:**

```bash
sudo -u postgres psql -c "CREATE USER db_user WITH PASSWORD 'db_password';"
sudo -u postgres psql -c "CREATE DATABASE exponential OWNER db_user ENCODING 'UTF8';"
```

**SQLite:** nothing to create; the installer creates the file. Make sure the directory it goes to (`var/`) is writable
by the user that runs the installer and later by the web server.

Engine choice, versions, tuning and conversion between engines: [chapter 7](07-databases.md).

## 4.4 Configure the environment

### 4.4.1 The 2.5 line: parameters.yml

`app/config/parameters.yml` is created by Composer from `app/config/parameters.yml.dist` (or copy it yourself). It
holds the values that differ per server; it is not committed. The parameters are written as `env(...)` defaults, so a
real environment variable of the same name overrides them:

```yaml
# app/config/parameters.yml
parameters:
    # Used to sign cookies and tokens: 64 random hexadecimal characters, different on every server
    env(SYMFONY_SECRET): 'c0ffee...'

    env(DATABASE_DRIVER): pdo_mysql          # pdo_mysql, pdo_pgsql or pdo_sqlite
    env(DATABASE_HOST): localhost
    env(DATABASE_PORT): ~                    # ~ = the driver's default port
    env(DATABASE_NAME): exponential
    env(DATABASE_USER): db_user
    env(DATABASE_PASSWORD): db_password
    env(DATABASE_CHARSET): utf8mb4
    env(DATABASE_COLLATION): utf8mb4_unicode_520_ci
```

Generate the secret with `openssl rand -hex 32`.

For **SQLite** set `env(DATABASE_DRIVER): pdo_sqlite` and leave host, user and password unused. The file is
`var/data_<environment>.db` (`database_path` in `app/config/default_parameters.yml`); to place it elsewhere set the
**environment variable** `DATABASE_PATH`, which `app/config/env/generic.php` reads at container compilation. An
`env(DATABASE_PATH)` entry in `parameters.yml`, as the 2.5 guide shows, has no effect, because no configuration reads
`env(DATABASE_PATH)`.

Other values you may set here (all have defaults in `app/config/default_parameters.yml`): `env(SEARCH_ENGINE)`
(`legacy` or `solr`), `env(CACHE_POOL)`, `env(HTTPCACHE_PURGE_SERVER)`, `env(MAILER_HOST)`. Settings that must be known
at compile time are environment variables only: `HTTPCACHE_PURGE_TYPE`, `MAILER_TRANSPORT`, `LOG_TYPE`,
`SESSION_HANDLER_ID`, `CACHE_POOL` for the pool file ([chapter 8](08-configuration.md)).

Two committed legacy files on `master` contain a developer's host names and should be reviewed before production:
`ezpublish_legacy/settings/override/site.ini.append.php` sets `[SiteAccessSettings] MatchOrder=host` with
`HostMatchMapItems` for `platform.alpha.se7enx.com`, and `app/config/ezplatform.yml` carries the same host names in a
comment. Siteaccess matching is done by Symfony (`URIElement: 1`), so these legacy entries do not route requests; change
or remove them so that they do not mislead.

### 4.4.2 3.x, 4.6.x and 5.x: .env.local

Symfony reads `.env` (committed defaults), then `.env.local` (your values, never committed), then the real environment.
Create `.env.local`:

```dotenv
# .env.local
APP_ENV=prod
APP_SECRET=0123456789abcdef0123456789abcdef            # openssl rand -hex 16 or longer

# One DSN for the database. serverVersion matters for MySQL and MariaDB.
DATABASE_URL="mysql://db_user:db_password@127.0.0.1:3306/exponential?serverVersion=8.0&charset=utf8mb4"
# MariaDB:     ...?serverVersion=mariadb-10.6.0&charset=utf8mb4
# PostgreSQL:  DATABASE_URL="postgresql://db_user:db_password@127.0.0.1:5432/exponential?serverVersion=16&charset=utf8"
# SQLite:      DATABASE_URL="sqlite:///%kernel.project_dir%/var/data_%kernel.environment%.db"

# REST API keys (section 4.7)
JWT_PASSPHRASE=a-long-random-passphrase

# Only when a proxy, load balancer or Varnish is in front (chapter 6, 6.8)
# TRUSTED_PROXIES=127.0.0.1,10.0.0.0/8
```

Notes per line:

- **3.x.** `config/packages/doctrine.yaml` reads `DATABASE_URL`. The committed `.env` of the 3.x branch contains a
  `DATABASE_URL` with a demo database name and password; your `.env.local` must override it. `.env` also sets
  `APP_ENV=dev` and a placeholder `APP_SECRET`.
- **4.6.x and 5.x.** Flex writes the recipe's variables into `.env` (`SEARCH_ENGINE`, `CACHE_POOL`,
  `HTTPCACHE_PURGE_SERVER`, `DATABASE_CHARSET`, `DATABASE_COLLATION`, `DATABASE_VERSION`, `SOLR_DSN`, ...). The
  installation guides also show separate `DATABASE_HOST`, `DATABASE_USER` and similar variables and say `DATABASE_URL` is
  derived from them; check `config/packages/doctrine.yaml` in your project to see which form it reads. Setting
  `DATABASE_URL` in `.env.local` works for the Doctrine recipe's `url: '%env(resolve:DATABASE_URL)%'`.
- **SQLite on 4.6.x and 5.x.** The guides add `MESSENGER_TRANSPORT_DSN=sync://` so that Symfony Messenger does not need
  a second database connection.
- **`APP_ENV` under Apache.** A server variable wins over `.env.local`. The `public/.htaccess` of `v3.3.44.7` and of
  the 4.6.x and 5.x recipe sets `APP_ENV=dev` for every request, so the value you write here is ignored by the web
  server until that line is removed. The 3.x branch removed it (commit `66f13e1`, released in `v3.3.44.8`); for
  the recipe, chapter 6, [6.2.1](06-serving-the-site.md#621-shipped-files-to-check-before-production), shows the fix.
- **`.env.local.php`.** For production, `composer dump-env prod` compiles the files into `.env.local.php`, which is
  faster to load ([Symfony documentation](https://symfony.com/doc/current/configuration.html#configuring-environment-variables-in-production)).

The legacy kernel needs no database settings of its own: LegacyBridge injects the Doctrine connection into
`site.ini [DatabaseSettings]` at boot (chapter 5, [5.6](05-the-legacy-kernel-inside.md#56-ini-and-yaml-which-wins)).

## 4.5 Run the platform installer

The installer creates the schema, loads the initial content (the root folder, users and groups, roles, sections,
languages, content types) and clears the cache. Both kernels then work on that data.

| Line | Command | Install types | Source of the command |
|---|---|---|---|
| 2.5 | `php bin/console ezplatform:install clean` | `clean`; `exponential-oss` with `se7enxweb/ezpublish-kernel` 7.5.41 or later | `EzSystems\PlatformInstallerBundle` in `se7enxweb/ezpublish-kernel` |
| 3.x | `php bin/console exponential:install exponential-oss` | `ibexa-oss` (default), `exponential-oss` | `se7enxweb/ezplatform-kernel` 1.3 (aliases `ibexa:install`, `ezplatform:install`); `exponential-oss` is `src/Installer/ExponentialOssInstaller.php` |
| 4.6.x | `php bin/console exponential:install exponential-oss` | `ibexa-oss` (default), `exponential-oss` | the repository installer of the 4.6 core (aliases `ibexa:install`, `ezplatform:install`); `exponential-oss` comes from the recipe's `src/Installer/` |
| 5.x | `php bin/console exponential:install exponential-oss` | `ibexa-oss` (default), `exponential-oss` | the repository installer of the 5.0 core; `exponential-oss` from the recipe |

`exponential-oss` is the upstream "core" installer under the Exponential name. On SQLite it reads the project's own
`data/sqlite/cleandata.sql` (3.x) because the vendor package has no SQLite seed; on the 2.5 line the README names it as
the install type for SQLite, because it builds the composite primary keys SQLite needs.

```bash
# 2.5, MySQL, MariaDB or PostgreSQL
php bin/console ezplatform:install clean --env=prod
# 2.5, SQLite (needs se7enxweb/ezpublish-kernel 7.5.41 or later; composer show se7enxweb/ezpublish-kernel)
php bin/console ezplatform:install exponential-oss --env=prod

# 3.x, 4.6.x, 5.x
php bin/console exponential:install exponential-oss
php bin/console exponential:install --help        # the install types this installation knows
```

Behaviour worth knowing:

- The installer **removes existing tables** of the schema it installs. Never point it at a database that holds content
  you want to keep.
- On 3.x the command indexes the content after the import unless you pass `--skip-indexing`; on any line you can
  rebuild the index later with `php bin/console ezplatform:reindex` (2.5) or `php bin/console exponential:reindex`
  (3.x and later).
- The 2.5 skeleton has a Composer shortcut, `composer ezplatform-install`, which runs `ezplatform:install clean`.
- **Legacy-only tables (5.x).** The release notes published with the tag `v5.0.3` state that fresh 5.x installs import
  the legacy table set from `ezpublish_legacy/share/legacy_schema.sql`, so that the legacy admin does not fail with
  "Table does not exist", and that the installer now does this automatically. For 3.x and 4.6.x this book could not
  verify whether every legacy-only table is created; section 4.12 shows how to check. `legacy_schema.sql` is a MySQL
  dump that begins every table with `DROP TABLE IF EXISTS`; do not import it into a database whose content you want to
  keep.

What can go wrong at this step:

| Message | Cause | Fix |
|---|---|---|
| `Unknown install type 'exponential-oss'` | 2.5 with `se7enxweb/ezpublish-kernel` older than 7.5.41, or 4.6.x/5.x without the recipe's `src/Installer/` | `composer show se7enxweb/ezpublish-kernel`; on 2.5 use `clean`; on 4.6.x/5.x check that `config/services.yaml` registers `App\Installer\ExponentialOssInstaller` |
| `Command "exponential:install" is not defined` | 2.5 line: that name exists from 3.x on | `ezplatform:install` on 2.5 |
| `SQLSTATE[HY000] [1045] Access denied` / `[2002] Connection refused` | wrong credentials or host in section 4.4, or the database server is not running | test the same values with `mysql -u db_user -p -h 127.0.0.1 exponential` |
| `SQLSTATE[42000] ... Specified key was too long` | MySQL or MariaDB older than the line's minimum, or a database created with another character set | recreate the database as in section 4.3 on a supported server |
| the command stops while indexing | the Solr core is not reachable while `SEARCH_ENGINE=solr` | install with the default `legacy` engine, switch to Solr afterwards ([chapter 8](08-configuration.md)) |
| `attempt to write a readonly database` (SQLite) | the user running the command cannot write `var/` | fix the permissions (section 4.9) and run it again |

## 4.6 Wire up the legacy kernel

These steps connect `ezpublish_legacy/` to the project. The Composer scripts run them; run them yourself after
`--no-scripts`, after adding or removing a legacy extension, or when a legacy page misses its stylesheets.

```bash
# 4.6.x and 5.x only: link src/ into ezpublish_legacy/ (extension "app", settings, storage)
php bin/install-legacy-links

# Bundle assets into the web root (web on 2.5, public from 3.x on)
php bin/console assets:install --symlink --relative public

# Legacy design, extension and share directories, and the wrapper scripts (index_rest.php,
# index_cluster.php) into the web root. On 2.5 the Composer script handler does this.
php bin/console ezpublish:legacy:assets_install --symlink --relative public

# Legacy extensions that Symfony bundles carry, linked into ezpublish_legacy/extension/
php bin/console ezpublish:legacybundles:install_extensions --relative

# Legacy autoload arrays: after every change to the extensions
php bin/console ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
```

Command names: LegacyBridge 3 (every release the 3.x skeleton allows, from 3.0.0.35), 4 from 4.0.0.2 and 5 call these
commands `exponential:legacy:assets-install`, `exponential:legacy:install-extensions` and `exponential:legacy:script`
and keep the `ezpublish:` names as aliases. LegacyBridge 2 (the 2.5 line) and the releases 4.0.0.0 and 4.0.0.1 have
only the `ezpublish:` names. The `ezpublish:` spellings above therefore work on every line and with every bridge
release; `composer show se7enxweb/legacy-bridge` tells you which release you have. Two commands that the installation
guides of the tags up to `v2.5.0.3`, `v3.3.44.7` and `v4.6.23.2` mention, `ezpublish:legacy:clear-cache` and
`ezpublish:legacy:generate-autoloads`, exist in no LegacyBridge release; use `ezpublish:legacy:script` with
`bin/php/ezcache.php` and `bin/php/ezpgenerateautoloads.php` instead. The guides on the branches no longer name them
(3.x commit `e278fde`, released in `v3.3.44.8`; 4.6.x `4edf8a6`, released in `v4.6.23.3`).

`ezpublish:legacy:init` prepares a Symfony project that did not have the bridge before (it creates `src/legacy_files/`,
adds the legacy Composer scripts and routes). The skeletons are already prepared; do not run it on them.

## 4.7 REST keys and the GraphQL schema

From 3.x on the REST API authenticates with JSON Web Tokens signed by a key pair (LexikJWTAuthenticationBundle):

```bash
php bin/console lexik:jwt:generate-keypair          # writes config/jwt/private.pem and public.pem
php bin/console lexik:jwt:generate-keypair --overwrite   # to rotate them
```

The keys are excluded from git; back them up with the server's secrets. `JWT_PASSPHRASE` in `.env.local` protects the
private key.

The GraphQL schema is generated from the content types and must be regenerated whenever they change:

```bash
php bin/console ezplatform:graphql:generate-schema   # 2.5 and 3.x
php bin/console list graphql                         # 4.6.x and 5.x: shows the generate-schema command's current name
```

## 4.8 Build the front-end assets

| Line | Commands | Output |
|---|---|---|
| 2.5 | `nvm use 14 && yarn install && yarn encore production`; the site's own SCSS: `node_modules/.bin/encore production --config-name app` | `web/assets/build/`, `web/assets/ezplatform/build/`, `web/assets/app/` |
| 3.x | `nvm use && yarn install && yarn build:prod && yarn ez` | `public/assets/`, the Admin UI build |
| 4.6.x, 5.x `v5.0.2` | `nvm use 20 && corepack enable && yarn install && yarn build && yarn ibexa:build` | `public/assets/`, the Admin UI build |
| 5.x `v5.0.3.1` and branch | `nvm use 24 && npm install -g yarn@1.22.22 && yarn install && yarn build && yarn ibexa:build` | the same |

Then the JavaScript translations: `php bin/console bazinga:js-translation:dump web/assets --merge-domains` (2.5) or
`... public/assets --merge-domains`. On 2.5 also `php bin/console assetic:dump --env=prod`.

The scripts come from each line's `package.json`: 3.x defines `build:dev`, `build:prod` and `ez`; the 4.6.x and 5.x
recipe defines `dev`, `build`, `watch`, `ibexa:dev`, `ibexa:build`. The `yarn ez` that the 4.6.x README of
`v4.6.23.2` shows does not exist on 4.6.x; the branch README runs `yarn ibexa:build` since commit `eb63593` (released in `v4.6.23.3`). The 2.5
`package.json` has no scripts; `yarn encore` calls the Encore binary directly.

On the 3.x branch, `composer ibexa-assets` runs `yarn install` and `php bin/console ibexa:encore:compile`, the Admin UI
build that the `Makefile` (`make build`) and the Deployer recipe call; the script was added on 2026-10-05 (commit
`21004ae`, released in `v3.3.44.8`), so with `v3.3.44.7` those two stop with `Command "ibexa-assets" is not
defined` and you run the `yarn` commands of the table instead.

Build on a build machine or in CI and deploy the result if the production server has no Node.js. What a successful
build ends with, and the failures seen most often:

```text
 DONE  Compiled successfully in ...ms
 ...
 webpack compiled successfully
```

| Message | Cause | Fix |
|---|---|---|
| `error:0308010C:digital envelope routines::unsupported` | 2.5 built with Node 17 or later | `nvm use 14` |
| `The engine "node" is incompatible with this module` | Node older than the line expects | the Node version of chapter 2, [2.7](02-requirements.md#27-nodejs-and-yarn) |
| `error Command "ez" not found.` | a script name of another line (`yarn ez` or `yarn build:prod` exist on 3.x only) | the commands of the table above |
| `JavaScript heap out of memory` | a full Admin UI build on a small machine | `NODE_OPTIONS=--max-old-space-size=4096 yarn ...` |

## 4.9 Permissions and caches

The web server (or Velocity's workers) must write to a few directories and to nothing else:

| Line | Writable by the web server user |
|---|---|
| 2.5 | `var/`, `web/var/`, `ezpublish_legacy/var/` |
| 3.x | `var/`, `public/var/`, `ezpublish_legacy/var/` |
| 4.6.x, 5.x | `var/`, `public/var/`, `ezpublish_legacy/var/`, and `src/LegacyRoot/var/site/storage/` (the target of the `ezpublish_legacy/var/site/storage` link) |
| SQLite | additionally the database file and its directory (`var/`) |

With ACLs, so that both you and the web server user (here `www-data`) can write:

```bash
sudo setfacl -R  -m u:www-data:rwX -m u:"$USER":rwX var public/var ezpublish_legacy/var
sudo setfacl -dR -m u:www-data:rwX -m u:"$USER":rwX var public/var ezpublish_legacy/var
```

Replace `public/var` with `web/var` on 2.5 and add `src/LegacyRoot/var/site/storage` on 4.6.x and 5.x. Do not make the
whole project writable; [chapter 6](06-serving-the-site.md#67-file-permissions) covers ownership in detail.

Clear both caches at the end:

```bash
php bin/console cache:clear --env=prod
php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --clear-all
```

Why two commands: on every line LegacyBridge registers a Symfony cache clearer (`LegacyCachePurger`), so
`cache:clear` also empties the legacy **template, INI and translation** caches (`eZCache::fetchByTag('template,ini,i18n')`
in the bridge source). It does not touch the legacy content view cache, the image alias cache or the other legacy
caches; `ezcache.php --clear-all` does. After an install both are empty anyway, but the habit of running both after
every deploy saves a lot of searching later ([chapter 9](09-operations.md)).

## 4.10 First login

The initial content contains one administrator: user `admin`, password `publish`. This password is published in every
guide; **change it at the first login**.

| Line | New-stack Admin UI | Legacy admin | Public site |
|---|---|---|---|
| 2.5 | `/admin/` | `/legacy_admin/` | `/` |
| 3.x | `/adminui/` | `/legacy_admin/` | `/` |
| 4.6.x, 5.x | `/admin/` per the recipe's `admin` siteaccess (the READMEs say `/adminui/`) | `/legacy_admin/` | `/`; the legacy front end at `/legacy_site/` |

The paths follow from the siteaccess names because all lines match siteaccesses by the first URL segment
(`URIElement: 1`). To read them from your installation:

```bash
php bin/console debug:config ezpublish siteaccess     # 2.5 and 3.x
php bin/console debug:config ibexa siteaccess         # 4.6.x and 5.x
```

The 2.5 and 3.x READMEs also name `/ezpublish_legacy/` as the legacy admin address. No siteaccess of that name exists
in their configuration, and the legacy kernel's directory is not below the web root, so that address does not reach the
legacy admin. Use `/legacy_admin/`.

Change the password in either interface: in the legacy admin under *My account*, *Change password*; in the Admin UI
under the user menu. Both write the same user record.

## 4.11 Platform installer or legacy setup wizard?

Exponential 6 on its own is installed with its browser setup wizard, the kickstarter or `exp:install`
([the Exponential 6 book, part II](https://github.com/se7enxweb/exponential/blob/main/doc/install/README.md)). Inside
Exponential Platform Legacy use the **platform installer** of section 4.5, for these reasons:

- The database belongs to the new stack. Its installer creates the schema both kernels share; the legacy wizard would
  create a legacy-only schema and its own settings.
- The legacy kernel gets its database connection injected by the bridge; it has no `[DatabaseSettings]` of its own.
- The skeletons switch the legacy validity check off (`site.ini [SiteAccessSettings] CheckValidity=false`, set in the
  2.5 override file and injected on 3.x and 4.6.x), which is what keeps the legacy wizard from starting.
- The legacy kernel's own `index.php` is not below the web root; every request goes through Symfony.

LegacyBridge still contains a wizard route, `/ezsetup`, which is active only when the default siteaccess is called
`setup` and writes an old-style `ezpublish_<env>.yml`. The skeletons do not use it, and this book does not cover it.

## 4.12 Verify the installation

```bash
php bin/console --env=prod about
php bin/console --env=prod doctrine:query:sql "SELECT COUNT(*) AS objects FROM ezcontentobject"
php bin/console --env=prod ezpublish:legacy:script bin/php/ezcache.php --list-ids
```

The last command shows the legacy side working. Its output looks like this (the list is longer and depends on the
kernel version):

```text
Running script 'bin/php/ezcache.php' in eZ Publish legacy context
The following ids are defined: (use --verbose for more details)
content, global_ini, ini, codepage, expiry, classid, sortkey, urlalias, chartrans, imagealias, template,
template-block, template-override, texttoimage, rss_cache, user_info_cache, content_tree_menu, ...
```

The first line is printed by the bridge's command, not by the legacy script: it proves the command exists and the
legacy kernel was started. If you see ``bin/php/ezcache.php: invalid option `--env'`` instead, the option was written after the
script path (section 4.2).

What each one proves, and what to expect:

| Command | Proves | Expect | If it fails |
|---|---|---|---|
| `about` | Symfony boots with your environment | a table with `Environment prod`, `Debug false` and the Symfony version of your line (3.4, 5.4 or 7.4) | a parse error names the YAML file; a missing class means `composer install` did not finish |
| `doctrine:query:sql` | the new stack reaches the database | one row with a positive count of content objects | `Connection refused` or `Access denied`: section 4.4; on the newest Doctrine bundles the command is called `dbal:run-sql` |
| `ezcache.php --list-ids` | the legacy kernel boots through the bridge with the injected connection | the list of legacy cache ids (`content`, `template`, `ini`, ...) | `Could not map database driver`: the Doctrine driver is not one the bridge maps (chapter 2, [2.3](02-requirements.md#23-php-extensions)) |

After [chapter 6](06-serving-the-site.md) is done, check the site from the command line too:

```bash
curl -sI http://127.0.0.1:8080/ | head -1                # the public site: 200, or a redirect
curl -sI http://127.0.0.1:8080/legacy_admin/ | head -1   # the legacy admin: 200 (login form) or a redirect to it
```

Then open, signed in as `admin`:

1. the public site `/`;
2. the Admin UI, and its content tree;
3. the legacy admin `/legacy_admin/`, then *Setup*, *System information* (database and PHP as the legacy kernel sees
   them) and *Content structure*;
4. in the legacy admin, open an article for editing and cancel: this touches the legacy-only tables (draft handling,
   workflows). An error naming a missing table means the legacy table set is incomplete ([chapter 12](12-troubleshooting.md)).

## 4.13 The whole install per line

Each block assumes the project was created as in chapter 3 and is run from the project root. Replace the credentials.

### 2.5

```bash
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
$EDITOR app/config/parameters.yml                      # 4.4.1
export SYMFONY_ENV=prod
php bin/console ezplatform:install clean
php bin/console assets:install --symlink --relative web
php bin/console ezpublish:legacybundles:install_extensions --relative
php bin/console ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
nvm use 14 && yarn install && yarn encore production
php bin/console bazinga:js-translation:dump web/assets --merge-domains
php bin/console assetic:dump
sudo setfacl -R -m u:www-data:rwX -m u:"$USER":rwX var web/var ezpublish_legacy/var
sudo setfacl -dR -m u:www-data:rwX -m u:"$USER":rwX var web/var ezpublish_legacy/var
php bin/console cache:clear
php bin/console ezpublish:legacy:script bin/php/ezcache.php --clear-all
```

### 3.x

```bash
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
$EDITOR .env.local                                     # 4.4.2
php bin/console exponential:install exponential-oss
php bin/console lexik:jwt:generate-keypair
php bin/console ezpublish:legacy:assets_install --symlink --relative public
php bin/console ezpublish:legacybundles:install_extensions --relative
php bin/console ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
nvm use && yarn install && yarn build:prod && yarn ez
php bin/console bazinga:js-translation:dump public/assets --merge-domains
php bin/console ezplatform:graphql:generate-schema
sudo setfacl -R -m u:www-data:rwX -m u:"$USER":rwX var public/var ezpublish_legacy/var
sudo setfacl -dR -m u:www-data:rwX -m u:"$USER":rwX var public/var ezpublish_legacy/var
php bin/console cache:clear
```

### 4.6.x and 5.x

```bash
mysql -u root -p -e "CREATE DATABASE exponential CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
$EDITOR .env.local                                     # 4.4.2
php bin/install-legacy-links
php bin/console exponential:install exponential-oss
php bin/console lexik:jwt:generate-keypair
php bin/console ezpublish:legacy:assets_install --symlink --relative public
php bin/console ezpublish:legacybundles:install_extensions --relative
php bin/console ezpublish:legacy:script bin/php/ezpgenerateautoloads.php
nvm use 20 && corepack enable && yarn install && yarn build && yarn ibexa:build   # 5.x branch: nvm use 24, see 4.8
php bin/console bazinga:js-translation:dump public/assets --merge-domains
P="var public/var ezpublish_legacy/var src/LegacyRoot/var/site/storage"
sudo setfacl -R -m u:www-data:rwX -m u:"$USER":rwX $P
sudo setfacl -dR -m u:www-data:rwX -m u:"$USER":rwX $P
php bin/console cache:clear
```

Then serve the site ([chapter 6](06-serving-the-site.md)) and work through section 4.12.

## 4.14 References

In this repository:

- [app/config/parameters.yml.dist](../../app/config/parameters.yml.dist),
  [app/config/default_parameters.yml](../../app/config/default_parameters.yml),
  [app/config/env/generic.php](../../app/config/env/generic.php),
  [app/config/ezplatform.yml](../../app/config/ezplatform.yml) of the 2.5 line
- [doc/INSTALL.md](../INSTALL.md); the other lines' guides:
  [3.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/doc/INSTALL.md),
  [4.6.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/4.6.x/INSTALL.md),
  [5.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/5.x/INSTALL.md)
- On the 3.x branch: [src/Installer/ExponentialOssInstaller.php](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/src/Installer/ExponentialOssInstaller.php),
  [config/app/packages/legacy.yaml](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/config/app/packages/legacy.yaml)

External:

- LegacyBridge: [commands](https://github.com/se7enxweb/LegacyBridge/tree/master/bundle/Command),
  [Composer script handler](https://github.com/se7enxweb/LegacyBridge/blob/master/bundle/Composer/ScriptHandler.php)
- Recipe files of 4.6.x and 5.x: [sevenx-recipes, exponential-platform-dxp](https://github.com/se7enxweb/sevenx-recipes/tree/master/se7enxweb/exponential-platform-dxp)
- Symfony: [environment variables and .env files](https://symfony.com/doc/current/configuration.html#configuring-environment-variables-in-env-files),
  [secrets](https://symfony.com/doc/current/configuration/secrets.html), [file permissions](https://symfony.com/doc/current/setup/file_permissions.html),
  [Webpack Encore](https://symfony.com/doc/current/frontend/encore/index.html),
  [Doctrine DBAL configuration](https://symfony.com/doc/current/reference/configuration/doctrine.html#doctrine-dbal-configuration)
- Upstream installer concepts: [Install Ibexa DXP](https://doc.ibexa.co/en/latest/getting_started/install_ibexa_dxp/)
- [LexikJWTAuthenticationBundle](https://github.com/lexik/LexikJWTAuthenticationBundle)
- MySQL: [CREATE USER](https://dev.mysql.com/doc/refman/8.0/en/create-user.html), [GRANT](https://dev.mysql.com/doc/refman/8.0/en/grant.html)
- The Exponential 6 book: [10.1 First login](https://github.com/se7enxweb/exponential/blob/main/doc/install/10-after-installing.md#101-first-login-and-the-administrator-password),
  [4. Choosing an install method](https://github.com/se7enxweb/exponential/blob/main/doc/install/04-choosing-an-install-method.md)

[Previous: 3. Getting the code](03-getting-the-code.md) · [Next: 5. The legacy kernel inside](05-the-legacy-kernel-inside.md) ·
[Contents](README.md)
