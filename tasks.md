# tasks — coding-agent-discipline

> 首建于本 session。[x]=已完成并验证，[ ]=待做。

## 已完成（本 arc）
- [x] 融入 handoff 三件套 commands + behavior-audit 精华并入 challenge-me（commit 4a61566）
- [x] 纳入 KB 两件套 project-kb-production / project-kb-refresh（1edb9ad）
- [x] 加 /kb-init /kb-refresh 短别名（2073ac2）
- [x] 写 verify-guard hook 并实测 5 用例 + 挂进 .claude/settings.json（d71375b）
- [x] 强化外部声明纪律（二手文档/记忆不算验证）（d71375b）
- [x] 修正所有 "Trae 不支持 skill" 过时文档（d71375b）
- [x] 数据解读纪律：证伪优先 + 结果分布 + 反惊悚（aef488e）

## 待做
- [ ] **self-help-first 补"假边界 + 举证不可得"**（覆盖过度保守/偷懒侧）
  - 完成判据：self-help-first 假红灯清单加"'取不到/不支持'只试默认工具就宣布=假边界"；verify-before-claiming/AGENTS 加"宣布不可得也要贴穷尽了哪些路径"
  - 依赖：无。优先级最高（唯一已提出未实现的规则缺口）
- [ ] **核实 Trae 能否自动导入 commands/**
  - 完成判据：给出确证的路径/结论，更新 INSTALL.md + docs/trae-user-rules.md 里的"待核实"字样
  - 依赖：需在真实 Trae 里验证
- [ ] **核实 Codex 自定义 prompt/command 目录**
  - 完成判据：确证后在 setup.sh/INSTALL.md 去掉"按你的版本核实"，或确认无此机制
- [ ] **核实 Trae/Codex 的 hook 配置格式**，让 verify-guard 能在这两个工具挂上
  - 完成判据：hooks/README.md 补上确证的配置片段
- [ ] （可选）把 verify-guard 从纯 tripwire 增强为"带精确数字的定性结论无置信度标记则软提醒"，评估误报率

## 用户侧动作（非代码，提醒下个 session 转告）
- [ ] 用户重跑 `bash setup.sh` 让最新规则/skill 传到 ~/.ai-coding-pack（全局 + Trae）
- [ ] 用户新开 session 让 .claude/settings.json 的 verify-guard hook 生效，`/hooks` 确认
