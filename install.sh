#!/usr/bin/env bash
# Installs /find-add for every AI tool found on this computer.
#
# Copies skills/find-add/SKILL.md into each tool's skills folder, and writes a
# slash-command file for tools that use their own command format (Cursor,
# Roo Code, OpenCode, Windsurf, Gemini CLI). Command files are generated from
# SKILL.md, so SKILL.md stays the single source of truth.
#
# Usage: ./install.sh [--all] [--uninstall] [--home DIR]
#   --all        install for every supported tool, including ones not detected
#   --uninstall  remove everything this script installs
#   --home DIR   home folder to install into (default: $HOME); useful for testing
set -euo pipefail

ALL=0
UNINSTALL=0
TARGET_HOME="$HOME"

while [ $# -gt 0 ]; do
  case "$1" in
    --all) ALL=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --home) shift; TARGET_HOME="${1:?--home needs a folder}" ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1 (try --help)" >&2; exit 1 ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/skills/find-add/SKILL.md"

if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: $SOURCE_FILE not found." >&2
  exit 1
fi

# ---- Build the command text from SKILL.md (frontmatter stripped) ----------

BODY="$(tr -d '\r' < "$SOURCE_FILE" | awk 'n < 2 && /^---[ \t]*$/ { n++; next } n >= 2' | sed '/./,$!d')"
if [ -z "$BODY" ]; then
  echo "Error: could not find the YAML frontmatter in $SOURCE_FILE" >&2
  exit 1
fi
case "$BODY" in
  *"'''"*) echo "Error: SKILL.md must not contain ''' (it is used to quote the Gemini CLI prompt)." >&2; exit 1 ;;
esac

DESCRIPTION="Find and add the best skills, plugins, MCP servers and repos for a task, then do the task"
INTRO="The user ran /find-add. Their task is the text they typed after the command, either in the same message or appended below these instructions. If there is no task, ask what they want done."
COMMAND_TEXT="$INTRO"$'\n\n'"$BODY"$'\n'

command_content() {
  case "$1" in
    plain)       printf '%s' "$COMMAND_TEXT" ;;
    frontmatter) printf -- '---\ndescription: "%s"\nargument-hint: <task>\n---\n\n%s' "$DESCRIPTION" "$COMMAND_TEXT" ;;
    toml)        printf "description = \"%s\"\nprompt = '''\n%s'''\n" "$DESCRIPTION" "$COMMAND_TEXT" ;;
  esac
}

# ---- What to install where -------------------------------------------------
# Each entry: found|kind|path|tool. Kind "skill" copies SKILL.md into
# <path>/SKILL.md; other kinds write <path>.

found() { if [ -e "$TARGET_HOME/$1" ]; then echo 1; else echo 0; fi; }

GEMINI_CMD=0
if command -v gemini >/dev/null 2>&1 || [ -d "$TARGET_HOME/.gemini/commands" ]; then
  GEMINI_CMD=1
fi

TARGETS=(
  "1|skill|.agents/skills/find-add|Agent Skills standard (Codex, Gemini CLI, VS Code, OpenCode)"
  "$(found .claude)|skill|.claude/skills/find-add|Claude Code"
  "$(found .copilot)|skill|.copilot/skills/find-add|GitHub Copilot (VS Code and CLI)"
  "$(found .cline)|skill|.cline/skills/find-add|Cline"
  "$(found .gemini)|skill|.gemini/skills/find-add|Gemini CLI / Antigravity CLI"
  "$(found .gemini)|skill|.gemini/config/skills/find-add|Antigravity IDE and app"
  "$GEMINI_CMD|toml|.gemini/commands/find-add.toml|Gemini CLI slash command"
  "$(found .cursor)|plain|.cursor/commands/find-add.md|Cursor"
  "$(found .roo)|frontmatter|.roo/commands/find-add.md|Roo Code"
  "$(found .config/opencode)|frontmatter|.config/opencode/commands/find-add.md|OpenCode"
  "$(found .codeium/windsurf)|frontmatter|.codeium/windsurf/global_workflows/find-add.md|Windsurf"
)

# Paths written by older versions of this installer.
LEGACY_PATHS=(".cursor/skills/find-add")

# ---- Uninstall ---------------------------------------------------------------

if [ "$UNINSTALL" -eq 1 ]; then
  removed=0
  paths=()
  for entry in "${TARGETS[@]}"; do
    IFS='|' read -r _ _ rel _ <<< "$entry"
    paths+=("$rel")
  done
  paths+=("${LEGACY_PATHS[@]}")

  for rel in "${paths[@]}"; do
    full="$TARGET_HOME/$rel"
    if [ -d "$full" ]; then
      # Only remove a skill folder that really is find-add.
      if [ -f "$full/SKILL.md" ] && grep -Eq '^name:[[:space:]]*find-add[[:space:]]*$' "$full/SKILL.md"; then
        rm -rf "$full"
        echo "Removed    $full"
        removed=$((removed + 1))
      fi
    elif [ -f "$full" ]; then
      rm -f "$full"
      echo "Removed    $full"
      removed=$((removed + 1))
    fi
  done
  echo ""
  echo "Done. Removed $removed item(s)."
  exit 0
fi

# ---- Install -----------------------------------------------------------------

installed=0
for entry in "${TARGETS[@]}"; do
  IFS='|' read -r is_found kind rel tool <<< "$entry"
  full="$TARGET_HOME/$rel"
  if [ "$ALL" -ne 1 ] && [ "$is_found" -ne 1 ]; then
    echo "Skipped    $tool (not found; use --all to install anyway)"
    continue
  fi
  if [ "$kind" = "skill" ]; then
    mkdir -p "$full"
    full="$full/SKILL.md"
    cp "$SOURCE_FILE" "$full"
  else
    mkdir -p "$(dirname "$full")"
    command_content "$kind" > "$full"
  fi
  echo "Installed  $tool -> $full"
  installed=$((installed + 1))
done

echo ""
echo "Done. Installed $installed item(s). Restart open AI tools (or reload their skills), then type:"
echo "  /find-add <your task>     Claude Code, Copilot, Cursor, Cline, Roo Code, OpenCode, Windsurf, Gemini CLI, Antigravity"
echo '  $find-add <your task>     Codex'
