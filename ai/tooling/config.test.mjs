import assert from "node:assert/strict";
import test from "node:test";
import {
    antigravityServers,
    codexMcpAuth,
    globalMcp,
    mergeMcp,
    mergeSettings,
} from "./config.mjs";

test("portable settings preserve project trust, plugins, and other local preferences", () => {
    const current = {
        features: { local_feature: true, apps: true },
        projects: { "/tmp/example": { trust_level: "trusted" } },
        plugins: { "example@local": { enabled: true } },
    };
    const result = mergeSettings(current, {
        features: { apps: false },
        model: "example-model",
    });
    assert.equal(result.features.apps, false);
    assert.equal(result.features.local_feature, true);
    assert.deepEqual(result.projects, current.projects);
    assert.deepEqual(result.plugins, current.plugins);
    assert.equal(current.features.apps, true);
});

test("Antigravity receives HTTP headers and stdio environment values at runtime", () => {
    const result = antigravityServers(
        [
            {
                name: "remote",
                url: "https://example.test/mcp",
                headers: { Authorization: "Bearer ${SYNTHETIC_TOKEN}" },
            },
            {
                name: "local",
                command: "example",
                args: ["--token", "${SYNTHETIC_TOKEN}"],
                env: ["SYNTHETIC_TOKEN"],
            },
        ],
        { SYNTHETIC_TOKEN: "synthetic-test-value" },
    );
    assert.deepEqual(result.remote, {
        serverUrl: "https://example.test/mcp",
        headers: { Authorization: "Bearer synthetic-test-value" },
    });
    assert.deepEqual(result.local, {
        command: "example",
        args: ["--token", "synthetic-test-value"],
        env: { SYNTHETIC_TOKEN: "synthetic-test-value" },
    });
});

test("Codex bearer tokens use environment names instead of literal placeholders", () => {
    const current = {
        model: "example-model",
        mcp_servers: {
            github: {
                url: "https://example.test/mcp",
                http_headers: {
                    Authorization: "Bearer ${SYNTHETIC_TOKEN}",
                    "X-Example": "keep",
                },
            },
            other: { url: "https://other.test/mcp" },
        },
    };
    const servers = [
        {
            name: "github",
            headers: { Authorization: "Bearer ${SYNTHETIC_TOKEN}" },
        },
    ];
    const result = codexMcpAuth(current, servers);
    assert.deepEqual(result.mcp_servers.github, {
        url: "https://example.test/mcp",
        bearer_token_env_var: "SYNTHETIC_TOKEN",
        http_headers: { "X-Example": "keep" },
    });
    assert.deepEqual(result.mcp_servers.other, current.mcp_servers.other);
    assert.equal(result.model, current.model);
    assert.ok(current.mcp_servers.github.http_headers.Authorization);
    assert.deepEqual(codexMcpAuth(result, servers), result);

    const withoutOtherHeaders = codexMcpAuth(
        {
            mcp_servers: {
                github: {
                    http_headers: {
                        Authorization: "Bearer ${SYNTHETIC_TOKEN}",
                    },
                },
            },
        },
        servers,
    );
    assert.equal(withoutOtherHeaders.mcp_servers.github.http_headers, undefined);
    assert.deepEqual(codexMcpAuth(current, []), current);
});

test("missing credentials produce an actionable error without exposing values", () => {
    assert.throws(
        () =>
            antigravityServers(
                [{ name: "remote", url: "https://example.test/${MISSING_TOKEN}" }],
                {},
            ),
        /Set MISSING_TOKEN before installing/,
    );
});

test("per-client globals are serialized independently with Codex runtime bearer authentication", () => {
    const manifest = {
        agents: ["claude", "codex"],
        mcp: [
            {
                name: "service",
                url: "https://synthetic.test/mcp",
                owner: { claude: "service", codex: "global" },
                headers: { Authorization: "Bearer ${SYNTHETIC_TOKEN}" },
            },
        ],
    };
    assert.deepEqual(globalMcp(manifest, "claude"), {});
    assert.deepEqual(globalMcp(manifest, "codex"), {
        service: {
            url: "https://synthetic.test/mcp",
            bearer_token_env_var: "SYNTHETIC_TOKEN",
        },
    });
    manifest.mcp[0].owner = { claude: "global", codex: "service" };
    assert.deepEqual(globalMcp(manifest, "codex"), {});
    assert.equal(
        globalMcp(manifest, "claude").service.url,
        "https://synthetic.test/mcp",
    );
});

test("MCP updates remove stale managed servers and preserve unrelated configuration", () => {
    const current = {
        custom: true,
        mcpServers: { personal: { command: "personal" }, stale: { command: "old" } },
    };
    const servers = { managed: { serverUrl: "https://example.test/mcp" } };
    const result = mergeMcp(current, ["stale"], servers);
    assert.deepEqual(result, {
        custom: true,
        mcpServers: { personal: current.mcpServers.personal, ...servers },
    });
    assert.deepEqual(mergeMcp(result, ["managed"], servers), result);
    assert.ok(current.mcpServers.stale);
});
