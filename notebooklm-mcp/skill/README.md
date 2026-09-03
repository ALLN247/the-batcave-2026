# Replacing the stale `notebooklm` skill

The `notebooklm` skill synced to this Claude account is pinned to **v0.3.4**.
Upstream is **v0.8.2**. This directory holds the official upstream skill and the
upload archive to replace it with.

- [`SKILL.md`](./SKILL.md) — the official v0.8.2 skill, for reading/diffing
- [`notebooklm-skill-0.8.2.zip`](./notebooklm-skill-0.8.2.zip) — the upload archive

Both were produced by `notebooklm skill package` from `notebooklm-py==0.8.2`.

---

## What is actually wrong with v0.3.4

Checked command by command against a real 0.8.2 install. Being precise here, because
the failure mode is not the obvious one.

**The commands still work.** `artifact list`, `generate audio`, `download audio`,
`source add-research`, `research status`, `history`, `language set`, `ask`, `use`,
`status` — all still valid in 0.8.2. The `artifact` CLI group was **not** renamed.
(`studio_*` is the *MCP tool* naming, which is a different surface — see the note at
the bottom.)

The real problems are these three:

### 1. The credential paths are wrong — this one actually breaks

v0.3.4 assumes a flat layout. 0.8.2 uses per-profile directories:

| | Path |
|---|---|
| Skill v0.3.4 assumes | `~/.notebooklm/storage_state.json` |
| 0.8.2 actually uses | `~/.notebooklm/profiles/<profile>/storage_state.json` |

Consequences: the skill's recovery step (`rm -rf ~/.notebooklm/browser_profile
~/.notebooklm/storage_state.json`) deletes nothing, so "delete and retry" silently
fails to reset anything. Its Cowork generator reads a file that does not exist.

### 2. Its auth check gives false green lights

v0.3.4 runs a bare `notebooklm auth check`, which largely inspects the cookie file.
A file can be present and well-formed while the session behind it is dead. The 0.8.2
skill validates for real:

```bash
notebooklm auth check --test --json
# require: .status == "ok"  AND  .checks.token_fetch == true
```

That is the difference between "a file exists" and "Google still accepts this session."

### 3. It is missing roughly a third of the CLI

Entire command groups v0.3.4 never mentions:

`doctor` · `label` · `collection` · `share` · `summary` · `metadata` ·
`suggest-prompts` · `suggest-next-steps` · `configure` · `rename` · `mcp` · `agent` ·
`auth refresh` · `auth inspect` · `auth import-cookies` · `source add-book` ·
`source books` · `generate cinematic-video` · `artifact export/retry/copy/choices`

Most notable absence: **`notebooklm doctor`**, the one command that diagnoses exactly
the profile/auth problems v0.3.4 leaves you guessing at.

### Bonus: its Cowork recipe is the discouraged credential path

v0.3.4 walks you through stripping your Google cookies and pasting them inline into a
skill file as `NOTEBOOKLM_AUTH_JSON`. The 0.8.2 skill explicitly demotes this —
"inline `NOTEBOOKLM_AUTH_JSON` is only a short-lived fallback" — and points at durable
master-token auth (`notebooklm login --master-token --account <email>`) instead.

A skill file with your session cookies pasted into it is a full-account credential
sitting in a document that syncs. If you built one of those from the old skill, that
file should be considered compromised: rotate it by running `notebooklm auth logout`,
signing in again, and deleting the old copy.

---

## How to replace it

The stale skill is **synced from your claude.ai account**, so it has to be replaced
there — editing a local copy will just be overwritten on the next sync.

1. Download `notebooklm-skill-0.8.2.zip` from this directory
2. In claude.ai: **Settings → Capabilities → Skills**
3. **Delete** the existing `notebooklm` skill (same name = a conflict, not an upgrade)
4. **Upload** the zip
5. Confirm the new one reports `v0.8.2`

The archive works for both chat and Cowork.

### Keeping it current

Regenerate whenever you upgrade the package, rather than hand-editing:

```bash
pip install --upgrade "notebooklm-py[browser,mcp]"
notebooklm skill package -o ./notebooklm-skill.zip --force
```

For Claude Code specifically, skip the archive entirely:

```bash
notebooklm skill install     # writes to ~/.claude/skills/
notebooklm skill status      # version + content-integrity check
```

**Do not fork this skill.** Forking it is how it went stale in the first place — a
pinned copy stops tracking the CLI it documents, and you find out via commands that
quietly point at the wrong paths. Keep Batcave-specific material in this repo
alongside it, not inside it.

---

## Skill or MCP?

They are different surfaces and you can run both:

|  | **Skill** | **MCP server** |
|---|---|---|
| How it works | Teaches Claude to drive the `notebooklm` CLI via shell | Claude calls 38 typed tools directly |
| Needs a shell | **Yes** | No |
| Works in claude.ai web/mobile | No | **Yes** (Path B) |
| Tool naming | `notebooklm artifact list` | `studio_list` |

In Claude Code, the skill is the lighter option. For claude.ai — where there is no
shell — the MCP connector is the only one that works. See [`../README.md`](../README.md).
