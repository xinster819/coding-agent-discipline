# 场景卡：业务咨询问答

**入口动作**
1. 在 `kb/ontology/answer_contracts.json` 找匹配的问题契约 → 按 evidence_chain 走到 final_evidence，用结果语言回答。
2. 无匹配契约 → `kb.py search <业务词>` 检索 docs/ 与 repos/；回答后**提议新增一条契约**（问题高频才收）。

**红线**：中间态 ≠ 答案；答不到最终结果就开头明说还差什么。
