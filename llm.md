# llm.md — palemon-bin

Arch PKGBUILDs for Pale Moon (gtk3 + gtk2), built in GitHub Actions. **No local builds.**

## Layout

```
palemoon-gtk3/PKGBUILD, palemoon.desktop, palemoon-bin.desktop, palemoon.sh
palemoon-gtk2/  (same files)
.github/workflows/build.yml
```

## State

- Version pinned: **35.0.2** (upstream latest as of 2026-10-09)
- Remote: `https://github.com/7sarus/palemon-bin` (public), branch `main`
- CI is **red**. Last run `37876750135`, both jobs failed. Fixes are committed
  but **unverified** — user stopped the runs before they could be re-run.
- All builds are stopped/completed; nothing in flight.

## CI run history (all failed, root cause of each)

| Run | Failure | Fix |
|---|---|---|
| 37876011501 | `makepkg` refuses to run as root (exit 10) | create `builder` user, run unprivileged |
| 37876106755 | same | + install runtime deps as root first |
| 37876197505 | `target not found: gtk2` | gtk2 is AUR-only on Arch |
| 37876323225 | `makepkg: invalid option '--pkgdir'` | removed flag |
| 37876418368 | `makepkg as root` again in AUR step | `useradd builder` moved earlier |
| 37876633045 | `PKGBUILD does not exist` | makepkg has no `-C`; use `bash -c 'cd ...'` |
| 37876633045 | `install: cannot create directory 'icudt78l.dat'` | `install -dm644 *.dat` is wrong; loop per-file `-Dm644` |
| 37876750135 | `cp: cannot stat 'chrome'` | `chrome/` is under `browser/`, not top level |
| 37876750135 | `cannot stat .../src/palemoon.desktop` | aux files live in `$startdir`, not `$srcdir` |
| 37876750135 | pacman could not resolve gtk2's deps | install AUR gtk2 `depends` as root before unprivileged makepkg |

## Conventions

- Package names `palemoon-gtk3` / `palemoon-gtk2`. Both `provides=('palemoon')` and
  conflict with each other and with Arch's `palemoon`.
- `source=` uses `download.php?mirror=us&bits=64&type=linuxgtk{2,3}`; 303-redirects to a
  versioned mirror path, so no URL edit needed on bump.
- `sha256sums` are regenerated in CI via `makepkg -g` from the download page, not hand-maintained.
  Verified against upstream: gtk2 `a70e0f05…`, gtk3 `3136ee8e…`.
- Payload installs to `/usr/lib/palemoon/`; launcher `/usr/bin/palemoon` wraps `run-mozilla.sh`.
- Aux files (`.desktop`, `.sh`) referenced with `$startdir/…`; extracted tree with `$srcdir/palemoon`.
- gtk3 package installs `gtk2/libmozgtk.so` (Flash support) → `gtk2` is an **optdepend**, not a
  hard dep, because Arch removed gtk2 from official repos in Oct 2025.

## Workflow

`build.yml` triggers on: push to main touching package dirs, weekly cron (Mon 04:23 UTC),
and `workflow_dispatch` (optional `publish` input for a GitHub release).

```sh
gh workflow run build.yml -f publish=true
```

## Next step

Re-run CI to verify the three unverified fixes:

```sh
gh workflow run build.yml
```

## Gotchas

- Dir is `palmon`, repo is `palemon-bin`. Intentional.
- Mirrors have no directory index (403). Version is parsed from
  `Hashes for release <ver>` on download.shtml.
- Upstream tarball is XZ despite auto-detect guessing bzip2; use `tar -tJf` when inspecting.
- Both tarballs have a single top-level `palemoon/` dir, no version dir.
- Top-level dirs in tarball: `browser defaults dictionaries fonts icons` (+ `gtk2/` in gtk3 build).