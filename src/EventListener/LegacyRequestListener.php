<?php

namespace App\EventListener;

use Ibexa\Contracts\Core\Repository\Exceptions\NotFoundException;
use Ibexa\Contracts\Core\Repository\Repository;
use Ibexa\Contracts\Core\SiteAccess\ConfigResolverInterface;
use eZ\Publish\Core\MVC\Legacy\Security\LegacyToken;
use Ibexa\Core\MVC\Symfony\Security\User;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\HttpKernelInterface;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\Security\Core\Authentication\Token\Storage\TokenStorageInterface;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;

/**
 * Drop-in replacement for eZ\Bundle\EzPublishLegacyBundle\EventListener\RequestListener.
 *
 * The upstream class calls the removed $repository->setCurrentUser() and
 * $repository->getCurrentUserReference() methods. In Ibexa 4.x those have
 * moved to $repository->getPermissionResolver()->{set,get}CurrentUserReference().
 */
class LegacyRequestListener implements EventSubscriberInterface
{
    private ConfigResolverInterface $configResolver;
    private Repository $repository;
    private TokenStorageInterface $tokenStorage;

    public function __construct(
        ConfigResolverInterface $configResolver,
        Repository $repository,
        TokenStorageInterface $tokenStorage
    ) {
        $this->configResolver = $configResolver;
        $this->repository = $repository;
        $this->tokenStorage = $tokenStorage;
    }

    public static function getSubscribedEvents(): array
    {
        return [KernelEvents::REQUEST => 'onKernelRequest'];
    }

    public function onKernelRequest(RequestEvent $event): void
    {
        $request = $event->getRequest();

        if (
            $event->getRequestType() !== HttpKernelInterface::MAIN_REQUEST
            || !$this->configResolver->getParameter('legacy_mode')
            // A request can arrive without a session (for instance the error page of a
            // request Platform rejected); getSession() would throw SessionNotFoundException.
            || !$request->hasSession()
        ) {
            return;
        }

        $session = $request->getSession();
        if (!($session->isStarted() && $session->has('eZUserLoggedInID'))) {
            return;
        }

        try {
            $legacyUserId = (int) $session->get('eZUserLoggedInID');
            $token = $this->tokenStorage->getToken();
            $permissionResolver = $this->repository->getPermissionResolver();

            // Check if token is already a legacy token and user is already loaded.
            if (
                $token instanceof LegacyToken
                && $token->getUser() instanceof User
                && $token->getUser()->getAPIUserReference()->getUserId() === $legacyUserId
                && $permissionResolver->getCurrentUserReference()->getUserId() === $legacyUserId
            ) {
                return;
            }

            // Load user and set as current via PermissionResolver (Ibexa 4.x API).
            $apiUser = $this->repository->getUserService()->loadUser($legacyUserId);
            $permissionResolver->setCurrentUserReference($apiUser);

            if ($token instanceof TokenInterface) {
                $token->setUser(new User($apiUser));
                if (!$token instanceof LegacyToken) {
                    $this->tokenStorage->setToken(new LegacyToken($token));
                }
            }
        } catch (NotFoundException $e) {
            $this->tokenStorage->setToken(null);
            $session->invalidate();
        }
    }
}
