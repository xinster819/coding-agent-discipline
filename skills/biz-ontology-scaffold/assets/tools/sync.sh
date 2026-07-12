#!/usr/bin/env bash
# sync.sh —— 按 source_registry.json 的 repos[] clone 缺失 / pull 已有（--ff-only 安全）。
# 输出人话摘要到 stdout（refresh.sh 会收进 CHANGELOG）。
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# 注意：macOS 自带 bash 3.2 无 mapfile，用 while-read（验收实测踩到）
REPO_TSV="$(python3 -c "
import json
for r in json.load(open('source_registry.json')).get('repos', []):
    print(r['name'] + '\t' + r.get('git', ''))
")"

[ -z "$REPO_TSV" ] && { echo "（registry 尚未登记任何 repo，跳过 sync）"; exit 0; }

mkdir -p repos
FAIL=0
while IFS=$'\t' read -r name url; do
  [ -z "$name" ] && continue
  dir="repos/$name"
  if [ ! -d "$dir/.git" ]; then
    if [ -z "$url" ]; then echo "❌ $name: 未 clone 且 registry 无 git 地址"; FAIL=1; continue; fi
    echo "⬇️  clone $name ..."
    git clone --quiet "$url" "$dir" && echo "✅ $name: 首次 clone 完成" || { echo "❌ $name: clone 失败"; FAIL=1; }
  else
    before=$(git -C "$dir" rev-parse --short HEAD)
    if git -C "$dir" pull --ff-only --quiet 2>/dev/null; then
      after=$(git -C "$dir" rev-parse --short HEAD)
      if [ "$before" = "$after" ]; then
        echo "· $name: 无更新 ($after)"
      else
        n=$(git -C "$dir" rev-list --count "$before..$after")
        echo "🔄 $name: $before → $after（$n 个新 commit）$(git -C "$dir" log --oneline -1 --format='最新: %s' HEAD)"
      fi
    else
      echo "⚠️ $name: pull 失败（本地有改动或分叉，需人工看）"; FAIL=1
    fi
  fi
done <<< "$REPO_TSV"
exit $FAIL
