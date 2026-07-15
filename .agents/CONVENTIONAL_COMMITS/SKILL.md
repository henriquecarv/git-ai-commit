---
name: conventional-commits
description: >-
  Generate a Conventional Commits message from a staged git diff. Use when the
  user runs git ai-commit or asks for a Conventional Commits message.
disable-model-invocation: true
---

# Conventional Commits

## Instructions

Write one high-quality Conventional Commits message for the staged diff.

**Output only the commit message.**

## Conventional Commits v1.0.0

1. Use this structure:

   ```text
   <type>[optional scope][optional !]: <description>

   [optional body]

   [optional footer(s)]
   ```

2. Use `feat` when the commit adds a feature.
3. Use `fix` when the commit fixes a bug.
4. Mark breaking changes with `!` before the colon or with a `BREAKING CHANGE:` footer.
5. If a breaking change footer is used, write `BREAKING CHANGE:` in uppercase, followed by a colon, a space, and a description.
6. Footers must use a token followed by a colon and space, or a hash (Git trailer style). Use `-` instead of whitespace in footer tokens, except for `BREAKING CHANGE`.

## Local rules

### Subject line

- Shape: `<type>[optional scope][optional !]: <imperative summary>`.
- Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.
- Use an imperative summary.
- Do not end with a period.
- Keep it strictly under 72 characters, including any issue prefix.

### Body

- Write one or more explanatory paragraphs for any non-trivial diff.
- Explain what changed, why it changed, and the practical impact.
- Summarize behavior and intent, not a file-by-file list.
- Do not use bullets, markdown fences, headings, analysis preambles, or labels.
- Wrap so no line exceeds 100 characters.

### Footers

- Add footers only after a blank line.
- Never invent issue references, people, email addresses, reviewers, co-authors, or metadata.
- `Co-authored-by:` is allowed only when the exact value is present in the diff.
- `Refs:` is allowed only when the exact reference is present in the diff or was provided directly by the user.
- `BREAKING CHANGE:` or `BREAKING-CHANGE:` is allowed only when the diff clearly shows a breaking change.

## Example

```text
fix: prevent racing of requests

Introduce a request id and dismiss stale responses.

Remove obsolete timeouts that mitigated the race.
```

**Output only the commit message.**
