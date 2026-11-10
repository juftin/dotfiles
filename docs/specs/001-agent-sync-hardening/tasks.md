# Agent sync hardening tasks

## US1: Client MCP ownership

-   [x] T001 [US1] Add regression fixtures for stale caches and mixed ownership in ai/tooling/plugins.test.mjs and config.test.mjs.
-   [x] T002 [US1] Preserve sources and repair both client caches through ai/tooling/plugins.mjs and install.mjs.
-   [x] T003 [US1] Generate client-global MCP definitions in ai/tooling/config.mjs and compile shared globals in manifest.mjs.

## US2: Installation verification

-   [x] T004 [US2] Add fixtures for manifest drift, plugin activation, and MCP ownership in ai/tooling/inventory.test.mjs.
-   [x] T005 [US2] Validate source inventory, installed plugin roots, activation, and MCP owners in ai/tooling/check.mjs.

## US3: Provisioning

-   [x] T006 [US3] Add container agent opt-out in bootstrap/bootstrap.sh and Dockerfile; test the skip path.
-   [x] T007 [US3] Point tools/uv/UvToolFile at juftin/spec-kit and update ai/README.md.

## Validation and convergence

-   [x] T008 Run Make tests/checks, syntax validation, hooks, and isolated regression fixtures.
-   [x] T009 Apply installation, verify live Claude/Codex ownership, and assess convergence against spec.md.
-   [x] T010 Publish upstream PR, run an independent review, address findings, and update the PR.
-   [x] T011 Report MCP overlaps from active unmanaged plugins without modifying their resources; cover both clients with regression fixtures.

US2 depends on the US1 plugin helpers. US3 is independent. Complete regression
fixtures before their implementations; validate each story before final checks.
