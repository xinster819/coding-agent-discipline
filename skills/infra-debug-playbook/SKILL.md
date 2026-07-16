---
name: infra-debug-playbook
description: 公司内部基建（bytedcli / TCE / RDS / Argos / apm / BMQ / 权限系统等）的实战作战手册——任务→已验证命令路由、参数陷阱账本、权限申请地址簿，配"踩通必回写"自生长回路。当用户要排查线上问题、查内部平台数据（表/指标/日志/pod/消费组）、用 bytedcli 或任何内部 CLI/平台干活、遇到权限不足需要申请入口、或 AI 曾用错工具入口时使用。Use when debugging with ByteDance internal infra tooling, querying internal platforms, or needing access-request entry points. 分工：bytedcli skill 是"能力目录"（有哪些域），本 skill 是"实战层"（这个任务的正确调用式+坑+权限入口）；根因推理走 hypothesis-ledger；业务级表/链路知识在各业务 ontology 实例的 resources 台账（可引用本手册）。
---

# infra-debug-playbook：基建实战手册（自生长）

> **为什么存在**：能力目录（bytedcli skill）告诉你"该用 bytedcli"，但"查 RDS 业务表的正确入口是 `rds db query` 而不是 `dms`/`db`"这类**调用式知识**只能靠踩——踩过的不回写，下个 session 重踩一遍。本 skill = 三张可生长的数据表 + 使用纪律。

## 数据在哪（单一真源，所有工具共享）

`~/.ai-coding-pack/infra-playbook/`（setup.sh **只初始化一次、永不覆盖**——这是可生长数据，不是模板）：
- `tool-routes.md`——任务 → 已验证命令（带实测日期）
- `pitfalls.md`——参数/地域/入口陷阱（现象→正确做法）
- `access-directory.md`——权限申请地址簿（资源 → 申请入口 → 生效验证法）

## 使用顺序（硬纪律）

1. **先查手册**：动手前先读 `tool-routes.md` 找同类任务的已验证命令；命中就直接用（含地域/env 设置）。
2. **手册没有 → 枚举后再试**：读 bytedcli skill 能力目录定位域 → 读全该域 `--help`/子命令树（**别凭入口名猜功能**，数据库查询在 `rds` 不在 `db`）→ 按 self-help-first 举证义务试满 ≥3 个不同入口。
3. **踩通必回写（本 skill 的灵魂）**：任何新命令跑通 / 新坑踩明白 / 新权限入口确认，**当场**写进对应文件（格式见各文件头），带日期和一句话场景。不回写 = 白踩。
4. **条目过时就修**：手册里的命令报错 → 复核后修正原条目并留一行勘误，不新增重复条目。

## 权限问题（高危：禁止编造）

- **内部平台 URL / 审批流 ID 是幻觉高发区**——`access-directory.md` 里没有的，一律输出"**【地址簿无此项】**需要人工补充：请把申请入口发我，我回写地址簿"，**绝不凭记忆/模式编一个内部链接**。
- 拿到入口后回写三件套：申请 URL/入口路径 + 需要的审批信息 + **生效验证命令**（怎么确认权限已到位，如重跑原命令看退出码）。
- 权限不足的报错要原文记进 pitfalls（下次一眼识别是权限问题而不是入口问题）。

## 条目质量（继承宪法）

- 每条命令必须**实测过**才能写"已验证"+ 日期；从文档抄来没跑过的标【待实测】。
- 声明 ≠ 行为：平台文档说支持 ≠ 手册条目，跑通才算。
- 手册数据不含密钥/token/生产 PII——只记命令形态与入口，凭证走各自的 auth 机制。

## 维护与归档

- 手册在 `~/.ai-coding-pack/infra-playbook/` 可被任何 session 直接编辑（这是设计，不是越界）。
- 建议定期（如 retro 时）把手册拷回本仓库 `skills/infra-debug-playbook/templates/` 做版本归档 + review。

## 分工收口

| 资产 | 管什么 |
|---|---|
| bytedcli skill（既有） | 能力目录 canonical：有哪些域、优先用 bytedcli |
| **本 skill** | 实战层：正确调用式 / 陷阱 / 权限入口，自生长 |
| hypothesis-ledger | 根因推理与跨 session 假设推进 |
| 业务 ontology 实例 `resources/` | 业务级表/链路/取数语义（可引用本手册条目） |
| self-help-first | "查不到"前的举证义务（本 skill 第 2 步执行它） |

*依据：本仓库实测踩坑直接入种子——TCE `--vregion` 位置试错 3 次（2026-07-12）、grafana 指标前缀盲猜全空（2026-07-12）、`rds db query` 靠用户纠正才找到（2026-07-15，evals/cases/13）。方法论同源：biz-ontology-scaffold 的 question_log/台账回写回路，应用于基建层。*
