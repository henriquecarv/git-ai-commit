# Git AI Commit

Generate a **Conventional Commits** message from your staged diff using local [Ollama](https://ollama.com) with `phi4-mini`, then open your Git editor for review before committing.

Works on **macOS**, **Linux**, and **Windows** (via [Git for Windows](https://git-scm.com/download/win) Bash, MSYS2, or WSL).

## Features

- Summarizes **staged** changes only (lockfiles excluded)
- Conventional Commits format (subject + body + optional footers)
- Wraps body lines to 100 characters
- Optional issue reference on the subject line (`AB#12345`)
- Always opens your editor (`git commit -ve`) — nothing is committed without your approval

## Platform support

| Platform    | Supported terminal                                                       | Install location                                   |
| ----------- | ------------------------------------------------------------------------ | -------------------------------------------------- |
| **macOS**   | Terminal, iTerm, etc.                                                    | `$(brew --prefix)/bin/git-ai-commit` (Homebrew)    |
| **Linux**   | Any POSIX shell                                                          | `$(brew --prefix)/bin/git-ai-commit` (Homebrew)    |
| **Windows** | **Git Bash**, MSYS2, or **WSL** (not plain `cmd.exe` / PowerShell alone) | `%USERPROFILE%\.config\git\git-ai-commit` (manual) |

`git-ai-commit` is a POSIX `sh` script. On Windows, run `git ai-commit` from **Git Bash** or WSL so Git can invoke `sh` and the script's utilities (`mktemp`, `fold`, etc.).

## Prerequisites

| Requirement        | Notes                                                            |
| ------------------ | ---------------------------------------------------------------- |
| **Git** 2.x+       | Alias support required                                           |
| **POSIX shell**    | Provided by macOS/Linux natively; on Windows use Git Bash or WSL |
| **Ollama** 0.5.13+ | `ollama` on `PATH`; `ollama agent` must work                     |
| **phi4-mini**      | Pulled locally in Ollama (`setup` can do this interactively)     |
| **Staged changes** | Run `git add` before `git ai-commit`                             |

Verify the CLI (same on all platforms):

```bash
ollama --version
ollama list
ollama agent --help
```

Install Ollama:

```bash
# macOS / Linux
curl -fsSL https://ollama.com/install.sh | sh

# Then pull the model (setup can do this interactively)
ollama pull phi4-mini
```

## Installation

### Homebrew (macOS and Linux — recommended)

This repository is a Homebrew tap. Add it once, then install with the standard command:

```bash
brew tap henriquecarv/git-ai-commit https://github.com/henriquecarv/git-ai-commit.git
brew install git-ai-commit
git-ai-commit setup
```

Ollama must be installed separately. `git-ai-commit setup` verifies that `ollama` is on `PATH`, checks for `phi4-mini`, and offers to run `ollama pull phi4-mini` before configuring Git.

**`git-ai-commit setup`** interactively configures `~/.gitconfig`:

- `core.editor` — e.g. `vim`, `nano`, `code --wait`, `cursor --wait`
- `ai-commit.issue-prefix` — e.g. `AB#`, `JIRA-`, `GH-` (optional; leave blank for none)
- `alias.ai-commit` — `!git-ai-commit`

After setup, use `git ai-commit` in any repository.

**Upgrade**

```bash
brew upgrade git-ai-commit
```

Re-run `git-ai-commit setup` if you want to change your editor, issue prefix, refresh the alias, or re-check Ollama/model availability.

See [TAP.md](TAP.md) for local tap development and maintainer release notes.

---

### Manual installation (alternative — macOS, Linux, Windows)

Use this path if you do not use Homebrew (required on Windows).

#### Install path

| OS           | Script directory                           |
| ------------ | ------------------------------------------ |
| macOS, Linux | `~/.config/git/git-ai-commit/`             |
| Windows      | `%USERPROFILE%\.config\git\git-ai-commit\` |

Global Git config file:

| OS           | File                       |
| ------------ | -------------------------- |
| macOS, Linux | `~/.gitconfig`             |
| Windows      | `%USERPROFILE%\.gitconfig` |

#### 1. Clone this repository

**macOS / Linux / Git Bash**

```bash
mkdir -p ~/.config/git
git clone https://github.com/henriquecarv/git-ai-commit.git ~/.config/git/git-ai-commit
```

SSH alternative:

```bash
git clone git@github.com:henriquecarv/git-ai-commit.git ~/.config/git/git-ai-commit
```

**Windows (PowerShell — clone only)**

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\git"
git clone https://github.com/henriquecarv/git-ai-commit.git "$env:USERPROFILE\.config\git\git-ai-commit"
```

Continue setup from **Git Bash** (see below).

#### 2. Make scripts executable

Run from **Git Bash** on Windows, or any terminal on macOS/Linux:

```bash
chmod +x ~/.config/git/git-ai-commit/git-ai-commit
chmod +x ~/.config/git/git-ai-commit/setup
```

#### 3. Configure Git (automated setup)

Run either command:

```bash
~/.config/git/git-ai-commit/git-ai-commit setup
```

Or invoke the setup script directly:

```bash
~/.config/git/git-ai-commit/setup
```

This interactively sets `core.editor`, `ai-commit.issue-prefix`, and `alias.ai-commit` in `~/.gitconfig`. The alias uses the full path to `git-ai-commit` when it is not on `PATH`.
Before the Git prompts, setup verifies that `ollama` is installed, checks for `phi4-mini`, and offers to pull it if needed.

After setup, use `git ai-commit` in any repository.

#### 4. Configure Git manually (without setup script)

Edit `~/.gitconfig` (or `%USERPROFILE%\.gitconfig` on Windows) and add:

**macOS / Linux / Git Bash**

```ini
[core]
    editor = vim

[ai-commit]
    issue-prefix = AB#

[alias]
    ai-commit = "!$HOME/.config/git/git-ai-commit/git-ai-commit"
```

Replace `editor` with your preferred editor, for example:

- `vim` or `nano`
- `code --wait` (VS Code)
- `cursor --wait` (Cursor)
- `notepad` (Windows Git Bash)

The `ai-commit` alias must point at the cloned `git-ai-commit` script. Adjust the path if you installed elsewhere.

#### 5. Update later

```bash
cd ~/.config/git/git-ai-commit && git pull
```

---

#### Windows notes

- Run `git ai-commit` from **Git Bash** or WSL, not plain `cmd.exe` / PowerShell.
- `$HOME` inside Git Bash is your Windows user profile (same as `%USERPROFILE%`).
- **WSL**: treat as Linux — use Homebrew inside WSL, or follow the manual steps above under the WSL home directory.
- Install **Ollama** in the same environment where you run Git.

---

### Optional: verbose commit editor (all platforms)

```ini
[commit]
    verbose = true
```

The script already passes `-v` to `git commit`; this setting keeps verbose commits consistent for manual commits too.

## Usage

Run from a repository terminal that supports the alias (Git Bash on Windows):

```bash
# Stage your changes
git add -p

# Generate message and open editor
git ai-commit

# Append issue ref to subject: "fix: foo (AB#12345)"
git ai-commit 12345
git ai-commit AB#12345
```

**Workflow**

1. `git ai-commit` runs the agent (spinner on stderr: `Loading commit message...`)
2. Your configured editor opens with the proposed message and staged diff
3. Edit, save, and quit to commit; close without saving to abort

**Excluded from the diff sent to the agent**

- `package-lock.json`
- `yarn.lock`
- `pnpm-lock.yaml`

## Customization

Edit `git-ai-commit` locally or fork this repository:

| Setting / variable | Default      | Purpose                                 |
| ------------------ | ------------ | --------------------------------------- |
| `ai-commit.issue-prefix` (git config) | _(empty)_ | Tracker prefix for `git ai-commit <id>`; set via `git-ai-commit setup` |
| `BODY_LINE_LENGTH` | `100`        | Max width for body lines (`fold`)       |
| `AGENT_PROMPT`     | _(built-in)_ | Instructions passed to the Ollama agent |

The agent is invoked as:

```sh
ollama agent -p --trust --mode ask --model phi4-mini "$prompt"
```

## Troubleshooting

| Symptom                                    | What to do                                                                                                           |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| `git: 'ai-commit' is not a git command`    | Run `git-ai-commit setup`, or confirm `[alias]` in global config                                                     |
| `git-ai-commit: command not found`         | Run `brew install git-ai-commit`, or confirm Homebrew `bin` is on `PATH`                                             |
| `Permission denied` (macOS/Linux/Git Bash) | `chmod +x` on `git-ai-commit` and `setup`                                                                            |
| `sh: ...: not found` (Windows)             | Use **Git Bash** or WSL; avoid `cmd.exe` / PowerShell for `git ai-commit`                                            |
| `ollama: command not found`                | Install Ollama; restart terminal; ensure `ollama` is on `PATH` in the same shell you use for Git                     |
| `no staged changes to summarize`           | Stage files with `git add`; lockfiles alone are ignored                                                              |
| `ollama agent failed`                      | Run `ollama agent --help`; confirm Ollama is healthy and retry in the repo                                           |
| `empty message from ollama agent`          | Retry, reduce diff size, or test `ollama agent` manually                                                             |
| `Model phi4-mini is not available locally` | Run `ollama pull phi4-mini`, or rerun `git-ai-commit setup` and accept the pull prompt                               |
| Editor does not open                       | Run `git-ai-commit setup`, or set `core.editor` (e.g. `vim`, `code --wait`, `notepad`)                               |
| Script errors after clone on Windows       | Run `git config --global core.autocrlf input` in Git Bash, or re-clone with `git clone --config core.autocrlf=input` |

**Debug (macOS / Linux / Git Bash)**

```bash
git config --global alias.ai-commit
git config --global core.editor
git config --global ai-commit.issue-prefix
which git-ai-commit sh ollama
git-ai-commit --help
```

**Debug (Windows PowerShell — paths only)**

```powershell
git config --global alias.ai-commit
git config --global core.editor
git config --global ai-commit.issue-prefix
Test-Path "$env:USERPROFILE\.config\git\git-ai-commit\git-ai-commit"
```

## Security

- The **full staged diff** is sent to your local Ollama agent. Do not stage secrets (`.env`, keys, tokens).
- `--trust` is used so the agent can run in your repo; use only in repositories you trust.
- Always review the generated message in your editor before committing.

## Quick checklist

- [ ] Ollama installed; `ollama agent` works in your terminal
- [ ] `phi4-mini` pulled locally, or `git-ai-commit setup` confirmed it
- [ ] macOS/Linux: `brew install git-ai-commit` and `git-ai-commit setup`
- [ ] Windows: repository cloned; `chmod +x` on both scripts; `git-ai-commit setup` run from Git Bash
- [ ] `ai-commit` alias, `core.editor`, and `ai-commit.issue-prefix` in global `.gitconfig`
- [ ] Test: stage a small change → `git ai-commit`

## Files

| File                       | Description                                  |
| -------------------------- | -------------------------------------------- |
| `git-ai-commit`            | Commit CLI (`git ai-commit` target)          |
| `setup`                    | Git config setup (via `git-ai-commit setup`) |
| `Formula/git-ai-commit.rb` | Homebrew formula                             |
| `TAP.md`                   | Tap and release notes                        |
| `README.md`                | This document                                |
| `LICENSE`                  | MIT license                                  |

## License

[MIT](LICENSE). Review all AI-generated commit messages before pushing.
