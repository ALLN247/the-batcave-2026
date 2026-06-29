# Campaign Brief — Sunday Is Yours Workbook Launch

*Routing: Multi-channel launch campaign → CAMPAIGN ARCHITECT*

**Status:** Ready to ship
**Owner:** Coach G / Mr. ALL'N
**Built by:** CAMPAIGN ARCHITECT (with HARRIET, HERALD, DIRECT RESPONSE COPYWRITER, LANDING PAGE BUILDER, BLOG POST WRITER, SOCIAL CONTENT ENGINE, VOICE OF COACH G)

---

## The offer

**Sunday Is Yours — The Educator's AI Agent Training for Buying Back Your Sunday Evenings**

- Format: 24-page digital workbook (PDF), 10-chapter motion training
- Price: **$37**, sold on **Gumroad**
- By: Mr. ALL'N (Chazmen Geames), The Batcave Architect

## The goal

1. Build the email list (Beehiiv) all summer.
2. Sell the $37 workbook.
3. Move buyers (and non-buyers who stick around) into **Builders of the Batcave** — $20/mo or $97/yr — for ongoing implementation support.

## The hero / the guide

- **Hero:** Ms. Renee — the overloaded urban educator. Grading at 11pm, planning at 5am, 4-5 preps, no district AI support, no budget for a $200/mo tool stack, scared AI either makes her look like she's cheating or makes her obsolete.
- **Guide:** Coach G — Lucius Fox energy. Not the hero. Hands her the Batcave; she's still the one who walks into that classroom every day.
- **Villain:** The technology equity gap. Not Ms. Renee. Not her school. The gap between what private schools can buy and what she's been given.

## StoryBrand arc for this campaign

| SB7 element | This campaign |
|---|---|
| Character | Ms. Renee — urban/faith-based educator, summer break, exhausted from the school year |
| Problem | External: no system for planning Sundays, AI tools feel like more work, not less. Internal: feels like she's failing if she can't keep up. Philosophical: it's not fair that wealthier schools hand teachers AI support and she gets none. |
| Guide | Coach G — empathy ("I built this because I live it — 200+ students, 4 preps, 46-minute periods") + authority (built it, uses it daily, gives it away at $37 instead of gatekeeping it) |
| Plan | 1) Get the workbook. 2) Build your first Agent Charter and Command Language this summer. 3) Walk into fall with your Sunday evenings back. |
| Call to Action | Direct: "Get Sunday Is Yours — $37." Transitional: "See what's inside the workbook" (free chapter/email sequence) |
| Failure to avoid | Burnout carries into another school year. Another Sunday lost to grading and lesson plans nobody sees. |
| Success | Sunday is yours. Curriculum drafted, comms triaged, lessons prepped — and Sunday is free. |

## Funnel

```
Hook (social/Threads/IG/LinkedIn)
   │
   ▼
Landing page (campaigns/sunday-is-yours/landing-page.html)
   │  → Beehiiv email capture (free preview / "what's inside")
   │  → Gumroad checkout ($37)
   ▼
Beehiiv welcome sequence (5 emails)
   │
   ▼
Buyers + non-buyers nurtured into:
   Builders of the Batcave — $20/mo or $97/yr
```

## Channels

- **Beehiiv** — primary distribution for blog posts, email sequence, list growth (per Coach G's explicit direction this campaign)
- **Threads** (primary), **LinkedIn**, **Instagram** — hooks and social posts, ALL'N League daily theme rotation where it fits (Money Monday / Transfer Tuesday / Wisdom Wednesday / Testimony Thursday / Freedom Friday)
- **Gumroad** — checkout for the $37 workbook (existing, unchanged)

## Brand guardrails applied (non-negotiable, per OID)

- Bible × Hip-Hop voice throughout. No corporate language, no bro-marketing hype, no false urgency/scarcity.
- Hero/Guide Check passed on every asset: Ms. Renee is the hero, Coach G is the guide.
- Royal Purple (#4B0082) + Old Gold (#CFB53B) only. **Never teal.**
- No outcome claims not evidenced by the workbook content itself.
- Web asset (landing page) is a standalone static HTML file — no Supabase/Vercel/React. (Note: if this needs to live on Coach G's actual web stack rather than as a static file, it should be rebuilt in **Base44** per the OID's web-build rule — flagged below in Open Questions.)

## Deliverables in this folder

| File | Specialist | Purpose |
|---|---|---|
| `landing-page.html` | LANDING PAGE BUILDER | Standalone launch page — workbook offer + Beehiiv signup + Gumroad CTA |
| `emails/01-welcome.md` ... `05-builders-upsell.md` | DIRECT RESPONSE COPYWRITER | Beehiiv welcome/nurture/offer/upsell sequence |
| `blog-posts/01-sunday-is-yours.md` | BLOG POST WRITER | Long-form Beehiiv post — the mindset shift (Helper → Operator) |
| `blog-posts/02-agent-charter.md` | BLOG POST WRITER | Long-form Beehiiv post — practical preview (the Agent Charter), drives to the workbook |
| `social/hooks.md` | HARRIET | 5 hook variations to drive traffic to the landing page |
| `social/posts.md` | HERALD / SOCIAL CONTENT ENGINE | Ready-to-post Threads/LinkedIn/IG content for the summer push |
| `voice-audit.md` | VOICE OF COACH G | Brand/voice sign-off checklist for every asset above |

## Open questions for Coach G

1. Landing page: ship as the static HTML in this repo, or should it be rebuilt inside Base44 (per the OID's "web builds use Base44 exclusively" rule)? Shipped here as static HTML for immediate use; flagging the rule so it's not silently broken.
2. Confirm the live Gumroad URL and Beehiiv signup/embed details — placeholders are used below (`[GUMROAD_LINK]`, `[BEEHIIV_EMBED]`) and need to be swapped for the real links before publishing.
3. Confirm whether "this summer" has a hard end date (e.g., a back-to-school cutoff) so the email sequence's send cadence can be scheduled against it.
