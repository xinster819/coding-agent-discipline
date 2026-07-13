# 场景卡：业务咨询问答

**入口动作**
1. 在 `kb/ontology/answer_contracts.json` 找匹配的问题契约 → 按 evidence_chain 走到 final_evidence，用结果语言回答。
2. 无匹配契约 → `kb.py search <业务词>`（词典自动扩展；业务词搜不到先补 `kb/ontology/glossary.json` 再搜）。
3. **回答后必登记 `kb/question_log.md`**（答准与否都记；不准的写清差在哪）——这是 KB 适配用户提问的唯一生长回路，"经验只写在对话里"=丢失。

**红线**：中间态 ≠ 答案；答不到最终结果就开头明说还差什么；验收提问不登记台账 = 验收无效。
