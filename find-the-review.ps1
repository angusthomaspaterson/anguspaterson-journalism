# The Nine Inch Nails reviews exist. This fetches them, plus a few other pages the
# search turned up, and settles what is really left of the missing photographs.
#
#   1. Four candidate review pages: the Hordern on 16 September 2007 and again on
#      24 February 2009, each archived on both inthemix and FasterLouder. Claude reads
#      the bylines to see which are yours.
#   2. The original Underworld feature, so the transcription can be checked against the
#      published page rather than against a screenshot of it.
#   3. FasterLouder's own index of every Nine Inch Nails article, in case there is more.
#   4. For each photograph that did not come down last time, asks the Wayback index
#      whether it holds ANY capture of that file, at any date, and writes the answer to
#      wayback-image-check.csv. No more guessing at nearest years.
#
# Nothing is published. Existing files are skipped, so this is safe to re-run.

$ErrorActionPreference = "Continue"
Set-Location -LiteralPath $PSScriptRoot
$root = $PSScriptRoot
$dest = Join-Path $root "archived-pages\nine-inch-nails"
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

function Fetch($url, $full, $label) {
  if ((Test-Path $full) -and ((Get-Item $full).Length -gt 500)) { Write-Host "skip  $label"; return }
  try {
    Invoke-WebRequest -Uri $url -OutFile $full -UseBasicParsing -TimeoutSec 120
    $len = (Get-Item $full).Length
    if ($len -lt 500) { Remove-Item $full -Force; Write-Host ("EMPTY $label") -ForegroundColor Yellow; return }
    Write-Host ("ok    {0,-40} {1} KB" -f $label, [math]::Round($len/1KB)) -ForegroundColor Green
  } catch {
    Write-Host ("FAIL  {0,-40} {1}" -f $label, $_.Exception.Message) -ForegroundColor Yellow
    if (Test-Path $full) { Remove-Item $full -Force }
  }
}

$wanted = @(
  @{ n="itm-2007-hordern";   ts="20081021093938"; u="http://www.inthemix.com.au/events/reviews/34197/Nine_Inch_Nails_The_Hordern_Sydney_160907" }
  @{ n="itm-2009-hordern";   ts="20090308040332"; u="http://www.inthemix.com.au/events/reviews/41756/Nine_Inch_Nails_Hordern_Pavilion_Sydney_240209_" }
  @{ n="fl-2007-hordern";    ts="20071113233239"; u="http://www.fasterlouder.com.au/reviews/events/10559/Nine-Inch-Nails-The-Hordern-Sydney-160907.htm" }
  @{ n="fl-2009-hordern";    ts="20090302160703"; u="http://www.fasterlouder.com.au/reviews/events/17237/Nine-Inch-Nails--Hordern-Pavilion-Sydney-240209-.htm" }
  @{ n="fl-2009-hordern-b";  ts="20150314205309"; u="http://www.fasterlouder.com.au/reviews/events/17237/Nine-Inch-Nails-Hordern-Pavilion-Sydney-240209" }
  @{ n="fl-2009-melbourne";  ts="20090321205808"; u="http://www.fasterlouder.com.au/reviews/events/17223/Nine-Inch-Nails-Jaguar-Love--Festival-Hall-Melbourne-250209.htm" }
  @{ n="fl-nin-article-list";ts="20130808015945"; u="http://www.fasterlouder.com.au/allabout/artist/53/Nine-Inch-Nails/articles" }
  @{ n="itm-underworld-original"; ts="20071116164106"; u="http://www.inthemix.com.au/features/35004/Underworld_Back_from_underneath_the_radar" }
)

Write-Host ""
Write-Host "Fetching the pages the search found." -ForegroundColor Cyan
foreach ($w in $wanted) {
  Fetch ("http://web.archive.org/web/" + $w.ts + "id_/" + $w.u) `
        (Join-Path $dest ($w.n + ".html")) $w.n
  Start-Sleep -Milliseconds 1500
}

# ------------------------------------------------------- do these images exist at all
$missing = @(
  "http://ic.i.tsatic-cdn.net/1398/635_340/a2764_1398927.jpg"
  "http://ic.i.tsatic-cdn.net/1398/300_449/69900_1398924.jpg"
  "http://ic.i.tsatic-cdn.net/1398/300_200/5b573_1398920.jpg"
  "http://ic.i.tsatic-cdn.net/1398/300_200/d1dd9_1398923.jpg"
  "http://ic.i.tsatic-cdn.net/1398/300_449/3fa0b_1398926.jpg"
  "http://ic.i.tsatic-cdn.net/1526/635_340/ef476_1526472.jpg"
  "http://ic.i.tsatic-cdn.net/1526/635_298/ea30e_1526467.jpg"
  "http://ic.i.tsatic-cdn.net/1526/635_335/cf23f_1526468.jpg"
  "http://ic.i.tsatic-cdn.net/1526/635_365/8d2cd_1526469.jpg"
  "http://images.inthemix.com.au/1734/1734655.jpg"
  "http://images.inthemix.com.au/1734/1734656.jpg"
  "http://images.inthemix.com.au/1734/1734657.jpg"
  "http://images.inthemix.com.au/1734/1734658.jpg"
  "http://images.inthemix.com.au/1734/1734659.jpg"
  "http://images.inthemix.com.au/1569/1569508.jpg"
  "http://images.inthemix.com.au/1569/1569456.jpg"
  "http://images.inthemix.com.au/1569/1569462.jpg"
  "http://images.inthemix.com.au/1569/1569467.jpg"
  "http://images.inthemix.com.au/1569/1569514.jpg"
  "http://images.inthemix.com.au/1569/1569702.jpg"
)

Write-Host ""
Write-Host ("Checking whether the Wayback index holds any capture of the {0} images that failed." -f $missing.Count) -ForegroundColor Cyan
$csv = New-Object System.Collections.Generic.List[string]
$csv.Add("url,captures,best_timestamp,statuscode")
$have = 0
foreach ($u in $missing) {
  $q = "http://web.archive.org/cdx/search/cdx?url=" + [uri]::EscapeDataString($u) + "&fl=timestamp,statuscode&limit=20"
  try {
    $r = Invoke-WebRequest -Uri $q -UseBasicParsing -TimeoutSec 90
    $lines = ($r.Content -split "`n") | Where-Object { $_.Trim() -ne "" }
    if ($lines.Count -eq 0) {
      $csv.Add('"' + $u + '","0","",""')
      Write-Host ("  none  " + $u) -ForegroundColor DarkGray
    } else {
      $f = $lines[0].Trim() -split "\s+"
      $csv.Add('"' + $u + '","' + $lines.Count + '","' + $f[0] + '","' + $f[1] + '"')
      Write-Host ("  {0,-4} captures  {1}  {2}" -f $lines.Count, $f[0], $u) -ForegroundColor Green
      $have++
    }
  } catch {
    $csv.Add('"' + $u + '","error","",""')
    Write-Host ("  ERROR " + $u + "  " + $_.Exception.Message) -ForegroundColor Yellow
  }
  Start-Sleep -Milliseconds 900
}
$csv | Set-Content -LiteralPath (Join-Path $root "wayback-image-check.csv") -Encoding UTF8

Write-Host ""
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
$n = (Get-ChildItem -LiteralPath $dest -Filter *.html -File | Measure-Object).Count
Write-Host ("Pages saved into archived-pages\nine-inch-nails\: {0} of {1}" -f $n, $wanted.Count)
Write-Host ("Images with at least one archived capture: {0} of {1}" -f $have, $missing.Count)
Write-Host "Written: wayback-image-check.csv"
Write-Host ""
Write-Host "Tell Claude those two numbers."
Write-Host ""
