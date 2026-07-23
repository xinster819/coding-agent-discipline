# tasks — coding-agent-discipline

> 刷新于 goal-guard 落地后（cfb99eb）。[x]=已完成并验证。

## 已完成（本 arc 全量,按时间序）
- [x] handoff 三件套 + behavior-audit 并入 challenge-me（4a61566）
- [x] KB 两件套纳入 + /kb 别名（1edb9ad/2073ac2）
- [x] verify-guard hook + 外部声明纪律 + Trae 文档修正（d71375b）
- [x] 数据解读纪律：证伪优先（aef488e）
- [x] hypothesis-ledger skill / 先答所问纪律 / ground truth 精简（7640913）
- [x] eval 体系（hook_eval + 失败卡 + 基线）（2cfedf0）
- [x] ontology spec 复盘收编：验收先红后绿/事实前提表/canonical 收口（ff5e664）
- [x] biz-ontology-scaffold skill + EXECUTION-SOP + P5 提问驱动生长回路（f66833d/8df9064/028f004）
- [x] R&F 复盘收编：存在性断言证据分级（d9dd0b4）；KB 校准三件套：可决策性标注/抽检/熔断（28ed301）
- [x] "早弃"侧纪律 + hook 拦裸放弃（71d2abf）；"静默降级"最优近似义务（d4e1366）；case14 按一手复盘修正 + 结案门禁（d391169）
- [x] 正例库 exemplars + 宪法七探索精神（5f15c2b）；mission 重定位六层杠杆（cbfaa2c）；effort 科学选档（1b7488c）
- [x] 完整方案收口 + /task-brief /cross-check + metrics-log + 收工三问（9a922ad/31cdde3）
- [x] 全链路自测 + cross-check 首跑修 hook 5 逃逸（410b3cd）；infra-debug-playbook（4183ce2/1bf87ce）
- [x] agent 方案调研 + 记忆系统下钻 + Mem0 两轮实测不引入 + 分块模糊实装全实例（4dec625→ac502cd）
- [x] goal drift 调研 + recitation 进 task-brief（b6609a6）；goal-guard hook 挂 Codex+CC（cfb99eb）
- [x] Codex 机制层 debug：确认 Codex 支持 Stop hook,verify-guard/goal-guard 已挂

## 待做
- [ ] **Codex hook 格式确认**（下个 session 第一动作）：用户跑一次 Codex 后读 `~/.codex/verify-guard-stdin-capture.jsonl`,确认 stdin 格式（transcript_path/cwd/stop_hook_active 字段）;一致→删捕获器,不一致→写兼容层
- [ ] **verify-guard 引用语境误报修复**（第 3 例已现,cases/08）：条件式句式豁免;判据=hook_eval 拦截 11/11 不掉且新增引用用例转绿
- [ ] **L4 两周三指标回填**（metrics-log,基线 2026-07-26 起）+ KB 抽检第一轮（业务侧 /cross-check ≥3 条,错误率进 CHANGELOG）
- [ ] [核实] Trae Commands 面板 / CoCo hook 机制
- [ ] [挂起带判据] Mem0 试点（触发条件见 research-memory-systems-2026.md）

## 用户侧动作
- [ ] Codex 下次启动:允许新 hook 信任确认（两个 guard + 捕获器）
- [ ] 高价值任务派活姿势:/task-brief（判据入 TASK_GOAL.md）;Claude Code 另加 /goal 双保险
