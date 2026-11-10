# Agent files

`agents/agents.toml` is the source inventory for skills, plugins, client targets,
and MCP ownership. `tooling/install.mjs` compiles its dotagents-compatible resources to
`~/.agents/agents.toml`, installs those with [dotagents](https://github.com/getsentry/dotagents),
and applies native plugin declarations and optional Antigravity adapters.

The source manifest extends dotagents with `installer = "native"`, native
`claude`/`codex` plugin IDs, Antigravity targets, and MCP `owner` mappings.
These extensions are consumed by this repo's installer;
the generated runtime manifest contains only dotagents-supported fields.

JavaScript sources, tests, npm manifests, and dependencies live in `tooling/`.
The checked-in manifest enables Claude and Codex. Antigravity support remains
available for other machines; see the opt-in instructions below.

From the repository root:

```shell
make agents-install
make agents-check
make agents-test
```

The full bootstrap also installs agent files. Container builds set
`DOTFILES_SKIP_AGENTS=1` to skip this installation; the explicit
`make agents-install` target always installs agents. Node.js 20+, npm, Git,
plus the Claude and Codex CLIs, are required. Antigravity bundles use its
documented manual installation directory; the Antigravity CLI is optional.
The npm lockfile pins the dotagents tooling version; `agents.lock` records
resolved dependencies, but dotagents `install` refreshes them rather than
treating that file as a frozen dependency lock.

## Source files

| Source                                  | Installed location                          | Management                                             |
| --------------------------------------- | ------------------------------------------- | ------------------------------------------------------ |
| `global/AGENTS.md`                      | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` | Shared instruction symlinks                            |
| `agents/agents.toml`                    | `~/.agents/agents.toml`                     | Generated dotagents manifest                           |
| `agents/agents.lock`                    | `~/.agents/agents.lock`                     | Lockfile symlink                                       |
| `agents/private/`                       | `~/.agents/private/`                        | Optional, gitignored local skills                      |
| `claude/settings.json`                  | `~/.claude/settings.json`                   | Merge preferences, retaining generated plugin settings |
| `claude/statusline.sh`                  | `~/.claude/statusline.sh`                   | App-specific symlink                                   |
| `codex/config.toml`                     | `~/.codex/config.toml`                      | Merge preferences, retaining local settings            |
| `antigravity/config.json`               | `~/.gemini/config/config.json`              | Merge preferences, retaining local settings            |
| `agents/agents.toml` MCP entries        | `~/.gemini/config/mcp_config.json`          | Generate Antigravity server definitions                |
| dotagents skills at `~/.agents/skills/` | `~/.gemini/config/skills/`                  | Antigravity skill directory symlink                    |

Antigravity paths are managed only when it is enabled in the top-level `agents`
list. Plugin skills and supporting resources are then projected to
`~/.gemini/config/plugins/<name>/` for each plugin targeting Antigravity.

The existing OpenCode instruction symlink is also retained. Project trust and unrelated local settings survive preference merges. Declared
plugins are enabled on every installation, including previously disabled ones.
Removed managed plugins are disabled; their caches and persistent data are retained.
Unrelated plugins are preserved. `~/.agents/dotfiles-state.json` remembers managed
native plugin IDs and global MCP names for removal syncing. Existing generated
marketplace plugin IDs are recognized during the first migration as well. Antigravity's
unrelated MCP entries survive regeneration; removed managed entries are pruned.
The installer saves the first changed copy of each merged local file as
`<filename>.dotfiles-backup`. Existing files or directories replaced with symlinks
receive timestamped backups.

## Changes and authentication

Edit `agents/agents.toml` to add or remove skills, servers, or plugins, then run
`make agents-install`. The installer runs dotagents `install` to refresh
dependencies and generated runtime artifacts, then reconciles managed client state. Use `targets` to select
Claude, Codex, and Antigravity for each plugin. Native plugin sources and selectors
are declared in the same manifest, for example:

```toml
[[plugins]]
name = "slack"
source = "anthropics/claude-plugins-official"
installer = "native"
claude = "slack@claude-plugins-official"
codex = "slack@claude-plugins-official"
targets = ["claude", "codex"]
```

App preference files contain app settings only. Edit the source inventory and use
`make agents-install`; edits made directly to the generated runtime manifest will
be overwritten. The installer runs dotagents before applying client-specific
MCP authentication and ownership, so use the wrapper for a complete sync.

Each MCP name has one owner per client. An omitted `owner` means a global
connection. A plugin name assigns it to that plugin; a table can vary by client:

```toml
[[mcp]]
name = "github"
url = "https://api.githubcopilot.com/mcp/"
headers = { Authorization = "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}" }
owner = "github"
targets = ["claude", "codex"]
```

Downloaded source bundles retain their upstream definitions.
Claude's local marketplace loads plugins in place, so the installer creates a
separate filtered marketplace at `~/.agents/claude-marketplace/`. Codex receives
its own projection in the installed version's cache. Ownership is applied separately
to each client, including reused versions, so a server can have different owners
in each client. Native cache backups preserve original definitions for later
ownership changes. The checker follows Claude's reported `readFromFolder`
when present, rather than trusting an unused cache path.

`make agents-check` compares the generated manifest with the source inventory,
verifies that declared native and managed plugins are installed and enabled, and
checks loaded global and plugin MCP definitions against their declared owners.
It also reports declared MCP names loaded by other enabled user plugins, without
changing those plugins or their settings. Resolve these overlaps in the client.
It also shows dotagents' upstream plugin compatibility warnings as advisories.
Missing dependencies, broken runtime artifacts, and all other warnings or errors
still return a failure. The checker uses structured results from the pinned
dotagents version; its CLI treats every warning as a failure.

Spec Kit uses wildcard and explicit declarations scoped to its skills:

```toml
[[skills]]
name = "*"
source = "juftin/spec-kit"

[[skills]]
name = "add-community-extension"
source = "juftin/spec-kit"
path = ".github/skills/add-community-extension"

[[skills]]
name = "code-review"
source = "juftin/spec-kit"
path = ".github/skills/code-review"
```

Running `make agents-install` picks up all current skills there, including future
additions. This installs the skills; the `specify` CLI is provisioned separately from
`juftin/spec-kit` by `tools/uv/UvToolFile`. Install just that tool with
`uv tool install specify-cli --from git+https://github.com/juftin/spec-kit.git`.

Project trust and command approval rules remain machine-local.

Private skills can be placed under `agents/private/<name>/SKILL.md`. An empty
private directory works on a new machine. This directory is ignored by Git.

Provide `GITHUB_PERSONAL_ACCESS_TOKEN` through your shell environment before
installation. The GitHub MCP declaration references that variable. The installer
converts its bearer placeholder to Codex's `bearer_token_env_var` setting after
dotagents installation, so Codex reads the token when it starts. GitHub uses this token;
do not run `codex mcp login github`, which attempts unsupported dynamic OAuth
client registration. Ensure the variable is exported in the environment that
launches Codex. When enabled, Antigravity
receives the resolved header in its local MCP config with owner-only permissions;
credentials never belong in the tracked manifest. Rerun installation after rotating
the token. OAuth servers still require signing in separately in each app.

## Antigravity compatibility

Antigravity is disabled in the default configuration. To enable it on another machine:

1. Add `"antigravity"` to the top-level `agents` list and the desired plugins'
   `targets` lists in `agents/agents.toml`.
2. Run `make agents-install`.

Enabling it applies `antigravity/config.json`, links shared instructions to
`~/.gemini/GEMINI.md`, and installs its skills, MCP definitions, and plugin bundles.
While disabled, the installer skips these steps and credential expansion for
Antigravity. Existing local Antigravity files are retained.

Dotagents has no native Antigravity target. The adapter converts global MCP
declarations to [Antigravity's MCP format](https://antigravity.google/docs/mcp).
Antigravity reads standalone skills through its
[global skills directory](https://antigravity.google/docs/skills), plus plugin
skills from [manually installed bundles](https://antigravity.google/docs/plugins)
under `~/.gemini/config/plugins/`.

The adapter exports plugin metadata and links skills and supporting resources.
Generated bundles have an ownership marker; removed bundles are pruned, while
unrelated plugins and name collisions are preserved. Plugin MCP definitions
are excluded from these bundles because Antigravity's connections are owned
by its global configuration. Subagents and rules are not exported.

Native Antigravity `hooks.json` definitions are exported when present. Claude's
`hooks/hooks.json` format is rejected with a porting error: the hook input/output
contracts differ, so changing event names alone would produce broken hooks.
None of the currently selected bundles provides lifecycle hooks. See the
[Antigravity hook contract](https://antigravity.google/docs/hooks).

Native plugins (Context7, GitHub, Serena, Slack, TypeScript LSP, Superpowers, and
Superpowers Developing for Claude Code) are declared in `agents/agents.toml` with
`installer = "native"`. Portable plugins (Astral, Juftin, Skill Creator, Code Review,
Commit Commands, and PR Review Toolkit) are compiled and managed through dotagents.
Authentication is completed separately in each app.
The repository's app settings are applied during installation; change portable
preferences here when you want them to persist across machines.
