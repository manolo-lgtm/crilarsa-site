$s = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$s\fichas-data.ps1"
foreach($fi in $fichas){
  $trs = ($fi.rows | % { "<tr><th>$($_[0])</th><td>$($_[1])</td></tr>" }) -join "`n"
  $html = @"
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ficha técnica · $($fi.name) · Crilarsa</title>
<meta name="robots" content="noindex">
<meta name="description" content="Ficha técnica de $($fi.name) (Crilarsa, Guayaquil): composición, granulometría, presentación, usos, limitaciones y manejo. Versión imprimible y PDF.">
<link rel="canonical" href="https://crilarsa.com/$($fi.page)">
<style>
body{font-family:Arial,Helvetica,sans-serif;color:#1e2833;margin:0;background:#eef0f2}
.sheet{max-width:780px;margin:24px auto;background:#fff;padding:36px 40px;box-shadow:0 4px 18px rgba(0,0,0,.08)}
header{display:flex;justify-content:space-between;align-items:center;background:#1e2833;margin:-36px -40px 24px;padding:18px 40px;color:#fff}
header img{height:44px}header span{font-size:12px;letter-spacing:.08em;text-transform:uppercase}
h1{font-size:26px;margin:0 0 4px}.sub{color:#5a6673;margin:0 0 20px}
.grid{display:grid;grid-template-columns:1fr 180px;gap:24px;align-items:start}
.grid img{width:100%}
table{width:100%;border-collapse:collapse;font-size:14px}th,td{text-align:left;padding:9px 10px;border-bottom:1px solid #dde2e7;vertical-align:top}th{width:38%;color:#3d5a78}
h2{font-size:15px;text-transform:uppercase;letter-spacing:.06em;color:#3d5a78;margin:22px 0 6px}
p{font-size:14px;line-height:1.55;margin:0}
footer{margin-top:28px;padding-top:14px;border-top:2px solid #1e2833;font-size:12px;color:#5a6673;line-height:1.6}
.print{display:inline-block;margin:0 auto 24px;padding:10px 18px;background:#3d5a78;color:#fff;border-radius:6px;text-decoration:none;font-size:14px;border:0;cursor:pointer}
.bar{text-align:center}
@media (max-width:640px){.sheet{padding:24px 18px;margin:0}header{margin:-24px -18px 20px;padding:14px 18px}.grid{grid-template-columns:1fr}.grid img{max-width:180px}}
@media print{body{background:#fff}.sheet{box-shadow:none;margin:0;max-width:none}.bar{display:none}header{-webkit-print-color-adjust:exact;print-color-adjust:exact}}
</style></head><body>
<main class="sheet">
<header><img src="logo-crilarsa-blanco.png" alt="Crilarsa C.A."><span>Ficha técnica</span></header>
<h1>$($fi.name)</h1><p class="sub">$(if($fi.src){$fi.src}else{'Datos según la etiqueta del producto'}) · Revisión 1 · Noviembre 2026 · No son resultados de laboratorio certificados</p>
<div class="grid"><div><table>$trs</table></div><img src="$($fi.img)" alt="Saco de $($fi.name)"></div>
<h2>Usos indicados</h2><p>$($fi.uses)</p>
<h2>Limitaciones técnicas</h2><p>$($fi.lim)</p>
$(if($fi.pend){"<h2>Datos en confirmación</h2><p>$($fi.pend)</p>"})
<h2>Almacenamiento y manejo</h2><p>$($fi.care)</p>
<h2>Dosis</h2><p>Depende del suelo, el agua o el proceso de cada cliente. Nuestro equipo técnico le orienta antes de la compra. Para otros parámetros técnicos, consúltenos.</p>
<footer>Crilarsa C.A. · RUC 0992110945001 · Vía a la Costa, km 22, Guayaquil, Ecuador · WhatsApp +593 98 521 1202 · finanzas@crilarsa.com · crilarsa.com<br>Información referencial basada en la etiqueta del producto y en datos publicados por Crilarsa. No constituye una garantía de resultados.</footer>
</main>
<div class="bar"><a class="print" href="$($fi.file -replace '\.html$','.pdf')" download>Descargar PDF</a> &nbsp; <button class="print" onclick="window.print()">Imprimir</button> &nbsp; <a class="print" href="$($fi.page)">Volver al producto</a></div>
</body></html>
"@
  [IO.File]::WriteAllText("$s\deploy\$($fi.file)",$html,(New-Object Text.UTF8Encoding $false))
}
# enlace en el catálogo (solo estos tres productos)
$f="$s\web\crilarsa-sitio.html"; $h=[IO.File]::ReadAllText($f)
$map=@{neutrocal='ficha-neutrocal.html';calforte='ficha-cal-forte.html';zeolita='ficha-zeolita.html';sulfato='ficha-yeso-agricola.html';mezcla='ficha-mezcla-3-1.html'}
foreach($k in $map.Keys){ $m=[regex]::Match($h,'<article class="prod" data-p="'+$k+'".*?</article>','Singleline'); if($m.Value -notmatch 'class="ficha"'){ $n=$m.Value.Replace('<div class="links">','<a class="ficha" href="'+$map[$k]+'" target="_blank" rel="noopener">Ficha técnica (imprimir o PDF) →</a>'+"`n          "+'<div class="links">'); $h=$h.Replace($m.Value,$n) } }
if(-not $h.Contains('.prod .ficha{')){ $h=$h.Replace('.prod .more{','.prod .ficha{display:inline-block;margin:0 0 14px 18px;font:600 15px var(--display);color:var(--green,#4a7a5e);text-decoration:none}.prod .ficha:hover{text-decoration:underline}'+"`n"+'.prod .more{') }
[IO.File]::WriteAllText($f,$h,(New-Object Text.UTF8Encoding $false))
# traducción del enlace
$es='Ficha técnica (imprimir o PDF) →'; $k=[System.Collections.ArrayList]@(); foreach($x in (Get-Content "$s\i18n\es-keys.json" -Raw -Encoding UTF8 | ConvertFrom-Json)){ [void]$k.Add([string]$x) }
if(-not $k.Contains($es)){ [void]$k.Add($es); ConvertTo-Json @($k) | Set-Content "$s\i18n\es-keys.json" -Encoding UTF8
 $t=@{en='Technical data sheet (print or PDF, Spanish) →';pt='Ficha técnica (imprimir ou PDF, em espanhol) →';fr='Fiche technique (imprimer ou PDF, en espagnol) →';ru='Техническая карта (печать или PDF, на испанском) →';uk='Технічна картка (друк або PDF, іспанською) →';zh='技术数据表（打印或 PDF，西班牙语）→'}
 foreach($l in $t.Keys){ $lines=[IO.File]::ReadAllLines("$s\i18n\$l.txt",[Text.Encoding]::UTF8); [IO.File]::WriteAllLines("$s\i18n\$l.txt",($lines+$t[$l]),(New-Object Text.UTF8Encoding $false)) } }
"ok"
