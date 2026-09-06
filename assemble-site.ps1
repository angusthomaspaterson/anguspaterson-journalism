# Assemble the archive repository.
# 1. Unzip site-html.zip into a folder (this becomes the repo). This script is inside it.
# 2. Unzip promos-bios-images.zip into the same folder.
# 3. Double-click assemble-site.bat, or run this script from inside that folder.
#
# The repository can live anywhere. The UpdraftPlus uploads and the videos stay
# outside it; the script looks for them and asks if it cannot find them.
#
# Two jobs:
#   a. copy the images the published pages reference, and nothing else
#   b. build a 700px copy of each under uploads/thumbs/ for the listing cards
#
# The cards are shown about 350px wide and cropped to 3:2. Pointing them at the full
# originals meant the All Work page, which now lists all 196 pieces on one page, would
# pull about 62 MB of photography if a reader scrolled the whole way down. The thumbs
# bring that under 10 MB. Images under uploads/new/ and their thumbs ship inside
# site-html.zip already: they came from the saved pages and the live publications,
# not from the WordPress backup.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

# The forty-one Promos & Bios images restored from the copywriting portfolio ship in
# their own zip, promos-bios-images.zip, because site-html.zip is already at the size
# limit. Unzip it into this folder and the files land in uploads\new\promos-bios.
$pb = Join-Path $PSScriptRoot "uploads\new\promos-bios"
$pbn = 0
if (Test-Path $pb) { $pbn = (Get-ChildItem -Recurse -File $pb).Count }
if ($pbn -lt 41) {
  Write-Host ""
  Write-Host "STOP: uploads\new\promos-bios holds $pbn of 41 images." -ForegroundColor Red
  Write-Host "Unzip promos-bios-images.zip into this folder, then run this script again." -ForegroundColor Red
  Write-Host "Without it the nine new Promos & Bios pieces publish with broken images."
  exit 1
}

# ---------------------------------------------------------------------------
# The two folders that stay outside the repository: the extracted UpdraftPlus
# uploads, and the twelve remuxed videos. The repository does not have to sit
# beside them. Leave these blank and the script looks in the obvious places and
# asks if it cannot find them. Fill them in to skip the looking.
$uploadsPath = ""     # ...\backup_2025-09-01-2005_..._-uploads\uploads
$videosPath  = ""     # ...\new-content\videos-web
# ---------------------------------------------------------------------------

# Where to look, nearest first. The repository's own neighbours come before the
# user folders, so a machine with the old side-by-side layout resolves instantly.
$searchRoots = @(
  (Split-Path $PSScriptRoot -Parent),
  (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent),
  "$env:USERPROFILE\Documents",
  "$env:USERPROFILE\Desktop",
  "$env:USERPROFILE\Downloads",
  "$env:USERPROFILE"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique

$sep = [System.IO.Path]::DirectorySeparatorChar
$repoRoot = (Resolve-Path $PSScriptRoot).Path.TrimEnd($sep)

function Outside-Repo($p) {
  $full = (Resolve-Path $p -ErrorAction SilentlyContinue)
  if (-not $full) { return $false }
  $full = $full.Path.TrimEnd($sep)
  return -not ($full -eq $repoRoot -or $full.StartsWith($repoRoot + $sep, [StringComparison]::OrdinalIgnoreCase))
}

function Find-Folder($name, $test) {
  foreach ($root in $searchRoots) {
    $hits = Get-ChildItem -Path $root -Directory -Recurse -Depth 4 -Filter $name -ErrorAction SilentlyContinue
    foreach ($h in $hits) {
      if ((Outside-Repo $h.FullName) -and (& $test $h.FullName)) { return $h.FullName }
    }
  }
  return $null
}

function Ask-For($what, $example, $test) {
  Write-Host ""
  Write-Host "I cannot find $what." -ForegroundColor Yellow
  Write-Host "In Explorer, open that folder, click the address bar, copy the path, paste it below."
  Write-Host "It looks like:  $example" -ForegroundColor DarkGray
  while ($true) {
    $p = (Read-Host "Path (or press Enter to skip)").Trim('"').Trim()
    if (-not $p) { return $null }
    if (-not (Outside-Repo $p)) {
      Write-Host "That is inside the repository. It has to be the folder outside it." -ForegroundColor Red
      continue
    }
    if (& $test $p) { return $p }
    Write-Host "That is not it. Nothing of the right shape is in there." -ForegroundColor Red
  }
}

# The uploads folder is the one with the year folders in it.
$isUploads = { param($p) (Test-Path $p) -and (Test-Path (Join-Path $p "2012")) -and (Test-Path (Join-Path $p "2014")) }
# The videos folder is the one with the mp4s in it.
$isVideos  = { param($p) (Test-Path $p) -and ((Get-ChildItem -Path $p -Filter *.mp4 -File -ErrorAction SilentlyContinue).Count -ge 1) }

$src = $uploadsPath
if (-not ($src -and (Outside-Repo $src) -and (& $isUploads $src))) {
  Write-Host "Looking for the UpdraftPlus uploads folder..." -ForegroundColor DarkGray
  $src = Find-Folder "uploads" $isUploads
}
if (-not $src) {
  $src = Ask-For "the extracted UpdraftPlus uploads folder" `
                 "C:\Users\You\...\backup_2025-09-01-2005_..._-uploads\uploads" $isUploads
}
if (-not $src) {
  Write-Host ""
  Write-Host "STOP: without that folder there are no images to copy." -ForegroundColor Red
  Write-Host "Extract the UpdraftPlus uploads backup, then run this again." -ForegroundColor Red
  exit 1
}
Write-Host "Uploads: $src" -ForegroundColor DarkGray

function New-Thumb($from, $to, $width) {
  $img = [System.Drawing.Image]::FromFile($from)
  try {
    if ($img.Width -le $width) { Copy-Item $from $to -Force; return }
    $h = [int][Math]::Round($img.Height * $width / $img.Width)
    $bmp = New-Object System.Drawing.Bitmap $width, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = "HighQualityBicubic"
    $g.DrawImage($img, 0, 0, $width, $h)
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
    $prm = New-Object System.Drawing.Imaging.EncoderParameters 1
    $prm.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 80
    $bmp.Save($to, $codec, $prm)
    $g.Dispose(); $bmp.Dispose()
  } finally { $img.Dispose() }
}

$files = @(
  "2010/10/hires-DMLMcoverDJMag4-724x1024.png"
  "2010/10/hires-DMLMcoverDJMag4.png"
  "2011/11/ITMfeatureIbiza.jpg"
  "2011/11/ITMfeaturePVD.jpg"
  "2011/11/ITMfeatureSasha.jpg"
  "2011/11/ITMnews3am.jpg"
  "2011/11/ITMnewsLawler.jpg"
  "2011/11/ITMreviewAB.jpg"
  "2011/11/ITMreviewPendulum.jpg"
  "2011/11/ITMreviewWOW.jpg"
  "2011/11/PrintFeatureSpaceInvadas3-737x1024.jpg"
  "2011/11/PrintFeatureSpaceInvadas3.jpg"
  "2011/11/Spotify_DJBADE_1.jpg"
  "2011/11/Spotify_DJBADE_11.jpg"
  "2011/11/desyn-article1-737x1024.jpg"
  "2011/11/desyn-article1.jpg"
  "2011/11/joris-voorn-article1-737x1024.jpg"
  "2011/11/joris-voorn-article1.jpg"
  "2011/11/king-unique-article1-737x1024.jpg"
  "2011/11/king-unique-article1.jpg"
  "2011/12/ITMfeatureDigweed.jpg"
  "2011/12/ITMfeatureTranceChance3.jpg"
  "2011/12/ITMfeatureVoorn.jpg"
  "2011/12/ITMfeatureWink2.jpg"
  "2011/12/ITMnewsDaftPunk.jpg"
  "2011/12/ITMnewsaskewlogo.jpg"
  "2011/12/ITMnewsdubfire.jpg"
  "2011/12/ITMnewsparklife.jpg"
  "2011/12/ITMnewsprydzlogo2.jpg"
  "2011/12/ITMreviewAnjuna93.jpg"
  "2011/12/ITMreviewBerlin.jpg"
  "2011/12/ITMreviewCutCopy.jpg"
  "2011/12/ITMreviewDeepchild2.jpg"
  "2011/12/ITMreviewLeftfield.jpg"
  "2011/12/ITMreviewStantons.jpg"
  "2011/12/ITMreviewVincenzo.jpg"
  "2011/12/ITMreviewVincenzo1.jpg"
  "2011/12/ITMreviewWarren.jpg"
  "2011/12/avb-737x1024.jpg"
  "2011/12/avb-spread1-737x1024.jpg"
  "2011/12/avb-spread1.jpg"
  "2011/12/avb-spread2-737x1024.jpg"
  "2011/12/avb-spread2.jpg"
  "2011/12/avb-spread3-737x1024.jpg"
  "2011/12/avb-spread3.jpg"
  "2011/12/avb.jpg"
  "2011/12/home-grown-cover-737x1024.jpg"
  "2011/12/home-grown-cover.jpg"
  "2011/12/home-grown-spread1-737x1024.jpg"
  "2011/12/home-grown-spread1.jpg"
  "2011/12/home-grown-spread2-737x1024.jpg"
  "2011/12/home-grown-spread2.jpg"
  "2011/12/home-grown-spread3-737x1024.jpg"
  "2011/12/home-grown-spread3.jpg"
  "2011/12/trentemoller-cover-737x1024.jpg"
  "2011/12/trentemoller-cover1.jpg"
  "2011/12/trentemoller-spread1-737x1024.jpg"
  "2011/12/trentemoller-spread2-737x1024.jpg"
  "2011/12/trentemoller-spread2.jpg"
  "2011/12/trentemoller-spread3-737x1024.jpg"
  "2011/12/trentemoller-spread3.jpg"
  "2012/03/Corker_cover-759x1024.jpg"
  "2012/03/Corker_cover.jpg"
  "2012/03/Corker_page1.jpg"
  "2012/03/PrintFeatureUNKLE1-737x1024.jpg"
  "2012/03/PrintFeatureUNKLE1.jpg"
  "2012/07/Corker_page2_reduced.jpg"
  "2012/07/Corker_page3_reduced-768x1024.jpg"
  "2012/07/Corker_page3_reduced.jpg"
  "2012/07/Corker_page4_reduced-768x1024.jpg"
  "2012/07/Corker_page4_reduced.jpg"
  "2012/07/ITMeventAboveBeyond.jpg"
  "2012/07/ITMeventDefqon1.jpg"
  "2012/07/ITMeventSonar.jpg"
  "2012/07/ITMeventTemplate.jpg"
  "2012/07/ITMeventTimeWarp.jpg"
  "2012/07/ITMfeatureAmerica.jpg"
  "2012/07/ITMreviewPryda.jpg"
  "2012/07/time-warp-2012.jpg"
  "2012/09/PVD1-724x1024.jpg"
  "2012/09/PVD1.jpg"
  "2012/09/PVD2-712x1024.jpg"
  "2012/09/PVD2.jpg"
  "2012/09/PVDtitle-724x1024.jpg"
  "2012/09/PVDtitle.jpg"
  "2012/10/AnomiePromo-723x1024.jpg"
  "2012/10/AnomiePromo.jpg"
  "2012/10/ITMeventUnderground.jpg"
  "2012/10/ITMnewsDeepchild.jpg"
  "2012/10/ITMnewsKingUnique.jpg"
  "2012/10/Musica_new1-899x1024.jpg"
  "2012/10/Musica_new1.jpg"
  "2012/10/Musica_new2.jpg"
  "2012/10/WesternSyntheticsPromo-724x1024.jpg"
  "2012/10/WesternSyntheticsPromo.jpg"
  "2012/10/promo-bio1.jpg"
  "2013/02/ITMeventGamble.jpg"
  "2013/02/ITMnewsCasino.jpg"
  "2013/02/ITMnewsDubfireADE.jpg"
  "2013/02/ITMnewsHawtin.jpg"
  "2013/08/DTreviewJozif2.jpg"
  "2013/08/TiestoDJMag1-723x1024.jpg"
  "2013/08/TiestoDJMag1.jpg"
  "2013/08/TiestoDJMag2-729x1024.jpg"
  "2013/08/TiestoDJMag2.jpg"
  "2013/08/TiestoDJMag3-723x1024.jpg"
  "2013/08/TiestoDJMag3.jpg"
  "2013/08/TiestoDJMagCover-729x1024.jpg"
  "2013/08/TiestoDJMagCover.jpg"
  "2013/09/BTDJMag1-673x1024.jpg"
  "2013/09/BTDJMag1.jpg"
  "2013/09/BTDJMag2-673x1024.jpg"
  "2013/09/BTDJMag2.jpg"
  "2013/09/BTDJMag3-673x1024.jpg"
  "2013/09/BTDJMag3.jpg"
  "2013/09/DTreviewApollonia.jpg"
  "2013/09/DTreviewRandweg.jpg"
  "2014/05/DJ-Mag-column-5331-732x1024.jpg"
  "2014/05/DJ-Mag-column-5331.jpg"
  "2014/05/DJ-Mag-column-copy.jpg"
  "2014/05/Grum-DJ-Mag-interview-1-742x1024.jpg"
  "2014/05/Grum-DJ-Mag-interview-1.jpg"
  "2014/05/Grum-DJ-Mag-interview-2-740x1024.jpg"
  "2014/05/Grum-DJ-Mag-interview-2.jpg"
  "2014/07/DJ-Mag-electro-progressive-reviews-June-20141-727x1024.jpg"
  "2014/07/DJ-Mag-electro-progressive-reviews-June-20141.jpg"
  "2014/08/DJ-Mag-electro-progressive-reviews-July-20142-737x1024.jpg"
  "2014/08/DJ-Mag-electro-progressive-reviews-July-20142.jpg"
  "2014/09/DJ-Mag-electro-progressive-reviews-September-2014-731x1024.jpg"
  "2014/09/DJ-Mag-electro-progressive-reviews-September-2014.jpg"
  "2014/10/DJ-Mag-electro-progressive-reviews-October-2014-732x1024.jpg"
  "2014/10/DJ-Mag-electro-progressive-reviews-October-2014.jpg"
  "2014/10/Spotify_DJBstory_cover.jpg"
  "2014/11/Hardwell-Top-100-1-721x1024.jpg"
  "2014/11/Hardwell-Top-100-1.jpg"
  "2014/11/Hardwell-Top-100-2-734x1024.jpg"
  "2014/11/Hardwell-Top-100-2.jpg"
  "2014/11/Hardwell-cover-lo-res.png"
  "2014/12/DJ-Mag-electro-progressive-reviews-November-2014-733x1024.jpg"
  "2014/12/DJ-Mag-electro-progressive-reviews-November-2014.jpg"
  "2015/01/DJ-Mag-electro-progressive-reviews-January-2014-732x1024.jpg"
  "2015/01/DJ-Mag-electro-progressive-reviews-January-2014.jpg"
  "2015/04/DJ-Mag-electro-progressive-reviews-March-2015-733x1024.jpg"
  "2015/04/DJ-Mag-electro-progressive-reviews-March-2015.jpg"
  "2015/05/Eastern-Bloc-Party.png"
  "2015/08/Anja1-724x1024.jpg"
  "2015/08/Anja1.jpg"
  "2015/08/Anja2-724x1024.jpg"
  "2015/08/Anja2.jpg"
  "2015/08/Anja3-724x1024.jpg"
  "2015/08/Anja3.jpg"
  "2015/08/Anja4-730x1024.jpg"
  "2015/08/Anja4.jpg"
  "2015/08/Anja5-724x1024.jpg"
  "2015/08/Anja5.jpg"
  "2015/08/Anja6-714x1024.jpg"
  "2015/08/Anja6.jpg"
  "2016/04/DJ-Mag-electro-progressive--747x1024.jpg"
  "2016/04/DJ-Mag-electro-progressive-.jpg"
  "2016/04/clubsterben-5-point-plan-copy-1020x564.png"
  "2016/04/ipse_berlin-1020x680.jpeg"
  "2016/04/lutz-1020x574.jpg"
  "2016/04/watergate-club-berlin-1020x.jpg"
  "2016/07/DJ-Mag-electro-progressive-reviews-559-702x1024.jpg"
  "2016/07/DJ-Mag-electro-progressive-reviews-559.jpg"
  "2016/08/DJ-Mag-electro-progressive--724x1024.jpg"
  "2016/08/DJ-Mag-electro-progressive-.jpg"
  "2016/09/DJ-Mag-electro-progressive-reviews-561-724x1024.jpg"
  "2016/09/DJ-Mag-electro-progressive-reviews-561.jpg"
  "2016/10/DMLMcoverDJMag1.png"
  "2016/12/DJ-Mag-electro-progressive-562-677x1024.jpg"
  "2016/12/DJ-Mag-electro-progressive-562.jpg"
  "2016/12/DJ-Mag-electro-progressive-reviews-562-724x1024.jpg"
  "2016/12/DJ-Mag-electro-progressive-reviews-562.jpg"
  "2017/01/DJ-Mag-electro-progressive-565-1.jpg"
  "2017/01/DJ-Mag-electro-progressive-565-676x1024.jpg"
  "2017/01/DJ-Mag-electro-progressive-565.jpg"
  "2017/01/dundov_screen-5.jpg"
  "2017/01/felix_screen.jpg"
  "2017/01/sunshine_screen.jpg"
  "2017/02/2017-02-16.jpg"
  "2017/02/Cinthie-1024x577-1024x577.jpg"
  "2017/02/DJ-Mag-electro-progressive-reviews-566-705x1024.jpg"
  "2017/02/DJ-Mag-electro-progressive-reviews-566.jpg"
  "2017/02/Handwerk_Audio_Studio_1200-v2-1024x578-1024x578.jpg"
  "2017/02/berlinstudio-screenshot.jpg"
  "2017/02/cinthie-1024x577.jpg"
  "2017/02/druglaws_screenshot.jpg"
  "2017/02/drugsfeature_rosannabach-1020x680.jpeg"
  "2017/02/easternbloc_screen.jpg"
  "2017/02/endurance_screen.jpg"
  "2017/02/eric-prydz-2016-billboard-1548.jpg"
  "2017/02/gatekeeper_screen.jpg"
  "2017/02/handwerk_audio_studio_1200-v2-1024x578-1024x578.jpg"
  "2017/02/keith_reilly.jpeg"
  "2017/02/tommie-sunshine-at-the-lizard-lounge-featured-1.jpg"
  "2017/03/1713803.jpg"
  "2017/03/2017-03-07.png"
  "2017/03/Atonal-Berlin-review-DJ-Mag-1-724x1024.jpg"
  "2017/03/Atonal-Berlin-review-DJ-Mag-1.jpg"
  "2017/03/Atonal-Berlin-review-DJ-Mag-2-724x1024.jpg"
  "2017/03/Atonal-Berlin-review-DJ-Mag-2.jpg"
  "2017/03/DJ-Mag-electro-progressive-reviews-567-705x1024.jpg"
  "2017/03/DJ-Mag-electro-progressive-reviews-567.jpg"
  "2017/03/corsten.jpg"
  "2017/03/kraviz-screen.jpg"
  "2017/04/1686802.jpg"
  "2017/04/1686803.jpg"
  "2017/04/1686804.jpg"
  "2017/04/1686805.jpg"
  "2017/04/1686806.jpg"
  "2017/04/1686807.jpg"
  "2017/04/1686808.jpg"
  "2017/04/2017-04-08-1.png"
  "2017/04/2017-04-08-2.png"
  "2017/04/2017-04-08.png"
  "2017/04/Anja-Schneider.jpg"
  "2017/04/Cocoon-Ibiza-interview-1-720x1024.jpg"
  "2017/04/Cocoon-Ibiza-interview-1.jpg"
  "2017/04/Cocoon-Ibiza-interview-2-743x1024.jpg"
  "2017/04/Cocoon-Ibiza-interview-2.jpg"
  "2017/04/DJ-Mag-Faithless-1-2-870x1024.jpg"
  "2017/04/DJ-Mag-Faithless-1-2.jpg"
  "2017/04/DJ-Mag-Faithless-1.jpg"
  "2017/04/DJ-Mag-Faithless-2-2-805x1024.jpg"
  "2017/04/DJ-Mag-Faithless-2-2.jpg"
  "2017/04/DJBroadcast-CultureBox-1-795x1024.jpg"
  "2017/04/DJBroadcast-CultureBox-1.jpg"
  "2017/04/DJBroadcast-CultureBox-2-670x1024.jpg"
  "2017/04/DJBroadcast-CultureBox-2.jpg"
  "2017/04/DJBroadcast-CultureBox-3-679x1024.jpg"
  "2017/04/DJBroadcast-CultureBox-3.jpg"
  "2017/04/DJBroadcast-CultureBox-4-795x1024.jpg"
  "2017/04/DJBroadcast-CultureBox-4.jpg"
  "2017/04/DJBroadcast-CultureBox-5-795x1024.jpg"
  "2017/04/DJBroadcast-CultureBox-5.jpg"
  "2017/04/DJBroadcast-CultureBox-6-679x1024.jpg"
  "2017/04/DJBroadcast-CultureBox-6.jpg"
  "2017/04/Groove-1.jpg"
  "2017/04/PainoBabylon_009-1024x720.jpg"
  "2017/04/PainoBabylon_009.jpg"
  "2017/04/PainoBabylon_013-1024x683.jpg"
  "2017/04/PainoBabylon_013.jpg"
  "2017/04/PainoBabylon_014-1024x708.jpg"
  "2017/04/PainoBabylon_014.jpg"
  "2017/04/PainoBabylon_018.jpg"
  "2017/04/Screen-Shot-2017-04-11-at-11.43.32-am.png"
  "2017/04/Screen-Shot-2017-04-11-at-12.02.08-pm.png"
  "2017/04/Screen-Shot-2017-04-11-at-12.09.38-pm.png"
  "2017/04/Screen-Shot-2017-04-11-at-5.14.22-pm.png"
  "2017/04/denmark-feature-image.jpg"
  "2017/04/djmag-3.jpg"
  "2017/04/electro-progressive-reviews-568-677x1024.jpg"
  "2017/04/electro-progressive-reviews-568.jpg"
  "2017/04/vegas.jpg"
  "2017/05/electro-progressive-reviews-569-1-678x1024.jpg"
  "2017/05/electro-progressive-reviews-569-1.jpg"
  "2017/06/electro-progressive-reviews-570-704x1024.jpg"
  "2017/06/electro-progressive-reviews-570.jpg"
  "2017/07/2017-07-11-3.png"
  "2017/07/2017-07-11-4.png"
  "2017/07/2017-07-11-6.png"
  "2017/07/electro-progressive-reviews-571-724x1024.jpg"
  "2017/07/electro-progressive-reviews-571.jpg"
  "2017/08/electro-progressive-reviews-572-726x1024.jpg"
  "2017/08/electro-progressive-reviews-572.jpg"
  "2017/09/Iceland-feature-1-726x1024.jpg"
  "2017/09/Iceland-feature-1.jpg"
  "2017/09/Iceland-feature-10-770x1024.jpg"
  "2017/09/Iceland-feature-10.jpg"
  "2017/09/Iceland-feature-11-737x1024.jpg"
  "2017/09/Iceland-feature-11.jpg"
  "2017/09/Iceland-feature-12-762x1024.jpg"
  "2017/09/Iceland-feature-12.jpg"
  "2017/09/Iceland-feature-13-753x1024.jpg"
  "2017/09/Iceland-feature-13.jpg"
  "2017/09/Iceland-feature-14-686x1024.jpg"
  "2017/09/Iceland-feature-14.jpg"
  "2017/09/Iceland-feature-15-780x1024.jpg"
  "2017/09/Iceland-feature-15.jpg"
  "2017/09/Iceland-feature-2-738x1024.jpg"
  "2017/09/Iceland-feature-2.jpg"
  "2017/09/Iceland-feature-3-754x1024.jpg"
  "2017/09/Iceland-feature-3.jpg"
  "2017/09/Iceland-feature-4-748x1024.jpg"
  "2017/09/Iceland-feature-4.jpg"
  "2017/09/Iceland-feature-5-765x1024.jpg"
  "2017/09/Iceland-feature-5.jpg"
  "2017/09/Iceland-feature-6-733x1024.jpg"
  "2017/09/Iceland-feature-6.jpg"
  "2017/09/Iceland-feature-7-703x1024.jpg"
  "2017/09/Iceland-feature-7.jpg"
  "2017/09/Iceland-feature-8-589x1024.jpg"
  "2017/09/Iceland-feature-8.jpg"
  "2017/09/Iceland-feature-9-743x1024.jpg"
  "2017/09/Iceland-feature-9.jpg"
  "2017/09/electro-progressive-reviews-573-725x1024.jpg"
  "2017/09/electro-progressive-reviews-573.jpg"
  "2017/10/electro-progressive-reviews-574-723x1024.jpg"
  "2017/10/electro-progressive-reviews-574.jpg"
  "2017/11/progressive-bigroom-reviews-575-719x1024.jpg"
  "2017/11/progressive-bigroom-reviews-575.jpg"
  "2018/01/bug_screen.jpg"
  "2018/01/capriati_screen.jpg"
  "2018/01/cooper_screen.jpg"
  "2018/01/deetron_screen.jpg"
  "2018/01/ripperton_screen.jpg"
  "2018/01/voorn_screen.jpg"
  "2018/03/progressive-bigroom-reviews-579-726x1024.jpg"
  "2018/03/progressive-bigroom-reviews-579.jpg"
  "2018/05/progressive-bigroom-reviews-580-725x1024.jpg"
  "2018/05/progressive-bigroom-reviews-580.jpg"
  "2018/05/progressive-bigroom-reviews-581-734x1024.jpg"
  "2018/05/progressive-bigroom-reviews-581.jpg"
  "2018/06/progressive-bigroom-reviews-582-725x1024.jpg"
  "2018/06/progressive-bigroom-reviews-582.jpg"
  "2018/08/progressive-bigroom-reviews-584-725x1024.jpg"
  "2018/08/progressive-bigroom-reviews-584.jpg"
  "2018/09/DJ-Mag-Christian-Loffler-interview-726x1024.jpg"
  "2018/09/DJ-Mag-Christian-Loffler-interview.jpg"
  "2018/11/Icarus-1-725x1024.jpg"
  "2018/11/Icarus-1.jpg"
  "2018/11/Icarus-2-725x1024.jpg"
  "2018/11/Icarus-2.jpg"
  "2018/11/Icarus-3-725x1024.jpg"
  "2018/11/Icarus-3.jpg"
  "2018/11/Icarus-4-725x1024.jpg"
  "2018/11/Icarus-4.jpg"
  "2019/01/Tiga-1-788x1024.jpg"
  "2019/01/Tiga-1.jpg"
  "2019/01/Tiga-2-788x1024.jpg"
  "2019/01/Tiga-2.jpg"
  "2019/01/Tiga-3-788x1024.jpg"
  "2019/01/Tiga-3.jpg"
  "2019/04/progressive-bigroom-reviews-592-721x1024.jpg"
  "2019/04/progressive-bigroom-reviews-592.jpg"
  "2020/10/hires-DMLMcoverDJMag2-724x1024.png"
  "2020/10/hires-DMLMcoverDJMag2.png"
)

$copied = 0; $thumbed = 0; $missing = @()
foreach ($f in $files) {
  $from = Join-Path $src $f
  $rel  = $f -replace '/','\'
  $to   = Join-Path $PSScriptRoot "uploads\$rel"
  if (-not (Test-Path $from)) { $missing += $f; continue }
  $dir = Split-Path $to -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  if ($from -ne $to) { Copy-Item $from $to -Force }
  $copied++

  $tt = Join-Path $PSScriptRoot "uploads\thumbs\$rel"
  $tdir = Split-Path $tt -Parent
  if (-not (Test-Path $tdir)) { New-Item -ItemType Directory -Path $tdir -Force | Out-Null }
  try { New-Thumb $from $tt 700; $thumbed++ } catch { Copy-Item $from $tt -Force }
}
Write-Host "copied $copied of $($files.Count) images, built $thumbed thumbnails"
if ($missing.Count) { Write-Host "MISSING:" -ForegroundColor Red; $missing | ForEach-Object { Write-Host "  $_" } }
# the 2026 images ship with the zip; their thumbs are built here rather than shipped,
# to keep the download under the size limit
$newRoot = Join-Path $PSScriptRoot "uploads\new"
$new = Get-ChildItem -Recurse -File $newRoot -ErrorAction SilentlyContinue
$nt = 0
foreach ($img in $new) {
  $rel = $img.FullName.Substring($newRoot.Length).TrimStart('\')
  $tt  = Join-Path $PSScriptRoot "uploads\thumbs\new\$rel"
  $tdir = Split-Path $tt -Parent
  if (-not (Test-Path $tdir)) { New-Item -ItemType Directory -Path $tdir -Force | Out-Null }
  try { New-Thumb $img.FullName $tt 700; $nt++ } catch { Copy-Item $img.FullName $tt -Force }
}
Write-Host "$($new.Count) images already in place under uploads/new, $nt thumbnails built for them"

# The twelve interview videos. They live outside the repo until now because they are
# large; the copies in new-content\videos-web are the ones remuxed to stream on click
# (the moov atom at the front) rather than the HandBrake exports, which download in
# full before they play.
$vsrc = $videosPath
if (-not ($vsrc -and (Outside-Repo $vsrc) -and (& $isVideos $vsrc))) {
  Write-Host "Looking for the videos folder..." -ForegroundColor DarkGray
  $vsrc = Find-Folder "videos-web" $isVideos
}
if (-not $vsrc) {
  $vsrc = Ask-For "the folder holding the twelve remuxed videos" `
                  "C:\Users\You\...\new-content\videos-web" $isVideos
}
$vdst = Join-Path $PSScriptRoot "videos"
if ($vsrc -and (Test-Path $vsrc)) {
  if (-not (Test-Path $vdst)) { New-Item -ItemType Directory -Path $vdst -Force | Out-Null }
  $vids = Get-ChildItem -File "$vsrc\*.mp4"
  foreach ($v in $vids) { Copy-Item $v.FullName (Join-Path $vdst $v.Name) -Force }
  $mb = [math]::Round((($vids | Measure-Object Length -Sum).Sum / 1MB), 0)
  Write-Host "copied $($vids.Count) videos, $mb MB"
} else {
  Write-Host "No videos copied - the twelve video pages will have nothing to play." -ForegroundColor Yellow
  Write-Host "Everything else is fine. Find the folder and run this again to add them." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Open index.html to check it, then commit the folder." -ForegroundColor Green
