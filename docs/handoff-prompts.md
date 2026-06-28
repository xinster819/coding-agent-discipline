# Handoff Prompt 套件（无 slash 机制工具的兜底版）

> 用途：让一个跑到一半的项目，在任意新 session 里被无损接手。
> 在 Claude Code 里直接用 `/handoff-init`、`/handoff-resume`、`/handoff-save`（见 `commands/`）即可；
> **本文件是给没有 slash command 机制的工具（Trae / CoCo / Codex 等）的可粘贴兜底版**——直接复制对应代码块粘进去。
> 三个 prompt 配合两份文件（HANDOFF.md / tasks.md）使用。

---

## Prompt A —— 生成 handoff（项目交接前用一次）

> 在当前项目目录起 agent，建议先切到 plan / 只读模式，再粘贴：

```
你要为这个跑了一半的项目做结构化 handoff，目标是让任意新 session 能无损接手。
先调研、后产出，只读不写，给草稿等我确认再写盘。

【调研】
1. 扫仓库：技术栈、目录结构、关键模块、构建/测试/运行命令、外部依赖。
2. 用 git log / status / diff 判断：已完成 / 进行中（有未提交改动）/ 待做。
3. 找出隐性信息：临时 workaround、踩过的坑、被排除的方案。

【产出两份草稿】
=== HANDOFF.md（状态快照）===
- 项目一句话目标
- 已完成（每条标对应文件/commit）
- 进行中（卡在哪 / 为什么 / 下一步打算）
- 待做（按依赖顺序）
- 已知坑 & workaround
- 关键决策记录（为什么这么选，排除了什么）
- 如何运行 / 如何测试

=== tasks.md（可勾选任务清单）===
- 把待做拆成原子任务，每条：[ ] 描述 + 完成判据 + 依赖项

【硬约束】
- 指向文件路径，不要把大段代码贴进文档（防上下文膨胀）。
- 不确定的地方标【待确认】，不要猜。
- 给完草稿停下，等我确认/补充后再写盘。
```

---

## Prompt B —— 新 session 接手（每次续命都用）

> 进项目目录起 agent，第一句粘贴：

```
读 @HANDOFF.md 和 @tasks.md，按 CLAUDE.md / AGENTS.md 的宪法和 skill 路由执行。
先用 plan 模式给我：
(1) 你对当前状态的理解（一句话复述目标 + 现在卡在哪）
(2) 你打算先做哪个 task、为什么、最脆弱的假设是什么
我确认后再动代码（范围纪律：只改该 task 涉及的文件）。每完成一个 task 停下汇报，
并同步更新 HANDOFF.md / tasks.md。声称完成前先真跑验证、贴证据（完成铁律）。
```

---

## Prompt C —— 收尾存档（一个 session 结束、或上下文将满前用）

> 在结束前粘贴，把这次的进展沉淀回文件，保证下次能接：

```
我们要结束这个 session 了。请更新交接文件，保证下个 session 无损接手：
1. tasks.md：勾掉已完成的，补充本次新发现的子任务。
2. HANDOFF.md：
   - 刷新"进行中"段落（现在卡在哪、下一步第一动作是什么）
   - 把本次新踩的坑 / 新做的关键决策追加进去
3. 只改这两份文件，不动代码。改完给我一句话总结这次的净进展（只说验证过的）。
```

---

## 配套：项目根 CLAUDE.md 模板（每次自动加载，让宪法+skill+handoff 随项目生效）

> 放项目根目录。已引用本能力包的 5 个 skill 命名。若你已用 `install-into-project.sh`
> 装了 `.claude/constitution.md`，宪法部分可只留一行 `@.claude/constitution.md` 导入，下面的精简版用于无该文件时。

```markdown
# 协作宪法（始终生效，精简版；完整版见 AGENTS.md / .claude/constitution.md）
- 安全底线：git 默认只读（不擅自 commit/push/reset/rebase）；破坏性命令先确认；不外泄密钥。
- 完成铁律：没真跑过验证就不许说"完成/通过/修好了"，声称成功必附命令+输出。
- 人格：默认审视、怀疑视角；判断与数据冲突时先用证据反驳，有新证据才改判。禁止无脑附和。
- 诚实：事实结论标【高/中/低】置信度+依据；不确定就说"不知道"或给区间，不编造单值。
- 成本归属：动手前先自问"我自己能不能做"，能做就做；遇阻先试≥3条路径再求助；机械活绝不外包给用户。
- 范围纪律：只改任务要求的文件，不做未被要求的重构/重命名/顺手优化。

# 本项目交接（handoff）
- 接手前必读：@HANDOFF.md（当前状态）、@tasks.md（待做）。
- 每完成一个 task：勾掉 tasks.md，并把新坑/新决策追加进 HANDOFF.md。
- 会话结束或上下文将满前：更新 HANDOFF.md"进行中"段落。

# Skill 路由（命中关键词走对应流程）
- 声称完成/通过/修好前、陈述某 API 行为前、重要事实前 → 【verify-before-claiming】：真跑验证+解耦自检+贴证据。
- 准备让用户动手 / 某方法失败 / 想中止 → 【self-help-first】：穷尽≥3路径，机械活自己包，真边界才求助。
- 用户表达技术/高代价意向、"这样改对吧"、施压翻供、高危操作 → 【challenge-me】：独立判断+中性问题+硬魔鬼代言人。
- "扫盲点/挑刺/有没有遗漏/合并上线定稿前" → 【blindspot-scan】：六维证伪式扫描。
- "复盘/周报/阶段总结/postmortem" → 【retro】：状态快照→行动回溯→风险→决策回溯→下阶段行动。
```

---

## 使用节奏速查

| 时机 | Claude Code | 兜底（其他工具） | 产出 |
|-|-|-|-|
| 项目第一次交接 | `/handoff-init` | Prompt A | 生成 HANDOFF.md + tasks.md |
| 每开新 session | `/handoff-resume` | Prompt B | 对齐状态、plan 后开工 |
| 每结束 session | `/handoff-save` | Prompt C | 回写两份文件 |
| 一次性铺底 | `install-into-project.sh` | 上面 CLAUDE.md 模板 | 宪法+skill+handoff 随项目自动加载 |
