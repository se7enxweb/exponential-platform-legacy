<?php

use Netgen\Bundle\LayoutsIbexaBundle\NetgenLayoutsIbexaBundle;
use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

// Routes of the Layouts integration with the Platform admin (the "Layouts" tab of the content view),
// imported when the optional Exponential Layouts is installed. Without them that admin content view stops
// with "route nglayouts_ibexa_admin_location_layouts does not exist". The paths in the file are
// absolute (/nglayouts/...), so no prefix.
return static function (RoutingConfigurator $routes): void {
    if (!class_exists(NetgenLayoutsIbexaBundle::class)) {
        return;
    }

    $routes->import('@NetgenLayoutsIbexaBundle/Resources/config/routing.yaml');
};
