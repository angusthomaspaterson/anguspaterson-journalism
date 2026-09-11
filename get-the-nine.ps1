# ---------------------------------------------------------------------------
#  The nine that survived
#
#  The sweep found nine of the forty-two photographs still in the archive, all
#  at 635 pixels wide. The last script located them correctly but saved most of
#  them to the wrong filename, so only two actually landed. This just fetches
#  the nine, by exact address, into the right place. Two are already there and
#  will be skipped.
#
#  A minute, maybe two. Nothing else is touched.
#
#  It also clears up the stray file called "h" that the last run left in
#  recovered-external\ . That was a saving mistake, not a photograph.
# ---------------------------------------------------------------------------

$ErrorActionPreference = "Continue"
Set-Location -LiteralPath $PSScriptRoot
$base = Join-Path $PSScriptRoot "recovered-external\ic.i.tsatic-cdn.net"

$items = @(
  @{ rel = "1551/635_340/3d279_1551600.jpg"; stamp = "20121021174308" }
  @{ rel = "1551/635_420/5057a_1551605.jpg"; stamp = "20121021174258" }
  @{ rel = "1697/635_340/5f9a6_1697692.jpg"; stamp = "20131228182953" }
  @{ rel = "1569/635_423/08d3b_1569456.jpg"; stamp = "20121024071730" }
  @{ rel = "1569/635_423/72bbc_1569462.jpg"; stamp = "20121024071654" }
  @{ rel = "1569/635_423/5791f_1569467.jpg"; stamp = "20121024071736" }
  @{ rel = "1569/635_340/b9822_1569508.jpg"; stamp = "20121024071648" }
  @{ rel = "1569/635_423/ed017_1569514.jpg"; stamp = "20121024071658" }
  @{ rel = "1569/635_423/31439_1569702.jpg"; stamp = "20121024071709" }
)

$ok = 0; $skip = 0; $fail = 0
foreach ($it in $items) {
  $full = Join-Path $base ($it.rel -replace "/", "\")
  $dir  = Split-Path $full -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

  if ((Test-Path $full) -and ((Get-Item $full).Length -gt 5000)) {
    Write-Host ("  already here   " + $it.rel) -ForegroundColor DarkGray
    $skip++
    continue
  }
  $url = "http://web.archive.org/web/" + $it.stamp + "id_/http://ic.i.tsatic-cdn.net/" + $it.rel
  try {
    Invoke-WebRequest -Uri $url -OutFile $full -UseBasicParsing -TimeoutSec 120
    $len = (Get-Item $full).Length
    if ($len -lt 5000) {
      Remove-Item $full -Force
      Write-Host ("  too small      " + $it.rel) -ForegroundColor Yellow
      $fail++
    } else {
      Write-Host ("  saved {0,5} KB  {1}" -f [math]::Round($len/1KB), $it.rel) -ForegroundColor Green
      $ok++
    }
  } catch {
    if (Test-Path $full) { Remove-Item $full -Force }
    Write-Host ("  failed         " + $it.rel) -ForegroundColor Yellow
    $fail++
  }
  Start-Sleep -Milliseconds 1200
}

$stray = Join-Path $PSScriptRoot "recovered-external\h"
if (Test-Path $stray) { Remove-Item $stray -Force; Write-Host "" ; Write-Host "  removed the stray file 'h'" -ForegroundColor DarkGray }

Write-Host ""
Write-Host "-----------------------------------------------------------" -ForegroundColor Cyan
Write-Host ("Downloaded now:    {0}" -f $ok) -ForegroundColor Green
Write-Host ("Already in place:  {0}" -f $skip)
Write-Host ("Failed:            {0}" -f $fail)
$total = (Get-ChildItem -LiteralPath $base -Recurse -File | Measure-Object).Count
Write-Host ("Photographs under ic.i.tsatic-cdn.net: {0}" -f $total)
Write-Host ""
Write-Host "Tell Claude the count and he will wire them into the articles." -ForegroundColor Cyan
Write-Host ""
