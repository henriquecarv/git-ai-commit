# frozen_string_literal: true

class GitAiCommit < Formula
  desc "Generate Conventional Commit messages via Cursor Agent"
  homepage "https://github.com/henriquecarv/git-ai-commit"
  url "https://github.com/henriquecarv/git-ai-commit.git", branch: "main"
  version "1.0.0"
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

      This configures core.editor and the git ai-commit alias in ~/.gitconfig.
      Cursor CLI must be installed separately.
    EOS
  end

  test do
    assert_predicate libexec/"setup", :executable?
    assert_match "git-ai-commit setup", shell_output("#{bin}/git-ai-commit --help")
  end
end
