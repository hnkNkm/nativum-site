#!/usr/bin/env sh
# ローカル確認用サーバー (flake ビルド成果物を配信)
# 使い方: ./serve.sh [port]   → http://localhost:8000
set -eu
exec nix run .#serve -- "${1:-8000}"
