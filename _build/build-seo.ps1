# Después de build-site.ps1 -Mode deploy y build-i18n.ps1 -Out deploy:
# genera páginas estáticas por idioma (en.html, en-productos.html, …), etiquetas SEO (canonical, hreflang, Open Graph, JSON-LD), sitemap.xml y robots.txt
$s = Split-Path -Parent $MyInvocation.MyCommand.Path
$d = "$s\deploy"; $site = 'https://crilarsa.com/'
$langs = 'es','en','pt','fr','ru','uk','zh'
$code = @{es='es';en='en';pt='pt';fr='fr';ru='ru';uk='uk';zh='zh-Hans'}
$locale = @{es='es_EC';en='en_US';pt='pt_BR';fr='fr_FR';ru='ru_RU';uk='uk_UA';zh='zh_CN'}
$pages = 'index','productos','planta','nosotros','carbonato-de-calcio','hidroxido-de-calcio','zeolita','yeso-agricola','mezcla-3-1'
function FileFor($l,$p){ if($l -eq 'es'){ "$p.html" } elseif($p -eq 'index'){ "$l.html" } else { "$l-$p.html" } }
function UrlFor($l,$p){ if($l -eq 'es' -and $p -eq 'index'){ $site } else { $site + (FileFor $l $p) } }
function Enc($t){ $t.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;') }
function EncA($t){ (Enc $t).Replace('"','&quot;') }

$dicts = @{}
foreach($l in $langs){ if($l -eq 'es'){ continue }
  $keys = Get-Content "$s\i18n\es-keys.json" -Raw -Encoding UTF8 | ConvertFrom-Json; $lines = [IO.File]::ReadAllLines("$s\i18n\$l.txt",[Text.Encoding]::UTF8)
  $hT = New-Object System.Collections.Hashtable ([StringComparer]::Ordinal)
  for($i=0;$i -lt $keys.Count;$i++){ $hT[[string]$keys[$i]] = $lines[$i].Trim() }; $dicts[$l] = $hT }

function Tr($dict,[string]$t){
  $k = ([System.Net.WebUtility]::HtmlDecode($t) -replace '\s+',' ').Trim(); if(-not $k){ return $null }
  if($dict.ContainsKey($k)){ return $dict[$k] }
  if($k.Contains(' · ')){ $p = $k -split ' · '; $o=@(); $ok=$false; $i=0
    while($i -lt $p.Count){ $found=$false; for($j=$p.Count;$j -gt $i;$j--){ $c = ($p[$i..($j-1)] -join ' · '); if($dict.ContainsKey($c)){ $o+=$dict[$c]; $ok=$true; $i=$j; $found=$true; break } }; if(-not $found){ $o+=$p[$i]; $i++ } }
    if($ok){ return ($o -join ' · ') } }
  return $null
}

function Translate([string]$html,$l){
  $dict = $dicts[$l]
  $parts = [regex]::Split($html,'(<script\b.*?</script>|<style\b.*?</style>|<svg\b.*?</svg>|<!--.*?-->|<[^>]+>)','Singleline')
  $sb = New-Object Text.StringBuilder
  foreach($x in $parts){
    if($x.StartsWith('<')){
      if($x -match '^<(script|style|svg|!--)'){ [void]$sb.Append($x); continue }
      $y = [regex]::Replace($x,'(\s(?:alt|title|placeholder|aria-label)=")([^"]*)(")',{ param($m) $v = Tr $dict $m.Groups[2].Value; if($v -ne $null){ $m.Groups[1].Value + (EncA $v) + $m.Groups[3].Value } else { $m.Value } })
      if($y -match '^<meta name="description"'){ $y = [regex]::Replace($y,'(content=")([^"]*)(")',{ param($m) $v = Tr $dict $m.Groups[2].Value; if($v -ne $null){ $m.Groups[1].Value + (EncA $v) + $m.Groups[3].Value } else { $m.Value } }) }
      $y = [regex]::Replace($y,'href="(index|productos|planta|nosotros|carbonato-de-calcio|hidroxido-de-calcio|zeolita|yeso-agricola|mezcla-3-1)\.html',{ param($m) 'href="' + ((FileFor $l $m.Groups[1].Value)) })
      [void]$sb.Append($y)
    } else {
      if($x.Trim().Length -eq 0){ [void]$sb.Append($x); continue }
      $v = Tr $dict $x
      if($v -ne $null){ $lead = [regex]::Match($x,'^\s*').Value; $trail = [regex]::Match($x,'\s*$').Value; [void]$sb.Append($lead + (Enc $v) + $trail) } else { [void]$sb.Append($x) }
    }
  }
  $sb.ToString().Replace('<html lang="es">',"<html lang=`"$($code[$l])`">")
}

function HeadExtra($l,$p,$html){
  $title = [System.Net.WebUtility]::HtmlDecode([regex]::Match($html,'<title>([^<]*)</title>').Groups[1].Value)
  $desc = [System.Net.WebUtility]::HtmlDecode([regex]::Match($html,'<meta name="description" content="([^"]*)"').Groups[1].Value)
  $x = New-Object Text.StringBuilder
  [void]$x.Append("<link rel=`"canonical`" href=`"$(UrlFor $l $p)`">`n")
  foreach($a in $langs){ [void]$x.Append("<link rel=`"alternate`" hreflang=`"$($code[$a])`" href=`"$(UrlFor $a $p)`">`n") }
  [void]$x.Append("<link rel=`"alternate`" hreflang=`"x-default`" href=`"$(UrlFor 'es' $p)`">`n")
  [void]$x.Append("<meta property=`"og:type`" content=`"website`">`n<meta property=`"og:site_name`" content=`"Crilarsa C.A.`">`n")
  [void]$x.Append("<meta property=`"og:title`" content=`"$(EncA $title)`">`n<meta property=`"og:description`" content=`"$(EncA $desc)`">`n")
  [void]$x.Append("<meta property=`"og:url`" content=`"$(UrlFor $l $p)`">`n<meta property=`"og:image`" content=`"${site}planta-bodega-general.jpg`">`n<meta property=`"og:locale`" content=`"$($locale[$l])`">`n")
  [void]$x.Append("<meta name=`"twitter:card`" content=`"summary_large_image`">`n")
  if($p -ne 'index'){ $bt=[System.Net.WebUtility]::HtmlDecode(([regex]::Match($html,'<h1>(.*?)</h1>','Singleline').Groups[1].Value -replace '<[^>]+>','').Trim()); $bc=[ordered]@{'@context'='https://schema.org';'@type'='BreadcrumbList';itemListElement=@([ordered]@{'@type'='ListItem';position=1;name='Crilarsa';item=(UrlFor $l 'index')},[ordered]@{'@type'='ListItem';position=2;name=$bt;item=(UrlFor $l $p)})}; [void]$x.Append("<script type=`"application/ld+json`">$(($bc | ConvertTo-Json -Depth 5 -Compress).Replace('</','<\/'))</script>`n") }
  if($p -eq 'index'){
    $ld = [ordered]@{
      '@context'='https://schema.org'; '@type'=@('Organization','LocalBusiness'); '@id'="${site}#empresa"
      name='Crilarsa C.A.'; alternateName='Crilarsa'; url=$site; logo="${site}logo-crilarsa-blanco.png"; image="${site}planta-bodega-general.jpg"
      description=$desc; telephone='+593985211202'; email='finanzas@crilarsa.com'; taxID='0992110945001'
      address=[ordered]@{ '@type'='PostalAddress'; streetAddress='Vía a la Costa, km 22'; addressLocality='Guayaquil'; addressRegion='Guayas'; addressCountry='EC' }
      areaServed=@('Ecuador','South America'); inLanguage=$code[$l]
      sameAs=@('https://wa.me/593985211202')
      knowsAbout=@('calcium carbonate','agricultural lime','hydrated lime','calcium hydroxide','zeolite','clinoptilolite','agricultural gypsum','calcium sulfate','limestone','aquaculture','banana farming')
      makesOffer=@(
        [ordered]@{'@type'='Offer'; itemOffered=[ordered]@{'@type'='Product'; name='Neutrocal — carbonato de calcio malla 200 (CaCO3)'; brand='Crilarsa'; image="${site}saco-neutrocal.png"}},
        [ordered]@{'@type'='Offer'; itemOffered=[ordered]@{'@type'='Product'; name='Cal Forte — hidróxido de calcio (Ca(OH)2)'; brand='Crilarsa'; image="${site}saco-calforte.png"}},
        [ordered]@{'@type'='Offer'; itemOffered=[ordered]@{'@type'='Product'; name='Zeolita clinoptilolita malla 200'; brand='Crilarsa'; image="${site}saco-zeolita.png"}},
        [ordered]@{'@type'='Offer'; itemOffered=[ordered]@{'@type'='Product'; name='Sulfato de calcio — yeso agrícola (CaSO4)'; brand='Crilarsa'; image="${site}saco-sulfato.png"}},
        [ordered]@{'@type'='Offer'; itemOffered=[ordered]@{'@type'='Product'; name='Mezcla mineral 3:1 — carbonato + sulfato de calcio'; image="${site}saco-mezcla.png"}}
      )
    }
    $json = ($ld | ConvertTo-Json -Depth 6 -Compress).Replace('</','<\/')
    [void]$x.Append("<script type=`"application/ld+json`">$json</script>`n")
  }
  $prodImg=@{'carbonato-de-calcio'='saco-neutrocal.png';'hidroxido-de-calcio'='saco-calforte.png';'zeolita'='saco-zeolita.png';'yeso-agricola'='saco-sulfato.png';'mezcla-3-1'='saco-mezcla.png'}
  if($prodImg.ContainsKey($p)){
    $h1 = [System.Net.WebUtility]::HtmlDecode(([regex]::Match($html,'<h1>(.*?)</h1>','Singleline').Groups[1].Value -replace '<[^>]+>','').Trim())
    $pl = [ordered]@{ '@context'='https://schema.org'; '@type'='Product'; name=$h1; description=$desc; image="${site}$($prodImg[$p])"; url=(UrlFor $l $p); category='Industrial minerals'; inLanguage=$code[$l]; manufacturer=[ordered]@{'@type'='Organization'; '@id'="${site}#empresa"; name='Crilarsa C.A.'; url=$site} }
    if($p -ne 'mezcla-3-1'){ $pl.brand=[ordered]@{'@type'='Brand'; name='Crilarsa'} }
    $json2 = ($pl | ConvertTo-Json -Depth 5 -Compress).Replace('</','<\/')
    [void]$x.Append("<script type=`"application/ld+json`">$json2</script>`n")
    $qa=[regex]::Matches($html,'<details><summary>(.*?)</summary><p>(.*?)</p></details>'); if($qa.Count){ $fq=[ordered]@{'@context'='https://schema.org';'@type'='FAQPage';mainEntity=@($qa | % { [ordered]@{'@type'='Question';name=[System.Net.WebUtility]::HtmlDecode($_.Groups[1].Value);acceptedAnswer=[ordered]@{'@type'='Answer';text=[System.Net.WebUtility]::HtmlDecode($_.Groups[2].Value)}} })}; [void]$x.Append("<script type=`"application/ld+json`">$(($fq | ConvertTo-Json -Depth 6 -Compress).Replace('</','<\/'))</script>`n") }
  }
  $x.ToString()
}

$urls = @()
foreach($p in $pages){
  $es = [IO.File]::ReadAllText("$d\$p.html",[Text.Encoding]::UTF8)
  $es = [regex]::Replace($es,'(?s)<link rel="canonical".*?(?=<link rel="icon")','')  # por si se vuelve a ejecutar
  foreach($l in $langs){
    $h = if($l -eq 'es'){ $es } else { Translate $es $l }
    $extra = HeadExtra $l $p $h
    $h = $h.Replace('<link rel="icon"', $extra + '<link rel="icon"')
    [IO.File]::WriteAllText("$d\$(FileFor $l $p)",$h,(New-Object Text.UTF8Encoding $false))
    $urls += ,@($l,$p)
  }
}
# sitemap con alternativas por idioma
$sm = New-Object Text.StringBuilder
[void]$sm.Append("<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`" xmlns:xhtml=`"http://www.w3.org/1999/xhtml`">`n")
$today = (Get-Date).ToString('yyyy-MM-dd')
foreach($u in $urls){ $l=$u[0]; $p=$u[1]
  [void]$sm.Append("  <url>`n    <loc>$(UrlFor $l $p)</loc>`n    <lastmod>$today</lastmod>`n    <priority>$(if($p -eq 'index'){'1.0'}else{'0.8'})</priority>`n")
  foreach($a in $langs){ [void]$sm.Append("    <xhtml:link rel=`"alternate`" hreflang=`"$($code[$a])`" href=`"$(UrlFor $a $p)`"/>`n") }
  [void]$sm.Append("    <xhtml:link rel=`"alternate`" hreflang=`"x-default`" href=`"$(UrlFor 'es' $p)`"/>`n  </url>`n") }
[void]$sm.Append("</urlset>`n")
[IO.File]::WriteAllText("$d\sitemap.xml",$sm.ToString(),(New-Object Text.UTF8Encoding $false))
[IO.File]::WriteAllText("$d\robots.txt","User-agent: *`nAllow: /`n`nSitemap: ${site}sitemap.xml`n",(New-Object Text.UTF8Encoding $false))
"pages: $($urls.Count)"
