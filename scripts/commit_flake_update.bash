#!/usr/bin/env bash

set -euo pipefail

if ! git config --get user.name >/dev/null 2>&1 || \
  [ "$(git config --get user.name)" = "" ] ||
  ! git config --get user.email >/dev/null 2>&1 || \
  [ "$(git config --get user.email)" = "" ]; then
  echo "git config user.{name,email} is not set - configuring"
  set -x
  git config --local user.email "actions-bot"
  git config --local user.name "actions-bot@users.noreply.github.com"
fi

nix flake update --commit-lock-file

cat >commit_msg <<EOF
chore(flake.lock): Update all Flake inputs ($(date -I))

$(git log -1 '--pretty=format:%b' | sed '1,2d')
EOF

git reset --soft 'HEAD~'

if [[ -z "${GITHUB_ENV:-}" ]]; then
  echo "Not running in CI - exiting"
  exit 0
fi

>> "$GITHUB_ENV" cat <<EOF
COMMIT_MSG<<EOV
$(cat ./commit_msg)
EOV
EOF
