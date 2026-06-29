# Command Center — Source of Truth

**Organization:** Teach Transformations Strategies LLC
**Owner:** Chazmen "Coach G" Geames (Mr. ALL'N)
**Version:** 2.0 — AICC 2.0 Day 1 (June 28, 2026)

This directory holds the **real, active** operating system for Coach G's AI team. Everything in here is canonical — it overrides any prior agent design in this repo that predates it (see `/RECONCILIATION.md` at the repo root).

## Files

| File | What it is |
|---|---|
| `TEACH-TRANSFORMATIONS-OID.md` | Organizational Intelligence Dossier — business identity, brand voice, audience personas, product/pricing ladder, key processes, proof/credibility, boundaries & guardrails. The brand bible. Read this before generating any content. |
| `AI-TEAM-ROSTER.md` | The full specialist roster (6 layers, 20+ named agents) the Orchestrator routes to. |
| `AIG-ORCHESTRATOR-UPGRADE.md` | Defines **AI.G** as Chief of Staff + Orchestrator, routing logic, and the routing-line convention (`*Routing: [Task category] → [Specialist name]*`). |
| `DAY1-SETUP-GUIDE.md` | Deployment instructions for the upgrade (additive only — never replaces existing context). |

## Orchestrator

**AI.G** is the real orchestrator — not a separate agent invented for this repo. AI.G:
1. Understands a task against the OID.
2. Checks the Team Roster for the best-fit specialist.
3. Runs that specialist if the platform supports it, or tells Coach G which file to load.
4. Falls back to handling the task directly if no specialist fits.

## Non-negotiable brand rules (from the OID — always apply)

- Bible × Hip-Hop voice. Direct, warm, faith-rooted, culturally authentic, service-first.
- Hero/Guide Check on every output: the **educator** is the hero (Batman). Coach G is the **guide** (Lucius Fox), never the hero.
- Brand colors: **Royal Purple (#4B0082) + Old Gold (#CFB53B). Never teal.**
- Never position AI as replacing teachers. Never invent client facts — pull from source docs only.
- Web builds: Base44 only. Never Supabase/Vercel/React stacks.
