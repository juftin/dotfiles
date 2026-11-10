import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import {
    pluginMcpServers,
    pluginRoots,
    prepareClaudeMarketplace,
    projectPluginMcp,
} from "./plugins.mjs";

test("stale Claude and Codex caches are repaired independently without losing source connections", (t) => {
    const root = mkdtempSync(join(tmpdir(), "dotfiles-plugin-"));
    t.after(() => rmSync(root, { recursive: true, force: true }));
    const source = join(root, "source");
    const caches = Object.fromEntries(
        ["claude", "codex"].map((client) => [client, join(root, client)]),
    );
    const upstream = {
        mcpServers: {
            service: { url: "https://synthetic.test/mcp" },
            other: { command: "synthetic" },
        },
    };
    for (const path of [source, ...Object.values(caches)]) {
        mkdirSync(path);
        writeFileSync(join(path, ".mcp.json"), JSON.stringify(upstream));
    }
    for (const owner of [
        { claude: "global", codex: "service" },
        { claude: "service", codex: "global" },
    ]) {
        const manifest = {
            agents: ["claude", "codex"],
            mcp: [
                { name: "service", owner },
                { name: "other", owner: "global" },
            ],
        };
        for (const client of ["claude", "codex"]) {
            projectPluginMcp(
                source,
                caches[client],
                manifest,
                { name: "service" },
                client,
            );
            projectPluginMcp(
                source,
                caches[client],
                manifest,
                { name: "service" },
                client,
            );
            assert.deepEqual(
                Object.keys(pluginMcpServers(caches[client], client)),
                owner[client] === "service" ? ["service"] : [],
            );
        }
        assert.deepEqual(
            JSON.parse(readFileSync(join(source, ".mcp.json"), "utf8")),
            upstream,
        );
    }
});

test("Claude's in-place marketplace projection preserves unfiltered shared sources", (t) => {
    const agentsDir = mkdtempSync(join(tmpdir(), "dotfiles-marketplace-"));
    t.after(() => rmSync(agentsDir, { recursive: true, force: true }));
    const source = join(agentsDir, "plugins", "core");
    mkdirSync(join(agentsDir, ".claude-plugin"), { recursive: true });
    mkdirSync(join(source, ".claude-plugin"), { recursive: true });
    writeFileSync(
        join(agentsDir, ".claude-plugin/marketplace.json"),
        JSON.stringify({
            name: "dotagents",
            plugins: [{ name: "core", source: "./plugins/core" }],
        }),
    );
    writeFileSync(
        join(source, ".claude-plugin/plugin.json"),
        JSON.stringify({ name: "core" }),
    );
    writeFileSync(
        join(source, ".mcp.json"),
        JSON.stringify({
            mcpServers: { service: { command: "synthetic" } },
        }),
    );
    const manifest = {
        agents: ["claude", "codex"],
        plugins: [{ name: "core" }],
        mcp: [{ name: "service", owner: { claude: "global", codex: "core" } }],
    };
    const marketplace = prepareClaudeMarketplace(agentsDir, manifest);
    const live = join(marketplace, "plugins/core");
    assert.deepEqual(pluginMcpServers(live, "claude"), {});
    assert.deepEqual(Object.keys(pluginMcpServers(source, "codex")), ["service"]);
    manifest.mcp[0].owner.claude = "core";
    prepareClaudeMarketplace(agentsDir, manifest);
    assert.deepEqual(Object.keys(pluginMcpServers(live, "claude")), ["service"]);
    assert.deepEqual(
        pluginRoots(
            agentsDir,
            "claude",
            { id: "core@dotagents" },
            [],
            [
                {
                    id: "core@dotagents",
                    scope: "user",
                    readFromFolder: live,
                    installPath: "/stale/cache",
                },
            ],
        ),
        [live],
    );
});

test("native cache backups allow a previously removed MCP connection to be restored", (t) => {
    const root = mkdtempSync(join(tmpdir(), "dotfiles-native-"));
    t.after(() => rmSync(root, { recursive: true, force: true }));
    writeFileSync(
        join(root, ".mcp.json"),
        JSON.stringify({ mcpServers: { service: { command: "synthetic" } } }),
    );
    const manifest = {
        agents: ["claude"],
        mcp: [{ name: "service", owner: "global" }],
    };
    projectPluginMcp(root, root, manifest, { name: "service" }, "claude");
    assert.deepEqual(pluginMcpServers(root, "claude"), {});
    manifest.mcp[0].owner = "service";
    projectPluginMcp(root, root, manifest, { name: "service" }, "claude");
    assert.deepEqual(Object.keys(pluginMcpServers(root, "claude")), ["service"]);
});

test("explicit empty Codex MCP metadata excludes Claude-only root definitions", (t) => {
    const root = mkdtempSync(join(tmpdir(), "dotfiles-skills-only-"));
    t.after(() => rmSync(root, { recursive: true, force: true }));
    mkdirSync(join(root, ".codex-plugin"));
    writeFileSync(
        join(root, ".codex-plugin/plugin.json"),
        JSON.stringify({ mcpServers: {} }),
    );
    writeFileSync(
        join(root, ".mcp.json"),
        JSON.stringify({ mcpServers: { service: {} } }),
    );
    assert.deepEqual(pluginMcpServers(root, "codex"), {});
    assert.deepEqual(Object.keys(pluginMcpServers(root, "claude")), ["service"]);
    writeFileSync(
        join(root, ".codex-plugin/plugin.json"),
        JSON.stringify({ mcpServers: "../outside.json" }),
    );
    assert.throws(() => pluginMcpServers(root, "codex"), /inside the plugin/);
});
