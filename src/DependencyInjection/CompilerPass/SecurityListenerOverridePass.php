<?php

declare(strict_types=1);

namespace App\DependencyInjection\CompilerPass;

use App\Security\SecurityListener;
use Symfony\Component\DependencyInjection\Compiler\CompilerPassInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;

/**
 * Runs at TYPE_OPTIMIZE (after TYPE_BEFORE_OPTIMIZATION) to override the class set by
 * EzPublishLegacyBundle's SecurityListenerPass, which forcibly resets the service class
 * to eZ\Bundle\EzPublishLegacyBundle\Security\SecurityListener at compile time.
 * This pass sets it back to our subclass which allows anonymous access to all siteaccesses.
 */
class SecurityListenerOverridePass implements CompilerPassInterface
{
    public function process(ContainerBuilder $container): void
    {
        if (!$container->hasDefinition('ezpublish.security.login_listener')) {
            return;
        }

        $container->findDefinition('ezpublish.security.login_listener')
            ->setClass(SecurityListener::class);
    }
}
