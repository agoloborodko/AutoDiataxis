# AutoDiataxis

Reusable documentation starter pack for any repository.

Version: 1.0.0 (`VERSION`). There was no earlier version number, tag, or release. 1.0.0 is the first declared contract. It removes `docs/updates.md`: a new project records each meaningful change as its own file under `docs/updates/` and does not receive this repository's history.

## AI Agent Workflow

This project is tailored for working with AI agents, specifically [BMAD-METHOD](https://docs.bmad-method.org/), but it should work with any agent.

To use it with a given agent, point that agent's repo entrypoint file (`AGENTS.md`, `CLAUDE.md`, or similar) to `project-context.md`.

Key feature: agents read the governance/maintenance instructions and update documentation when changes require it.

It provides:

- Documentation governance rules (`docs/governance/`)
- Documentation maintenance workflows/checklists (`docs/maintenance/`)
- Canonical templates (`docs/_templates/`)
- A minimal project-specific docs scaffold that can self-emerge over time (`docs/app/`)
- A simple Bash CLI to inject the docs package into another repo

## Repository Layout

```text
docs/
  _templates/      # canonical doc template + checklist
  governance/      # rules: triggers, link/index rules, review enforcement, Diataxis
  maintenance/     # docs update process + review checklist
  app/             # generic project-specific scaffold (Diataxis-oriented)
  index.md         # root docs index
  updates/         # one file per meaningful change; the starter ships this directory empty
project-context.md # minimal guidance block to inject into target repos
scripts/
  inject-docs.sh   # plain Bash injector
```

## Injector CLI

Script: `scripts/inject-docs.sh`

What it does:

1. Copies this repo's `docs/` folder into `TARGET_REPO/docs`, without `docs/updates.md` or dated files in `docs/updates/`
2. Appends this repo's `project-context.md` to `TARGET_REPO/project-context.md`
3. Adds marker comments so the context block is not appended twice

### Usage

```bash
scripts/inject-docs.sh /path/to/target-repo
```

If the target repo already has a `docs/` folder, the script stops with an error.

To replace the target `docs/` folder:

```bash
scripts/inject-docs.sh --overwrite-docs /path/to/target-repo
```

## Notes / Assumptions

- The script is intentionally simple and Bash-first.
- Reinstall/update synchronization is not currently supported beyond replacing `docs/` with `--overwrite-docs`.
- The injected `project-context.md` block is append-once (idempotent via markers).
- The target repository is expected to author its own content in `docs/app/`.

## Quick Start (Target Repo)

After injection into a target repo:

1. Open `/docs/index.md`
2. Keep governance/maintenance rules as-is unless intentionally changing process
3. Replace placeholders in `/docs/app/overview/project-overview.md`
4. Add project-specific docs under `/docs/app/` using Diataxis placement rules
5. Record each meaningful documentation change as one file under `/docs/updates/`, with frontmatter, a summary, and links. The injected directory starts empty.
