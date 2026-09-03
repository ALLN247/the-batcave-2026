#!/usr/bin/env bash
# Verify a running remote MCP server before wiring it into claude.ai.
# Usage: ./verify-connection.sh https://nlm.example.com
set -uo pipefail

BASE="${1:-}"
[ -n "$BASE" ] || { echo "Usage: $0 <base-url>   e.g. $0 https://nlm.example.com" >&2; exit 2; }
BASE="${BASE%/}"

pass=0; fail=0
ok()   { echo "  PASS  $*"; pass=$((pass+1)); }
bad()  { echo "  FAIL  $*"; fail=$((fail+1)); }

echo "Verifying $BASE"
echo

echo "[1/4] OAuth authorization-server metadata"
code=$(curl -s -o /tmp/nlm_as.json -w '%{http_code}' --max-time 15 \
       "$BASE/.well-known/oauth-authorization-server" 2>/dev/null || echo 000)
if [ "$code" = "200" ]; then
  ok "discovery reachable (200)"
  python3 - <<'PY' 2>/dev/null || echo "        (install python3 to parse endpoints)"
import json
d = json.load(open("/tmp/nlm_as.json"))
for k in ("issuer","authorization_endpoint","token_endpoint","registration_endpoint"):
    if d.get(k): print(f"        {k}: {d[k]}")
PY
else
  bad "discovery returned $code (expected 200)"
  echo "        - is the server running with OAUTH_PASSWORD + OAUTH_BASE_URL set?"
  echo "        - is OAUTH_BASE_URL a bare origin (no /mcp path)?"
  echo "        - is the tunnel/proxy up?"
fi

echo
echo "[2/4] Protected-resource metadata"
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 \
       "$BASE/.well-known/oauth-protected-resource" 2>/dev/null || echo 000)
[ "$code" = "200" ] && ok "reachable (200)" || echo "  INFO  returned $code (not always served; non-fatal)"

echo
echo "[3/4] MCP endpoint rejects unauthenticated calls"
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 -X POST "$BASE/mcp" \
       -H 'Content-Type: application/json' \
       -H 'Accept: application/json, text/event-stream' \
       -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"verify","version":"1"}}}' \
       2>/dev/null || echo 000)
case "$code" in
  401|403) ok "$code — endpoint is live and correctly requires auth" ;;
  200)     bad "200 unauthenticated — the endpoint is NOT protected. Do not expose this." ;;
  404)     bad "404 — wrong path. The connector URL must end in /mcp" ;;
  000)     bad "unreachable — check the tunnel/proxy and that the server is running" ;;
  *)       bad "unexpected status $code" ;;
esac

echo
echo "[4/4] Login page"
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$BASE/login" 2>/dev/null || echo 000)
case "$code" in
  200|400) ok "$code — /login is served" ;;
  *)       echo "  INFO  /login returned $code (needs a valid ?sid=; non-fatal)" ;;
esac

echo
echo "-----------------------------------------------"
echo "  $pass passed, $fail failed"
if [ "$fail" -eq 0 ]; then
  echo
  echo "  Ready. In claude.ai: Settings -> Connectors -> Add custom connector"
  echo "  URL: $BASE/mcp"
else
  echo
  echo "  See ../README.md#troubleshooting"
fi
rm -f /tmp/nlm_as.json
[ "$fail" -eq 0 ]
