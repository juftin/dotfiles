import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { isDeepStrictEqual } from "node:util";
import { parse } from "smol-toml";
import { globalMcp } from "./config.mjs";
import { readConfig } from "./files.mjs";
import { dotagentsConfig, mcpOwner, pluginPlan, pluginServers } from "./manifest.mjs";
import { pluginMcpServers, pluginRoots } from "./plugins.mjs";
// These structured checks come from the pinned dotagents version in package.json.
import { runDoctor } from "@sentry/dotagents/dist/cli/commands/doctor.js";
import { resolveScope } from "@sentry/dotagents/dist/scope.js";

/** Compare TOML and JSON data without treating parser object prototypes as drift. */
function sameConfig(left, right) {
    return isDeepStrictEqual(
        JSON.parse(JSON.stringify(left)),
        JSON.parse(JSON.stringify(right)),
    );
}

/** Verify the source inventory against active client settings and plugin caches. */
export function inventoryChecks(
    manifest,
    {
        userHome,
        agentsDir = join(userHome, ".agents"),
        codexPlugins = [],
        claudePlugins = [],
    },
) {
    const checks = [];
    const add = (name, problems, success) =>
        checks.push({
            name,
            status: problems.length ? "error" : "ok",
            message: problems.length ? problems.join(" ") : success,
        });
    const drift = [];
    try {
        const generated = readConfig(join(agentsDir, "agents.toml"), parse);
        if (!sameConfig(generated, dotagentsConfig(manifest)))
            drift.push(
                "Generated agents.toml differs from the source inventory; run make agents-install.",
            );
    } catch {
        drift.push("Unable to read the generated manifest; run make agents-install.");
    }
    add("source inventory", drift, "Generated manifest matches the source inventory.");
    const state = readConfig(join(agentsDir, "dotfiles-state.json"));
    for (const agent of manifest.agents.filter((value) =>
        ["claude", "codex"].includes(value),
    )) {
        const pluginIssues = [];
        const mcpIssues = [];
        const owners = new Map();
        const record = (name, owner) => {
            const entries = owners.get(name) ?? new Set();
            entries.add(owner);
            owners.set(name, entries);
        };
        let settings;
        try {
            settings = readConfig(
                join(
                    userHome,
                    agent === "claude" ? ".claude/settings.json" : ".codex/config.toml",
                ),
                agent === "claude" ? JSON.parse : parse,
            );
        } catch {
            add(`${agent} settings`, ["Unable to read " + agent + " settings."], "");
            continue;
        }
        const enabled = (id) =>
            agent === "claude"
                ? settings.enabledPlugins?.[id] === true
                : settings.plugins?.[id]?.enabled === true;
        const plan = pluginPlan(manifest, agent);
        for (const id of state.plugins?.[agent] ?? []) {
            if (!plan.some((plugin) => plugin.id === id) && enabled(id))
                pluginIssues.push(`Removed ${agent} plugin is still enabled: ${id}.`);
        }
        for (const plugin of plan) {
            if (!enabled(plugin.id))
                pluginIssues.push(`${agent} plugin is disabled: ${plugin.id}.`);
            if (
                agent === "codex" &&
                !codexPlugins.some(
                    (entry) =>
                        entry.pluginId === plugin.id &&
                        entry.installed &&
                        entry.enabled,
                )
            )
                pluginIssues.push(
                    `Codex does not report an active installation of ${plugin.id}.`,
                );
            try {
                const roots = pluginRoots(
                    userHome,
                    agent,
                    plugin,
                    codexPlugins,
                    claudePlugins,
                );
                if (!roots.length) throw new Error("Missing registry entry");
                for (const root of roots) {
                    const metadata = readConfig(
                        join(root, `.${agent}-plugin/plugin.json`),
                    );
                    if (!existsSync(root) || (!plugin.native && !metadata.name))
                        throw new Error("Missing plugin cache");
                    const servers = pluginMcpServers(root, agent);
                    for (const name of Object.keys(servers)) {
                        if (mcpOwner(manifest, name, agent) !== plugin.name)
                            mcpIssues.push(
                                `${agent}: ${name} is loaded by non-owner plugin ${plugin.id}.`,
                            );
                        if (
                            agent === "codex" &&
                            settings.plugins?.[plugin.id]?.mcp_servers?.[name]
                                ?.enabled === false
                        ) {
                            mcpIssues.push(
                                `codex: ${name} is disabled in plugin ${plugin.id}.`,
                            );
                        } else if (enabled(plugin.id)) {
                            record(name, plugin.name);
                        }
                    }
                    if (!plugin.native) {
                        const upstream = pluginMcpServers(
                            join(agentsDir, "plugins", plugin.name),
                            agent,
                        );
                        const expected = pluginServers(
                            upstream,
                            manifest,
                            plugin.name,
                            agent,
                        );
                        if (!sameConfig(servers, expected))
                            mcpIssues.push(
                                `${agent}: cached MCP definitions are stale for ${plugin.id}.`,
                            );
                    }
                }
            } catch {
                pluginIssues.push(
                    `Missing or invalid ${agent} plugin cache: ${plugin.id}.`,
                );
            }
        }
        try {
            const config =
                agent === "claude"
                    ? readConfig(join(userHome, ".claude.json"))
                    : settings;
            const servers =
                config[agent === "claude" ? "mcpServers" : "mcp_servers"] ?? {};
            const expected = globalMcp(manifest, agent);
            for (const name of Object.keys(servers)) {
                if (
                    manifest.mcp?.some((server) => server.name === name) ||
                    state.mcp?.[agent]?.includes(name)
                ) {
                    if (servers[name].enabled === false) {
                        mcpIssues.push(`${agent}: global MCP ${name} is disabled.`);
                    } else {
                        record(name, "global");
                    }
                    if (mcpOwner(manifest, name, agent) !== "global")
                        mcpIssues.push(
                            `${agent}: ${name} has an unexpected global connection.`,
                        );
                }
            }
            for (const [name, entry] of Object.entries(expected)) {
                if (
                    !Object.entries(entry).every(
                        ([key, value]) =>
                            servers[name] &&
                            sameConfig(servers[name][key] ?? null, value),
                    )
                )
                    mcpIssues.push(
                        `${agent}: global MCP configuration is missing or stale for ${name}.`,
                    );
                if (
                    entry.bearer_token_env_var &&
                    servers[name]?.http_headers?.Authorization
                )
                    mcpIssues.push(
                        `${agent}: ${name} has an unexpected literal authorization header.`,
                    );
            }
        } catch {
            mcpIssues.push("Unable to inspect " + agent + " global MCP settings.");
        }
        for (const server of manifest.mcp ?? []) {
            const expected = mcpOwner(manifest, server.name, agent);
            const actual = owners.get(server.name) ?? new Set();
            if (expected && (actual.size !== 1 || !actual.has(expected)))
                mcpIssues.push(
                    `${agent}: ${server.name} must have exactly one active owner (${expected}).`,
                );
        }
        add(
            `${agent} plugins`,
            pluginIssues,
            `All ${plan.length} declared ${agent} plugins are installed and enabled.`,
        );
        add(
            `${agent} MCP ownership`,
            mcpIssues,
            `${agent} MCP definitions match their declared owners.`,
        );
    }
    return checks;
}

/** Report every finding, allowing only plugin compatibility warnings to pass. */
export function reportChecks(checks, report = console.log) {
    for (const check of checks) {
        const icon = { ok: "✓", warn: "!", error: "✗" }[check.status] ?? "?";
        report(`  ${icon} ${check.message}`);
    }
    const failed = checks.some(
        (check) =>
            check.status !== "ok" &&
            !(check.name === "plugin compatibility" && check.status === "warn"),
    );
    if (!failed) report("\nInstallation checks passed.");
    return failed ? 1 : 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
    const scope = resolveScope("user");
    const { checks } = await runDoctor({ scope, fix: false });
    if (existsSync(scope.configPath)) {
        const root = dirname(dirname(fileURLToPath(import.meta.url)));
        const manifest = parse(readFileSync(join(root, "agents/agents.toml"), "utf8"));
        let codexPlugins = [];
        if (manifest.agents.includes("codex")) {
            try {
                codexPlugins = JSON.parse(
                    execFileSync("codex", ["plugin", "list", "--json"], {
                        encoding: "utf8",
                        stdio: ["ignore", "pipe", "pipe"],
                    }),
                ).installed;
            } catch {
                checks.push({
                    name: "Codex inventory",
                    status: "error",
                    message: "Unable to list installed Codex plugins.",
                });
            }
        }
        let claudePlugins = [];
        if (manifest.agents.includes("claude")) {
            try {
                claudePlugins = JSON.parse(
                    execFileSync("claude", ["plugin", "list", "--json"], {
                        encoding: "utf8",
                        stdio: ["ignore", "pipe", "pipe"],
                    }),
                );
            } catch {
                checks.push({
                    name: "Claude inventory",
                    status: "error",
                    message: "Unable to list installed Claude plugins.",
                });
            }
        }
        checks.push(
            ...inventoryChecks(manifest, {
                userHome: homedir(),
                agentsDir: scope.root,
                codexPlugins,
                claudePlugins,
            }),
        );
    }
    process.exitCode = reportChecks(checks);
}
