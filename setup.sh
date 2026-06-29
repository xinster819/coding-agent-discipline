#!/usr/bin/env bash
# ------------------------------------------------------------------
# 全局安装脚本：把这套编码协作能力（AGENTS.md + skills）安装到
# Claude Code / Codex / Snowflake CoCo，对所有项目全局生效。
# Trae 原生支持 Skills（自动加载 ~/.agents/skills，与 Codex 同目录，本脚本已覆盖）；规则走 user_rules。
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
rm -rf "$DEST/commands" && cp -R "$SRC_DIR/commands" "$DEST/commands"
rm -rf "$DEST/docs" && cp -R "$SRC_DIR/docs" "$DEST/docs"
rm -rf "$DEST/hooks" && cp -R "$SRC_DIR/hooks" "$DEST/hooks"
echo "  已复制 AGENTS.md、skills/、commands/、docs/、hooks/ 到 $DEST"

echo "==> 2. Claude Code（~/.claude）"
mkdir -p "$HOME/.claude/skills" "$HOME/.claude/commands"
backup "$HOME/.claude/CLAUDE.md"
link "$DEST/AGENTS.md" "$HOME/.claude/CLAUDE.md"          # Claude Code 读 CLAUDE.md
for d in "$DEST"/skills/*/; do link "$d" "$HOME/.claude/skills/$(basename "$d")"; done
for f in "$DEST"/commands/*.md; do link "$f" "$HOME/.claude/commands/$(basename "$f")"; done

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

==> 完成。已全局安装到 Claude Code（宪法 + skills + slash commands）/ Codex（宪法 + skills）；CoCo 复用 ~/.claude/skills。

【Slash command（已链接到 ~/.claude/commands，新开 claude 输入 / 即可见）】
  handoff 三件套：/handoff-init（项目首次接入）→ /handoff-resume（每次开工）→ /handoff-save（每次收工）
  KB 别名：/kb-init（建/重建知识库）、/kb-refresh（刷新知识库）
  另：装好的 skill 本身也能直接 / 调用，如 /project-kb-production、/challenge-me。

【CoCo 的规则文件（AGENTS.md）是「工作区根目录」级别，没有全局 home 路径】
  想让宪法在某个项目对 CoCo 生效，在该项目根执行：
    ln -sfn "$DEST/AGENTS.md" ./AGENTS.md

【Trae（原生支持 Skills，自动加载 ~/.agents/skills）】
  1) Skills：本脚本已把 skills 链接进 ~/.agents/skills——Trae 设置 → Skills & Commands，
     打开「Enable .agents Skills Directory」开关，点 ↻ 刷新，即可见 7 个 skill（按需开关）。
  2) 规则（宪法）：Trae 设置 → Rules & Memories，把 $DEST/docs/trae-user-rules.md 分隔线之间
     的整段粘进 user_rules（或直接用 $DEST/AGENTS.md）。
  3) handoff：用 $DEST/docs/handoff-prompts.md 的可粘贴 Prompt A/B/C。

【Codex 的 handoff（无 Claude Code slash 机制）】
  用可粘贴兜底版：$DEST/docs/handoff-prompts.md（含 Prompt A/B/C + 项目 CLAUDE.md 模板）。

【可选·机制兜底 hook（强约束，拦无证据断言）】
  本脚本已把脚本放到 $DEST/hooks/verify-guard.py。要启用，在 ~/.claude/settings.json 的
  hooks.Stop 里加：python3 $DEST/hooks/verify-guard.py（完整片段见 $DEST/hooks/README.md）。
  这是唯一不靠模型自觉的一层；Trae/Codex 的 hook 配置见 README（未核实前不臆造）。

验证：在任一工具里挑个真实任务跑一遍，看宪法是否生效、skill 是否在该触发时触发；
      Claude Code 里输入 / 看 handoff 命令是否出现；Trae 在 Skills 面板看 7 个 skill 是否列出。
EOF
