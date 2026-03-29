<?php

// ##########
// 7x Exponential Platform : app.php - Front Index
// ##########

ini_set('display_errors', 'On');
ini_set('display_startup_errors', 1);
// ini_set('error_reporting', "E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR" );

// phpinfo();

// ##########

use App\Kernel;

require_once dirname(__DIR__).'/vendor/autoload_runtime.php';

return function (array $context) {
    return new Kernel($context['APP_ENV'], (bool) $context['APP_DEBUG']);
};
