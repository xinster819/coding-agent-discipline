# 下钻调研：开源 Agent 记忆系统选型（2026-07，检索于 2026-07-21）

> 三路并行实调（GitHub README/官方 docs/源码级确认，全程无限流，每条带来源）。
> **选型判据（本仓库硬约束）**：①内网数据敏感→必须 self-host；②四工具共享→文件或本地服务，不绑单一工具/框架；③与现有文件式三层记忆（playbook=程序性/question_log=情景/memory=语义）的兼容；④零依赖哲学→引重依赖需实证瓶颈。

## 结论先行（2026-07-27 已实测，非纸面推演）

**"直接用 Mem0 会不会更好"——实测答案：不会。** 本机真实试点（mem0ai 2.0.12 + 本地中文 embedding bge-small-zh-v1.5 + Qdrant，`infer=False` 全程零 LLM 调用；语料=本仓库 25 个真实记忆文档；13 条真实查询含 9 条语义改写）：

| 方法 | literal @1/@3 | paraphrase @1/@3 |
|---|---|---|
| A 现有 kb.py（整句 substring） | 0/4 · 0/4 | 0/9 · 0/9 |
| **B 零依赖升级（2字词元重叠排序，~20 行代码）** | 3/4 · **4/4** | **6/9 · 7/9** |
| C Mem0 语义检索（向量） | 4/4 · 4/4 | **6/9 · 7/9** |

三个事实：①现有整句 grep 对自然语言问句全军覆没（0/13）——**痛点是真的**；②但救它不需要向量平台：**20 行零依赖的词元重叠排序拿到了与 Mem0 完全打平的 paraphrase 召回**（6/9@1、7/9@3），Mem0 仅在 literal @1 多对 1 条；③两条双方全挂的查询（"指标搜索为什么空""找独立复核例子"）说明剩余瓶颈在**文档表述**（卡片里缺场景化语言），换引擎救不了。
**已落地**：B 方案已实装进 `biz-ontology-scaffold` 引擎 kb.py（0 精确命中时自动模糊兜底，只扫 docs/resources/kb 管道），冒烟通过；已有实例 `upgrade.sh` 即得。
**试点中的实证副产品**：Mem0 默认 PostHog 遥测开机即活跃（内网顾虑坐实，需 `MEM0_TELEMETRY=false`）；`Memory.from_config` 即使纯检索用法也强制构造 LLM 客户端（需占位 key）；v2 的 `search()` 已改用 `filters` 签名（网上旧教程失效）。
**实验边界（诚实标注）**：语料仅 25 文档（当前真实规模）——千级文档后向量优势可能显现，升级判据保留；bge-small 是小模型，更强 embedding 未测；Mem0 完整体（LLM fact 抽取 + BM25/实体融合）未测，测的是其检索核心。基准脚本可复跑：scratchpad/memory_bench.py。

### 第二轮：真实业务 KB 复测（2026-07-27，回应"测试用例是不是不好"的质疑）

第一轮的两个弱点（语料是框架自己的记忆卡片；查询和 gold 都由框架侧编标）在第二轮修正：**语料 = content_workflow 真实 KB**（14 文件/158 块，含 46KB 大文档，按标题分块）；**查询 = 业务 question_log 台账里的 14 条用户原话**；**gold = 台账"转化动作"列记录的真实答案落点**（业务侧留档，非实验者标注）。

| 方法 | Recall@1 | Recall@3 |
|---|---|---|
| A 旧整句 grep | 0/14 | 0/14 |
| B 已实装 20 行模糊（整文件前 4k） | 12/14 | 13/14 |
| **B2 分块模糊（升级版，已实装）** | 11/14 | **14/14（唯一全对）** |
| C Mem0（bge-small-zh，分块） | 12/14 | 13/14 |

结论在真实战场上**成立且加强**：Mem0 与 20 行方案仍打平；**分块模糊是唯一 Recall@3 全对的方法**（Mem0 挂掉的"catalog 你有统计到吗"被它救回——短口语查询上小模型 embedding 反而输给词元重叠）。B2 已实装进引擎 kb.py（分块打分取最大，大文档答案在深处也能命中），冒烟通过。基准脚本：scratchpad/memory_bench2.py。

主流调研反向验证：**文件式笔记记忆是一等公民形态**——Anthropic 把"markdown 文件 + 六命令 + 开工先查库纪律"产品化为 GA 的 memory tool，Claude Code 的 auto-memory（MEMORY.md 索引 + 200 行装载预算）与本仓库结构几乎同构。我们不是"土法"，是走在主流形态上。

## 候选打分（详细事实见下节）

| 候选 | 内网 self-host | 四工具共享 | 文件式兼容 | 依赖重量 | 判定 |
|---|---|---|---|---|---|
| **Anthropic memory tool（GA）** | ✅ 存储本来就在你手里 | ✅ 协议/纪律可移植 | ✅ **同构** | ✅ 零 | **设计立即可抄** |
| **Mem0 OSS v2** | ✅（可接 OpenAI 兼容内部网关；⚠️默认带 posthog 遥测，试点前必须核实可关） | 🟡 REST server 可；原生多客户端方案 OpenMemory **正在 sunset** | ❌ 范式不同（LLM 抽取 fact 存向量库） | 🟡 库模式很轻（pip+本地 Qdrant+SQLite，唯一外部依赖=一个 LLM API） | **未来首选试点** |
| **Graphiti** | ✅（Neo4j/FalkorDB+本地 LLM 可行；小模型有抽取失败风险） | 🟡 实验性 MCP server | ❌ 图范式 | ❌ 重（图库+LLM 抽取硬依赖） | 出现时序/关系推理需求再评 |
| **cognee** | ✅（纯本地零外部服务模式：SQLite+LanceDB+KuzuDB） | 🟡 MCP profile | ❌ | ❌ 重（图+向量+ontology 全套 pipeline） | 同上；活跃度极高，备选 |
| Letta | 🟡 主仓已转 legacy、Docker 镜像弃用、必须 Postgres+pgvector | ❌ 绑自家 agent 运行时（当记忆层=绕道用法） | ❌ | ❌ | **排除**（转型期+运行时锁定） |
| Zep CE | ❌ 官方已停维护（代码进 legacy/，官方替代=Graphiti） | — | — | — | **排除** |
| LangMem | ✅ | ❌ pip 即拖入 LangGraph | 🟡 | 🟡 | **排除**（9 个月无发版、0.0.x） |

## 三条行动

**1. 立即（零成本，抄纪律不引依赖）**：Anthropic memory tool 的 API 注入纪律原文——"ALWAYS VIEW YOUR MEMORY DIRECTORY BEFORE DOING ANYTHING ELSE / 边干边记 / ASSUME INTERRUPTION（假设上下文随时被重置）"——其中 **ASSUME INTERRUPTION** 是我们回写纪律没有显式写的精髓：不是"收工时回写"，是**边干边写、随时可断**。落点：biz-ontology 模板 AGENTS.md 与 handoff 纪律补这一句。

**2. 挂起项转"带判据的升级路径"**（替代 roadmap 里模糊的"体量大了再说"）：满足任一才启动试点——
   - glossary 人工映射条目超过 ~200 条仍频繁漏检（语义检索的真实需求信号）；
   - question_log 里"覆盖内但 search 没找到"类失败 ≥3 次/周；
   - 出现"谁依赖谁/何时成立"的关系与时序记忆需求（→ 此时评 Graphiti/cognee 而非 Mem0）。

**3. 试点方案预置（触发后执行）**：Mem0 **库模式**（`pip install mem0ai`+`openai_base_url` 指内部 LLM 网关+本地 Qdrant），**先红后绿验收**：拿 question_log 历史问答做召回对比测试（grep+glossary vs Mem0 search），赢了才上；试点前置检查：posthog 遥测可关闭的证据、add() 每次 1 LLM 调用的成本核算。

## 关键事实备查（均检索于 2026-07-21，来源见调研原文）

- **Mem0**：61.3k star，Apache-2.0，~周更；v2 已移除外部图库支持（Neo4j 配置不再读取），图功能内建化（实体存向量库并行 collection）；`add()`=1 次 LLM 调用+多次 embedding，`search()` 只用 embedding；OSS 缺 temporal reasoning/memory decay（v3 平台版专属）；REST server 带 dashboard；OpenMemory（本地 MCP 多客户端）官方 sunset 中。
- **Graphiti**：~29k star，Apache-2.0，活跃（v0.29.2, 2026-06）；时序知识图谱（事实带有效期窗口+溯源）；LLM 结构化抽取是硬依赖，支持 OpenAI 兼容端点/本地模型（附小模型失败警告）；Zep CE 官方公告停维护（2025-04），自托管替代即 Graphiti。
- **Letta**：23.9k star，Apache-2.0；主仓自称 legacy server，活跃开发已移至 letta-code（TS）；官方 Docker 镜像不再维护；记忆=core memory blocks（常驻上下文）+archival（向量检索）；memory blocks 有独立 REST API 可多 agent 共享（绕道用法）。
- **cognee**：28.8k star，Apache-2.0，极活跃（v1.4.0.dev0, 2026-07-20）；v1.0 四操作 remember/recall/forget/improve；三类存储可单 Postgres 打通或纯本地零服务。
- **LangMem**：1.6k star，MIT；langgraph 为必装依赖；PyPI 最新 0.0.30（2025-10），9 个月无发版。
- **Anthropic memory tool**：GA 无需 beta header（`memory_20250818`）；API 只提供协议+自动注入纪律，存储与 path-traversal 防护全在客户端；SDK 有现成本地文件实现；可与 context editing/compaction 配套；官方"多 session 开发模式"=init session 建进度档+后续 session 先读档收工回写（与本仓库 handoff 同构）。
- **Claude Code memory**：CLAUDE.md 层级加载(managed→user→project→local,向上走目录树)+`@import`(最深 4 跳)+`.claude/rules/`(带 paths 作用域)+auto-memory(`MEMORY.md` 只装前 200 行/25KB,主题文件按需读)。
