#!/usr/bin/env bash
set -euo pipefail

SUBCMD="${1:-}"
shift || true

usage() {
  echo "git wt init <repo-url>"
  echo "git wt add <folder> [branch] [base]"
  echo "git wt remove <folder>"
  echo "git wt run <git-args...>"
}

BARE_NAME="${GIT_WT_BARE_DIR:-.bare}"
DEFAULT_BRANCH_FILE=".git-wt-default-branch"

# Utility: get default branch (from file or detect)
get_default_branch() {
  if [ -f "$DEFAULT_BRANCH_FILE" ]; then
    cat "$DEFAULT_BRANCH_FILE"
  else
    # Try to detect from origin/HEAD
    git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
  fi
}

# ---------- INIT ----------
cmd_init() {
  REPO_URL="${1:-}"
  [ -n "$REPO_URL" ] || { usage; exit 1; }

  REPO_NAME=$(basename "$REPO_URL" .git)

  mkdir -p "$REPO_NAME"
  cd "$REPO_NAME"

  if [ ! -d "$BARE_NAME" ]; then
    git clone --bare "$REPO_URL" "$BARE_NAME"
  fi

  echo "gitdir: ./$BARE_NAME" > .git

  echo "AGENTS.md" >> $BARE_NAME/info/exclude
  echo ".github/copilot-instructions.md" >> $BARE_NAME/info/exclude

  git config --replace-all remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  git fetch origin --prune

  # Detect and save default branch
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
  echo "$DEFAULT_BRANCH" > "$DEFAULT_BRANCH_FILE"

  [ -d "$DEFAULT_BRANCH" ] || git worktree add "$DEFAULT_BRANCH" "$DEFAULT_BRANCH"

  if git show-ref --verify --quiet refs/remotes/origin/stage; then
    [ -d stage ] || git worktree add stage stage
  else
    echo "⚠ stage branch does not exist"
  fi

  [ -d review ] || git worktree add review --detach

  echo
  echo "Done!"
  echo
  echo "Structure:"
  echo "  $REPO_NAME/"
  echo "    ├── $BARE_NAME/"
  echo "    ├── $DEFAULT_BRANCH/"
  echo "    └── stage/"
  echo "    └── review/"
  echo
}

# ---------- ADD ----------
cmd_add() {
    git fetch origin --prune

    BRANCH="${1:-}"
    FOLDER="${2:-}"
    BASE="${3:-}"

    DEFAULT_BRANCH=$(get_default_branch)
    [ -n "$BASE" ] || BASE="$DEFAULT_BRANCH"

    [ -n "$BRANCH" ] || { echo "❌ branch required"; exit 1; }
    [ -n "$FOLDER" ] || FOLDER="$BRANCH"
    [ -d "$FOLDER" ] && { echo "❌ folder already exists"; exit 1; }

    if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
        echo "▶ Using existing local branch: $BRANCH"
        git worktree add "$FOLDER" "$BRANCH"
        if ! git -C "$FOLDER" rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
            if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
                git -C "$FOLDER" branch --set-upstream-to="origin/$BRANCH"
            fi
        fi
    elif git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
        echo "▶ Using existing remote branch: origin/$BRANCH"
        git worktree add -b "$BRANCH" "$FOLDER" "origin/$BRANCH"
    else
        echo "▶ Creating new branch: $BRANCH from $BASE"
        if ! git show-ref --verify --quiet "refs/heads/$BASE" &&
            ! git show-ref --verify --quiet "refs/remotes/origin/$BASE"; then
          echo "❌ base branch does not exist: $BASE"
          exit 1
        fi
        git worktree add -b "$BRANCH" "$FOLDER" "$BASE"
        if git show-ref --verify --quiet "refs/remotes/origin/$BASE"; then
            git -C "$FOLDER" branch --set-upstream-to="origin/$BASE"
        fi
    fi

    MAIN_BRANCH="$DEFAULT_BRANCH"
    MAIN_BRANCH_ABS="$(cd "$MAIN_BRANCH" && pwd)"
    FOLDER_ABS="$(cd "$FOLDER" && pwd)"

    if [ -f "${MAIN_BRANCH_ABS}/AGENTS.md" ]; then
        ln -sf "${MAIN_BRANCH_ABS}/AGENTS.md" "${FOLDER_ABS}/AGENTS.md" 2>/dev/null || cp "${MAIN_BRANCH_ABS}/AGENTS.md" "${FOLDER_ABS}/AGENTS.md"
    fi

    if [ -f "${MAIN_BRANCH_ABS}/.github/copilot-instructions.md" ]; then
        mkdir -p "${FOLDER_ABS}/.github"
        ln -sf "${MAIN_BRANCH_ABS}/.github/copilot-instructions.md" "${FOLDER_ABS}/.github/copilot-instructions.md" 2>/dev/null || cp "${MAIN_BRANCH_ABS}/.github/copilot-instructions.md" "${FOLDER_ABS}/.github/copilot-instructions.md"
    fi
}

# ---------- REMOVE ----------
cmd_remove() {
  FOLDER="${1:-}"
  [ -n "$FOLDER" ] || { usage; exit 1; }
  [ -d "$FOLDER" ] || { echo "❌ folder not found"; exit 1; }

  git worktree remove "$FOLDER"
}

# ---------- RUN ----------
cmd_run() {
    [ $# -gt 0 ] || { echo "❌ git command required"; exit 1; }
    git "$@"
}

case "$SUBCMD" in
  init)   cmd_init "$@" ;;
  add)    cmd_add "$@" ;;
  remove) cmd_remove "$@" ;;
  run)    cmd_run "$@" ;;
  *)      usage; exit 1 ;;
esac
