# 安装指南（全局，所有项目生效）

四个工具都吃同一套开放标准——`SKILL.md` 目录靠 `description` 自动触发，规则走 `AGENTS.md`/`CLAUDE.md` 或各自的 rules 面板。Claude Code / Codex / CoCo 用全局 skill 目录；**Trae 也原生支持 Skills**（自动加载 `~/.agents/skills`，与 Codex 同目录），规则粘进 Rules & Memories。所以**一份规则 + 一套 skill 能驱动全部四个**，只是 Trae 的规则需粘一次。

## 最快路径：一键脚本

在本包根目录执行：

```bash
bash setup.sh
```

它会把本包复制到 `~/.ai-coding-pack`（单一真源），再从各工具全局目录符号链接过去，并打印 CoCo / Trae 的手动步骤。以后要改规则，**只改 `~/.ai-coding-pack/` 里的文件**，所有工具同步生效。

---

## 手动安装（想完全掌控时）

先把本包放到稳定位置，例如 `~/.ai-coding-pack/`（含 `AGENTS.md` 和 `skills/`）。

### 1. Claude Code
- **规则（全局）**：`ln -sfn ~/.ai-coding-pack/AGENTS.md ~/.claude/CLAUDE.md`
  （Claude Code 读 `~/.claude/CLAUDE.md`；也可在该文件首行写 `@~/.ai-coding-pack/AGENTS.md` 导入）
- **Skills（全局）**：把每个 skill 目录链接进 `~/.claude/skills/`：
  ```bash
  mkdir -p ~/.claude/skills
  for d in ~/.ai-coding-pack/skills/*/; do ln -sfn "$d" ~/.claude/skills/$(basename "$d"); done
  ```
- **Slash Commands（全局）**：把 handoff 三件套链接进 `~/.claude/commands/`：
  ```bash
  mkdir -p ~/.claude/commands
  for f in ~/.ai-coding-pack/commands/*.md; do ln -sfn "$f" ~/.claude/commands/$(basename "$f"); done
  ```
- 触发：skill 靠 `SKILL.md` 的 `description` 自动匹配，也可 `/skill-name` 显式调用；command 用 `/handoff-init`、`/handoff-resume`、`/handoff-save`。
- 官方文档：记忆 https://code.claude.com/docs/en/memory ｜Skills https://code.claude.com/docs/en/skills ｜Slash commands https://code.claude.com/docs/en/slash-commands

### 2. Codex
- **规则（全局）**：`ln -sfn ~/.ai-coding-pack/AGENTS.md ~/.codex/AGENTS.md`
- **Skills（全局）**：Codex 用 `~/.agents/skills/`（**注意不是 `.claude`**）：
  ```bash
  mkdir -p ~/.agents/skills
  for d in ~/.ai-coding-pack/skills/*/; do ln -sfn "$d" ~/.agents/skills/$(basename "$d"); done
  ```
- **Handoff（无 Claude Code slash 机制）**：用 `~/.ai-coding-pack/docs/handoff-prompts.md` 的可粘贴版（Prompt A/B/C）。若你的 Codex 版本支持自定义 prompt 目录，可把 `commands/*.md` 链接过去（**路径按你的版本核实**，本包不臆造）。
- 官方文档：AGENTS.md https://developers.openai.com/codex/guides/agents-md ｜Skills https://developers.openai.com/codex/skills

### 3. Snowflake CoCo（Cortex Code）
- **Skills**：CoCo 原生扫描 `~/.claude/skills/`——做完第 1 步即已生效，**无需额外操作**。（也可链接到 `~/.snowflake/cortex/skills/`。）
- **规则**：CoCo 的 `AGENTS.md` 是**工作区根目录**级别（没有全局 home 路径）。在每个项目根执行：
  `ln -sfn ~/.ai-coding-pack/AGENTS.md ./AGENTS.md`
  ⚠️ 该符号链接指向本机绝对路径，会被 git 跟踪。**把它加进 `.gitignore`**，或干脆复制一份项目自己的 `AGENTS.md`，免得 commit 进仓库后在同事机器上变成断链。
- 官方文档：扩展性 https://docs.snowflake.com/en/user-guide/cortex-code/extensibility

### 4. Trae（原生支持 Skills；规则走 Rules & Memories）
> 实测：当前 Trae 有 **Skills & Commands** 面板，并能自动加载 `~/.agents/skills`（与 Codex 同目录）。依据：用户的 Trae 设置截图 + 本机 `ls ~/.agents/skills` 确认 7 个软链接（检索于 2026-06-29）。
- **Skills（已自动覆盖）**：`setup.sh` 已把 7 个 skill 链接进 `~/.agents/skills`。在 Trae 设置 → **Skills & Commands**，打开「Enable .agents Skills Directory」开关，点 ↻ 刷新，即见 `verify-before-claiming` / `self-help-first` / `challenge-me` / `blindspot-scan` / `retro` / `project-kb-production` / `project-kb-refresh`，按需开关。靠 `description` 关键词自动触发。
- **规则（宪法）**：Trae 设置 → **Rules & Memories**，把 `docs/trae-user-rules.md` 分隔线之间的整段粘进 `user_rules`（= 宪法 + 改动前清单/非程序员模式两条增补）。或直接粘 `AGENTS.md`。
- **⚠️ 装前先删旧规则**：若 Trae 里已有别的 global rule（如自写的"防胡说八道协议"或 Superpowers 段），先删掉再粘，别两份重复协议并存（context rot）。
- **项目规则**：`.trae/rules/project_rules.md`（项目规则会覆盖个人规则）。
- **Handoff**：用 `docs/handoff-prompts.md` 的可粘贴 Prompt A/B/C。（Trae 有 Commands 面板，能否自动导入本包 `commands/` **尚未核实**，待确认；在此之前用可粘贴版最稳。）
- 官方文档：Rules https://docs.trae.ai/ide/rules

---

## handoff 三件套（项目跨 session 接力）

只有 Claude Code 有原生 slash command；其他工具用 `docs/handoff-prompts.md` 的可粘贴版。节奏是一个循环：

| 时机 | Claude Code | 兜底（Codex/Trae/CoCo） | 产出 |
|---|---|---|---|
| 项目首次接入 | `/handoff-init` | docs Prompt A | HANDOFF.md + tasks.md |
| 每次开工 | `/handoff-resume` | docs Prompt B | 读档对齐、plan 后开工 |
| 每次收工 / 上下文将满 | `/handoff-save` | docs Prompt C | 回写两份文件 |

> 想让某项目默认带上宪法+skill+handoff，跑 `bash install-into-project.sh /path/to/project`，把 `.claude/` 与 `CLAUDE.md` 一起 commit，团队共享。

---

## 代码库导航 KB（怎么调用）

`project-kb-production` / `project-kb-refresh` 是 skill，**两种方式都能用**：

- **直接 `/skill-name`**（Claude Code 装好的 skill 自动有 `/` 入口）：`/project-kb-production`、`/project-kb-refresh`，支持传参（如 `/project-kb-refresh 合并了 auth 模块` → `$ARGUMENTS`）。
- **短别名**（commands/ 里的薄包装，等效、更好敲）：`/kb-init`、`/kb-refresh`。
- **自动触发**：不敲命令时，靠 skill 的 `description` 关键词自动唤起（Codex/CoCo 无 `/` 自动入口，主要靠这条）。

---

## 可选：机制兜底 hook（强约束，不靠自觉）

规则/skill 是强引导、可被绕过；要真正拦住"无证据就报完成/凭印象断言外部能力"，配 `hooks/verify-guard.py`。它作为 **Claude Code Stop hook**，在回复结束前扫描，命中无证据断言就打回要证据（已实测 5 个用例）。

在 `~/.claude/settings.json` 加：
```json
{ "hooks": { "Stop": [ { "hooks": [ { "type": "command", "command": "python3 ~/.ai-coding-pack/hooks/verify-guard.py" } ] } ] } }
```
> 它是 tripwire 不是 100% 保证（覆盖已约定的禁用词契约）；fail-open，不会因 hook 故障卡住你。Trae/Codex 的 hook 事件名待核实，见 `hooks/README.md`，不臆造。

---

## 验证安装是否生效
挑一个真实任务跑一遍，检查：
1. **宪法生效**：让它做个会"想偷懒报完成"的小改动，看它是否坚持先跑验证、给证据。
2. **skill 触发**：说"这样改对吧"看是否触发 challenge-me 式反驳；说"复盘下"看是否走 retro。
3. **command 可见**（仅 Claude Code）：输入 `/` 应看到 `/handoff-init`、`/handoff-resume`、`/handoff-save`、`/kb-init`、`/kb-refresh`，以及 skill 自带入口如 `/project-kb-production`。
4. 不准就回到 `~/.ai-coding-pack/` 调 `description` 触发词或宪法措辞——这就是自进化回路。

> 注意：规则/skill 是**强引导而非硬约束**（靠运行时召回生效，可被绕过）。要"计划外文件被改就拦截"这类硬约束，需配各工具的 hook（Claude PreToolUse hook / CoCo hooks.json / Codex hooks）。
