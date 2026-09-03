#!/usr/bin/env bash
# Path A — install the NotebookLM MCP server into a local MCP client.
# Usage: ./setup-local.sh [claude-code|claude-desktop|cursor|windsurf]
set -euo pipefail

CLIENT="${1:-claude-code}"
VENV="$HOME/.notebooklm-venv"

case "$CLIENT" in
  claude-code|claude-desktop|cursor|windsurf) ;;
  *) echo "Unknown client: $CLIENT" >&2
     echo "Expected one of: claude-code, claude-desktop, cursor, windsurf" >&2
     exit 2 ;;
esac

echo "==> Checking Python (need 3.10+)"
PYTHON="$(command -v python3.12 || command -v python3.11 || command -v python3.10 || command -v python3)"
"$PYTHON" -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)' || {
  echo "ERROR: $PYTHON is older than 3.10." >&2
  echo "  macOS: brew install python@3.12" >&2
  echo "  Linux: sudo apt install -y python3.12 python3.12-venv" >&2
  exit 1
}
echo "    using $PYTHON ($("$PYTHON" -c 'import sys; print(sys.version.split()[0])'))"

echo "==> Installing notebooklm-py into $VENV"
[ -d "$VENV" ] || "$PYTHON" -m venv "$VENV"
"$VENV/bin/pip" install --quiet --upgrade pip
"$VENV/bin/pip" install --quiet --upgrade "notebooklm-py[browser,mcp]"
"$VENV/bin/playwright" install chromium >/dev/null 2>&1 || \
  echo "    WARN: playwright browser install failed; 'notebooklm login' may not work"

mkdir -p "$HOME/bin"
ln -sf "$VENV/bin/notebooklm" "$HOME/bin/notebooklm"
export PATH="$HOME/bin:$PATH"
echo "    installed $(notebooklm --version)"

if ! command -v uvx >/dev/null 2>&1; then
  echo
  echo "    NOTE: 'uvx' not found. The generated config launches the server via uvx."
  echo "    Install uv:  curl -LsSf https://astral.sh/uv/install.sh | sh"
  echo "    (or edit the config to point at $VENV/bin/notebooklm-mcp instead)"
fi

echo "==> Checking authentication"
if notebooklm auth check >/dev/null 2>&1; then
  echo "    already authenticated"
else
  echo "    Not authenticated. A browser will open — sign into Google,"
  echo "    then return to NotebookLM and follow the prompt."
  notebooklm login
fi

notebooklm doctor || true

echo "==> Registering MCP server with $CLIENT"
notebooklm mcp install "$CLIENT"

cat <<DONE

Done. Restart $CLIENT to load the server.

Verify by asking Claude to call 'server_info', or run:
  claude mcp list

Add this to your shell profile so the CLI stays on PATH:
  export PATH="\$HOME/bin:\$PATH"
DONE
