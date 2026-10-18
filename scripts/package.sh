#!/bin/sh
# Package a built vexaim binary the way install.sh expects release assets:
#   <outdir>/vexaim-<target>.tar.gz   (contains just `vexaim`)
#   <outdir>/SHA256SUMS               (one line per archive, "<hash>  <file>"; appended, so run once per target)
# usage: scripts/package.sh <target> <path-to-vexaim> <outdir>
set -eu
[ $# -eq 3 ] || { echo "usage: $0 <target> <path-to-vexaim> <outdir>" >&2; exit 2; }
target="$1"; bin="$2"; out="$3"
mkdir -p "$out"
stage="$(mktemp -d)"; trap 'rm -rf "$stage"' EXIT
cp "$bin" "$stage/vexaim"
chmod +x "$stage/vexaim"
archive="vexaim-$target.tar.gz"
tar -czf "$out/$archive" -C "$stage" vexaim
if command -v sha256sum >/dev/null 2>&1; then sum="$(sha256sum "$out/$archive" | cut -d' ' -f1)"
else sum="$(shasum -a 256 "$out/$archive" | cut -d' ' -f1)"; fi
printf '%s  %s\n' "$sum" "$archive" >> "$out/SHA256SUMS"
echo "packaged $out/$archive"
