#!/usr/bin/env bash
# upgrade.sh —— 把框架新版本同步进一个已有实例。
# 用法：  bash upgrade.sh <实例目录>
# 动作：  ① 覆盖 <实例>/tools/（引擎，实例内本就禁改）
#         ② 增量补新模板（目标不存在才拷，绝不覆盖业务数据）
#         ③ 跑 doctor + 在实例 CHANGELOG 记一笔
# 不碰：  source_registry.json / docs / resources / answer_contracts / glossary(已存在时) /
#         question_log(已存在时) / AGENTS.md / SPEC.md / README.md / CHANGELOG / repos / .kb
set -euo pipefail

ASSETS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../assets" && pwd)"
DEST="${1:-}"
[ -z "$DEST" ] && { echo "用法: bash upgrade.sh <实例目录>"; exit 1; }
[ -f "$DEST/source_registry.json" ] || { echo "错误：$DEST 不是本框架实例（缺 source_registry.json）"; exit 1; }

echo "==> 1. 覆盖引擎 tools/"
cp "$ASSETS/tools/"* "$DEST/tools/"
chmod +x "$DEST/tools/"*.sh

echo "==> 2. 增量补新模板（已存在则跳过）"
ADDED=""
for rel in kb/ontology/glossary.json kb/question_log.md; do
  if [ ! -f "$DEST/$rel" ]; then
    mkdir -p "$DEST/$(dirname "$rel")"
    cp "$ASSETS/$rel" "$DEST/$rel"
    ADDED="$ADDED $rel"
    echo "  + $rel"
  else
    echo "  · $rel 已存在，跳过"
  fi
done
# 场景卡 qa.md 含新回路规则，但可能被实例定制过：不覆盖，仅提示 diff
if ! diff -q "$ASSETS/kb/scenarios/qa.md" "$DEST/kb/scenarios/qa.md" >/dev/null 2>&1; then
  echo "  ⚠️ kb/scenarios/qa.md 与框架新版不同（可能实例定制过）：请人工对比合并"
  echo "     diff \"$ASSETS/kb/scenarios/qa.md\" \"$DEST/kb/scenarios/qa.md\""
fi

echo "==> 3. 体检 + 记录"
cd "$DEST"
python3 tools/kb.py doctor || true
LOG="CHANGELOG/$(date '+%Y-%m').md"
mkdir -p CHANGELOG
{
  echo ""
  echo "## $(date '+%Y-%m-%d %H:%M %z') 框架升级"
  echo "- 引擎 tools/ 已更新（glossary 扩展搜索 + doctor 新检查项）"
  echo "- 新增模板:${ADDED:- 无（均已存在）}"
  echo "- 待人工: 若 doctor 有 ❌（如新检查项 glossary/question_log），按提示补齐"
} >> "$LOG"
echo "==> 完成，升级记录已写入 $DEST/$LOG"
