import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import test from "node:test";

test("container bootstrap skips agent dependencies while explicit agent installation still runs", () => {
    const source = readFileSync(
        new URL("../../bootstrap/bootstrap.sh", import.meta.url),
        "utf8",
    );
    const epilogue = source.slice(
        source.lastIndexOf('if [ "${1:-}" = "--agents" ]; then'),
    );
    const stubs = [
        "dotfiles_ascii",
        "install_dependencies",
        "install_binaries",
        "install_dotfiles",
        "init_submodules",
        "symlink_dotfiles",
        "symlink_ai_files",
        "log_success",
    ]
        .map((name) => `${name}() { :; }`)
        .join("\n");
    const script = `set -e\n${stubs}\ninstall_ai_agents() { echo agents-installed; }\n${epilogue}`;
    const run = (args) =>
        spawnSync("bash", ["-c", script, "fixture", ...args], {
            encoding: "utf8",
            env: { ...process.env, DOTFILES_SKIP_AGENTS: "1" },
        });
    const container = run([]);
    assert.equal(container.status, 0);
    assert.equal(container.stdout.includes("agents-installed"), false);
    const explicit = run(["--agents"]);
    assert.equal(explicit.status, 0);
    assert.match(explicit.stdout, /agents-installed/);
    assert.match(
        readFileSync(new URL("../../Dockerfile", import.meta.url), "utf8"),
        /RUN DOTFILES_SKIP_AGENTS=1 make .* bootstrap/,
    );
});
