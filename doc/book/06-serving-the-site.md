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
| Shipped example in this repository | none; configuration derived in 6.3 from the engine's documentation | `doc/apache2/` (2.5 layout; on 3.x the `public/` layout from commit `7248e69`, plus `media-site*.conf`) | `doc/nginx/` (2.5 layout; 3.x adds `media-site.conf`) | commands in the READMEs |
| Suits shared hosting | usually not (a long-running process) | yes | rarely | no |

Use a traditional server when your hosting forbids long-running processes, when you run PHP 8.0 (4.6.x allows it;
Velocity needs 8.1), or when you already run a tuned Apache or nginx you want to keep.

## 6.2 What the web root may hand out

Every setup must enforce the same rules, so they are stated once here. They come from the shipped rewrite rules
(`web/.htaccess` and `doc/apache2/vhost.template` for 2.5, `public/.htaccess` of 3.x and of the 4.6.x and 5.x recipe).

1. **Only the front controller runs.** `web/app.php` (2.5) or `public/index.php`. Any other `.php` below the web root,
   in particular under `var/`, must never run because its path was requested: `var/` holds uploaded files, and a
   script that an editor managed to upload would otherwise run with the site's rights. The shipped rules forbid
   executable extensions under `var/`, and how the rule is written depends on where it stands:

   | Where | Rule | Why the difference |
   |---|---|---|
   | `.htaccess` (3.x `public/.htaccess`, the 4.6.x and 5.x recipe) | `RewriteRule ^var/.*(?i)\.(php3?\|phar\|phtml\|sh\|exe\|pl\|bin)$ - [F]` | in a directory context the path has no leading slash |
   | virtual host (`doc/apache2/vhost.template`) | `RewriteRule ^/var/.*(?i)\.(...)$ - [F]` | in a server context the path starts with `/` |

   The template carried the `.htaccess` spelling, which never matches in a virtual host, until 2026-10-05 (commits
   `01e4d59` on `master`, `984732f` on 3.x; released in `v2.5.0.4` and `v3.3.44.8`). A virtual host generated from an
   older template has no working protection: correct the line by hand. The 2.5 `web/.htaccess` has **no** such rule,
   and its rule `RewriteCond %{REQUEST_URI} ^/(assets|bundles|design|extension)/` passes every file below `design/` and
   `extension/` through unchanged, `.php` files included. Behind it, hand only the front controller to PHP
   (section 6.5.1 shows how), so that a passed-through `.php` file is never executed.
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

### 6.2.1 Shipped files to check before production

Several front-controller files were shipped with development settings. The branches were corrected on 2026-10-05, and the
releases of that day carry the corrections (`v2.5.0.4`, `v3.3.44.8`); the older tags still contain the old files, and a project keeps whatever it was created from. Find your case in the
table, then check your own copy with the commands below it.

| File | Up to `v2.5.0.3` / `v3.3.44.7`, or as the recipe writes it | On the branch and since the release named | What to do on a project from the tag |
|---|---|---|---|
| `web/.htaccess` (2.5) | `v2.5.0.1` to `v2.5.0.3` and `v5.0.3`: the last rule sends **every request to `app_dev.php`** | every request that is not a static file goes to `app.php`; `/app_dev.php/...` is passed through only when asked for by name (`fa091cd`, `v2.5.0.4`) | take the branch's file, or end the file with `RewriteRule ^(.*)$ app.php [QSA,L]` and nothing routing to `app_dev.php` |
| `web/app_dev.php` (2.5) | the check that only allows the local machine is commented out, so anyone gets `dev` with debugging | the check is active: requests from `127.0.0.1`, `::1` or the PHP built-in server pass, others get `403 You are not allowed to access this file`; `SYMFONY_DEV_ALLOW_REMOTE=1` in the server's environment opens it on a development server (`d924ceb`, `v2.5.0.4`) | delete the file on production servers, or take the branch's file; never set `SYMFONY_DEV_ALLOW_REMOTE` in production |
| `web/app.php` (2.5) | starts with `ini_set('display_errors', 'On')` for every request | sets nothing at the top; with debugging off it switches `display_errors` and `display_startup_errors` off (`7605f57`, `v2.5.0.4`) | take the branch's file; errors belong in the log ([chapter 13](13-security-hardening.md)) |
| `public/.htaccess` (3.x) | `v3.3.44.7`: `SetEnvIf Request_URI ".*" APP_ENV=dev`, so every request under Apache runs in `dev` whatever `.env.local` says | the line is commented out and set to `prod`; the environment comes from the server, `.env.local` or `.env` (`66f13e1`, `v3.3.44.8`) | delete the line, or change it to `APP_ENV=prod` |
| `public/.htaccess` (4.6.x, 5.x, from the Flex recipe) | `SetEnvIf Request_URI ".*" APP_ENV=dev` | unchanged: the recipe has not been corrected yet | delete the line, or change it to `APP_ENV=prod`; the recipe does not overwrite your file on later updates |
| Legacy INI files of the 4.6.x and 5.x recipe (slots 1.2 and 1.4) | `[DebugSettings] DebugOutput=enabled`: slot 1.2 in `src/ezpublish_legacy/app/settings/siteaccess/legacy_site/site.ini.append.php`, slot 1.4 in that file, in `.../siteaccess/site/site.ini.append.php` and in the global `src/LegacySettings/override/site.ini.append.php` (which also sets `ShowUsedTemplates=enabled`) | unchanged; a recipe correction is pending | set `DebugOutput=disabled` (and `ShowUsedTemplates=disabled`) in those files: the legacy kernel then stops appending its debug report, with SQL, timings and file paths, to pages |
| `doc/nginx/media-site.conf` (3.x) | `fastcgi_param APP_ENV dev;` and a PHP 7.3 socket | unchanged | `prod` and your PHP-FPM socket |

Why this matters: in `dev` Symfony shows full stack traces with configuration values, enables the web profiler where
it is installed and compiles the container on every change. A 2.5 site served with the `.htaccess` of `v2.5.0.3`
shows every visitor the debug toolbar, and the `SetEnvIf` line wins over `.env.local` because a server variable takes
precedence over the `.env` files.

Check your copy, from the project root:

```bash
# 2.5: the last rewrite rule must name app.php, and app_dev.php must contain an active check
grep -n -E '^RewriteRule .*(app|app_dev)\.php' web/.htaccess
grep -n -E '^/\*|^\*/|REMOTE_ADDR' web/app_dev.php
grep -n "display_errors" web/app.php
# 3.x, 4.6.x, 5.x: no line may force dev
grep -n -E '^[^#]*APP_ENV=dev' public/.htaccess
# 4.6.x, 5.x: the legacy debug report must be off
grep -rn -E '^(DebugOutput|ShowUsedTemplates)=enabled' src/LegacySettings src/ezpublish_legacy/app/settings
```

Expected on a corrected 2.5 project: the last `.htaccess` line printed is `RewriteRule ^(.*)$ app.php [QSA,L]`;
`app_dev.php` prints only the `REMOTE_ADDR` line, without the `/*` and `*/` lines around it that commented the check
out in `v2.5.0.3`; `app.php` prints only `ini_set('display_errors', '0');`. Expected on the newer lines: no output from
the last two commands. And from outside, against the live site:

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://example.com/app_dev.php/        # 2.5: 403 (or 404 if deleted)
curl -sI https://example.com/ | grep -i '^x-debug-token'                          # no output: not dev
```

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
| **Persistent workers** | the engine's compatibility layer (`Q.compat`) rewrites the included PHP so that `header()` and 43 other functions reach the response, and restores static state between requests | shimmed | the fastest: the application stays loaded | after the checks of 6.3.8 pass on your site |

For the persistent mode three things are specific to this product:

- The legacy kernel fills its datatype, workflow event and notification event registries once with `include_once`.
  Between requests the engine resets globals, so these must be **kept**, or publishing in the legacy kernel fails with
  `Call to a member function initializeEvent() on null`. The engine's `exponential` preset keeps them, but that preset
  is written for the kernel served on its own (its file and script lists assume the kernel's root, not Symfony's web
  root), so name the globals yourself, as `Q.webserver.keepGlobals` in the file or with `--keep-globals`.
- Per-siteaccess injected settings leak between requests of one process (chapter 5, [5.5.2](05-the-legacy-kernel-inside.md#552-what-the-project-injects-3x-46x-5x)).
  The 4.6.x and 5.x recipe leaves them empty; on 3.x move them to INI files before using persistent workers.
- Write the compatibility settings into the file rather than using `--preset=symfony`. That preset sets only the
  front-controller rewrite to `index.php` and a few `ini` values, among them `upload_max_filesize=10M` and
  `post_max_size=12M`, which the engine enforces when it parses uploads; and a preset is applied **after** the
  configuration file, so it overrides your own values. The file of section 6.3.4 sets the same things with values that
  suit this product, and with `app.php` on the 2.5 line.

### 6.3.4 The configuration file

Keep the engine's configuration in a JSON file outside the web root, for example `velocity.json` in the project root.
For **3.x, 4.6.x and 5.x**, in the CGI mode:

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
      "cgi": { "patterns": ["\\.php$"] }
    }
  }
}
```

What each part does:

- `web.static.paths`: section 6.2, rule 2, as patterns. A file whose path matches is sent as it is; any other file,
  `ezpublish_legacy/var/site/log/error.log` reached through `public/var` included, goes to the front controller
  instead. Without this key the engine hands out every file with a served extension. Anchor every pattern with `^/`:
  an unanchored pattern matches anywhere in the path.
- `web.cache.enabled: false`: the engine's own response cache is off by default since v0.0.4.39; saying so explicitly
  keeps a cache module enabled elsewhere in `/etc/qbix` from switching it on. Symfony's HTTP cache (2.5 `prod`) or
  Varnish does the page caching for this product.
- `webserver.scripts`: only `index.php` runs when asked for by name; any other `.php` is treated as if it did not exist
  and goes to the front controller.
- `webserver.cgi.patterns`: the CGI carve-out of section 6.3.3. Every URL that is neither a listed file nor a listed
  script goes to `index.php`, the engine's default front controller, so no rewrite rule is needed.

Do **not** add `Q.webserver.fallback` (shown in some engine examples for single-page applications): it is meant for a
static file, and in the engine's code up to v0.0.4.43 a string or `file` fallback calls a method that does not exist,
so a request that reaches it ends in an error instead of a page.

For the **persistent mode**, replace the `cgi` block with the compatibility settings and the kept globals:

```json
    "compat": {
      "rewrite": "index.php",
      "ini": { "upload_max_filesize": "48M", "post_max_size": "48M", "memory_limit": "512M" }
    },
    "webserver": {
      "scripts": ["/index.php"],
      "keepGlobals": [
        "eZDataTypes", "eZDataTypeObjects", "eZDataTypeAllowedTypes",
        "eZWorkflowTypes", "eZWorkflowTypeObjects", "eZWorkflowAllowedTypes",
        "eZNotificationEventTypes", "eZNotificationEventTypeObjects", "eZNotificationEventTypeAllowedTypes"
      ]
    }
```

`compat` stands next to `web` and `webserver` inside `Q`. The `ini` values are what the application sees through
`ini_get()` and what the engine applies to uploads; the process's real limits come from the `php.ini` of the PHP CLI
that runs the engine, so set `memory_limit` there as well.

For the **2.5 line** the web root is `web/` and the front controller is `app.php`, which the engine does not know by
default. `webserver.frontControllers` names it; the static list follows `web/.htaccess` and
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
      "frontControllers": { "^/": "app.php" },
      "cgi": { "patterns": ["\\.php$"] }
    }
  }
}
```

In the persistent mode on 2.5, `compat.rewrite` is `app.php`. `app_dev.php` is not in `scripts`, so a request for it
goes to `app.php` like any other unknown script: the development front controller is unreachable under this
configuration, which is what production needs. Do not rely on `web/.htaccess` under Velocity: the engine's
documentation states that a pooled worker runs the script the server chose and does not read `.htaccess` to choose
it. The JSON file is the routing.

### 6.3.5 Start it

The CGI mode needs `php-cgi` of the same PHP version (the engine looks for `php-cgi`, `php-cgi8.3`, `php-cgi8.2` and
`php-cgi8.1` on the `PATH`; for any other name or version set `Q.webserver.cgi.binary`). Start on a high port for the
first test:

```bash
cd /var/www/my_project
qbixserver --root=public --config=velocity.json --host=127.0.0.1 --port=8080 --pid=var/velocity.pid
#          --root=web for the 2.5 line
```

Persistent workers instead of CGI, with the file's `compat` and `keepGlobals` of section 6.3.4:

```bash
qbixserver --root=public --config=velocity.json --host=127.0.0.1 --port=8080 --pid=var/velocity.pid --workers=8
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
| `--keep-globals` | globals kept between requests, the same as `Q.webserver.keepGlobals` (section 6.3.3) |
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

When Velocity terminates TLS itself, Symfony needs no trusted-proxy setting: the engine sets `HTTPS=on` and
`REQUEST_SCHEME=https` for a request that arrived over TLS, and PHP sees the visitor's address as `REMOTE_ADDR`.
Symfony therefore builds `https://` links and secure cookies without being told anything. A proxy or load balancer in
front of Velocity is section 6.8.

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
| every page `200` but empty, or without `Set-Cookie` and `Location` | persistent mode with the compatibility layer switched off (`Q.compat.skipSourceCodeTransform: true` somewhere in the loaded configuration): headers sent with `header()` are lost | remove that setting (`--layout` shows where it comes from), or use the CGI mode |
| `Call to a member function initializeEvent() on null` when publishing in the legacy admin | persistent mode without the kept globals | add `keepGlobals` of 6.3.4 |
| 2.5: every clean URL answers the engine's 404 page, `/app.php` works | no front controller named: the engine looks for `index.php`, which `web/` does not have | `"frontControllers": { "^/": "app.php" }` (6.3.4) |
| a 500 or a closed connection for URLs that are not files | `Q.webserver.fallback` set to a file name (section 6.3.4) | remove `fallback` |
| uploads above 10 MB arrive with an upload error, or the whole form arrives empty above 12 MB | `--preset=symfony` sets `upload_max_filesize=10M` and wins over the file | drop the preset, set `Q.compat.ini` (6.3.4) |
| legacy admin without stylesheets | `ezpublish:legacy:assets_install` was not run, or a static path is missing | chapter 4, [4.6](04-installing.md#46-wire-up-the-legacy-kernel); compare the failing URL with 6.3.4 |
| `php-cgi: not found` | the CGI mode without the `php-cgi` binary | install it (`php-cgi`, `php8.3-cgi`, ...) or set `Q.webserver.cgi.binary` |
| the start stops with a bind error | another server owns the port | `ss -ltnp` lists who listens on `:80` and `:443` |
| settings you did not write are active | the engine also loaded `/etc/qbix` or `/etc/vc` | `qbixserver --layout ...` shows the files |

> **Not verified for this book:** the configuration of this section is derived from the engine's documentation and
> code and was not run against a live installation of each line. The engine's documentation names Symfony among the
> applications it serves in both modes; the legacy kernel inside Symfony adds the points of 6.3.3. Report results
> and corrections to the project's issue tracker; report anything that exposes a site by e-mail to
> `security@se7enx.com` instead ([13.11](13-security-hardening.md#1311-keeping-up-to-date)).

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

[doc/apache2/Readme.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/apache2/Readme.md) explains two ways, both pointing the `DocumentRoot` at `web/`:

- a **virtual host with the rules inside** (`AllowOverride None`, recommended: no `.htaccess` lookups), shown in the
  Readme for the prefork MPM with `mod_php`;
- the **template** [doc/apache2/vhost.template](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/apache2/vhost.template) for PHP-FPM through `mod_proxy_fcgi`, with
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

The template uses `ServerName`, `DocumentRoot %BASEDIR%/web` and `DirectoryIndex app.php`. Two lines to check in the
generated file before you use it:

- **The `var/` rule.** It must read `RewriteRule ^/var/.*(?i)\.(php3?|phar|phtml|sh|exe|pl|bin)$ - [F]`, with the
  slash after `^`. Templates before commit `01e4d59` (2026-10-05, released in `v2.5.0.4`) wrote `^var/`, which
  never matches in a virtual host (section 6.2, rule 1).
- **The PHP handler.** The template hands every `.php` file below `web/` to PHP-FPM (`<FilesMatch \.php$>`). Only
  `app.php` needs to run; narrowing the match to it means that a `.php` file which a rewrite rule passes through as a
  static path (anything below `design/`, `extension/`, `var/storage/images/`) can never be executed:

  ```apache
  <FilesMatch "^app\.php$">
      SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost/"
  </FilesMatch>
  ```

Before you reload:

```bash
apachectl configtest                 # Syntax OK
systemctl reload apache2             # httpd on Red Hat style systems
curl -sI http://example.com/ | head -1                                   # HTTP/1.1 200 OK (or a redirect)
curl -s -o /dev/null -w '%{http_code}\n' http://example.com/var/x.php    # 403: the var/ rule works
```

If you use the shipped `web/.htaccess` instead (`AllowOverride All`), take the corrected file of the branch or correct
it first (section 6.2.1). It has no `var/` rule of its own, so the narrowed handler above matters even more there.
Up to `v2.5.0.3` it also sends `content/treemenu` URLs to `index_treemenu.php`, the tree menu front controller of a
stand-alone legacy kernel. Behind the bridge that file does not exist in `web/`: the bridge's `assets_install` writes
only `index_rest.php` and `index_cluster.php` there. Those requests therefore end in a 404, and the legacy admin's
left-hand content tree can stay empty. Commit `523606a` (2026-10-05, released in `v2.5.0.4`) removes the rule, so
the URLs reach `app.php`, where the bridge's route `_ezpublishLegacyTreeMenu`
(`/content/treemenu/{nodeId}/{modified}/{expiry}/{perm}`, loaded through `_ezpublishLegacyRoutes` in
`app/config/routing.yml`) answers them; on an older project delete the line
`RewriteRule ^([^/]+/)?content/treemenu.* index_treemenu.php [L]` yourself. The rewrite was checked on a test Apache
(the URL now reaches `app.php`), the tree menu itself not on a live installation. The example
`doc/apache2/.htaccess` had the same rule and still sent every request to `app_dev.php`; since commit `6ba381b` it is
the same file as `web/.htaccess`.

### 6.5.2 3.x, 4.6.x and 5.x: public/

Up to `v3.3.44.7` the `doc/apache2/vhost.template` on the 3.x branch is the 2.5 template and does not fit these
lines: it sets `DocumentRoot %BASEDIR%/web` and `DirectoryIndex app.php`, rewrites every URL to `/app.php`, and its
DFS cluster rule sends images to `/app.php` as well. On 3.x, 4.6.x and 5.x there is no `web/` and no `app.php`, so a
virtual host generated from it answers every dynamic URL with 404 (and serves nothing at all if `web/` does not
exist). Commit `7248e69` on the 3.x branch (2026-10-05, released in `v3.3.44.8`) replaces it with a template for
`public/` and `public/index.php`: `APP_ENV`, `APP_DEBUG`, `APP_HTTP_CACHE` and `TRUSTED_PROXIES` from the
placeholders `bin/vhost.sh` fills (its options keep their 2.5 names, `--sf-env` and so on, and it needs `--basedir`
because it only detects the root by a `web/` folder), the legacy asset paths, `build/` and `images/`, the `var/` rule,
404 for `index.php` in the URL and DFS images through `/index.php`. A virtual host generated from it passes
`apachectl configtest`; on a test Apache dynamic URLs reached `index.php`, `/var/.../x.php` gave 403 and
`/index.php/...` 404. The same commit rewrites the folder's `Readme.md` for this layout and makes its example
`.htaccess` the same file as `public/.htaccess`. On 3.x that template is the most complete virtual host with the
rules inside (the 4.6.x and 5.x branches ship no `doc/` folder). The 3.x branch also has
`doc/apache2/media-site-vhost.conf` (rules inside, `DocumentRoot .../public`) and
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

    # Only the front controller runs (section 6.2, rule 1)
    <FilesMatch "^index\.php$">
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

[doc/nginx/Readme.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/nginx/Readme.md) has a complete server block for `web/`; copy the parameter files first:

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
[doc/nginx/vhost.template](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/nginx/vhost.template) is filled by `bin/vhost.sh --template-file=doc/nginx/vhost.template`
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

| Line | Trust the proxy | Who reads it | Disable Symfony's own HTTP cache |
|---|---|---|---|
| 2.5 | environment variable `SYMFONY_TRUSTED_PROXIES` (comma-separated, or `TRUST_REMOTE` for whatever address connects) | `web/app.php`, with all `X-Forwarded-*` headers | `SYMFONY_HTTP_CACHE=0` |
| 3.x | `TRUSTED_PROXIES` in `.env.local` (the shipped `.env` sets `127.0.0.1`); `REMOTE_ADDR` trusts the connecting address | on the branch, `framework.trusted_proxies` in `config/packages/ezpublish.yaml` with the headers `x-forwarded-for`, `-proto`, `-port` (commit `d820756`, released in `v3.3.44.8`); with `v3.3.44.7` only the platform's deprecated fallback read it | the purge type and HTTP cache settings in [chapter 8](08-configuration.md) |
| 4.6.x, 5.x | `TRUSTED_PROXIES` in `.env.local` (the recipe's `.env` sets `127.0.0.1`) | on the branches, `config/packages/trusted_proxies.yaml` (commits `309785f`, `78e2848`; released in `v4.6.23.3`, `v5.0.3.1`); with `v4.6.23.2` and `v5.0.2` **nothing** reads it, so add that file (chapter 3, [3.4.5](03-getting-the-code.md#345-files-you-may-have-to-add-to-a-project-from-an-older-tag)) | the same |

Check what is in effect, from 3.x on: `php bin/console --env=prod debug:config framework trusted_proxies` must print
your proxies, not `null` or an empty value. What goes wrong without it: links and redirects point to `http://` behind an
HTTPS proxy (a redirect loop when the proxy forces HTTPS), the login cookie is not marked secure, and the logs and the
legacy kernel's user sessions see the proxy's address for every visitor.

**A proxy in front of Velocity.** Velocity then resolves the forwarded headers itself before PHP sees the request: it
replaces `REMOTE_ADDR` with the visitor's address and sets `HTTPS` only when the connection comes from an address in
`Q.webserver.proxy.trusted` (default `127.0.0.1` and `::1`; add your load balancer's addresses there). Symfony then
sees a direct HTTPS request and needs no trusted proxy of its own. Up to Velocity v0.0.4.43 the engine took
`X-Forwarded-Proto` from **any** client; from commit `380a64d` (2026-10-05, after v0.0.4.43, in the engine's next
release) it reads `X-Forwarded-Proto`, `CloudFront-Forwarded-Proto` and `CF-Visitor` only from trusted proxies, the
same list that decides `REMOTE_ADDR`, while a TLS connection to Velocity is HTTPS whoever makes it:

```json
{ "Q": { "webserver": { "proxy": { "trusted": ["127.0.0.1", "::1", "10.0.0.0/8"] } } } }
```

**Varnish.** [doc/varnish/varnish.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/varnish/varnish.md) requires Varnish 5.1 or later (6.0 LTS recommended) with
the `xkey` module from varnish-modules. The VCL is `doc/varnish/vcl/varnish4_xkey.vcl`, with the backend and the ACLs of
purgers and debuggers in `doc/varnish/vcl/parameters.vcl` (edit `.host` and `.port` to your web server or Velocity).
On 2.5 switch the purge type at compile time with the environment variable `HTTPCACHE_PURGE_TYPE=varnish` (or `http`)
and name Varnish in `HTTPCACHE_PURGE_SERVER`; `app/config/env/generic.php` and `default_parameters.yml` read exactly
these names. The 2.5 installation guide's section on Varnish names `env(PURGE_TYPE)` and `env(HTTPCACHE_PURGE_SERVERS)`,
which no configuration reads, and `framework.trusted_proxies`, which `web/app.php` does not use. Purge everything with
`php bin/console --env=prod fos:httpcache:invalidate:tag ez-all`: every page the platform caches carries the tag
`ez-all`. (`fos:httpcache:invalidate:path` takes a list of paths and has no `--all` option.)

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

`.platform.app.yaml`, `.platform/` and [doc/platformsh/](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/platformsh/README.md) (2.5 and 3.x) are the upstream
Platform.sh files, marked "Beta" in their README. What the application file declares:

| | Up to `v2.5.0.3`, `v3.3.44.7` | On the branch and since the release named |
|---|---|---|
| 2.5 | `type: php:7.3`, web root `web`, `passthru: "/app.php"`, `SYMFONY_ENV: prod`, `SYMFONY_TRUSTED_PROXIES: TRUST_REMOTE` | the same with `type: php:8.2` (commit `b41967c`, `v2.5.0.4`) |
| 3.x | the 2.5 file unchanged: PHP 7.3, `web`, `app.php`, `SYMFONY_*` variables, a `composer ezplatform-install` step that does not exist on 3.x | `type: php:8.3`, web root `public`, `passthru: "/index.php"`, `APP_ENV: prod`, `APP_DEBUG: 0`, `TRUSTED_PROXIES: REMOTE_ADDR`, install with `bin/console ibexa:install` (the default install type), cron `ibexa:cron:run` (commit `aa00125`, `v3.3.44.8`) |

A deployment from the older tags cannot work on either line (PHP 7.3 cannot install them); use the file of `v2.5.0.4`,
`v3.3.44.8` or the branch. The
4.6.x and 5.x lines ship no Platform.sh files. This book does not cover Platform.sh further.

## 6.11 Checklist

- [ ] The shipped development settings are corrected (section 6.2.1).
- [ ] Only the front controller runs: a request for `/var/x.php` answers 403 or 404, never runs (section 6.2); only the listed paths are files (the checks of 6.3.8).
- [ ] `APP_ENV=prod` (3.x and later) or no `SYMFONY_ENV=dev` (2.5); no `X-Debug-Token` header.
- [ ] HTTPS works, and plain HTTP redirects to it.
- [ ] The writable directories are writable by the server's user, nothing else is (section 6.7).
- [ ] Both admins load with their stylesheets; publishing works in both.
- [ ] A proxy in front is trusted (section 6.8: `debug:config framework trusted_proxies`, or `Q.webserver.proxy.trusted` for Velocity), and purges reach it.
- [ ] The server starts at boot (6.3.7, or the distribution's Apache or nginx unit).

## 6.12 References

In this repository:

- [doc/apache2/Readme.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/apache2/Readme.md), [doc/apache2/vhost.template](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/apache2/vhost.template),
  [doc/nginx/Readme.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/nginx/Readme.md), [doc/nginx/vhost.template](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/nginx/vhost.template),
  [doc/nginx/ez_params.d/](https://github.com/se7enxweb/exponential-platform-legacy/tree/master/doc/nginx/ez_params.d), [bin/vhost.sh](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/bin/vhost.sh)
- [web/.htaccess](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/web/.htaccess), [web/app.php](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/web/app.php), [web/app_dev.php](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/web/app_dev.php)
- [doc/varnish/varnish.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/varnish/varnish.md), [doc/varnish/vcl/](https://github.com/se7enxweb/exponential-platform-legacy/tree/master/doc/varnish/vcl)
- [doc/docker/README.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/docker/README.md), [doc/platformsh/README.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/platformsh/README.md),
  [doc/platformsh/INSTALL.md](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/platformsh/INSTALL.md), [.platform.app.yaml](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/.platform.app.yaml)
- On 3.x: [doc/apache2/media-site-vhost.conf](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/doc/apache2/media-site-vhost.conf),
  [doc/nginx/media-site.conf](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/doc/nginx/media-site.conf),
  [public/.htaccess](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/public/.htaccess),
  [doc/apache2/vhost.template](https://github.com/se7enxweb/exponential-platform-legacy/blob/3.x/doc/apache2/vhost.template)
- The 4.6.x and 5.x recipe's [public/.htaccess](https://github.com/se7enxweb/sevenx-recipes/blob/master/se7enxweb/exponential-platform-dxp/1.4/public/.htaccess);
  the branch fixes of 2026-10-05: [fa091cd](https://github.com/se7enxweb/exponential-platform-legacy/commit/fa091cd),
  [d924ceb](https://github.com/se7enxweb/exponential-platform-legacy/commit/d924ceb),
  [7605f57](https://github.com/se7enxweb/exponential-platform-legacy/commit/7605f57),
  [66f13e1](https://github.com/se7enxweb/exponential-platform-legacy/commit/66f13e1),
  [d820756](https://github.com/se7enxweb/exponential-platform-legacy/commit/d820756),
  [309785f](https://github.com/se7enxweb/exponential-platform-legacy/commit/309785f)

External:

- Exponential Velocity: [repository](https://github.com/se7enxweb/exponential-velocity),
  [configuration](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/configuration.md),
  [compatibility](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/compatibility.md),
  [HTTPS](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/https.md),
  [response cache](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/cache.md),
  [Docker images](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/docker.md),
  [requirements](https://github.com/se7enxweb/exponential-velocity/blob/main/docs/requirements.md),
  [the proxy header handling](https://github.com/se7enxweb/exponential-velocity/blob/main/src/Q/WebServer/Proxy.php) and
  [commit 380a64d](https://github.com/se7enxweb/exponential-velocity/commit/380a64d6dc9a55c047b7d850556fcb17352a5abc)
  (forwarded protocol only from trusted proxies)
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
- systemd: [systemd.service(5)](https://man7.org/linux/man-pages/man5/systemd.service.5.html)

[Previous: 5. The legacy kernel inside](05-the-legacy-kernel-inside.md) · [Next: 7. Databases](07-databases.md) ·
[Contents](README.md)
