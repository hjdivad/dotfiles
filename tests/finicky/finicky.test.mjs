import assert from "node:assert/strict";
import { copyFileSync, mkdirSync, mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

import { bundleConfig, profileFor, SLACK } from "./harness.mjs";

const REPO_ROOT = join(dirname(fileURLToPath(import.meta.url)), "..", "..");
const CONFIG = join(REPO_ROOT, "packages", "finicky", "finicky.ts");

// Copy the global config into a temp tree that mirrors the repo layout, with
// an optional local-packages/finicky/finicky.ts.
function makeTree(localSource, { localPackagesDir = false } = {}) {
  const root = mkdtempSync(join(tmpdir(), "finicky-tree-"));
  const entry = join(root, "packages", "finicky", "finicky.ts");
  mkdirSync(dirname(entry), { recursive: true });
  copyFileSync(CONFIG, entry);

  if (localPackagesDir) {
    mkdirSync(join(root, "local-packages", "dotfiles"), { recursive: true });
  }

  if (localSource !== undefined) {
    const local = join(root, "local-packages", "finicky", "finicky.ts");
    mkdirSync(dirname(local), { recursive: true });
    writeFileSync(local, localSource);
  }
  return entry;
}

test("without local rules, everything opens in the Brave Default profile", () => {
  const config = bundleConfig(makeTree());

  assert.equal(config.handlers.length, 0);
  assert.equal(config.rewrite.length, 0);
  assert.equal(profileFor(config, "https://example.com/"), "Brave Browser:Default");
  assert.equal(profileFor(config, "https://example.com/", SLACK), "Brave Browser:Default");
});

test("a local-packages checkout without finicky rules uses the global config", () => {
  const config = bundleConfig(makeTree(undefined, { localPackagesDir: true }));

  assert.equal(config.handlers.length, 0);
  assert.equal(profileFor(config, "https://example.com/"), "Brave Browser:Default");
});

test("local handlers run before global handlers and local options merge", () => {
  const config = bundleConfig(
    makeTree(`
      export default {
        options: { keepRunning: false },
        handlers: [
          { match: (url) => url.host === "example.com", browser: { name: "Brave Browser", profile: "Other" } },
        ],
      };
    `),
  );

  assert.equal(config.options.keepRunning, false);
  assert.equal(profileFor(config, "https://example.com/a"), "Brave Browser:Other");
  assert.equal(profileFor(config, "https://example.org/a"), "Brave Browser:Default");
});

test("a local defaultBrowser overrides the global default", () => {
  const config = bundleConfig(
    makeTree(`export default { defaultBrowser: { name: "Brave Browser", profile: "Other" } };`),
  );

  assert.equal(profileFor(config, "https://example.org/"), "Brave Browser:Other");
});

test("errors in the local config are not swallowed", () => {
  assert.throws(
    () => bundleConfig(makeTree(`throw new Error("broken local finicky config");`)),
    /broken local finicky config/,
  );
});
