# bmad-autodoc

Reusable documentation starter pack for any repository.

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
  updates.md       # docs updates log
project-context.md # minimal guidance block to inject into target repos
scripts/
  inject-docs.sh   # plain Bash injector
```

## Injector CLI

Script: `scripts/inject-docs.sh`

What it does:

1. Copies this repo's `docs/` folder into `TARGET_REPO/docs`
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
5. Maintain `/docs/updates.md` as docs evolve
