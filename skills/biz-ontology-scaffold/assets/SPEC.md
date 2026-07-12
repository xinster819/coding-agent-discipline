# __DOMAIN__-ontology — 面向业务的 Ontology / 知识库架构

> 目标：把业务全部资源（代码仓库、核心文档、DB/MQ/HDFS 等资源依赖）整合成一个 **AI 友好**的知识库，
> 支撑三类场景：**业务咨询问答 / 系统异常排查 / 指标异常分析**，并能**定时自更新 + 人类可 review 的更新记录**。

## 0. 事实前提表（每个前提标证据或【假设】）

| 前提 | 状态 | 证据 / 待确认 |
|---|---|---|
| 部署位置 `__WORKSPACE__` | 【假设】 | 你的业务仓库都在 `~/BI_Projects`（ls 实测）；不合适 `mv` 即可，registry 内全用相对路径 |
| 仓库清单、文档源、资源清单 | ❓待你提供 | 见 §6 |
| 工具零外部依赖（纯 Python 标准库） | ✅ | registry 用 **JSON** 而非 YAML（标准库无 YAML parser——前车之鉴） |
| `kb.py search` 真读 registry | ✅ | tools/kb.py 实现即 registry 驱动，**无硬编码文件列表**（前车之鉴：文档声明≠工具行为） |
| 定时任务用 cron | 【假设】 | 给出 crontab 行但**不替你安装**（改用户配置需你确认） |

## 1. 目录结构（canonical：本文件；覆盖边界 canonical：source_registry.json）

```
__DOMAIN__-ontology/
├── SPEC.md                  # 本设计（architecture canonical）
├── AGENTS.md                # AI 使用本 KB 的唯一规则入口（rules canonical，不另立第二套）
├── README.md                # 人类入口：怎么跑、怎么 review
├── source_registry.json     # ★ 覆盖边界唯一真源：repos + docs + resources 全在此注册
├── repos/                   # 全部代码仓库（sync.sh 按 registry clone/pull 到这里）
├── docs/                    # 核心业务文档（手放或脚本拉取，registry 注册）
├── resources/               # 资源依赖台账：db.json / mq.json / hdfs.json（含取数命令与口径）
├── kb/
│   ├── ontology/            # 业务本体：entities.json（服务/表/topic 及关系）
│   │   └── answer_contracts.json  # ★ 从"用户最高频问题"倒推的回答契约（如"到底罚成没有"）
│   └── scenarios/           # 三场景入口卡：qa.md / incident.md / metrics.md
├── tools/
│   ├── kb.py                # 稳定入口：search / doctor / index（零依赖，registry 驱动）
│   ├── sync.sh              # clone/pull 全部 repos + 摘要
│   └── refresh.sh           # sync → index → doctor → 写 CHANGELOG（定时任务入口）
├── CHANGELOG/               # user-friendly 更新记录，按月一个文件，供人 review
└── .kb/                     # 机器状态：manifest.json（索引快照，勿手改）
```

**设计要点（对应踩过的坑）**
- **覆盖边界显式**：不在 registry 里的目录/文件类型 = 不覆盖，KB 不假装知道。
- **文档/代码/资源三管道分开**：index 分别计数，doctor 分别体检。
- **一个查询面**：AI 只需知道 `kb.py search|doctor`，不需要知道内部文件名。
- **answer_contracts 从核心业务问题倒推**：每条契约 = 一个高频问题 + 判定所需完整证据链（哪个日志/哪张表/哪个字段=最终结果），防"进入了惩罚路径"式的中间态行话回答。
- **canonical 收口**：规则只有 `AGENTS.md` 一份；若未来某 repo 内有自己的 verdict/SOP 文档，在 AGENTS.md 里声明引用关系，不新立模型。

## 2. 三场景怎么被 KB 支撑

| 场景 | 入口 | 依赖的 KB 件 |
|---|---|---|
| 业务咨询问答 | `kb/scenarios/qa.md` | answer_contracts（问题→证据链）+ docs 索引 |
| 系统异常排查 | `kb/scenarios/incident.md` | ontology/entities（服务↔资源依赖图）+ repos 代码索引 + resources 取数命令 |
| 指标异常分析 | `kb/scenarios/metrics.md` | resources 台账（指标口径/取数命令）+ answer_contracts |

## 3. 自动更新流水线

```
cron（你确认后安装）
  └── tools/refresh.sh
        1. sync.sh：按 registry clone 缺失 / pull 已有（--ff-only，安全）
        2. kb.py index：重建 manifest（docs/code 分管道计数）
        3. kb.py doctor：体检，失败则 CHANGELOG 标 ⚠️ 且退出码非 0
        4. 追加 CHANGELOG/<YYYY-MM>.md：人话摘要（哪些 repo 有新 commit、索引增减、doctor 结果、需人工关注项）
```
建议 crontab（**你自己装**，或告诉我你确认后我装）：
`0 7,13,19 * * * cd __WORKSPACE__ && ./tools/refresh.sh >> .kb/cron.log 2>&1`

## 4. 验收标准（先红后绿——当前红态已实测，见 README）

| # | 验收项 | 当前（红） | 完成判据（绿） |
|---|---|---|---|
| 1 | `kb.py doctor` 通过 | ❌ registry 无源、repos 空 | 退出码 0，三管道计数 >0 |
| 2 | `kb.py search <某业务词>` 命中 | ❌ 0 命中 | 命中且给出 file:line |
| 3 | 新注册 repo 后 search 能命中其文件 | ❌ 无 repo | 注册+refresh 后命中（证明 search 真读 registry） |
| 4 | refresh 后 CHANGELOG 有当次人话记录 | ❌ 空 | 有日期条目含 repo 变更摘要 |
| 5 | 3 条真实业务问题走 answer_contracts 能给出"结果语言"答案 | ❌ 契约为空 | 每条指到证据链终点（成/败字段），无中间态行话 |

## 5. 分期

- **P0（本次已交付）**：骨架 + 工具（sync/index/search/doctor/refresh/CHANGELOG）+ 模板 + 红态验收基线
- **P1（你给清单后）**：填 registry → 首次 sync/index → doctor 转绿 → 3 条真实问题打样 answer_contracts
- **P2**：cron 上线、ontology/entities 充实（服务↔DB/MQ/HDFS 依赖图）、按使用反馈迭代场景卡

## 6. 你需要提供的（P1 输入清单）

1. **repo 清单**：git 地址列表（或就用 `~/BI_Projects` 下现有目录名，我登记后由 sync 管理）
2. **核心文档**：放进 `docs/` 或给我路径/导出方式
3. **资源依赖清单**：DB/MQ/HDFS 的名称、用途一句话、查询/取数命令（有多少给多少，台账可增量补）
4. **3 个你最高频的业务问题**（如"广告主 X 到底罚成没有"）——用来打样 answer_contracts
