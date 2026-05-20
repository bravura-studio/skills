# Skills

Packaged workflows for BUILD.FUN.FREE agents. See [skills-standard.md](../references/skills-standard.md) for the spec (AD-036).

## Structure

```
skills/
  sprint/             # Engineering sprint chain (Think → Plan → Build → Review → Test → Ship → Reflect)
    sprint-plan/      # Think: forcing questions, design doc
    sprint-review/    # Plan: lock scope + architecture
    code-review/      # Review: pre-merge audit
    qa-check/         # Test: verification checklist
    ship-pr/          # Ship: create PR
    retro/            # Reflect: extract learnings
  content/            # Content pipeline (Scripta)
    content-research/ # Research: vault + web deep dive
    content-draft/    # Write: draft following brand guide
    content-edit/     # QA: fact-check, tone, SEO
    content-publish/  # Ship: deploy to andochoa.com
  ops/                # Operational skills (infra, maintenance, heartbeats)
  knowledge/          # Knowledge management skills (vault hygiene, dream cycle)
  _learnings/         # Per-project learnings.jsonl files
```

## Usage

Skills are invoked via `/skill-name` in Claude Code or referenced in Paperclip agent personas.

