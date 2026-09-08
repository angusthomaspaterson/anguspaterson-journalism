# Recover the images that survive in the Wayback Machine.
#
# RUN THIS FROM INSIDE THE REPOSITORY FOLDER, beside index.html. It writes into
# recovered-external\, which is where fifteen pages already look for these files.
# Double-click recover-wayback-images.bat rather than this file. Both files must
# sit in the repository folder, beside index.html.
#
# 25 files: 16 from the Wayback Machine, 9 straight from datatransmission.co, which
# moved off its WP Engine origin hostname but still serves the same uploads tree. It skips anything already downloaded, so running it
# twice is safe, and the Wayback Machine is slow: allow about a minute.

$ErrorActionPreference = "Continue"
# Everything below is written relative to THIS FILE, not to the working directory,
# so it lands in the repository whatever the shell happens to think is current.
Set-Location -LiteralPath $PSScriptRoot

$items = @(
  @{ url = "http://web.archive.org/web/20181219111831if_/http://images.inthemix.com.au/1691/1691068.jpg"; path = "recovered-external/images.inthemix.com.au/1691_1691068.jpg" }
  @{ url = "http://web.archive.org/web/20191105150806if_/http://images.inthemix.com.au/1691/1691069.jpg"; path = "recovered-external/images.inthemix.com.au/1691_1691069.jpg" }
  @{ url = "http://web.archive.org/web/20191105150820if_/http://images.inthemix.com.au/1691/1691070.jpg"; path = "recovered-external/images.inthemix.com.au/1691_1691070.jpg" }
  @{ url = "http://web.archive.org/web/20190614125105if_/http://www.ibiza-voice.com/media/news/2014/maxcooper/4D.jpg"; path = "recovered-external/www.ibiza-voice.com/4D.jpg" }
  @{ url = "http://web.archive.org/web/20190614130228if_/http://www.ibiza-voice.com/media/news/2014/maxcooper/human-artwork.jpg"; path = "recovered-external/www.ibiza-voice.com/human-artwork.jpg" }
  @{ url = "http://web.archive.org/web/20190614114537if_/http://www.ibiza-voice.com/media/news/2014/tommiesunshine/Tommie_Sunshine2.jpg"; path = "recovered-external/www.ibiza-voice.com/Tommie_Sunshine2.jpg" }
  @{ url = "http://web.archive.org/web/20190614121549if_/http://www.ibiza-voice.com/media/news/2014/tommiesunshine/Tommie_Sunshine3.jpg"; path = "recovered-external/www.ibiza-voice.com/Tommie_Sunshine3.jpg" }
  @{ url = "http://web.archive.org/web/20130605180157if_/http://www.ibiza-voice.com/media/news/news_2013/felixdahousecat/felix2.jpg"; path = "recovered-external/www.ibiza-voice.com/felix2.jpg" }
  @{ url = "http://web.archive.org/web/20190614123245if_/http://www.ibiza-voice.com/media/news/news_2013/jorisvoorn/Joris_Voorn2.jpg"; path = "recovered-external/www.ibiza-voice.com/Joris_Voorn2.jpg" }
  @{ url = "http://web.archive.org/web/20190614113033if_/http://www.ibiza-voice.com/media/news/news_2013/petardundov/Petar_Dundov_Studio.jpg"; path = "recovered-external/www.ibiza-voice.com/Petar_Dundov_Studio.jpg" }
  @{ url = "http://web.archive.org/web/20190614113206if_/http://www.ibiza-voice.com/media/news/news_2013/petardundov/Sailing_Off_The_Grid.jpg"; path = "recovered-external/www.ibiza-voice.com/Sailing_Off_The_Grid.jpg" }
  @{ url = "http://web.archive.org/web/20190614113213if_/http://www.ibiza-voice.com/media/news/news_2013/ripperton/A_little_part_of_his_shade.jpg"; path = "recovered-external/www.ibiza-voice.com/A_little_part_of_his_shade.jpg" }
  @{ url = "http://web.archive.org/web/20190614123314if_/http://www.ibiza-voice.com/media/news/news_2013/steve_bug/Steve-Bug2.jpg"; path = "recovered-external/www.ibiza-voice.com/Steve-Bug2.jpg" }
  @{ url = "http://web.archive.org/web/20190614113740if_/http://www.ibiza-voice.com/media/news/news_2013/steve_bug/pfrdd23.png"; path = "recovered-external/www.ibiza-voice.com/pfrdd23.png" }
  @{ url = "http://web.archive.org/web/20160513220518if_/https://vegaspoolseason.com/wp-content/uploads/2013/06/Highest-Paid-DJs.jpg"; path = "recovered-external/vegaspoolseason.com/Highest-Paid-DJs.jpg" }
  @{ url = "http://web.archive.org/web/20150924173842if_/https://cdn.boilerroom.tv/wp-content/uploads/2015/08/2012_Captura-de-pantalla-2015-08-26-a-las-11.31.12.png"; path = "recovered-external/cdn.boilerroom.tv/2012_Captura-de-pantalla-2015-08-26-a-las-11.31.12.png" }
  @{ url = "https://datatransmission.co/wp-content/uploads/2014/10/phuture-1.jpg"; path = "recovered-external/datatransmission.co/phuture-1.jpg" }
  @{ url = "https://datatransmission.co/wp-content/uploads/2014/10/phuture2-1.jpg"; path = "recovered-external/datatransmission.co/phuture2-1.jpg" }
  @{ url = "https://datatransmission.co/wp-content/uploads/2014/10/phuture3-1.jpg"; path = "recovered-external/datatransmission.co/phuture3-1.jpg" }
  @{ url = "https://datatransmission.co/wp-content/uploads/2014/10/phuture4-1.jpg"; path = "recovered-external/datatransmission.co/phuture4-1.jpg" }
  @{ url = "https://datatransmission.co/wp-content/uploads/2014/10/phutre5-1.jpg"; path = "recovered-external/datatransmission.co/phutre5-1.jpg" }
  @{ url = "https://datatransmission.co/wp-content/uploads/2014/10/phuture6-1.jpg"; path = "recovered-external/datatransmission.co/phuture6-1.jpg" }
  @{ url = "https://datatransmission.co/wp-content/uploads/2014/10/phutue1-1.jpg"; path = "recovered-external/datatransmission.co/phutue1-1.jpg" }
  @{ url = "https://datatransmission.co/wp-content/uploads/2013/12/adambeyer21.jpg"; path = "recovered-external/datatransmission.co/adambeyer21.jpg" }
  @{ url = "https://datatransmission.co/wp-content/uploads/2013/12/adambeyer31.jpg"; path = "recovered-external/datatransmission.co/adambeyer31.jpg" }
)

foreach ($i in $items) {
  $full = Join-Path $PSScriptRoot $i.path
  $dir = Split-Path $full -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  if (Test-Path $full) { Write-Host "skip  $($i.path)"; continue }
  try {
    Invoke-WebRequest -Uri $i.url -OutFile $full -UseBasicParsing -TimeoutSec 60
    Write-Host "ok    $($i.path)  ($((Get-Item $full).Length) bytes)"
  } catch {
    Write-Host "FAIL  $($i.path)  $($_.Exception.Message)"
  }
  Start-Sleep -Seconds 3
}

$root = Join-Path $PSScriptRoot "recovered-external"
$got  = @(Get-ChildItem -Path $root -Recurse -File -ErrorAction SilentlyContinue)
Write-Host ""
if ($got.Count -eq 0) {
  Write-Host "NOTHING WAS DOWNLOADED. Nothing was written to $root." -ForegroundColor Red
  Write-Host "That usually means no internet, or web.archive.org is refusing requests." -ForegroundColor Red
} else {
  Write-Host ("{0} of 25 images recovered, {1:N0} KB in total:" -f $got.Count, (($got | Measure-Object Length -Sum).Sum / 1KB)) -ForegroundColor Green
  foreach ($f in $got) {
    Write-Host ("  {0,9:N0} bytes  {1}" -f $f.Length, $f.FullName.Substring($PSScriptRoot.Length + 1))
  }
  if ($got.Count -lt 25) {
    Write-Host ""
    Write-Host ("{0} did not come down. Tell me which and I will take them out of the pages." -f (25 - $got.Count)) -ForegroundColor Yellow
  }
}
