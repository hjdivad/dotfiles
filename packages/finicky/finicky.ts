// Finicky (https://github.com/johnste/finicky) is the macOS default browser. It
// routes each link opened outside the browser (Slack, Mail, terminals, ...) to a
// specific browser and profile.
//
// Installed as a symlink at ~/.config/finicky/finicky.ts. Finicky resolves the
// symlink before bundling with esbuild, so relative imports resolve from this
// repo. Keep this file TypeScript: Finicky moves .js configs to a temp
// directory for a babel pass, which breaks relative imports.
//
// Machine- or work-specific rules live in the optional
// local-packages/finicky/finicky.ts. Its handlers and rewrites run before the
// ones here; its defaultBrowser and options override the ones here.
//
// Finicky caches the bundle until this file's mtime changes and only watches
// this file. After editing the local rules, run `task dot:finicky:reload`.

declare const require: (path: string) => any;

type Config = {
  defaultBrowser?: unknown;
  options?: Record<string, unknown>;
  rewrite?: unknown[];
  handlers?: unknown[];
};

const BRAVE_DEFAULT = { name: "Brave Browser", profile: "Default" };

const base: Config = {
  defaultBrowser: BRAVE_DEFAULT,
  options: {},
  rewrite: [],
  handlers: [],
};

function loadLocal(pkg: string, name: string): Config {
  try {
    // A template-literal require is an esbuild glob import. esbuild bundles
    // any matching files and still builds (with only a warning) when there are
    // none, so the local config is optional. The glob must start in a
    // directory that exists, so it starts at the repo root (`local-*`) rather
    // than in local-packages/finicky, which may be missing.
    const mod = require(`../../local-${pkg}/finicky/${name}.ts`);
    return mod.default ?? mod;
  } catch (error) {
    if (String(error).includes("Module not found in bundle")) {
      return {};
    }
    // Surface errors in the local config instead of silently dropping its rules.
    throw error;
  }
}

function merge(base: Config, local: Config): Config {
  return {
    ...base,
    ...local,
    options: { ...base.options, ...local.options },
    rewrite: [...(local.rewrite ?? []), ...(base.rewrite ?? [])],
    handlers: [...(local.handlers ?? []), ...(base.handlers ?? [])],
  };
}

export default merge(base, loadLocal("packages", "finicky"));
