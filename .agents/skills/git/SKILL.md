---
name: git
description: >-
  Use after any task changes repository content in this repo, and for Git
  commits, amendments, staging, commit messages, or local history preparation.
  Ensure each completed change becomes a focused local commit. Reuse an
  unpublished commit when the new work has the same intent.
---

# Git

Use this skill after a completed task changes repository content. Also use it
when committing, amending, staging, or writing commit messages in this repo.

Do not create an empty commit for a read-only, no-op, or incomplete task. Do not
push unless the user explicitly asks.

## Commit Workflow

- Check `git status --short` before staging.
- Inspect the commits between the upstream branch and `HEAD`.
- Decide if the change belongs in an existing unpublished commit. Use the
  criteria in "Reuse an Unpublished Commit."
- Stage only files required for the requested commit. Leave unrelated dirty files untouched.
- Inspect `git diff --cached` before committing.
- Check the final commit message before creating or amending a commit.
- Commit the change or update a suitable unpublished commit.
- After committing or amending, show the local commit range, the new `HEAD`
  hash, and `git status --short`.

## Reuse an Unpublished Commit

Treat a commit as unpublished only when no known remote-tracking branch contains
it. Check remote-tracking branches before you rewrite a commit.

- Reuse a commit only when the new work has the same intent and forms one
  logical change with it. A shared file is not sufficient.
- Amend `HEAD` directly when it is a suitable unpublished commit.
- To update an earlier unpublished commit, use a fixup commit and autosquash
  only when the worktree has no unrelated changes and all rewritten commits are
  unpublished.
- If a rewrite can disturb unrelated work, create a new focused commit.
- If you are not sure that the intent matches, create a new focused commit.
- Never rewrite a published commit.

## Commit Message Format

- Prefer Conventional Commit subjects when the scope is clear, for example:
  `fix(nvim): fix gopls semantic token capabilities`
- Keep the subject concise and imperative-ish.
- Always include a body for non-trivial changes.
- Wrap each commit body line at 72 columns or fewer.
- Explain why the change is needed, not just what changed.
- Include concrete failure modes, commands, or errors when they motivated the change.
- Use indented blocks for quoted errors or command output.
- End each commit that Codex creates or amends with `Co-authored-by: Codex`.
- Do not add an email address to this trailer.

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
