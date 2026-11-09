param([string]$Root,[int]$Port=8765)
$l=New-Object System.Net.HttpListener; $l.Prefixes.Add("http://localhost:$Port/"); $l.Start()
$types=@{'.html'='text/html; charset=utf-8';'.mp4'='video/mp4';'.mov'='video/mp4';'.jpg'='image/jpeg';'.jpeg'='image/jpeg';'.png'='image/png';'.css'='text/css';'.js'='text/javascript';'.svg'='image/svg+xml';'.json'='application/json'}
while($l.IsListening){ $c=$l.GetContext(); try{ $p=[Uri]::UnescapeDataString($c.Request.Url.AbsolutePath.TrimStart('/')); if($p -eq ''){$p='index.html'}; $f=Join-Path $Root $p
 if(Test-Path $f -PathType Leaf){ $b=[IO.File]::ReadAllBytes($f); $ext=[IO.Path]::GetExtension($f).ToLower(); $c.Response.ContentType=$(if($types[$ext]){$types[$ext]}else{'application/octet-stream'})
  $rng=$c.Request.Headers['Range']; if($rng -match 'bytes=(\d+)-(\d*)'){ $s=[int64]$matches[1]; $e=$(if($matches[2]){[int64]$matches[2]}else{$b.Length-1}); $c.Response.StatusCode=206; $c.Response.AddHeader('Content-Range',"bytes $s-$e/$($b.Length)"); $c.Response.AddHeader('Accept-Ranges','bytes'); $len=$e-$s+1; $c.Response.ContentLength64=$len; $c.Response.OutputStream.Write($b,[int]$s,[int]$len) } else { $c.Response.AddHeader('Accept-Ranges','bytes'); $c.Response.ContentLength64=$b.Length; $c.Response.OutputStream.Write($b,0,$b.Length) } }
 else { $c.Response.StatusCode=404 } } catch {} finally { try{$c.Response.Close()}catch{} } }
