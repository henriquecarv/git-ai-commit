# frozen_string_literal: true

class GitAiCommit < Formula
  desc "Generate Conventional Commit messages via Ollama (phi4-mini)"
  homepage "https://github.com/henriquecarv/git-ai-commit"
  url "https://github.com/henriquecarv/git-ai-commit.git", branch: "main"
  version "2.1.0"
  license "MIT"

  depends_on "git"

  def install
    libexec.install "git-ai-commit", "setup"
    bin.install_symlink libexec/"git-ai-commit"
  end

  def caveats
    <<~EOS
      Run:
        git-ai-commit setup

      This configures core.editor, ai-commit.issue-prefix, and the git ai-commit alias in ~/.gitconfig.
      Ollama must be installed separately, and phi4-mini must be available locally.
      git-ai-commit setup verifies Ollama and can pull phi4-mini interactively.
    EOS
  end

  test do
    assert_predicate libexec/"setup", :executable?
    assert_match "git-ai-commit setup", shell_output("#{bin}/git-ai-commit --help")

    ENV["HOME"] = testpath
    (testpath/"ollama").write <<~SH
      #!/bin/sh
      case "$1" in
        list) printf 'phi4-mini:latest\t2.5 GB\n' ;;
        pull) exit 0 ;;
        *) exit 0 ;;
      esac
    SH
    (testpath/"ollama").chmod 0755
    ENV["PATH"] = "#{testpath}:#{ENV["PATH"]}"

    pipe_output("#{bin}/git-ai-commit setup", "\n\n")
    assert_match "alias.ai-commit", shell_output("git config --global --get-regexp alias")
    assert_equal "", shell_output("git config --global ai-commit.issue-prefix").strip
  end
end
