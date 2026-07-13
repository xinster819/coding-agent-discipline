---
name: biz-ontology-scaffold
description: 一条命令实例化"面向业务的 ontology / 知识库工作区"的通用脚手架——目录骨架 + 零依赖引擎（search/doctor/index/sync/refresh）+ 模板（覆盖边界 registry、回答契约 answer_contracts、三场景卡、资源台账、user-friendly CHANGELOG）。当用户要"给某业务建 ontology / 知识库工作区 / 把代码库+文档+DB/MQ/HDFS 资源整合成 AI 友好的知识库 / 支持业务问答+异常排查+指标分析 / 代码仓库定时自动更新且更新记录可人工 review"时使用。Use to scaffold a business ontology workspace: multi-repo clone + AI-friendly KB + scheduled refresh with human-reviewable changelog. 方法论 canonical 是 project-kb-production（本 skill 是其可执行脚手架实现，不另立模型）；只刷新已有库用 project-kb-refresh；单纯建导航 KB 不需要业务本体时直接用 project-kb-production。
---

# biz-ontology-scaffold：业务 Ontology 工作区脚手架

> **收口声明**：方法论以 `project-kb-production` 为 canonical（显式覆盖边界 / 文档代码分管道 / 稳定 search+doctor 入口 / 短重建链 / 硬验证）。本 skill 把它落成**可执行资产**，并追加业务 ontology 特有件（answer_contracts / 三场景卡 / 资源台账 / 自动更新+人审记录）。两者冲突时以 production 为准。

## 何时用
- 要为某业务域建"代码仓库 + 文档 + 资源依赖（DB/MQ/HDFS）"一体的 AI 友好知识库
- 要求：支持业务问答 / 异常排查 / 指标分析三场景；repos 定时自动更新；更新记录人类可 review

## 一条命令实例化
```bash
bash scripts/init.sh <目标目录> <业务域名>
# 例：bash scripts/init.sh ~/BI_Projects/ad-audit-ontology ad-audit
```
生成骨架并自动跑 index+doctor 展示**红态验收基线**（先红后绿）。

## 框架分层（引擎 vs 实例）
| 层 | 内容 | 谁改 |
|---|---|---|
| 引擎（`tools/`） | kb.py（search/doctor/index，零依赖、registry 驱动）、sync.sh、refresh.sh | 框架升级时覆盖，实例内不改 |
| 配置（`source_registry.json`） | 覆盖边界唯一真源：repos/docs/资源全在此注册 | 实例按业务填 |
| 知识（`kb/` `resources/` `docs/`） | answer_contracts、场景卡、台账、文档 | 实例持续沉淀 |
| 记录（`CHANGELOG/`） | refresh 自动写人话记录，按月一文件 | 机器写、人 review |

## 关键设计（每条对应一个踩过的坑）
1. **工具行为 = registry 驱动，无硬编码**——验收第 3 条强制证明"新注册 repo 后 search 能命中"（防"文档声明≠工具行为"）。
2. **验收先红后绿**——init 即展示红态；每个验收项必须"当前失败、接入后通过"。
3. **answer_contracts 从最高频业务问题倒推**——契约含 final_evidence（最终结果字段）与 intermediate_states_not_answers（禁把"进入了 X 流程"当答案）。
4. **零外部依赖**——纯 Python 标准库，registry/契约/台账全 JSON（标准库无 YAML parser）。
5. **canonical 收口**——实例的 AGENTS.md 是该工作区唯一规则入口，repo 内既有 SOP/verdict 文档在其"引用关系"表登记从属，不并立第 N 套。
6. **更新可 review**——refresh 每次追加人话 CHANGELOG（repo 新 commit 摘要/索引增减/doctor 结果/⚠️项）；doctor 失败退出码非 0 可接告警。
7. **macOS bash 3.2 兼容**——sync.sh 不用 mapfile（实测踩过）。
8. **提问驱动生长（P5 回路）**——KB 不预测用户问什么，靠回收真实提问长成用户的形状：`kb/question_log.md` 问答台账（答不准的必录）→ `kb/ontology/glossary.json` 业务词典（业务语言→代码符号，search 自动扩展查询）→ 同类问题 ≥2 次升级 answer_contracts。防"验收失败经验只留在对话里"（实证事故）。已有实例用 `scripts/upgrade.sh` 升级（引擎覆盖+模板增量，业务数据不动）。

## 角色分工
本 skill（框架侧）只管：引擎、模板、SOP。**实例化、填源、部署、cron 等业务对接执行，由业务侧执行者按 [references/EXECUTION-SOP.md](references/EXECUTION-SOP.md) 完成**——那是给执行 agent 照跑的标准作业程序（P0 实例化 → P1 填边界 → P2 首刷验收 → P3 契约打样 → P4 定时确认，每步带先红后绿判据）。执行中发现框架问题回报本仓库，不在实例里魔改 tools/。

## 实例化后的推进（P1）
1. `source_registry.json` 登记 repos（name+git）；文档进 `docs/`；台账填 `resources/*.json`
2. 用户给最高频 3 个业务问题 → 填 `kb/ontology/answer_contracts.json`
3. `./tools/refresh.sh` → doctor 转绿 + search 命中业务词 = 验收
4. 用户确认后装 cron（README 有现成行；改用户配置必须先确认）

## 验收清单（实例级，先红后绿）
- [ ] doctor 退出码 0（三管道计数 >0）
- [ ] search 业务词命中且给 file:line
- [ ] 新注册 repo 后 search 能命中其文件
- [ ] refresh 后 CHANGELOG 有当次人话记录
- [ ] 3 条真实业务问题按契约走到"结果语言"答案

*依据：project-kb-production（方法论 canonical）；evals/cases/09-11（假阳性验收 / 文档声明当工具行为 / 规则源不收口）；实例首跑实测（红态基线、注册→命中链路、bash 3.2 mapfile 坑）。*
