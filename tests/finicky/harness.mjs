// Test helpers for the Finicky config.
//
// bundleConfig() bundles a config the way Finicky 4 does (esbuild IIFE,
// neutral platform) and evaluates it in an empty VM context, which catches
// accidental dependencies on Node globals such as `require`.
//
// route() is a small stand-in for Finicky's handler matching. It supports
// function, RegExp, and array matchers. It throws on string wildcard matchers
// rather than guessing at Finicky's wildcard semantics.

import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import vm from "node:vm";

// Keep in sync with github.com/evanw/esbuild in Finicky's apps/finicky/src/go.mod.
const ESBUILD = "esbuild@0.24.2";

export const SLACK = {
  name: "Slack",
  bundleId: "com.tinyspeck.slackmacgap",
  path: "/Applications/Slack.app",
};

export function bundleConfig(entry) {
  const outfile = join(mkdtempSync(join(tmpdir(), "finicky-test-")), "bundle.js");
  execFileSync(
    "npx",
    [
      "--yes",
      ESBUILD,
      entry,
      "--bundle",
      "--format=iife",
      "--global-name=finickyConfig",
      "--platform=neutral",
      "--target=es2015",
      "--log-level=error",
      `--outfile=${outfile}`,
    ],
    { stdio: ["ignore", "ignore", "pipe"] },
  );

  const context = vm.createContext({});
  vm.runInContext(readFileSync(outfile, "utf8"), context);
  // Objects come from the VM realm, so compare fields rather than using
  // assert.deepStrictEqual on them.
  return context.finickyConfig.default;
}

function isMatch(matcher, url, options) {
  if (Array.isArray(matcher)) {
    return matcher.some((m) => isMatch(m, url, options));
  }
  if (typeof matcher === "function") {
    return Boolean(matcher(url, options));
  }
  if (Object.prototype.toString.call(matcher) === "[object RegExp]") {
    return matcher.test(url.href);
  }
  throw new Error(`unsupported matcher in test harness: ${String(matcher)}`);
}

export function route(config, url, opener = null) {
  const parsed = new URL(url);
  const options = { opener };
  const handler = (config.handlers ?? []).find((h) => isMatch(h.match, parsed, options));
  return handler ? handler.browser : config.defaultBrowser;
}

export function profileFor(config, url, opener = null) {
  const browser = route(config, url, opener);
  return `${browser.name}:${browser.profile}`;
}
