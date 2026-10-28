# dlm-app — agent instructions

- Spec: `docs/PLAN.md` is authoritative. Conventions: `docs/CONVENTIONS.md` (mandatory).
  Decisions: `docs/adr/`.
- Intent records: this repository uses intentline — see the block below and
  `.claude/skills/intentline/SKILL.md`.
- The daemon this app talks to lives in `sabadia/dlm-server`; if a screen needs
  something it cannot do, the task depends on a `P13.x` issue there. Do not work
  around it in the app.

@AGENTS.md
