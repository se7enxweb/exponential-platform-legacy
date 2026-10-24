<?php

use Netgen\Bundle\ContentBrowserBundle\NetgenContentBrowserBundle;
use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

// The Content Browser comes with the optional Netgen Layouts (PHP 8.4 and later).
return static function (RoutingConfigurator $routes): void {
    if (!class_exists(NetgenContentBrowserBundle::class)) {
        return;
    }

    $routes->import('@NetgenContentBrowserBundle/Resources/config/routing.yaml')
        ->prefix('%netgen_content_browser.route_prefix%');
};
