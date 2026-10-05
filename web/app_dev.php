<?php
// This file is mainly here for use with symfony server commands.
// Recommended rewrite rules for apache and nginx does not use this.

// If you don't want to setup permissions the proper way (in dev), just uncomment the following PHP line
// read https://symfony.com/doc/current/setup.html#checking-symfony-application-configuration-and-setup
// for more information
//umask(0000);

// This check prevents access to debug front controllers that are deployed by accident to production servers.
// Only requests made on this machine (127.0.0.1, ::1, or the PHP built-in server) are let through.
// To open the dev front controller to other addresses on a development server you control,
// set SYMFONY_DEV_ALLOW_REMOTE=1 in that server's environment (e.g. "SetEnv SYMFONY_DEV_ALLOW_REMOTE 1"
// in the vhost). Never set it on a production server.
$allowRemoteDev = in_array(getenv('SYMFONY_DEV_ALLOW_REMOTE') ?: ($_SERVER['SYMFONY_DEV_ALLOW_REMOTE'] ?? ''), ['1', 'true'], true);
if (!$allowRemoteDev
    && (isset($_SERVER['HTTP_CLIENT_IP'])
        || isset($_SERVER['HTTP_X_FORWARDED_FOR'])
        || !(in_array($_SERVER['REMOTE_ADDR'] ?? '', ['127.0.0.1', '::1', '::ffff:127.0.0.1'], true) || PHP_SAPI === 'cli-server'))
) {
    header('HTTP/1.0 403 Forbidden');
    exit('You are not allowed to access this file. Check ' . basename(__FILE__) . ' for more information.');
}
unset($allowRemoteDev);

putenv('SYMFONY_ENV=dev');
putenv('SYMFONY_DEBUG=true');

require 'app.php';
