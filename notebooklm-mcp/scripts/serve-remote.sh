#!/usr/bin/env bash
# Path B — run the MCP server over HTTP for a claude.ai custom connector.
#
# Reads configuration from the environment. It stores no secrets itself.
# Set these before running (see ../ENVIRONMENT.md):
#
#   NOTEBOOKLM_MCP_OAUTH_PASSWORD   32+ random chars (16 is the hard minimum)
#   NOTEBOOKLM_MCP_OAUTH_BASE_URL   bare https origin, e.g. https://nlm.example.com
#
set -euo pipefail

VENV="${NOTEBOOKLM_VENV:-$HOME/.notebooklm-venv}"
PY="$VENV/bin/python"
[ -x "$PY" ] || { echo "ERROR: no venv at $VENV. Run setup-local.sh first." >&2; exit 1; }

export NOTEBOOKLM_MCP_TRANSPORT="${NOTEBOOKLM_MCP_TRANSPORT:-http}"
export NOTEBOOKLM_MCP_HOST="${NOTEBOOKLM_MCP_HOST:-127.0.0.1}"
export NOTEBOOKLM_MCP_PORT="${NOTEBOOKLM_MCP_PORT:-9420}"

fail() { echo "ERROR: $*" >&2; exit 1; }

# --- preflight -------------------------------------------------------------
PASS="${NOTEBOOKLM_MCP_OAUTH_PASSWORD:-}"
BASE="${NOTEBOOKLM_MCP_OAUTH_BASE_URL:-}"
TOKEN="${NOTEBOOKLM_MCP_TOKEN:-}"

if [ -n "$PASS" ] || [ -n "$BASE" ]; then
  [ -n "$PASS" ] && [ -n "$BASE" ] || \
    fail "OAuth is partially configured. Set BOTH NOTEBOOKLM_MCP_OAUTH_PASSWORD and NOTEBOOKLM_MCP_OAUTH_BASE_URL."
  [ "${#PASS}" -ge 16 ] || \
    fail "NOTEBOOKLM_MCP_OAUTH_PASSWORD is ${#PASS} chars; minimum is 16. Use 32+:
  python3 -c 'import secrets; print(secrets.token_urlsafe(32))'"
  [ "${#PASS}" -ge 32 ] || echo "WARN: password is ${#PASS} chars. 32+ recommended."
  case "$BASE" in
    https://*) ;;
    *) fail "NOTEBOOKLM_MCP_OAUTH_BASE_URL must start with https:// (got: $BASE)" ;;
  esac
  # must be a BARE origin: no path segment after the host
  if [ -n "$(printf '%s' "${BASE#https://}" | sed 's|/*$||' | grep '/' || true)" ]; then
    fail "NOTEBOOKLM_MCP_OAUTH_BASE_URL must be a bare origin with no path.
  Got:      $BASE
  Expected: https://$(printf '%s' "${BASE#https://}" | cut -d/ -f1)
  (The connector URL you paste into claude.ai is the one that ends in /mcp.)"
  fi
fi

# A non-loopback bind needs the explicit opt-in AND some form of auth.
case "$NOTEBOOKLM_MCP_HOST" in
  127.0.0.1|::1|localhost) ;;
  *)
    [ "${NOTEBOOKLM_MCP_ALLOW_EXTERNAL_BIND:-}" = "1" ] || \
      fail "Binding to $NOTEBOOKLM_MCP_HOST requires NOTEBOOKLM_MCP_ALLOW_EXTERNAL_BIND=1"
    [ -n "$PASS" ] || [ -n "$TOKEN" ] || \
      fail "An external bind requires auth: set NOTEBOOKLM_MCP_OAUTH_PASSWORD (claude.ai) or NOTEBOOKLM_MCP_TOKEN (bearer)."
    ;;
esac

# The server exits at startup if the Google session is missing or expired.
"$VENV/bin/notebooklm" auth check >/dev/null 2>&1 || \
  fail "NotebookLM is not authenticated. Run: notebooklm login   (then: notebooklm doctor)"

# --- report ----------------------------------------------------------------
echo "Starting notebooklm-mcp"
echo "  bind          : $NOTEBOOKLM_MCP_HOST:$NOTEBOOKLM_MCP_PORT"
echo "  profile       : ${NOTEBOOKLM_PROFILE:-default}"
if [ -n "$BASE" ]; then
  echo "  oauth base    : $BASE"
  echo "  connector URL : ${BASE%/}/mcp     <- paste THIS into claude.ai"
else
  echo "  oauth         : disabled (loopback / bearer only)"
fi
echo

exec "$PY" -m notebooklm.mcp \
  --transport http \
  --host "$NOTEBOOKLM_MCP_HOST" \
  --port "$NOTEBOOKLM_MCP_PORT" \
  --log-level "${NOTEBOOKLM_LOG_LEVEL:-INFO}"
