# Agent sync hardening

## User scenarios and acceptance criteria

### US1: Reliable client MCP ownership (P1)

A user installs agents after changing MCP ownership or while a client retains
an older cached plugin version.

-   Claude and Codex each load exactly one declared owner per MCP name.
-   Repeated installation repairs caches without destroying source definitions.
-   A server can be global in one client and plugin-owned in another.
-   Unrelated settings and plugins remain intact.

### US2: Reliable installation checks (P1)

A user checks whether the source inventory is installed and active.

-   An empty, missing, or stale generated manifest fails verification.
-   Missing or disabled native and managed plugins fail verification.
-   Incorrect MCP owners, duplicate declarations, missing connections, and invalid
    client metadata fail verification without exposing credentials.
-   Upstream compatibility notices remain visible and advisory.
-   Checks are read-only.

### US3: Portable provisioning (P1)

A user builds the container or installs tools on a new machine.

-   Container bootstrap can skip agents without npm, client CLIs, private repository
    access, or agent credentials. Explicit agents-install still installs agents.
-   Spec Kit CLI provisioning uses juftin/spec-kit, matching the skills.

## Scope and assumptions

Fix the five final-review findings. Keep optional Antigravity support disabled
in the work manifest. Authentication remains a separate client action. Do not
change unrelated preferences. Publish an upstream PR after verification, run an
independent review, address its findings, and update the PR.

## Success criteria

Regression fixtures pass for stale caches, both mixed-owner directions, native
plugin activation, empty manifests, wrong/missing MCP owners, and idempotence.
All tests, syntax checks, and hooks pass. Claude's actual CED load folder contains only
Datadog and Serena. Container validation confirms agent installation is skipped.
