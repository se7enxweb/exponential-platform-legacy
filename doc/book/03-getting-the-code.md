# 3. Getting the code

This chapter shows how to obtain Exponential Platform Legacy for each release line: which tags and branches exist, which
Composer version constraint selects which line (and which ones look right but do not), the exact `composer
create-project` command per line and what it runs, cloning a branch with git instead, and a tour of the project root
you end up with. Read section 3.2 before you type any `composer` command: one published tag selects the wrong line if
you do not name the version.

[Previous: 2. Requirements](02-requirements.md) · [Next: 4. Installing](04-installing.md) · [Contents](README.md)

---

## Contents of this chapter

1. [Tags, branches and Packagist versions](#31-tags-branches-and-packagist-versions)
2. [Choosing a version constraint](#32-choosing-a-version-constraint)
3. [Before you run Composer](#33-before-you-run-composer)
4. [composer create-project per line](#34-composer-create-project-per-line)
5. [Cloning a branch with git](#35-cloning-a-branch-with-git)
6. [Release archives](#36-release-archives)
7. [A tour of the project root](#37-a-tour-of-the-project-root)
8. [Putting your project under version control](#38-putting-your-project-under-version-control)
9. [References](#39-references)

---

## 3.1 Tags, branches and Packagist versions

The repository is [github.com/se7enxweb/exponential-platform-legacy](https://github.com/se7enxweb/exponential-platform-legacy);
Packagist publishes it as [`se7enxweb/exponential-platform-legacy`](https://packagist.org/packages/se7enxweb/exponential-platform-legacy).
Version numbers have four positions (the first 5.x tags, `v5.0.0` to `v5.0.3`, have three); only the last one counts
up within a series (`v3.3.44.9` is followed by `v3.3.44.10`, never by `v3.3.45.0`). Tags are permanent: a published
tag is never moved or re-cut, and a mistake in one is corrected by publishing the next version.

| Line | Branch (Packagist dev version) | Tags (date of the tagged commit) |
|---|---|---|
| 2.5 | `master` (`dev-master`, alias `2.5.x-dev`) | `v2.5.0.0` (2025-08-25), `v2.5.0.1` (2025-09-14), `v2.5.0.2` (2026-04-10), `v2.5.0.3` (2026-04-21); also `v5.0.3` (2026-07-08), see below |
| 3.x | `3.x` (`3.x-dev`) | `v3.0.0.0` to `v3.0.0.14` (2026-03-28 to 2026-04-03), `v3.3.44.0` to `v3.3.44.7` (2026-04-07 to 2026-04-12) |
| 4.6.x | `4.6.x` (`4.6.x-dev`) | `v4.6.23.0` (2026-04-06), `v4.6.23.1` (2026-04-07), `v4.6.23.2` (2026-04-16) |
| 5.x | `5.x` (`5.x-dev`) | `v5.0.0` (2026-04-12), `v5.0.1` (2026-04-14), `v5.0.2` (2026-04-16) |
| snapshots | `2.5.0.0` to `2.5.0.3` (`2.5.0.0-dev` ...) | branches frozen at each 2.5 release; use the tags |
| history | `1.7` to `1.13`, `2.0`, `2.2` | upstream branches, not maintained (chapter 1, [1.4](01-introduction.md#the-old-branches)) |

Within the 3.x line, the `v3.0.0.x` series came first; `v3.3.44.x` is the current series. The `v4.6.23.0` tag still
required `se7enxweb/exponential-platform-dxp 4.6.x-dev`; from `v4.6.23.1` on the skeleton requires the
LegacyBridge branch `4.6.x-LB-dev` of that package. `v5.0.0` required LegacyBridge `^4.0.0.0`; from `v5.0.1` on it is
`^5.0.0.0`.

The next releases are planned as `v2.5.0.4`, `v3.3.44.8`, `v4.6.23.3` and `v5.0.3.1`. They are not tagged yet (checked
on 2026-10-05); they will carry the branch fixes listed in chapter 1,
[Fixes on the branches](01-introduction.md#fixes-on-the-branches-that-no-tag-carries-yet).

To see what exists today rather than what this book saw, list the tags by version (a plain name sort puts `.10` before
`.9`) and the releases:

```bash
git ls-remote --tags https://github.com/se7enxweb/exponential-platform-legacy.git | sort -t/ -k3 -V | tail -5
gh release list -R se7enxweb/exponential-platform-legacy --limit 5      # GitHub CLI, optional
```

Output on 2026-10-05, hashes shortened. An annotated tag appears twice: once with the hash of the tag object and once,
with `^{}`, with the hash of the commit it points to.

```text
923ddaa0...  refs/tags/v4.6.23.2^{}
45a77c00...  refs/tags/v5.0.0
955dc63b...  refs/tags/v5.0.1
bfbe3daf...  refs/tags/v5.0.2
43461d83...  refs/tags/v5.0.2^{}
8479bb75...  refs/tags/v5.0.3
```

If a planned version from the list above appears there, it has been released; use it instead of the versions this
chapter names.

### The v5.0.3 tag selects the 2.5 line

`v5.0.3` was tagged on `master`. Its `composer.json` is the 2.5 line's (Symfony 3.4, `se7enxweb/ezpublish-kernel
~7.5.33`, LegacyBridge `^2.1`, web root `web/`). It is the highest stable version on Packagist, so:

| You type | Composer installs |
|---|---|
| `composer create-project se7enxweb/exponential-platform-legacy my_project` | `v5.0.3`: the **2.5 line** |
| `... se7enxweb/exponential-platform-legacy:^5.0 my_project` | `v5.0.3`: the **2.5 line** |
| `... se7enxweb/exponential-platform-legacy:~5.0.2 my_project` | `v5.0.3` as well (`~5.0.2` allows 5.0.3) |

The 5.x installation guide's own quick start up to `v5.0.2` (`composer create-project se7enxweb/exponential-platform-legacy
my-project`, without a version) therefore does not give you 5.x; the branch guide asks for `~5.0.3.1` since commit
`54f90fb`. Name the line every time, as in section 3.4.

How to tell afterwards which line you received: the 2.5 line has `app/` and `web/`, the others `config/` and
`public/`; `grep legacy-bridge composer.json` prints `^2.1` for the 2.5 line. Once the planned `v5.0.3.1` is published
it becomes the highest stable version (Composer compares `5.0.3.1` as greater than `5.0.3`), and an unconstrained
`create-project` or `^5.0` then reaches the 5.x line again. Naming the line stays the safe habit.

## 3.2 Choosing a version constraint

The argument after the package name and a colon is a Composer version constraint. These are the ones that select each
line, checked against the versions Packagist publishes:

| Line | A stable release | The branch (newest commits) | Do not use |
|---|---|---|---|
| 2.5 | `~2.5.0.3` (`v2.5.0.3` and later `2.5.0.x`) | `dev-master` or `2.5.x-dev` | `2.5.0.x-dev` (named in the 2.5 README and guide; no published version matches it); `^5.0` |
| 3.x | `~3.3.44.7` | `3.x-dev` | `^3.0` resolves too, but also admits the older `v3.0.0.x` series; the tilde names the current series |
| 4.6.x | `~4.6.23.2` | `4.6.x-dev` | `4.6.x-LB-dev` (that is a branch of `se7enxweb/exponential-platform-dxp`, not of this package) |
| 5.x | `5.0.2` (exact); after its release `~5.0.3.1` | `5.x-dev` | no constraint, `^5.0`, `~5.0.2`, `~5.0`: all reach `v5.0.3` as long as it is the newest stable version |

A tilde with all four positions (`~2.5.0.3`) allows the last position to grow and nothing else: `>=2.5.0.3 <2.5.1`.

The 3.x, 4.6.x and 5.x skeletons set `"minimum-stability": "dev"`: even when you create the project from a stable tag,
some of its dependencies are development branches (`se7enxweb/exponential-platform-dxp 4.6.x-LB-dev` and `dev-5.x-LB`,
the legacy kernel `dev-main` through LegacyBridge 4 and 5, `se7enxweb/symfony 5.4.x-dev` on 3.x). Two installs of the
same tag on different days can therefore resolve to different commits of those packages. Keep the `composer.lock` your
first install writes (section 3.8) to make later installs repeatable.

## 3.3 Before you run Composer

- **Check the requirements** of your line ([chapter 2](02-requirements.md)) for the PHP that runs Composer.
- **GitHub access.** Composer downloads many packages from GitHub. Anonymous API access is rate limited; give Composer a
  token (`composer config --global github-oauth.github.com <token>`) if downloads stop with a rate-limit message.
- **Memory.** `export COMPOSER_MEMORY_LIMIT=-1` avoids Composer running out of memory while it resolves.
- **Plugins.** The skeletons allow a fixed list of Composer plugins in `config.allow-plugins` (on 4.6.x and 5.x:
  `ibexa/post-install`, `se7enxweb/exponential-legacy-installer`, `symfony/flex`, `symfony/runtime`, everything else
  `false`). The legacy installer plugin is what places the legacy kernel in `ezpublish_legacy/`; do not deny it.
- **Not as root.** Run Composer as the user that will own the files ([chapter 6](06-serving-the-site.md#67-file-permissions)).
- **The database comes later.** `create-project` installs code and runs scripts; it does not touch a database, except
  that the 2.5 line asks for `parameters.yml` values (section 3.4.1).

## 3.4 composer create-project per line

### 3.4.1 The 2.5 line

```bash
composer create-project se7enxweb/exponential-platform-legacy:~2.5.0.3 my_project
cd my_project
```

What happens, from the 2.5 `composer.json`:

1. Composer installs the packages, among them `se7enxweb/exponential ^6.0.12`, which the legacy installer plugin puts in
   `ezpublish_legacy/` (`extra.ezpublish-legacy-dir`).
2. `post-install-cmd` runs the `symfony-scripts` group:
   - `Incenteev\ParameterHandler\ScriptHandler::buildParameters` creates `app/config/parameters.yml` from
     `app/config/parameters.yml.dist` and **asks for each value** in an interactive terminal (database, secret). Press
     Enter to accept a default; you can edit the file afterwards ([chapter 4](04-installing.md#44-configure-the-environment)).
   - clears the Symfony cache, installs bundle assets into `web/bundles/` and writes the requirements file;
   - the `legacy-scripts` group: `installAssets` (legacy assets and wrapper scripts into `web/`),
     `installLegacyBundlesExtensions` (legacy extensions shipped in bundles into `ezpublish_legacy/extension/`) and
     `generateAutoloads` (runs `ezpublish:legacy:script bin/php/ezpgenerateautoloads.php`);
   - `bazinga:js-translation:dump web/assets --merge-domains` and `assetic:dump`;
   - `yarn install` and the Encore build of the Admin UI assets;
   - `bin/security-checker security:check`.
3. `post-create-project-cmd` prints the welcome text.

The script group runs `yarn`, so Node.js 14 and Yarn must be on the `PATH` (chapter 2, [2.7](02-requirements.md#27-nodejs-and-yarn)).
Without them, or to run each step yourself, pass `--no-scripts` and follow [chapter 4](04-installing.md).

The 2.5 guide adds `--ignore-platform-reqs` to every Composer command. Read chapter 2, [2.2](02-requirements.md#22-php-versions-per-line)
before you do the same.

### 3.4.2 The 3.x line

```bash
composer create-project se7enxweb/exponential-platform-legacy:~3.3.44.7 my_project
cd my_project
```

The 3.x skeleton carries its configuration in the repository (`config/`, `src/`, `public/`, `templates/`), and Symfony
Flex adds recipe files from the endpoints in `extra.symfony.endpoint`
([se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes) and Flex's defaults). Then `post-install-cmd`
runs:

| Script | What it does |
|---|---|
| `bazinga:js-translation:dump public/assets --merge-domains` | JavaScript translations for the Admin UI |
| `assets:install --symlink --relative public` | bundle assets into `public/bundles/` |
| `ezpublish:legacy:assets_install --symlink --relative public` | legacy design, extension and share directories and the wrapper scripts into `public/` |
| `ezpublish:legacybundles:install_extensions --relative` | legacy extensions shipped in bundles into `ezpublish_legacy/extension/` |
| `ScriptHandler::installIniSettings` | LegacyBridge 3 only: installs the project's legacy INI settings |
| `ezpublish:legacy:script bin/php/ezpgenerateautoloads.php` | legacy autoload arrays |

### 3.4.3 The 4.6.x line

```bash
composer create-project se7enxweb/exponential-platform-legacy:~4.6.23.2 my_project
cd my_project
```

The tag `v4.6.23.2` holds only `composer.json`, a README, an INSTALL guide and the licence files; the branch adds
`config/packages/trusted_proxies.yaml` (commit `309785f`, section 3.4.5). Everything else comes from the Symfony Flex
recipe of `se7enxweb/exponential-platform-dxp` (slot `se7enxweb/exponential-platform-dxp/1.2` in
[sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes)): `bin/install-legacy-links`, `config/`, `public/`
(`index.php`, `.htaccess`, `index_rest.php`, `index_cluster.php`), `src/` (the installer type `exponential-oss`, the
legacy request listeners, the injected-settings subscriber, `src/LegacySettings/` and `src/ezpublish_legacy/app/`),
the Encore configuration and `package.json`, the bundle list and the environment variables for `.env`. The recipe manifest also
declares `"symlinks": {"web": "public"}`; Symfony Flex has no configurator of that name, so do not count on a `web`
link existing: the web root is `public/`.

Which recipe slot applies: Symfony Flex chooses the recipe by the version of the installed package. The branch
`4.6.x-LB` of `se7enxweb/exponential-platform-dxp` carries the branch alias `1.2.x-dev` and the branch `5.x-LB` the
alias `1.4.x-dev`, so Flex installs the slots `1.2` and `1.4` of the recipe repository. The folders named
`4.6.x-LB-dev` and `5.0` in that repository look as if they belonged to these lines, but `index.json` does not list
`4.6.x-LB-dev`, and neither is the slot Flex picks; read `1.2` and `1.4` when you want to know what a project receives.
`composer recipes se7enxweb/exponential-platform-dxp` in your project shows the installed recipe version.

Then `post-install-cmd` runs:

1. `php bin/install-legacy-links`: links `ezpublish_legacy/extension/app`, `ezpublish_legacy/settings/override`, the
   siteaccess settings directories (`legacy_site`, `legacy_admin`, `ngadminui`) and
   `ezpublish_legacy/var/site/storage` to their sources under `src/` (chapter 5, [5.3](05-the-legacy-kernel-inside.md#53-where-the-legacy-files-live));
2. the `auto-scripts`: JavaScript translations, `assets:install --symlink --relative public`,
   `ezpublish:legacy:assets_install --symlink --relative public`, `ezpublish:legacybundles:install_extensions --relative`,
   `cache:clear` and `assets:install public`;
3. `ezpublish:legacy:script bin/php/ezpgenerateautoloads.php`.

### 3.4.4 The 5.x line

```bash
composer create-project se7enxweb/exponential-platform-legacy:5.0.2 my_project
# or the branch, with every fix since:
composer create-project se7enxweb/exponential-platform-legacy:5.x-dev my_project
cd my_project
```

The same mechanism as 4.6.x, with the recipe slot `se7enxweb/exponential-platform-dxp/1.4`, Symfony 7.4 and
LegacyBridge 5. What differs between the tag and the branch:

| | `5.0.2` | `5.x-dev` (branch, planned release `v5.0.3.1`) |
|---|---|---|
| Files in the skeleton besides `composer.json` and the documents | none | `config/services.yaml`, `config/packages/lexik_jwt_authentication.yaml`, `config/packages/trusted_proxies.yaml`, `package.json`, `webpack.config.js`, `yarn.lock` |
| Post-install scripts | those of 4.6.x without the final `assets:install public` | the same as 4.6.x |
| Node.js for the asset build | 20 LTS | 24 LTS |

The branch's own files take precedence over the recipe's: Symfony Flex does not overwrite a file that already exists
when it installs a recipe. Its `config/services.yaml` keeps `src/ezpublish_legacy/app/root/config.php` out of the
service discovery, which otherwise stops `cache:clear` with a class error on a fresh install (commit `c98f567`).

### 3.4.5 Files you may have to add to a project from an older tag

A project created from `v4.6.23.2` or `v5.0.2` does not get the corrections made on the branches afterwards, because
Composer copies the skeleton only once. The one that matters for most installations is the trusted-proxy file; create it
yourself when a proxy, load balancer or Varnish is in front of the site ([chapter 6](06-serving-the-site.md#68-reverse-proxies-and-varnish)):

```yaml
# config/packages/trusted_proxies.yaml  (as on the 4.6.x and 5.x branches)
framework:
    trusted_proxies: '%env(default::TRUSTED_PROXIES)%'
    trusted_headers: ['x-forwarded-for', 'x-forwarded-proto', 'x-forwarded-port']
```

The same applies to the other lines. What to take over from the branch into a project created from the newest tag:

| Created from | Take over | Why |
|---|---|---|
| `v2.5.0.3` (or `v5.0.3`) | `web/.htaccess`, `web/app.php`, `web/app_dev.php` from `master` | the tagged files run every request in `dev` with debugging and display errors ([6.2.1](06-serving-the-site.md#621-shipped-files-to-check-before-production)) |
| `v3.3.44.7` | `public/.htaccess`; the `trusted_proxies` lines of `config/packages/ezpublish.yaml`; the removal of `ezplatformsearch` from `config/app/packages/legacy.yaml` | the tagged `.htaccess` forces `dev`; `TRUSTED_PROXIES` is otherwise not read; the extension is not installed |
| `v4.6.23.2`, `v5.0.2` | `config/packages/trusted_proxies.yaml` (above); remove the `APP_ENV` line of the recipe's `public/.htaccess` and set the recipe's `DebugOutput=enabled` to `disabled` | the recipe file forces `dev`, and the legacy debug report is on ([6.2.1](06-serving-the-site.md#621-shipped-files-to-check-before-production)) |

To fetch one file of a branch without cloning, use its raw address and compare it with your copy before you replace
it, because you may have changed yours:

```bash
curl -fsSL -o var/app.php.master https://raw.githubusercontent.com/se7enxweb/exponential-platform-legacy/master/web/app.php
diff -u web/app.php var/app.php.master          # review, then copy it over web/app.php
```

### 3.4.6 Options worth knowing

| Option | Effect |
|---|---|
| `--no-scripts` | installs packages only; run the steps of [chapter 4](04-installing.md) yourself |
| `--no-interaction` | no questions (the 2.5 parameter handler then writes the defaults from `parameters.yml.dist`) |
| `--keep-vcs` | keeps the `.git` directory of the skeleton, useful if you want to follow the branch with `git pull` |
| `--prefer-dist` | archives instead of clones (the 3.x, 4.6.x and 5.x skeletons already prefer `dist`) |
| `--no-dev` | leaves out development packages (Behat, PHPUnit, the profiler); for production builds |

## 3.5 Cloning a branch with git

Cloning gives you the skeleton with its history; Composer then installs the dependencies:

```bash
git clone -b 3.x https://github.com/se7enxweb/exponential-platform-legacy.git my_project   # or master, 4.6.x, 5.x
cd my_project
composer install
```

| Branch | After `composer install` |
|---|---|
| `master` (2.5) | the same as `create-project`, without the welcome text |
| `3.x` | the same as `create-project` |
| `4.6.x`, `5.x` | the branch holds only `composer.json`; Symfony Flex writes the recipe files during `composer install` because none of them is recorded in a `symfony.lock` yet |

Errors in the branch guides of the tags up to `v3.3.44.7`, `v4.6.23.2` and `v5.0.2`: the 4.6.x installation guide's
"git clone" section says `git checkout 3.x` (use `4.6.x`), the 5.x guide's says `git checkout master` (use `5.x`),
and the 3.x, 4.6.x and 5.x guides clone over SSH (`git@github.com:...`), which needs a GitHub account with a key;
HTTPS works for everyone. The branches are corrected since 2026-10-05 (3.x `f557295`, 4.6.x `058646c`, 5.x `dc4080b`).

To follow a release instead of a branch, check out its tag: `git checkout v4.6.23.2`.

## 3.6 Release archives

Each [GitHub release](https://github.com/se7enxweb/exponential-platform-legacy/releases) offers the tagged skeleton as
"Source code" zip and tar.gz; some release notes also link a copy on SourceForge. An archive is the same as a clone of
the tag without history: unpack it and run `composer install`. The archives contain no `vendor/` and no
`ezpublish_legacy/` kernel, so they are not usable without Composer.

## 3.7 A tour of the project root

### 3.7.1 The 2.5 line

```
my_project/
├── app/
│   ├── AppKernel.php, AppCache.php      the Symfony kernel and the HTTP cache kernel
│   ├── config/
│   │   ├── config.yml, config_<env>.yml  framework configuration
│   │   ├── ezplatform.yml                repository, siteaccesses, design, ez_publish_legacy
│   │   ├── parameters.yml(.dist)         your database, secret, mailer (parameters.yml is not committed)
│   │   ├── default_parameters.yml        defaults read from environment variables
│   │   ├── env/generic.php               compile-time settings from environment variables
│   │   ├── cache_pool/, dfs/             optional Redis/Memcached pools, cluster
│   │   └── routing.yml, security.yml
│   └── Resources/views/                  Twig templates of the site
├── bin/console                           the Symfony console
├── ezpublish_legacy/                     the legacy kernel (installed by Composer; only settings/ is in git)
├── src/AppBundle/                        your bundle
├── web/                                  the web root: app.php, app_dev.php, .htaccess, assets/, bundles/
├── var/                                  cache/, logs/, sessions/ of Symfony
├── doc/                                  this book, the server examples (apache2, nginx, varnish, docker, platformsh)
├── assets/, webpack.config.js, ez.webpack.*.js, package.json   front-end sources and build
└── composer.json
```

### 3.7.2 The 3.x line

```
my_project/
├── bin/console
├── config/
│   ├── bundles.php, services.yaml, packages/, routes/   Symfony configuration
│   └── app/                              the project's own layer: siteaccesses, legacy injected settings, server profiles
├── ezpublish_legacy/                     the legacy kernel
├── src/
│   ├── Kernel.php, Installer/            the kernel and the exponential-oss install type
│   ├── ExponentialPlatformLegacyInjectedSettings/   the bundle that injects legacy INI settings from YAML
│   └── ezpublish_legacy/app/             the legacy "app" extension and siteaccess settings
├── public/                               the web root: index.php, .htaccess
├── templates/, translations/, assets/    Twig, translations, front-end sources
├── var/                                  Symfony cache and logs
├── Makefile, deploy.php, deploy/         shortcuts, Deployer recipes
└── .env                                  shipped defaults; your values go in .env.local
```

### 3.7.3 The 4.6.x and 5.x lines

```
my_project/
├── bin/console, bin/install-legacy-links
├── config/                               from the recipe: packages/ibexa*.yaml, ez_publish_legacy.yaml, routes/
├── ezpublish_legacy/                     the legacy kernel; several entries are symbolic links into src/
├── src/
│   ├── Installer/ExponentialOssInstaller.php
│   ├── EventListener/, EventSubscriber/  legacy request handling and injected settings
│   ├── LegacySettings/override/          global legacy INI overrides (linked into ezpublish_legacy/settings/override)
│   ├── LegacyRoot/var/site/storage/      uploaded files (linked into ezpublish_legacy/var/site/storage)
│   └── ezpublish_legacy/app/             the "app" extension and the siteaccess settings
├── public/                               the web root
├── templates/, assets/, package.json, webpack.config.js
├── var/
└── .env, .env.local
```

## 3.8 Putting your project under version control

After `create-project` the project is yours; put it in your own repository. The skeletons' `.gitignore` files already
exclude what is generated or secret:

| Excluded | 2.5 | 3.x and later |
|---|---|---|
| dependencies | `/vendor/`, `/node_modules/` | the same |
| the legacy kernel | `/ezpublish_legacy` | `/ezpublish_legacy/` |
| secrets | `/app/config/parameters.yml`, `auth.json` | `.env.local` (Symfony convention), `/config/jwt/*.pem`, `auth.json` |
| generated assets | `/web/bundles/`, `/web/assets/build/*`, `/web/design`, `/web/extension`, `/web/share`, `/web/var` | `/public/assets/`, `/public/design`, `/public/extension`, `/public/share`, `/public/var`, `/public/build/` |
| runtime | `/var/*` except the placeholder files | `var/` (from the Symfony recipes) |

Two things to decide on for the 2.5 line:

- **Lock files.** The 2.5 `.gitignore` excludes `composer.lock` and `yarn.lock`. Commit them in your own project;
  without a lock file every install resolves the development branches anew (section 3.2). Remove the two lines from
  `.gitignore` first, or `git add` skips them.
- **`web/.htaccess`.** The 2.5 `.gitignore` also lists `/web/.htaccess`, although the skeleton ships that file (Git keeps tracking
  a file once it is committed, even one an ignore rule matches). In a new repository of your own, `git add .` therefore
  leaves it out, and a deployment from your repository has no rewrite rules: under Apache with `AllowOverride All`,
  clean URLs such as `/legacy_admin/` then answer 404 because nothing sends them to `app.php`. Either delete the line from `.gitignore` or add the file explicitly with `git add -f web/.htaccess`.

A first commit that avoids both traps:

```bash
git init
sed -i -e '/^composer.lock$/d' -e '/^yarn.lock$/d' -e '/^\/web\/.htaccess$/d' .gitignore     # 2.5 only
git add . && git status --short | grep -E 'composer.lock|web/.htaccess'                     # both must be listed
git commit -m "Initial project from exponential-platform-legacy"
```

## 3.9 References

In this repository:

- [composer.json](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/composer.json) and [.gitignore](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/.gitignore) of the 2.5 line
- [README.md, Installation](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/README.md#installation) and [doc/INSTALL.md, First-Time Installation](../INSTALL.md)
- The other lines' guides: [3.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/doc/INSTALL.md),
  [4.6.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/4.6.x/INSTALL.md),
  [5.x](https://github.com/se7enxweb/exponential-platform-legacy/blob/5.x/INSTALL.md)

External:

- [Releases on GitHub](https://github.com/se7enxweb/exponential-platform-legacy/releases) and
  [versions on Packagist](https://packagist.org/packages/se7enxweb/exponential-platform-legacy)
- The Flex recipes: [se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes)
- Composer: [create-project](https://getcomposer.org/doc/03-cli.md#create-project), [install](https://getcomposer.org/doc/03-cli.md#install-i),
  [versions and constraints](https://getcomposer.org/doc/articles/versions.md),
  [minimum-stability](https://getcomposer.org/doc/04-schema.md#minimum-stability),
  [scripts](https://getcomposer.org/doc/articles/scripts.md), [authentication for GitHub](https://getcomposer.org/doc/articles/authentication-for-private-packages.md#github-oauth)
- Symfony: [Symfony Flex](https://symfony.com/doc/current/setup/flex.html),
  [configuring with environment variables](https://symfony.com/doc/current/configuration.html#configuration-based-on-environment-variables)
- The Exponential 6 book: [3. Getting the code](https://github.com/se7enxweb/exponential/blob/main/doc/install/03-getting-the-code.md),
  for the legacy kernel package on its own

[Previous: 2. Requirements](02-requirements.md) · [Next: 4. Installing](04-installing.md) · [Contents](README.md)
