# Upgrade instructions

Upgrading Exponential Platform Legacy is described in the book:

- [Chapter 10: Upgrading between release lines](doc/book/10-upgrading-between-lines.md): which line you run, updating
  within a line, the method for a line change, 2.5 to 3.3, 3.3 to 4.6, 4.6 to 5, and the legacy kernel's own database
  updates.
- [Chapter 11: Migrating into Exponential Platform Legacy](doc/book/11-migrating-into.md): from eZ Publish 3.x, 4.x
  and 5.x, eZ Platform and Ibexa.

The legacy kernel inside (Exponential 6) has its own update files in `ezpublish_legacy/update/database/`; see
[chapter 11 of the Exponential 6 book](https://github.com/se7enxweb/exponential/blob/main/doc/install/11-upgrading.md).

For the upstream background of the 2.5 line's platform kernel, see the upstream pages
[Update from v1.13 and v2.x](https://doc.ibexa.co/en/2.5/update_and_migration/from_1.x_2.x/update_from_1.x_2.x/) and
[Update database to v2.5](https://doc.ibexa.co/en/2.5/update_and_migration/from_1.x_2.x/update_db_to_2.5/); the update
files they name ship in `vendor/se7enxweb/ezpublish-kernel/data/update/`.
