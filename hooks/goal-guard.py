#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
goal-guard —— /goal 的确定性等价物（Stop hook，Claude Code 与 Codex 通用）。

机制（opt-in，普通会话零影响）：
  1. 高预算任务开工时（/task-brief 流程），agent 在项目根写 TASK_GOAL.md，
     完成判据用 checkbox 格式：`- [ ] 判据…`；
  2. 本 hook 在每次回合结束时检查该文件：仍有未勾选项 `- [ ]` 且无
     【尽力未得】章节 → block（不许收工，继续干或按举证格式收尾）；
  3. 出口：全部勾成 `- [x]`，或写入【尽力未得】段（已试清单+剩余项），
     或把 TASK_GOAL.md 改名/删除（显式放弃任务）。
防死循环：stop_hook_active=true 时放行；文件不存在放行；fail-open。
"""
import json
import os
import sys


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)
    if data.get("stop_hook_active"):
        sys.exit(0)

    cwd = data.get("cwd") or os.environ.get("PWD") or os.getcwd()
    path = os.path.join(cwd, "TASK_GOAL.md")
    if not os.path.isfile(path):
        sys.exit(0)
    try:
        with open(path, encoding="utf-8") as f:
            txt = f.read()
    except OSError:
        sys.exit(0)

    open_items = [ln.strip() for ln in txt.splitlines() if ln.strip().startswith("- [ ]")]
    if not open_items:
        sys.exit(0)                     # 判据全绿 → 放行
    if "【尽力未得】" in txt:
        sys.exit(0)                     # 已按举证格式收尾 → 放行

    reason = (
        "⛔ goal-guard：TASK_GOAL.md 还有 "
        + str(len(open_items))
        + " 条判据未完成：\n  "
        + "\n  ".join(open_items[:5])
        + ("\n  …" if len(open_items) > 5 else "")
        + "\n继续推进；每完成一条把 `- [ ]` 改为 `- [x]`（复诵纪律）。"
        "确实做不完的，在 TASK_GOAL.md 里写【尽力未得】段（已试清单+报错+剩余未试项）后方可收工。"
    )
    print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))
    sys.exit(0)


if __name__ == "__main__":
    main()
