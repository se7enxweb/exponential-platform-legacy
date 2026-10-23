<?php

/**
 * @copyright Copyright (C) 1998-2026 7x (se7enx.com). All rights reserved.
 * @license   GNU General Public License v2 or later
 *
 * Exponential Platform Legacy — installer type "exponential-oss".
 *
 * Registered as the "exponential-oss" installer type so that:
 *
 *   php bin/console ibexa:install exponential-oss
 *   php bin/console ezplatform:install exponential-oss   # deprecated alias, still works
 *
 * both resolve to this installer.  It delegates all work to the upstream
 * CoreInstaller (schema via SchemaBuilder + cleandata.sql seed data), making
 * it a drop-in equivalent of "ibexa-oss" under the Exponential Platform name.
 *
 * To customise the install — e.g. import additional demo content, extra SQL,
 * or skip certain steps — override importSchema(), importData(), or
 * importBinaries() here rather than patching vendor code.
 */

declare(strict_types=1);

namespace App\Installer;

use Ibexa\Bundle\RepositoryInstaller\Installer\CoreInstaller;

/**
 * Installer for the "exponential-oss" install type.
 *
 * Extends CoreInstaller unchanged.  All logic lives in CoreInstaller /
 * DbBasedInstaller; this class exists so its service definition can carry the
 * { name: ibexa.installer, type: exponential-oss } tag independently of the
 * upstream "ibexa-oss" registration — meaning both types are simultaneously
 * available without interfering with each other.
 */
final class ExponentialOssInstaller extends CoreInstaller
{
    // No overrides needed for the base "exponential-oss" type.
    // Add importSchema() / importData() / importBinaries() overrides here
    // if you want to customise what gets installed.
}
