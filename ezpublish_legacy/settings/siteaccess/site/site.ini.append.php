<?php /* #?ini charset="utf-8"?

# Legacy settings of the public siteaccess "site" (Symfony matches it, URIElement: 1). Symfony renders
# its pages; the legacy kernel only answers what Symfony has no route for (legacy modules such as
# user/register or content/search, and unknown addresses, which get the legacy 404 page). The
# kernel's own default asks every visitor to log in first, which turned each of those into the
# login form with status 200.
[SiteAccessSettings]
RequireUserLogin=false
RelatedSiteAccessList[]
RelatedSiteAccessList[]=site
RelatedSiteAccessList[]=admin
RelatedSiteAccessList[]=legacy_admin
*/ ?>
