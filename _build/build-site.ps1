param([ValidateSet('preview','deploy')][string]$Mode='preview')
# Construye el sitio de varias páginas a partir de web\crilarsa-sitio.html (fuente única)
$s = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = [IO.File]::ReadAllText("$s\web\crilarsa-sitio.html").Replace("`r`n","`n")
$out = if ($Mode -eq 'deploy') { "$s\deploy" } else { "$s\preview" }
New-Item -ItemType Directory -Force $out | Out-Null

function Grab([string]$re) { $m = [regex]::Match($src, $re, 'Singleline'); if (-not $m.Success) { throw "No encontrado: $re" }; $m.Value }
$style   = Grab '<style>.*?</style>'
$nav     = Grab '<nav class="nav".*?</nav>'
$hero    = Grab '<header class="hero".*?</header>'
$footer  = Grab '<footer>.*?</footer>'
$mbar    = Grab '<div class="mbar".*?</div>'
$cartui  = Grab '<button class="cart-btn".*?</footer>\s*</div>\s*</div>'
$fab     = Grab '<aside class="fabwrap".*?</aside>'
$script  = Grab '<script>.*?</script>'
function Sec([string]$id) { Grab ('<section class="[^"]*" id="' + $id + '">.*?\n</section>') }
$sectores = Sec 'sectores'; $directo = Sec 'directo'; $integrado = Sec 'integrado'; $productos = Sec 'productos'; $guia = Sec 'guia'; $compras = Sec 'compras'
. "$PSScriptRoot\fichas-data.ps1"
$asesoria = Sec 'asesoria'; $planta = Sec 'planta'; $logistica = Sec 'logistica'; $mision = Sec 'mision'; $contacto = Sec 'contacto'


$explore = @'
<section class="explore" id="explorar">
  <div class="inner">
    <div class="head">
      <div class="eyebrow">Conozca Crilarsa</div>
      <h2>Más información, organizada por tema</h2>
    </div>
    <div class="cards">
      <a class="card" href="productos.html" style="background-image:url('estiba-pallets-montacargas.jpg')"><div><strong>Productos</strong><span>Catálogo completo, aplicaciones y presentaciones, con asesoría técnica.</span><em>Ver productos →</em></div></a>
      <a class="card" href="planta.html" style="background-image:url('molino-elevador.jpg')"><div><strong>Nuestra planta y logística</strong><span>Recorrido por la operación, video y capacidad de carga.</span><em>Ver la planta →</em></div></a>
      <a class="card" href="nosotros.html" style="background-image:url('materia-prima-caliza.jpg')"><div><strong>Nosotros</strong><span>Trayectoria desde 1989, misión, visión y valores.</span><em>Conocer más →</em></div></a>
    </div>
  </div>
</section>
'@

$story = @'
<section class="story" id="trayectoria">
  <div class="inner">
    <div class="text">
      <div class="eyebrow">Trayectoria</div>
      <h2>Más de 35 años en minerales calcáreos</h2>
      <p>Nuestra historia en la extracción y molienda de minerales calcáreos en Guayaquil comenzó en 1989. En el año 2000 se constituyó Crilarsa C.A., que hoy abastece a camaroneras, bananeras, productores agrícolas, industrias y distribuidores de todo el país.</p>
      <p>Operamos dos grandes naves industriales en la Vía a la Costa, km 22, con maquinaria pesada, muelles de carga y amplias áreas de materia prima, almacenamiento y expansión: una planta preparada para atender grandes volúmenes con eficiencia.</p>
    </div>
    <img src="planta-bodega-general.jpg" alt="Nave industrial de Crilarsa con sacos estibados" loading="lazy">
  </div>
</section>
'@

function PageHero($crumb, $title, $text, $img) {
@"
<header class="page-hero" style="background-image:url('$img')">
  <div class="inner">
    <div class="crumbs"><a href="index.html">Inicio</a> / $crumb</div>
    <h1>$title</h1>
    <p>$text</p>
  </div>
</header>
"@
}

# Página propia por producto: ficha del catálogo + usos por sector + cómo comprar
$tabsHtml = Grab '<div class="tabs" role="tablist".*?</div>'
function SectorName($id){ $m=[regex]::Match($tabsHtml,'aria-controls="'+$id+'"[^>]*>(?:<svg.*?</svg>)?\s*([^<]+)</button>','Singleline'); $m.Groups[1].Value.Trim() }
function Faq($pres,$q,$a){
  $items = @(@('¿En qué presentación se vende?',$pres),@($q,$a),
    @('¿Cómo solicito una cotización?','Elija la cantidad de sacos, agréguelos a su pedido y envíe la solicitud por WhatsApp o correo. Le confirmamos precio de fábrica, disponibilidad y fecha de carga.'),
    @('¿Puedo retirar en planta?','Sí. El retiro es en nuestra planta de la Vía a la Costa, km 22, Guayaquil, coordinando el día y la hora con su asesor.'),
    @('¿Qué dosis debo aplicar?','Depende de su suelo, su agua o su proceso. Recomendamos basarla en un análisis reciente; nuestro equipo le orienta antes de la compra.'))
  $d = ($items | % { "      <details><summary>$($_[0])</summary><p>$($_[1])</p></details>" }) -join "`n"
@"
<section class="asesoria" id="preguntas">
  <div class="inner">
    <div class="head"><div class="eyebrow">Preguntas frecuentes</div><h2>Preguntas frecuentes</h2></div>
    <div class="faq">
$d
    </div>
  </div>
</section>
"@
}function ProdPage($key,$crumb,$title,$text,$img,$faq){
  $art = [regex]::Match($productos,'<article class="prod" data-p="'+$key+'".*?</article>','Singleline').Value
  $art = [regex]::Replace($art,'\s*<a class="more" href="[^"]*">[^<]*</a>','')
  $cards = ''
  foreach($sid in 'banano','camaron','agricola','pecuario','azucar','agua','construccion'){
    $pm = [regex]::Match($sectores,'<div class="panel" role="tabpanel" id="'+$sid+'".*?(?=<div class="panel" role="tabpanel"|\n  </div>\n</section>)','Singleline').Value
    $li = [regex]::Match($pm,'<li data-p="'+$key+'"><strong>[^<]*</strong><span>(.*?)</span></li>','Singleline')
    if($li.Success){ $cards += "      <article><h3>$(SectorName $sid)</h3><p>$($li.Groups[1].Value)</p><a href=`"index.html#$sid`">Ver soluciones para el sector →</a></article>`n" }
  }
  $fd = $fichas | ? { $_.key -eq $key } | select -First 1
  $trs = ($fd.rows | % { "          <tr><th scope=`"row`">$($_[0])</th><td>$($_[1])</td></tr>" }) -join "`n"
  $pendH = if($fd.pend){ "      <div><h3>Datos en confirmación</h3><p>$($fd.pend)</p></div>`n" } else { '' }
  $specSec = @"
<section class="asesoria" id="especificaciones">
  <div class="inner">
    <div class="head"><div class="eyebrow">Datos técnicos</div><h2>Especificaciones técnicas</h2></div>
    <table class="spec">
      <caption>Datos de etiqueta o publicados por Crilarsa; no son resultados de laboratorio certificados.</caption>
      <thead><tr><th scope="col">Propiedad</th><th scope="col">Valor</th></tr></thead>
      <tbody>
$trs
      </tbody>
    </table>
    <div class="specnotes">
      <div><h3>Usos indicados</h3><p>$($fd.uses)</p></div>
      <div><h3>Limitaciones técnicas</h3><p>$($fd.lim)</p></div>
      <div><h3>Almacenamiento y manejo</h3><p>$($fd.care)</p></div>
$pendH    </div>
    <div class="speclinks"><a class="btn btn-ghost" href="$($fd.file)" target="_blank" rel="noopener">Ver ficha técnica</a><a class="btn btn-ghost" href="$($fd.file -replace '\.html$','.pdf')" download>Descargar PDF</a></div>
  </div>
</section>
"@
  $hero = PageHero $crumb $title $text $img
  $body = @"
<section class="catalog" id="producto">
  <div class="inner">
    <div class="cat">
      $art
    </div>
  </div>
</section>
$specSec
<section class="asesoria" id="usos">
  <div class="inner">
    <div class="head"><div class="eyebrow">Aplicaciones</div><h2>Usos por sector</h2></div>
    <div class="uses">
$cards    </div>
  </div>
</section>
<section class="asesoria" id="comprar">
  <div class="inner">
    <div class="head"><div class="eyebrow">Cotización</div><h2>Cómo comprar</h2></div>
    <div class="buy-steps">
      <div><strong>Elija la cantidad de sacos</strong><span>Agréguelos a su pedido desde esta página.</span></div>
      <div><strong>Envíe su solicitud</strong><span>Por WhatsApp o por correo, con su empresa y destino.</span></div>
      <div><strong>Reciba su cotización</strong><span>Le confirmamos precio de fábrica, disponibilidad y fecha de carga.</span></div>
    </div>
  </div>
</section>
"@
  @($hero,$body,$faq,$contacto)
}
$pages = [ordered]@{
  'index.html'     = @{ title='Crilarsa | Carbonato de calcio, cal y zeolita en Guayaquil, Ecuador'; desc='Fabricante en Guayaquil, Ecuador, de carbonato de calcio, cal hidratada (Cal Forte), zeolita, yeso agrícola y mezcla 3:1 para agricultura, acuicultura e industria. Venta directa de fábrica y pedidos por volumen. Desde 1989.'; pre='<link rel="preload" as="image" href="planta-bodega-general-m.jpg" media="(max-width: 860px)" fetchpriority="high"><link rel="preload" as="image" href="planta-bodega-general.jpg" media="(min-width: 861px)" fetchpriority="high">'; body=@($hero,$guia,$sectores,$directo,$integrado,$explore,$compras,$contacto) };
  'productos.html' = @{ title='Carbonato de calcio, cal hidratada, zeolita y yeso agrícola | Crilarsa'; desc='Catálogo de minerales de Crilarsa en Ecuador: carbonato de calcio Neutrocal malla 200, hidróxido de calcio Cal Forte, zeolita clinoptilolita, sulfato de calcio y mezcla 3:1. Precios de fábrica y despacho por volumen.'; body=@((PageHero 'Productos' 'Catálogo de minerales' 'Carbonato de calcio, sulfato de calcio, mezcla 3:1, zeolita y Cal Forte, elaborados en nuestra planta. Vea también <a href="index.html#sectores" style="color:#fff">qué productos usa cada sector</a>.' 'materia-prima-caliza.jpg'),$productos,$asesoria,$contacto) };
  'planta.html'    = @{ title='Planta de molienda de piedra caliza en Guayaquil | Crilarsa'; desc='Planta de Crilarsa en la Vía a la Costa, km 22, Guayaquil, Ecuador: extracción, molienda y ensacado de piedra caliza, con carga mecanizada de 1.000 sacos en unos 15 minutos.'; body=@((PageHero 'Nuestra planta' 'Nuestra planta en operación' 'Dos grandes naves industriales en la Vía a la Costa, km 22, con maquinaria pesada y muelles de carga, preparadas para atender grandes volúmenes.' 'linea-produccion.jpg'),$planta.Replace('<h2>Nuestra planta en operación</h2>','<h2>Recorrido por la operación</h2>'),$logistica,$contacto) };
  'carbonato-de-calcio.html' = @{ title='Carbonato de calcio en Ecuador — Neutrocal malla 200 | Crilarsa'; desc='Carbonato de calcio Neutrocal malla 200 en sacos de 45 kg, de nuestra planta en Guayaquil. Para bananeras, camaroneras, cultivos y construcción. Cotice por volumen.'; body=(ProdPage 'neutrocal' 'Carbonato de calcio' 'Carbonato de calcio — Neutrocal' 'Carbonato de calcio malla 200 de nuestra planta en Guayaquil, en sacos de 45 kg.' 'materia-prima-caliza.jpg' (Faq 'Saco de 45 kg, malla 200. Otras granulometrías bajo consulta.' '¿En qué se diferencia del Cal Forte?' 'El carbonato de calcio corrige la acidez de forma gradual; el hidróxido de calcio (Cal Forte) actúa más rápido y eleva más el pH. Le orientamos según su caso.')) };
  'hidroxido-de-calcio.html' = @{ title='Cal hidratada e hidróxido de calcio en Guayaquil — Cal Forte | Crilarsa'; desc='Cal Forte: hidróxido de calcio (cal hidratada) en sacos de 25 kg. Para preparación de piscinas camaroneras, bioseguridad en granjas, ajuste de pH y estabilización de suelos. Ecuador.'; body=(ProdPage 'calforte' 'Hidróxido de calcio' 'Hidróxido de calcio — Cal Forte' 'Cal hidratada de acción rápida en sacos de 25 kg, de producción propia.' 'ensacado-big-bag.jpg' (Faq 'Saco de 25 kg. Cal Forte Plus, Tipo A.' '¿Se puede aplicar con camarón en la piscina?' 'No. Por su acción fuerte se aplica sobre el fondo después de la cosecha y antes del llenado.')) };
  'zeolita.html' = @{ title='Zeolita natural en Ecuador — clinoptilolita malla 200 | Crilarsa'; desc='Zeolita clinoptilolita malla 200 en sacos de 25 kg. Uso agrícola, en camaroneras y camas de galpones. Despacho desde Guayaquil.'; body=(ProdPage 'zeolita' 'Zeolita' 'Zeolita natural' 'Clinoptilolita malla 200 en sacos de 25 kg.' 'estiba-pallets-montacargas.jpg' (Faq 'Saco de 25 kg, malla 200.' '¿Qué tipo de zeolita es?' 'Clinoptilolita natural, malla 200.')) };
  'yeso-agricola.html' = @{ title='Yeso agrícola (sulfato de calcio) en Ecuador | Crilarsa'; desc='Sulfato de calcio o yeso agrícola: calcio y azufre sin subir el pH, para bananeras y suelos compactados o sódicos. Cotice desde nuestra planta en Guayaquil.'; body=(ProdPage 'sulfato' 'Sulfato de calcio' 'Sulfato de calcio — yeso agrícola' 'Calcio y azufre sin subir el pH del suelo.' 'molino-elevador.jpg' (Faq 'Consulte presentaciones disponibles.' '¿El yeso agrícola sube el pH del suelo?' 'No. Aporta calcio y azufre sin subir el pH, por eso se usa cuando el pH ya es adecuado.')) };
  'mezcla-3-1.html' = @{ title='Mezcla 3:1 de carbonato y sulfato de calcio para banano | Crilarsa'; desc='Mezcla mineral 3:1 ultrafina de carbonato y sulfato de calcio en sacos de 45 o 50 kg: encalado y azufre en una sola aplicación. Guayaquil, Ecuador.'; body=(ProdPage 'mezcla' 'Mezcla mineral 3:1' 'Mezcla mineral 3:1' 'Carbonato y sulfato de calcio ultrafinos en un solo saco de 45 o 50 kg.' 'linea-produccion.jpg' (Faq 'Saco de 45 kg o 50 kg, molienda ultrafina.' '¿Qué contiene la mezcla 3:1?' 'Tres partes de carbonato de calcio por una parte de sulfato de calcio, en molienda ultrafina.')) };  'nosotros.html'  = @{ title='Crilarsa C.A. | Productor de minerales calcáreos en Ecuador desde 1989'; desc='Crilarsa C.A. produce minerales calcáreos en Guayaquil desde 1989: carbonato de calcio, cal y zeolita para bananeras, camaroneras, agricultura e industria en Ecuador y Sudamérica.'; body=@((PageHero 'Nosotros' 'Crilarsa C.A.' 'Minerales de calidad, producción propia y atención directa de fábrica desde 1989.' 'planta-bodega-general.jpg'),$story,$mision,$contacto) }
}

$banner = if ($Mode -eq 'preview') { '<div class="preview inner">Vista previa sin publicar · sitio organizado en páginas: Inicio, Productos, Nuestra planta y Nosotros</div>' } else { '' }

foreach ($name in $pages.Keys) {
  $p = $pages[$name]
  $body = ($p.body -join "`n`n")
  $nv = $nav
  $doc = @"
<title>$($p.title)</title>
<meta name="description" content="$($p.desc)">
<link rel="icon" type="image/png" href="logo-crilarsa-blanco.png">$($p.pre)
$style
</head>
<body>
$banner
$nv

<main id="contenido">
$body
</main>

$footer

$cartui
$mbar
$fab

$script
"@
  $isMainPreview = ($Mode -eq 'preview' -and $name -eq 'index.html')
  if ($isMainPreview) {
    $doc = $doc.Replace("</head>`n<body>`n","")
    $doc = "<meta name=`"claude:viewport-fit-sides`" content=`"cover`">`n" + $doc
  } else {
    $doc = "<!doctype html>`n<html lang=`"es`">`n<head>`n<meta charset=`"utf-8`">`n<meta name=`"viewport`" content=`"width=device-width, initial-scale=1, viewport-fit=cover`">`n" + $doc + "`n</body>`n</html>`n"
  }
  $doc = [regex]::Replace($doc,'<img (?![^>]*loading=)(?![^>]*logo-crilarsa)(?!src="''\+)','<img loading="lazy" decoding="async" ')
  [IO.File]::WriteAllText("$out\$name", $doc, (New-Object Text.UTF8Encoding $false))
  "{0}: {1:N0} KB" -f $name, ((Get-Item "$out\$name").Length/1KB)
}
