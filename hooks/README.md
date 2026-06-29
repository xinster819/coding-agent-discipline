# hooks —— 机制层兜底（强约束，非靠自觉）

规则和 skill 是**强引导、非硬约束**（靠运行时召回生效，可被绕过）。hook 是这套包里**唯一能真正拦住**违规的一层——它在工具/运行时层面执行，不依赖模型自觉。

## verify-guard.py

**做什么**：作为 Claude Code 的 **Stop hook**，在一条回复结束前扫描它。若出现宪法【明令禁用的无证据断言】（如"修好了 / 应该没问题 / done! / X 不支持 Y"），而整条消息里**没有任何证据标记**（命令输出 / 代码块 / `file:line`）或【假设·未验证】标签，就**阻止结束**，要求补证据或改标假设后再收尾。

**诚实声明（重要）**：这是基于关键词的 **tripwire，不是 100% 保证**。它覆盖的是「已约定的禁用词契约」，拦不住所有幻觉。真正的依据仍是 `verify-before-claiming` / 完成铁律——hook 只是机制兜底。脚本 **fail-open**：自身任何异常都直接放行，绝不因 hook 故障卡住你。

**已实测**（`python3 verify-guard.py` 喂 5 个用例）：无证据"修好了"→拦；带代码块→放行；"Trae 不支持 SKILL.md"无证据→拦；带【假设】标→放行；`stop_hook_active` 防循环→放行。

**调触发面**：改 `verify-guard.py` 顶部的 `BANNED`（禁用词）/ `EXTERNAL`（外部能力断言正则）/ `EVIDENCE`（放行标记）三个列表。

---

## 安装

### Claude Code（已实测的目标）
在 `~/.claude/settings.json` 加 Stop hook（`setup.sh` 已把脚本放到 `~/.ai-coding-pack/hooks/`）：

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "python3 ~/.ai-coding-pack/hooks/verify-guard.py" }
        ]
      }
    ]
  }
}
```

> 命中时 Claude Code 会把 `reason` 回灌给模型并要求继续，直到改到合规或本轮 stop hook 不再触发。
> 官方 hooks 文档：https://code.claude.com/docs/en/hooks

### Trae / Codex
两者都有 hook 机制（Trae 设置侧栏有 **Hooks** 面板；Codex 有 hooks 配置）。

⚠️ **但它们的事件名 / 配置格式我尚未核实**——按本仓库这次的教训（别对外部工具当前行为凭记忆断言），这里**不写未经验证的配置**。要在 Trae/Codex 上装这个 guard，先对照各自官方 Hooks 文档确认"响应结束"类事件怎么配，或让我先查证再给你确切配置。脚本本身（读 stdin JSON、输出 block 决策）是通用的，可能需按各工具的 hook I/O 约定改一层适配。
