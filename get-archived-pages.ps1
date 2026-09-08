# Pull down the twelve archived ARTICLE pages the hunt found.
#
# These are the pages themselves, not images: each one carries the image URLs as they
# stood on the day it was captured, which is how we find out what the photographs were
# actually called. Claude reads them and builds the final download list from what is in
# them. Nothing is published and no images are fetched here.
#
# The "id_" in each URL asks the Wayback Machine for the original page rather than its
# own rewritten copy, so the image URLs come through untouched.

$ErrorActionPreference = "Continue"

# Everything is written relative to THIS FILE, not to the working directory, so it lands
# beside the script whatever the shell thinks is current, elevated or not.
Set-Location -LiteralPath $PSScriptRoot
$dest = Join-Path $PSScriptRoot "archived-pages"
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

$pages = @(
  @{ name = "one-night-in-ibiza-p1"; url = "http://web.archive.org/web/20110629180344id_/http://www.inthemix.com.au/features/50400/One_night_in_Ibiza_Cream_Amnesia" }
  @{ name = "one-night-in-ibiza-p2"; url = "http://web.archive.org/web/20110702012624id_/http://www.inthemix.com.au/features/50400/One_night_in_Ibiza_Cream_Amnesia?page=2" }
  @{ name = "one-night-in-ibiza-p3"; url = "http://web.archive.org/web/20110702040100id_/http://www.inthemix.com.au/features/50400/One_night_in_Ibiza_Cream_Amnesia?page=3" }
  @{ name = "one-night-in-ibiza-p4"; url = "http://web.archive.org/web/20110702035956id_/http://www.inthemix.com.au/features/50400/One_night_in_Ibiza_Cream_Amnesia?page=4" }
  @{ name = "time-warp-mannheim-p1"; url = "http://web.archive.org/web/20120410023116id_/http://www.inthemix.com.au/features/52603/One_night_in_Mannheim_inthemix_goes_to_Time_Warp_2012" }
  @{ name = "time-warp-mannheim-p2"; url = "http://web.archive.org/web/20120414123320id_/http://www.inthemix.com.au/features/52603/One_night_in_Mannheim_inthemix_goes_to_Time_Warp_2012?page=2" }
  @{ name = "time-warp-mannheim-p3"; url = "http://web.archive.org/web/20120415041714id_/http://www.inthemix.com.au/features/52603/One_night_in_Mannheim_inthemix_goes_to_Time_Warp_2012?page=3" }
  @{ name = "time-warp-mannheim-p4"; url = "http://web.archive.org/web/20120415040215id_/http://www.inthemix.com.au/features/52603/One_night_in_Mannheim_inthemix_goes_to_Time_Warp_2012?page=4" }
  @{ name = "tomorrowland-2012"; url = "http://web.archive.org/web/20160609081128id_/http://inthemix.junkee.com/tomorrowland-2012-the-epic-review/17213" }
  @{ name = "riot-in-denmark-p1"; url = "http://web.archive.org/web/20151229055006id_/http://inthemix.junkee.com/riot-in-denmark-partying-hard-at-distortion-festival/24866" }
  @{ name = "riot-in-denmark-p2"; url = "http://web.archive.org/web/20151229032005id_/http://inthemix.junkee.com/riot-in-denmark-partying-hard-at-distortion-festival/24866/2" }
  @{ name = "paco-osuna"; url = "http://web.archive.org/web/20150829201415id_/http://boilerroom.tv/paco-osuna-barcelona/" }
)

$ok = 0
foreach ($p in $pages) {
  $out = Join-Path $dest ($p.name + ".html")
  if (Test-Path $out) { Write-Host "skip  $($p.name)"; $ok++; continue }
  try {
    Invoke-WebRequest -Uri $p.url -OutFile $out -UseBasicParsing -TimeoutSec 90
    $kb = [math]::Round((Get-Item $out).Length / 1KB)
    Write-Host ("ok    {0,-24} {1} KB" -f $p.name, $kb) -ForegroundColor Green
    $ok++
  } catch {
    Write-Host ("FAIL  {0,-24} {1}" -f $p.name, $_.Exception.Message) -ForegroundColor Yellow
    if (Test-Path $out) { Remove-Item $out -Force }
  }
  Start-Sleep -Seconds 4
}

Write-Host ""
Write-Host ("$ok of $($pages.Count) pages saved into archived-pages\") -ForegroundColor Green
Write-Host "Tell Claude they are there."
Write-Host ""
