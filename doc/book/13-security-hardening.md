# 13. Security hardening

A hybrid installation has two applications to harden, and they share more than a database: one session cookie, one
secret, one storage directory and one web root. This chapter goes through them layer by layer: what the web server
must never hand out, the secrets and where they come from, debug output, the two admin interfaces, sign-in, sessions
and form tokens, trusted proxies on both sides (including the legacy kernel's `TrustedProxies[]` of Exponential
6.0.15), headers and HTTPS, file permissions and keeping up to date. Several defaults in the published releases are
development settings; most were corrected on the branches on 5 October 2026 and published the same day in the releases
`v2.5.0.4`, `v3.3.44.8`, `v4.6.23.3` and `v5.0.3.1`; the 4.6 and 5 recipes still carry two of them. Each is named here, with the commit that corrects it and
the change an existing site needs, because files outside `vendor/` are not updated by Composer.

[Previous: 12. Troubleshooting](12-troubleshooting.md) · [Contents](README.md)

## Contents of this chapter

- [13.1 The layers at a glance](#131-the-layers-at-a-glance)
- [13.2 What the web server must never hand out](#132-what-the-web-server-must-never-hand-out)
- [13.3 Secrets](#133-secrets)
- [13.4 Debug output and error display](#134-debug-output-and-error-display)
- [13.5 The admin siteaccesses](#135-the-admin-siteaccesses)
- [13.6 Sign-in, sessions and cookies](#136-sign-in-sessions-and-cookies)
- [13.7 Form tokens against cross-site request forgery](#137-form-tokens-against-cross-site-request-forgery)
- [13.8 Headers and HTTPS](#138-headers-and-https)
- [13.9 Behind a proxy: trusted proxies on both sides](#139-behind-a-proxy-trusted-proxies-on-both-sides)
- [13.10 File permissions](#1310-file-permissions)
- [13.11 Keeping up to date](#1311-keeping-up-to-date)
- [13.12 Go-live checklist](#1312-go-live-checklist)
- [References](#references)

## 13.1 The layers at a glance

| Layer | Symfony side | Legacy kernel | Shared |
|---|---|---|---|
| Entry point | `web/app.php` (2.5), `public/index.php` (later) | reached only through the Symfony front controller | the web root |
| Secrets | `SYMFONY_SECRET` / `APP_SECRET`, JWT keys (3.x and later) | none of its own for forms: the bridge gives it Symfony's | `kernel.secret` |
| Sign-in | Symfony security (`ezpublish_front` firewall on 2.5) | its own `user/login` on `legacy_mode` siteaccesses | the user table |
| Session | Symfony's session | uses Symfony's session; its own cookie settings are switched off | one cookie |
| Client address, HTTPS | Symfony's trusted proxies | `eZSys`, from 6.0.15 with `TrustedProxies[]` | `$_SERVER` |
| Files | `var/`, `public/var` link | `ezpublish_legacy/var/` | the storage directory |

## 13.2 What the web server must never hand out

The web root (`web/` on 2.5, `public/` later) contains the front controllers, built assets and four links into the
legacy kernel: `design`, `extension`, `share` and `var` ([8.6](08-configuration.md#86-designs-and-templates-on-both-sides)).
Everything else, including `app/`, `config/`, `.env*`, `vendor/`, `src/` and the legacy kernel's `settings/`, is
outside it, which is the first line of defence. The second line is the rewrite rules:

**Production must run `app.php`, never `app_dev.php`.** What a production 2.5 site needs from its front controllers:

| File | Production behaviour |
|---|---|
| `web/.htaccess` (or the vhost) | the final rule routes to `app.php` |
| `web/app_dev.php` | refuses every client that is not local (`127.0.0.1`, `::1`, or the PHP built-in server), and is better not deployed at all |
| `web/app.php` | never shows errors to visitors when debugging is off |

**The tagged 2.5 releases do not behave like this.** The releases `v2.5.0.0` to `v2.5.0.3` (and `v5.0.3`, which is a
`master` commit with the same files) ship development settings. From `v2.5.0.1` on their `web/.htaccess` ends with

```apache
# Route everything else to app.php (prod)
# RewriteRule ^(.*)$ app.php [QSA,L]

# Optional: enable dev front controller if needed
RewriteRule ^(.*)$ app_dev.php [QSA,L]
```

so every request runs the `dev` environment with the debug toolbar and full stack traces; in all of these releases
`web/app_dev.php` has its IP check commented out and `web/app.php` begins with `ini_set('display_errors', 'On')`.

**The correction is on `master`** since 5 October 2026, in three commits, and is in the 2.5
release [`v2.5.0.4`](https://github.com/se7enxweb/exponential-platform-legacy/releases/tag/v2.5.0.4) of the same day (`v5.0.3` keeps the old files, because published tags never move):

| Commit | File | Now |
|---|---|---|
| `fa091cd` | `web/.htaccess` | the last rule sends everything to `app.php`; a new rule above it lets `/app_dev.php/...` through only by its own name |
| `d924ceb` | `web/app_dev.php` | the check is active again: requests from `127.0.0.1`, `::1` or the PHP built-in server pass, anything else, and anything carrying `X-Forwarded-For` or `Client-IP`, gets `403 Forbidden`. A development server you control can open it with `SYMFONY_DEV_ALLOW_REMOTE=1` in its environment; never set that on a production server |
| `7605f57` | `web/app.php` | the `display_errors` lines are gone; with debugging off it sets `display_errors` and `display_startup_errors` to `0` itself, whatever `php.ini` says, so errors go to the log only |

The example `.htaccess` in `doc/apache2/` had the same final rule to `app_dev.php`; since commit `6ba381b` it is the
same file as `web/.htaccess`, so do not copy an older one into a site.

These are files Composer does not manage: `composer update` does not bring them into an existing project. On every
2.5 site, and on any copy you did not check yourself:

1. Check what you have:

   ```bash
   grep -nE '^[^#]*RewriteRule \^\(\.\*\)\$' web/.htaccess   # expected: ... app.php [QSA,L]
   grep -nE '^\s*if \(!\$allowRemoteDev|^\s*\|\| !\(in_array' web/app_dev.php   # expected: two uncommented lines
   grep -n "display_errors" web/app.php                      # expected: ini_set('display_errors', '0'); no 'On'
   ```

2. Bring the three files to the state of the commits above (copy them from `master`, or apply
   `git show fa091cd d924ceb 7605f57` to your copy), or use the virtual host rules of
   [`doc/apache2/vhost.template`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/apache2/vhost.template) (or the nginx ones in [`doc/nginx/`](https://github.com/se7enxweb/exponential-platform-legacy/tree/master/doc/nginx)) with
   `AllowOverride None`, which route to `app.php` and ignore `web/.htaccess`.
3. Remove `web/app_dev.php` from the production deployment anyway; the check is a safety net, not a reason to keep it.
4. Verify from outside:

   ```bash
   curl -sI https://example.com/ | grep -i x-debug-token          # expected: nothing (the profiler adds it only in dev)
   curl -s -o /dev/null -w '%{http_code}\n' https://example.com/app_dev.php/   # expected: 403 or 404
   ```

On the 3.x, 4.6 and 5 lines the equivalent switch is `APP_ENV` ([13.4](#134-debug-output-and-error-display)).

**Only asset paths may be served directly.** The vhost template passes through the legacy asset patterns
(`/design/<design>/(stylesheets|images|javascript|fonts)/`, `/extension/<ext>/design/<design>/(stylesheets|...)/`,
`/var/<site>/storage/images/`, ...) and sends everything else to `app.php`. The `web/.htaccess` of these releases is wider: it
passes `/(assets|bundles|design|extension)/...` through untouched, so any file in a legacy extension, including plain
`.ini` settings files and PHP files, is reachable by URL. Prefer the narrower patterns.

The pass-through rule is still in `web/.htaccess` on `master`; on a site that must use `.htaccess`, replace
`RewriteCond %{REQUEST_URI} ^/(assets|bundles|design|extension)/` with the narrower legacy patterns listed above it in
the same file, and keep `assets` and `bundles` (Symfony's built assets) as they are. To check:
`curl -s -o /dev/null -w '%{http_code}\n' https://example.com/extension/ezjscore/extension.xml` must not print `200`
(the request should reach `app.php` and end in a `404`).

**No PHP from `var/`.** Uploaded files land under `var/<site>/storage/`. In a virtual host the path a `RewriteRule`
sees starts with `/`. The vhost template of the releases up to `v2.5.0.3` (and of the 3.x releases up to
`v3.3.44.7`) has `RewriteRule ^var/.*(?i)\.(php3?|phar|phtml|sh|exe|pl|bin)$ - [F]`, which therefore never matches,
so a PHP file uploaded under `var/` could be requested. Commit `01e4d59` on `master` (`984732f` on 3.x; released in `v2.5.0.4` and `v3.3.44.8`) corrects it to

```apache
RewriteRule ^/var/.*(?i)\.(php3?|phar|phtml|sh|exe|pl|bin)$ - [F]
```

like the template's other rules; a vhost written from an older template needs the same one-character change by
hand. Make sure as well that the PHP handler (`<FilesMatch \.php$> SetHandler ...`) cannot apply below `var/`. Test it
with a harmless file: put `var/site/storage/test.php` containing `<?php echo 'x';`, request it, expect `403`, then
delete it. The Exponential 6 book, chapter 13.2, lists the same rules for the legacy kernel alone.

## 13.3 Secrets

| Secret | 2.5 | 3.x, 4.6, 5 | Shipped value, to replace |
|---|---|---|---|
| Framework secret (`kernel.secret`) | `env(SYMFONY_SECRET)` in `parameters.yml` | `APP_SECRET` | 2.5: `ThisEzPlatformTokenIsNotSoSecret_PleaseChangeIt`; 3.x: `ThisTokenIsNotSoSecretChangeIt` |
| Database password | `env(DATABASE_PASSWORD)` | in `DATABASE_URL` | 3.x `.env`: a demonstration URL with user and password for `demo_platformlegacy` |
| JWT for REST | none | `config/jwt/private.pem`, `JWT_PASSPHRASE` | 3.x: `ThisTokenIsNotSoSecretChangeIt` |
| Varnish purge token | `HTTPCACHE_VARNISH_INVALIDATE_TOKEN` | same | empty |

The framework secret is more than Symfony's: the bridge hands it to the legacy `ezformtoken` extension as the secret
of the legacy form tokens ([13.7](#137-form-tokens-against-cross-site-request-forgery)), and it signs remember-me
cookies and the CSRF tokens of Symfony forms. A known value lets anyone forge those.

- Generate a value: `openssl rand -hex 32`.
- 2.5: put secrets in `app/config/parameters.yml` (ignored by git through the shipped `.gitignore`) or, better, in the
  environment of the PHP-FPM pool and the cron user.
- 3.x and later: put them in `.env.local` (never in the committed `.env`) or use Symfony's secrets vault
  (`php bin/console secrets:set APP_SECRET`, `secrets:generate-keys` for production keys).
- After changing the framework secret, existing sessions' CSRF tokens and remember-me cookies become invalid; users
  sign in again.
- Never put database credentials into legacy INI files; the bridge injects them ([7.2](07-databases.md#72-how-the-bridge-hands-the-connection-to-the-legacy-kernel)).

## 13.4 Debug output and error display

| Where | Shipped | Production |
|---|---|---|
| 2.5 `web/app.php` | up to `v2.5.0.3`: `ini_set('display_errors', 'On')` and `ini_set('display_startup_errors', 1)` at the top; from `7605f57` on `master` (`v2.5.0.4`): error display switched off whenever debugging is off | the `master` file; set `display_errors=Off` in the PHP-FPM pool as well |
| 2.5 environment | `SYMFONY_ENV` unset means `prod`, but up to `v2.5.0.3` the committed `.htaccess` routes to `app_dev.php`, which forces `dev` (corrected in `fa091cd`, released in `v2.5.0.4`, [13.2](#132-what-the-web-server-must-never-hand-out)) | `prod`, `SYMFONY_DEBUG` unset or `0` |
| 3.x `public/.htaccess` | up to `v3.3.44.7`: `SetEnvIf Request_URI ".*" APP_ENV=dev`, which beats `.env.local`; from `66f13e1` on the `3.x` branch (`v3.3.44.8`): commented out | not forced in `.htaccess` |
| 4.6 and 5 `public/.htaccess` (written by the recipe) | `SetEnvIf Request_URI ".*" APP_ENV=dev`: every request through Apache runs in `dev`, whatever `.env.local` says. A correction of the recipes is pending the maintainers' approval | comment the line out, or set it to `prod` |
| 3.x and later `.env` | `APP_ENV=dev` in the committed `.env` | `APP_ENV=prod`, `APP_DEBUG=0` in `.env.local` or the environment |
| Legacy kernel, 2.5 and 3.x | master's override has `DebugOutput` and `Debug` commented out | keep `[DebugSettings] DebugOutput=disabled`; limit `DebugByIP` to your own addresses if you need it |
| Legacy kernel, 4.6 and 5 | the recipe's `src/LegacySettings/override/site.ini.append.php` has `[DebugSettings] DebugOutput=enabled` | set `DebugOutput=disabled` there |

Why the `.htaccess` line matters more than `.env.local`: Symfony's Dotenv never overwrites a variable that the web
server already set, and `SetEnvIf` sets one. The console does not read `.htaccess`, so `php bin/console about`
reports `prod` while the web pages run in `dev`; check from outside as in [13.2](#132-what-the-web-server-must-never-hand-out)
(`x-debug-token`).

```bash
grep -n 'APP_ENV' public/.htaccess        # expected: no uncommented SetEnvIf ... APP_ENV=dev
grep -n -A2 '^\[DebugSettings\]' src/LegacySettings/override/site.ini.append.php   # 4.6, 5: DebugOutput=disabled
```

With the debug toolbar or legacy debug output visible, a visitor sees SQL, settings, paths and sometimes credentials.

## 13.5 The admin siteaccesses

| Line | Platform admin | Legacy admin |
|---|---|---|
| 2.5 | `/admin/` (siteaccess `admin`, group `admin_group`) | `/legacy_admin/` (`legacy_mode: true`) |
| 3.x | siteaccess `adminui` (`ngsite.admin_siteaccess_name`) | `legacy_admin`, and `ngadminui` |
| 4.6, 5 | `/admin/` (siteaccess `admin`, group `admin_group`, added by the recipe's `ibexa_admin_ui.yaml`) | `/legacy_admin/` |

1. **Change the seed's administrator password** at once (the guides of every line document the seed account as
   `admin` / `publish`), in either admin; the user table is shared.
2. **Give admins their own host name** with a `Map\Host` matcher instead of `URIElement`, so that the admin
   siteaccesses do not answer on the public host ([8.5](08-configuration.md#85-siteaccesses-and-legacy_mode)).
3. **Restrict that host at the web server**: an IP allow list or an extra HTTP authentication in front of the
   application, which stops password guessing before PHP runs.
4. **Roles**: the platform and the legacy kernel use the same roles and policies tables; review them in either admin.
5. The legacy admin signs in with the legacy kernel's `user/login`. The kernel's sign-in lockout and password rules
   (Exponential 6 book, chapter 13.6) apply there; the platform admin's sign-in is Symfony's.

## 13.6 Sign-in, sessions and cookies

- **One session.** The bridge passes Symfony's session to the legacy kernel and injects `false` for the legacy
  `[Session] CookieTimeout`, `CookiePath`, `CookieDomain`, `CookieSecure` and `CookieHttponly`, so the legacy settings
  for the cookie are ignored. Configure the cookie in Symfony:

  ```yaml
  # 2.5: app/config/config.yml (Symfony 3.4: cookie_secure is a boolean, cookie_samesite exists)
  framework:
      session:
          cookie_secure: true          # the site runs on HTTPS only
          cookie_httponly: true        # the default
          cookie_samesite: lax
  ```

  A 4.6 installation's `framework.yaml` (written by Symfony's own Flex recipe) already has `cookie_secure: auto` and
  `cookie_samesite: lax` (the value `auto`
  exists from Symfony 4.2, so not on 2.5).
- **Session name**: Symfony names the session per siteaccess (`eZSESSID` plus a hash) unless configured; the 3.x
  configuration sets `eZSESSID` for its groups, so one sign-in covers them.
- **Legacy sign-in on public siteaccesses is switched off.** On every siteaccess without `legacy_mode` the bridge
  injects `SiteAccessRules` that disable the legacy modules `user/login` and `user/logout`, so there is only one
  sign-in form to harden, Symfony's.
- **Password reset** pages are outside the firewall on 2.5 (`ezpublish_forgot_password` with `security: false`);
  they must still be served over HTTPS.

## 13.7 Form tokens against cross-site request forgery

When the legacy `ezformtoken` extension is present, the bridge configures it from Symfony at every kernel build: its
secret becomes `kernel.secret` and its field name Symfony's CSRF field name, so forms built on one side validate on
the other. If Symfony's form CSRF protection is disabled, the bridge disables the legacy form tokens too. Keep
`framework.csrf_protection` enabled (2.5's `config.yml` has `csrf_protection: ~`, which enables it) and keep
`ezformtoken` active in the legacy kernel.

## 13.8 Headers and HTTPS

Send the security headers from the web server or the reverse proxy, so that they cover both kernels and static
files alike:

```apache
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
Header always set X-Content-Type-Options "nosniff"
Header always set Referrer-Policy "strict-origin-when-cross-origin"
Header always set X-Frame-Options "SAMEORIGIN"
```

Add a `Content-Security-Policy` only after testing both admins: the legacy admin and the platform admin load inline
scripts. Redirect plain HTTP to HTTPS at the web server. Behind a TLS-terminating proxy, both kernels must be told
that the request was HTTPS, which is the next section.

## 13.9 Behind a proxy: trusted proxies on both sides

A reverse proxy, load balancer or CDN reports the visitor's address and scheme in `X-Forwarded-*` headers. Any visitor
can send those headers too, so each application must believe them only from proxies it trusts. In this distribution
there are **two** applications reading them, and each has its own setting: Symfony's `Request` (platform code,
Symfony security, the HTTP cache) and the legacy kernel's `eZSys` (absolute URLs, redirects, `DebugByIP`, the sign-in
lockout, the audit log), which reads `$_SERVER` directly even inside a bridged request. (The legacy `CookieSecure`
logic plays no part here: the bridge switches the legacy cookie settings off, [13.6](#136-sign-in-sessions-and-cookies).)

**Symfony side, per line.** On every line from 3.x on the variable is `TRUSTED_PROXIES`, which each line's `.env`
sets to `127.0.0.1`; since 5 October 2026 each branch has a framework configuration that reads it:

| Line | Where the list comes from | Headers trusted |
|---|---|---|
| 2.5 | environment variable `SYMFONY_TRUSTED_PROXIES`, read in `web/app.php`: a comma-separated list, or `TRUST_REMOTE` to trust whatever `REMOTE_ADDR` is. `framework.trusted_proxies` in `config.yml`, shown in older guides, is deprecated since Symfony 3.3 and only triggers a deprecation notice; use the variable | all `X-Forwarded-*` (`HEADER_X_FORWARDED_ALL`) |
| 3.x | `framework.trusted_proxies: '%env(default::TRUSTED_PROXIES)%'` in `config/packages/ezpublish.yaml` (commit `d820756`, released in `v3.3.44.8`). Before it, and in the releases up to `v3.3.44.7`, only the deprecated fallback of `EzPlatformCoreExtension` (`se7enxweb/ezplatform-core`) read the variable, at container compile time and only when nothing else had set the proxies | `x-forwarded-for`, `x-forwarded-proto`, `x-forwarded-port` (the fallback: all but `X-Forwarded-Host`) |
| 4.6 | `config/packages/trusted_proxies.yaml` of the branch and of `v4.6.23.3` (commit `309785f`), with the same two lines. Before it nothing read `TRUSTED_PROXIES` | `x-forwarded-for`, `x-forwarded-proto`, `x-forwarded-port` |
| 5 | `config/packages/trusted_proxies.yaml` of the branch and of `v5.0.3.1` (commit `78e2848`). Before it Symfony 7's default applied, which reads `SYMFONY_TRUSTED_PROXIES`, a variable the project does not set | `x-forwarded-for`, `x-forwarded-proto`, `x-forwarded-port` |

A 4.6 or 5 project created before these commits does not have the file; create it with the content of the commit:

```yaml
# config/packages/trusted_proxies.yaml
framework:
    trusted_proxies: '%env(default::TRUSTED_PROXIES)%'
    trusted_headers: ['x-forwarded-for', 'x-forwarded-proto', 'x-forwarded-port']
```

The value is a comma-separated list of addresses or ranges (`10.0.0.0/16,192.0.2.10`); `REMOTE_ADDR` stands for
whatever address the request comes from, which is how a proxy whose address changes (Varnish on Platform.sh) is
trusted. Set it in `.env.local` or the server environment, then clear the cache. Check what is in effect:

```bash
php bin/console --env=prod debug:container --env-var=TRUSTED_PROXIES     # 3.x and later: the value Symfony sees
php bin/console --env=prod debug:config framework trusted_proxies
```

`TRUST_REMOTE` on 2.5, `REMOTE_ADDR` and a `0.0.0.0/0` range anywhere trust every visitor; use them only when the
application is reachable exclusively through the proxy (firewall). `X-Forwarded-Host` is not trusted on 3.x and
later; a proxy that changes the host name must pass the original `Host` header instead.

**Legacy kernel: `[HTTPHeaderSettings] TrustedProxies[]` (Exponential 6.0.15).** From 6.0.15 the legacy kernel
believes `X-Forwarded-Proto`, `-Port`, `-Server`, `-Host` and `-For` only when `REMOTE_ADDR` is a listed proxy; the
default list is `127.0.0.1` and `::1`, and `ClientIpByCustomHTTPHeader` takes effect only for trusted proxies. The
full description, with examples for Apache, nginx, Velocity and cloud load balancers, is the bc note
[Forwarded headers are trusted only from configured proxies](https://github.com/se7enxweb/exponential/blob/main/doc/bc/6.0/trusted-proxies.md).
For this distribution:

- **Which installs have it**: lines 4.6 and 5 install `se7enxweb/exponential` from `dev-main` and get it with their
  next update; lines 2.5 and 3.3 require `^6.0.12` and get it when 6.0.15 is tagged (the newest tag at the time of
  writing is 6.0.14, which trusts the headers from anyone).
- **Set the same list on both sides.** A proxy trusted by Symfony but not by the legacy kernel gives pages where the
  Symfony parts use `https://` and the legacy parts `http://`.
- **Where to set it**: in the legacy global override (`ezpublish_legacy/settings/override/site.ini.append.php`, on
  4.6 and 5 `src/LegacySettings/override/site.ini.append.php`):

  ```ini
  [HTTPHeaderSettings]
  TrustedProxies[]
  TrustedProxies[]=127.0.0.1
  TrustedProxies[]=::1
  TrustedProxies[]=10.0.0.0/16
  ClientIpByCustomHTTPHeader=X-Forwarded-For
  ```

  The empty `TrustedProxies[]` line first empties the inherited list, so the example lists loopback again; without
  the empty line the entries are added to the default `127.0.0.1` and `::1`. On 3.x and later the list can also be an
  injected merge setting (`'site.ini/HTTPHeaderSettings/TrustedProxies': ['10.0.0.0/16']`,
  [8.4](08-configuration.md#84-injecting-your-own-legacy-settings)); a merge setting is always appended to the INI
  list, it cannot replace it. Entries are addresses or ranges only; a host name is ignored.
- **Velocity** in front works out the visitor's address itself from its own trusted list and passes it as
  `REMOTE_ADDR`; configure proxies in front of Velocity there (the bc note's Velocity section).

Test both sides from outside, without a proxy: a forged header must change nothing.

```bash
curl -s -o /dev/null -w '%{redirect_url}\n' -H 'X-Forwarded-Proto: https' http://example.com/legacy_admin/user/logout
# expected: an http:// URL. An https:// URL means the legacy kernel trusted a header from you.
```

## 13.10 File permissions

| Writable by the web server | Why |
|---|---|
| `var/` (Symfony cache, logs, sessions; SQLite file and its directory) | runtime |
| `ezpublish_legacy/var/` (on 4.6 and 5 also `src/LegacyRoot/var/site/storage/`, which `var/site/storage` links to) | legacy cache, logs, uploaded files |
| `web/var` / `public/var` | a link to `ezpublish_legacy/var/`; nothing to set on the link itself |

Everything else, including `ezpublish_legacy/settings/`, `src/`, `config/` and `vendor/`, should be readable but not
writable by the web server. Run console commands and cron as the same user as PHP-FPM (or give both write access with
ACLs, as the README's `setfacl` lines do), never as root: root-owned cache files break the next request. Do not use
`chmod -R 777`, which older guides offer as a fallback; it lets every local user change the code the site runs.

## 13.11 Keeping up to date

- Security reports go by e-mail to `security@se7enx.com`, never to the public issue tracker ([`SECURITY.md`](../../SECURITY.md), which also lists the supported release lines).
- Watch the releases of this repository, of [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`) and
  of [se7enxweb/exponential](https://github.com/se7enxweb/exponential) (legacy kernel security fixes, such as the
  6.0.15 trusted proxies change).
- `composer audit` lists known advisories for the installed packages; the 2.5 line also runs the SensioLabs security
  checker in its Composer scripts (`bin/security-checker security:check`).
- Read the legacy kernel's own hardening chapter for what is inside it: passwords and sign-in lockout, the audit log,
  mail consent (Exponential 6 book, chapter 13).

## 13.12 Go-live checklist

- [ ] Web server routes to `app.php` / `index.php`, never `app_dev.php`; `app_dev.php` removed or IP-restricted
- [ ] `display_errors` off (also in 2.5's `web/app.php`); `prod` environment, not forced to `dev` by `.htaccess` (13.4); legacy `DebugOutput` disabled (also in the 4.6 and 5 recipe override)
- [ ] Only legacy asset paths served directly; no PHP executable under `var/` (vhost rule written `^/var/`, tested)
- [ ] Framework secret, database password, JWT passphrase replaced; none in committed files
- [ ] Seed administrator password changed; admin siteaccesses on their own host, restricted at the web server
- [ ] Session cookie secure and HttpOnly; CSRF protection and `ezformtoken` enabled
- [ ] HTTPS with HSTS; security headers sent by the web server
- [ ] Trusted proxies configured on the Symfony side (`TRUSTED_PROXIES` read by the configuration of 13.9, or `SYMFONY_TRUSTED_PROXIES` on 2.5) **and** in the legacy kernel's `TrustedProxies[]`; forged-header test passed
- [ ] File permissions as in 13.10; cron and console as the site user
- [ ] Backups and a tested restore ([9.7](09-operations.md#97-backups-and-restore))

## References

In this repository: [`web/.htaccess`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/web/.htaccess), [`web/app.php`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/web/app.php),
[`web/app_dev.php`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/web/app_dev.php), [`app/config/security.yml`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/app/config/security.yml),
[`app/config/config.yml`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/app/config/config.yml), [`app/config/parameters.yml.dist`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/app/config/parameters.yml.dist),
[`doc/apache2/vhost.template`](https://github.com/se7enxweb/exponential-platform-legacy/blob/master/doc/apache2/vhost.template), [`SECURITY.md`](../../SECURITY.md); the corrections
[`fa091cd`](https://github.com/se7enxweb/exponential-platform-legacy/commit/fa091cd),
[`d924ceb`](https://github.com/se7enxweb/exponential-platform-legacy/commit/d924ceb),
[`7605f57`](https://github.com/se7enxweb/exponential-platform-legacy/commit/7605f57) and
[`01e4d59`](https://github.com/se7enxweb/exponential-platform-legacy/commit/01e4d59) on `master`;
on the other branches [`66f13e1`](https://github.com/se7enxweb/exponential-platform-legacy/commit/66f13e1) and
[`d820756`](https://github.com/se7enxweb/exponential-platform-legacy/commit/d820756) (3.x),
[`309785f`](https://github.com/se7enxweb/exponential-platform-legacy/commit/309785f) (4.6.x),
[`78e2848`](https://github.com/se7enxweb/exponential-platform-legacy/commit/78e2848) (5.x). The 4.6 and 5 project
files: [se7enxweb/sevenx-recipes](https://github.com/se7enxweb/sevenx-recipes), folders `1.2` and `1.4` of
`se7enxweb/exponential-platform-dxp` (`public/.htaccess`, `src/LegacySettings/override/site.ini.append.php`).

The bridge: [se7enxweb/LegacyBridge](https://github.com/se7enxweb/LegacyBridge) (Composer package `se7enxweb/legacy-bridge`) (`bundle/LegacyMapper/Session.php`,
`Security.php`, `Configuration.php`).

The Exponential 6 book and notes:
[chapter 13, security hardening](https://github.com/se7enxweb/exponential/blob/main/doc/install/13-security-hardening.md),
[trusted proxies (6.0.15)](https://github.com/se7enxweb/exponential/blob/main/doc/bc/6.0/trusted-proxies.md).

External: Symfony [How to configure Symfony to work behind a load balancer or a reverse proxy](https://symfony.com/doc/current/deployment/proxies.html)
(and the [3.x version](https://symfony.com/doc/3.x/deployment/proxies.html) for the 2.5 line),
[secrets management](https://symfony.com/doc/current/configuration/secrets.html),
[security](https://symfony.com/doc/current/security.html),
[CSRF protection](https://symfony.com/doc/current/security/csrf.html);
PHP [session security](https://www.php.net/manual/en/session.security.php);
upstream concepts [security checklist](https://doc.ibexa.co/en/latest/infrastructure_and_maintenance/security/security_checklist/);
[OWASP Secure Headers Project](https://owasp.org/projects/secure-headers-project).

[Previous: 12. Troubleshooting](12-troubleshooting.md) · [Contents](README.md)
