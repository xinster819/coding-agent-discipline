#!/usr/bin/env bash
# ------------------------------------------------------------------
# 全局安装脚本：把这套编码协作能力（AGENTS.md + skills）安装到
# Claude Code / Codex / Snowflake CoCo，对所有项目全局生效。
# Trae 不支持 SKILL.md / AGENTS.md，脚本末尾给手动步骤。
#
# 原理：把本包复制到稳定的「单一真源」目录 ~/.ai-coding-pack，
# 再从各工具的全局目录用「符号链接」指过去。改一处，处处更新。
#
# 用法：在本包根目录执行  bash setup.sh
# 安全：会先备份已存在的同名文件为 *.bak.<时间戳>
# ------------------------------------------------------------------
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.ai-coding-pack"
TS="$(date +%Y%m%d%H%M%S)"

backup() { [ -e "$1" ] && [ ! -L "$1" ] && mv "$1" "$1.bak.$TS" && echo "  备份旧文件 → $1.bak.$TS" || true; }
link()   { ln -sfn "$1" "$2" && echo "  链接 $2 → $1"; }

echo "==> 1. 建立单一真源 $DEST"
mkdir -p "$DEST"
cp "$SRC_DIR/AGENTS.md" "$DEST/AGENTS.md"
rm -rf "$DEST/skills" && cp -R "$SRC_DIR/skills" "$DEST/skills"
echo "  已复制 AGENTS.md 和 skills/ 到 $DEST"

echo "==> 2. Claude Code（~/.claude）"
mkdir -p "$HOME/.claude/skills"
backup "$HOME/.claude/CLAUDE.md"
link "$DEST/AGENTS.md" "$HOME/.claude/CLAUDE.md"          # Claude Code 读 CLAUDE.md
for d in "$DEST"/skills/*/; do link "$d" "$HOME/.claude/skills/$(basename "$d")"; done

echo "==> 3. Codex（~/.codex + ~/.agents/skills）"
mkdir -p "$HOME/.codex" "$HOME/.agents/skills"
backup "$HOME/.codex/AGENTS.md"
link "$DEST/AGENTS.md" "$HOME/.codex/AGENTS.md"
for d in "$DEST"/skills/*/; do link "$d" "$HOME/.agents/skills/$(basename "$d")"; done

echo "==> 4. Snowflake CoCo"
# CoCo 原生扫描 ~/.claude/skills（第 2 步已覆盖）。如需也放进 CoCo 自家目录：
if [ -d "$HOME/.snowflake/cortex" ] || [ "${FORCE_COCO:-0}" = "1" ]; then
  mkdir -p "$HOME/.snowflake/cortex/skills"
  for d in "$DEST"/skills/*/; do link "$d" "$HOME/.snowflake/cortex/skills/$(basename "$d")"; done
  echo "  已链接到 ~/.snowflake/cortex/skills"
else
  echo "  跳过（未检测到 ~/.snowflake/cortex）。CoCo 会直接读 ~/.claude/skills，通常无需额外操作。"
fi

cat <<EOF

==> 完成。已全局安装到 Claude Code / Codex（+ CoCo 复用 ~/.claude/skills）。

【CoCo 的规则文件（AGENTS.md）是「工作区根目录」级别，没有全局 home 路径】
  想让宪法在某个项目对 CoCo 生效，在该项目根执行：
    ln -sfn "$DEST/AGENTS.md" ./AGENTS.md

【Trae 需手动（不支持 SKILL.md / AGENTS.md）】
  1) 打开 Trae 设置 → Rules → user_rules（全局）
  2) 把 $DEST/AGENTS.md 的内容整段粘进去
  3) skills 无法直接复用：把你最看重的 skill（如 verify-before-claiming、challenge-me）
     的步骤摘进 user_rules 或项目 .trae/rules/project_rules.md

验证：在任一工具里挑个真实任务跑一遍，看宪法是否生效、skill 是否在该触发时触发。
EOF
