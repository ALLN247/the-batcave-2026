# Environment Variables

Every variable the `notebooklm-py` MCP server reads, verified against v0.8.2.

## Transport / bind

| Variable | Default | Notes |
|---|---|---|
| `NOTEBOOKLM_MCP_TRANSPORT` | `stdio` | `stdio` or `http`. Path A uses stdio; Path B needs `http`. |
| `NOTEBOOKLM_MCP_HOST` | loopback | Bind address. A non-loopback value **requires** `ALLOW_EXTERNAL_BIND=1`. |
| `NOTEBOOKLM_MCP_PORT` | `9420` | HTTP transport only. |
| `NOTEBOOKLM_MCP_ALLOW_EXTERNAL_BIND` | unset | `1` opts into a non-loopback bind. Auth then becomes mandatory. |
| `NOTEBOOKLM_MCP_TRUST_PROXY` | unset | `1` trusts proxy client-IP headers (`CF-Connecting-IP`). Set **only** behind a proxy you control — otherwise the login throttle can be spoofed. |

The loopback bind is protected by a DNS-rebinding guard that rejects any request whose
`Host` header is not a loopback literal (`403 Host not allowed`). Without it, a
malicious web page could resolve its own domain to `127.0.0.1` and drive your server.
The guard is skipped on an external bind — where bearer/OAuth auth is mandatory instead.

## Authentication

| Variable | Notes |
|---|---|
| `NOTEBOOKLM_MCP_TOKEN` | Static bearer token. Good for Claude Code/Desktop over HTTP. claude.ai **cannot** use this — its connector UI has no bearer field. |
| `NOTEBOOKLM_MCP_OAUTH_PASSWORD` | Password gating the self-hosted OAuth provider. **Minimum 16 chars, enforced at startup.** Use 32+. |
| `NOTEBOOKLM_MCP_OAUTH_BASE_URL` | Public origin of the OAuth authorization server. Must be a **bare HTTPS origin** — `https://host`, no path. |
| `NOTEBOOKLM_MCP_OAUTH_STATE_PATH` | Override for the OAuth state file. Default is derived from the base URL (`<home>/oauth/<slug>.json`). |
| `NOTEBOOKLM_MCP_PUBLIC_URL` | Public base for file-transfer links. Falls back to `OAUTH_BASE_URL`. |

Bearer and OAuth compose via FastMCP's `MultiAuth` — one server can serve Claude Code
by bearer and claude.ai by OAuth simultaneously.

### Why a password, and why it must be strong

claude.ai only speaks OAuth, so the server *is* an OAuth 2.1 authorization server. It
subclasses FastMCP's `InMemoryOAuthProvider` (full DCR, PKCE, token issue/refresh/revoke)
rather than hand-rolling the protocol, then adds:

- a password gate that never touches `/authorize` — the validated `redirect_uri` never
  enters the browser, making an open redirect structurally impossible
- per-IP login throttling and capped dynamic client registration (pre-auth DoS)
- atomic `0600` persistence so a restart doesn't force re-authorization

Your password is the **primary brute-force defense** on a URL that fronts a full Google
account credential. Generate it, don't invent it:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

**Rotating the password does not revoke issued refresh tokens.** To actually revoke:
delete the OAuth state file, then restart.

## Profile / backend

| Variable | Default | Notes |
|---|---|---|
| `NOTEBOOKLM_PROFILE` | `default` | Named auth profile. Useful for separating school and personal Google accounts. |
| `NOTEBOOKLM_BACKEND` | `web` | `web` or `android`. |
| `NOTEBOOKLM_HOME` | `~/.notebooklm` | Root of config, profiles, and credentials. |
| `NOTEBOOKLM_AUTH_JSON` | unset | Inline storage-state JSON. For sandboxes that can't read local files. **Puts a full-account credential in an environment variable — avoid unless required.** |
| `NOTEBOOKLM_SERVER_TOKEN` | unset | Bearer for the separate REST server (`notebooklm.server`), not the MCP server. |

## Behavior

| Variable | Notes |
|---|---|
| `NOTEBOOKLM_MCP_CHAT_CONCURRENCY` | Max concurrent chat asks. |
| `NOTEBOOKLM_MCP_STRICT_IDS` | Require exact IDs, disabling name/partial-ID resolution. |
| `NOTEBOOKLM_MCP_UPLOAD_WIDGET` | Controls the browser upload widget for `source_add`. |
| `NOTEBOOKLM_LOG_LEVEL` | Also settable via `--log-level`. |

## Files to protect

All are full-account secrets. Keep them `0600`, never commit them, back them up encrypted:

```
~/.notebooklm/profiles/<profile>/storage_state.json   # Google session cookies
~/.notebooklm/profiles/<profile>/master_token.json    # android backend
~/.notebooklm/oauth/<slug>.json                       # OAuth clients + refresh tokens
```
