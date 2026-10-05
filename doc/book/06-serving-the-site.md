# 6. Serving the site: Velocity, Apache, nginx and the rest

An installed Exponential Platform Legacy project is a Symfony application with one front controller in its web root:
`web/app.php` on the 2.5 line, `public/index.php` from 3.x on. Something has to accept connections, speak HTTP and
HTTPS, hand out the static files that may be handed out, and pass every other request to that front controller. This
chapter starts with **Exponential Velocity**, the application server of the Exponential family and the recommended way
at every stage: it listens on the HTTP and HTTPS ports itself, so no separate web server and no separate TLS
terminator are needed. It then covers the traditional setups shipped as examples in this repository (Apache 2.4,
nginx), the Symfony CLI for development, Varnish in front, the Docker and Platform.sh blueprints, and the file
permissions every setup needs. Several shipped files are not safe for production as they are; section 6.2 lists them
before any server is configured.

[Previous: 5. The legacy kernel inside](05-the-legacy-kernel-inside.md) · [Next: 7. Databases](07-databases.md) ·
[Contents](README.md)

---

## Contents of this chapter

1. [The choice in one table](#61-the-choice-in-one-table)
2. [What the web root may hand out](#62-what-the-web-root-may-hand-out)
3. [Exponential Velocity](#63-exponential-velocity)
4. [The Symfony CLI (development only)](#64-the-symfony-cli-development-only)
5. [Apache 2.4](#65-apache-24)
6. [nginx](#66-nginx)
7. [File permissions](#67-file-permissions)
8. [Reverse proxies and Varnish](#68-reverse-proxies-and-varnish)
9. [Docker](#69-docker)
10. [Platform.sh](#610-platformsh)
11. [Checklist](#611-checklist)
12. [References](#612-references)

---

## 6.1 The choice in one table

| | Exponential Velocity | Apache 2.4 + PHP-FPM | nginx + PHP-FPM | Symfony CLI |
|---|---|---|---|---|
| Role | **recommended**, development to production | traditional | traditional | development only |
| Separate web server | **no** | is the web server | is the web server | no |
| HTTPS | **built in**: your certificate files, a self-signed one, or Let's Encrypt | `mod_ssl` plus certbot or a panel | `ssl` module plus certbot | local certificate of the CLI |
| PHP needed | 8.1 or later | any the line supports | any the line supports | any the line supports |
| Shipped example in this repository | none; configuration derived in 6.3 from the engine's documentation | `doc/apache2/` (2.5 layout; 3.x adds `media-site*.conf`) | `doc/nginx/` (2.5 layout; 3.x adds `media-site.conf`) | commands in the READMEs |
| Suits shared hosting | usually not (a long-running process) | yes | rarely | no |

Use a traditional server when your hosting forbids long-running processes, when you run PHP 8.0 (4.6.x allows it;
Velocity needs 8.1), or when you already run a tuned Apache or nginx you want to keep.

## 6.2 What the web root may hand out

Every setup must enforce the same rules, so they are stated once here. They come from the shipped rewrite rules
(`web/.htaccess` and `doc/apache2/vhost.template` for 2.5, `public/.htaccess` of 3.x and of the 4.6.x and 5.x recipe).

1. **Only the front controller runs.** `web/app.php` (2.5) or `public/index.php`. Any other `.php` below the web root,
   in particular under `var/`, must never run because its path was requested. The shipped rules forbid executable
   extensions under `var/` (`RewriteRule ^var/.*(?i)\.(php3?|phar|phtml|sh|exe|pl|bin)$ - [F]`).
2. **Only listed files are sent as files.** The list:

   | Path | Why | Lines |
   |---|---|---|
   | `bundles/`, `assets/`, `build/` | bundle and Encore assets | all (`build/` from 3.x on) |
   | `design/<design>/(stylesheets\|images\|javascript\|fonts)/` | legacy design assets | all |
   | `extension/<ext>/design/<design>/(stylesheets\|flash\|images\|lib\|javascripts?\|fonts)/` | legacy extension assets | all |
   | `share/icons/` | legacy icons | all |
   | `var/<site>/storage/images(-versioned)/` | images of both kernels | all |
   | `var/<site>/cache/(texttoimage\|public)/` | legacy public cache (packed scripts and styles) | all |
   | `var/<site>/storage/original/image/*.svg`, `var/<site>/storage/sitemap/` | SVG originals, sitemaps | 3.x and later |
   | `packages/styles/...`, `var/storage/packages/` | legacy package previews | 2.5 |
   | `favicon.ico`, `robots.txt`, `images/` | site files | all |
   | `css/`, `js/`, `fonts/` (Assetic) | dumped Assetic assets, `prod` only | 2.5 |

   Everything else goes to the front controller, which answers with a page or a 404. This matters because the web
   root's `var` **is** `ezpublish_legacy/var` (a symbolic link made by `ezpublish:legacy:assets_install`, chapter 5,
   [5.3.4](05-the-legacy-kernel-inside.md#534-in-the-web-root)), so the legacy logs (`var/<site>/log/`), the compiled
   templates and every other legacy cache are below the web root. A server that hands out "every existing file"
   exposes them. (The project's own `var/`, with the Symfony cache and an SQLite database, is not below the web root.)
3. **Pass the `Authorization` header** to PHP (REST API, basic auth). The shipped Apache rules do it with
   `RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]`.

### 6.2.1 Shipped files to change before production

| File | What it does as shipped | Change it to |
|---|---|---|
| `web/.htaccess` (2.5) | the last rule sends **every request to `app_dev.php`**; the `app.php` rule is commented out | `RewriteRule ^(.*)$ app.php [QSA,L]` (and remove the `app_dev.php` line) |
| `web/app_dev.php` (2.5) | its check that only allows `127.0.0.1` and `::1` is commented out, then it sets `SYMFONY_ENV=dev` and `SYMFONY_DEBUG=true` | delete it on production servers, or restore the check; never route to it |
| `web/app.php` (2.5) | starts with `ini_set('display_errors', 'On')` | remove or set `Off`; errors belong in the log ([chapter 13](13-security-hardening.md)) |
| `public/.htaccess` (3.x, 4.6.x and 5.x recipe) | `SetEnvIf Request_URI ".*" APP_ENV=dev`: every request under Apache runs in `dev`, whatever `.env.local` says | remove the line, or set `APP_ENV=prod` |
| `doc/nginx/media-site.conf` (3.x) | `fastcgi_param APP_ENV dev;` and a PHP 7.3 socket | `prod` and your PHP-FPM socket |

Why this matters: in `dev` Symfony shows full stack traces with configuration values, enables the web profiler where
it is installed and compiles the container on every change. Together with the commented-out guard in `app_dev.php`, a
2.5 site served with the shipped `.htaccess` shows every visitor the debug toolbar.

## 6.3 Exponential Velocity

Velocity ([se7enxweb/exponential-velocity](https://github.com/se7enxweb/exponential-velocity)) is an application server
written in PHP: a parent process accepts every connection, answers static files itself, terminates TLS, and hands PHP
requests to workers. That is why a Velocity site needs no Apache, nginx, PHP-FPM or separate TLS terminator.

### 6.3.1 How this differs from Exponential 6

The Exponential 6 kernel ships a console command, `exp:velocity`, that writes Velocity's configuration from
`settings/velocity.ini` and starts it ([the Exponential 6 book, chapter 8](https://github.com/se7enxweb/exponential/blob/main/doc/install/08-serving-the-site.md)).
That command serves the **kernel's own root** with the kernel's `index.php`. In Exponential Platform Legacy the kernel
lives in `ezpublish_legacy/`, which is not the web root, and every request must go through Symfony's front controller
so that the bridge can inject the database and the other settings. Do not start `exp:velocity` from inside
`ezpublish_legacy/` for a Platform Legacy site. Start the engine directly, with the web root as its document root,
as its own documentation describes for Symfony applications. The configuration below is **derived** from that
documentation (`README.md`, `docs/configuration.md`, `docs/compatibility.md`, `docs/https.md` of the engine at
v0.0.4.43) and from the rules of section 6.2; it is not shipped by this project. Test it with section 6.3.8 before you
rely on it.

### 6.3.2 Install the engine

The engine needs PHP 8.1 or later with the `sockets` extension (required by its `composer.json`), `pcntl` and `posix`
(workers) and `openssl` (HTTPS). Either add it to the project:

```bash
composer require se7enxweb/exponential-velocity
php vendor/se7enxweb/exponential-velocity/sbin/qbixserver.php --version
```

or keep one copy for the machine, outside every project:

```bash
git clone https://github.com/se7enxweb/exponential-velocity.git /opt/exponential-velocity
php /opt/exponential-velocity/sbin/qbixserver.php --version
```

Expect a line such as `Qbix Server v0.0.4.43+...`: the engine keeps its upstream program names (`qbixserver`,
`qbixctl`) for compatibility. The examples below write `qbixserver` for whichever path you chose. The engine is also
available as operating-system packages and container images ([section 6.9](#69-docker)).

### 6.3.3 Two ways to run a Symfony application

Velocity runs PHP in its own CLI process, and under the CLI SAPI PHP's built-in `header()`, `setcookie()` and
`http_response_code()` do nothing. Symfony sends its headers with exactly those functions. The engine documents two
answers:

| Mode | How | Native `header()` | Cost | When |
|---|---|---|---|---|
| **CGI carve-out** | scripts matching `Q.webserver.cgi.patterns` run in a `php-cgi` process per request | works natively | about 50 ms of start-up per request (the engine's figure); static files and the server stay fast | the safe start; the mode the engine's documentation describes for Symfony, Laravel and WordPress |
| **Persistent workers** with `--preset=symfony` | the engine rewrites the included PHP so that `header()` and 43 other functions reach the response, and restores static state between requests | shimmed | the fastest: the application stays loaded | after the checks of 6.3.8 pass on your site |

For the persistent mode two things are specific to this product:

- The legacy kernel fills its datatype, workflow event and notification event registries once with `include_once`.
  Between requests the engine resets globals, so these must be **kept**, or publishing in the legacy kernel fails with
  `Call to a member function initializeEvent() on null`. The engine's `exponential` preset keeps them; with the
  `symfony` preset name them yourself with `--keep-globals` (the list below is the one the `exponential` preset uses).
- Per-siteaccess injected settings leak between requests of one process (chapter 5, [5.5.2](05-the-legacy-kernel-inside.md#552-what-the-project-injects-3x-46x-5x)).
  The 4.6.x and 5.x recipe leaves them empty; on 3.x move them to INI files before using persistent workers.

### 6.3.4 The configuration file

Keep the engine's configuration in a JSON file outside the web root, for example `velocity.json` in the project root.
For **3.x, 4.6.x and 5.x**:

```json
{
  "Q": {
    "web": {
      "static": {
        "paths": [
          "^/(bundles|assets|build|images)/",
          "^/design/[^/]+/(stylesheets|images|javascript|fonts)/",
          "^/extension/[^/]+/design/[^/]+/(stylesheets|flash|images|fonts|lib|javascripts?)/",
          "^/share/icons/",
          "^/var/([^/]+/)?storage/images(-versioned)?/",
          "^/var/([^/]+/)?storage/original/image/.+\\.svg$",
          "^/var/([^/]+/)?storage/sitemap/",
          "^/var/([^/]+/)?cache/(texttoimage|public)/",
          "^/(favicon\\.ico|robots\\.txt)$"
        ]
      },
      "cache": { "enabled": false }
    },
    "webserver": {
      "scripts": ["/index.php"],
      "cgi": { "patterns": ["\\.php$"] },
      "fallback": "index.php"
    }
  }
}
```

What each part does:

- `web.static.paths`: section 6.2, rule 2, as patterns. A file whose path matches is sent as it is; any other file,
  `ezpublish_legacy/var/site/log/error.log` reached through `public/var` included, goes to the front controller
  instead. Without this key the engine hands out every file with a served extension.
- `web.cache.enabled: false`: the engine's own response cache is off by default since v0.0.4.39; saying so explicitly
  keeps a cache module enabled elsewhere in `/etc/qbix` from switching it on. Symfony's HTTP cache (2.5 `prod`) or
  Varnish does the page caching for this product.
- `webserver.scripts`: only `index.php` runs when asked for by name; any other `.php` is treated as if it did not exist
  and goes to the front controller.
- `webserver.cgi.patterns` and `fallback`: the CGI carve-out of section 6.3.3, and every URL that is not a file to
  `index.php`. Leave out `cgi` to use persistent workers (section 6.3.5).

For the **2.5 line** the web root is `web/` and the front controller `app.php`; the list follows `web/.htaccess` and
`doc/apache2/vhost.template`:

```json
{
  "Q": {
    "web": {
      "static": {
        "paths": [
          "^/(bundles|assets)/",
          "^/(css|js|fonts?)/.*\\.(css|js|otf|eot|ttf|svg|woff2?)$",
          "^/design/[^/]+/(stylesheets|images|javascript|fonts)/",
          "^/extension/[^/]+/design/[^/]+/(stylesheets|flash|images|lib|javascripts?)/",
          "^/share/icons/",
          "^/var/([^/]+/)?storage/images(-versioned)?/",
          "^/var/([^/]+/)?cache/(texttoimage|public)/",
          "^/packages/styles/.+/(stylesheets|images|javascript)/[^/]+/",
          "^/packages/styles/.+/thumbnail/",
          "^/var/storage/packages/",
          "^/(favicon\\.ico|robots\\.txt)$"
        ]
      },
      "cache": { "enabled": false }
    },
    "webserver": {
      "scripts": ["/app.php"],
      "cgi": { "patterns": ["\\.php$"] },
      "fallback": "app.php"
    }
  }
}
```

The engine also reads `.htaccess` rules; correct `web/.htaccess` first (section 6.2.1), so that nothing can route to
`app_dev.php`.

### 6.3.5 Start it

The CGI mode needs `php-cgi` (the engine finds it on the `PATH`; `Q.webserver.cgi.binary` names another one). Start on
a high port for the first test:

```bash
cd /var/www/my_project
qbixserver --root=public --config=velocity.json --host=127.0.0.1 --port=8080 --pid=var/velocity.pid
#          --root=web for the 2.5 line
```

Persistent workers instead of CGI (remove the `cgi` block from the file first):

```bash
qbixserver --root=public --config=velocity.json --host=127.0.0.1 --port=8080 --pid=var/velocity.pid \
  --preset=symfony --workers=8 \
  --keep-globals=eZDataTypes,eZDataTypeObjects,eZDataTypeAllowedTypes,eZWorkflowTypes,eZWorkflowTypeObjects,eZWorkflowAllowedTypes,eZNotificationEventTypes,eZNotificationEventTypeObjects,eZNotificationEventTypeAllowedTypes
```

Options used (`qbixserver --help` lists them all):

| Option | Meaning |
|---|---|
| `--root` | the document root: the web root of the project, never the project root |
| `--config` | the JSON file of 6.3.4 |
| `--host`, `--port`, `--https-port` | bind address and ports; the engine's defaults are `0.0.0.0`, 80 and 443 |
| `--pid` | pid file, used by `--stop` and `--reload` |
| `--workers` | size of the worker pool; the default is what fits in memory, at most 8 per core and 64 in all, never fewer than 4 |
| `--user`, `--group` | when started as root (ports below 1024): who the workers become; default the owner of the document root, never root |
| `--preset` | `symfony` loads the compatibility settings for a Symfony front controller |
| `--keep-globals` | globals kept between requests (section 6.3.3) |
| `--layout` | print which configuration files would be loaded, and exit: run it once, because the engine also reads `/etc/qbix` (and the `/etc/vc` overlay) when they exist |
| `-t` | test the configuration and exit |
| `--stop`, `--reload` | stop gracefully, or re-execute the server keeping its socket |

**The environment.** Symfony takes `APP_ENV` from the real environment first, then from `.env.local`. Put `APP_ENV=prod`
in `.env.local` (3.x and later) so the setting does not depend on how the server was started. On 2.5 `app.php`
defaults to `prod` when `SYMFONY_ENV` is not set.

**For visitors**, bind to all addresses on ports 80 and 443 (started as root; the workers drop to the site's user) and
add HTTPS (section 6.3.6):

```bash
sudo qbixserver --root=/var/www/my_project/public --config=/var/www/my_project/velocity.json \
  --host=0.0.0.0 --port=80 --https-port=443 --user=www-data --group=www-data \
  --pid=/run/velocity-my_project.pid
```

### 6.3.6 HTTPS

Velocity terminates TLS itself, with HTTP/2. Add one of these blocks under `Q.web` in `velocity.json`
(`docs/https.md` of the engine):

```json
"https": { "port": 443, "mode": "files",
           "cert": "/etc/ssl/example.com/fullchain.pem", "key": "/etc/ssl/example.com/privkey.pem" }
```

```json
"https": { "port": 443, "mode": "letsencrypt",
           "acme": { "email": "hostmaster@example.com", "domains": ["example.com", "www.example.com"] } }
```

```json
"https": { "port": 8443, "mode": "self-signed" }
```

Notes from the engine's documentation: Let's Encrypt needs DNS pointing at this machine and **port 80 of this server
reachable from the internet** (the HTTP-01 challenge); until the certificate arrives a self-signed one is served and the
real one replaces it without a restart; renewal runs in the background. A certificate pair that is expired or does not
match its key is never shown to visitors. On start the console prints a line such as `tls: certificate ready (...)`.
The same subject for Exponential 6, with the `/etc/vc` configuration tree, is in
[the Exponential 6 book, 8.3.9](https://github.com/se7enxweb/exponential/blob/main/doc/install/08-serving-the-site.md#839-https-served-by-velocity-itself).

Tell Symfony the requests arrive over HTTPS from Velocity itself: no trusted-proxy setting is needed when Velocity
terminates TLS, because PHP sees the request directly. A proxy in front of Velocity is section 6.8.

### 6.3.7 Running it as a service

The engine ships two systemd units: `service/qbixserver.service` (a plain example) and
`packaging/systemd/exponential-velocity.service` (the unit of the operating-system package, which reads
`/etc/default/exponential-velocity`). A unit for one project, **derived** from the plain example:

```ini
# /etc/systemd/system/velocity-my_project.service
[Unit]
Description=Exponential Velocity for my_project
After=network-online.target mariadb.service
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/var/www/my_project
ExecStart=/usr/bin/php /opt/exponential-velocity/sbin/qbixserver.php --root=public --config=velocity.json --host=0.0.0.0 --port=80 --https-port=443 --user=www-data --group=www-data --pid=/run/velocity-my_project.pid
ExecReload=/usr/bin/php /opt/exponential-velocity/sbin/qbixserver.php --reload --pid=/run/velocity-my_project.pid
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl enable --now velocity-my_project
systemctl status velocity-my_project
```

After a deploy, a changed PHP class or configuration reaches persistent workers only after `systemctl reload` (or a
restart); in CGI mode every request starts fresh. Clear the Symfony and legacy caches **after** the reload, so that no
page rendered by the old code is cached again ([chapter 9](09-operations.md)).

### 6.3.8 Check it

Run these against the test port before you open the site to visitors. Each line says what to expect.

```bash
B=http://127.0.0.1:8080
curl -s -o /dev/null -w '%{http_code}\n' $B/                          # 200 (or 30x): the front controller answers
curl -s -o /dev/null -w '%{http_code}\n' $B/legacy_admin/             # 200 or 30x: the legacy kernel through the bridge
curl -sI $B/bundles/ | head -1                                        # a 404 from Symfony, not a directory listing
curl -s -o /dev/null -w '%{http_code}\n' $B/var/site/log/error.log    # 404: the log is not handed out
curl -s -o /dev/null -w '%{http_code}\n' $B/app_dev.php               # 2.5: 404, never a debug page
curl -sI $B/ | grep -i -E '^(content-type|set-cookie|cache-control|x-debug)'   # Symfony's headers arrive; no X-Debug-Token
```

Then sign in to both admins, edit and publish a content object in the legacy admin (this exercises the kept registries
in the persistent mode) and upload an image (this exercises `var/` and image variations). The `X-Debug-Token` header
appears only in `dev`: its presence means the environment is wrong.

What can go wrong:

| Symptom | Cause | Fix |
|---|---|---|
| every page `200` but empty, or without `Set-Cookie` and `Location` | persistent mode without the shims: headers sent with `header()` are lost | use `--preset=symfony`, or the CGI mode |
| `Call to a member function initializeEvent() on null` when publishing in the legacy admin | persistent mode without `--keep-globals` | add the list of 6.3.5 |
| legacy admin without stylesheets | `ezpublish:legacy:assets_install` was not run, or a static path is missing | chapter 4, [4.6](04-installing.md#46-wire-up-the-legacy-kernel); compare the failing URL with 6.3.4 |
| `php-cgi: not found` | the CGI mode without the `php-cgi` binary | install it (`php-cgi`, `php8.3-cgi`, ...) or set `Q.webserver.cgi.binary` |
| the start stops with a bind error | another server owns the port | `ss -ltnp | grep ':80 '` |
| settings you did not write are active | the engine also loaded `/etc/qbix` or `/etc/vc` | `qbixserver --layout ...` shows the files |

> **Not verified for this book:** the configuration of this section is derived from the engine's documentation and
> code and was not run against a live installation of each line. The engine's documentation names Symfony among the
> applications it serves in both modes; the legacy kernel inside Symfony adds the two points of 6.3.3. Report results
> and corrections to the project's issue tracker.

## 6.4 The Symfony CLI (development only)

The [Symfony CLI](https://symfony.com/download) runs a local server with its own certificate:

```bash
symfony server:start                            # 3.x and later: finds public/ itself
symfony server:start --document-root=web        # 2.5
```

The READMEs list the addresses: `https://127.0.0.1:8000/` and the admin paths of chapter 4,
[4.10](04-installing.md#410-first-login). It is meant for development: one process, no production tuning.

## 6.5 Apache 2.4

### 6.5.1 The 2.5 line: doc/apache2

[doc/apache2/Readme.md](../apache2/Readme.md) explains two ways, both pointing the `DocumentRoot` at `web/`:

- a **virtual host with the rules inside** (`AllowOverride None`, recommended: no `.htaccess` lookups), shown in the
  Readme for the prefork MPM with `mod_php`;
- the **template** [doc/apache2/vhost.template](../apache2/vhost.template) for PHP-FPM through `mod_proxy_fcgi`, with
  every option, which the script `bin/vhost.sh` fills in.

Generate a virtual host from the template. The script takes most values as options; the PHP-FPM address has no
option and is read from the environment variable `FASTCGI_PASS` (every template variable can be given that way); without it the template gets the old default `unix:/var/run/php5-fpm.sock`:

```bash
FASTCGI_PASS=unix:/run/php-fpm/www.sock ./bin/vhost.sh --basedir=/var/www/my_project \
  --template-file=doc/apache2/vhost.template \
  --host-name=example.com --host-alias=www.example.com --sf-env=prod \
  > /etc/apache2/sites-available/my_project.conf
./bin/vhost.sh -h        # every option and its default
```

What the template does, rule by rule: sets `SYMFONY_ENV` with `SetEnvIf` (so rewrite conditions can read it), passes
`Authorization`, forbids executables under `var/`, serves image storage, the legacy asset paths, `favicon.ico`,
`robots.txt`, `bundles/` and `assets/` as files, serves the Assetic directories outside `dev`, answers `/app.php` in
the URL with 404, and rewrites everything else to `/app.php`. It also sets ten-year expiry on stored images (their URLs
change when they change) and gzip for text types.

The template uses `ServerName`, `DocumentRoot %BASEDIR%/web` and `DirectoryIndex app.php`. Before you reload:

```bash
apachectl configtest                 # Syntax OK
systemctl reload apache2             # httpd on Red Hat style systems
curl -sI http://example.com/ | head -1
```

If you use the shipped `web/.htaccess` instead (`AllowOverride All`), correct it first (section 6.2.1).

### 6.5.2 3.x, 4.6.x and 5.x: public/

The `doc/apache2/vhost.template` on the 3.x branch is unchanged from the 2.5 layout (`web/`, `app.php`) and does not
fit these lines. The 3.x branch adds `doc/apache2/media-site-vhost.conf` (rules inside, `DocumentRoot .../public`) and
`media-site.conf` (`AllowOverride All`, relying on `public/.htaccess`). The rules in `media-site-vhost.conf` lack the
legacy asset paths (`design/`, `extension/`, `share/icons/`, `var/.../cache/`), so the legacy admin loses its
stylesheets with it. The simplest correct setup is therefore the `.htaccess` route, with `public/.htaccess` corrected
(section 6.2.1); it already contains the legacy paths. A virtual host, **derived** from `media-site.conf` and the
Apache PHP-FPM handler:

```apache
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /var/www/my_project/public
    DirectoryIndex index.php

    <Directory /var/www/my_project/public>
        Options +FollowSymLinks -Indexes
        # public/.htaccess carries the rewrite rules (section 6.2); correct its APP_ENV line first
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost"
    </FilesMatch>

    # Pass the Authorization header for the REST API
    SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1

    ErrorLog  /var/log/apache2/my_project-error.log
    CustomLog /var/log/apache2/my_project-access.log combined
</VirtualHost>
```

`FollowSymLinks` is required: `public/var`, `public/design`, `public/extension`, `public/share` and `public/bundles/*`
are symbolic links. For HTTPS add a `*:443` virtual host with `SSLEngine on`, your certificate and
`Protocols h2 http/1.1`, then redirect port 80.

## 6.6 nginx

### 6.6.1 The 2.5 line: doc/nginx

[doc/nginx/Readme.md](../nginx/Readme.md) has a complete server block for `web/`; copy the parameter files first:

```bash
sudo cp -R doc/nginx/ez_params.d /etc/nginx/
```

| File | Content |
|---|---|
| `ez_prod_rewrite_params` | Assetic directories served as files (leave it out in `dev`) |
| `ez_rewrite_params` | image storage, favicon, robots, `bundles/`, `assets/`; 404 for `app.php` in the URL; everything else to `/app.php` |
| `ez_legacy_rewrite_params` | the legacy asset paths |
| `ez_fastcgi_params` | the FastCGI parameters for `app.php` |
| `ez_server_params` | `disable_symlinks off` (the web root contains links) and quiet favicon logging |

In the Readme's block, set `root /var/www/my_project/web;`, your `fastcgi_pass` (`unix:/run/php-fpm/www.sock` or
`127.0.0.1:9000`) and `fastcgi_param SYMFONY_ENV prod;`. `client_max_body_size 48m` limits uploads. The template
[doc/nginx/vhost.template](../nginx/vhost.template) is filled by `bin/vhost.sh --template-file=doc/nginx/vhost.template`
like the Apache one.

```bash
sudo nginx -t && sudo systemctl reload nginx
```

### 6.6.2 3.x, 4.6.x and 5.x: public/

The 3.x branch adds `doc/nginx/media-site.conf` with the parameter directory `doc/nginx/ibexa_params.d/` for
`public/index.php`. Two corrections are needed before production: it sets `fastcgi_param APP_ENV dev;` and a PHP 7.3
socket, and `ibexa_rewrite_params` has no legacy asset rules, so the legacy admin loses its stylesheets. Add the legacy
rules from the 2.5 file `ez_legacy_rewrite_params` (the paths are the same below `public/`) before the final rewrite:

```bash
sudo cp -R doc/nginx/ibexa_params.d doc/nginx/ez_params.d /etc/nginx/
```


```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/my_project/public;

    include ibexa_params.d/ibexa_rewrite_image_params;
    include ez_params.d/ez_legacy_rewrite_params;     # legacy design, extension, share and cache paths
    include ibexa_params.d/ibexa_rewrite_params;      # ends with: everything else to /index.php

    client_max_body_size 48m;

    location / {
        location ~ ^/index\.php(/|$) {
            include ibexa_params.d/ibexa_fastcgi_params;
            fastcgi_pass unix:/run/php-fpm/www.sock;
            fastcgi_param APP_ENV prod;
        }
        location ~ ^/var/.*(?i)\.(php3?|phar|phtml|sh|exe|pl|bin)$ {
            return 403;
        }
    }

    include ibexa_params.d/ibexa_server_params;
}
```

The order of the `include` lines matters: the legacy rules must come before the catch-all rewrite to `/index.php` at
the end of `ibexa_rewrite_params`. This block is **derived** from the two shipped files; check it with `nginx -t` and
the checks of 6.3.8 (same URLs, your port).

## 6.7 File permissions

One user owns the project files (the deploy user, for example `example`); the web server or Velocity's workers run as
a user that may **read** everything below the web root and the project's code, and **write** only to:

| Line | Writable |
|---|---|
| 2.5 | `var/`, `ezpublish_legacy/var/` (also reached as `web/var`) |
| 3.x | `var/`, `ezpublish_legacy/var/` (also `public/var`) |
| 4.6.x, 5.x | `var/`, `ezpublish_legacy/var/`, `src/LegacyRoot/var/site/storage/` |
| SQLite, any line | the database file and its directory |

ACLs give both users write access without making files world-writable:

```bash
HTTPDUSER=www-data
sudo setfacl -dR -m u:"$HTTPDUSER":rwX -m u:"$(whoami)":rwX var ezpublish_legacy/var
sudo setfacl  -R -m u:"$HTTPDUSER":rwX -m u:"$(whoami)":rwX var ezpublish_legacy/var
```

Never writable by the web server: `vendor/`, `config/` or `app/config/`, `src/` (except the storage directory above),
`.env.local`, `config/jwt/`. The JWT private key must be readable by the web server user and nobody else. The 2.5
guide's fallback `chmod -R 777` on the var directories works, but lets every account on the machine change the site's
cache and storage; use it only on a single-user development machine.

Velocity started as root drops its workers to `--user` and `--group` (by default the owner of the document root), so
the same rules apply. Do not run console commands as root: files they create in `var/` would not be writable by the
workers afterwards.

## 6.8 Reverse proxies and Varnish

When a proxy or load balancer terminates TLS or caches in front of the application, Symfony must trust it, or it
builds `http://` links and sees the proxy's address as the client's.

| Line | Trust the proxy | Disable Symfony's own HTTP cache |
|---|---|---|
| 2.5 | environment variable `SYMFONY_TRUSTED_PROXIES` (comma-separated, or `TRUST_REMOTE`), read by `web/app.php` | `SYMFONY_HTTP_CACHE=0` |
| 3.x, 4.6.x, 5.x | `TRUSTED_PROXIES` in `.env.local` (the shipped `.env` sets `127.0.0.1`) | the purge type and HTTP cache settings in [chapter 8](08-configuration.md) |

**Varnish.** [doc/varnish/varnish.md](../varnish/varnish.md) requires Varnish 5.1 or later (6.0 LTS recommended) with
the `xkey` module from varnish-modules. The VCL is `doc/varnish/vcl/varnish4_xkey.vcl`, with the backend and the ACLs of
purgers and debuggers in `doc/varnish/vcl/parameters.vcl` (edit `.host` and `.port` to your web server or Velocity).
On 2.5 switch the purge type at compile time with the environment variable `HTTPCACHE_PURGE_TYPE=varnish` (or `http`)
and name Varnish in `HTTPCACHE_PURGE_SERVER`; `app/config/env/generic.php` and `default_parameters.yml` read exactly
these names. The 2.5 installation guide's section on Varnish names `env(PURGE_TYPE)` and `env(HTTPCACHE_PURGE_SERVERS)`,
which no configuration reads, and `framework.trusted_proxies`, which `web/app.php` does not use. Purge all:
`php bin/console fos:httpcache:invalidate:path / --all`.

The legacy kernel's content view cache is invalidated by the legacy kernel itself when content is published in the
legacy admin; HTTP cache purges for content published there go through the bridge's HTTP cache purger. Test a publish
in each admin and check that the page changes in Varnish ([chapter 9](09-operations.md)).

## 6.9 Docker

`doc/docker/` (2.5, and unchanged on 3.x) contains the upstream Docker Compose blueprints: building blocks
`base-prod.yml` or `base-dev.yml` plus optional `redis.yml`, `varnish.yml`, `solr.yml`, `dfs.yml` and others, combined
through `COMPOSE_FILE` in `.env`. Their own README calls them "made mainly for automation" (QA, tests, demos). They are
built on the image `ezsystems/php:7.3-v1` (`.env`: `PHP_IMAGE`), and PHP 7.3 cannot install any current line
(chapter 2, [2.2](02-requirements.md#22-php-versions-per-line)). Use them as a reference for the services a stack
needs, not as they are. `install_script.sh` also runs `composer ezplatform-install`, which installs a clean database
each time.

Velocity publishes container images built on the official PHP images, one per PHP version and variant
(`ghcr.io/se7enxweb/exponential-velocity:php8.3-standard` and others, documented in the engine's `docs/docker.md`).
Mount the project and point the server at its web root:

```bash
docker run -d -p 8080:8080 -v "$PWD:/srv/site" \
  ghcr.io/se7enxweb/exponential-velocity:php8.3-standard \
  qbixserver --root=/srv/site/public --config=/srv/site/velocity.json --port=8080
```

Choose the PHP version of your line (8.4 for 5.x) and check that the image has the extensions of chapter 2,
[2.3](02-requirements.md#23-php-extensions) (`docker exec <container> qbixctl ext:check` lists the image's baseline).
The database runs in its own container or outside.

## 6.10 Platform.sh

`.platform.app.yaml`, `.platform/` and [doc/platformsh/](../platformsh/README.md) (2.5 and 3.x) are the upstream
Platform.sh files, marked "Beta" in their README. As shipped, `.platform.app.yaml` declares `type: php:7.3`, web root
`web` and `passthru: "/app.php"`, on the 3.x branch too, where the web root is `public/` and the front controller
`index.php`. They need at least the PHP version and, on 3.x, the web root and front controller changed before a
deployment can work. The 4.6.x and 5.x lines ship no Platform.sh files. This book does not cover Platform.sh further.

## 6.11 Checklist

- [ ] The shipped development settings are corrected (section 6.2.1).
- [ ] Only the front controller runs; only the listed paths are files (section 6.2; the checks of 6.3.8).
- [ ] `APP_ENV=prod` (3.x and later) or no `SYMFONY_ENV=dev` (2.5); no `X-Debug-Token` header.
- [ ] HTTPS works, and plain HTTP redirects to it.
- [ ] The writable directories are writable by the server's user, nothing else is (section 6.7).
- [ ] Both admins load with their stylesheets; publishing works in both.
- [ ] A proxy in front is trusted (section 6.8), and purges reach it.
- [ ] The server starts at boot (6.3.7, or the distribution's Apache or nginx unit).

## 6.12 References

In this repository:

- [doc/apache2/Readme.md](../apache2/Readme.md), [doc/apache2/vhost.template](../apache2/vhost.template),
  [doc/nginx/Readme.md](../nginx/Readme.md), [doc/nginx/vhost.template](../nginx/vhost.template),
  [doc/nginx/ez_params.d/](../nginx/ez_params.d/), [bin/vhost.sh](../../bin/vhost.sh)
- [web/.htaccess](../../web/.htaccess), [web/app.php](../../web/app.php), [web/app_dev.php](../../web/app_dev.php)
- [doc/varnish/varnish.md](../varnish/varnish.md), [doc/varnish/vcl/](../varnish/vcl/)
- [doc/docker/README.md](../docker/README.md), [doc/platformsh/README.md](../platformsh/README.md),
  [doc/platformsh/INSTALL.md](../platformsh/INSTALL.md), [.platform.app.yaml](../../.platform.app.yaml)
- On 3.x: [doc/apache2/media-site-vhost.conf](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/doc/apache2/media-site-vhost.conf),
  [doc/nginx/media-site.conf](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/doc/nginx/media-site.conf),
  [public/.htaccess](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/public/.htaccess)

External:

- Exponential Velocity: [repository](https://github.com/se7enxweb/exponential-velocity),
  [configuration](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/configuration.md),
  [compatibility](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/compatibility.md),
  [HTTPS](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/https.md),
  [response cache](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/cache.md),
  [Docker images](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/docker.md),
  [requirements](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/requirements.md)
- The Exponential 6 book: [8. Serving the site](https://github.com/se7enxweb/exponential/blob/main/doc/install/08-serving-the-site.md),
  [13. Security hardening](https://github.com/se7enxweb/exponential/blob/main/doc/install/13-security-hardening.md)
- Symfony: [configuring a web server](https://symfony.com/doc/current/setup/web_server_configuration.html),
  [proxies and load balancers](https://symfony.com/doc/current/deployment/proxies.html),
  [the Symfony CLI](https://symfony.com/doc/current/setup/symfony_cli.html),
  [file permissions](https://symfony.com/doc/current/setup/file_permissions.html)
- Apache HTTP Server: [mod_rewrite](https://httpd.apache.org/docs/2.4/mod/mod_rewrite.html),
  [mod_proxy_fcgi](https://httpd.apache.org/docs/2.4/mod/mod_proxy_fcgi.html),
  [AllowOverride](https://httpd.apache.org/docs/2.4/mod/core.html#allowoverride)
- nginx: [location](https://nginx.org/en/docs/http/ngx_http_core_module.html#location),
  [rewrite](https://nginx.org/en/docs/http/ngx_http_rewrite_module.html#rewrite),
  [fastcgi module](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)
- PHP: [FastCGI Process Manager](https://www.php.net/manual/en/install.fpm.php)
- Varnish: [varnish-modules (xkey)](https://github.com/varnish/varnish-modules);
  [FOSHttpCache, Varnish configuration](https://foshttpcache.readthedocs.io/en/latest/varnish-configuration.html)
- Upstream concepts: [HTTP cache](https://doc.ibexa.co/en/latest/infrastructure_and_maintenance/cache/http_cache/http_cache/),
  [reverse proxy](https://doc.ibexa.co/en/latest/infrastructure_and_maintenance/cache/http_cache/reverse_proxy/)
- Let's Encrypt: [challenge types](https://letsencrypt.org/docs/challenge-types/)
- systemd: [systemd.service](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html)

[Previous: 5. The legacy kernel inside](05-the-legacy-kernel-inside.md) · [Next: 7. Databases](07-databases.md) ·
[Contents](README.md)
