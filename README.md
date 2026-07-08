# 编码协作能力包（coding-agent-pack）

> 一套不改模型、仅靠 **Rule + Skill** 两层杠杆，让 AI 编码 agent 与你的工作习惯深度契合的能力体系。
> 跨工具：Claude Code / Codex / CoCo / Trae 四个都用同一套（skill 自动加载；Trae 把规则粘一次）。全局安装，所有项目生效。
> 本包是两份方案（你另一个 agent 的 `ai-collab-pack` + 本调研方案）合并打磨后的最终版，并按"编码 agent"专门调优、用前沿研究背书。

---

## 它解决什么（你的六大诉求 → 对应能力）

| 你的痛点 | 能力 | 落在哪 | 研究根因 |
|---|---|---|---|
| AI 没跑就说"修好了"、幻觉 API/包 | 先查证再开口 + 完成铁律 | 宪法① · verify-before-claiming | 报"完成"仍 30–40% 没实现；19.7% 推荐包不存在 |
| 挤牙膏、要追问才给全 | 一次给全 + 固定骨架 | 宪法② | instruction-following / laziness |
| 不确定也硬给、过度自信 | 标置信度 + 过度自信自检 + 给区间 | 宪法③ | 言语化置信度默认过度自信，需自检纠偏 |
| 把机械活甩回给我 | 成本归属 + 自助红绿灯 | 宪法④ · self-help-first | 自主 agent 应自取信息而非追问 |
| 谄媚、无脑附和我的错方案 | 独立判断先行 + 中性问题 + 硬魔鬼代言人 | 宪法⑤ · challenge-me | 谄媚是 RLHF 结构性副产品；软反驳无效 |
| 自作主张改无关代码 / 上线踩坑 | 范围纪律 + 六维盲点扫描 | 宪法⑥ · blindspot-scan | AI 无关改动占约 23% 回归 bug |
| 擅自 commit/push、跑 rm -rf、泄露密钥 | 安全底线（git 默认只读 / 破坏性命令先确认 / 不外泄机密）始终生效 | 宪法·安全底线 | coding agent 头号破坏性事故 |

> 完整的研究证据与论文/repo 清单见上一级目录 `01_调研报告_为你定制AI能力.md`。

---

## 架构：两层，不堆料

- **RULE（编码协作宪法 = `AGENTS.md`）**：永久人格 + 六大纪律的**基线**，始终加载，刻意精简（每条都得改变行为，否则删）。
- **SKILL（8 个领域流程）**：靠 `description` 关键词**按需触发**，省上下文，放需要展开的深流程。**5 个纪律流程**（约束 agent 怎么思考/干活）+ **2 个代码库导航流程**（project-kb-production / refresh）+ **1 个调查流程**（hypothesis-ledger，长周期多 session 假设账本深挖）。
- **COMMAND（5 个 slash command）**：手动 `/` 显式调用的薄命令层——3 个 handoff（项目跨 session 接力）+ 2 个 KB 别名（`/kb-init`、`/kb-refresh`，详见下方速查）。
- **HOOK（机制兜底，可选但强烈建议）**：`hooks/verify-guard.py`——RULE/SKILL 是强引导可被绕过，hook 是**唯一不靠模型自觉**的一层。作为 Claude Code Stop hook，拦截"无证据的成功/能力断言"（如"修好了""X 不支持 Y"）并打回要证据。安装见 `hooks/README.md`。
- **EVAL（改规则前后跑，防凭轶事迭代）**：`evals/`——hook 自动评测（拦截率/误报率）+ 真实失败案例卡。改任何规则/hook 后跑 `python3 evals/hook_eval.py`，用数据判断这版是正向还是负向，见 `evals/README.md`。

> 反直觉点：规则不是越多越好。把所有边界塞进一份长 prompt 会导致 context rot（token 越多召回越差）。所以**宪法瘦，深流程下沉成 skill**。前沿模型可靠遵循的指令约 150–200 条，本宪法远低于此。

## 纪律 Skill 速查（5 个）

| Skill | 触发时机 | 核心产出 |
|---|---|---|
| **verify-before-claiming** | 声称完成/通过/修好前、陈述 API 行为前、重要事实前 | 完成铁律 + 真跑验证 + 解耦自检(CoVe) + 贴证据 + 反合理化对照表 |
| **self-help-first** | 卡住 / 想求助 / 准备让你动手前 | 求助 vs 甩锅红绿灯 + 真实/假边界清单 + 求助三件套 + 反过度矫正 STOP |
| **challenge-me** | 你表达技术/高代价意向("这样行吧"/"我打算…")/施压/高危操作 | 独立判断先行 + 中性问题改写 + 拒绝被压翻供 + 硬魔鬼代言人 + 高危加护栏（延后冷静+动机审计） |
| **blindspot-scan** | 合并/上线/定稿前、"挑刺/盲点" | 六维证伪式扫描（正确性·假设·失败模式·安全·性能·可维护） |
| **retro** | 复盘/周报/阶段回顾/事故 postmortem | 状态快照→行动项回溯→风险→决策回溯(反谄媚)→下阶段行动 |

## 代码库导航 Skill 速查（2 个）

帮 agent 在大仓库 / 多仓库里稳定找到 repo 入口、规则、测试命令、关键符号——和 handoff（跨时间接力）互补，管"跨空间不迷路"。

| Skill | 触发时机 | 核心产出 |
|---|---|---|
| **project-kb-production** | 建知识库 / 搭 KB / agent 老在仓库里迷路 | 显式覆盖边界 + 文档/代码分索引 + 稳定 search/doctor 入口 + 短重建链 + 硬验证 |
| **project-kb-refresh** | "最近代码有更新，KB 跟上没" / 搜出来还是旧的 | 定位变更范围 → 映射覆盖 → 重建 → doctor → 实查变更内容 → 归档影响摘要 |

> 同源基因：两者的硬规则「Verification Before Claims / Real Queries Are Mandatory」与 verify-before-claiming 的完成铁律一脉相承——KB 没真查到就不算"更新完成"。
>
> **怎么调用**：Claude Code 里装好的 skill 自动获得 `/` 入口,可直接敲 `/project-kb-production`、`/project-kb-refresh`(支持传参,如 `/project-kb-refresh 合并了 auth 模块`)。嫌名字长另提供短别名 **`/kb-init`**、**`/kb-refresh`**(commands/ 里的薄包装,等效)。Codex 无 `/` 自动入口,靠 skill description 自动触发。

## 3 个 Slash Command 速查（项目跨 session 接力）

Claude Code 原生 slash command；其他工具用 `docs/handoff-prompts.md` 的可粘贴版。三者是一个循环。

| 命令 | 时机 | 干什么 |
|---|---|---|
| `/handoff-init` | 项目首次接入 | 扫仓库 + git，生成 HANDOFF.md / tasks.md（只读，给草稿待确认） |
| `/handoff-resume` | 每次新开 session | 读档恢复状态，plan 后沿用原节奏继续 |
| `/handoff-save` | 每次收工 / 上下文将满前 | 把进展回写交接文件 |

---

## 这一版相比两份原稿改了什么（合并要点）

**采纳了 `ai-collab-pack` 的精华**：`self-help-first`（成本归属/不甩锅，含红绿灯与 STOP 条件，编码 agent 高频痛点）、`blindspot-scan`、`weekly-review`（升级为 `retro`）三个流程的骨架。

**用本调研方案补强**：
1. **完成铁律**——"没真跑过就不许说完成"，配禁用词与反合理化对照表（编码 agent 第一大隐形失败）。
2. **过度自信自检**——原稿只让标置信度，本版加了"给高分前先自检反例/是否迎合语气"的关键纠偏。
3. **反谄媚三件套升级**——独立判断先行 + 中性问题改写 + **硬**指派魔鬼代言人（研究证明"请你批判性思考"这类软话无效，必须"必须反对"）。
4. **防幻觉 API/依赖、先读后写、范围纪律**——编码专项条款。
5. **全部研究背书**——每个 skill footer 标注依据论文/官方文档。

---

## 全新 Claude / Codex 30 秒上手

一个干净环境，从零到能用：

```bash
git clone <本仓库地址> coding-agent-discipline
cd coding-agent-discipline
bash setup.sh        # 全局装：宪法 + 8 skill + 5 slash command，单一真源在 ~/.ai-coding-pack
```

`setup.sh` 会把本包复制到 `~/.ai-coding-pack`（**单一真源**），再从各工具全局目录符号链接过去——以后改规则只改这一处，所有工具同步生效。装完即生效，无需重启会话。

**装好后怎么用：**
1. **宪法自动生效**：安全底线 + 六大纪律每次都加载，不用手动带。
2. **skill 自动触发**：靠关键词（如"这样改对吧"→ challenge-me，"复盘下"→ retro），也可 `/skill-name` 显式调用。
3. **跨 session 项目接力**：用 handoff 三件套 `/handoff-init` → `/handoff-resume` → `/handoff-save`。
4. **验证装好了**：新开 `claude`，输入 `/` 应看到 `/handoff-init` 等；说"这样改对吧"应触发 challenge-me 式反驳。

**Codex 用户**：`setup.sh` 已装宪法（`~/.codex/AGENTS.md`）+ skill（`~/.agents/skills/`）；handoff 没有原生 slash，用 `docs/handoff-prompts.md` 的可粘贴 Prompt A/B/C。

**只想装进某一个项目**（随 git 团队共享）：`bash install-into-project.sh /path/to/project`。

> 完整分工具步骤（含 CoCo / Trae）见 `INSTALL.md`。

## 维护（让它越用越贴合你）
- **纠正两次就写进规则**：同类问题纠正 AI 两次，就让它把规则加进 `AGENTS.md`。
- **改一处，处处生效**：只改 `~/.ai-coding-pack/` 里的单一真源。
- 定期删掉没在用的条款，保持宪法精简。
