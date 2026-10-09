# palemon-bin

Arch Linux packaging for [Pale Moon](https://www.palemoon.org/), built from the
official upstream Linux tarballs.

Two mutually exclusive packages:

| Package | Upstream build | Status |
|---|---|---|
| `palemoon-gtk3` | `palemoon-<ver>.linux-x86_64-gtk3.tar.xz` | Default, recommended |
| `palemoon-gtk2` | `palemoon-<ver>.linux-x86_64-gtk2.tar.xz` | Legacy, GTK2 |

Both `provide` and `conflict` with each other and with Arch's `palemoon` package.

## How CI works

Nothing is built locally. Everything happens in GitHub Actions
(`.github/workflows/build.yml`):

1. Scrapes `https://www.palemoon.org/download.shtml` for the latest release number.
2. Rewrites `pkgver` in the matching `PKGBUILD` and regenerates `sha256sums`
   with `makepkg -g`.
3. Builds the package with `makepkg -sf` inside `archlinux:base-devel`.
4. Uploads the `.pkg.tar.zst` as a workflow artifact.
5. Commits the bumped `PKGBUILD` back to `main`.

The job also runs on a weekly schedule so new upstream releases are picked up
automatically.

### Trigger a build

```sh
gh workflow run build.yml                     # build, no release
gh workflow run build.yml -f publish=true     # build and attach to a GitHub release
```

Or from the Actions tab → *Build packages* → *Run workflow*.

### Install the result

```sh
# from an artifact
gh run download <run-id> -n palemoon-gtk3
sudo pacman -U palemoon-gtk3-*.pkg.tar.zst

# from a release
sudo pacman -U https://github.com/7sarus/palemon-bin/releases/download/palemoon-35.0.2/palemoon-gtk3-35.0.2-1-x86_64.pkg.tar.zst
```

## Manual version bump

```sh
sed -i 's/^pkgver=.*/pkgver=35.0.3/' palemoon-gtk3/PKGBUILD
cd palemoon-gtk3 && makepkg -g   # refresh sha256sums
```

## Notes

- Source URL points at `download.php?mirror=us&...`, which 303-redirects to a
  versioned file on a Pale Moon mirror, so it survives version bumps.
- Upstream publishes SHA256 sums on the download page; CI regenerates them
  independently rather than trusting a pinned value.
- The GTK3 tarball also ships `gtk2/libmozgtk.so`, used for Flash support. It
  is installed under `/usr/lib/palemoon/gtk2/`, which is why `palemoon-gtk3`
  depends on `gtk2`.