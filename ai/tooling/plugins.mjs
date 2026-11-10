import { cpSync, existsSync, rmSync } from "node:fs";
import { isAbsolute, join, relative, resolve } from "node:path";
import { readConfig, saveConfig } from "./files.mjs";
import { pluginPlan, pluginServers } from "./manifest.mjs";

/** Resolve active user-scope plugin caches from each client's installed inventory. */
export function pluginRoots(
    userHome,
    agent,
    plugin,
    codexPlugins = [],
    claudePlugins = [],
) {
    if (agent === "claude") {
        const active = claudePlugins.filter(
            (entry) => entry.id === plugin.id && entry.scope === "user",
        );
        if (active.length) {
            return [
                ...new Set(
                    active.map((entry) => entry.readFromFolder ?? entry.installPath),
                ),
            ];
        }
        const registry = readConfig(
            join(userHome, ".claude/plugins/installed_plugins.json"),
        );
        return (registry.plugins?.[plugin.id] ?? [])
            .filter((entry) => entry.scope === "user")
            .map((entry) => entry.installPath);
    }
    const installed = codexPlugins.find(
        (entry) => entry.pluginId === plugin.id && entry.installed,
    );
    if (!installed?.version) return [];
    const [name, marketplace] = plugin.id.split("@");
    return [
        join(userHome, ".codex/plugins/cache", marketplace, name, installed.version),
    ];
}

/** Build a Claude projection because local marketplace plugins load in place. */
export function prepareClaudeMarketplace(agentsDir, manifest) {
    const root = join(agentsDir, "claude-marketplace");
    const catalog = readConfig(join(agentsDir, ".claude-plugin/marketplace.json"));
    for (const plugin of pluginPlan(manifest, "claude").filter(
        (entry) => !entry.native,
    )) {
        const source = join(agentsDir, "plugins", plugin.name);
        const destination = join(root, "plugins", plugin.name);
        rmSync(destination, { recursive: true, force: true });
        cpSync(source, destination, { recursive: true });
        projectPluginMcp(source, destination, manifest, plugin, "claude");
    }
    saveConfig(
        join(root, ".claude-plugin/marketplace.json"),
        JSON.stringify(catalog, null, 4) + "\n",
    );
    return root;
}

/** Resolve plugin-local MCP references without allowing writes outside the bundle. */
function componentPath(root, file) {
    const path = resolve(root, file);
    const child = relative(root, path);
    if (isAbsolute(file) || child === ".." || child.startsWith("../")) {
        throw new Error("MCP reference must stay inside the plugin bundle.");
    }
    return path;
}

/** Inspect only MCP components loaded by the selected native interface. */
export function pluginMcpServers(root, agent) {
    const manifest = readConfig(join(root, `.${agent}-plugin/plugin.json`));
    const reference = manifest.mcpServers;
    const defaults = readConfig(join(root, ".mcp.json"));
    const base =
        agent === "claude" || reference === undefined
            ? defaults.mcpServers ?? defaults
            : {};
    if (Array.isArray(reference))
        throw new Error("MCP reference arrays are not supported by this adapter.");
    if (reference && typeof reference === "object")
        return { ...base, ...(reference.mcpServers ?? reference) };
    if (typeof reference !== "string") return base;
    const path = componentPath(root, reference);
    if (!existsSync(path)) throw new Error("Referenced MCP component is missing.");
    const document = readConfig(path);
    return { ...base, ...(document.mcpServers ?? document) };
}

/** Restore and filter each client's cache from untouched upstream definitions. */
export function projectPluginMcp(sourceRoot, destination, manifest, plugin, agent) {
    const files = new Set([
        ".mcp.json",
        "mcp.json",
        ".claude-plugin/mcp.json",
        ".codex-plugin/mcp.json",
    ]);
    for (const client of ["claude", "codex"]) {
        const metadata = readConfig(join(sourceRoot, `.${client}-plugin/plugin.json`));
        if (typeof metadata.mcpServers === "string") files.add(metadata.mcpServers);
    }
    for (const file of files) {
        const source = componentPath(sourceRoot, file);
        const path = componentPath(destination, file);
        if (!existsSync(source) && !existsSync(path)) continue;
        // Native bundles have no separate source checkout. Their versioned cache
        // backup retains the original definitions across later ownership changes.
        const original =
            sourceRoot === destination && existsSync(`${source}.dotfiles-backup`)
                ? `${source}.dotfiles-backup`
                : source;
        const config = readConfig(original);
        const projected = pluginServers(
            config.mcpServers ?? config,
            manifest,
            plugin.name,
            agent,
        );
        saveConfig(
            path,
            JSON.stringify(
                config.mcpServers ? { ...config, mcpServers: projected } : projected,
                null,
                4,
            ) + "\n",
        );
    }
    const metadataPath = `.${agent}-plugin/plugin.json`;
    const source = join(sourceRoot, metadataPath);
    const path = join(destination, metadataPath);
    const original =
        sourceRoot === destination && existsSync(`${source}.dotfiles-backup`)
            ? `${source}.dotfiles-backup`
            : source;
    const metadata = readConfig(original);
    if (existsSync(source) || existsSync(path)) {
        const next = readConfig(path);
        if (metadata.mcpServers && typeof metadata.mcpServers === "object") {
            const config = metadata.mcpServers;
            const projected = pluginServers(
                config.mcpServers ?? config,
                manifest,
                plugin.name,
                agent,
            );
            next.mcpServers = config.mcpServers
                ? { ...config, mcpServers: projected }
                : projected;
        } else if (typeof metadata.mcpServers === "string") {
            next.mcpServers = metadata.mcpServers;
        } else {
            delete next.mcpServers;
        }
        saveConfig(path, JSON.stringify(next, null, 4) + "\n");
    }
}
