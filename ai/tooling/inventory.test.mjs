import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { parse, stringify } from "smol-toml";
import { inventoryChecks } from "./check.mjs";
import { globalMcp } from "./config.mjs";
import { dotagentsConfig, pluginPlan } from "./manifest.mjs";

/** Create an isolated installation with one core plugin and one native plugin. */
function fixture(t) {
    const userHome = mkdtempSync(join(tmpdir(), "dotfiles-inventory-"));
    t.after(() => rmSync(userHome, { recursive: true, force: true }));
    const write = (path, value, toml = false) => {
        mkdirSync(dirname(path), { recursive: true });
        writeFileSync(path, toml ? stringify(value) : JSON.stringify(value));
    };
    const manifest = {
        version: 1,
        agents: ["claude", "codex"],
        skills: [],
        plugins: [
            { name: "core", source: "synthetic/core" },
            {
                name: "native",
                installer: "native",
                claude: "native@synthetic",
                codex: "native@synthetic",
            },
        ],
        mcp: [
            { name: "global", url: "https://synthetic.test/mcp" },
            { name: "service", owner: "core" },
            { name: "native", owner: "native" },
        ],
    };
    const codexPlugins = [];
    const registry = { plugins: {} };
    const roots = {};
    for (const agent of manifest.agents) {
        const config =
            agent === "claude"
                ? { enabledPlugins: {} }
                : { plugins: {}, mcp_servers: globalMcp(manifest, agent) };
        for (const plugin of pluginPlan(manifest, agent)) {
            const root = join(
                userHome,
                agent === "claude" ? ".claude/plugins/cache" : ".codex/plugins/cache",
                plugin.native
                    ? "synthetic"
                    : agent === "claude"
                      ? "dotagents"
                      : "dotagents-local",
                plugin.name,
                "1",
            );
            roots[`${agent}:${plugin.name}`] = root;
            write(join(root, `.${agent}-plugin/plugin.json`), { name: plugin.name });
            write(join(root, ".mcp.json"), {
                mcpServers: {
                    [plugin.native ? "native" : "service"]: { command: "synthetic" },
                },
            });
            if (agent === "claude") {
                config.enabledPlugins[plugin.id] = true;
                registry.plugins[plugin.id] = [{ scope: "user", installPath: root }];
            } else {
                config.plugins[plugin.id] = { enabled: true };
                codexPlugins.push({
                    pluginId: plugin.id,
                    version: "1",
                    installed: true,
                    enabled: true,
                });
            }
            if (!plugin.native)
                write(join(userHome, ".agents/plugins", plugin.name, ".mcp.json"), {
                    mcpServers: { service: { command: "synthetic" } },
                });
        }
        write(
            join(
                userHome,
                agent === "claude" ? ".claude/settings.json" : ".codex/config.toml",
            ),
            config,
            agent === "codex",
        );
    }
    write(join(userHome, ".claude.json"), {
        mcpServers: globalMcp(manifest, "claude"),
    });
    write(join(userHome, ".claude/plugins/installed_plugins.json"), registry);
    write(join(userHome, ".agents/agents.toml"), dotagentsConfig(manifest), true);
    return { manifest, userHome, codexPlugins, roots, write };
}

test("complete core and native installations pass without changing client files", (t) => {
    const f = fixture(t);
    const path = join(f.userHome, ".claude/settings.json");
    const before = readFileSync(path, "utf8");
    assert.ok(inventoryChecks(f.manifest, f).every((check) => check.status === "ok"));
    assert.equal(readFileSync(path, "utf8"), before);
});

test("marketplace-defined native bundles need no compatibility manifest", (t) => {
    const f = fixture(t);
    rmSync(join(f.roots["claude:native"], ".claude-plugin"), { recursive: true });
    assert.ok(inventoryChecks(f.manifest, f).every((check) => check.status === "ok"));
});

test("disabled global and plugin MCP connections fail ownership verification", (t) => {
    const f = fixture(t);
    f.write(
        join(f.userHome, ".codex/config.toml"),
        {
            plugins: {
                "core@dotagents-local": {
                    enabled: true,
                    mcp_servers: { service: { enabled: false } },
                },
                "native@synthetic": { enabled: true },
            },
            mcp_servers: {
                ...globalMcp(f.manifest, "codex"),
                global: { url: "https://synthetic.test/mcp", enabled: false },
            },
        },
        true,
    );
    const check = inventoryChecks(f.manifest, f).find(
        (entry) => entry.name === "codex MCP ownership",
    );
    assert.equal(check.status, "error");
    assert.match(check.message, /service is disabled/);
    assert.match(check.message, /global MCP global is disabled/);
});

test("empty generated inventories fail even when their own doctor reports healthy", (t) => {
    const f = fixture(t);
    f.write(
        join(f.userHome, ".agents/agents.toml"),
        { version: 1, agents: [], skills: [], plugins: [] },
        true,
    );
    assert.equal(
        inventoryChecks(f.manifest, f).find(
            (check) => check.name === "source inventory",
        ).status,
        "error",
    );
});

test("missing and disabled native plugins fail installation verification", (t) => {
    const f = fixture(t);
    rmSync(f.roots["claude:native"], { recursive: true });
    f.codexPlugins.find((entry) => entry.pluginId === "native@synthetic").enabled =
        false;
    const errors = inventoryChecks(f.manifest, f).filter(
        (check) => check.status === "error",
    );
    assert.ok(errors.some((check) => check.name === "claude plugins"));
    assert.ok(errors.some((check) => check.name === "codex plugins"));
});

test("stale cached MCPs and duplicate global ownership fail without printing credentials", (t) => {
    const f = fixture(t);
    f.write(join(f.roots["claude:core"], ".mcp.json"), {
        mcpServers: {
            service: { command: "synthetic" },
            global: { headers: { Authorization: "synthetic-secret" } },
        },
    });
    f.write(join(f.userHome, ".claude.json"), {
        mcpServers: { service: { command: "synthetic" } },
    });
    const checks = inventoryChecks(f.manifest, f);
    assert.equal(
        checks.find((check) => check.name === "claude MCP ownership").status,
        "error",
    );
    assert.equal(JSON.stringify(checks).includes("synthetic-secret"), false);
});

test("Claude in-place load paths take priority over healthy but unused caches", (t) => {
    const f = fixture(t);
    const live = join(f.userHome, "live-core");
    f.write(join(live, ".claude-plugin/plugin.json"), { name: "core" });
    f.write(join(live, ".mcp.json"), {
        mcpServers: {
            service: { command: "synthetic" },
            global: { command: "synthetic" },
        },
    });
    f.claudePlugins = [
        {
            id: "core@dotagents",
            scope: "user",
            installPath: f.roots["claude:core"],
            readFromFolder: live,
        },
    ];
    const check = inventoryChecks(f.manifest, f).find(
        (entry) => entry.name === "claude MCP ownership",
    );
    assert.equal(check.status, "error");
    assert.match(check.message, /global is loaded by non-owner/);
});

test("unmanaged plugin overlaps fail without modifying unrelated client resources", (t) => {
    const f = fixture(t);
    const paths = {
        claude: join(f.userHome, ".claude/settings.json"),
        codex: join(f.userHome, ".codex/config.toml"),
    };
    const extras = {
        claude: join(f.userHome, "personal-plugin"),
        codex: join(f.userHome, ".codex/plugins/cache/personal/extra/1"),
    };
    for (const agent of ["claude", "codex"]) {
        f.write(join(extras[agent], ".mcp.json"), {
            mcpServers: { service: { command: "synthetic" } },
        });
        const path = paths[agent];
        const config =
            agent === "claude"
                ? JSON.parse(readFileSync(path, "utf8"))
                : parse(readFileSync(path, "utf8"));
        if (agent === "claude") config.enabledPlugins["extra@personal"] = true;
        else config.plugins["extra@personal"] = { enabled: true };
        f.write(path, config, agent === "codex");
    }
    f.claudePlugins = [
        {
            id: "extra@personal",
            scope: "user",
            enabled: true,
            readFromFolder: extras.claude,
            installPath: extras.claude,
        },
    ];
    f.codexPlugins.push({
        pluginId: "extra@personal",
        installed: true,
        enabled: true,
        version: "1",
    });
    const before = Object.values(paths).map((path) => readFileSync(path, "utf8"));
    let checks = inventoryChecks(f.manifest, f);
    for (const agent of ["claude", "codex"]) {
        const check = checks.find((entry) => entry.name === `${agent} MCP ownership`);
        assert.equal(check.status, "error");
        assert.match(
            check.message,
            /service is also loaded by unmanaged plugin extra@personal/,
        );
    }
    assert.deepEqual(
        Object.values(paths).map((path) => readFileSync(path, "utf8")),
        before,
    );
    for (const root of Object.values(extras)) {
        f.write(join(root, ".mcp.json"), {
            mcpServers: { unrelated: { command: "synthetic" } },
        });
    }
    checks = inventoryChecks(f.manifest, f);
    assert.ok(checks.every((check) => check.status === "ok"));
});

test("missing plugin-owned MCPs and stale global transports fail verification", (t) => {
    const f = fixture(t);
    f.write(join(f.roots["codex:native"], ".mcp.json"), { mcpServers: {} });
    f.write(join(f.userHome, ".claude.json"), {
        mcpServers: { global: { url: "https://wrong.synthetic.test" } },
    });
    const checks = inventoryChecks(f.manifest, f);
    assert.equal(
        checks.find((check) => check.name === "codex MCP ownership").status,
        "error",
    );
    assert.equal(
        checks.find((check) => check.name === "claude MCP ownership").status,
        "error",
    );
});
