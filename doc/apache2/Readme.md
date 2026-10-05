Apache 2.4 configuration (3.x line)
===================================

On the 3.x line the web root is `public/` and the front controller is `public/index.php`. (The 2.5 line, on
`master`, uses `web/` and `app.php`; its files do not fit this line.) The book's chapter 6, "Serving the site",
explains every option in detail: [doc/book/06-serving-the-site.md](../book/06-serving-the-site.md).


Prerequisites
-------------
- Some general knowledge of how to install and configure Apache
- Apache 2.4 with the [Event](https://httpd.apache.org/docs/2.4/mod/event.html) MPM (or
  [Worker](https://httpd.apache.org/docs/2.4/mod/worker.html)) and PHP-FPM over FastCGI (`mod_proxy_fcgi`).
- Apache modules installed and enabled:
 - required: `mod_rewrite`, `mod_env`, `mod_setenvif`, `mod_proxy`, `mod_proxy_fcgi`
 - recommended: `mod_expires`, `mod_deflate`


Files in this folder
--------------------

| File | Use |
|---|---|
| `vhost.template` | the full virtual host with the rewrite rules inside (`AllowOverride None`); fill it in by hand or with `bin/vhost.sh` |
| `media-site-vhost.conf` | a shorter virtual host with the rules inside; it lacks the legacy asset rules (`design/`, `extension/`, `share/icons/`, `var/.../cache/`), so add them from `vhost.template` if you use the legacy admin |
| `media-site.conf` | a virtual host with `AllowOverride All`, which relies on `public/.htaccess` |
| `.htaccess` | the same rules as `public/.htaccess`, for reference |


Configure
---------

1. Place the virtual host in a suitable Apache config folder, typically:
   - Debian/Ubuntu: `/etc/apache2/sites-available/<yoursite>.conf`, then `a2ensite <yoursite>`
   - RHEL/CentOS/Amazon-Linux: `/etc/httpd/conf.d/<yoursite>.conf`
2. Adjust the basics to your setup:
   - [VirtualHost](https://httpd.apache.org/docs/2.4/en/mod/core.html#virtualhost): IP and port number to listen to.
   - [ServerName](https://httpd.apache.org/docs/2.4/en/mod/core.html#servername) and
     [ServerAlias](https://httpd.apache.org/docs/2.4/en/mod/core.html#serveralias): your host names.
   - [DocumentRoot](https://httpd.apache.org/docs/2.4/en/mod/core.html#documentroot) and `<Directory>`: the `public`
     directory of the installation.
   - `SetHandler "proxy:unix:<socket>|fcgi://localhost/"`: the socket of your PHP-FPM pool.
3. Set `APP_ENV=prod` (in `.env.local`, or with the `SetEnvIf` line of the template) on production.
4. Check and reload Apache:
   - `apachectl configtest`
   - Debian/Ubuntu: `sudo systemctl reload apache2`; RHEL/CentOS/Amazon-Linux: `sudo systemctl reload httpd`


Virtual host template
---------------------

`vhost.template` contains placeholders such as `%BASEDIR%`, `%HOST_NAME%` and `%FASTCGI_PASS%`. The script
`bin/vhost.sh` fills them in; run it from the installation root (`./bin/vhost.sh -h` shows the options). The PHP-FPM
socket has no option of its own; give it in the environment variable `FASTCGI_PASS`:

```bash
FASTCGI_PASS=unix:/run/php/php8.3-fpm.sock ./bin/vhost.sh --basedir=/var/www/exponential_website \
  --template-file=doc/apache2/vhost.template \
  --host-name=example.com \
  --sf-env=prod \
  | sudo tee /etc/apache2/sites-available/exponential.conf > /dev/null
```

The script keeps the option names of the 2.5 line (`--sf-env`, `--sf-debug`, `--sf-http-cache`,
`--sf-trusted-proxies`); in this template they set `APP_ENV`, `APP_DEBUG`, `APP_HTTP_CACHE` and `TRUSTED_PROXIES`.
Always pass `--basedir`: the script detects the installation root by itself only when a `web/` folder exists.

`TRUSTED_PROXIES` is read by `framework.trusted_proxies` in `config/packages/ezpublish.yaml`; set it (in
`.env.local` or the virtual host) to the addresses of Varnish, a load balancer or a TLS proxy in front of Apache.

#### Common issues

##### NameVirtualHost conflicts

The `NameVirtualHost` setting might already exist in the default configuration. Defining a new one will result in a
conflict. If Apache reports errors such as `NameVirtualHost [IP_ADDRESS] has no VirtualHosts` or `Mixing * ports and
non-* ports with a NameVirtualHost address is not supported`, try removing the `NameVirtualHost` line.
For more details, see [NameVirtualHost directive](http://httpd.apache.org/docs/2.4/mod/core.html#namevirtualhost) section in Apache documentation.
