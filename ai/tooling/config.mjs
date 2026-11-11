import { getAgent } from "@sentry/dotagents/dist/targets/registry.js";
import { mcpOwner } from "./manifest.mjs";

/** Serialize only the global MCP connections owned by this client. */
export function globalMcp(manifest, agent) {
    const servers = (manifest.mcp ?? []).filter(
        (server) => mcpOwner(manifest, server.name, agent) === "global",
    );
    const serialized = Object.fromEntries(
        servers.map((server) => getAgent(agent).serializeServer(server)),
    );
    return agent === "codex"
        ? codexMcpAuth({ mcp_servers: serialized }, servers).mcp_servers
        : serialized;
}

/** Merge portable preferences while retaining settings owned by each application. */
export function mergeSettings(current, preferences) {
    const merged = { ...current };
    for (const [key, value] of Object.entries(preferences)) {
        merged[key] =
            value && typeof value === "object" && !Array.isArray(value)
                ? mergeSettings(current?.[key] ?? {}, value)
                : value;
    }
    return merged;
}

/** Translate dotagents MCP declarations without depending on Antigravity interpolation. */
export function antigravityServers(servers, environment) {
    const expand = (value) =>
        value.replace(/\$\{([A-Za-z_][A-Za-z0-9_]*)\}/g, (_, name) => {
            if (!environment[name]) {
                throw new Error(
                    `Set ${name} before installing Antigravity MCP servers.`,
                );
            }
            return environment[name];
        });
    return Object.fromEntries(
        servers.map((server) => {
            const entry = server.url
                ? { serverUrl: expand(server.url) }
                : {
                      command: expand(server.command),
                      args: (server.args ?? []).map(expand),
                  };
            if (server.headers) {
                entry.headers = Object.fromEntries(
                    Object.entries(server.headers).map(([key, value]) => [
                        key,
                        expand(value),
                    ]),
                );
            }
            if (server.env?.length) {
                entry.env = Object.fromEntries(
                    server.env.map((name) => [name, expand(`\${${name}}`)]),
                );
            }
            return [server.name, entry];
        }),
    );
}

/** Convert bearer placeholders to Codex's runtime environment authentication setting. */
export function codexMcpAuth(current, servers) {
    const result = structuredClone(current);
    for (const server of servers) {
        const token = /^Bearer \$\{([A-Za-z_][A-Za-z0-9_]*)\}$/.exec(
            server.headers?.Authorization ?? "",
        );
        const entry = result.mcp_servers?.[server.name];
        if (!token || !entry) continue;
        entry.bearer_token_env_var = token[1];
        delete entry.http_headers?.Authorization;
        if (entry.http_headers && Object.keys(entry.http_headers).length === 0) {
            delete entry.http_headers;
        }
    }
    return result;
}

/** Enforce declared plugins and retire only previously managed plugin IDs. */
export function reconcilePlugins(current, agent, desiredIds, previousIds = []) {
    const result = structuredClone(current);
    const key = agent === "claude" ? "enabledPlugins" : "plugins";
    const suffix = agent === "claude" ? "@dotagents" : "@dotagents-local";
    const entries = (result[key] ??= {});
    const desired = new Set(desiredIds);
    const managed = new Set([
        ...previousIds,
        ...Object.keys(entries).filter((id) => id.endsWith(suffix)),
        ...desired,
    ]);
    for (const id of managed) {
        const enabled = desired.has(id);
        entries[id] = agent === "claude" ? enabled : { ...entries[id], enabled };
    }
    return result;
}

/** Replace previously managed servers while preserving user-added servers and settings. */
export function mergeMcp(current, previousNames, servers, key = "mcpServers") {
    const preserved = { ...current[key] };
    for (const name of previousNames) delete preserved[name];
    return { ...current, [key]: { ...preserved, ...servers } };
}
