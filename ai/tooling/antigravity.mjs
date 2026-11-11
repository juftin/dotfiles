import {
    existsSync,
    mkdirSync,
    readFileSync,
    readdirSync,
    rmSync,
    symlinkSync,
    writeFileSync,
} from "node:fs";
import { basename, join } from "node:path";

const marker = ".dotfiles-managed";
const reserved = new Set([
    "plugin.json",
    "mcp.json",
    "mcp_config.json",
    "hooks.json",
    "hooks",
    "agents",
    "rules",
    "node_modules",
    "skills",
]);
const events = new Set([
    "SessionStart",
    "PreToolUse",
    "PostToolUse",
    "PreInvocation",
    "PostInvocation",
    "Stop",
    "enabled",
]);

/** Load native Antigravity hooks without pretending Claude payloads are compatible. */
function nativeHooks(sourceRoot) {
    const path = join(sourceRoot, "hooks.json");
    if (!existsSync(path)) {
        if (existsSync(join(sourceRoot, "hooks/hooks.json"))) {
            throw new Error(
                `Port Claude hooks to native Antigravity hooks.json in ${sourceRoot}.`,
            );
        }
        return undefined;
    }
    const hooks = JSON.parse(readFileSync(path, "utf8"));
    if (Object.hasOwn(hooks, "hooks")) {
        throw new Error(
            "Expected native Antigravity hooks.json, not a Claude hooks wrapper in " +
                path,
        );
    }
    for (const definition of Object.values(hooks)) {
        if (
            !definition ||
            typeof definition !== "object" ||
            Array.isArray(definition) ||
            Object.keys(definition).some((key) => !events.has(key))
        ) {
            throw new Error(`Expected native Antigravity hook definitions in ${path}.`);
        }
    }
    return hooks;
}

/** Find skill roots even when an upstream bundle adds a namespace directory. */
function skillDirectories(directory) {
    if (!existsSync(directory)) return [];
    if (existsSync(join(directory, "SKILL.md"))) return [directory];
    const children = readdirSync(directory, { withFileTypes: true })
        .filter((entry) => entry.isDirectory())
        .map((entry) => join(directory, entry.name));
    const direct = children.filter((path) => existsSync(join(path, "SKILL.md")));
    return direct.length ? direct : children.flatMap(skillDirectories);
}

/** Export owned plugin bundles, preserving unrelated plugins and linked skill resources. */
export function exportAntigravityPlugins(destination, bundles) {
    const prepared = bundles.map(({ name, sourceRoot }) => {
        if (!/^[a-z0-9]+(?:[.-][a-z0-9]+)*$/.test(name)) {
            throw new Error(`Invalid plugin name: ${name}`);
        }
        const target = join(destination, name);
        if (existsSync(target) && !existsSync(join(target, marker))) {
            throw new Error(
                `Refusing to replace unmanaged Antigravity plugin ${name}.`,
            );
        }
        const metadataPath = ["plugin.json", ".claude-plugin/plugin.json"]
            .map((file) => join(sourceRoot, file))
            .find(existsSync);
        if (!metadataPath) throw new Error(`Plugin manifest missing in ${sourceRoot}.`);
        const skills = skillDirectories(join(sourceRoot, "skills"));
        if (new Set(skills.map((skill) => basename(skill))).size !== skills.length) {
            throw new Error("Conflicting skill folder names in " + sourceRoot);
        }
        return {
            skills,
            name,
            sourceRoot,
            target,
            metadata: JSON.parse(readFileSync(metadataPath, "utf8")),
            hooks: nativeHooks(sourceRoot),
        };
    });
    mkdirSync(destination, { recursive: true });
    const desired = new Set(prepared.map((bundle) => bundle.name));
    for (const entry of readdirSync(destination)) {
        if (!desired.has(entry) && existsSync(join(destination, entry, marker))) {
            rmSync(join(destination, entry), { recursive: true });
        }
    }
    for (const { name, sourceRoot, target, metadata, hooks, skills } of prepared) {
        if (existsSync(target)) rmSync(target, { recursive: true });
        mkdirSync(target, { recursive: true });
        writeFileSync(
            join(target, marker),
            "Managed by dotfiles ai/tooling/install.mjs\n",
            {
                mode: 0o600,
            },
        );
        writeFileSync(
            join(target, "plugin.json"),
            JSON.stringify(
                {
                    $schema: "https://antigravity.google/schemas/v1/plugin.json",
                    name,
                    version: metadata.version ?? "0.0.0",
                    description: metadata.description ?? name,
                },
                null,
                4,
            ) + "\n",
            { mode: 0o600 },
        );
        for (const entry of readdirSync(sourceRoot)) {
            if (!entry.startsWith(".") && !reserved.has(entry)) {
                symlinkSync(join(sourceRoot, entry), join(target, entry));
            }
        }
        if (skills.length) {
            mkdirSync(join(target, "skills"));
            for (const skill of skills) {
                symlinkSync(skill, join(target, "skills", basename(skill)));
            }
        }
        if (hooks)
            writeFileSync(
                join(target, "hooks.json"),
                JSON.stringify(hooks, null, 4) + "\n",
                { mode: 0o600 },
            );
    }
}
