# HANDOFF — coding-agent-discipline

> 首建于本 session（此前无 handoff 文件）。内容来自 git log + 会话记录，只指路径不贴代码。

## 一句话目标
一个"编码协作能力包"：不改模型，靠 **RULE（宪法）+ SKILL + COMMAND + HOOK** 四层，让 AI 编码 agent（Claude Code / Codex / CoCo / Trae）与用户的高标准工作习惯契合。仓库要长期作为"AI Coding 常用能力仓库"。

## 结构现状
- 宪法：`AGENTS.md`（安全底线 + 六大纪律 + 流程索引）；`CLAUDE.md` 用 `@AGENTS.md` 引用。
- 7 skill：5 纪律（verify-before-claiming / self-help-first / challenge-me / blindspot-scan / retro）+ 2 导航（project-kb-production / project-kb-refresh）。
- 5 command：handoff-init/resume/save + kb-init/kb-refresh（`commands/`）。
- hook：`hooks/verify-guard.py`（Stop hook，拦无证据断言）+ `hooks/README.md`；项目级挂在 `.claude/settings.json`。
- docs：`docs/handoff-prompts.md`（无 slash 工具的兜底）、`docs/trae-user-rules.md`（Trae 规则层 bundle）。
- 安装：`setup.sh`（全局，单一真源 `~/.ai-coding-pack`）、`install-into-project.sh`（项目级）。

## 已完成（近 5 个 commit，已验证）
- `aef488e` 数据解读纪律：证伪优先 + 结果分布 + 反惊悚（AGENTS ① / verify-before-claiming step6 / blindspot 维度2 / trae bundle 同步）
- `d71375b` verify-guard hook（实测 5 用例）+ 外部声明纪律 + 修正 Trae 过时文档（Trae 实为原生支持 Skills，自动加载 ~/.agents/skills）
- `2073ac2` /kb-init /kb-refresh 短别名
- `1edb9ad` 纳入 KB 两件套
- `4a61566` 融入 handoff 三件套 + behavior-audit 并入 challenge-me

## 进行中 / 下一步第一动作
- **无正在写的代码**。当前状态：所有改动已提交推送，`main` 与 `origin/main` 同步。
- **下一步第一动作（若续命）**：落地下方"待做 #1"——self-help-first 的"假边界/举证不可得"迭代（这是唯一被提出但未实现的规则缺口）。

## 待做（按优先级）
1. **[规则缺口] self-help-first 补"假边界 + 举证不可得"**：覆盖"过度保守/偷懒"这一侧（如"QPS 取不到"其实是没用对工具）。上一轮提出过 2 条方案（假红灯加"自判假边界"；verify-before-claiming/AGENTS 加"宣布不可得也要举证"），**用户未拍板、未实现**。这是与"证伪"对称的另一极性，建议优先。
2. **[核实] Trae 是否能自动导入 `commands/`**：Trae 有 Commands 面板，但能否吃本包 command 文件未验证（当前标"待核实"）。
3. **[核实] Codex 自定义 prompt/command 目录路径**：commands 目前只对 Claude Code 确证；Codex 走 `docs/handoff-prompts.md` 兜底。
4. **[核实] Trae/Codex 的 hook 事件名与配置格式**：verify-guard 只在 Claude Code 确证；`hooks/README.md` 已标"未核实不臆造"。

## 已知坑 & workaround
- **单一真源是"拷贝"不是软链**：`setup.sh` 把仓库 `cp` 到 `~/.ai-coding-pack`，各工具再软链到它。**改了仓库 ≠ 全局已更新**——必须重跑 `bash setup.sh` 才生效（Trae 还要在 Skills 面板点 ↻）。
- **hook 启动时加载**：`.claude/settings.json` 里的 Stop hook 中途加不生效，要**新开 session**；用 `/hooks` 查是否加载。
- **docs/trae-user-rules.md 与 AGENTS.md 会漂移**：它是手写的 Trae 规则层 bundle，非自动派生；改 AGENTS.md 记得同步它（本次已同步"证伪"条）。
- **verify-guard 是 tripwire 非保证**：只认已约定禁用词 + 外部能力断言正则；**测不出"缺席型"错误**（没查反面字段、偷懒没试够）；fail-open。

## 关键决策记录（为什么这么选）
- **behavior-audit 并入 challenge-me 而非独立 skill**：守"宪法瘦、不堆料"，两者都是反谄媚决策审查。
- **不纳入 stability-dashboard-builder**：重型 SRE 专用、已全局安装，会让仓库变杂货铺。
- **数据解读错误的杠杆放在"证伪"而非 hook**：这类是缺席型错误，hook 难可靠检测；rule 层 + 高风险时 fresh-context 反驳是现实最优。
- **不承诺"彻底避免"**：规则是强引导非硬约束；反复向用户强调这点（诚实 > 让用户安心）。

## 如何验证 / 运行
- 脚本语法：`bash -n setup.sh install-into-project.sh`
- hook：`python3 hooks/verify-guard.py`（喂造的 transcript JSON，见 hooks/README「已实测」）
- 全局安装：`bash setup.sh`；项目级：`bash install-into-project.sh <proj>`
- 无自动化测试套件（这是文档/prompt 仓库，不是应用代码）。

## 记忆（在仓库外，不随 git）
`~/.claude/projects/-Users-bytedance-Personal-Projects-coding-agent-discipline/memory/`：verify-external-claims、falsify-data-conclusions、trae-supports-skills-natively。
