#!/usr/bin/env bash
# ------------------------------------------------------------------
# Gatsby blog deploy script
#   1. Clones the *source-code* repo (already contains /public)
#   2. Pushes the /public folder to the *blog-public* repo
#
# Prerequisites
#   • GITHUB_TOKEN is supplied in the environment (injected by Python)
#   • git is installed on the Raspberry Pi
# ------------------------------------------------------------------

set -euo pipefail            # Fail fast on errors
IFS=$'\n\t'

# ─── CONFIG ────────────────────────────────────────────────────────
SRC_REPO="https://github.com/khizarirshadchaudhry/my-blog.git"
DEST_REPO="https://khizarirshadchaudhry:${GITHUB_TOKEN}@github.com/khizarirshadchaudhry/blog-public.git"
BRANCH="main"
WORK_DIR="/home/ubuntu/cd-work"   # Temp workspace; will be recreated each run
GIT_USER_NAME="Khizar Irshad Chaudhry"
GIT_USER_EMAIL="k.irshadch@gmail.com"

# ─── SAFETY CHECKS ────────────────────────────────────────────────
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "❌  GITHUB_TOKEN not set in environment"
  exit 1
fi

# ─── PREPARE WORKSPACE ────────────────────────────────────────────
echo "🔄  Cleaning workspace…"
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

# ─── CLONE SOURCE REPO ────────────────────────────────────────────
echo "📥  Cloning source repo (${SRC_REPO})…"
git clone --depth 1 "${SRC_REPO}" src
cd src/public                 # enter the built site folder

# ─── INITIALISE NEW REPO IN /public ───────────────────────────────
echo "🏷️   Initialising git repo in /public…"
git init
git config user.name  "${GIT_USER_NAME}"
git config user.email "${GIT_USER_EMAIL}"
git checkout -b "${BRANCH}"

# ─── COMMIT & PUSH TO blog-public ─────────────────────────────────
echo "🚀  Pushing to blog-public…"
git add .
git commit -m "Deploy $(date '+%Y-%m-%d %H:%M:%S')"
git remote add origin "${DEST_REPO}"
git push --force origin "${BRANCH}"

echo "✅  Deployment finished successfully."
