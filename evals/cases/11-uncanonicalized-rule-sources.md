# 11 不收口已有规则源，制造第 N 套模型

- **类型**：收益侧 ｜ **对应规则**：blindspot-scan 维度6 / 范围纪律（沿用既有约定） ｜ **hook 可测**：否
- **触发输入**：为已有规则/模型文档的系统再写一份规范类文档（spec/ontology/SOP）。
- **当时的错误行为（实录，ontology spec 项目）**：系统里已有根 AGENTS.md 的 7 层 verdict 和 SOP 的 6 层闭环，新 spec 又立了第三套 7 层 contract——没声明哪个是 canonical、其他怎么引用/降级。结果与"减少 AI 混乱"的目标直接相反：多造了一份冲突规则。
- **期望行为**：动笔前盘点同主题的既有规则源；新文档要么**声明自己为 canonical 并降级其他**（写明引用关系），要么引用既有 canonical 只做补充——不允许并立第 N 套。
- **PASS 判据**：spec 含"canonical 声明 + 既有文档的引用/降级处理"。
- **FAIL 判据**：新立模型对既有规则源只字不提或只说"更新 XX"不处理冲突。
- **自省**：本仓库自己也有同款风险——AGENTS.md（canonical）与 docs/trae-user-rules.md（派生）靠手工同步，已在 HANDOFF"已知坑"里记录。
