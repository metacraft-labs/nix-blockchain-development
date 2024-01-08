#!/usr/bin/env bash

set -euo pipefail

if ! git config --get user.name >/dev/null 2>&1 || \
  [ "$(git config --get user.name)" = "" ] ||
  ! git config --get user.email >/dev/null 2>&1 || \
  [ "$(git config --get user.email)" = "" ]; then
  echo "git config user.{name,email} is not set - configuring"
  set -x
  git config --local user.email "out@space.com"
  git config --local user.name "beep boop"
fi

commit_prefix="build(flake.nix/inputs):"
date="($(date -I))"

if [ $# -eq 0 ]; then
  command="nix flake update --commit-lock-file"
  commit_title="$commit_prefix Update all Nix flake inputs $date"
else
  commit_title="$commit_prefix Update ["
  command="nix flake lock --commit-lock-file"
  for arg in "$@"; do
    command+=" --update-input '$arg'"
    commit_title+=" '$arg'"
  done
  commit_title+=" ] Nix flake inputs $date"
fi

(
  eval "set -x; $command"
)

git commit --amend -F - <<EOF
$commit_title

$(git log -1 '--pretty=format:%b' | sed '1,2d')
EOF

