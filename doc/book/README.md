# Installing and running Exponential Platform Legacy: the book

This book takes you from an empty server to a production Exponential Platform Legacy site and keeps it running
afterwards. Exponential Platform Legacy is the hybrid distribution: a Symfony application with the Exponential 6
legacy kernel inside, bridged by LegacyBridge, both working on one database. The book covers all four maintained
release lines (2.5 on `master`, 3.3 on `3.x`, 4.6 on `4.6.x`, 5 on `5.x`) and says where they differ. Each chapter
stands on its own and ends with references to this repository, to the related se7enxweb repositories, to the
[Exponential 6 book](https://github.com/se7enxweb/exponential/blob/main/doc/install/README.md) for the legacy kernel
itself, and to the official Symfony, PHP and upstream documentation.

In a hurry? [The short installation guide](../INSTALL.md) has the quick start and links back into the chapters here.

## Contents

### Part I: Before you install

| Chapter | What it covers |
|---|---|
| [1. Introduction: what you are installing](01-introduction.md) | What Exponential Platform Legacy is, two kernels in one application, the product family, the release lines, which line to choose, conventions, glossary |
| [2. Requirements](02-requirements.md) | PHP versions per line, extensions, php.ini, databases, Composer, Node.js and Yarn, serving, optional services, sizing, a checklist |
| [3. Getting the code](03-getting-the-code.md) | Tags, branches and Packagist versions, choosing a version constraint, `composer create-project` per line, cloning, a tour of the project root |

### Part II: Installing and serving

| Chapter | What it covers |
|---|---|
| [4. Installing](04-installing.md) | Database, environment, the platform installer, wiring up the legacy kernel, REST keys and GraphQL, assets, permissions and caches, first login, verification, the whole install per line |
| [5. The legacy kernel inside](05-the-legacy-kernel-inside.md) | What the bridge does on a request, legacy siteaccesses, where the legacy files live, the bridge's configuration, injected settings, running legacy scripts and cronjobs, autoloads, caches, extensions, the legacy admin |
| [6. Serving the site](06-serving-the-site.md) | Exponential Velocity, the Symfony CLI, Apache, nginx, file permissions, reverse proxies and Varnish, Docker, Platform.sh |

### Part III: Running the site

| Chapter | What it covers |
|---|---|
| [7. Databases](07-databases.md) | One database and two drivers, how the bridge hands the connection to the legacy kernel, `parameters.yml` against `DATABASE_URL`, MySQL/MariaDB, PostgreSQL, SQLite per line, Oracle, which tables each installer creates, the version rows, moving to another engine |
| [8. Configuration: YAML and INI](08-configuration.md) | Everything the bridge injects, which side wins, injecting your own legacy settings, siteaccesses and `legacy_mode`, designs and templates on both sides, image variations against aliases, languages, where the files are |
| [9. Operations](09-operations.md) | Caches on both sides and the order to clear them, cron on both sides, Messenger workers, search and Solr, images, logs, backups, performance, deploying a change |

### Part IV: Keeping it running

| Chapter | What it covers |
|---|---|
| [10. Upgrading between release lines](10-upgrading-between-lines.md) | The four lines side by side, the `v5.0.3` tag, updating within a line, the method for a line change, 2.5 to 3.3, 3.3 to 4.6, 4.6 to 5, the legacy kernel's own updates, verification and rollback |
| [11. Migrating into Exponential Platform Legacy](11-migrating-into.md) | From eZ Publish 3.x/4.x and 5.x, eZ Platform 1.x to 3.x and Ibexa 4.x/5.x: the target line, what the Exponential 6 book's migration chapters cover, what is specific to the hybrid, a checklist |
| [12. Troubleshooting](12-troubleshooting.md) | Symptom, cause and fix for getting the code, console commands, the database, pages and admin, images, caches, cron and search, upgrades |
| [13. Security hardening](13-security-hardening.md) | What the web server must never hand out, secrets, debug output, the admin siteaccesses, sessions and form tokens, headers, trusted proxies on both sides (Symfony and the legacy kernel's `TrustedProxies[]`), permissions, a go-live checklist |

## Which chapters do I need?

| Your situation | Read |
|---|---|
| A first test install on a laptop | [Short guide](../INSTALL.md), then chapters [1](01-introduction.md), [3](03-getting-the-code.md) and [4](04-installing.md) |
| A production site on one server | Chapters [2](02-requirements.md), [3](03-getting-the-code.md), [4](04-installing.md), [6](06-serving-the-site.md), [7](07-databases.md), [9](09-operations.md), [13](13-security-hardening.md) |
| You know Exponential 6 and want to know what the bridge changes | Chapters [5](05-the-legacy-kernel-inside.md), [7](07-databases.md) (sections 7.1 and 7.2), [8](08-configuration.md) |
| Daily operation: caches, cron, backups, deploys | Chapter [9](09-operations.md), with [5](05-the-legacy-kernel-inside.md) for the legacy side |
| Choosing or changing the database engine | Chapter [7](07-databases.md) |
| Updating within your line | Chapter [10](10-upgrading-between-lines.md) (section 10.3), then [9](09-operations.md) (section 9.9) |
| Moving to a newer release line | Chapters [10](10-upgrading-between-lines.md), [8](08-configuration.md), [12](12-troubleshooting.md) |
| Moving a site from eZ Publish 3.x, 4.x or 5.x | Chapter [11](11-migrating-into.md), then chapters 14, 15 and 17 of the [Exponential 6 book](https://github.com/se7enxweb/exponential/blob/main/doc/install/README.md) |
| Moving a site from eZ Platform or Ibexa | Chapter [11](11-migrating-into.md), then chapters 16 and 17 of the Exponential 6 book |
| Before going live | Chapter [13](13-security-hardening.md) and its checklist |
| Something does not work | Chapter [12](12-troubleshooting.md) |

## Other documentation

- [The project README](../../README.md): an overview, the technology stack of the 2.5 line and its command reference.
- [The short installation guide](../INSTALL.md).
- [Upgrade notes](../../UPGRADE.md).
- Server configuration examples: [Apache](../apache2/), [nginx](../nginx/), [Varnish](../varnish/varnish.md),
  [Docker](../docker/README.md), [Platform.sh](../platformsh/README.md).
- The legacy kernel: [the Exponential 6 book](https://github.com/se7enxweb/exponential/blob/main/doc/install/README.md).
- The bridge: [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`).
