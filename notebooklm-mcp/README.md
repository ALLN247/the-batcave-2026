# NotebookLM ↔ Claude — MCP Connection

Wiring Google NotebookLM into Claude as a Model Context Protocol server, so Claude can
create notebooks, add sources, run research, chat against your sources, and generate
Studio artifacts (audio overviews, video, slide decks, quizzes, flashcards, reports)
without you leaving the chat.

**The headline: you do not have to build this server.** It already exists.
`notebooklm-py` (v0.8.2, MIT, by Teng Lin) ships a complete, hardened MCP server
inside the package — 38 tools, bearer auth, and a self-hosted OAuth 2.1 provider built
specifically because "claude.ai's custom-connector UI speaks only OAuth." The work here
is wiring and hosting, not authoring.

- Package: https://pypi.org/project/notebooklm-py/
- Source: https://github.com/teng-lin/notebooklm-py

> **Read this before you start.** This is an *unofficial* client. It drives NotebookLM
> by replaying your logged-in Google session, not through a public Google API. See
> [Risks](#risks-read-this-part) — it matters more than the install steps.

---

## Pick your path

There are two very different jobs hiding under "connect NotebookLM to my Claude
account." They cost different amounts of effort. Pick deliberately.

| | **Path A — Local** | **Path B — Remote** |
|---|---|---|
| Works in | Claude Code, Claude Desktop, Cursor, Windsurf | **claude.ai** (web + mobile), Cowork |
| Transport | stdio | streamable HTTP + OAuth |
| Setup time | ~10 minutes | ~1–2 hours |
| Needs a public URL | No | **Yes** |
| Needs an always-on machine | No | **Yes** |
| Ongoing cost | $0 | $0–$5/mo |

**If you want NotebookLM inside claude.ai on your phone, you need Path B.** There is no
way around the always-on host: claude.ai is in Anthropic's cloud and has to reach your
server over the public internet. Path A's server only exists while your laptop is
running the client.

Most people should **do Path A first** even if Path B is the goal. It proves your Google
auth works and lets you exercise all 38 tools before you take on hosting.

---

## Prerequisites (both paths)

- **Python 3.10+** (3.11 or 3.12 recommended)
- **A Google account with NotebookLM access**
- **`uv`** — recommended, since the generated config launches the server with `uvx`:
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

Install the CLI into its own virtualenv so you always have it on hand:

```bash
python3 -m venv ~/.notebooklm-venv
source ~/.notebooklm-venv/bin/activate
pip install "notebooklm-py[browser,mcp]"
playwright install chromium

mkdir -p ~/bin && ln -sf ~/.notebooklm-venv/bin/notebooklm ~/bin/notebooklm
export PATH="$HOME/bin:$PATH"   # add this line to ~/.zshrc or ~/.bashrc
```

Then authenticate once. This opens a browser — sign into Google normally:

```bash
notebooklm login
notebooklm doctor     # profile setup, auth status, migration check
notebooklm list       # should print your notebooks
```

`notebooklm doctor` is the command to run first whenever anything misbehaves.

> **Auth is required at server startup.** The MCP server validates your Google session
> when it boots — an unauthenticated or expired profile makes the process exit rather
> than start and fail later. If the server won't start, run `notebooklm doctor` before
> you debug anything else.

---

## Path A — Local (Claude Code / Desktop)

One command:

```bash
notebooklm mcp install claude-code
```

Supported clients: `claude-desktop`, `claude-code`, `cursor`, `windsurf`.

It writes an idempotent server block and never clobbers your other MCP servers:

```json
{
  "mcpServers": {
    "notebooklm": {
      "command": "uvx",
      "args": ["--from", "notebooklm-py[mcp]", "notebooklm-mcp"]
    }
  }
}
```

Restart the client. Verify by asking Claude to call `server_info`, or:

```bash
claude mcp list
```

That's Path A. If you only work in Claude Code or Desktop, you are done.

---

## Path B — Remote (claude.ai custom connector)

This is what puts NotebookLM in claude.ai on every device you sign into.

### How it fits together

```
claude.ai  ──HTTPS──>  your public URL  ──>  notebooklm-mcp  ──>  NotebookLM
              (OAuth)      (tunnel/VPS)        (:9420/mcp)      (your Google session)
```

Anthropic's servers make an outbound call to *your* URL. That URL must be public HTTPS
and reachable whenever you want to use the connector.

### Step 1 — Set the environment

The server refuses a non-loopback bind unless you explicitly opt in **and** configure
auth. That is a deliberate safety interlock, not an obstacle to route around.

```bash
export NOTEBOOKLM_MCP_TRANSPORT=http
export NOTEBOOKLM_MCP_HOST=0.0.0.0
export NOTEBOOKLM_MCP_PORT=9420
export NOTEBOOKLM_MCP_ALLOW_EXTERNAL_BIND=1

# OAuth — required for claude.ai. Both must be set together.
export NOTEBOOKLM_MCP_OAUTH_PASSWORD='<32+ random chars>'
export NOTEBOOKLM_MCP_OAUTH_BASE_URL='https://notebooklm.yourdomain.com'

# Only if you terminate TLS at a trusted proxy (Cloudflare, Caddy, nginx):
export NOTEBOOKLM_MCP_TRUST_PROXY=1
```

Generate the password properly — it gates a full-account credential:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Hard requirements the server enforces at startup:

- **Password ≥ 16 characters.** Shorter values are rejected outright. Use 32+.
- **`OAUTH_BASE_URL` must be a bare HTTPS origin** — `https://host` with no path.
  Not `https://host/mcp`. The OAuth routes (`/authorize`, `/token`, `/register`,
  `/login`, `/.well-known/*`) mount at the root, so a path would make discovery
  advertise endpoints that don't exist.

Full variable reference: [`ENVIRONMENT.md`](./ENVIRONMENT.md).

### Step 2 — Get a public HTTPS URL

**Cloudflare Tunnel (recommended).** No open inbound ports, free, works from a home
machine behind NAT:

```bash
cloudflared tunnel login
cloudflared tunnel create notebooklm-mcp
cloudflared tunnel route dns notebooklm-mcp notebooklm.yourdomain.com
cloudflared tunnel run --url http://127.0.0.1:9420 notebooklm-mcp
```

**Alternative — a small VPS** ($4–5/mo) with Caddy in front for automatic TLS. See
[`deploy/Caddyfile`](./deploy/Caddyfile).

Avoid ephemeral `trycloudflare.com` URLs for anything but a smoke test — the hostname
changes on restart, and the OAuth state file is keyed on the base URL, so every restart
forces you to re-authorize.

### Step 3 — Run it as a service

Don't babysit a terminal. Templates are included:

- Linux: [`deploy/notebooklm-mcp.service`](./deploy/notebooklm-mcp.service) (systemd)
- macOS: [`deploy/com.notebooklm.mcp.plist`](./deploy/com.notebooklm.mcp.plist) (launchd)

```bash
./scripts/serve-remote.sh          # foreground, for testing first
```

### Step 4 — Add the connector in claude.ai

1. **Settings → Connectors → Add custom connector**
2. URL: `https://notebooklm.yourdomain.com/mcp`  ← note the `/mcp` path here
3. Claude discovers the OAuth metadata and redirects you to your own `/login` page
4. Enter your `NOTEBOOKLM_MCP_OAUTH_PASSWORD`
5. Approve — the 38 tools appear

The **base URL** is bare (`https://host`); the **connector URL** includes `/mcp`. That
asymmetry trips people up. Base URL is where OAuth lives; `/mcp` is where MCP lives.

Verify:

```bash
./scripts/verify-connection.sh https://notebooklm.yourdomain.com
```

---

## What Claude can do once connected (38 tools)

| Group | Tools |
|---|---|
| **Notebooks** | `notebook_create` `notebook_list` `notebook_rename` `notebook_delete` `notebook_describe` |
| **Sources** | `source_add` `source_list` `source_read` `source_rename` `source_delete` `source_wait` `source_add_drive_file` `source_add_play_book` `source_list_play_books` |
| **Chat** | `chat_ask` `chat_start` `chat_status` `chat_cancel` `chat_configure` `suggest_prompts` |
| **Studio** | `studio_generate` `studio_list` `studio_status` `studio_download` `studio_retry` `studio_rename` `studio_delete` |
| **Research** | `research_start` `research_status` `research_import` `research_cancel` |
| **Sharing** | `share_status` `share_set_access` `share_set_user` `share_remove_user` |
| **Notes/Meta** | `note_save` `server_info` `await_upload` |

`studio_generate` covers audio overviews, video, cinematic video, slide decks,
infographics, mind maps, data tables, quizzes, flashcards, and reports.

Generation is slow and rate-limited by Google — audio 10–20 min, video 15–45 min. Use
the `_start` / `_status` pairs rather than blocking, and expect occasional failures that
`studio_retry` clears.

---

## Risks (read this part)

**This is an unofficial integration.** It authenticates by replaying your Google
session cookies. Consequences, stated plainly:

1. **It can break without warning.** Google changes NotebookLM's internals whenever it
   likes. Pin a known-good version and expect to update.
2. **Terms of Service.** Automating a Google product through a private interface may
   conflict with Google's ToS. You are accepting that risk on your own account. Do not
   put student PII or anything covered by FERPA through it, and do not deploy it to a
   district or roll it out to staff without cleared approval.
3. **The stored session is a full-account credential.** `storage_state.json`,
   `master_token.json`, and the OAuth state file are as sensitive as your Google
   password. Keep them `0600` and never commit them.
4. **Path B publishes a door to your Google account.** Anyone with your URL *and*
   password reaches your notebooks. Use a 32+ character random password, keep the
   server patched, and shut the tunnel down when you're not using it.
5. **Revocation is manual.** Rotating the OAuth password does **not** revoke tokens
   already issued. Real revocation is: delete the OAuth state file, then restart.

Nothing in this repo stores a credential. The scripts read them from your environment.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Server exits at startup | Not authenticated | `notebooklm login`, then `notebooklm doctor` |
| `403 Host not allowed` | Non-loopback `Host` header on a loopback bind | Set `ALLOW_EXTERNAL_BIND=1` + auth, or fix the proxy |
| `too weak` at startup | Password under 16 chars | Use 32+ random chars |
| `partially configured` | Only one OAuth var set | Set **both** password and base URL |
| claude.ai discovery fails | Base URL has a path | Base must be bare `https://host` |
| Connector connects, no tools | Wrong connector URL | Append `/mcp` |
| Auth works, then dies days later | Google session expired | Re-run `notebooklm login` |
| `uvx` not found | `uv` not installed | Install `uv`, or swap the config to an absolute binary path |

Diagnostics:

```bash
notebooklm doctor
notebooklm auth check
notebooklm mcp install claude-code --config-path ./preview.json   # dry-run the block
```

---

## Note on the existing `notebooklm` skill

The skill currently synced into this account is built against **v0.3.4**. Upstream is
**v0.8.2** and the surface has moved substantially — `artifact *` became `studio *`,
and `profile`, `label`, `collection`, `share`, `copy`, `doctor`, and `mcp` are all new.
The old skill's command table will produce commands that no longer exist.

`notebooklm-py` now ships its own maintained skill:

```bash
notebooklm skill install     # then: notebooklm skill status
```

Prefer that over the pinned copy — it tracks the CLI it documents.
