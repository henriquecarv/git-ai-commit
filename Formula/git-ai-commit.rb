# frozen_string_literal: true

class GitAiCommit < Formula
  desc "Generate Conventional Commit messages via Cursor Agent"
  homepage "https://github.com/henriquecarv/git-ai-commit"
  url "https://github.com/henriquecarv/git-ai-commit.git", branch: "main"
  version "3.0.1"
  license "MIT"

  depends_on "git"

  def install
    libexec.install "git-ai-commit", "setup"
    libexec.install ".agents"
    bin.install_symlink libexec/"git-ai-commit"
  end

  def caveats
    <<~EOS
      Run:
        git-ai-commit setup

      This configures core.editor, ai-commit.issue-prefix, and the git ai-commit alias in ~/.gitconfig.
      Cursor CLI Agent must be installed separately and available as `agent` on PATH.
      git-ai-commit setup verifies `agent --version` before configuring Git.
    EOS
  end

  test do
    assert_predicate libexec/"setup", :executable?
    assert_match "git-ai-commit setup", shell_output("#{bin}/git-ai-commit --help")

    ENV["HOME"] = testpath
    (testpath/"agent").write <<~SH
      #!/bin/sh
      case "$1" in
        --version) printf 'agent 1.0.0\\n' ;;
        *) exit 0 ;;
      esac
    SH
    (testpath/"agent").chmod 0755
    ENV["PATH"] = "#{testpath}:#{ENV["PATH"]}"

    pipe_output("#{bin}/git-ai-commit setup", "\n\n")
    assert_match "alias.ai-commit", shell_output("git config --global --get-regexp alias")
    assert_equal "", shell_output("git config --global ai-commit.issue-prefix").strip
  end
end
