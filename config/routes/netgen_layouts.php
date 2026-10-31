<?php

use Netgen\Bundle\LayoutsBundle\NetgenLayoutsBundle;
use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

// Exponential Layouts is optional: it needs PHP 8.4 and is added with
// `composer require netgen/layouts-ibexa:^2.0 netgen/layouts-standard:^2.0` (see INSTALL.md).
// When it is installed, the project imports its routes itself; the Legacy Bridge recipe does not.
return static function (RoutingConfigurator $routes): void {
    if (!class_exists(NetgenLayoutsBundle::class)) {
        return;
    }

    $routes->import('@NetgenLayoutsBundle/Resources/config/routing.yaml')
        ->prefix('%netgen_layouts.route_prefix%');
};
