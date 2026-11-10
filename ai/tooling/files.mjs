import {
    constants,
    copyFileSync,
    existsSync,
    mkdirSync,
    readFileSync,
    writeFileSync,
    chmodSync,
} from "node:fs";
import { dirname } from "node:path";

/** Read optional application state, accepting initially empty files. */
export function readConfig(path, parser = JSON.parse) {
    if (!existsSync(path)) return {};
    const content = readFileSync(path, "utf8").trim();
    return content ? parser(content) : {};
}

/** Save local state with a first-run backup and owner-only permissions. */
export function saveConfig(path, content) {
    mkdirSync(dirname(path), { recursive: true });
    if (existsSync(path)) {
        if (readFileSync(path, "utf8") === content) {
            chmodSync(path, 0o600);
            return;
        }
        try {
            copyFileSync(path, `${path}.dotfiles-backup`, constants.COPYFILE_EXCL);
        } catch (error) {
            if (error.code !== "EEXIST") throw error;
        }
    }
    writeFileSync(path, content, { mode: 0o600 });
    chmodSync(path, 0o600);
}
