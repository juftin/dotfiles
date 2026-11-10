import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { reportChecks } from "./check.mjs";

const compatibility = {
    name: "plugin compatibility",
    status: "warn",
    message: "An upstream bundle contains ignored legacy resources.",
};

test("compatibility notices remain visible without failing intact installations", () => {
    const output = [];
    assert.equal(
        reportChecks(
            [
                compatibility,
                { name: "plugin runtime", status: "ok", message: "Artifacts intact." },
            ],
            (line) => output.push(line),
        ),
        0,
    );
    assert.ok(output.includes(`  ! ${compatibility.message}`));
    assert.ok(output.includes("  ✓ Artifacts intact."));
});

test("runtime drift, missing dependencies, errors, and unknown warnings still fail", () => {
    for (const finding of [
        { name: "plugin runtime", status: "warn" },
        { name: "installed skills", status: "error" },
        { name: "installed plugins", status: "error" },
        { name: "plugin compatibility", status: "error" },
        { name: "new upstream check", status: "warn" },
    ]) {
        assert.equal(
            reportChecks(
                [compatibility, { ...finding, message: "Needs repair." }],
                () => {},
            ),
            1,
            JSON.stringify(finding),
        );
    }
});

test("the check command fails when the global manifest is missing", () => {
    const directory = mkdtempSync(join(tmpdir(), "dotfiles-check-"));
    try {
        const result = spawnSync(
            process.execPath,
            [new URL("./check.mjs", import.meta.url).pathname],
            {
                env: { ...process.env, DOTAGENTS_HOME: directory },
                encoding: "utf8",
            },
        );
        assert.ifError(result.error);
        assert.equal(result.status, 1);
        assert.match(result.stdout, /agents\.toml not found/);
    } finally {
        rmSync(directory, { recursive: true, force: true });
    }
});
