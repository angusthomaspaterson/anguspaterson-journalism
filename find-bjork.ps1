# Find the Bjork review: Opera House Forecourt, Sydney, 23 January 2008.
#
# One run does both halves this time. It searches, then downloads whatever the search
# found, so there is no second trip.
#
#   1. Asks the Wayback index for every archived inthemix and FasterLouder address whose
#      URL mentions Bjork, the Forecourt or the Opera House. Both mastheads put the
#      headline in the address, which is what makes this work.
#   2. Downloads every result that looks like an article, so Claude can read the byline
#      and the copy straight away.
#   3. As a backstop, sweeps everything either site had archived between the show and
#      mid-2008, in case the headline never names her. Those go to CSV for Claude to
#      read; nothing is downloaded from them.
#
# Nothing is published. Existing files are skipped, so this is safe to re-run.

$ErrorActionPreference = "Continue"
Set-Location -LiteralPath $PSScriptRoot
$root = $PSScriptRoot
$dest = Join-Path $root "archived-pages\bjork"
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

function Ask-Cdx($name, $query) {
  $out = Join-Path $root ("wayback-" + $name + ".csv")
  Write-Host ""
  Write-Host ("Asking: " + $name) -ForegroundColor Cyan
  $rows = New-Object System.Collections.Generic.List[string]
  try {
    $r = Invoke-WebRequest -Uri $query -UseBasicParsing -TimeoutSec 240
    $lines = ($r.Content -split "`n") | Where-Object { $_.Trim() -ne "" }
    $csv = New-Object System.Collections.Generic.List[string]
    $csv.Add("original,timestamp,statuscode")
    foreach ($l in $lines) {
      $f = $l.Trim() -split "\s+"
      if ($f.Count -ge 3) {
        $csv.Add('"' + $f[0] + '","' + $f[1] + '","' + $f[2] + '"')
        $rows.Add($f[1] + " " + $f[0])
      }
    }
    $csv | Set-Content -LiteralPath $out -Encoding UTF8
    if ($rows.Count -eq 0) { Write-Host "  nothing archived" -ForegroundColor Yellow }
    else { Write-Host ("  {0} captures -> wayback-{1}.csv" -f $rows.Count, $name) -ForegroundColor Green }
  } catch {
    Write-Host ("  FAILED: " + $_.Exception.Message) -ForegroundColor Yellow
  }
  return $rows
}

function Cdx-Domain($site, $extra) {
  return "http://web.archive.org/cdx/search/cdx?url=$site&matchType=domain&fl=original,timestamp,statuscode&collapse=urlkey&limit=500&filter=statuscode:200" + $extra
}

$bjork     = "&filter=original:.*[Bb][Jj][Oo][Rr][Kk].*"
$forecourt = "&filter=original:.*[Ff][Oo][Rr][Ee][Cc][Oo][Uu][Rr][Tt].*"
$opera     = "&filter=original:.*[Oo][Pp][Ee][Rr][Aa].[Hh][Oo][Uu][Ss][Ee].*"

$hits = New-Object System.Collections.Generic.List[string]
foreach ($q in @(
  @{ n="itm-bjork";      u=(Cdx-Domain "inthemix.com.au"     $bjork) }
  @{ n="fl-bjork";       u=(Cdx-Domain "fasterlouder.com.au" $bjork) }
  @{ n="itm-forecourt";  u=(Cdx-Domain "inthemix.com.au"     $forecourt) }
  @{ n="fl-forecourt";   u=(Cdx-Domain "fasterlouder.com.au" $forecourt) }
  @{ n="itm-operahouse"; u=(Cdx-Domain "inthemix.com.au"     $opera) }
  @{ n="fl-operahouse";  u=(Cdx-Domain "fasterlouder.com.au" $opera) }
)) {
  $r = Ask-Cdx $q.n $q.u
  foreach ($x in $r) { $hits.Add($x) }
}

# ------------------------------------------------------------------ download the finds
# Only addresses that look like an article are worth fetching. Gig guides, artist hubs,
# galleries and forum threads are not the review.
$patterns = @("/events/reviews/", "/reviews/events/", "/features/", "/reviews/music/", "/news/")
$seen = New-Object System.Collections.Generic.HashSet[string]
$n = 0

Write-Host ""
Write-Host "Downloading the article pages among those results." -ForegroundColor Cyan
foreach ($row in $hits) {
  if ($n -ge 60) { break }
  $sp = $row.IndexOf(" ")
  if ($sp -lt 1) { continue }
  $ts = $row.Substring(0, $sp)
  $orig = $row.Substring($sp + 1)

  $isArticle = $false
  foreach ($p in $patterns) { if ($orig -like ("*" + $p + "*")) { $isArticle = $true } }
  if (-not $isArticle) { continue }
  # skip the mobile, contribute and staging mirrors of the same article
  if ($orig -match "://(m|contribute|web1|webitm\d|css|livechat)\.") { continue }

  $key = ($orig -replace "^https?://(www\.)?", "" -replace ":80", "")
  if (-not $seen.Add($key)) { continue }

  $safe = ($key -replace "[^A-Za-z0-9]", "_")
  if ($safe.Length -gt 95) { $safe = $safe.Substring(0, 95) }
  $full = Join-Path $dest ($ts + "_" + $safe + ".html")
  if ((Test-Path $full) -and ((Get-Item $full).Length -gt 500)) { Write-Host "skip  $key"; $n++; continue }
  try {
    Invoke-WebRequest -Uri ("http://web.archive.org/web/" + $ts + "id_/" + $orig) `
                      -OutFile $full -UseBasicParsing -TimeoutSec 120
    $len = (Get-Item $full).Length
    if ($len -lt 500) { Remove-Item $full -Force; Write-Host ("EMPTY " + $key) -ForegroundColor Yellow }
    else { Write-Host ("ok    {0,-70} {1} KB" -f $key, [math]::Round($len/1KB)) -ForegroundColor Green }
  } catch {
    Write-Host ("FAIL  " + $key + "  " + $_.Exception.Message) -ForegroundColor Yellow
    if (Test-Path $full) { Remove-Item $full -Force }
  }
  $n++
  Start-Sleep -Milliseconds 1200
}

# ------------------------------------------------------------------ backstop sweep
function Cdx-Window($site, $from, $to) {
  return "http://web.archive.org/cdx/search/cdx?url=$site&matchType=domain&fl=original,timestamp,statuscode&collapse=urlkey&limit=3000&filter=statuscode:200&from=$from&to=$to"
}
Ask-Cdx "itm-window-2008" (Cdx-Window "inthemix.com.au"     "20080123" "20080731") | Out-Null
Ask-Cdx "fl-window-2008"  (Cdx-Window "fasterlouder.com.au" "20080123" "20080731") | Out-Null

# ------------------------------------------------------------------ summary
Write-Host ""
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
$saved = (Get-ChildItem -LiteralPath $dest -Filter *.html -File | Measure-Object).Count
Write-Host ("Article pages saved into archived-pages\bjork\: {0}" -f $saved)
if ($saved -eq 0) {
  Write-Host "Nothing downloaded. Either the search found no articles, or the Wayback" -ForegroundColor Yellow
  Write-Host "Machine refused the requests. Either way, tell Claude." -ForegroundColor Yellow
}
Write-Host ""
Write-Host "CSV files written beside this script:"
foreach ($f in (Get-ChildItem -LiteralPath $root -Filter "wayback-*.csv" -File | Sort-Object Name)) {
  $c = (Get-Content -LiteralPath $f.FullName | Measure-Object -Line).Lines - 1
  Write-Host ("  {0,-36} {1} rows" -f $f.Name, $c)
}
Write-Host ""
Write-Host "Tell Claude how many pages were saved."
Write-Host ""
