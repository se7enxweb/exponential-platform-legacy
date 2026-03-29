<?php

declare(strict_types=1);

namespace App\Installer;

class NetgenSiteInstaller extends \Netgen\Bundle\SiteInstallerBundle\Installer\NetgenSiteInstaller
{
    public function importSchema(): void
    {
        $this->importSchemaFile(
            $this->installerDataPath . '/../schema/schema.sql',
            'ezmedia',
        );
    }
}
