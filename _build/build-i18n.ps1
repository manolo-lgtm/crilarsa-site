param([string]$Out)
$s = Split-Path -Parent $MyInvocation.MyCommand.Path
$keys = Get-Content "$s\i18n\es-keys.json" -Raw -Encoding UTF8 | ConvertFrom-Json
New-Item -ItemType Directory -Force "$Out\i18n" | Out-Null
foreach($l in 'en','pt','fr','ru','uk','zh'){
  $lines = [IO.File]::ReadAllLines("$s\i18n\$l.txt",[Text.Encoding]::UTF8)
  if($lines.Count -ne $keys.Count){ throw "$l tiene $($lines.Count) líneas; se esperan $($keys.Count)" }
  $sb = New-Object Text.StringBuilder; [void]$sb.Append('{')
  for($i=0;$i -lt $keys.Count;$i++){
    if($i){ [void]$sb.Append(',') }
    $k = ([string]$keys[$i]) | ConvertTo-Json; $v = ([string]$lines[$i]).Trim() | ConvertTo-Json
    [void]$sb.Append("`n$k`:$v")
  }
  [void]$sb.Append("`n}")
  [IO.File]::WriteAllText("$Out\i18n\$l.json",$sb.ToString(),(New-Object Text.UTF8Encoding $false))
}
"i18n -> $Out\i18n"
