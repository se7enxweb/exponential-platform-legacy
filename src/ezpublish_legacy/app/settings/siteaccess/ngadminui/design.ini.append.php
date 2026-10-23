<?php /* #?ini charset="utf-8"?

[StylesheetSettings]
# Reset the global CSSFileList to exclude sevenx_themes_simple CSS (it bleeds in
# because sevenx_themes_simple is a globally active extension). Admin3 loads its
# own CSS via its pagelayout template directly; only the websitetoolbar and ezflow
# entries are needed here.
CSSFileList[]
CSSFileList[]=websitetoolbar.css
EditorCSSFileList[]=ngsite_ezoe.css

BackendJavaScriptList[]=ezjsc::jquery
BackendJavaScriptList[]=ezjsc::jqueryio
BackendJavaScriptList[]=ezjsc::jqueryUI
BackendJavaScriptList[]=ezjsc::yui2

*/ ?>
