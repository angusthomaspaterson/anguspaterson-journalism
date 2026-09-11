# ---------------------------------------------------------------------------
#  The last 42 photographs
#
#  The archive is now 206 pieces. Every photograph that survives has been found
#  and wired in, with one exception: 42 inline photographs across 7 articles.
#  This goes after them, and it is the last image hunt worth running.
#
#  What is different this time. Earlier rounds guessed at addresses and mostly
#  missed, because the Wayback Machine crawled inthemix's small thumbnails
#  rather than the large sizes the articles displayed. So this script does not
#  guess. It asks the archive what it holds for each folder, reads the answer,
#  and downloads whatever it finds at the largest size available.
#
#  Four of these seven folders have never been swept at all:
#
#      1686   12 photographs   The inthemix Guide to Amsterdam
#      1551    7 photographs   Sonar Festival 2012: inthemix goes to Barcelona
#      1697    5 photographs   Inside a Winter Weekend Partying in Helsinki
#      1736    1 photograph    "It's the Most Advanced, Flipped-Out Show So Far"
#
#  The other three were swept before and came up short, but at the time the
#  sweep only looked at one host. They are included again, across both.
#
#      1569    9 photographs   Tomorrowland 2012: The epic review
#      1734    5 photographs   Riot in Denmark: Distortion Festival
#      1526    3 photographs   One night in Mannheim: Time Warp 2012
#
#  Nothing is published and nothing on your machine is changed except that new
#  photographs appear under recovered-external\. Files already there are
#  skipped, so this is safe to run more than once. Takes 10 to 20 minutes.
# ---------------------------------------------------------------------------

$ErrorActionPreference = "Continue"
Set-Location -LiteralPath $PSScriptRoot
$root = $PSScriptRoot

$targets = @(
  @{ folder = "1686"; ids = @(1686816,1686817,1686818,1686819,1686820,1686821,1686822,1686823,1686824,1686825,1686827,1686830); story = "The inthemix Guide to Amsterdam" }
  @{ folder = "1551"; ids = @(1551600,1551601,1551602,1551603,1551604,1551605,1551607); story = "Sonar Festival 2012, Barcelona" }
  @{ folder = "1697"; ids = @(1697692,1697699,1697700,1697701,1697702); story = "A Winter Weekend in Helsinki" }
  @{ folder = "1736"; ids = @(1736135); story = "The Most Advanced, Flipped-Out Show" }
  @{ folder = "1569"; ids = @(1569456,1569462,1569466,1569467,1569481,1569495,1569508,1569514,1569702); story = "Tomorrowland 2012" }
  @{ folder = "1734"; ids = @(1734655,1734656,1734657,1734658,1734659); story = "Riot in Denmark: Distortion" }
  @{ folder = "1526"; ids = @(1526467,1526468,1526469); story = "One night in Mannheim: Time Warp" }
)

function Ask-Cdx($url, $limit) {
  $q = "http://web.archive.org/cdx/search/cdx?url=" + [uri]::EscapeDataString($url) +
       "&matchType=prefix&fl=original,timestamp,statuscode&collapse=urlkey&filter=statuscode:200&limit=" + $limit
  try {
    $r = Invoke-WebRequest -Uri $q -UseBasicParsing -TimeoutSec 300
    $rows = @()
    foreach ($l in ($r.Content -split "`n")) {
      if ($l.Trim() -eq "") { continue }
      $f = $l.Trim() -split "\s+"
      if ($f.Count -ge 2) { $rows += ,@($f[0], $f[1]) }
    }
    return $rows
  } catch {
    Write-Host ("    query failed: " + $_.Exception.Message) -ForegroundColor Yellow
    return @()
  }
}

function Save-Capture($original, $stamp) {
  # strip scheme, keep host+path, so the file lands in a mirror of the CDN layout
  $clean = $original -replace "^https?://", ""
  $clean = $clean -replace "^.*?/s/resize/\d+/(https?://)?", ""      # unwrap cloudimg proxy
  $full  = Join-Path $root ("recovered-external\" + ($clean -replace "/", "\"))
  $dir   = Split-Path $full -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  if ((Test-Path $full) -and ((Get-Item $full).Length -gt 2000)) { return "skip" }
  try {
    Invoke-WebRequest -Uri ("http://web.archive.org/web/" + $stamp + "id_/" + $original) `
                      -OutFile $full -UseBasicParsing -TimeoutSec 120
    $len = (Get-Item $full).Length
    if ($len -lt 2000) { Remove-Item $full -Force; return "too small" }
    return ("ok " + [math]::Round($len/1KB) + " KB")
  } catch {
    if (Test-Path $full) { Remove-Item $full -Force }
    return "fail"
  }
}

$summary = @()

foreach ($t in $targets) {
  $fld = $t.folder
  Write-Host ""
  Write-Host ("===== folder " + $fld + "  ::  " + $t.story) -ForegroundColor Cyan
  Write-Host ("      looking for " + $t.ids.Count + " photographs")

  # ask every host these images were ever served from
  $rows = @()
  foreach ($h in @("images.inthemix.com.au/$fld/", "ic.i.tsatic-cdn.net/$fld/", "i.inthemix.com.au/$fld/")) {
    $r = Ask-Cdx $h 2000
    Write-Host ("      " + $h.PadRight(36) + " " + $r.Count + " captures")
    $rows += $r
  }
  # the cloudimg proxy rewrote the same images through its own host
  $r = Ask-Cdx "ebeqsne.cloudimg.io/s/resize/680/http://images.inthemix.com.au/$fld/" 2000
  if ($r.Count -gt 0) { Write-Host ("      cloudimg proxy".PadRight(42) + " " + $r.Count + " captures") }
  $rows += $r

  # save the full capture list for this folder, so nothing has to be asked twice
  $csv = New-Object System.Collections.Generic.List[string]
  $csv.Add("original,timestamp")
  foreach ($row in $rows) { $csv.Add('"' + $row[0] + '","' + $row[1] + '"') }
  $csv | Set-Content -LiteralPath (Join-Path $root ("captures-" + $fld + ".csv")) -Encoding UTF8

  # for each wanted photograph, take every capture that names it, biggest first
  foreach ($id in $t.ids) {
    $mine = @($rows | Where-Object { $_[0] -match ("" + $id) })
    if ($mine.Count -eq 0) {
      Write-Host ("      " + $id + "  no capture at any size") -ForegroundColor DarkGray
      $summary += ,@($fld, $id, "none")
      continue
    }
    # sort by the width in the path (…/635_290/…) so the largest is tried first
    $ranked = $mine | Sort-Object -Descending {
      if ($_[0] -match "/(\d{2,4})_\d{2,4}/") { [int]$matches[1] } else { 0 }
    }
    $done = $false
    foreach ($cap in $ranked) {
      $res = Save-Capture $cap[0] $cap[1]
      if ($res -like "ok*" -or $res -eq "skip") {
        Write-Host ("      " + $id + "  " + $res + "   " + $cap[0]) -ForegroundColor Green
        $summary += ,@($fld, $id, $res)
        $done = $true
        break
      }
      Start-Sleep -Milliseconds 700
    }
    if (-not $done) {
      Write-Host ("      " + $id + "  " + $mine.Count + " captures listed, none downloadable") -ForegroundColor Yellow
      $summary += ,@($fld, $id, "listed but dead")
    }
    Start-Sleep -Milliseconds 900
  }
}

Write-Host ""
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
$got  = @($summary | Where-Object { $_[2] -like "ok*" -or $_[2] -eq "skip" }).Count
$none = @($summary | Where-Object { $_[2] -eq "none" }).Count
$dead = @($summary | Where-Object { $_[2] -eq "listed but dead" }).Count
Write-Host ("Photographs recovered:            {0} of {1}" -f $got, $summary.Count) -ForegroundColor Green
Write-Host ("No capture at any size:           {0}" -f $none)
Write-Host ("Listed in the index but dead:     {0}" -f $dead)
$total = 0
if (Test-Path (Join-Path $root "recovered-external")) {
  $total = (Get-ChildItem -LiteralPath (Join-Path $root "recovered-external") -Recurse -File | Measure-Object).Count
}
Write-Host ("Files under recovered-external:   {0}" -f $total)
Write-Host ""
Write-Host "Per folder:"
foreach ($t in $targets) {
  $f = $t.folder
  $g = @($summary | Where-Object { $_[0] -eq $f -and ($_[2] -like "ok*" -or $_[2] -eq "skip") }).Count
  Write-Host ("  {0}  {1,2} of {2,2}   {3}" -f $f, $g, $t.ids.Count, $t.story)
}
Write-Host ""
Write-Host "Tell Claude those numbers and he will wire in whatever came down." -ForegroundColor Cyan
Write-Host ""
