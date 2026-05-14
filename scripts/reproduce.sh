#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_REPO_URL="https://github.com/harbor-framework/terminal-bench-2.git"
SOURCE_COMMIT="${SOURCE_COMMIT:-2fd12b88aafdd04a52c298e3940bcb189f9766d6}"
TB2_REPO="${TB2_REPO:-"$ROOT/../terminal-bench-2-ref"}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

if [ ! -d "$TB2_REPO/.git" ]; then
  git clone --quiet "$SOURCE_REPO_URL" "$TMPDIR/terminal-bench-2"
  TB2_REPO="$TMPDIR/terminal-bench-2"
fi

if ! git -C "$TB2_REPO" cat-file -e "$SOURCE_COMMIT^{commit}" 2>/dev/null; then
  git -C "$TB2_REPO" fetch --quiet origin "$SOURCE_COMMIT"
fi

official="$TMPDIR/official.txt"
aa="$ROOT/artifacts/aa_terminal_bench_2_tasks.txt"
excluded="$TMPDIR/excluded.txt"
local_tasks="$TMPDIR/local_tasks.txt"

while IFS= read -r dir; do
  if git -C "$TB2_REPO" cat-file -e "$SOURCE_COMMIT:$dir/task.toml" 2>/dev/null; then
    printf '%s\n' "$dir"
  fi
done < <(git -C "$TB2_REPO" ls-tree -d --name-only "$SOURCE_COMMIT") | sort > "$official"

find "$ROOT" -mindepth 1 -maxdepth 1 -type d \
  ! -name .git \
  ! -name artifacts \
  ! -name scripts \
  -exec test -f '{}/task.toml' ';' \
  -print | sed "s#^$ROOT/##" | sort > "$local_tasks"

comm -23 "$official" "$aa" > "$excluded"

echo "Upstream Terminal-Bench 2 tasks at $SOURCE_COMMIT: $(wc -l < "$official" | tr -d ' ')"
echo "Artificial Analysis Terminal-Bench 2 tasks: $(wc -l < "$aa" | tr -d ' ')"
echo "Excluded upstream tasks: $(wc -l < "$excluded" | tr -d ' ')"
cat "$excluded"
echo "Local task directories: $(wc -l < "$local_tasks" | tr -d ' ')"

diff -u "$official" "$ROOT/artifacts/terminal_bench_2_official_tasks.txt"
diff -u "$excluded" "$ROOT/artifacts/excluded_tasks.txt"
diff -u "$aa" "$local_tasks"

mkdir "$TMPDIR/source"
git -C "$TB2_REPO" archive --format=tar "$SOURCE_COMMIT" $(cat "$aa") | tar -xf - -C "$TMPDIR/source"

while IFS= read -r task; do
  if [ "$task" = "sanitize-git-repo" ]; then
    diff_output="$(diff -qr "$TMPDIR/source/$task" "$ROOT/$task" || true)"
    unexpected_diff="$(printf '%s\n' "$diff_output" | grep -v 'sanitize-git-repo/tests/test_outputs.py' || true)"
    if [ -n "$unexpected_diff" ]; then
      printf '%s\n' "$unexpected_diff"
      exit 1
    fi
  else
    diff -qr "$TMPDIR/source/$task" "$ROOT/$task" >/dev/null
  fi
done < "$aa"

echo "Byte comparison for included task directories: OK, except documented redactions"
