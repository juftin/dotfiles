import assert from "node:assert/strict";
import test from "node:test";
import { dotagentsConfig, mcpOwner, pluginPlan, pluginServers } from "./manifest.mjs";
import { reconcilePlugins } from "./config.mjs";

const manifest = {
    version: 1,
    agents: ["claude", "codex", "antigravity"],
    skills: [],
    plugins: [
        { name: "astral", source: "example/astral" },
        { name: "ced", source: "example/ced", targets: ["claude", "codex"] },
        {
            name: "notion",
            installer: "native",
            source: "example/notion",
            claude: "notion-workspace@notion-marketplace",
            codex: "notion@curated",
        },
    ],
    mcp: [
        { name: "github", url: "https://github.example/mcp" },
        {
            name: "notion",
            url: "https://notion.example/mcp",
            owner: { claude: "notion", codex: "notion", antigravity: "global" },
        },
        { name: "datadog", owner: "ced", targets: ["claude", "codex"] },
    ],
};

test("one inventory generates only supported dotagents targets and resources", () => {
    const result = dotagentsConfig(manifest);
    assert.deepEqual(result.agents, ["claude", "codex"]);
    assert.deepEqual(result.plugins, [
        {
            name: "astral",
            source: "example/astral",
            targets: ["claude", "codex"],
        },
        { name: "ced", source: "example/ced", targets: ["claude", "codex"] },
    ]);
    assert.deepEqual(result.mcp, [
        { name: "github", url: "https://github.example/mcp" },
    ]);
    assert.equal(
        pluginPlan(manifest, "claude").find((plugin) => plugin.name === "notion").id,
        "notion-workspace@notion-marketplace",
    );
    assert.equal(
        pluginPlan(manifest, "codex").find((plugin) => plugin.name === "notion").id,
        "notion@curated",
    );
    assert.equal(mcpOwner(manifest, "notion", "antigravity"), "global");
    assert.equal(mcpOwner(manifest, "datadog", "antigravity"), undefined);
});

test("disabled clients stay inactive despite explicit plugin and MCP targets", () => {
    const enabled = {
        ...manifest,
        plugins: manifest.plugins.map((plugin) => ({
            ...plugin,
            targets: plugin.targets ?? manifest.agents,
        })),
        mcp: manifest.mcp.map((server) => ({
            ...server,
            targets: server.targets ?? manifest.agents,
        })),
    };
    const disabled = { ...enabled, agents: ["claude", "codex"] };
    assert.deepEqual(pluginPlan(disabled, "antigravity"), []);
    assert.equal(mcpOwner(disabled, "github", "antigravity"), undefined);
    assert.equal(mcpOwner(disabled, "notion", "antigravity"), undefined);
    assert.deepEqual(dotagentsConfig(disabled), dotagentsConfig(enabled));
    assert.equal(pluginPlan(enabled, "antigravity").length, 2);
    assert.equal(mcpOwner(enabled, "notion", "antigravity"), "global");
});

test("client-specific globals are left to the wrapper instead of being broadcast by dotagents", () => {
    const mixed = {
        ...manifest,
        mcp: [
            {
                name: "service",
                url: "https://synthetic.test/mcp",
                owner: { claude: "global", codex: "ced", antigravity: "global" },
            },
        ],
    };
    assert.deepEqual(dotagentsConfig(mixed).mcp, []);
});

test("invalid MCP owners fail before configuration is generated", () => {
    assert.throws(
        () =>
            dotagentsConfig({
                ...manifest,
                mcp: [{ name: "service", owner: "missing" }],
            }),
        /Unknown MCP owner missing/,
    );
});

test("removed managed plugins retire while unrelated plugins and local policy survive", () => {
    const current = {
        projects: { example: { trust_level: "trusted" } },
        plugins: {
            "astral@dotagents-local": { enabled: false, local_policy: true },
            "removed@dotagents-local": { enabled: true },
            "old-native@curated": { enabled: true },
            "personal@elsewhere": { enabled: true },
        },
    };
    const desired = pluginPlan(manifest, "codex").map((p) => p.id);
    const result = reconcilePlugins(current, "codex", desired, ["old-native@curated"]);
    assert.equal(result.plugins["astral@dotagents-local"].enabled, true);
    assert.equal(result.plugins["astral@dotagents-local"].local_policy, true);
    assert.equal(result.plugins["removed@dotagents-local"].enabled, false);
    assert.equal(result.plugins["old-native@curated"].enabled, false);
    assert.equal(result.plugins["personal@elsewhere"].enabled, true);
    assert.deepEqual(result.projects, current.projects);
    assert.deepEqual(
        reconcilePlugins(result, "codex", desired, ["old-native@curated"]),
        result,
    );
    assert.equal(current.plugins["astral@dotagents-local"].enabled, false);

    const claude = reconcilePlugins(
        {
            enabledPlugins: {
                "removed@dotagents": true,
                "personal@elsewhere": true,
            },
        },
        "claude",
        ["astral@dotagents"],
    );
    assert.equal(claude.enabledPlugins["removed@dotagents"], false);
    assert.equal(claude.enabledPlugins["astral@dotagents"], true);
    assert.equal(claude.enabledPlugins["personal@elsewhere"], true);
});

test("MCP ownership removes bundled overlaps and rejects undeclared connections", () => {
    const servers = {
        github: { url: "https://github.example/mcp" },
        notion: { url: "https://notion.example/mcp" },
        datadog: { url: "https://datadog.example/mcp" },
    };
    assert.deepEqual(pluginServers(servers, manifest, "ced", "codex"), {
        datadog: servers.datadog,
    });
    assert.deepEqual(pluginServers(servers, manifest, "notion", "claude"), {
        notion: servers.notion,
    });
    assert.throws(
        () => pluginServers({ unknown: {} }, manifest, "ced", "claude"),
        /Declare an MCP owner for unknown/,
    );
    assert.ok(servers.github);
});
