<?php

namespace App\EventListener;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;

/**
 * Safe replacement for eZ\Bundle\EzPublishLegacyBundle\EventListener\RestListener.
 *
 * The upstream RestListener unconditionally calls ezxFormToken::setIntention(),
 * but that class only exists after the legacy kernel has booted (which never
 * happens on pure-Symfony siteaccesses such as /admin/).  We guard with
 * class_exists() so the admin UI works without triggering a ClassNotFoundError.
 */
class LegacyRestListener implements EventSubscriberInterface
{
    private string $csrfTokenIntention;

    public function __construct(string $csrfTokenIntention)
    {
        $this->csrfTokenIntention = $csrfTokenIntention;
    }

    public static function getSubscribedEvents(): array
    {
        // Use the same event constant as the original, supporting both
        // the old EzPlatformRestBundle namespace and the newer Ibexa\Bundle\Rest one.
        $events = [];

        if (class_exists(\Ibexa\Bundle\Rest\RestEvents::class)) {
            $events[\Ibexa\Bundle\Rest\RestEvents::REST_CSRF_TOKEN_VALIDATED] = 'setCsrfIntention';
        } elseif (class_exists(\EzSystems\EzPlatformRestBundle\RestEvents::class)) {
            $events[\EzSystems\EzPlatformRestBundle\RestEvents::REST_CSRF_TOKEN_VALIDATED] = 'setCsrfIntention';
        }

        return $events;
    }

    public function setCsrfIntention(): void
    {
        if (!class_exists('ezxFormToken')) {
            return;
        }

        \ezxFormToken::setIntention($this->csrfTokenIntention);
    }
}
