# 调研：提升 Agent 能力的主流与前沿方案（2025-2026）

> 状态：搜索+抓源完成（15 源/25 断言，检索于 2026-07-20~26）；**对抗核验层因会话限额未跑**，全部断言标 ❓（抓取自原文、未三票核验）；arXiv 被限流，**agentic RL / 自我改进角覆盖不足**（待补跑）。
> 与本仓库六层框架的对照见文末——这是本调研的核心产出。

## 1. Context Engineering（已成主流，事实标准由 Anthropic 定义）

- **动因 "context rot"**：token 越多、召回越差，LLM 有有限 "attention budget"（Anthropic 工程博客）❓——与本仓库"宪法要瘦"的理由完全同源。
- **四大运行时技术**（Anthropic 已提供第一方 API 支持，无需自建编排）❓：
  - **Compaction**（压缩重启，`compact_20260112`）：Claude Code 长任务实际采用；cookbook 实测峰值上下文 335k→169k(约50%)，高层事实全保留、冷僻细节全丢失；
  - **Tool-result clearing**（`clear_tool_uses_20250919`）：只清工具结果块，峰值 335k→173k；
  - **Memory tool**（`memory_20250818`，public beta）：上下文窗口外的结构化笔记（六命令，文件后端开发者自实现）——实测带记忆的第二 session 直接读 ~3k token 已存结论续跑；
  - **Just-in-time 检索**：agent 只持轻量标识符（路径/查询/链接），运行时按需加载；Claude Code 用 glob/grep/head/tail 原语。
- 来源：anthropic.com/engineering/effective-context-engineering-for-ai-agents、platform.claude.com/cookbook（tool-use context engineering）

## 2. 记忆系统（已成主流，开源生态繁荣）

- **Mem0**（github.com/mem0ai/mem0，~61.3k star，检索 2026-07-20）❓：开源记忆层事实首选；2026-04 自报 LoCoMo 92.5 / LongMemEval 94.4（**项目方自报，无第三方复现**）。
- 生态：Letta（MemGPT）、Zep、Graphiti（图记忆）；**Agent_Memory_Techniques**（NirDiamant，30 个可跑 notebook）给出可执行分类学❓：短期缓冲→长期（情景/语义/程序性）→认知架构（consolidation/自反思/遗忘衰减）→多智能体共享→评测（LoCoMo 基准）。
- 要点：**主流记忆形态就是"结构化笔记 + 检索"**，与本仓库 playbook/question_log/记忆文件同构；差别在检索层（向量/图 vs 我们的 grep+词典）。

## 3. Multi-agent 编排（主流共识：能单则单，多是升级手段不是默认）

三大厂商罕见一致❓：
- **Anthropic**：workflows（预定义路径）vs agents（动态决策）二分法；五种主流编排模式（prompt chaining / routing / parallelization / **orchestrator-workers** / evaluator-optimizer）；**明确主张简单可组合优先，收益可测量才加复杂度**。
- **OpenAI**：默认先把单 agent 做满，仅当"复杂指令跟不住/持续选错工具"才拆多 agent；两类模式：Manager（agents as tools）与 Decentralized（handoff）。
- **LangChain**：五模式（subagents / handoffs / **skills** / router / 自定义 workflow）；动机排第一的是**上下文管理**；官方警告多智能体不是默认选项。
- **反方（Cognition/Devin）**："Don't build multi-agents"——2025 技术水平下并行多 agent 只会产出脆弱系统（决策分散+上下文无法共享）❓。
- **有效的窄形态**：子 agent 用干净上下文做聚焦任务、只回传 1-2k token 摘要（Anthropic 称其多智能体研究系统显著优于单 agent）❓——正是本仓库 /cross-check 的形态。

## 4. 长时程 Harness（新兴前沿，Anthropic 2026 工程实践）

- **官方承认开放问题**：即便 Opus 4.5 + Agent SDK，跨多 context window 稳定推进仍未解决❓。
- **两段式架构**❓：init agent 首个 session 搭脚手架（init.sh、claude-progress.txt 进度日志、初始 commit）→ 后续 coding agent 只做增量+留结构化更新——**与本仓库 handoff 三件套/HANDOFF.md 高度同构**。
- **每 session 只做一个 feature**（配合初始化时展开的完整清单，案例 200+ 条）被证明是治"一次做太多/过早宣布完成"的关键❓——同构于本仓库"结案门禁+覆盖矩阵"。
- 来源：anthropic.com/engineering/effective-harnesses-for-long-running-agents

## 5. Skills / 规则注入（已成主流形态之一）

- LangChain 把 **skills**（单 agent 按需加载专门提示/知识）列为五大架构模式之一❓；Anthropic/Claude Code 的 SKILL.md 生态即此形态——本仓库整个 L0 层就是它的实例。

## 6. 覆盖不足（待补）

- **Agentic RL / self-improvement**：arXiv 抓取全部被限流，本轮无一手材料——**不凭记忆补写**，待限额重置后补跑核验与此角（resumeFromRunId 可复用已完成前缀）。

---

## 对照本仓库六层框架的 Gap 分析（本调研核心产出）

| 主流方案 | 我们的对应物 | 判定 |
|---|---|---|
| Context engineering（context rot/瘦上下文） | 宪法瘦身哲学、KB JIT 式 search（只持标识符现查） | ✅ 方向一致，属"土法同构" |
| Memory tool / 结构化笔记 | infra-playbook、question_log、记忆文件、HANDOFF | ✅ 形态相同（文件笔记就是主流形态）；**gap：检索层**（他们向量/图，我们 grep+glossary）——量级大了再升级，不提前堆 |
| 长时程 harness（进度文件+每session一件事+init脚手架） | handoff 三件套、结案门禁、覆盖矩阵、/task-brief | ✅ **高度同构**，Anthropic 官方实践反向验证了我们的路 |
| 单 agent 优先、简单可组合优先 | 六层框架"规则冻结、不堆料"、宪法反 context rot | ✅ 与三大厂商共识一致 |
| 子 agent 干净上下文+浓缩回传 | /cross-check（L6） | ✅ 已落地且首跑见效 |
| evaluator-optimizer 编排 | hook_eval + 抽检 + 熔断 | 🟡 有雏形；差自动化程度 |
| **Compaction / tool-result clearing（API 级）** | 无（依赖 Claude Code 内建 compact） | ❌ **真 gap**——长任务 KB 构建/深挖类可引入 |
| **记忆评测基准（LoCoMo 类）** | 无——我们的记忆/回写从未量化评测 | ❌ 真 gap（低优先：先把三指标跑起来） |
| **Agentic RL / 自我改进训练** | 无（也超出"不改模型"边界） | ❌ 未覆盖+超边界；调研补跑后再评估 |

**三条行动建议（按杠杆）**：
1. **不折腾方向**：主流共识（单 agent 优先/简单优先/文件式记忆/进度文件 harness）与本仓库路线高度一致——继续走，不换道；
2. **可引入**：长任务（KB 全量重建/深挖）套 Anthropic 两段式 harness 的"init 脚手架+进度文件"模式强化 handoff-init；context 编辑 API（compaction/clearing）在自建长任务工具时采用；
3. **待补**：限额重置后补跑对抗核验 + agentic RL 角；记忆检索层升级（向量/图）挂起，等 playbook/KB 体量证明 grep 不够用再动。
