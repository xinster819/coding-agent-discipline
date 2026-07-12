#!/usr/bin/env bash
# init.sh —— 实例化一个业务 ontology 工作区（通用框架 → 具体业务实例）。
# 用法：  bash init.sh <目标目录> <业务域名>
# 例：    bash init.sh ~/BI_Projects/ad-audit-ontology ad-audit
# 结果：  目标目录生成完整骨架（引擎+模板），并跑一次 index+doctor 展示红态验收基线。
set -euo pipefail

ASSETS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../assets" && pwd)"
DEST="${1:-}"; DOMAIN="${2:-}"
[ -z "$DEST" ] || [ -z "$DOMAIN" ] && { echo "用法: bash init.sh <目标目录> <业务域名>"; exit 1; }
[ -e "$DEST" ] && { echo "错误：$DEST 已存在（不覆盖已有目录，换路径或先自行处理）"; exit 1; }

echo "==> 1. 生成骨架 $DEST"
mkdir -p "$DEST"
cp -R "$ASSETS/." "$DEST/"
mkdir -p "$DEST/repos" "$DEST/docs" "$DEST/.kb" "$DEST/CHANGELOG"
chmod +x "$DEST/tools/"*.sh

echo "==> 2. 注入业务域名（占位符 → $DOMAIN）"
LC_ALL=C find "$DEST" -type f \( -name '*.md' -o -name '*.json' \) -exec sed -i '' \
  -e "s|__DOMAIN__|$DOMAIN|g" -e "s|__WORKSPACE__|$DEST|g" {} +

echo "==> 3. 首次 index + doctor（预期红：repos 未登记——这就是先红后绿的验收基线）"
cd "$DEST"
python3 tools/kb.py index
python3 tools/kb.py doctor || true

cat <<EOF

==> 完成。工作区：$DEST
下一步（P1，见 SPEC.md §6）：
  1) 在 source_registry.json 的 repos[] 登记代码仓库（name + git 地址）
  2) 核心文档放 docs/；资源台账填 resources/*.json
  3) 用最高频的 3 个业务问题填 kb/ontology/answer_contracts.json
  4) ./tools/refresh.sh —— doctor 转绿 + search 命中业务词 = 验收通过
  5) 确认后安装 cron（README 有现成行）
EOF
