#!/usr/bin/env bash
# 用於 docker ENTRYPOINT 前，檢查路徑是否被允許
set -euo pipefail

IFS=':' read -ra PATHS <<< "${ALLOWED_PATHS:-/workspace}"
TARGET=${1:-}

for p in "${PATHS[@]}"; do
  [[ "$TARGET" == "$p"* ]] && exec "$@"
done

echo "🚫 路徑 $TARGET 不在允許清單內，拒絕執行！"
exit 13
