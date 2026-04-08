<?php

/**
 * @copyright Copyright (C) 1998-2026 7x (se7enx.com). All rights reserved.
 * @license   GNU General Public License v2 or later
 *
 * Exponential Platform Legacy (Platform v3) — installer type "exponential-oss".
 *
 * Registers the "exponential-oss" install type so that:
 *
 *   php bin/console ezplatform:install exponential-oss
 *
 * resolves to this installer. Delegates all work to the upstream CoreInstaller
 * (schema via SchemaBuilder + cleandata.sql seed data), making it a drop-in
 * equivalent of "ibexa-oss" under the Exponential Platform name.
 *
 * Platform v3 uses the EzSystems\PlatformInstallerBundle namespace and the
 * "ezplatform.installer" service tag (not the Ibexa\ namespace / ibexa.installer
 * tag used by Platform v4).
 *
 * SQLite: a dedicated data/sqlite/cleandata.sql is shipped in this skeleton.
 * The installer points baseDataDir to the project root data/ directory on
 * SQLite so it finds data/sqlite/cleandata.sql instead of looking in vendor.
 * For MySQL/PostgreSQL the vendor cleandata.sql is used as normal via parent.
 */

declare(strict_types=1);

namespace App\Installer;

use Doctrine\DBAL\Connection;
use EzSystems\DoctrineSchema\API\Builder\SchemaBuilder;
use EzSystems\PlatformInstallerBundle\Installer\CoreInstaller;

/**
 * Installer for the "exponential-oss" install type (Platform v3 / 3.x).
 *
 * Extends CoreInstaller. On SQLite, overrides baseDataDir to the project's
 * own data/ directory which ships data/sqlite/cleandata.sql. On MySQL and
 * PostgreSQL the upstream vendor cleandata.sql is used via parent.
 */
final class ExponentialOssInstaller extends CoreInstaller
{
    private string $projectDir;

    public function __construct(Connection $db, SchemaBuilder $schemaBuilder, string $projectDir)
    {
        parent::__construct($db, $schemaBuilder);
        $this->projectDir = $projectDir;
    }

    public function importData(): void
    {
        if ($this->db->getDatabasePlatform()->getName() === 'sqlite') {
            // Point to the project's own data/ directory which ships
            // data/sqlite/cleandata.sql (vendor kernel has no sqlite version).
            $this->baseDataDir = $this->projectDir . '/data';
        }

        parent::importData();
    }
}
