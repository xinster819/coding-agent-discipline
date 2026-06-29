#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
verify-guard —— Claude Code Stop hook（tripwire，不是 100% 保证）。

作用：在一条回复结束前扫描它，如果出现了本仓库宪法【明令禁用的无证据断言】，
且整条消息里**没有任何证据标记**（命令输出 / 代码块 / file:line）或【假设·未验证】标签，
就阻止结束（decision: block），把控制权交回让模型补证据或改标假设后再收尾。

诚实声明（也是本 hook 自己要守的规矩）：
- 这是基于关键词的 tripwire，覆盖的是「已约定的禁用词契约」，**不可能拦住所有幻觉**。
  真正的依据仍是 verify-before-claiming / 完成铁律；hook 只是机制兜底。
- fail-open：脚本任何异常都直接放行（exit 0），绝不因 hook 自身故障卡住用户。
- 调触发面 / 加白名单：改下面 BANNED / EXTERNAL / EVIDENCE 三个列表即可。

安装见同目录 README.md。
"""
import json
import re
import sys

# —— 宪法明令禁用（无证据时不得出现）。命中其一即候选拦截。——
BANNED = [
    "should work", "probably", "seems to", "done!", "perfect!",
    "应该没问题", "应该可以", "基本没问题", "基本好了", "逻辑上肯定对",
    "修好了", "搞定了", "肯定没问题", "应该就好了", "妥了",
]

# —— 外部工具能力断言（X 支持/不支持 …）——这次踩坑的盲区，需工具名 + 能力动词同现 ——
EXTERNAL = re.compile(
    r"(trae|codex|claude\s*code|cocode|coco|cursor|copilot)"
    r"[^。\n]{0,16}?(不支持|不能|没有[^。\n]{0,8}机制|无法|才支持|原生支持|不读)",
    re.IGNORECASE,
)

# —— 证据/谦逊标记：出现任一即视为已附证据或已降级，放行 ——
EVIDENCE = [
    "【假设", "【未验证", "未验证", "我还没验证", "尚未验证", "没验证",
    "❓", "💭", "✅", "置信度", "退出码", "exit code", "检索于", "据我所知",
]
# file:line 形式（如 setup.sh:42）也算证据
FILELINE = re.compile(r"[\w./\-]+\.\w+:\d+")


def last_assistant_text(path):
    """读 transcript JSONL，取最后一条 assistant 消息的纯文本。"""
    text = ""
    try:
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except Exception:
                    continue
                if obj.get("type") == "assistant" or obj.get("role") == "assistant":
                    msg = obj.get("message", obj)
                    content = msg.get("content")
                    if isinstance(content, str):
                        text = content
                    elif isinstance(content, list):
                        text = "".join(
                            c.get("text", "")
                            for c in content
                            if isinstance(c, dict) and c.get("type") == "text"
                        )
    except Exception:
        return ""
    return text


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)  # 读不到输入：放行

    # 已经在 stop-hook 续跑里：别再拦，防死循环
    if data.get("stop_hook_active"):
        sys.exit(0)

    path = data.get("transcript_path")
    if not path:
        sys.exit(0)

    text = last_assistant_text(path)
    if not text:
        sys.exit(0)

    low = text.lower()

    # 有代码块 / 证据标记 / file:line → 已附证据，放行
    if "```" in text or FILELINE.search(text) or any(m.lower() in low for m in EVIDENCE):
        sys.exit(0)

    hits = [w for w in BANNED if w.lower() in low]
    if EXTERNAL.search(text):
        hits.append("外部工具能力断言（支持/不支持）")

    if hits:
        reason = (
            "⛔ verify-guard 拦截：回复里出现无证据的断言【"
            + "、".join(hits[:5])
            + "】，但整条消息没有任何证据标记（命令输出 / 代码块 / file:line）"
            "或【假设·未验证】标签。\n"
            "按完成铁律与 verify-before-claiming：要么**当场跑命令 / 查文件**并贴出证据，"
            "要么把该结论改标【假设·未验证】+ 置信度，然后再结束。\n"
            "（若确属误报：补一个证据标记 / 代码块即可放行；触发词列表在 hooks/verify-guard.py。）"
        )
        print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))
        sys.exit(0)

    sys.exit(0)


if __name__ == "__main__":
    main()
