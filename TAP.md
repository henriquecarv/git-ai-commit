# Homebrew tap: `git-ai-commit`

This repository is a [Homebrew tap](https://docs.brew.sh/Taps). After a one-time tap, install with the standard command:

```bash
brew tap henriquecarv/git-ai-commit https://github.com/henriquecarv/git-ai-commit.git
brew install git-ai-commit
git-ai-commit setup
```

Prerequisites:

- Cursor CLI Agent available as `agent` on `PATH`
- Git 2.x+

## What `git-ai-commit setup` does

- Verifies `agent` is on `PATH` (install from `https://cursor.com/install` if missing)
- Verifies `agent --version` works before configuring Git
- Sets `core.editor` in `~/.gitconfig` (interactive prompt)
- Sets `ai-commit.issue-prefix` (interactive prompt; optional)
- Sets `alias.ai-commit = !git-ai-commit`

After setup, use `git ai-commit` in any repository.

## Upgrade

```bash
brew upgrade git-ai-commit
```

Re-run `git-ai-commit setup` if you want to change your editor, issue prefix, refresh the alias, or re-check Cursor Agent availability.

## Local tap (development)

From a clone of this repository (after committing the formula and script):

```bash
brew tap henriquecarv/git-ai-commit "file://$(pwd)"
brew install --build-from-source git-ai-commit
```

## Tagged releases (maintainers)

For a checksum-pinned stable bottle (e.g. homebrew-core submission), tag a release and update the formula `url` / `sha256`:

```bash
git tag v1.0.0
git push origin v1.0.0

# Build tarball
mkdir -p /tmp/git-ai-commit-1.0.0
cp git-ai-commit setup LICENSE README.md /tmp/git-ai-commit-1.0.0/
cp -R .agents /tmp/git-ai-commit-1.0.0/
tar -czf git-ai-commit-1.0.0.tar.gz -C /tmp git-ai-commit-1.0.0
shasum -a 256 git-ai-commit-1.0.0.tar.gz
```

Point the formula at the hosted archive and set the matching `sha256`.

## homebrew-core (optional)

Once the formula is stable, open a PR to [homebrew-core](https://github.com/Homebrew/homebrew-core) so users can run `brew install git-ai-commit` without `brew tap`.
