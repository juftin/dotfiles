import assert from "node:assert/strict";
import {
    existsSync,
    mkdirSync,
    mkdtempSync,
    readFileSync,
    realpathSync,
    renameSync,
    rmSync,
    writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { exportAntigravityPlugins } from "./antigravity.mjs";

/** Build isolated plugin assets without changing any client's home directory. */
function fixture(t) {
    const root = realpathSync(mkdtempSync(join(tmpdir(), "dotfiles-ag-")));
    t.after(() => rmSync(root, { recursive: true, force: true }));
    const sourceRoot = join(root, "source");
    mkdirSync(join(sourceRoot, "skills/example"), { recursive: true });
    mkdirSync(join(sourceRoot, "scripts"));
    writeFileSync(
        join(sourceRoot, "skills/example/SKILL.md"),
        "---\nname: example\ndescription: Synthetic fixture\n---\nUse ../../scripts/helper.sh\n",
    );
    writeFileSync(join(sourceRoot, "scripts/helper.sh"), "echo synthetic\n");
    writeFileSync(
        join(sourceRoot, "plugin.json"),
        JSON.stringify({ name: "example", version: "1.0.0" }),
    );
    return { sourceRoot, destination: join(root, "plugins") };
}

test("Antigravity receives linked plugin skills, resources, and native lifecycle hooks", (t) => {
    const { sourceRoot, destination } = fixture(t);
    const hooks = {
        initialize: { SessionStart: [{ type: "command", command: "echo synthetic" }] },
    };
    writeFileSync(join(sourceRoot, "hooks.json"), JSON.stringify(hooks));
    writeFileSync(
        join(sourceRoot, "mcp.json"),
        JSON.stringify({ mcpServers: { duplicated: {} } }),
    );
    const bundles = [{ name: "example", sourceRoot }];
    exportAntigravityPlugins(destination, bundles);
    assert.equal(
        realpathSync(join(destination, "example/skills/example/SKILL.md")),
        join(sourceRoot, "skills/example/SKILL.md"),
    );
    assert.equal(
        realpathSync(join(destination, "example/scripts/helper.sh")),
        join(sourceRoot, "scripts/helper.sh"),
    );
    assert.deepEqual(
        JSON.parse(readFileSync(join(destination, "example/hooks.json"), "utf8")),
        hooks,
    );
    assert.equal(existsSync(join(destination, "example/mcp.json")), false);
    exportAntigravityPlugins(destination, bundles);
    assert.equal(
        JSON.parse(readFileSync(join(destination, "example/plugin.json"), "utf8"))
            .version,
        "1.0.0",
    );
    mkdirSync(join(destination, "personal"));
    exportAntigravityPlugins(destination, []);
    assert.equal(existsSync(join(destination, "example")), false);
    assert.equal(existsSync(join(destination, "personal")), true);
});

test("nested skill namespaces work while direct skills take precedence over legacy copies", (t) => {
    const { sourceRoot, destination } = fixture(t);
    mkdirSync(join(sourceRoot, "skills/namespace"));
    renameSync(
        join(sourceRoot, "skills/example"),
        join(sourceRoot, "skills/namespace/example"),
    );
    exportAntigravityPlugins(destination, [{ name: "example", sourceRoot }]);
    assert.equal(
        realpathSync(join(destination, "example/skills/example/SKILL.md")),
        join(sourceRoot, "skills/namespace/example/SKILL.md"),
    );
    mkdirSync(join(sourceRoot, "skills/example"));
    writeFileSync(
        join(sourceRoot, "skills/example/SKILL.md"),
        "Current synthetic skill",
    );
    exportAntigravityPlugins(destination, [{ name: "example", sourceRoot }]);
    assert.equal(
        realpathSync(join(destination, "example/skills/example/SKILL.md")),
        join(sourceRoot, "skills/example/SKILL.md"),
    );
});

test("Antigravity export preserves unmanaged collisions and rejects unsafe names", (t) => {
    const { sourceRoot, destination } = fixture(t);
    mkdirSync(join(destination, "example"), { recursive: true });
    assert.throws(
        () => exportAntigravityPlugins(destination, [{ name: "example", sourceRoot }]),
        /unmanaged/,
    );
    assert.throws(
        () =>
            exportAntigravityPlugins(destination, [{ name: "../outside", sourceRoot }]),
        /Invalid plugin name/,
    );
    assert.ok(existsSync(join(sourceRoot, "plugin.json")));
});

test("Claude lifecycle hooks require an explicit payload port before activation", (t) => {
    const { sourceRoot, destination } = fixture(t);
    mkdirSync(join(sourceRoot, "hooks"));
    writeFileSync(
        join(sourceRoot, "hooks/hooks.json"),
        JSON.stringify({ hooks: { SessionStart: [] } }),
    );
    assert.throws(
        () => exportAntigravityPlugins(destination, [{ name: "example", sourceRoot }]),
        /Port Claude hooks/,
    );
    assert.equal(existsSync(destination), false);
    rmSync(join(sourceRoot, "hooks"), { recursive: true });
    writeFileSync(
        join(sourceRoot, "hooks.json"),
        JSON.stringify({ hooks: { SessionStart: [] } }),
    );
    assert.throws(
        () => exportAntigravityPlugins(destination, [{ name: "example", sourceRoot }]),
        /not a Claude hooks wrapper/,
    );
});
