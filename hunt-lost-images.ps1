# Hunt for the images the first recovery pass could not find.
#
# The first pass asked the Wayback Machine one question per image: "is this exact URL
# archived?" and took NOT_ARCHIVED for an answer. It never asked the three questions
# that actually matter for inthemix, which changed hostname twice:
#
#   1. Is the ARTICLE page archived, at any of the hostnames it lived under? An archived
#      page carries the image URLs as they were on the day of capture, which for the
#      Junkee era is a different image host entirely.
#   2. Is anything in the image DIRECTORY archived? A miss on one filename says nothing
#      about its neighbours.
#   3. Do the http / https and www / bare variants differ? The index treats them as
#      separate URLs.
#
# This script only ASKS. It downloads nothing and changes nothing. It writes
# wayback-hunt.csv; send that back and I will turn the hits into actual images.
#
# It makes a few hundred requests with a pause between each, so allow ten minutes.

$ErrorActionPreference = "Continue"
# Everything below is written relative to THIS FILE, not to the working directory,
# so it lands in the repository whatever the shell happens to think is current.
Set-Location -LiteralPath $PSScriptRoot

$out = Join-Path $PSScriptRoot "wayback-hunt.csv"
$rows = @()

function Ask($what, $url, $match) {
  $q = "http://web.archive.org/cdx/search/cdx?url=" + [uri]::EscapeDataString($url) +
       "&output=json&limit=20&collapse=digest&fl=timestamp,original,statuscode"
  if ($match) { $q += "&matchType=" + $match }
  try {
    $r = Invoke-RestMethod -Uri $q -TimeoutSec 45
    if ($r -and $r.Count -gt 1) {
      foreach ($row in $r[1..($r.Count-1)]) {
        $script:rows += [pscustomobject]@{
          kind = $what; query = $url; timestamp = $row[0]; found = $row[1]; status = $row[2]
        }
      }
      Write-Host ("  {0,-4} {1}" -f ($r.Count-1), $url) -ForegroundColor Green
    } else {
      Write-Host ("  {0,-4} {1}" -f "-", $url) -ForegroundColor DarkGray
    }
  } catch {
    Write-Host ("  ERR  {0}  {1}" -f $url, $_.Exception.Message) -ForegroundColor Yellow
  }
  Start-Sleep -Milliseconds 900
}

Write-Host "1. The article pages, at every hostname inthemix used" -ForegroundColor Cyan

Write-Host "   one-night-in-ibiza-cream-amnesia"
Ask "article" "http://inthemix.junkee.com/*/50400" ""
Ask "article" "http://www.inthemix.com.au/features/50400/" "prefix"
Ask "article" "http://www.inthemix.com.au/features/50400/One_night_in_Ibiza_Cream_Amnesia" ""

Write-Host "   sonar-festival-2012-inthemix-goes-to-barcelona"
Ask "article" "http://angusthomaspaterson.com/?p=726" ""

Write-Host "   one-night-in-mannheim-inthemix-goes-to-time-warp-2012"
Ask "article" "http://inthemix.junkee.com/*/52603" ""
Ask "article" "http://www.inthemix.com.au/features/52603/" "prefix"
Ask "article" "http://www.inthemix.com.au/features/52603/One_night_in_Mannheim_inthemix_goes_to_Time_Warp_2012" ""

Write-Host "   tomorrowland-2012-the-epic-review"
Ask "article" "http://inthemix.com.au/features/17213/" "prefix"
Ask "article" "http://inthemix.junkee.com/tomorrowland-2012-the-epic-review" "prefix"
Ask "article" "http://inthemix.junkee.com/tomorrowland-2012-the-epic-review/17213/3" ""
Ask "article" "http://junkee.com/tomorrowland-2012-the-epic-review" "prefix"
Ask "article" "http://www.inthemix.com.au/features/17213/" "prefix"

Write-Host "   deetron-i-evolved-over-the-years-to-working-with-so-many-vocalists"
Ask "article" "http://angusthomaspaterson.com/?p=1203" ""

Write-Host "   joseph-capriatis-self-portrait-i-wanted-to-create-the-music-that-is-inside-of-me"
Ask "article" "http://angusthomaspaterson.com/?p=1200" ""

Write-Host "   its-the-most-advanced-flipped-out-show-so-far-talking-epic-3-0-with-eric-prydz"
Ask "article" "http://inthemix.com.au/features/25024/" "prefix"
Ask "article" "http://inthemix.junkee.com/its-the-most-advanced-flipped-out-show-so-far-talking-epic-3-0-with-eric-prydz" "prefix"
Ask "article" "http://inthemix.junkee.com/its-the-most-advanced-flipped-out-show-so-far-talking-epic-3-0-with-eric-prydz/25024" ""
Ask "article" "http://junkee.com/its-the-most-advanced-flipped-out-show-so-far-talking-epic-3-0-with-eric-prydz" "prefix"
Ask "article" "http://www.inthemix.com.au/features/25024/" "prefix"

Write-Host "   paco-osuna-from-barcelona-to-ibiza"
Ask "article" "https://boilerroom.tv/paco-osuna-barcelona/" ""

Write-Host "   inside-a-winter-weekend-partying-in-helsinki-londons-clubbing-cousin"
Ask "article" "http://inthemix.com.au/features/22142/" "prefix"
Ask "article" "http://inthemix.junkee.com/inside-a-winter-weekend-partying-in-helsinki-londons-clubbing-cousin" "prefix"
Ask "article" "http://inthemix.junkee.com/inside-a-winter-weekend-partying-in-helsinki-londons-clubbing-cousin/22142" ""
Ask "article" "http://junkee.com/inside-a-winter-weekend-partying-in-helsinki-londons-clubbing-cousin" "prefix"
Ask "article" "http://www.inthemix.com.au/features/22142/" "prefix"

Write-Host "   the-inthemix-guide-to-amsterdam"
Ask "article" "http://inthemix.com.au/features/21078/" "prefix"
Ask "article" "http://inthemix.junkee.com/the-inthemix-guide-to-amsterdam" "prefix"
Ask "article" "http://inthemix.junkee.com/the-inthemix-guide-to-amsterdam/21078" ""
Ask "article" "http://junkee.com/the-inthemix-guide-to-amsterdam" "prefix"
Ask "article" "http://www.inthemix.com.au/features/21078/" "prefix"

Write-Host "   riot-in-denmark-distortion-festival"
Ask "article" "http://inthemix.com.au/features/24866/" "prefix"
Ask "article" "http://inthemix.junkee.com/riot-in-denmark-partying-hard-at-distortion-festival" "prefix"
Ask "article" "http://inthemix.junkee.com/riot-in-denmark-partying-hard-at-distortion-festival/24866" ""
Ask "article" "http://junkee.com/riot-in-denmark-partying-hard-at-distortion-festival" "prefix"
Ask "article" "http://www.inthemix.com.au/features/24866/" "prefix"

Write-Host ""
Write-Host "2. The image directories, in case a neighbour survived" -ForegroundColor Cyan
Ask "directory" "http://images.inthemix.com.au/1398/" "prefix"
Ask "directory" "http://images.inthemix.com.au/1526/" "prefix"
Ask "directory" "http://images.inthemix.com.au/1551/" "prefix"
Ask "directory" "http://images.inthemix.com.au/1569/" "prefix"
Ask "directory" "http://images.inthemix.com.au/1686/" "prefix"
Ask "directory" "http://images.inthemix.com.au/1697/" "prefix"
Ask "directory" "http://images.inthemix.com.au/1734/" "prefix"
Ask "directory" "http://images.inthemix.com.au/1736/" "prefix"
Ask "directory" "http://www.ibiza-voice.com/media/news/news_2013/deetron/" "prefix"
Ask "directory" "http://www.ibiza-voice.com/media/news/news_2013/josephcapriati/" "prefix"
Ask "directory" "https://cdn.boilerroom.tv/wp-content/uploads/2015/08/" "prefix"

Write-Host ""
Write-Host "3. Each image, exact, plus the protocol and www variants" -ForegroundColor Cyan
Ask "image" "http://images.inthemix.com.au/1398/1398927.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1398/1398927.jpg" ""
Ask "image" "https://images.inthemix.com.au/1398/1398927.jpg" ""
Ask "image" "http://images.inthemix.com.au/1526/1526467.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1526/1526467.jpg" ""
Ask "image" "https://images.inthemix.com.au/1526/1526467.jpg" ""
Ask "image" "http://images.inthemix.com.au/1526/1526468.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1526/1526468.jpg" ""
Ask "image" "https://images.inthemix.com.au/1526/1526468.jpg" ""
Ask "image" "http://images.inthemix.com.au/1526/1526469.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1526/1526469.jpg" ""
Ask "image" "https://images.inthemix.com.au/1526/1526469.jpg" ""
Ask "image" "http://images.inthemix.com.au/1526/1526472.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1526/1526472.jpg" ""
Ask "image" "https://images.inthemix.com.au/1526/1526472.jpg" ""
Ask "image" "http://images.inthemix.com.au/1551/1551600.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1551/1551600.jpg" ""
Ask "image" "https://images.inthemix.com.au/1551/1551600.jpg" ""
Ask "image" "http://images.inthemix.com.au/1551/1551601.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1551/1551601.jpg" ""
Ask "image" "https://images.inthemix.com.au/1551/1551601.jpg" ""
Ask "image" "http://images.inthemix.com.au/1551/1551602.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1551/1551602.jpg" ""
Ask "image" "https://images.inthemix.com.au/1551/1551602.jpg" ""
Ask "image" "http://images.inthemix.com.au/1551/1551603.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1551/1551603.jpg" ""
Ask "image" "https://images.inthemix.com.au/1551/1551603.jpg" ""
Ask "image" "http://images.inthemix.com.au/1551/1551604.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1551/1551604.jpg" ""
Ask "image" "https://images.inthemix.com.au/1551/1551604.jpg" ""
Ask "image" "http://images.inthemix.com.au/1551/1551605.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1551/1551605.jpg" ""
Ask "image" "https://images.inthemix.com.au/1551/1551605.jpg" ""
Ask "image" "http://images.inthemix.com.au/1551/1551607.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1551/1551607.jpg" ""
Ask "image" "https://images.inthemix.com.au/1551/1551607.jpg" ""
Ask "image" "http://images.inthemix.com.au/1569/1569456.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1569/1569456.jpg" ""
Ask "image" "https://images.inthemix.com.au/1569/1569456.jpg" ""
Ask "image" "http://images.inthemix.com.au/1569/1569462.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1569/1569462.jpg" ""
Ask "image" "https://images.inthemix.com.au/1569/1569462.jpg" ""
Ask "image" "http://images.inthemix.com.au/1569/1569466.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1569/1569466.jpg" ""
Ask "image" "https://images.inthemix.com.au/1569/1569466.jpg" ""
Ask "image" "http://images.inthemix.com.au/1569/1569467.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1569/1569467.jpg" ""
Ask "image" "https://images.inthemix.com.au/1569/1569467.jpg" ""
Ask "image" "http://images.inthemix.com.au/1569/1569481.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1569/1569481.jpg" ""
Ask "image" "https://images.inthemix.com.au/1569/1569481.jpg" ""
Ask "image" "http://images.inthemix.com.au/1569/1569495.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1569/1569495.jpg" ""
Ask "image" "https://images.inthemix.com.au/1569/1569495.jpg" ""
Ask "image" "http://images.inthemix.com.au/1569/1569508.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1569/1569508.jpg" ""
Ask "image" "https://images.inthemix.com.au/1569/1569508.jpg" ""
Ask "image" "http://images.inthemix.com.au/1569/1569514.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1569/1569514.jpg" ""
Ask "image" "https://images.inthemix.com.au/1569/1569514.jpg" ""
Ask "image" "http://images.inthemix.com.au/1569/1569702.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1569/1569702.jpg" ""
Ask "image" "https://images.inthemix.com.au/1569/1569702.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686816.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686816.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686816.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686817.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686817.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686817.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686818.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686818.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686818.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686819.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686819.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686819.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686820.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686820.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686820.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686821.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686821.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686821.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686822.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686822.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686822.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686823.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686823.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686823.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686824.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686824.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686824.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686825.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686825.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686825.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686827.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686827.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686827.jpg" ""
Ask "image" "http://images.inthemix.com.au/1686/1686830.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1686/1686830.jpg" ""
Ask "image" "https://images.inthemix.com.au/1686/1686830.jpg" ""
Ask "image" "http://images.inthemix.com.au/1697/1697692.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1697/1697692.jpg" ""
Ask "image" "https://images.inthemix.com.au/1697/1697692.jpg" ""
Ask "image" "http://images.inthemix.com.au/1697/1697699.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1697/1697699.jpg" ""
Ask "image" "https://images.inthemix.com.au/1697/1697699.jpg" ""
Ask "image" "http://images.inthemix.com.au/1697/1697700.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1697/1697700.jpg" ""
Ask "image" "https://images.inthemix.com.au/1697/1697700.jpg" ""
Ask "image" "http://images.inthemix.com.au/1697/1697701.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1697/1697701.jpg" ""
Ask "image" "https://images.inthemix.com.au/1697/1697701.jpg" ""
Ask "image" "http://images.inthemix.com.au/1697/1697702.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1697/1697702.jpg" ""
Ask "image" "https://images.inthemix.com.au/1697/1697702.jpg" ""
Ask "image" "http://images.inthemix.com.au/1734/1734655.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1734/1734655.jpg" ""
Ask "image" "https://images.inthemix.com.au/1734/1734655.jpg" ""
Ask "image" "http://images.inthemix.com.au/1734/1734656.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1734/1734656.jpg" ""
Ask "image" "https://images.inthemix.com.au/1734/1734656.jpg" ""
Ask "image" "http://images.inthemix.com.au/1734/1734657.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1734/1734657.jpg" ""
Ask "image" "https://images.inthemix.com.au/1734/1734657.jpg" ""
Ask "image" "http://images.inthemix.com.au/1734/1734658.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1734/1734658.jpg" ""
Ask "image" "https://images.inthemix.com.au/1734/1734658.jpg" ""
Ask "image" "http://images.inthemix.com.au/1734/1734659.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1734/1734659.jpg" ""
Ask "image" "https://images.inthemix.com.au/1734/1734659.jpg" ""
Ask "image" "http://images.inthemix.com.au/1736/1736135.jpg" ""
Ask "image" "http://www.images.inthemix.com.au/1736/1736135.jpg" ""
Ask "image" "https://images.inthemix.com.au/1736/1736135.jpg" ""
Ask "image" "http://ibiza-voice.com/media/news/news_2013/deetron/Music_Over_Matter.jpg" ""
Ask "image" "http://www.ibiza-voice.com/media/news/news_2013/deetron/Music_Over_Matter.jpg" ""
Ask "image" "https://www.ibiza-voice.com/media/news/news_2013/deetron/Music_Over_Matter.jpg" ""
Ask "image" "http://ibiza-voice.com/media/news/news_2013/josephcapriati/Joseph_Capriati3.jpg" ""
Ask "image" "http://www.ibiza-voice.com/media/news/news_2013/josephcapriati/Joseph_Capriati3.jpg" ""
Ask "image" "https://www.ibiza-voice.com/media/news/news_2013/josephcapriati/Joseph_Capriati3.jpg" ""
Ask "image" "http://ibiza-voice.com/media/news/news_2013/josephcapriati/Joseph_Capriati_Self_Portrait.jpg" ""
Ask "image" "http://www.ibiza-voice.com/media/news/news_2013/josephcapriati/Joseph_Capriati_Self_Portrait.jpg" ""
Ask "image" "https://www.ibiza-voice.com/media/news/news_2013/josephcapriati/Joseph_Capriati_Self_Portrait.jpg" ""
Ask "image" "http://cdn.boilerroom.tv/wp-content/uploads/2015/08/2006_Club410.04.06-165x165.jpg?b7272f" ""
Ask "image" "https://cdn.boilerroom.tv/wp-content/uploads/2015/08/2006_Club410.04.06-165x165.jpg?b7272f" ""
Ask "image" "https://www.cdn.boilerroom.tv/wp-content/uploads/2015/08/2006_Club410.04.06-165x165.jpg?b7272f" ""
Ask "image" "http://cdn.boilerroom.tv/wp-content/uploads/2015/08/2006_Paco-980x653.jpg?b7272f" ""
Ask "image" "https://cdn.boilerroom.tv/wp-content/uploads/2015/08/2006_Paco-980x653.jpg?b7272f" ""
Ask "image" "https://www.cdn.boilerroom.tv/wp-content/uploads/2015/08/2006_Paco-980x653.jpg?b7272f" ""
Ask "image" "http://cdn.boilerroom.tv/wp-content/uploads/2015/08/2012_Captura-de-pantalla-2015-08-26-a-las-11.31.12.png?b7272f" ""
Ask "image" "https://cdn.boilerroom.tv/wp-content/uploads/2015/08/2012_Captura-de-pantalla-2015-08-26-a-las-11.31.12.png?b7272f" ""
Ask "image" "https://www.cdn.boilerroom.tv/wp-content/uploads/2015/08/2012_Captura-de-pantalla-2015-08-26-a-las-11.31.12.png?b7272f" ""

$rows | Export-Csv -Path $out -NoTypeInformation -Encoding UTF8
Write-Host ""
Write-Host ("Done. {0} captures found, written to {1}" -f $rows.Count, $out) -ForegroundColor Green
Write-Host "Send that file back."
