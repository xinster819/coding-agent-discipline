---
name: hypothesis-ledger
description: 长周期 / 跨多 session 的系统稳定性、性能、代码质量根因深挖流程——用"假设账本"把每个异常当【假设】逐条走完整证据链推到 CONFIRMED/REJECTED，每 session 只挖 1-2 条挖到底、不广撒网，配跨会话状态文件（hypotheses/findings/todo/data_sources）。当用户说"慢慢挖 / 挖到底 / 别急着下结论 / 开个假设账本 / 做长周期稳定性分析 / 这堆异常逐个证伪"，或面对一坨待查异常、需要多轮推进而非一次给答案时使用。Use for long-horizon, multi-session root-cause investigations where evidence closure matters more than speed. 一次性小 bug、单点问答、当场能查完的问题不适用（直接走 verify-before-claiming / 系统排查即可）。建立在 verify-before-claiming 的"源优先/证伪"之上，只负责把深挖组织成可跨 session 推进的账本。
---

# hypothesis-ledger：假设账本（长周期深挖）

## 何时触发
- 长周期（跨多 session / 数小时~数天）的系统稳定性、性能、代码质量根因深挖
- 一坨异常现象堆在一起，需要逐个证伪、不能广撒网开一堆浅坑
- 用户说"慢慢挖 / 挖到底 / 别急着下结论 / 开个假设账本 / 我不着急要结果"

> 不适用：一次性小 bug、单点问答、当场就能查完的 → 直接用 `verify-before-claiming`。
> 分工：`verify-before-claiming` 管"单条声明是否有证据"；本 skill 管"多条假设跨 session 推进到底"。不重复前者的源优先/证伪，只加账本机器。

## 姿态
**证据闭环 > 速度。** 任何异常先当【假设】，不当已知结论。慢下来，把 1-2 条挖穿，胜过 10 条各挖一铲。

## 状态文件（跨 session 记忆，每次 session 必读必更）
- **hypotheses.md**：假设账本（核心）。每条：`id` / 一句话假设 / `status`（UNCONFIRMED·CONFIRMED·REJECTED）/ evidence（证据链每步）/ 缺口
- **findings.md**：只放已 CONFIRMED 的结论
- **todo.md**：下次待挖清单 + 本次卡点
- **data_sources.md**：取数手册——拉什么数据、跑什么命令、口径是什么（你的环境用什么就写什么：bytedcli / Prometheus / Grafana / SQL…）

## 硬规则（不可违反）
1. 观测到的任何异常 → 先写成 hypotheses.md 一条，`status=UNCONFIRMED`。
2. **UNCONFIRMED 不许进最终报告的"结论"章节。**
3. 每条假设必须走完**整证据链**：观测数据（metrics/log/trace）→ 关联到具体代码/配置（`file:line`）→ 定位根因 → 验证根因成立。任一步做不到，就在 evidence 里显式标 `[ ] 未确认：还差什么数据/代码`，**不跳过、不脑补**。
4. **每 session 只深挖 1-2 条，挖到底**，不广撒网。
5. 数据敏感结论（延迟/错误率/计数等）现拉数据佐证，标**取数时间 + 口径**；单计数不定性，看结果分布（承 verify-before-claiming 的证伪）。

## 深挖触发（带着推测继续 = 违规）
- 出现"看着能解释但没验证"的推测 → **停下来拉数据/读代码验证**，不能带着推测往下走。
- metrics 尖刺 → 对齐时间轴，找同时刻的 log/trace/发布事件/定时任务，不能只描述现象。
- 代码里的可疑写法 → 回到线上指标确认它是否**真的**造成了问题，不做静态臆断。

## 假设生命周期
`UNCONFIRMED` →（证据链走通）`CONFIRMED` /（被证伪）`REJECTED`。
REJECTED 也留档、写清为什么被否——防止下次重复挖同一条。

## 收口自评（每个 session 结束前必答）
- 这次把哪条假设从 UNCONFIRMED 推到了 CONFIRMED / REJECTED？
- **一条都没推动 = 本次 session 无效** → 在 todo.md 记录卡在哪、缺什么数据/权限/代码。
- **结案门禁（宣布"完成/无遗留/全部闭环"前必过）**：对账本/todo 里**每个 open 项**逐条自问"剩余预算（loop 数/时间/用户授权）内可解吗"——**可解而未解，不许写"无遗留"**（实录：14/100 loop 时写"无遗留待商议项"，账本里躺着一次查询就能解的缺口——虚假完备声明）。真不可解的，标"不可解原因 + 需要什么才能解"。

## 输出骨架（写结论时）
```
【结论】先正面回答用户问的那件事（成/败/是/否/数值，用人话）
【证据】证据链逐步：数据 → file:line → 根因 → 验证
【最脆弱的假设】这条结论最可能错在哪
【置信度】高/中/低 + 一句依据
```

## 红线
- 不把 UNCONFIRMED 当结论；不为了"结案"把假设硬凑成 CONFIRMED。
- 尖刺/异常必对齐时间轴，不只描述现象。
- 可疑代码必回线上指标确认，不静态臆断。
- 删/改状态文件外的东西前守范围纪律；数据敏感值不脑补。

*依据：提炼自用户实战的"长周期系统分析深挖协议"；与 verify-before-claiming（源优先/证伪，单条声明）、blindspot-scan（系统性风险扫描）、retro（阶段复盘）互补——本 skill 专管"多 session 假设账本推进"。*
