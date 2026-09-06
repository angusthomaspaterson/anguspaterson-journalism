# Publishing the music archive to GitHub Pages

Step by step, start to finish. Written 6 September 2026.

The same GitHub Desktop process as the copywriting archive, with one extra step
in the middle. The copywriting archive was a folder you could publish as it came.
This one is not: its 338 WordPress images and 12 videos are too large to send
over, so they stay on your machine and a script pulls them into the repository
folder before you publish it. That is Step 3, it takes two minutes, and it is
the only part that differs.

The repository can live wherever GitHub Desktop puts it. The script goes looking
for the backup and the videos, and asks you for the path if it cannot find them.

---

## Before you start

| You need | How to check |
|---|---|
| A GitHub account | Signed in at `github.com`. Free is enough. |
| GitHub Desktop | `desktop.github.com`. Free, no command line. |
| **site-html.zip** | The site: 268 pages, the 2026 images, the assemble script. |
| **promos-bios-images.zip** | 41 images for the new Promos & Bios pieces. Separate only because the first zip is at the size limit for a transfer. |
| The extracted UpdraftPlus uploads | The folder ending `backup_2025-09-01-2005_..._-uploads\uploads\`, the one with `2011`, `2012` and so on inside it. Anywhere on the machine. |
| The twelve remuxed videos | The folder `videos-web\`, twelve `.mp4` files. Anywhere on the machine. |

GitHub Desktop matters here more than it did last time. The finished repository
is about 1,300 files and 280 MB, and GitHub's browser upload takes 100 files a
commit. Desktop does the lot in one go. No single file is near the 100 MB limit;
the largest is the LMFAO video at 18 MB.

---

## Step 1. Create the repository

In GitHub Desktop: **File**, then **New Repository**.

- **Name:** this becomes part of the published web address, so pick something
  readable. `anguspaterson-archive` gives
  `username.github.io/anguspaterson-archive`.
- **Local path:** leave it as Desktop suggests. It creates the folder for you,
  normally under `Documents\GitHub\`. That is where everything goes.
- Leave the other fields alone. Do not add a README, a `.gitignore` or a
  licence; the zip already has what it needs.

The backup and the videos stay where they are. They do not go in the repository
folder, and they do not need to sit near it.

## Step 2. Unzip both files into it

Unzip **site-html.zip**, then **promos-bios-images.zip**, both into the
repository folder Desktop just made.

**Unzip straight into that folder rather than extracting somewhere else and
pasting the files across.** One of them, `.nojekyll`, is a hidden file, and
Windows Explorer will not copy it unless hidden files are showing. Without it
GitHub runs Jekyll over the site and pictures go missing. If you have already
pasted, Step 7 tells you how to check.

The contents go at the top level, not inside a subfolder. When both are
extracted you should see, directly in the folder: `index.html`, `all-work\`,
`assets\`, `uploads\`, `assemble-site.ps1`, `assemble-site.bat`,
`PUBLISHING.md`, and the hidden `.nojekyll`.

**Check:** `uploads\new\promos-bios\` exists and has nine subfolders in it. If it
does not, the second zip has not been extracted, and the next step will stop and
tell you so.

## Step 3. Run the assemble script

Double-click **assemble-site.bat** in the folder.

That is a two-line wrapper that runs `assemble-site.ps1` for you. Windows blocks
unsigned PowerShell scripts by default, so double-clicking the `.ps1` directly
does nothing useful; the `.bat` gets around it for that one run and changes no
setting on the machine.

It looks for the two outside folders under `Documents`, `Desktop`, `Downloads`
and your user folder, and beside the repository. If they are somewhere else, on
another drive for instance, it asks and you paste the path in.

A black window opens. It says what it is looking for, then works for a couple
of minutes and ends with roughly this:

```
Looking for the UpdraftPlus uploads folder...
Uploads: C:\Users\...\backup_2025-09-01-2005_..._-uploads\uploads
copied 338 of 338 images, built 338 thumbnails
166 images already in place under uploads/new, 166 thumbnails built for them
copied 12 videos, 143 MB

Done. Open index.html to check it, then commit the folder.
```

Press a key to close it.

**If it stops instead**, read the red text. There are only three things it
complains about, and each names the fix:

| Message | What to do |
|---|---|
| `Path (or press Enter to skip):` | It could not find the backup, or the videos. In Explorer open that folder, click the address bar, copy the path, paste it in, Enter. It checks the folder is the right one and asks again if it is not. |
| `STOP: uploads\new\promos-bios holds 0 of 41 images` | promos-bios-images.zip has not been extracted into this folder. Do that, then run it again. |
| `STOP: without that folder there are no images to copy` | You skipped the uploads prompt. Find the extracted backup and run it again. |
| `MISSING:` followed by a list of filenames | Those images are not in the backup. Tell me which ones; nothing else is affected. |

`No videos copied` is a yellow warning, not an error. The site still builds; the
twelve video pages just have nothing to play. Find the folder and run it again
to add them.

Running it a second time is safe. It overwrites what it copied before and
changes nothing else.

## Step 4. Check the site locally

Open `index.html` in a browser. It runs straight off the disk.

Walk through:

- The tile grid on the home page: 13 tiles, all with pictures.
- **All Work**: everything on one page, 196 pieces, thumbnails all the way down.
- **Promos & Bios**: 12 pieces, Jaytech first, no blank cards.
- Any **Video Interviews** piece: press play. It should start straight away
  rather than downloading the whole file first.
- Any article: the previous and next links at the bottom should work.

If a picture is missing here it will be missing on the web. Fix it now.

## Step 5. Commit and publish

Back in GitHub Desktop.

**Check first:** it should list about 1,300 changed files. If it lists one
folder, the zips went into a subfolder rather than the top level.

1. Type a summary, for example
   `Archive of angusthomaspaterson.com, 2000 to 2019`.
2. Click **Commit to main**.
3. Click **Publish repository**.
4. **Leave "Keep this code private" unticked.**

Public is required, not optional. GitHub Pages on the free tier only serves
public repositories, so a private repository publishes nothing. The site was a
public web page for nineteen years, so this is no change in exposure.

The upload moves about 280 MB, mostly video, and will sit there for several
minutes. It only happens once.

## Step 6. Turn on Pages

On `github.com`, open the repository, then **Settings**, then **Pages** in the
left sidebar.

- **Source:** Deploy from a branch
- **Branch:** `main`
- **Folder:** `/ (root)`
- **Save**

## Step 7. Check the live site

Wait two or three minutes for the first build, then open
`https://<your-username>.github.io/<repository>/`. The Pages settings page shows
the exact address once it is live.

Do the same walk as Step 4. Every path in the build is relative, so the site
works from this sub-address exactly as it did off the disk.

- **A 404 straight after saving** usually means the first build has not
  finished. Give it a few minutes.
- **Pictures missing here but fine locally** points at Jekyll. On GitHub, open
  the repository and look for `.nojekyll` in the file list; GitHub shows hidden
  files, so if it is not listed it did not make it across. Create it: in the
  repository on GitHub, **Add file**, **Create new file**, name it `.nojekyll`,
  leave it empty, commit.

---

## That is the whole job

Everything below is optional.

### Keeping the backup out of the repository

In the layout above, `Updraft Plus files` sits outside the repository folder, so
Git cannot see it and nothing needs doing. If the folders ever move, add a file
called `.gitignore` in the repository containing:

```
*.gz
*.sql
Updraft*
```

That backup contains `db.gz`, the whole WordPress database including the user
table. It should never reach a public repository.

### Making a change

1. Edit the files in the folder.
2. In GitHub Desktop: commit, then push.
3. The live site updates in about a minute.

You do not need to run the assemble script again unless images are added.

### Renaming the repository

Settings, General, rename. GitHub redirects the old address to the new one, so
existing links keep working, and the site address changes to match. This is the
setting to use if the URL reads awkwardly. It is not the custom domain field.

### Putting it on your own subdomain

The **Custom domain** field wants a full hostname, with a dot and a top-level
domain. A bare name is rejected as malformed, and it has to be a domain you
control.

`angusthomaspaterson.com` is this archive's own name and the obvious home for
it, if the registration is still yours. Otherwise it comes off
`anguspatersonux.com`, on a different subdomain from the copywriting archive.

1. Decide the domain, for example `archive.anguspatersonux.com`.
2. At your DNS provider, add a **CNAME** record for that subdomain pointing to
   `<your-username>.github.io`. On Cloudflare set it to **DNS only**, not
   proxied, or the certificate will fail to issue.

   For a bare `angusthomaspaterson.com` with no subdomain it is four **A**
   records instead, pointing at `185.199.108.153`, `185.199.109.153`,
   `185.199.110.153` and `185.199.111.153`.
3. In Settings, Pages, enter the domain in **Custom domain** and save. This
   writes a `CNAME` file into the repository.
4. Wait for the certificate to issue, then tick **Enforce HTTPS**.

Do the DNS record first, or immediately after. Entering the domain without it
leaves the site unreachable at the new address.

GitHub recommends verifying the domain under Settings, Pages first, which stops
anyone else claiming it if you ever remove it.

### The old addresses

The build carries 55 redirect pages that preserve the original
`/%category%/%postname%/` URLs, the ones still live on Twitter and elsewhere.
They work automatically; there is nothing to configure.

### Limits worth knowing

| | |
|---|---|
| Repository size | 1 GB. This archive is about 280 MB. |
| Bandwidth | 100 GB a month. |
| Single file | 100 MB. Largest here is the LMFAO video at 18 MB. |
| Browser upload | 100 files per commit, which is why Desktop is easier. |

The heaviest page is All Work at about 18 MB, if a reader scrolls all 196
thumbnails. Video is set to load nothing until play is pressed.
