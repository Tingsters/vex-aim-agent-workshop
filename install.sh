#!/bin/sh
# Installs the `vex-aim` agent skill and the `vexaim` robot tool (macOS / Linux).
#
#   sh install.sh                      install for Goose, Codex and Claude Code (user-level)
#   sh install.sh --agents claude      only Claude Code   (goose | codex | claude | all)
#   sh install.sh --udev               Linux: also install the udev rule (asks for sudo)
#   sh install.sh --dry-run            show what would happen, change nothing
#   sh install.sh --uninstall          remove what this script installed
#   sh install.sh --from-source        build the tool with cargo instead of downloading it
#   sh install.sh --from-dir DIR       use vexaim-<target>.tar.gz + SHA256SUMS from DIR (offline/testing)
#   sh install.sh --base-url URL       download from URL instead of the GitHub release
#   sh install.sh --home DIR           install under DIR instead of $HOME (testing)
#
# What it changes (nothing else): ~/.agents/skills/vex-aim (Goose, Codex), ~/.claude/skills/vex-aim (Claude Code).
# `sh install.sh --help` prints this header.
set -eu

REPO="steveonjava/vex-aim-agent-workshop"
BASE_URL="https://github.com/$REPO/releases/latest/download"
HERE="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$HERE/skill/vex-aim"
MARKER=".vexaim-installed"

TARGET_HOME="$HOME"; AGENTS="all"; FROM_DIR=""; FROM_SOURCE=0; UDEV=0; DRY=0; UNINSTALL=0; DOCTOR=1; FORCE=0

say()  { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --agents)      [ $# -ge 2 ] || die "--agents needs a value"; AGENTS="$2"; shift 2 ;;
    --from-dir)    [ $# -ge 2 ] || die "--from-dir needs a directory"; FROM_DIR="$2"; shift 2 ;;
    --base-url)    [ $# -ge 2 ] || die "--base-url needs a URL"; BASE_URL="$2"; shift 2 ;;
    --home)        [ $# -ge 2 ] || die "--home needs a directory"; TARGET_HOME="$2"; shift 2 ;;
    --from-source) FROM_SOURCE=1; shift ;;
    --udev)        UDEV=1; shift ;;
    --dry-run)     DRY=1; shift ;;
    --uninstall)   UNINSTALL=1; shift ;;
    --no-doctor)   DOCTOR=0; shift ;;
    --force)       FORCE=1; shift ;;
    -h|--help)     sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)             die "unknown option: $1 (try --help)" ;;
  esac
done

# --- which skill folders ------------------------------------------------------------------
want_dirs=""
add_dir() { case " $want_dirs " in *" $1 "*) ;; *) want_dirs="$want_dirs $1" ;; esac; }
for a in $(printf '%s' "$AGENTS" | tr ',' ' '); do
  case "$a" in
    goose|codex) add_dir "$TARGET_HOME/.agents/skills/vex-aim" ;;
    claude)      add_dir "$TARGET_HOME/.claude/skills/vex-aim" ;;
    all)         add_dir "$TARGET_HOME/.agents/skills/vex-aim"; add_dir "$TARGET_HOME/.claude/skills/vex-aim" ;;
    *)           die "unknown agent '$a' (use goose, codex, claude or all)" ;;
  esac
done
[ -n "$want_dirs" ] || die "no agents selected"

# --- uninstall ----------------------------------------------------------------------------
if [ "$UNINSTALL" -eq 1 ]; then
  for d in "$TARGET_HOME/.agents/skills/vex-aim" "$TARGET_HOME/.claude/skills/vex-aim"; do
    if [ -f "$d/$MARKER" ]; then
      if [ "$DRY" -eq 1 ]; then say "would remove $d"; else rm -rf "$d"; say "removed $d"; fi
    elif [ -e "$d" ]; then
      warn "$d exists but was not installed by this script: left alone"
    fi
  done
  say "udev rule (if you installed one) is not removed: sudo rm /etc/udev/rules.d/99-vex-aim.rules"
  exit 0
fi

# --- platform -----------------------------------------------------------------------------
OS="$(uname -s)"; ARCH="$(uname -m)"
case "$OS/$ARCH" in
  Linux/x86_64)                 TARGET="linux-x86_64" ;;
  Darwin/arm64)                 TARGET="macos-arm64" ;;
  Darwin/x86_64)                TARGET="macos-x86_64" ;;
  *)                            TARGET="" ;;
esac
say "platform: $OS $ARCH${TARGET:+ ($TARGET)}"
[ -d "$SKILL_SRC" ] || die "run this script from a clone of the repository (missing $SKILL_SRC)"

if [ -z "$TARGET" ] && [ "$FROM_SOURCE" -eq 0 ]; then
  die "no prebuilt binary for $OS/$ARCH. Re-run with --from-source (needs Rust: https://rustup.rs)"
fi

ARCHIVE="vexaim-$TARGET.tar.gz"
if [ "$DRY" -eq 1 ]; then
  if [ "$FROM_SOURCE" -eq 1 ]; then say "would build from source: cargo build --release --manifest-path $HERE/cli/Cargo.toml"
  elif [ -n "$FROM_DIR" ]; then say "would use $FROM_DIR/$ARCHIVE (verifying SHA256SUMS)"
  else say "would download $BASE_URL/$ARCHIVE and $BASE_URL/SHA256SUMS and verify the checksum"; fi
  for d in $want_dirs; do say "would install skill + bin/vexaim into $d"; done
  [ "$UDEV" -eq 1 ] && say "would run the udev installer (sudo)"
  say "dry run: nothing changed"
  exit 0
fi

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT INT TERM

sha256_of() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi; }

fetch() { # url dest
  if command -v curl >/dev/null 2>&1; then curl -fsSL --retry 2 -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then wget -q -O "$2" "$1"
  else die "need curl or wget to download"; fi
}

verify_and_extract() { # dir-with-archive-and-sums
  want="$(grep " $ARCHIVE\$" "$1/SHA256SUMS" | head -n1 | cut -d' ' -f1)"
  [ -n "$want" ] || die "$ARCHIVE is not listed in SHA256SUMS: refusing to install"
  got="$(sha256_of "$1/$ARCHIVE")"
  [ "$want" = "$got" ] || die "checksum mismatch for $ARCHIVE (expected $want, got $got): refusing to install"
  say "checksum OK"
  tar -xzf "$1/$ARCHIVE" -C "$TMP" vexaim
}

build_from_source() {
  command -v cargo >/dev/null 2>&1 || die "cargo not found. Install Rust from https://rustup.rs (ask the student first), then re-run with --from-source"
  say "building from source (a few minutes the first time)"
  if ! cargo build --release --manifest-path "$HERE/cli/Cargo.toml"; then
    [ "$OS" = "Linux" ] && warn "on Linux the build needs libudev headers: sudo apt install libudev-dev pkg-config  (Fedora: sudo dnf install systemd-devel)"
    die "build failed"
  fi
  cp "$HERE/cli/target/release/vexaim" "$TMP/vexaim"
}

if [ "$FROM_SOURCE" -eq 1 ]; then
  build_from_source
elif [ -n "$FROM_DIR" ]; then
  say "using local files in $FROM_DIR"
  verify_and_extract "$FROM_DIR"
else
  say "downloading $ARCHIVE"
  if fetch "$BASE_URL/$ARCHIVE" "$TMP/$ARCHIVE" && fetch "$BASE_URL/SHA256SUMS" "$TMP/SHA256SUMS"; then
    verify_and_extract "$TMP"
  elif command -v cargo >/dev/null 2>&1; then
    warn "download failed; falling back to building from source with your existing Rust toolchain"
    build_from_source
  else
    die "download failed (offline, or no release published yet?) and Rust is not installed. Options: check the internet connection and retry; or install Rust (https://rustup.rs) and re-run with --from-source"
  fi
fi

chmod +x "$TMP/vexaim"
"$TMP/vexaim" --version >/dev/null 2>&1 || die "the vexaim binary does not run on this machine"
say "vexaim $("$TMP/vexaim" --version | sed 's/^vexaim //') runs"

# --- install ------------------------------------------------------------------------------
installed=""
for d in $want_dirs; do
  if [ -e "$d" ] && [ ! -f "$d/$MARKER" ] && [ "$FORCE" -eq 0 ]; then
    die "$d already exists and was not installed by this script. Move it away or re-run with --force"
  fi
  rm -rf "$d"
  mkdir -p "$d/bin"
  cp -R "$SKILL_SRC/." "$d/"
  cp "$TMP/vexaim" "$d/bin/vexaim"
  chmod +x "$d/bin/vexaim"
  if [ -d "$d/linux" ]; then chmod +x "$d/linux/install-udev.sh" 2>/dev/null || true; fi
  printf 'installed by vex-aim-agent-workshop install.sh on %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$d/$MARKER"
  if [ "$OS" = "Darwin" ]; then xattr -d com.apple.quarantine "$d/bin/vexaim" 2>/dev/null || true; fi
  say "installed skill + tool: $d"
  installed="$installed $d"
done

# --- Linux udev ---------------------------------------------------------------------------
if [ "$OS" = "Linux" ]; then
  first="${installed# }"; first="${first%% *}"
  if [ -f /etc/udev/rules.d/99-vex-aim.rules ]; then
    say "udev rule already installed"
  elif [ "$UDEV" -eq 1 ]; then
    say "installing the udev rule (needs sudo)"
    sh "$first/linux/install-udev.sh"
  else
    warn "Linux: ModemManager can grab the robot's USB ports for ~25 s after each plug-in. Fix once with: sh $first/linux/install-udev.sh   (asks for sudo)"
  fi
fi

# --- verify -------------------------------------------------------------------------------
first="${installed# }"; first="${first%% *}"
if [ "$DOCTOR" -eq 1 ]; then
  say "robot check (plug the AIM in with its USB cable and turn it on)"
  if "$first/bin/vexaim" doctor; then say "robot ready"
  else warn "robot not ready yet. The install itself is fine; see docs/troubleshooting.md for the 'fix:' lines above"; fi
fi

say "DONE. Tool: $first/bin/vexaim"
say "NEXT: start a NEW session of your agent (Goose / Codex / Claude Code) so it loads the vex-aim skill"
