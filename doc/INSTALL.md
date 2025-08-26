## Exponential Platform 6.0 INSTALL


Requirements
------------

### Apache version:

   The latest version of the 1.3 branch.
   or
   Apache 2.x run in "prefork" mode.

### PHP version:

   The latest version of the 8.3 branch is strongly recommended.

   Note that you will have to increase the default "memory_limit" setting
   which is located in the "php.ini" configuration file to 64 MB or larger. (Don't
   forget to restart Apache after editing "php.ini".)

   The date.timezone directive must be set in php.ini or in
   .htaccess. For a list of supported timezones please see
   http://php.net/manual/en/timezones.php

### Composer version:

   The latest version of the 2.x branch is recommended.

### Database server:
   MySQL 4.1 or later (UTF-8 is required)
   or
   PostgreSQL 8.x
   or
   Oracle 11g


GitHub Installation Guide
------------------

- Clone the repository

`git clone git@github.com:se7enxweb/exponentialplatformlegacy.git;`

- Install Exponential Platform required PHP libraries like Zeta Components and Exponential Platform extensions as specified in this project's composer.json.

`cd exponentialplatformlegacy; composer install --keep-vcs --ignore-platform-reqs;`

Note: For the short term future the composer argument '--ignore-platform-reqs' is required to install the software via composer package dependencies successfully. This limitation will soon be removed in the future as we continue to update requirements within the composer package definition files for each package repostiory (tedious detail oriented work).

- Run Exponential Platform Console Installation of Default Database Content Packages

`php app/console ezplatform:install clean;`


For the rest of the installation steps you will find the installation guide at https://exponential.doc.exponential.earth/display/DEVELOPER/Step%2b1_%2bInstallation.html

And at: https://exponential.doc.exponential.earth/display/DEVELOPER/Installation%2bUsing%2bComposer.html

And at: https://exponential.doc.exponential.earth/display/DEVELOPER/Installation%2bGuide%2bfor%2bUnix-Based%2bSystems.html


Composer Installation Guide
------------------

- Download the package from [se7enxweb/exponential](https://packagist.org/packages/se7enxweb/exponentialplatformlegacy)

`mkdir exponentialplatformlegacy;`

- Install Exponential Platform required PHP libraries like Zeta Components and Exponential Platform extensions as specified in this project's composer.json.

`cd exponentialplatformlegacy; composer require se7enxweb/exponentialplatformlegacy:v2.5.0.0 --ignore-platform-reqs;`

Note: For the short term future the composer argument '--ignore-platform-reqs' is required to install the software via composer package dependencies successfully. This limitation will soon be removed in the future as we continue to update requirements within the composer package definition files for each package repostiory (tedious detail oriented work).

- Run Exponential Platform Console Installation of Default Database Content Packages

`php app/console ezplatform:install clean;`


For the rest of the installation steps you will find the installation guide at https://exponential.doc.exponential.earth/display/DEVELOPER/Step%2b1_%2bInstallation.html

And at: https://exponential.doc.exponential.earth/display/DEVELOPER/Installation%2bUsing%2bComposer.html

And at: https://exponential.doc.exponential.earth/display/DEVELOPER/Installation%2bGuide%2bfor%2bUnix-Based%2bSystems.html