#!/bin/sh
# Install latest stable vexaim/basic skill and the workshop teaching skill.
# --agents all|goose|codex|claude --home DIR --from-dir RELEASE_ASSETS
# --base-url URL --dry-run --force --udev --uninstall (workshop skill only)
set -eu
HERE=''; SOURCE=''
if [ -f "$0" ]; then HERE=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd); fi
if [ -n "$HERE" ] && [ -f "$HERE/skill/vex-aim-workshop/SKILL.md" ]; then SOURCE=$HERE/skill/vex-aim-workshop; fi
REPO=https://github.com/Tingsters/vexaim-cli
AGENTS=all; TARGET_HOME=$HOME; FROM_DIR=''; BASE_URL=''; DRY=0; FORCE=0; UDEV=0; UNINSTALL=0
MARKER=.vexaim-workshop-installed
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
while [ $# -gt 0 ]; do
  case "$1" in
    --agents|--home|--from-dir|--base-url)
      [ $# -ge 2 ] || die "$1 needs a value"
      case "$1" in --agents) AGENTS=$2 ;; --home) TARGET_HOME=$2 ;; --from-dir) FROM_DIR=$2 ;; --base-url) BASE_URL=$2 ;; esac
      shift 2 ;;
    --dry-run) DRY=1; shift ;; --force) FORCE=1; shift ;; --udev) UDEV=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;; --no-doctor) shift ;;
    -h|--help) printf '%s\n' 'Install vexaim and both workshop skills.' '--agents all|goose|codex|claude --home DIR --from-dir RELEASE_ASSETS' '--base-url URL --dry-run --force --udev --uninstall'; exit 0 ;; *) die "unknown option: $1" ;;
  esac
done
USE_AGENTS=0; USE_CLAUDE=0
for a in $(printf '%s' "$AGENTS" | tr ',' ' '); do
  case "$a" in goose|codex) USE_AGENTS=1 ;; claude) USE_CLAUDE=1 ;;
    all) USE_AGENTS=1; USE_CLAUDE=1 ;; *) die "unknown agent: $a" ;; esac
done
set --
[ "$USE_AGENTS" -eq 0 ] || set -- "$@" "$TARGET_HOME/.agents/skills/vex-aim-workshop"
[ "$USE_CLAUDE" -eq 0 ] || set -- "$@" "$TARGET_HOME/.claude/skills/vex-aim-workshop"
[ $# -gt 0 ] || die 'no agents selected'
for d do
  [ ! -L "$d" ] || die "refusing linked skill folder: $d"
  if [ "$UNINSTALL" -eq 1 ]; then
    if [ -f "$d/$MARKER" ]; then
      if [ "$DRY" -eq 1 ]; then printf 'would remove %s\n' "$d"; else rm -rf -- "$d"; fi
    fi
  elif [ -e "$d" ] && [ ! -f "$d/$MARKER" ] && [ "$FORCE" -eq 0 ]; then die "$d was not installed by this script; use --force"; fi
done
[ "$UNINSTALL" -eq 0 ] || { printf 'Shared vexaim CLI/basic skill left installed.\n'; exit 0; }
[ "$DRY" -eq 0 ] || { printf 'Would install latest stable CLI/basic skill and workshop skill. No changes.\n'; exit 0; }
TMP=$(mktemp -d); trap 'rm -rf -- "$TMP"' EXIT INT TERM
fetch() {
  if command -v curl >/dev/null 2>&1; then curl -fsSL --retry 2 -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then wget -q -O "$2" "$1"
  else die 'need curl or wget'; fi
}
if [ -z "$SOURCE" ]; then
  # One archive supplies a consistent snapshot of all teaching references. It
  # contains no executable; the CLI still comes from a checksummed release.
  fetch 'https://github.com/Tingsters/vex-aim-agent-workshop/archive/refs/heads/main.tar.gz' "$TMP/workshop.tar.gz" || die 'workshop download failed; retry or use a checkout'
  mkdir "$TMP/workshop"
  tar -xzf "$TMP/workshop.tar.gz" -C "$TMP/workshop" --strip-components=1
  SOURCE=$TMP/workshop/skill/vex-aim-workshop
  [ -f "$SOURCE/SKILL.md" ] || die 'downloaded workshop is missing its teaching skill'
fi
if [ -n "$FROM_DIR" ]; then
  cp "$FROM_DIR/VERSION" "$FROM_DIR/SHA256SUMS" "$FROM_DIR/install.sh" "$TMP/"
else
  discovery=${BASE_URL:-$REPO/releases/latest/download}
  fetch "$discovery/VERSION" "$TMP/VERSION" || die 'CLI release download failed; retry or use --from-dir'
fi
VERSION=$(tr -d '\r\n' < "$TMP/VERSION")
printf '%s\n' "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z]+([.-][0-9A-Za-z]+)*)?$' || die 'invalid CLI release version'
if [ -z "$FROM_DIR" ]; then
  release=${BASE_URL:-$REPO/releases/download/v$VERSION}
  if ! fetch "$release/install.sh" "$TMP/install.sh" || ! fetch "$release/SHA256SUMS" "$TMP/SHA256SUMS"; then die 'CLI installer download failed'; fi
fi
want=$(awk '$2 == "install.sh" { print $1 }' "$TMP/SHA256SUMS")
[ ${#want} -eq 64 ] || die 'install.sh is not listed in SHA256SUMS exactly once'
if command -v sha256sum >/dev/null 2>&1; then got=$(sha256sum "$TMP/install.sh" | cut -d' ' -f1)
else got=$(shasum -a 256 "$TMP/install.sh" | cut -d' ' -f1); fi
[ "$want" = "$got" ] || die 'CLI installer checksum mismatch; no skills changed'
# Preserve the destination list inside a function while assembling CLI arguments.
install_cli() {
  set -- --agents "$AGENTS" --home "$TARGET_HOME" --version "$VERSION"
  if [ -n "$FROM_DIR" ]; then set -- "$@" --from-dir "$FROM_DIR"
  elif [ -n "$BASE_URL" ]; then set -- "$@" --base-url "$BASE_URL"; fi
  [ "$FORCE" -eq 0 ] || set -- "$@" --force
  [ "$UDEV" -eq 0 ] || set -- "$@" --udev
  sh "$TMP/install.sh" "$@"
}
install_cli || die 'CLI installation failed; workshop skill was not installed'
tool=$(dirname -- "$1")/vex-aim/bin/vexaim
behavior_help=$("$tool" exec --help) || die 'cannot inspect the installed CLI'
case "$behavior_help" in *--behaviors*) ;; *) die 'this workshop requires vexaim 0.5.0+ with exec --behaviors; update CLI release assets; teaching skill was not installed';; esac
for d do
  stage=$d.stage-$$; backup=$d.backup-$$
  if [ -e "$stage" ] || [ -e "$backup" ]; then die 'staging folder already exists'; fi
  cp -R "$SOURCE" "$stage"
  printf 'workshop; vexaim %s\n' "$VERSION" > "$stage/$MARKER"
  if [ -e "$d" ]; then mv -- "$d" "$backup"; fi
  if ! mv -- "$stage" "$d"; then
    [ ! -e "$backup" ] || mv -- "$backup" "$d"
    rm -rf -- "$stage"; die 'workshop skill installation failed'
  fi
  rm -rf -- "$backup"
  printf 'Installed workshop skill: %s\n' "$d"
done
printf 'Start a NEW agent session to load vex-aim and vex-aim-workshop.\n'
