#!/usr/bin/env bash

set -euo pipefail

# Keep sudo alive while Homebrew installs are running (mirrors .macos behavior)
if command -v sudo >/dev/null 2>&1; then
  sudo -v || true
  while true; do
    sudo -n true 2>/dev/null || true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "brew.sh is intended for macOS."
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi

TAPS=(
  "bjarneo/cliamp"
  "smudge/smudge"
)

# dezoomify-rs is intentionally NOT listed: Homebrew has no Intel macOS bottle
# for it, and building from source pulls in rust + llvm@22 as build deps,
# which compile for many hours. If needed, grab the prebuilt binary from
# https://github.com/lovasoa/dezoomify-rs/releases instead.
# blueutil is intentionally NOT listed: no Intel macOS bottle, and building it
# from source requires a full Xcode.app install (CLT is not enough).
# `script/bt-reset` falls back to restarting bluetoothd when it's absent.
FORMULAE=(
  "bc"
  "bjarneo/cliamp/cliamp"
  "cabal-install"
  "direnv"
  "fd"
  "ffmpeg"
  "fftw"
  "fnm"
  "gh"
  "ghc"
  "imagemagick"
  "mole"
  "neovim"
  "python"
  "smudge/smudge/nightlight"
  "starship"
  "webp"
  "yt-dlp"
)

CASKS=(
  "font-monaspace"
)

echo "Updating Homebrew..."
brew update
brew upgrade

echo "Installing taps..."
for tap in "${TAPS[@]}"; do
  if brew tap | grep -qx "$tap"; then
    echo "  skip tap $tap"
  else
    brew tap "$tap"
  fi
done

echo "Installing formulae..."
FAILED_FORMULAE=()
for formula in "${FORMULAE[@]}"; do
  if brew list --formula "$formula" >/dev/null 2>&1; then
    echo "  skip brew $formula"
  else
    # Don't let one failed formula (e.g. a Tier 3 source build) abort setup.
    brew install "$formula" || FAILED_FORMULAE+=("$formula")
  fi
done
if [[ ${#FAILED_FORMULAE[@]} -gt 0 ]]; then
  echo "WARNING: failed to install: ${FAILED_FORMULAE[*]}" >&2
fi

# Node.js comes from fnm with official prebuilt nodejs.org binaries, not the
# Homebrew node formula: Homebrew no longer bottles node for Intel macOS, so
# `brew install node` (or corepack/vercel-cli, which depend on it) compiles
# Node from source there, taking hours. corepack ships inside Node itself and
# vercel installs through npm.
echo "Installing Node.js LTS via fnm..."
eval "$(fnm env)"
if fnm list | grep -q 'lts-latest'; then
  echo "  skip node (fnm LTS already installed)"
else
  fnm install --lts
  fnm default lts-latest
fi
corepack enable

if command -v vercel >/dev/null 2>&1; then
  echo "  skip vercel (already on PATH)"
else
  npm install --global vercel
fi

echo "Installing casks..."
for cask in "${CASKS[@]}"; do
  if brew list --cask "$cask" >/dev/null 2>&1; then
    echo "  skip cask $cask"
  else
    brew install --cask "$cask"
  fi
done

echo "Cleaning up..."
brew cleanup

echo "Done."
