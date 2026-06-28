---
name: project-kb-refresh
description: 当项目已有知识库（KB），但近期代码或文档变更可能还没反映到 search / onboarding / MCP 结果里，需要做"有验证的刷新 + 覆盖检查 + 影响摘要"时使用。当用户说"最近代码库有更新，检查 KB 有没有跟上 / 搜出来的还是旧的 / 新文件搜不到 / 开工前先把 KB 刷一下"时触发。核心：刷新只有在"相关索引已重建 + 近期变更确实可被搜到"两者都成立时才算完成，不止步于 manifest 更新。Use when an existing project knowledge base may be stale after code or document changes and needs a verified refresh, coverage check, and update summary. 首次建库用 project-kb-production；一次性 grep / 单文件查找不适用。
---

# Project KB Refresh

Use this skill when a project already has a knowledge base, but recent code or document changes may not yet be reflected in search, onboarding, or MCP results.

This skill is for refresh and verification work, not first-time KB construction. If the project does not yet have:

- a source registry
- a document or code index
- a stable search entrypoint
- a verification command

use `project-kb-production` first.

## When to Use

- A user says "最近代码库有更新，检查 KB 有没有跟上"
- Search results feel stale after recent merges
- A repo has new files that should be searchable
- An existing KB has to be rebuilt before a coding task or onboarding task
- You need a short, repeatable refresh workflow plus an archiveable impact summary

## When Not to Use

- The project has no KB yet
- The task is a single grep or one-off file lookup
- The user wants a design for a brand-new KB architecture

## Core Principle

A KB refresh is complete only when both are true:

1. the relevant index has been rebuilt
2. recently changed content is actually searchable

Do not stop at manifest updates alone.

## Required Inputs

Before refreshing, confirm these:

1. `workspace_root`
2. `kb_root`
3. `source_registry`
4. `verification_command`
5. `recent_change_scope`
6. `search_entrypoint`

If any input is missing, define it before running rebuild steps.

## Refresh Decision

Use this rule:

- if docs changed, rebuild document index
- if code changed, rebuild code index
- if routing quality depends on enrichment, rerun enrichment
- if graph artifacts depend on changed sources, rebuild graph separately

Do not blindly rebuild everything if the project has a good incremental chain. Do not skip targeted rebuilds if the current snapshot is stale.

## Standard Refresh Workflow

Run these steps in order:

1. identify where recent changes actually happened
2. map those changes to KB coverage rules
3. rebuild affected indexes
4. rerun non-default enrichment steps if required
5. run doctor or equivalent verification
6. run 2-3 real queries against recently changed paths, filenames, or symbols
7. write an update summary

## Coverage Check Rules

Before claiming a KB is stale or up to date, answer these questions:

1. Is the workspace root a real git repo, or a multi-repo aggregation directory?
2. Which child repos actually changed?
3. Are the changed paths inside current registry coverage?
4. Are they excluded by design, or missing unexpectedly?

Do not confuse:

- `not covered by design`
- `should be covered but old snapshot`
- `should be covered but indexer is broken`

Those are different states and need different actions.

## Quick Reference

- Check recent changes first.
- Compare changed files with registry coverage.
- Rebuild before you diagnose search quality.
- Run enrichment if the project relies on it.
- Doctor before summary.
- Query changed content directly after refresh.
- Archive what changed, what stayed excluded, and what still needs work.

## Hard Rules

### Rule 1: Verify the Repository Shape First

If the workspace contains multiple child repos, do not run one root `git status` and treat that as project truth.

Inspect each relevant repo or change source separately.

### Rule 2: Rebuild the Right Layer

If only docs changed, do not claim a code refresh was necessary.

If only code changed, do not claim docs are fresh unless you verified they were unaffected.

### Rule 3: Non-Default Enrichment Must Be Explicit

If search quality depends on extra steps such as:

- glossary injection
- business tag injection
- graph build
- symbol enrichment

document and rerun those steps explicitly. Do not assume the main index command already did them.

### Rule 4: Real Queries Are Mandatory

After refresh, run real search queries against recently changed content.

Good examples:

- changed filename
- changed symbol
- changed business term

Manifest-only validation is insufficient.

## Common Failure Modes

### Failure: Root `git status` Misleads the Refresh Decision

Symptom:

- workspace root is not the actual git repo
- recent changes are incorrectly judged as absent or unknown

Fix:

- detect whether the workspace is an aggregation directory
- inspect child repos directly

### Failure: Coverage Script Reports Impossible Missing Files

Symptom:

- coverage script says obvious indexed files are missing

Fix:

- read the manifest schema before scripting
- confirm where file entries really live
- validate the script against 2-3 known files first

### Failure: Refresh Succeeds But Business Search Gets Worse

Symptom:

- rebuild command exits successfully
- exact or business-language search quality drops

Fix:

- verify whether enrichment is outside the default refresh path
- rerun the documented enrichment step

### Failure: "Should Be Covered" Is Mixed Up With "Excluded by Design"

Symptom:

- user sees a changed file that is not searchable

Fix:

- classify it into one of:
  - excluded by registry
  - should be covered but stale snapshot
  - should be covered but build bug

Do not use one explanation for all three.

## Verification Checklist

Do not say "KB is updated" until you have fresh evidence for all relevant items:

- rebuild command exit code is `0`
- doctor or equivalent returns success
- changed content is searchable
- exclusions are explained as design, not hand-waving
- update summary is written

## Update Summary Template

Use this format after every refresh:

```text
KB refresh summary
- Scope:
- Rebuild commands:
- Enrichment commands:
- Verification command:
- Document index size:
- Code index size:
- Repos checked:
- Changed files now searchable:
- Excluded-by-design areas:
- Remaining gaps:
```

## Minimal Success Criteria

A KB refresh is minimally complete when:

- the relevant rebuild command succeeds
- doctor succeeds
- recent changed content is retrievable by search
- any exclusions are traceable to registry rules
- an update summary exists

## Relationship to Other Files

This skill works best when the target project also has:

- `AGENTS.md` documenting KB entrypoints and boundaries
- a registry file such as `source_registry.yaml`
- a machine-readable verification command like `doctor --json`
- a search entrypoint agents can call without internal path knowledge

## Final Reminder

Refreshing a KB is not "run one command and hope."

It is:

- identify change scope
- map to coverage
- rebuild
- rerun enrichment
- verify with doctor
- verify with real queries
- archive the impact

Stop only after all seven are done.

*依据：真实工程 KB 交付踩坑总结——刷新的硬规则「Real Queries Are Mandatory / Verify the Repository Shape First」与本仓库 verify-before-claiming 的完成铁律、self-help-first 的"先查证再下结论"同源。首次建库见 project-kb-production。*
