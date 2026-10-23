<?php

namespace AppBundle\Twig;

use eZ\Publish\Core\MVC\ConfigResolverInterface;

/**
 * exp_legacy_jquery_scripts(): the jQuery files the installed legacy kernel ships, as script URLs.
 *
 * The page head used to name jquery-3.7.1.min.js and jquery-migrate-1.2.1.min.js. Kernel 6.0.14
 * has those, kernel 6.0.15 ships jQuery 4.0.0 with jQuery Migrate 4.0.2 instead, so the head
 * loaded nothing there. The files are the ones the kernel's own ezjsc::jquery loads: ezjscore.ini
 * [eZJSCore] LocalScripts[jquery] and, when the kernel names one, LocalScripts[jqueryMigrate]
 * (ExternalScripts when LoadFromCDN=enabled). A local file that is not on disk is left out.
 */
class LegacyScriptsExtension extends \Twig_Extension
{
    const SCRIPT_DIR = '/extension/ezjscore/design/standard/javascript/';

    /** @var \eZ\Publish\Core\MVC\ConfigResolverInterface */
    private $legacyConfigResolver;

    /** @var string */
    private $legacyRootDir;

    /** @var string[]|null */
    private $scripts;

    public function __construct(ConfigResolverInterface $legacyConfigResolver, $legacyRootDir)
    {
        $this->legacyConfigResolver = $legacyConfigResolver;
        $this->legacyRootDir = rtrim($legacyRootDir, '/');
    }

    public function getFunctions()
    {
        return [
            new \Twig_SimpleFunction('exp_legacy_jquery_scripts', [$this, 'getJQueryScripts']),
        ];
    }

    /**
     * @return string[] script URLs, jQuery first
     */
    public function getJQueryScripts()
    {
        if ($this->scripts !== null) {
            return $this->scripts;
        }
        $this->scripts = [];
        try {
            $external = $this->legacyConfigResolver->getParameter('eZJSCore.LoadFromCDN', 'ezjscore') === 'enabled';
            $files = $this->legacyConfigResolver->getParameter(
                $external ? 'eZJSCore.ExternalScripts' : 'eZJSCore.LocalScripts',
                'ezjscore'
            );
        } catch (\Exception $e) {
            error_log('LegacyScriptsExtension: ezjscore.ini not readable: ' . $e->getMessage());

            return $this->scripts;
        }
        foreach (['jquery', 'jqueryMigrate'] as $key) {
            if (empty($files[$key])) {
                continue;
            }
            $file = $files[$key];
            if ($external) {
                // the 6.0.14 kernel writes its CDN addresses without a scheme ("://ajax.googleapis.com/...")
                $this->scripts[] = strpos($file, '://') === 0 ? 'https' . $file : $file;
                continue;
            }
            $path = $file[0] === '/' ? $file : self::SCRIPT_DIR . $file;
            if (is_file($this->legacyRootDir . $path)) {
                $this->scripts[] = $path;
            }
        }

        return $this->scripts;
    }
}
