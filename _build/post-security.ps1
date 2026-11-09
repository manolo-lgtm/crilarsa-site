# Último paso de compilación: política de seguridad de contenido y de referencia en todas las páginas publicadas.
# GitHub Pages no permite cabeceras HTTP propias, así que se usa <meta http-equiv>. El sitio no carga scripts, estilos ni imágenes externas.
$s = Split-Path -Parent $MyInvocation.MyCommand.Path
$csp = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; media-src 'self'; connect-src 'self'; font-src 'self' data:; object-src 'none'; base-uri 'self'; form-action 'self' https://wa.me mailto:; upgrade-insecure-requests"
$add = "<meta http-equiv=`"Content-Security-Policy`" content=`"$csp`">`n<meta name=`"referrer`" content=`"strict-origin-when-cross-origin`">"
$n=0
foreach($p in Get-ChildItem "$s\deploy\*.html" | ? { $_.Name -notmatch '^index\.v' }){
  $t=[IO.File]::ReadAllText($p.FullName)
  if(-not $t.Contains('Content-Security-Policy')){
    $i=$t.IndexOf('<meta charset="utf-8">'); if($i -lt 0){ throw "sin charset: $($p.Name)" }
    $t=$t.Insert($i+'<meta charset="utf-8">'.Length, "`n"+$add); [IO.File]::WriteAllText($p.FullName,$t,(New-Object Text.UTF8Encoding $false)); $n++ }
}
"csp en $n páginas"
