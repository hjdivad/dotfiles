---
name: git
description: >-
  Use for git commits, amending commits, commit messages, staging changes, or
  preparing local git history in this repo. Ensures only intended files are
  staged and commit messages explain why with standard wrapped body lines.
---

# Git

Use this skill whenever committing, amending, staging, or writing commit messages in this repo.

## Commit Workflow

- Check `git status --short` before staging.
- Stage only files required for the requested commit. Leave unrelated dirty files untouched.
- Inspect `git diff --cached` before committing.
- After committing or amending, show the new `HEAD` hash and confirm `git status --short`.

## Commit Message Format

- Prefer Conventional Commit subjects when the scope is clear, for example:
  `fix(nvim): fix gopls semantic token capabilities`
- Keep the subject concise and imperative-ish.
- Always include a body for non-trivial changes.
- Wrap body lines to standard git commit width, about 72 columns.
- Explain why the change is needed, not just what changed.
- Include concrete failure modes, commands, or errors when they motivated the change.
- Use indented blocks for quoted errors or command output.

## Body Template

Use this structure when it fits:

```text
<why the current behavior is wrong or insufficient>

<what this change does and why that fixes the issue>

<notable validation, caveats, or follow-on behavior>
```

For bug fixes, include the observed error if useful:

```text
Resolves errors like:

    attempt to index local 'semantic' (a nil value)
```

## Quality Bar

- A good message should let future readers understand the failure without
  reconstructing the whole debugging session.
- Do not use vague bodies like "Update config" or "Fix issue".
- If the user gives an exact subject or body text, preserve it unless it is
  technically wrong; improve wrapping and add missing justification as needed.
