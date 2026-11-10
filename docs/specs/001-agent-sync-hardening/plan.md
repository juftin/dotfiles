# Implementation plan

## Technical context and constitution

Node.js ESM, node:test, Bash, pinned dotagents 3.4.0, existing Make targets.
No project constitution or extension hooks exist; global AGENTS.md applies.
Preserve unrelated settings, backups, and downloaded plugin definitions.

## Design

1. Keep source plugin MCP definitions intact. Independently project fresh source
   definitions into a separate Claude marketplace and the installed Codex cache.
   Claude loads local marketplace plugins in place; follow its readFromFolder
   rather than assuming installed_plugins.json installPath is the active root.
2. Compile shared global MCPs into dotagents. Serialize each client's complete
   global MCP configuration directly from the source inventory in the wrapper.
3. Share file and plugin helpers between installer and health checker. Compare
   generated/source manifests and inspect installed native/core plugin activation
   and loaded MCP ownership. Read-only diagnostics omit credentials.
4. Add DOTFILES_SKIP_AGENTS to bootstrap and set it in Docker's bootstrap RUN.
   Keep explicit agents-install unchanged. Provision the Spec Kit CLI fork.

## Validation

Use temporary client directories and synthetic server definitions. Reproduce
stale caches, both mixed-owner directions, disabled/missing plugins, stale
manifests, and missing/wrong MCP owners. Run Make tests/checks, syntax checks,
and pre-commit. Apply installation and verify live CED ownership. Build Docker
if a daemon is available; otherwise exercise the skip path in a shell fixture.

## Research decisions

Claude plugin list --json reports readFromFolder for local plugins, which takes
precedence over its user-scope installed_plugins.json cache path. Codex plugin list --json
provides installed IDs, versions, and enabled flags. Its version identifies the
active cache. Dotagents' CLI doctor does not validate native plugin caches.
These are internal scripts; no new external API or data contract is introduced.
