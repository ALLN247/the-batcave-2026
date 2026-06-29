# Reconciliation Note — ATLAS / Scout OS / NOVA vs. the Real System

**Date:** 2026-06-29

## What happened

Early in this repo's history, `/agents/ATLAS/`, `/agents/ScoutOS/`, and `/agents/NOVA/` were designed from scratch as a three-layer agent system (executive coordination / cognition / marketing) based on a creative brief at the time. That work was a reasonable prototype given the information available — but Coach G's **real** operating system already existed and is far more developed.

## The real system (now canonical — see `/command-center/`)

- **Orchestrator:** AI.G (Chief of Staff, promoted to Orchestrator as of AICC 2.0 Day 1, June 28, 2026) — not ATLAS.
- **Specialist roster:** 20+ named, purpose-built agents across 6 layers (Executive, Content & Voice, Operations, Intelligence, Product & Revenue, Education) — see `command-center/AI-TEAM-ROSTER.md`. This already covers everything ATLAS/Scout OS/NOVA were designed to do, and far more granularly.
- **Brand bible:** `command-center/TEACH-TRANSFORMATIONS-OID.md` — the actual business identity, voice, audience, products, processes, and guardrails. This supersedes any brand assumptions baked into the old agent designs.

## Mapping old → real

| Invented agent | Real equivalent(s) |
|---|---|
| ATLAS (Executive Chief of Staff) | **AI.G** (Orchestrator + Chief of Staff), **ARCHITECT** (Ops Controller) |
| Scout OS (cognition/synthesis/generative design) | **LINK** (Ecosystem Architect — designs new agent roles), **REGINA** (Deep Research), **THE ALCHEMIST** (Knowledge Engine) |
| NOVA (Chief Marketing Officer) | **CAMPAIGN ARCHITECT**, **HERALD**, **HARRIET**, **DIRECT RESPONSE COPYWRITER**, **LANDING PAGE BUILDER**, **SOCIAL CONTENT ENGINE**, **BLOG POST WRITER**, **VOICE OF COACH G** |

## Disposition

`/agents/ATLAS/`, `/agents/ScoutOS/`, `/agents/NOVA/`, and `/docs/agent-architecture.md` are kept in place as historical prototype work — they are **not deleted**, but they are **deprecated** and no longer represent the operating system in use. All new work in this repo follows `/command-center/` as the source of truth.

Going forward: any task in this repo gets routed against `command-center/AI-TEAM-ROSTER.md`, voice-checked against `command-center/TEACH-TRANSFORMATIONS-OID.md`, and opened with the routing-line convention from `command-center/AIG-ORCHESTRATOR-UPGRADE.md` where applicable.
