#!/usr/bin/env bash
# refresh.sh —— 定时任务入口：sync → index → doctor → 写 user-friendly CHANGELOG。
# doctor 失败：CHANGELOG 标 ⚠️ 且退出码非 0（cron 邮件/告警可接）。
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

TS="$(date '+%Y-%m-%d %H:%M %z')"
LOG="CHANGELOG/$(date '+%Y-%m').md"
mkdir -p CHANGELOG

SYNC_OUT="$(./tools/sync.sh 2>&1)"; SYNC_RC=$?
INDEX_OUT="$(python3 tools/kb.py index 2>&1)"; INDEX_RC=$?
DOCTOR_OUT="$(python3 tools/kb.py doctor 2>&1)"; DOCTOR_RC=$?

STATUS="✅ 正常"
[ $SYNC_RC -ne 0 ] || [ $INDEX_RC -ne 0 ] || [ $DOCTOR_RC -ne 0 ] && STATUS="⚠️ 有失败项，需人工看"

{
  echo ""
  echo "## $TS 自动刷新 — $STATUS"
  echo ""
  echo "**仓库同步**"
  echo '```'
  echo "$SYNC_OUT"
  echo '```'
  echo "**索引**：$INDEX_OUT"
  echo ""
  echo "**体检**"
  echo '```'
  echo "$DOCTOR_OUT"
  echo '```'
} >> "$LOG"

echo "refresh 完成（$STATUS），记录已写入 $LOG"
[ "$STATUS" = "✅ 正常" ] || exit 1
