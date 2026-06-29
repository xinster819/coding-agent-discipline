---
description: 建/重建本项目知识库（KB）——project-kb-production skill 的短别名入口
argument-hint: [可选：workspace_root / kb_root / 覆盖范围 / 数据源等输入]
---

为本项目建立或重建本地知识库（KB）。请使用 **project-kb-production** skill 的完整流程执行：

1. 先确认 Required Inputs：`workspace_root` / `kb_root` / `source_registry` /
   `document_sources` / `code_sources` / `verification_command`——**缺任何一项先停下来问，不要默认全仓库扫描**。
2. 显式覆盖边界（小而准的 registry 胜过大而噪）→ 文档与代码分管道索引 → 暴露稳定 `search` / `doctor` 入口。
3. 重建后**硬验证**：doctor 成功 + 对 2-3 个近期变更的文件名/符号实查能搜到（manifest 出现 ≠ 可搜到）。
4. 归档影响摘要（覆盖范围 / 重建命令 / 验证命令 / 索引规模 / 按设计排除项 / 剩余 gap）。

> 这是 `/project-kb-production` 的短别名；直接敲 `/project-kb-production` 等效。
> 刷新已有 KB 用 `/kb-refresh`。

补充输入 / 约束（可选）：$ARGUMENTS
