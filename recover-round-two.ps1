# Round two, revised. Three jobs, none of which touch your published site.
#
#   1. Download the twenty-three photographs whose real filenames the archived article
#      pages gave up. These are the images that were simply absent from five pieces.
#   2. Ask the Wayback Machine which archived pages exist for a handful of searches,
#      and write each answer to a CSV file for Claude to read.
#   3. Download every archived page found under your author profiles on inthemix and
#      FasterLouder, so Claude can read your own index of 1,914 articles and find the
#      Nine Inch Nails review in it.
#
# Nothing is published. Nothing already present is overwritten: a file that already
# exists is skipped, so running this twice is safe, and safe to re-run if it stops
# partway through.
#
# Every path is anchored to THIS FILE rather than the working directory, so it behaves
# the same whether you double-click it or run it from somewhere else, elevated or not.

$ErrorActionPreference = "Continue"
Set-Location -LiteralPath $PSScriptRoot

$root  = $PSScriptRoot
$pages = Join-Path $root "archived-pages"
$angy  = Join-Path $pages "angy"
foreach ($d in @((Join-Path $root "recovered-external"), $pages, $angy)) {
  if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

function Get-One($url, $relPath, $label) {
  $full = Join-Path $root $relPath
  $dir  = Split-Path $full -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  if ((Test-Path $full) -and ((Get-Item $full).Length -gt 0)) { Write-Host "skip  $label"; return $true }
  try {
    Invoke-WebRequest -Uri $url -OutFile $full -UseBasicParsing -TimeoutSec 90
    $len = (Get-Item $full).Length
    if ($len -lt 500) { Remove-Item $full -Force; Write-Host ("EMPTY $label") -ForegroundColor Yellow; return $false }
    Write-Host ("ok    {0,-52} {1} KB" -f $label, [math]::Round($len/1KB)) -ForegroundColor Green
    return $true
  } catch {
    Write-Host ("FAIL  {0,-52} {1}" -f $label, $_.Exception.Message) -ForegroundColor Yellow
    if (Test-Path $full) { Remove-Item $full -Force }
    return $false
  }
}

# ---------------------------------------------------------------- the missing page
Write-Host ""
Write-Host "Retrying the one archived page that came down empty last time." -ForegroundColor Cyan
Get-One "http://web.archive.org/web/20110702040100id_/http://www.inthemix.com.au/features/50400/One_night_in_Ibiza_Cream_Amnesia?page=3" `
        "archived-pages\one-night-in-ibiza-p3.html" "one-night-in-ibiza-p3" | Out-Null

# ---------------------------------------------------------------- the photographs
# "2012id_" asks the Wayback Machine for whichever capture sits nearest that year, and
# for the original file rather than its own rewritten copy.
$imgs = @(
  @{ h="ic.i.tsatic-cdn.net"; p="1398/635_340/a2764_1398927.jpg"; y="2012" }
  @{ h="ic.i.tsatic-cdn.net"; p="1398/300_449/69900_1398924.jpg"; y="2012" }
  @{ h="ic.i.tsatic-cdn.net"; p="1398/300_200/5b573_1398920.jpg"; y="2012" }
  @{ h="ic.i.tsatic-cdn.net"; p="1398/300_200/d1dd9_1398923.jpg"; y="2012" }
  @{ h="ic.i.tsatic-cdn.net"; p="1398/300_449/3fa0b_1398926.jpg"; y="2012" }
  @{ h="ic.i.tsatic-cdn.net"; p="1526/635_340/ef476_1526472.jpg"; y="2012" }
  @{ h="ic.i.tsatic-cdn.net"; p="1526/635_298/ea30e_1526467.jpg"; y="2012" }
  @{ h="ic.i.tsatic-cdn.net"; p="1526/635_335/cf23f_1526468.jpg"; y="2012" }
  @{ h="ic.i.tsatic-cdn.net"; p="1526/635_365/8d2cd_1526469.jpg"; y="2012" }
  @{ h="images.inthemix.com.au"; p="1734/1734654.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1734/1734655.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1734/1734656.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1734/1734657.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1734/1734658.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1734/1734659.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1569/1569508.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1569/1569456.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1569/1569462.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1569/1569467.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1569/1569514.jpg"; y="2016" }
  @{ h="images.inthemix.com.au"; p="1569/1569702.jpg"; y="2016" }
  @{ h="cdn.boilerroom.tv"; p="wp-content/uploads/2015/08/2006_Paco-980x653.jpg"; y="2016" }
  @{ h="cdn.boilerroom.tv"; p="wp-content/uploads/2015/08/2006_Club410.04.06-165x165.jpg"; y="2016" }
)

Write-Host ""
Write-Host ("Downloading {0} photographs." -f $imgs.Count) -ForegroundColor Cyan
$got = 0
foreach ($i in $imgs) {
  $url = "http://web.archive.org/web/$($i.y)id_/http://$($i.h)/$($i.p)"
  $rel = "recovered-external\" + $i.h + "\" + ($i.p -replace "/", "\")
  if (Get-One $url $rel ($i.h + "/" + $i.p)) { $got++ }
  Start-Sleep -Milliseconds 1500
}

# ---------------------------------------------------------------- the questions
# The Wayback CDX index can be filtered with a regular expression against the original
# address. inthemix and FasterLouder both put the headline in the URL, so asking for
# every archived address on those sites containing "nine inch" finds the review without
# knowing its article number.
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
function Cdx-Prefix($url, $lim) {
  return "http://web.archive.org/cdx/search/cdx?url=$url&matchType=prefix&fl=original,timestamp,statuscode&collapse=urlkey&limit=$lim&filter=statuscode:200"
}

$nine = "&filter=original:.*[Nn][Ii][Nn][Ee].?[Ii][Nn][Cc][Hh].*"

$hordern = "&filter=original:.*[Hh][Oo][Rr][Dd][Ee][Rr][Nn].*"

Ask-Cdx "itm-underworld"   (Cdx-Domain "inthemix.com.au"     "&filter=original:.*[Uu]nderworld.*") | Out-Null
Ask-Cdx "itm-nine"         (Cdx-Domain "inthemix.com.au"     $nine) | Out-Null
Ask-Cdx "fl-nine"          (Cdx-Domain "fasterlouder.com.au" $nine) | Out-Null
Ask-Cdx "itm-hordern"      (Cdx-Domain "inthemix.com.au"     $hordern) | Out-Null
Ask-Cdx "fl-hordern"       (Cdx-Domain "fasterlouder.com.au" $hordern) | Out-Null

# Nine Inch Nails played the Hordern twice: 16 September 2007 and 24 February 2009.
# These two sweeps list everything either site had archived in the months after each
# show, so the review can be spotted by its headline even if the word "nine" never
# appears in the address.
function Cdx-Window($site, $from, $to) {
  return "http://web.archive.org/cdx/search/cdx?url=$site&matchType=domain&fl=original,timestamp,statuscode&collapse=urlkey&limit=2000&filter=statuscode:200&from=$from&to=$to"
}
Ask-Cdx "itm-window-2007" (Cdx-Window "inthemix.com.au"     "20070916" "20071231") | Out-Null
Ask-Cdx "fl-window-2007"  (Cdx-Window "fasterlouder.com.au" "20070916" "20071231") | Out-Null
Ask-Cdx "itm-window-2009" (Cdx-Window "inthemix.com.au"     "20090224" "20090630") | Out-Null
Ask-Cdx "fl-window-2009"  (Cdx-Window "fasterlouder.com.au" "20090224" "20090630") | Out-Null

# Every archived page under either author profile. These are the indexes of his own
# published work, which is the shortest route to whatever else is missing.
$angyRows = New-Object System.Collections.Generic.List[string]
foreach ($u in @("inthemix.com.au/people/angy", "fasterlouder.com.au/people/angy",
                 "fasterlouder.com.au/profile/angy", "inthemix.com.au/profile/angy")) {
  $tag = ($u -replace "[^A-Za-z0-9]", "-")
  $r = Ask-Cdx ("author-" + $tag) (Cdx-Prefix $u 500)
  foreach ($x in $r) { $angyRows.Add($x) }
}

# ---------------------------------------------------------------- author index pages
Write-Host ""
Write-Host ("Downloading up to 90 archived author-index pages.") -ForegroundColor Cyan
$n = 0
foreach ($row in $angyRows) {
  if ($n -ge 90) { break }
  $sp = $row.IndexOf(" ")
  if ($sp -lt 1) { continue }
  $ts = $row.Substring(0, $sp)
  $orig = $row.Substring($sp + 1)
  # a filename that keeps the address readable and cannot collide
  $safe = ($orig -replace "^https?://", "" -replace "[^A-Za-z0-9]", "_")
  if ($safe.Length -gt 90) { $safe = $safe.Substring(0, 90) }
  $rel = "archived-pages\angy\" + $ts + "_" + $safe + ".html"
  Get-One ("http://web.archive.org/web/" + $ts + "id_/" + $orig) $rel ($ts + " " + $orig) | Out-Null
  $n++
  Start-Sleep -Milliseconds 1200
}

# ---------------------------------------------------------------- summary
Write-Host ""
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host ("Photographs: {0} of {1} now present in recovered-external\." -f $got, $imgs.Count)
if ($got -eq 0) {
  Write-Host "Nothing downloaded at all. That usually means no internet, or the" -ForegroundColor Red
  Write-Host "Wayback Machine is refusing requests. Tell Claude." -ForegroundColor Red
}
$angyCount = 0
if (Test-Path $angy) { $angyCount = (Get-ChildItem -LiteralPath $angy -Filter *.html -File | Measure-Object).Count }
Write-Host ("Author-index pages saved into archived-pages\angy\: {0}" -f $angyCount)
Write-Host ""
Write-Host "CSV files written beside this script:"
foreach ($f in (Get-ChildItem -LiteralPath $root -Filter "wayback-*.csv" -File | Sort-Object Name)) {
  $c = (Get-Content -LiteralPath $f.FullName | Measure-Object -Line).Lines - 1
  Write-Host ("  {0,-42} {1} rows" -f $f.Name, $c)
}
Write-Host ""
Write-Host "Tell Claude the photograph count, the author-index count, and that the"
Write-Host "CSV files are there."
Write-Host ""
