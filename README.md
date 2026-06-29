# The Batcave — 2026

**Organization:** Teach Transformations Strategies LLC
**Operator:** Coach G / Mr. ALL'N
**Brand tagline:** Fair Play. We ALL'N.

---

## What This Is

The Batcave is the operational command repository for the Teach Transformations AI agent system.

This is the executive operating layer — where the real orchestrator and specialist roster live, and where campaigns get built and shipped.

---

## Source of Truth

**`/command-center/`** is canonical. It holds the actual operating system in use:

| File | What it is |
|---|---|
| `TEACH-TRANSFORMATIONS-OID.md` | Organizational Intelligence Dossier — brand voice, audience, products, processes, guardrails |
| `AI-TEAM-ROSTER.md` | 20+ named specialist agents across 6 layers |
| `AIG-ORCHESTRATOR-UPGRADE.md` | **AI.G** — Chief of Staff promoted to Orchestrator, routing logic |
| `DAY1-SETUP-GUIDE.md` | Deployment instructions |

See [`RECONCILIATION.md`](./RECONCILIATION.md) for how this repo's earlier prototype agents (ATLAS / Scout OS / NOVA, in `/agents/`) map onto the real system. They're kept for history but are deprecated — `/command-center/` wins.

---

## Active Work

**`/campaigns/sunday-is-yours/`** — the launch campaign for the **Sunday Is Yours Workbook** ($37, Gumroad): summer excitement content, email list growth via Beehiiv, and the funnel into Builders of the Batcave ($20/mo).

---

## Repository Structure

```
the-batcave-2026/
├── command-center/          # SOURCE OF TRUTH — real orchestrator + roster + brand bible
│   ├── README.md
│   ├── TEACH-TRANSFORMATIONS-OID.md
│   ├── AI-TEAM-ROSTER.md
│   ├── AIG-ORCHESTRATOR-UPGRADE.md
│   └── DAY1-SETUP-GUIDE.md
├── campaigns/
│   └── sunday-is-yours/     # $37 workbook launch campaign
├── agents/                  # DEPRECATED prototypes — see RECONCILIATION.md
│   ├── ATLAS/
│   ├── ScoutOS/
│   └── NOVA/
├── docs/
│   └── agent-architecture.md  # historical — see RECONCILIATION.md
├── RECONCILIATION.md
└── README.md
```

---

## Mission

Close the technology equity gap in urban education by delivering AI-powered professional development solutions that save educators time and transform student outcomes.

*Fair Play. Build the Batcave.*
