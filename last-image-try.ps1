# One more try at the photographs, using three approaches none of the earlier passes used.
#
#   1. TWO PIECES NEVER LOOKED AT. Sonar 2012 and Defqon.1 Holland were not among the
#      twelve article pages fetched earlier, so their photograph filenames have never
#      been read. This finds and downloads those two pages. Genuinely new ground.
#
#   2. WHOLE-FOLDER SWEEPS. Until now each image was checked at its exact address, the
#      one dimension variant that happened to appear in the article. The CDN served
#      several sizes of every photograph. These sweeps ask what the archive holds under
#      the whole folder, so any surviving variant of any photograph shows up, whatever
#      its size. This is the test that could still surprise us.
#
#   3. THE RESIZING PROXY. The later pieces loaded their images through cloudimg.io
#      rather than direct. Those are different addresses and may have been crawled when
#      the originals were not.
#
#   Plus the inthemix event galleries, which were separate pages of event photography.
#
# Everything is written to CSV for Claude to read, apart from the two article pages.
# Nothing is published.

$ErrorActionPreference = "Continue"
Set-Location -LiteralPath $PSScriptRoot
$root = $PSScriptRoot
$dest = Join-Path $root "archived-pages\last-try"
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

function Ask-Cdx($name, $query) {
  $out = Join-Path $root ("wayback-" + $name + ".csv")
  Write-Host ""
  Write-Host ("Asking: " + $name) -ForegroundColor Cyan
  $rows = New-Object System.Collections.Generic.List[string]
  try {
    $r = Invoke-WebRequest -Uri $query -UseBasicParsing -TimeoutSec 300
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
function Cdx-Prefix($url, $lim) {
  return "http://web.archive.org/cdx/search/cdx?url=" + [uri]::EscapeDataString($url) + "&matchType=prefix&fl=original,timestamp,statuscode&collapse=urlkey&limit=$lim"
}
function Cdx-Domain($site, $extra) {
  return "http://web.archive.org/cdx/search/cdx?url=$site&matchType=domain&fl=original,timestamp,statuscode&collapse=urlkey&limit=500&filter=statuscode:200" + $extra
}

# -------------------------------------------------- 1. the two pieces never looked at
$hits = New-Object System.Collections.Generic.List[string]
foreach ($q in @(
  @{ n="find-sonar";        u=(Cdx-Domain "inthemix.com.au"     "&filter=original:.*[Ss][Oo][Nn][Aa][Rr].*") }
  @{ n="find-defqon";       u=(Cdx-Domain "inthemix.com.au"     "&filter=original:.*[Dd][Ee][Ff][Qq][Oo][Nn].*") }
  @{ n="find-tomorrowland"; u=(Cdx-Domain "inthemix.com.au"     "&filter=original:.*[Tt][Oo][Mm][Oo][Rr][Rr][Oo][Ww][Ll][Aa][Nn][Dd].*") }
  @{ n="find-amnesia";      u=(Cdx-Domain "inthemix.com.au"     "&filter=original:.*[Aa][Mm][Nn][Ee][Ss][Ii][Aa].*") }
  @{ n="find-timewarp";     u=(Cdx-Domain "inthemix.com.au"     "&filter=original:.*[Tt][Ii][Mm][Ee]._?[Ww][Aa][Rr][Pp].*") }
)) {
  $r = Ask-Cdx $q.n $q.u
  foreach ($x in $r) { $hits.Add($x) }
}

Write-Host ""
Write-Host "Downloading the feature and gallery pages among those results." -ForegroundColor Cyan
$want = @("/features/", "/events/reviews/", "/gallery/")
$seen = New-Object System.Collections.Generic.HashSet[string]
$n = 0
foreach ($row in $hits) {
  if ($n -ge 70) { break }
  $sp = $row.IndexOf(" "); if ($sp -lt 1) { continue }
  $ts = $row.Substring(0, $sp); $orig = $row.Substring($sp + 1)
  $ok = $false; foreach ($w in $want) { if ($orig -like ("*" + $w + "*")) { $ok = $true } }
  if (-not $ok) { continue }
  if ($orig -match "://(m|contribute|web1|webitm\d|css|livechat)\.") { continue }
  $key = ($orig -replace "^https?://(www\.)?", "" -replace ":80", "")
  if (-not $seen.Add($key)) { continue }
  $safe = ($key -replace "[^A-Za-z0-9]", "_"); if ($safe.Length -gt 95) { $safe = $safe.Substring(0, 95) }
  $full = Join-Path $dest ($ts + "_" + $safe + ".html")
  if ((Test-Path $full) -and ((Get-Item $full).Length -gt 500)) { Write-Host "skip  $key"; $n++; continue }
  try {
    Invoke-WebRequest -Uri ("http://web.archive.org/web/" + $ts + "id_/" + $orig) -OutFile $full -UseBasicParsing -TimeoutSec 120
    $len = (Get-Item $full).Length
    if ($len -lt 500) { Remove-Item $full -Force; Write-Host ("EMPTY " + $key) -ForegroundColor Yellow }
    else { Write-Host ("ok    {0,-66} {1} KB" -f $key, [math]::Round($len/1KB)) -ForegroundColor Green }
  } catch {
    Write-Host ("FAIL  " + $key) -ForegroundColor Yellow
    if (Test-Path $full) { Remove-Item $full -Force }
  }
  $n++
  Start-Sleep -Milliseconds 1200
}

# -------------------------------------------------- 2. whole-folder sweeps
Ask-Cdx "folder-tsatic-1398" (Cdx-Prefix "ic.i.tsatic-cdn.net/1398/" 2000) | Out-Null
Ask-Cdx "folder-tsatic-1526" (Cdx-Prefix "ic.i.tsatic-cdn.net/1526/" 2000) | Out-Null
Ask-Cdx "folder-tsatic-all"  (Cdx-Prefix "ic.i.tsatic-cdn.net/" 2000) | Out-Null
Ask-Cdx "folder-itmimg-1569" (Cdx-Prefix "images.inthemix.com.au/1569/" 2000) | Out-Null
Ask-Cdx "folder-itmimg-1734" (Cdx-Prefix "images.inthemix.com.au/1734/" 2000) | Out-Null
Ask-Cdx "folder-itmimg-all"  (Cdx-Prefix "images.inthemix.com.au/" 2000) | Out-Null

# -------------------------------------------------- 3. the resizing proxy
Ask-Cdx "proxy-cloudimg" (Cdx-Prefix "ebeqsne.cloudimg.io/" 2000) | Out-Null

# -------------------------------------------------- summary
Write-Host ""
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
$saved = (Get-ChildItem -LiteralPath $dest -Filter *.html -File | Measure-Object).Count
Write-Host ("Pages saved into archived-pages\last-try\: {0}" -f $saved)
Write-Host ""
Write-Host "Folder sweeps, which is the number that matters:"
foreach ($n2 in @("folder-tsatic-1398","folder-tsatic-1526","folder-tsatic-all",
                  "folder-itmimg-1569","folder-itmimg-1734","folder-itmimg-all","proxy-cloudimg")) {
  $p = Join-Path $root ("wayback-" + $n2 + ".csv")
  if (Test-Path $p) {
    $c = (Get-Content -LiteralPath $p | Measure-Object -Line).Lines - 1
    $col = if ($c -gt 0) { "Green" } else { "DarkGray" }
    Write-Host ("  {0,-24} {1} captures" -f $n2, $c) -ForegroundColor $col
  } else {
    Write-Host ("  {0,-24} not written" -f $n2) -ForegroundColor Yellow
  }
}
Write-Host ""
Write-Host "Tell Claude the page count and those seven numbers."
Write-Host ""
