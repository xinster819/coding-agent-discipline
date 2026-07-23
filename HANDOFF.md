# HANDOFF — coding-agent-discipline

> 刷新于 goal-guard 落地后（cfb99eb）。只指路径不贴代码。

## 一句话目标（已升级）
**Mission：探索最大化 agent 潜力**（用户明确重定位，不只是规则注入）。六层杠杆全景与优先级：`docs/potential-roadmap.md`（canonical）。规则层已冻结（只减不加、只攒正例）。

## 结构现状
- 宪法 `AGENTS.md`（安全底线+七章，含「七、探索精神」正面授权）；trae bundle=`docs/trae-user-rules.md`（手工派生，改宪法要同步它）。
- **10 skill**：5 纪律 + 2 KB 导航 + hypothesis-ledger + biz-ontology-scaffold（含 EXECUTION-SOP/init/upgrade 脚本）+ infra-debug-playbook（三表自生长，数据在 `~/.ai-coding-pack/infra-playbook/`，setup.sh 永不覆盖）。
- **7 command**：handoff×3 + kb×2 + **/task-brief**（判据先红后绿→写 TASK_GOAL.md）+ **/cross-check**（fresh-context 证伪/抽检）。
- **2 hook**（机制层）：`verify-guard.py`（拦无证据断言+裸放弃，评测 11/11）+ `goal-guard.py`（/goal 确定性等价物：TASK_GOAL.md 有未勾判据不许停，5/5 实测）。挂载：Claude Code 全局 settings.json + **Codex hooks.json**（Codex 有与 CC 同构的 hook 机制，实测确认）。
- **evals/**：hook_eval 自动评测 + 14 失败卡 + 4 正例卡（exemplars）+ metrics-log 三指标台账 + README（正负并重方法论）。
- 业务实例（4 个，引擎已全升级至分块模糊版）：content_workflow（最活跃，26 条 question_log）、customer_experience、bios、biz-ontology（原型）。

## 本 arc 关键决策（新增）
- **Mem0 不引入**（两轮实测：真实业务 KB 14 条真实提问上,20 行词元重叠与向量打平,分块模糊 14/14@3 唯一全对；升级判据预置在 `docs/research-memory-systems-2026.md`）。
- **goal drift 调研结论**：我们的 handoff/goal/结案门禁与 Anthropic 官方 harness 逐件同构；真缺口=执行期复诵，已补进 task-brief（`docs/research-goal-drift-2026.md`）。
- **"同构≠等效"教训**：思想同构的文本规则执行力远低于机制；Codex 此前零机制是持续犯错主因——已补 verify-guard+goal-guard 两个 hook。
- effort 选档：两轴(错误代价×验证成本)+触发式升档，不盲目拉满（宪法七·深度自调节）。
- 案例卡实录必须向当事 agent 一手复盘核准（case 14 曾按用户转述写错两处）。

## 进行中 / 下一步第一动作
- 全部已提交推送，`main`=`origin/main`（最新 cfb99eb）。
- **待用户侧确认的两件**：①Codex 下次启动会弹 hook 信任确认（verify-guard/goal-guard/捕获器），需点允许；②跑一次 Codex 会话后，读 `~/.codex/verify-guard-stdin-capture.jsonl` 确认 Stop hook 数据格式与 CC 一致（不一致则改兼容层——这是下个 session 第一动作）。

## 待做（按优先级）
1. **[验证] Codex hook 格式确认**（见上）——确认后删捕获器条目。
2. **[修复] verify-guard 引用语境误报第 3 例已出现**（cases/08 已记）：GIVEUP 命中时检查条件式句式（"就标注/不许/若"）；改完 hook_eval 拦截率 11/11 不许掉。
3. **[执行] L4 数据**：两周三指标回填（evals/metrics-log.md，基线周 2026-07-26 起）+ KB 抽检第一轮（业务侧用 /cross-check）。
4. [核实] Trae Commands 面板能否导入本包 commands/；CoCo hook 机制。
5. [挂起带判据] Mem0 试点触发条件见 research-memory-systems 文档。

## 已知坑 & workaround（新增项）
- **单一真源是拷贝**：改仓库后必须 `bash setup.sh` 才到全局；实例还要 `upgrade.sh`（升级链：仓库→setup.sh→~/.ai-coding-pack→upgrade.sh→实例）。
- hook 启动时加载，`/clear` 大概率不重载 hook（未实证），重开会话才稳。
- verify-guard 已知红灯=元讨论/引用语境误报（3 例，cases/08）；goal-guard 是 opt-in（无 TASK_GOAL.md 零影响）。
- Mem0 若将来试点：PostHog 遥测默认开（MEM0_TELEMETRY=false）、纯检索也要占位 key、v2 search 用 filters 签名。
- 台账新发现：问过的问题连答案落在 question_log，重复提问直接命中（L3 复利生效实证）。

## 如何验证 / 运行
- hook：`python3 evals/hook_eval.py`（exit 1=仅已知红灯正常）；goal-guard 手测见 hooks/README。
- KB 引擎：任一实例 `python3 tools/kb.py doctor && python3 tools/kb.py search <业务问句>`。
- 基准复跑：scratchpad/memory_bench{,2}.py（venv 在 scratchpad/m0env）。

## 记忆（仓库外）
`~/.claude/projects/-Users-bytedance-Personal-Projects-coding-agent-discipline/memory/`：mission-maximize-agent-potential（六层+规则冻结）、verify-external-claims、falsify-data-conclusions、trae-supports-skills-natively。
