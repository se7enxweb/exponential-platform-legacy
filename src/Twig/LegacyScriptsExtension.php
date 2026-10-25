<?php

declare(strict_types=1);

namespace App\Twig;

use eZ\Publish\Core\MVC\ConfigResolverInterface;
use Twig\Extension\AbstractExtension;
use Twig\TwigFunction;

/**
 * What the installed legacy kernel provides to the page head of the site's themes.
 *
 *   exp_legacy_js_library()       'yui' when the kernel still ships YUI (its YUI 2 loader is on disk: kernel
 *                                 6.0.14 and earlier), 'expui' when it does not and Exponential UI (extension
 *                                 expui) is there (kernel 6.0.15), 'none' otherwise. The Netgen Admin UI decides
 *                                 the same way (ngadmin_legacy_js_library()).
 *   exp_legacy_jquery_scripts()   the jQuery files the kernel's own ezjsc::jquery loads, as script URLs:
 *                                 ezjscore.ini [eZJSCore] LocalScripts[jquery] and, when the kernel names one,
 *                                 LocalScripts[jqueryMigrate] (ExternalScripts when LoadFromCDN=enabled). jQuery
 *                                 3.7.1 with Migrate 1.2.1 on kernel 6.0.14, jQuery 4.0.0 with Migrate 4.0.2 on
 *                                 kernel 6.0.15. A local file that is not on disk is left out.
 */
final class LegacyScriptsExtension extends AbstractExtension
{
    private const SCRIPT_DIR = '/extension/ezjscore/design/standard/javascript/';

    private const YUI_LOADER = '/extension/ezjscore/design/standard/lib/yui/2.8.2/build/yuiloader/yuiloader-min.js';

    private ConfigResolverInterface $legacyConfigResolver;

    private string $legacyRootDir;

    private ?string $library = null;

    /** @var string[]|null */
    private ?array $scripts = null;

    public function __construct(ConfigResolverInterface $legacyConfigResolver, string $legacyRootDir)
    {
        $this->legacyConfigResolver = $legacyConfigResolver;
        $this->legacyRootDir = rtrim($legacyRootDir, '/');
    }

    public function getFunctions(): array
    {
        return [
            new TwigFunction('exp_legacy_js_library', [$this, 'getJavaScriptLibrary']),
            new TwigFunction('exp_legacy_jquery_scripts', [$this, 'getJQueryScripts']),
        ];
    }

    public function getJavaScriptLibrary(): string
    {
        if ($this->library === null) {
            if (is_file($this->legacyRootDir . self::YUI_LOADER)) {
                $this->library = 'yui';
            } elseif (is_dir($this->legacyRootDir . '/extension/expui/design')) {
                $this->library = 'expui';
            } else {
                $this->library = 'none';
            }
        }

        return $this->library;
    }

    /**
     * @return string[] script URLs, jQuery first
     */
    public function getJQueryScripts(): array
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
            if (empty($files[$key]) || !is_string($files[$key])) {
                continue;
            }
            $file = $files[$key];
            if ($external) {
                // kernel 6.0.14 writes its CDN addresses without a scheme ("://ajax.googleapis.com/...")
                $this->scripts[] = strpos($file, '://') === 0 ? 'https' . $file : $file;

                continue;
            }
            $path = $this->localScriptPath($file);
            if ($path !== null) {
                $this->scripts[] = $path;
            }
        }

        return $this->scripts;
    }

    /**
     * The address of a LocalScripts file, resolved as ezjscore's packer does: a name is a file of a design's
     * javascript/ directory (the kernel's own: extension/ezjscore), a path that starts with "/" is relative to a
     * design directory itself (Exponential UI names /lib/jquery/jquery-4.0.0.min.js of its own design). Null when
     * no design has the file.
     */
    private function localScriptPath(string $file): ?string
    {
        if ($file[0] !== '/') {
            $relative = 'javascript/' . $file;
            if (is_file($this->legacyRootDir . self::SCRIPT_DIR . $file)) {
                return self::SCRIPT_DIR . $file;
            }
        } else {
            $relative = ltrim($file, '/');
        }
        $designs = array_merge(
            glob($this->legacyRootDir . '/extension/*/design/standard', GLOB_ONLYDIR) ?: [],
            glob($this->legacyRootDir . '/design/standard', GLOB_ONLYDIR) ?: [],
            glob($this->legacyRootDir . '/extension/*/design/*', GLOB_ONLYDIR) ?: [],
            glob($this->legacyRootDir . '/design/*', GLOB_ONLYDIR) ?: []
        );
        foreach ($designs as $design) {
            if (is_file($design . '/' . $relative)) {
                return substr($design, strlen($this->legacyRootDir)) . '/' . $relative;
            }
        }

        return null;
    }
}
