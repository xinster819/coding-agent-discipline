#!/usr/bin/env bash
# ------------------------------------------------------------------
# 把这套能力装进「某一个指定的 Claude Code 项目」（项目级，可随仓库共享）。
# 用法：  bash install-into-project.sh /path/to/your/project
# 结果：
#   <项目>/.claude/skills/<skill>/SKILL.md   ← 5 个 skill（自动发现，无需配置）
#   <项目>/.claude/constitution.md           ← 宪法（安全底线+六大纪律）
#   <项目>/CLAUDE.md 里加一行 @.claude/constitution.md（已存在则非破坏式追加）
# 之后建议把 .claude/ 一起 commit 进 git，团队共享。
# ------------------------------------------------------------------
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="${1:-}"
[ -z "$PROJ" ] && { echo "用法: bash install-into-project.sh /path/to/your/project"; exit 1; }
[ -d "$PROJ" ] || { echo "错误：目录不存在 $PROJ"; exit 1; }

echo "==> 安装 skills 到 $PROJ/.claude/skills"
mkdir -p "$PROJ/.claude/skills"
cp -R "$SRC_DIR"/skills/* "$PROJ/.claude/skills/"
for d in "$PROJ"/.claude/skills/*/; do echo "    + $(basename "$d")"; done

echo "==> 安装 handoff slash commands 到 $PROJ/.claude/commands"
mkdir -p "$PROJ/.claude/commands"
cp "$SRC_DIR"/commands/*.md "$PROJ/.claude/commands/"
for f in "$PROJ"/.claude/commands/*.md; do echo "    + /$(basename "$f" .md)"; done

echo "==> 安装宪法到 $PROJ/.claude/constitution.md"
cp "$SRC_DIR/AGENTS.md" "$PROJ/.claude/constitution.md"

CLAUDE_MD="$PROJ/CLAUDE.md"
IMPORT_LINE="@.claude/constitution.md"
if [ -f "$CLAUDE_MD" ]; then
  if grep -qF "$IMPORT_LINE" "$CLAUDE_MD"; then
    echo "==> CLAUDE.md 已包含 import，跳过"
  else
    printf '\n%s\n' "$IMPORT_LINE" >> "$CLAUDE_MD"
    echo "==> 已在已有 CLAUDE.md 末尾追加：$IMPORT_LINE"
  fi
else
  printf '%s\n' "$IMPORT_LINE" > "$CLAUDE_MD"
  echo "==> 已创建 CLAUDE.md 并写入：$IMPORT_LINE"
fi

cat <<EOF

==> 完成。验证：
  cd "$PROJ" && claude
  然后输入：/        # 应能看到 /verify-before-claiming、/challenge-me、/handoff-init 等
  或问：    我有哪些 skill 可用？
  或诊断：  /doctor  # 看 skill 描述是否因上下文预算被截断

handoff 三件套：首次 /handoff-init 生成 HANDOFF.md+tasks.md；每次开工 /handoff-resume；收工 /handoff-save。
建议把 .claude/ 与 CLAUDE.md 一起 commit，团队共享。
EOF
