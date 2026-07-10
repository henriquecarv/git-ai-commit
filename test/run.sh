#!/usr/bin/env sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
script="$repo_root/git-ai-commit"
tmp_root=${TMPDIR:-/tmp}/git-ai-commit-tests.$$

cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT INT TERM

mkdir -p "$tmp_root/bin"

cat >"$tmp_root/bin/ollama" <<'SH'
#!/usr/bin/env sh
set -eu

if [ "$1" = run ] && [ "${2:-}" = --help ]; then
  printf 'Run a model\n'
  printf '      --nowordwrap              Do not wrap words\n'
  exit 0
fi

printf '%s\n' "$*" >>"$OLLAMA_ARGS"
cat >"$PROMPT_CAPTURE"
cat "$MODEL_OUTPUT"
SH
chmod +x "$tmp_root/bin/ollama"

cat >"$tmp_root/bin/git" <<'SH'
#!/usr/bin/env sh
set -eu

case $1 in
  diff)
    cat "$STAGED_DIFF"
    ;;
  config)
    if [ "${4:-}" = ai-commit.issue-prefix ]; then
      exit 1
    fi
    exit 1
    ;;
  commit)
    : >"$COMMIT_ARGS"
    shift
    for arg do
      printf 'ARG:%s\n' "$arg" >>"$COMMIT_ARGS"
    done
    ;;
  *)
    printf 'unexpected git command: %s\n' "$*" >&2
    exit 1
    ;;
esac
SH
chmod +x "$tmp_root/bin/git"

PATH="$tmp_root/bin:$PATH"
export PATH

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  file=$1
  text=$2
  label=$3
  grep -Fq "$text" "$file" || fail "$label"
}

assert_not_contains() {
  file=$1
  text=$2
  label=$3
  if grep -Fq "$text" "$file"; then
    fail "$label"
  fi
}

run_case() {
  name=$1
  shift
  case_dir="$tmp_root/$name"
  mkdir -p "$case_dir"

  STAGED_DIFF="$case_dir/diff"
  MODEL_OUTPUT="$case_dir/model-output"
  COMMIT_ARGS="$case_dir/commit-args"
  PROMPT_CAPTURE="$case_dir/prompt"
  OLLAMA_ARGS="$case_dir/ollama-args"

  export STAGED_DIFF MODEL_OUTPUT COMMIT_ARGS PROMPT_CAPTURE OLLAMA_ARGS

  printf 'diff --git a/file b/file\n+changed content\n' >"$STAGED_DIFF"
  : >"$MODEL_OUTPUT"
  : >"$COMMIT_ARGS"
  : >"$PROMPT_CAPTURE"
  : >"$OLLAMA_ARGS"

  "$@"
}

run_case preserve_body sh -c '
  cat >"$MODEL_OUTPUT" <<EOF
fix: improve commit summaries

Explain the behavioral change in terms of the user flow.

Keep the second paragraph so rich output survives post-processing.
EOF
  "$0"
' "$script"
assert_contains "$tmp_root/preserve_body/commit-args" "ARG:fix: improve commit summaries" "subject is preserved"
assert_contains "$tmp_root/preserve_body/commit-args" "Explain the behavioral change" "first body paragraph is preserved"
assert_contains "$tmp_root/preserve_body/commit-args" "Keep the second paragraph" "second body paragraph is preserved"

run_case removes_invented_refs sh -c '
  cat >"$MODEL_OUTPUT" <<EOF
fix: avoid invented references

Keep the useful explanation.

Refs: AB#999
EOF
  "$0"
' "$script"
assert_contains "$tmp_root/removes_invented_refs/commit-args" "Keep the useful explanation." "body remains when invented footer is removed"
assert_not_contains "$tmp_root/removes_invented_refs/commit-args" "Refs: AB#999" "invented ref is removed"

run_case allows_explicit_refs sh -c '
  cat >"$MODEL_OUTPUT" <<EOF
fix: preserve explicit references

Keep the useful explanation.

Refs: AB#123
EOF
  "$0" 123
' "$script"
assert_contains "$tmp_root/allows_explicit_refs/commit-args" "Refs: AB#123" "explicit ref is preserved"

run_case keeps_colon_body sh -c '
  cat >"$MODEL_OUTPUT" <<EOF
fix: preserve colon prose

Impact: users now get a clear generated message.
Reason: the model receives a complete stdin prompt.
EOF
  "$0"
' "$script"
assert_contains "$tmp_root/keeps_colon_body/commit-args" "Impact: users now get a clear generated message." "colon body line is preserved"
assert_contains "$tmp_root/keeps_colon_body/commit-args" "Reason: the model receives a complete stdin prompt." "second colon body line is preserved"

run_case empty_output_fails sh -c '
  : >"$MODEL_OUTPUT"
  if "$0" >/dev/null 2>&1; then
    exit 1
  fi
' "$script" || fail "empty output should fail"
if [ -s "$tmp_root/empty_output_fails/commit-args" ]; then
  fail "empty output should not commit"
fi

run_case large_diff_stdin sh -c '
  i=1
  : >"$STAGED_DIFF"
  while [ "$i" -le 300 ]; do
    printf "+line %s\n" "$i" >>"$STAGED_DIFF"
    i=$((i + 1))
  done
  printf "+large-diff-marker\n" >>"$STAGED_DIFF"
  cat >"$MODEL_OUTPUT" <<EOF
fix: read prompts from stdin

Keep the complete staged diff available to the local model.
EOF
  "$0"
' "$script"
assert_contains "$tmp_root/large_diff_stdin/prompt" "large-diff-marker" "large staged diff reaches ollama stdin"
assert_contains "$tmp_root/large_diff_stdin/ollama-args" "run --nowordwrap phi4-mini" "nowordwrap flag is used when supported"

printf 'ok - git-ai-commit smoke tests passed\n'
