# 调研：多轮沟通后 Agent 丢失原始目标（goal drift）——业界解法图谱（检索 2026-07-23）

> 两路并行实调：①官方/框架侧（Anthropic 三篇工程博客、Claude Code docs、Manus、OpenAI 官方 PDF 逐页、LangGraph、Cognition）；②开源+研究侧（9 框架逐个实查 + 9 篇实证）。除个别标注外均为一手原文，带引文。

## 一、问题的实证规模（为什么它是真问题）

| 发现 | 数据 | 来源 |
|---|---|---|
| 多轮 vs 单轮性能 | 平均**掉 39%**，"拐错弯就迷路且不会恢复" | Microsoft, arXiv 2505.06120（20万+模拟对话） |
| drift 出现速度 | **8 轮内**即显著，归因 attention decay（首部 token 注意力衰减） | arXiv 2402.10962 (COLM 2024) |
| 一致性衰减 | 最佳 agent pass^1>60% 但 **pass^8≈25%** | τ-bench (Sierra) |
| 首轮指令保持 | frontier 模型全部 **<50%**（最好 41.4%） | MultiChallenge (Scale AI) |
| 关键洞察 | **抗漂移能力与指令遵循能力弱相关**——"模型更听话"≠"更不漂移"，必须 harness 层解决 | arXiv 2505.02709 (AIES 2025) |
| 根因 | context rot：注意力预算随 token 增长耗尽；关键信息在上下文**中部**时最易丢（U 型曲线） | Anthropic 工程博客；Lost in the Middle (TACL 2024)；Chroma Context Rot |

## 二、解法图谱（按 drift 的四个环节组织，业界收敛度很高）

**环节① 注意力稀释**（目标还在上下文里但被淹没）
- **Recitation 复诵**（Manus，被引最多的单点技术）：每步重写 `todo.md` 勾选状态，"把全局计划不断推到上下文尾部的近期注意力区"，明确自述对抗 lost-in-the-middle 与 goal misalignment。
- **TodoWrite/Task 工具**（Claude Code）：recitation 的产品化+结构化（pending/in_progress/completed + 依赖）；LangChain 点破其本质："planning tool 是 no-op——价值全在把计划反复写回上下文"。
- **Plan-and-Execute**（LangGraph）：state 四字段（input=原始目标/plan/pastSteps/response），**replanner 每轮结构性重看原始目标**；smolagents `planning_interval` 每 N 步强制插入规划步。

**环节② compaction/换窗丢失**（压缩或新窗口时目标没带过去）
- 目标**外置文件**、压缩杀不掉：Anthropic structured note-taking（NOTES.md/memory tool）；CLAUDE.md **compaction 后自动 re-inject**（对话内指令则会丢——官方明说要写进文件）；OpenHands condenser `keep_first` 永久保护初始用户消息；Cognition 用专用压缩模型且承认"hard to get right"、SWE-1.7 甚至把"写好/用好交接摘要"练进模型训练。

**环节③ 子任务发散**（多 agent 拿不到完整意图）
- Cognition：单线程 + 共享全量 trace，"决策过于分散、上下文无法充分共享"是根因；10 个月后修正版：子 agent 出智力、**写操作保持单线程**。
- Anthropic 多 agent 研究系统教训："Without detailed task descriptions, agents duplicate work, leave gaps"——每个子 agent 必须给明确目标/输出格式/边界；Magentic-One 双账本（Task Ledger 事实+计划 / Progress Ledger 每步自反思+停滞检测）。

**环节④ 提前收工**（drift 的另一张脸：目标没完成就宣布完成）
- **`/goal`**（Claude Code v2.1.139+，官方实现）："completion is decided by a fresh model rather than the one doing the work"——完成与否由独立小模型按条件判定，不许干活的模型自由心证；配 Stop hook 可做确定性脚本判定。
- **Anthropic 长任务 harness**：init session 建 `feature_list.json`（200+ 条逐条 pass/fail）+ `claude-progress.txt` + 开工仪式（读 git log/进度文件→选最高优先级未完成项）——直接治"后来的 agent 看到有进展就宣布完工"。
- **OpenAI**：run loop 显式 exit conditions（代码化完成判据）+ **relevance classifier** 运行时拦跑题（唯一把"偏题"做成独立防线的官方指南）。

## 三、对照本仓库（验证 + 真缺口）

| 业界机制 | 我们的对应物 | 判定 |
|---|---|---|
| /goal 独立模型判完成 | 已在用（实证有效）；且其设计哲学=我们的完成铁律+cross-check（fresh context 判定） | ✅ 同构，官方背书 |
| feature_list pass/fail + progress 文件 + 开工仪式 | handoff 三件套（HANDOFF.md/tasks.md）+ 结案门禁 + task-brief 判据先红后绿 | ✅ 高度同构 |
| 目标外置文件防 compaction | 宪法/CLAUDE.md/HANDOFF 全是文件式 + ASSUME INTERRUPTION 纪律 | ✅ 已具备 |
| 详细子任务描述防发散 | /cross-check 与 SOP 已要求；宪法"长任务防漂移"条款 | ✅ 已具备 |
| **Recitation 每步复诵**（执行期持续勾选重写） | ⚠️ 缺口：task-brief 是开工一次性交判据，**执行期没有"每完成一步立即回写清单"的复诵纪律**；Claude Code 有 TodoWrite 原生兜底，**Codex/Trae 全靠自觉** | ❌ → 本次已补进 task-brief/SOP |
| Relevance classifier 运行时拦跑题 | 无 | 🟡 低优先（我们场景跑题少、成本高） |
| 把交接摘要练进模型（SWE-1.7） | 超出"不改模型"边界 | — 关注即可 |

## 四、行动（已落地一条，其余不动）

1. ✅ **task-brief 补复诵纪律**：执行期每完成/推进一项判据，立即重写勾选状态清单（Claude Code 用 Task 工具，Codex/Trae 手写 progress 清单到回复尾部）——Manus recitation 的移植。
2. 不新增其他机制：四环节里三个已有同构物，业界数据反向验证了 handoff/goal/结案门禁这条路（Anthropic 官方 harness 与我们几乎逐件对应）。
3. 给用户的使用要点：长任务**必配** `/goal` 或 task-brief（把目标变成停止条件——研究实证"模型更听话≠更不漂移"，靠 prompt 叮嘱无效，必须机制）。
