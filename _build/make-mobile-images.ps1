# Genera versiones livianas (-m.jpg, máx. 800 px de ancho) de las fotos de contenido para celulares.
Add-Type -AssemblyName System.Drawing
$s = Split-Path -Parent $MyInvocation.MyCommand.Path
$enc=[Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | ? { $_.MimeType -eq 'image/jpeg' }
$ep=New-Object Drawing.Imaging.EncoderParameters 1; $ep.Param[0]=[Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality,[long]68)
$all=''; foreach($p in Get-ChildItem "$s\deploy\*.html" | ? { $_.Name -notmatch '^(index\.v|en-|pt-|fr-|ru-|uk-|zh-)' }){ $all+=[IO.File]::ReadAllText($p.FullName) }
$names=[regex]::Matches($all,'<img[^>]*src="([A-Za-z0-9._-]+\.(?:jpe?g))"') | % { $_.Groups[1].Value } | ? { $_ -notmatch '-m\.jpe?g$' } | select -Unique
$made=@(); $skip=@('planta-bodega-general.jpg')  # su -m es la portada móvil precargada (720 px, calidad 60): no se regenera aquí
foreach($n in $names){
  $src="$s\deploy\$n"; if(-not (Test-Path $src) -or $skip -contains $n){ continue }
  $out="$s\deploy\"+[IO.Path]::GetFileNameWithoutExtension($n)+'-m.jpg'
  $img=[Drawing.Image]::FromFile($src)
  if($img.Width -le 820 -and (Get-Item $src).Length -lt 150KB){ $img.Dispose(); continue }
  $w=[int][Math]::Min([Math]::Min(800,$img.Width),$img.Width*1000/$img.Height); $h=[int]($img.Height*$w/$img.Width)
  $bmp=New-Object Drawing.Bitmap $w,$h; $g=[Drawing.Graphics]::FromImage($bmp); $g.InterpolationMode='HighQualityBicubic'; $g.DrawImage($img,0,0,$w,$h); $g.Dispose(); $img.Dispose()
  $bmp.Save($out,$enc,$ep); $bmp.Dispose(); $made+="$n -> $([int]((Get-Item $out).Length/1KB))KB"
}
$made
