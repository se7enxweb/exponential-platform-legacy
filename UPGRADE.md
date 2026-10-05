# Upgrade instructions

Upgrading Exponential Platform Legacy is described in the book:

- [Chapter 10: Upgrading between release lines](doc/book/10-upgrading-between-lines.md): which line you run, updating
  within a line, the method for a line change, 2.5 to 3.3, 3.3 to 4.6, 4.6 to 5, and the legacy kernel's own database
  updates.
- [Chapter 11: Migrating into Exponential Platform Legacy](doc/book/11-migrating-into.md): from eZ Publish 3.x, 4.x
  and 5.x, eZ Platform and Ibexa.

## Before you update a 2.5 site

`composer update` does not touch the files in `web/`, so the corrections of 5 October 2026 to the front controllers
(`web/.htaccess` routes to `app.php`, `web/app_dev.php` answers local requests only, `web/app.php` no longer switches
error display on; commits `fa091cd`, `d924ceb`, `7605f57`) reach an existing site only when you apply them yourself.
The releases up to `v2.5.0.3` route every request to `app_dev.php`. See
[section 13.2 of the book](doc/book/13-security-hardening.md#132-what-the-web-server-must-never-hand-out), and section
10.1 for what the next release of each line contains.

## The legacy kernel's database updates

The legacy kernel inside (Exponential 6) has its own update files in `ezpublish_legacy/update/database/`; see
[chapter 11 of the Exponential 6 book](https://github.com/se7enxweb/exponential/blob/main/doc/install/11-upgrading.md)
and [section 10.7 of this book](doc/book/10-upgrading-between-lines.md#107-the-legacy-kernel-inside-every-line), which
says what the 6.0 files change (the wider `ezuser.password_hash`, the trash date column, the PostgreSQL sequence
names, the 6.0.15 tables) and which of their statements may run twice.

## Upstream background

For the upstream background of the 2.5 line's platform kernel, see the upstream pages
[Update from v1.13 and v2.x](https://doc.ibexa.co/en/2.5/update_and_migration/from_1.x_2.x/update_from_1.x_2.x/) and
[Update database to v2.5](https://doc.ibexa.co/en/2.5/update_and_migration/from_1.x_2.x/update_db_to_2.5/); the update
files they name ship in `vendor/se7enxweb/ezpublish-kernel/data/update/`.
