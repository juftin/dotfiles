const clients = ["claude", "codex"];

/** Resolve the explicitly selected clients, including the Antigravity adapter. */
export function targets(manifest, entry) {
    return (entry.targets ?? manifest.agents).filter((agent) =>
        manifest.agents.includes(agent),
    );
}

/** Resolve one server's owner; absent clients must not activate that connection. */
export function mcpOwner(manifest, name, agent) {
    const server = manifest.mcp?.find((entry) => entry.name === name);
    if (!server || !targets(manifest, server).includes(agent)) return undefined;
    return typeof server.owner === "object"
        ? server.owner[agent]
        : server.owner ?? "global";
}

/** Compile the central inventory into the subset supported by dotagents itself. */
export function dotagentsConfig(manifest) {
    const activeClients = manifest.agents.filter((agent) => clients.includes(agent));
    for (const agent of manifest.agents) {
        if (![...clients, "antigravity"].includes(agent)) {
            throw new Error("Unsupported agent: " + agent);
        }
        const available = new Set(
            pluginPlan(manifest, agent).map((plugin) => plugin.name),
        );
        for (const server of manifest.mcp ?? []) {
            const owner = mcpOwner(manifest, server.name, agent);
            if (owner && owner !== "global" && !available.has(owner)) {
                throw new Error(
                    "Unknown MCP owner " +
                        owner +
                        " for " +
                        server.name +
                        " in " +
                        agent,
                );
            }
            if (owner === "global" && !server.url && !server.command) {
                throw new Error("Missing MCP transport for " + server.name);
            }
        }
    }
    return {
        version: manifest.version,
        agents: activeClients,
        skills: manifest.skills ?? [],
        ...(manifest.trust && { trust: manifest.trust }),
        plugins: (manifest.plugins ?? [])
            .filter((plugin) => plugin.installer !== "native")
            .map(({ name, source, path, ref, ...plugin }) => ({
                name,
                source,
                ...(path && { path }),
                ...(ref && { ref }),
                targets: targets(manifest, plugin).filter((agent) =>
                    clients.includes(agent),
                ),
            })),
        mcp: (manifest.mcp ?? [])
            .filter(
                (server) =>
                    activeClients.length > 0 &&
                    activeClients.every(
                        (agent) => mcpOwner(manifest, server.name, agent) === "global",
                    ),
            )
            .map(({ owner, targets, ...server }) => server),
    };
}

/** Select concrete native plugin identifiers from the single source inventory. */
export function pluginPlan(manifest, agent) {
    return (manifest.plugins ?? [])
        .filter((plugin) => targets(manifest, plugin).includes(agent))
        .map((plugin) => {
            if (!/^[a-z0-9]+(?:[.-][a-z0-9]+)*$/.test(plugin.name)) {
                throw new Error(`Invalid plugin name: ${plugin.name}`);
            }
            const native = plugin.installer === "native";
            const id =
                agent === "antigravity"
                    ? plugin.name
                    : native
                      ? plugin[agent]
                      : `${plugin.name}@${
                            agent === "claude" ? "dotagents" : "dotagents-local"
                        }`;
            if (agent !== "antigravity" && !id?.includes("@"))
                throw new Error(`Missing ${agent} plugin ID for ${plugin.name}`);
            return { ...plugin, id, native };
        });
}

/** Keep only the MCP connections assigned to this plugin in this client. */
export function pluginServers(servers, manifest, plugin, agent) {
    return Object.fromEntries(
        Object.entries(servers).filter(([name]) => {
            if (!manifest.mcp?.some((server) => server.name === name)) {
                throw new Error(
                    `Declare an MCP owner for ${name} from plugin ${plugin}.`,
                );
            }
            return mcpOwner(manifest, name, agent) === plugin;
        }),
    );
}
