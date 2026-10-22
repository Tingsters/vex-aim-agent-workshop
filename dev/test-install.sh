#!/bin/sh
# Workshop integration tests against native, complete CLI release assets.
set -eu
HERE=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
ASSETS=$(CDPATH='' cd -- "${1:?usage: test-install.sh ASSETS}" && pwd)
WORK=$(mktemp -d); trap 'rm -rf -- "$WORK"' EXIT INT TERM
pass=0
check() { "$@" || { printf 'FAIL: %s\n' "$*" >&2; exit 1; }; pass=$((pass+1)); }
install_to() { target=$1; shift; sh "$HERE/install.sh" --home "$target" "$@"; }
expect_fail() {
  if "$@" >"$WORK/error" 2>&1; then printf 'unexpected success\n'; exit 1; fi
  pass=$((pass+1))
}
H1="$WORK/home with spaces"
check install_to "$H1" --dry-run --from-dir not-a-real-directory
check test ! -e "$H1"
check install_to "$H1" --from-dir "$ASSETS"
for agent in .agents .claude; do
  check test -f "$H1/$agent/skills/vex-aim/SKILL.md"
  check test -x "$H1/$agent/skills/vex-aim/bin/vexaim"
  check test -f "$H1/$agent/skills/vex-aim-workshop/SKILL.md"
  check test ! -d "$H1/$agent/skills/vex-aim-workshop/bin"
  for reference in "$HERE"/skill/vex-aim-workshop/references/*.md; do
    check cmp "$reference" "$H1/$agent/skills/vex-aim-workshop/references/$(basename "$reference")"
  done
  check test "$("$H1/$agent/skills/vex-aim/bin/vexaim" --version)" = "vexaim $(cat "$ASSETS/VERSION")"
done
check install_to "$H1" --from-dir "$ASSETS"
H2="$WORK/single"
check install_to "$H2" --from-dir "$ASSETS" --agents claude
check test -f "$H2/.claude/skills/vex-aim-workshop/SKILL.md"
check test ! -e "$H2/.agents"
STREAM="$WORK/streamed home"
# stdin has no script directory: download the teaching references, not a copy
# from the checkout or the caller's current working directory.
# Keep the pipe to exercise the same invocation as curl | sh.
# shellcheck disable=SC2002
(cd "$WORK"; cat "$HERE/install.sh" | sh -s -- --home "$STREAM" --from-dir "$ASSETS")
check test -x "$STREAM/.agents/skills/vex-aim/bin/vexaim"
check test -f "$STREAM/.agents/skills/vex-aim-workshop/references/activities.md"
check test -f "$STREAM/.claude/skills/vex-aim-workshop/SKILL.md"
BAD="$WORK/bad"; cp -R "$ASSETS" "$BAD"
printf '\n# tampered\n' >> "$BAD/install.sh"
expect_fail install_to "$WORK/rejected" --from-dir "$BAD"
check test ! -e "$WORK/rejected"
cp "$ASSETS/install.sh" "$BAD/install.sh"
for archive in "$BAD"/*.tar.gz; do printf 'tampered' >> "$archive"; done
expect_fail install_to "$WORK/rejected" --from-dir "$BAD"
check test ! -e "$WORK/rejected/.agents/skills/vex-aim-workshop"
FOREIGN="$WORK/foreign"; mkdir -p "$FOREIGN/.agents/skills/vex-aim-workshop"
printf 'keep\n' > "$FOREIGN/.agents/skills/vex-aim-workshop/SKILL.md"
expect_fail install_to "$FOREIGN" --from-dir "$ASSETS"
check install_to "$FOREIGN" --uninstall
check test "$(cat "$FOREIGN/.agents/skills/vex-aim-workshop/SKILL.md")" = keep
check install_to "$H1" --uninstall --dry-run
check test -f "$H1/.agents/skills/vex-aim-workshop/SKILL.md"
check install_to "$H1" --uninstall
for agent in .agents .claude; do
  check test ! -e "$H1/$agent/skills/vex-aim-workshop"
  check test -x "$H1/$agent/skills/vex-aim/bin/vexaim"
done
printf '%s workshop checks passed\n' "$pass"
