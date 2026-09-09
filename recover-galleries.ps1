# The photographs are his own, and they were in his galleries rather than his articles.
#
# What the folder sweeps changed:
#
#   1. TWO LEAD PHOTOGRAPHS DO SURVIVE, at sizes the articles never used. The One night
#      in Ibiza lead exists at 635x290 and the Time Warp Mannheim lead at 311x206. Both
#      are downloaded here. The seven body photographs in those two pieces have no
#      capture at any size and are gone for good.
#
#   2. THE GALLERIES. inthemix ran event photo galleries separately from the articles.
#      The three Sonar 2012 galleries are archived, and every photograph in them is
#      credited to "angy". His own pictures. Each gallery page carries the full list at
#      623x415, 57 photographs in all. This tries every one.
#
#      The same pages say he had 104 other albums, so this also sweeps the folders those
#      live in, asks where the rest of his albums are archived, and looks for the Sonar
#      article, which the earlier search missed because the headline carries an accent.
#
# Nothing is published. Existing files are skipped, so this is safe to re-run.

$ErrorActionPreference = "Continue"
Set-Location -LiteralPath $PSScriptRoot
$root = $PSScriptRoot
$base = Join-Path $root "recovered-external\ic.i.tsatic-cdn.net"
if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base -Force | Out-Null }

function Get-Img($src, $stamp) {
  $full = Join-Path $base ($src.TrimStart("/") -replace "/", "\")
  $dir  = Split-Path $full -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  if ((Test-Path $full) -and ((Get-Item $full).Length -gt 500)) { return "skip" }
  try {
    Invoke-WebRequest -Uri ("http://web.archive.org/web/" + $stamp + "id_/http://ic.i.tsatic-cdn.net" + $src) `
                      -OutFile $full -UseBasicParsing -TimeoutSec 90
    $len = (Get-Item $full).Length
    if ($len -lt 500) { Remove-Item $full -Force; return "empty" }
    return ("ok " + [math]::Round($len/1KB) + " KB")
  } catch { if (Test-Path $full) { Remove-Item $full -Force }; return "fail" }
}

Write-Host ""
Write-Host "The two lead photographs the sweeps turned up." -ForegroundColor Cyan
foreach ($p in @(
  @{ s = "/1398/635_290/edc7a_1398927.jpg"; t = "20121018"; n = "One night in Ibiza lead, 635x290" }
  @{ s = "/1526/311_206/4b202_1526472.jpg"; t = "20120911"; n = "Time Warp Mannheim lead, 311x206" }
)) {
  $r = Get-Img $p.s $p.t
  $col = "Yellow"; if ($r -like "ok*" -or $r -eq "skip") { $col = "Green" }
  Write-Host ("  {0,-40} {1}" -f $p.n, $r) -ForegroundColor $col
  Start-Sleep -Milliseconds 1200
}

Write-Host ""
Write-Host "Defqon.1 Holland, whose folder was never swept." -ForegroundColor Cyan
foreach ($s in @("/1554/635_340/a4b12_1554017.jpg", "/1554/635_422/9f98d_1554019.jpg", "/1554/635_422/58e0a_1554018.jpg")) {
  $r = Get-Img $s "20120711"
  $col = "Yellow"; if ($r -like "ok*" -or $r -eq "skip") { $col = "Green" }
  Write-Host ("  {0,-46} {1}" -f $s, $r) -ForegroundColor $col
  Start-Sleep -Milliseconds 1200
}

$sonar = @(
  "/1547/623_415/236cd_1547986.jpg"
  "/1547/623_415/ed071_1547985.jpg"
  "/1547/623_415/12cbb_1547987.jpg"
  "/1548/623_414/3c134_1548002.jpg"
  "/1548/623_414/33161_1548035.jpg"
  "/1548/623_415/fd906_1548057.jpg"
  "/1548/623_415/b078e_1548060.jpg"
  "/1548/623_415/31907_1548064.jpg"
  "/1548/277_416/1fba4_1548066.jpg"
  "/1548/623_415/ec4d6_1548067.jpg"
  "/1548/623_415/219ea_1548068.jpg"
  "/1548/623_415/f20b2_1548069.jpg"
  "/1548/623_415/84d69_1548070.jpg"
  "/1548/623_415/26d0a_1548790.jpg"
  "/1548/623_415/cd1d9_1548789.jpg"
  "/1548/623_415/bbc91_1548791.jpg"
  "/1548/623_415/b1cda_1548792.jpg"
  "/1548/623_415/463cc_1548793.jpg"
  "/1548/623_415/ded78_1548794.jpg"
  "/1548/623_415/7f863_1548795.jpg"
  "/1548/623_415/75e4d_1548796.jpg"
  "/1548/623_415/e1d70_1548797.jpg"
  "/1548/623_415/8521d_1548798.jpg"
  "/1548/623_415/9270d_1548799.jpg"
  "/1548/623_415/b0883_1548800.jpg"
  "/1548/623_415/afc97_1548801.jpg"
  "/1548/623_415/59340_1548802.jpg"
  "/1548/623_415/49acb_1548803.jpg"
  "/1548/623_406/3248e_1548818.jpg"
  "/1548/623_415/5c4b5_1548788.jpg"
  "/1548/623_415/58438_1548804.jpg"
  "/1548/623_415/20243_1548805.jpg"
  "/1548/623_400/2980e_1548806.jpg"
  "/1548/623_415/e501b_1548808.jpg"
  "/1548/623_415/1080b_1548810.jpg"
  "/1548/623_415/c6a57_1548811.jpg"
  "/1548/623_415/a29e0_1548812.jpg"
  "/1548/623_442/555a5_1548813.jpg"
  "/1548/623_363/58f40_1548814.jpg"
  "/1548/623_397/03a77_1548815.jpg"
  "/1548/623_399/c13dc_1548816.jpg"
  "/1548/623_391/ce5f0_1548817.jpg"
  "/1548/623_415/4768b_1548098.jpg"
  "/1548/623_415/7d635_1548094.jpg"
  "/1548/623_415/69233_1548096.jpg"
  "/1548/623_415/53762_1548097.jpg"
  "/1548/623_415/27f34_1548099.jpg"
  "/1548/623_415/0fd97_1548100.jpg"
  "/1548/623_415/8376a_1548102.jpg"
  "/1548/623_375/24032_1548103.jpg"
  "/1548/623_346/ab916_1548104.jpg"
  "/1548/623_270/d52fb_1548105.jpg"
  "/1548/623_335/312bb_1548106.jpg"
  "/1548/623_402/127f3_1548107.jpg"
  "/1548/623_415/1f479_1548108.jpg"
  "/1548/277_416/f88b7_1548109.jpg"
  "/1548/277_416/bde04_1548110.jpg"
)

Write-Host ""
Write-Host ("His {0} Sonar 2012 photographs, at 623x415." -f $sonar.Count) -ForegroundColor Cyan
$got = 0; $i = 0
foreach ($s in $sonar) {
  $i++
  $r = Get-Img $s "20120701"
  if ($r -like "ok*" -or $r -eq "skip") { $got++ }
  $col = "DarkYellow"; if ($r -like "ok*") { $col = "Green" } elseif ($r -eq "skip") { $col = "DarkGray" }
  Write-Host ("  {0,3}/{1}  {2,-40} {3}" -f $i, $sonar.Count, $s, $r) -ForegroundColor $col
  Start-Sleep -Milliseconds 900
}

function Ask-Cdx($name, $query) {
  $out = Join-Path $root ("wayback-" + $name + ".csv")
  Write-Host ""
  Write-Host ("Asking: " + $name) -ForegroundColor Cyan
  try {
    $r = Invoke-WebRequest -Uri $query -UseBasicParsing -TimeoutSec 300
    $lines = ($r.Content -split "`n") | Where-Object { $_.Trim() -ne "" }
    $csv = New-Object System.Collections.Generic.List[string]
    $csv.Add("original,timestamp,statuscode")
    foreach ($l in $lines) {
      $f = $l.Trim() -split "\s+"
      if ($f.Count -ge 3) { $csv.Add('"' + $f[0] + '","' + $f[1] + '","' + $f[2] + '"') }
    }
    $csv | Set-Content -LiteralPath $out -Encoding UTF8
    Write-Host ("  {0} captures" -f $lines.Count) -ForegroundColor Green
  } catch { Write-Host ("  FAILED: " + $_.Exception.Message) -ForegroundColor Yellow }
}
function Pfx($u, $lim) {
  return "http://web.archive.org/cdx/search/cdx?url=" + [uri]::EscapeDataString($u) + "&matchType=prefix&fl=original,timestamp,statuscode&collapse=urlkey&limit=" + $lim
}

foreach ($fld in @("1545", "1546", "1547", "1548", "1549", "1554")) {
  Ask-Cdx ("folder-" + $fld) (Pfx ("ic.i.tsatic-cdn.net/" + $fld + "/") 2000)
}
Ask-Cdx "his-galleries" (Pfx "inthemix.com.au/gallery/snap/" 2000)
Ask-Cdx "gallery-angy"  (Pfx "inthemix.com.au/people/angy/gallery" 500)
Ask-Cdx "find-barcelona" ("http://web.archive.org/cdx/search/cdx?url=inthemix.com.au&matchType=domain&fl=original,timestamp,statuscode&collapse=urlkey&limit=500&filter=statuscode:200&filter=original:.*[Bb][Aa][Rr][Cc][Ee][Ll][Oo][Nn][Aa].*")

Write-Host ""
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host ("Sonar photographs now present: {0} of {1}" -f $got, $sonar.Count)
$total = (Get-ChildItem -LiteralPath $base -Recurse -File | Measure-Object).Count
Write-Host ("Files under recovered-external\ic.i.tsatic-cdn.net: {0}" -f $total)
Write-Host ""
Write-Host "CSV files written:"
foreach ($f in (Get-ChildItem -LiteralPath $root -Filter "wayback-folder-15*.csv" -File | Sort-Object Name)) {
  $c = (Get-Content -LiteralPath $f.FullName | Measure-Object -Line).Lines - 1
  Write-Host ("  {0,-34} {1}" -f $f.Name, $c)
}
foreach ($n in @("his-galleries", "gallery-angy", "find-barcelona")) {
  $p = Join-Path $root ("wayback-" + $n + ".csv")
  if (Test-Path $p) {
    $c = (Get-Content -LiteralPath $p | Measure-Object -Line).Lines - 1
    Write-Host ("  {0,-34} {1}" -f ("wayback-" + $n + ".csv"), $c)
  }
}
Write-Host ""
Write-Host "Tell Claude the Sonar count and those CSV numbers."
Write-Host ""
