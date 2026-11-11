import { execFileSync, spawnSync } from "node:child_process";
import {
    existsSync,
    lstatSync,
    mkdirSync,
    realpathSync,
    readlinkSync,
    renameSync,
    symlinkSync,
    unlinkSync,
    readFileSync,
} from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { parse, stringify } from "smol-toml";
import {
    antigravityServers,
    globalMcp,
    mergeMcp,
    mergeSettings,
    reconcilePlugins,
} from "./config.mjs";
import { dotagentsConfig, mcpOwner, pluginPlan } from "./manifest.mjs";
import { readConfig, saveConfig } from "./files.mjs";
import { pluginRoots, prepareClaudeMarketplace, projectPluginMcp } from "./plugins.mjs";
import { exportAntigravityPlugins } from "./antigravity.mjs";

const toolingRoot = dirname(fileURLToPath(import.meta.url));
const root = dirname(toolingRoot);
const userHome = homedir();
const sourceManifest = join(root, "agents/agents.toml");
const manifest = parse(readFileSync(sourceManifest, "utf8"));
const compiled = dotagentsConfig(manifest);
const antigravityEnabled = manifest.agents.includes("antigravity");
const statePath = join(userHome, ".agents/dotfiles-state.json");
const previousState = readConfig(statePath);
const plans = Object.fromEntries(
    ["claude", "codex", "antigravity"].map((agent) => [
        agent,
        pluginPlan(manifest, agent),
    ]),
);
// Resolve credentials before changing files; values only go into local config.
const servers = antigravityEnabled
    ? antigravityServers(
          (manifest.mcp ?? []).filter(
              (server) => mcpOwner(manifest, server.name, "antigravity") === "global",
          ),
          process.env,
      )
    : {};

for (const agent of ["claude", "codex"]) {
    if (plans[agent].length === 0) continue;
    const available = spawnSync(agent, ["--version"], { stdio: "ignore" });
    if (available.error || available.status !== 0) {
        throw new Error(
            agent + " CLI is required; install it before make agents-install.",
        );
    }
}

const effectiveManifest = join(userHome, ".agents/agents.toml");
if (existsSync(effectiveManifest) && lstatSync(effectiveManifest).isSymbolicLink()) {
    if (realpathSync(effectiveManifest) !== sourceManifest) {
        throw new Error("Refusing to replace an unrelated agents.toml symlink.");
    }
    unlinkSync(effectiveManifest);
}
saveConfig(effectiveManifest, stringify(compiled));

const claudePath = join(userHome, ".claude/settings.json");
const claudePreferences = join(root, "claude/settings.json");
const claudeSettings = mergeSettings(
    readConfig(claudePath),
    readConfig(claudePreferences),
);
// Migrate the old dotfiles symlink so generated marketplace paths stay machine-local.
if (
    existsSync(claudePath) &&
    lstatSync(claudePath).isSymbolicLink() &&
    realpathSync(claudePath) === claudePreferences
) {
    unlinkSync(claudePath);
}
saveConfig(claudePath, `${JSON.stringify(claudeSettings, null, 4)}\n`);

const codexPath = join(userHome, ".codex/config.toml");
const codexPreferences = readConfig(join(root, "codex/config.toml"), parse);
saveConfig(
    codexPath,
    stringify(mergeSettings(readConfig(codexPath, parse), codexPreferences)),
);
if (antigravityEnabled) {
    for (const [source, destination] of [
        [join(root, "global/AGENTS.md"), join(userHome, ".gemini/GEMINI.md")],
        [join(userHome, ".agents/skills"), join(userHome, ".gemini/config/skills")],
    ]) {
        mkdirSync(dirname(destination), { recursive: true });
        const current = lstatSync(destination, { throwIfNoEntry: false });
        if (current?.isSymbolicLink()) {
            if (readlinkSync(destination) === source) continue;
            unlinkSync(destination);
        } else if (current) {
            renameSync(destination, `${destination}.${Date.now()}.dotfiles-backup`);
        }
        symlinkSync(source, destination);
    }
    const antigravityPath = join(userHome, ".gemini/config/config.json");
    saveConfig(
        antigravityPath,
        `${JSON.stringify(
            mergeSettings(
                readConfig(antigravityPath),
                readConfig(join(root, "antigravity/config.json")),
            ),
            null,
            4,
        )}\n`,
    );
}

const cli = join(toolingRoot, "node_modules/@sentry/dotagents/dist/cli/index.js");
execFileSync(process.execPath, [cli, "--global", "install"], { stdio: "inherit" });

// Remove former global connections now owned by plugins, preserving unrelated servers.
for (const agent of ["claude", "codex"]) {
    const path = agent === "claude" ? join(userHome, ".claude.json") : codexPath;
    const parser = agent === "claude" ? JSON.parse : parse;
    const key = agent === "claude" ? "mcpServers" : "mcp_servers";
    const config = readConfig(path, parser);
    const desired = globalMcp(manifest, agent);
    const previous = [
        ...(previousState.mcp?.[agent] ?? []),
        ...(manifest.mcp ?? []).map((server) => server.name),
    ];
    const next = mergeMcp(config, previous, desired, key);
    saveConfig(
        path,
        agent === "claude" ? JSON.stringify(next, null, 4) + "\n" : stringify(next),
    );
}

if (antigravityEnabled) {
    const mcpPath = join(userHome, ".gemini/config/mcp_config.json");
    const managedPath = join(userHome, ".agents/antigravity-mcp-servers.json");
    const previousNames = existsSync(managedPath) ? readConfig(managedPath) : [];
    saveConfig(
        mcpPath,
        `${JSON.stringify(
            mergeMcp(readConfig(mcpPath), previousNames, servers),
            null,
            4,
        )}\n`,
    );
    saveConfig(managedPath, `${JSON.stringify(Object.keys(servers))}\n`);
}

/** Run native plugin commands after the client availability checks. */
function activatePlugins(command, args, plugins) {
    for (const plugin of plugins) {
        execFileSync(command, [...args, plugin], { stdio: "inherit" });
    }
}

// Claude's local marketplace plugins load in place, independently of old cache
// entries. Give it a filtered projection while preserving dotagents' source bundles.
const claudeMarketplace = manifest.agents.includes("claude")
    ? prepareClaudeMarketplace(join(userHome, ".agents"), manifest)
    : undefined;
if (claudeMarketplace) {
    const settings = readConfig(claudePath);
    settings.extraKnownMarketplaces ??= {};
    settings.extraKnownMarketplaces.dotagents = {
        ...settings.extraKnownMarketplaces.dotagents,
        source: { source: "directory", path: claudeMarketplace },
    };
    saveConfig(claudePath, JSON.stringify(settings, null, 4) + "\n");
    const path = join(userHome, ".claude/plugins/known_marketplaces.json");
    const known = readConfig(path);
    known.dotagents = {
        ...known.dotagents,
        source: { source: "directory", path: claudeMarketplace },
        installLocation: claudeMarketplace,
        lastUpdated: known.dotagents?.lastUpdated ?? new Date().toISOString(),
    };
    saveConfig(path, JSON.stringify(known, null, 4) + "\n");
}

// Native plugin sources and selectors come exclusively from agents.toml.
for (const agent of ["claude", "codex"]) {
    const native = plans[agent].filter((plugin) => plugin.native);
    const known =
        agent === "claude"
            ? readConfig(join(userHome, ".claude/plugins/known_marketplaces.json"))
            : {};
    const marketplaces = new Map(
        native
            .filter(
                (plugin) => plugin.source && !plugin.id.endsWith("@openai-api-curated"),
            )
            .map((plugin) => [plugin.id.split("@")[1], plugin.source]),
    );
    for (const [name, source] of marketplaces) {
        if (known[name]) continue;
        activatePlugins(agent, ["plugin", "marketplace", "add"], [source]);
    }
    if (agent === "claude") {
        activatePlugins(
            agent,
            ["plugin", "install", "--scope", "user"],
            native.map((plugin) => plugin.id),
        );
        activatePlugins(
            agent,
            [
                "plugin",
                "install",
                "--scope",
                "user",
                "--marketplace",
                claudeMarketplace,
            ],
            plans[agent]
                .filter((plugin) => !plugin.native)
                .map((plugin) => plugin.name),
        );
    } else {
        activatePlugins(
            agent,
            ["plugin", "add"],
            plans[agent].map((plugin) => plugin.id),
        );
    }

    // Installation can preserve a prior disabled flag; the inventory owns this state.
    const path = agent === "claude" ? claudePath : codexPath;
    const config = readConfig(path, agent === "claude" ? JSON.parse : parse);
    const next = reconcilePlugins(
        config,
        agent,
        plans[agent].map((plugin) => plugin.id),
        previousState.plugins?.[agent] ?? [],
    );
    saveConfig(
        path,
        agent === "claude" ? JSON.stringify(next, null, 4) + "\n" : stringify(next),
    );
}

// Native installers can reuse caches even after the marketplace source changes.
const codexInstalled = manifest.agents.includes("codex")
    ? JSON.parse(
          execFileSync("codex", ["plugin", "list", "--json"], { encoding: "utf8" }),
      ).installed
    : [];
const claudeInstalled = manifest.agents.includes("claude")
    ? JSON.parse(
          execFileSync("claude", ["plugin", "list", "--json"], { encoding: "utf8" }),
      )
    : [];
for (const agent of ["claude", "codex"]) {
    for (const plugin of plans[agent]) {
        const roots = pluginRoots(
            userHome,
            agent,
            plugin,
            codexInstalled,
            claudeInstalled,
        );
        if (!roots.length || roots.some((path) => !existsSync(path))) {
            throw new Error(`Installed ${agent} plugin cache missing: ${plugin.id}`);
        }
        for (const destination of roots) {
            const source = plugin.native
                ? destination
                : join(userHome, ".agents/plugins", plugin.name);
            projectPluginMcp(source, destination, manifest, plugin, agent);
        }
    }
}

if (antigravityEnabled) {
    const registry = readConfig(
        join(userHome, ".claude/plugins/installed_plugins.json"),
    );
    const bundles = plans.antigravity.map((plugin) => {
        const sourceRoot = plugin.native
            ? registry.plugins?.[plugin.claude]?.find((entry) => entry.scope === "user")
                  ?.installPath
            : join(userHome, ".agents/plugins", plugin.name);
        if (!sourceRoot || !existsSync(sourceRoot)) {
            throw new Error(
                "Install the Claude plugin before exporting " +
                    plugin.name +
                    " to Antigravity.",
            );
        }
        return { name: plugin.name, sourceRoot };
    });
    exportAntigravityPlugins(join(userHome, ".gemini/config/plugins"), bundles);
}
saveConfig(
    statePath,
    JSON.stringify(
        {
            plugins: Object.fromEntries(
                ["claude", "codex"].map((agent) => [
                    agent,
                    [
                        ...new Set([
                            ...(previousState.plugins?.[agent] ?? []),
                            ...plans[agent].map((plugin) => plugin.id),
                        ]),
                    ],
                ]),
            ),
            mcp: Object.fromEntries(
                ["claude", "codex"].map((agent) => [
                    agent,
                    (manifest.mcp ?? [])
                        .filter(
                            (server) =>
                                mcpOwner(manifest, server.name, agent) === "global",
                        )
                        .map((server) => server.name),
                ]),
            ),
        },
        null,
        4,
    ) + "\n",
);
console.log(`Agent files installed for ${manifest.agents.join(", ")}.`);
