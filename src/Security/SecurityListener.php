<?php

namespace App\Security;

use eZ\Bundle\EzPublishLegacyBundle\Security\SecurityListener as LegacySecurityListener;
use eZ\Publish\Core\MVC\Symfony\SiteAccess;
use Symfony\Component\Security\Core\Authentication\Token\AnonymousToken;
use Symfony\Component\Security\Core\Authentication\Token\NullToken;

/**
 * Overrides the legacy-bridge SecurityListener (the final concrete class that wins the
 * service override chain) to allow anonymous users to access all frontend siteaccesses
 * regardless of DB SiteAccess policy limitation values. The default cleandata.sql ships
 * with a single hard-coded CRC32 hash that doesn't match project siteaccess names,
 * causing a redirect-to-login loop for anonymous visitors.
 */
class SecurityListener extends LegacySecurityListener
{
    protected function hasAccess(SiteAccess $siteAccess): bool
    {
        $token = $this->tokenStorage->getToken();

        // Anonymous tokens carry no credentials — skip the DB policy check entirely.
        if ($token instanceof AnonymousToken || $token instanceof NullToken) {
            return true;
        }

        return parent::hasAccess($siteAccess);
    }
}
