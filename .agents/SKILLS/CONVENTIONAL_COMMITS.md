Write one high-quality Conventional Commits message for this staged diff.
Output only the commit message.

Follow Conventional Commits v1.0.0:

1. The commit message must use this structure:

    <type>[optional scope][optional !]: <description>

    [optional body]

    [optional footer(s)]

2. Use `feat` when the commit adds a feature.
3. Use `fix` when the commit fixes a bug.
4. Mark breaking changes with `!` before the colon or with a `BREAKING CHANGE:` footer.
5. If a breaking change footer is used, write `BREAKING CHANGE:` in uppercase, followed by a colon, a space, and a description.
6. Footers must use a token followed by `: ` or ` #`, similar to Git trailers. Use `-` instead of whitespace in footer tokens, except for `BREAKING CHANGE`.

Local rules:

1. Subject line:
    - Shape: `<type>[optional scope][optional !]: <imperative summary>`.
    - Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.
    - Use an imperative summary.
    - Do not end with a period.
    - Keep it strictly under 72 characters, including any issue prefix.
2. Body:
    - Write one or more explanatory paragraphs for any non-trivial diff.
    - Explain what changed, why it changed, and the practical impact.
    - Summarize behavior and intent, not a file-by-file list.
    - Do not use bullets, markdown fences, headings, analysis preambles, or labels.
    - Wrap so no line exceeds 100 characters.
3. Footers:
    - Add footers only after a blank line.
    - Never invent issue references, people, email addresses, reviewers, co-authors, or metadata.
    - `Co-authored-by:` is allowed only when the exact value is present in the diff.
    - `Refs:` is allowed only when the exact reference is present in the diff or was provided directly by the user.
    - `BREAKING CHANGE:` or `BREAKING-CHANGE:` is allowed only when the diff clearly shows a breaking change.

Example shape:

fix: prevent racing of requests

Introduce a request id and dismiss stale responses.

Remove obsolete timeouts that mitigated the race.

Output only the commit message.
