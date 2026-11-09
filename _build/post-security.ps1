# Último paso de compilación: política de seguridad de contenido y de referencia en todas las páginas publicadas.
# GitHub Pages no permite cabeceras HTTP propias, así que se usa <meta http-equiv>. El sitio no carga scripts, estilos ni imágenes externas.
$s = Split-Path -Parent $MyInvocation.MyCommand.Path
$csp = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; media-src 'self'; connect-src 'self'; font-src 'self' data:; object-src 'none'; base-uri 'self'; form-action 'self' https://wa.me mailto:; upgrade-insecure-requests"
$add = "<meta http-equiv=`"Content-Security-Policy`" content=`"$csp`">`n<meta name=`"referrer`" content=`"strict-origin-when-cross-origin`">"
$SK=@{es="Saltar al contenido";en="Skip to content";pt="Pular para o conteúdo";fr="Aller au contenu";ru="Перейти к содержимому";uk="Перейти до вмісту";zh="跳到主要内容"}
$n=0
foreach($p in Get-ChildItem "$s\deploy\*.html" | ? { $_.Name -notmatch '^index\.v' }){
  $t=[IO.File]::ReadAllText($p.FullName)
  if($t.Contains('id="contenido"') -and -not $t.Contains('class="skip"')){ $lg=([regex]::Match($t,'<html lang="([a-z]{2})').Groups[1].Value); if(-not $SK.ContainsKey($lg)){ $lg='es' }; $t=[regex]::Replace($t,'(<body[^>]*>)',('$1'+"`n"+'<a class="skip" href="#contenido">'+$SK[$lg]+'</a>'),1); [IO.File]::WriteAllText($p.FullName,$t,(New-Object Text.UTF8Encoding $false)) }
  $t2=[regex]::Replace($t,'<img (?![^>]*srcset)([^>]*?)src="([A-Za-z0-9._-]+)\.(jpe?g)"',{ param($m) $b=$m.Groups[2].Value; if(Test-Path "$s\deploy\$b-m.jpg"){ "<img $($m.Groups[1].Value)src=`"$b.$($m.Groups[3].Value)`" srcset=`"$b-m.jpg 800w, $b.$($m.Groups[3].Value) 1600w`" sizes=`"(max-width: 860px) 100vw, 50vw`"" } else { $m.Value } }); if($t2 -ne $t){ $t=$t2; [IO.File]::WriteAllText($p.FullName,$t,(New-Object Text.UTF8Encoding $false)) }
  if(-not $t.Contains('Content-Security-Policy')){
    $i=$t.IndexOf('<meta charset="utf-8">'); if($i -lt 0){ throw "sin charset: $($p.Name)" }
    $t=$t.Insert($i+'<meta charset="utf-8">'.Length, "`n"+$add); [IO.File]::WriteAllText($p.FullName,$t,(New-Object Text.UTF8Encoding $false)); $n++ }
}
"csp en $n páginas"
