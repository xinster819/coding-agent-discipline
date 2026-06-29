---
description: 刷新本项目已有知识库（KB）——project-kb-refresh skill 的短别名入口
argument-hint: [可选：近期变更范围，如“合并了 auth 模块”]
---

刷新本项目已有知识库（KB）。请使用 **project-kb-refresh** skill 的完整流程执行：

1. 先定位近期变更**实际发生处**：多仓库/聚合目录别只跑根 `git status`，逐个相关子仓库看。
2. 映射变更到 KB 覆盖规则 → 重建受影响索引 → 重跑非默认 enrichment（glossary/business tag/graph/symbol，如项目依赖）。
3. `doctor` 验证 → 对变更的**文件名/符号/业务词实查 2-3 条**确认可搜到。
4. 写影响摘要。把"未覆盖（按设计）/ 应覆盖但快照旧 / 应覆盖但构建 bug"三种状态分清，别用一个解释套全部。

> 完成判据：**相关索引已重建** 且 **近期变更确实可被搜到**，两者都成立才算刷新完成，不止步于 manifest 更新。
> 这是 `/project-kb-refresh` 的短别名；直接敲 `/project-kb-refresh` 等效。本项目若还没有 KB，改用 `/kb-init`。

近期变更范围（可选）：$ARGUMENTS
