---
name: project-kb-production
description: 为软件项目（尤其多仓库 / 大目录）搭建或重建本地知识库（KB），让 agent 与新人能稳定找到 repo 入口、稳定规则、测试命令、核心流程、业务背景、关键代码符号。当用户说"建知识库 / 搭 KB / agent 老是在仓库里迷路 / 规则散在 AGENTS.md 与文档里找不到 / 要一套可重复的重建+验证流程"时使用。强调显式覆盖边界、文档与代码分管道索引、稳定 search/doctor 入口、短重建链、每次刷新后硬验证。Use when creating or rebuilding a project knowledge base so agents can navigate repos, rules, docs, and code through explicit coverage, verification, and update workflows. 仅刷新已有 KB 用 project-kb-refresh；不适用于在线 RAG / 检索服务。
---

# Project KB Production

Use this skill when you need to build a reusable local knowledge base for a software project, or when an existing knowledge base must be updated after code and document changes.

This skill is for engineering knowledge bases that help agents and new contributors find:

- repo entry points
- stable rules
- test commands
- core workflows
- business background
- important code symbols

This skill is not for production RAG systems, online serving, or "index everything first" experiments.

## When to Use

- A project has multiple repos or large directories and agents keep getting lost.
- Rules live in `AGENTS.md`, `CLAUDE.md`, `README.md`, or design docs, but agents do not reliably find them.
- The team wants a local-first KB for navigation and onboarding.
- The project already has a KB, but recent code or document changes may not be reflected in search results.
- You need one repeatable command chain for rebuild + verify + archive, not ad hoc searching.

## When Not to Use

- The task is a one-off grep question inside a tiny repo.
- The project has no stable docs, no stable directory boundaries, and no willingness to maintain a registry.
- The real need is an online product search system with ranking, serving, permissions, and user traffic.

## Core Principle

Treat a project KB as an engineering navigation system, not a magic search box.

Quality comes from:

1. explicit source boundaries
2. separate document and code indexing
3. stable search and doctor entrypoints
4. repeatable rebuild workflows
5. hard verification after every refresh

If those five are weak, better ranking will not save the KB.

## Required Inputs

Before building anything, confirm these inputs:

1. `workspace_root`
2. `kb_root`
3. `source_registry`
4. `document_sources`
5. `code_sources`
6. `verification_command`

If any input is missing, stop and define it first.

## Recommended Layout

Use a minimal structure like this:

```text
<repo>/
  .trae/
    skills/
      project-kb-production/
        SKILL.md
  <kb-root>/
    README.md
    AGENTS.md
    source_registry.yaml
    lark_sources.json            # only if external docs need fetch
    docs/
    src/
    tools/
    .kb/
```

## Build Strategy

### 1. Start with Explicit Coverage

Do not scan the whole project by default.

Create a source registry that explicitly lists:

- document sources
- code sources
- include patterns
- exclude patterns
- language or source type

Prefer a small accurate registry over a huge noisy registry.

### 2. Split Document and Code Pipelines

Use different pipelines for:

- documents: headings, sections, curated docs
- code: files, symbols, packages, modules

Do not merge them into one build step unless the project is truly tiny.

### 3. Keep One Stable Query Surface

Even if the implementation has multiple query paths, give agents one obvious entry:

- `search`
- `onboarding`
- `doctor`
- optional MCP tool

Agents should not need to know internal filenames to use the KB.

## Default Workflow

Follow this order unless the project has a better proven chain:

1. confirm registry and source-of-truth files
2. rebuild document index if docs changed
3. rebuild code index if code changed
4. run extra enrichment steps if the project depends on them
5. run doctor or equivalent verification
6. run 2-3 real search queries against recently changed content
7. archive the impact summary

## Update Modes

### New KB

Use this sequence:

1. define source registry
2. build document index
3. build code index
4. expose search entrypoint
5. add onboarding presets
6. add doctor command
7. verify with real queries

### Existing KB Refresh

Use this sequence:

1. inspect recent repo changes
2. map changed files to KB coverage
3. rebuild only affected indexes if incremental build exists
4. rerun enrichment if required
5. run doctor
6. verify that recent changes are actually searchable

## Quick Reference

- Small accurate registry beats large noisy registry.
- Documents and code should have different chunking logic.
- Always expose one search command and one doctor command.
- Rebuild first, then verify, then summarize.
- Treat enrichment steps as first-class build stages if search quality depends on them.
- Search for 2-3 changed symbols or filenames after refresh; manifest-only checks are not enough.

## Hard Rules

### Rule 1: Coverage Must Be Explicit

If a repo, directory, or file type is not registered, do not assume the KB covers it.

### Rule 2: Verification Before Claims

Never say the KB is "updated" until a fresh verification command succeeds.

Acceptable evidence includes:

- successful doctor JSON
- successful rebuild output
- successful sample queries against changed files

### Rule 3: Searchability Beats Metadata

A file appearing in a manifest is not enough.

You must also prove at least one real query can retrieve recently changed content.

### Rule 4: Write Down Non-Default Steps

If the KB needs extra enrichment such as:

- glossary injection
- business tag injection
- graph build
- symbol routing

do not hide that in tribal knowledge. Put it in the KB `AGENTS.md`.

## Common Failure Modes

### Failure: Root Directory Is Not the Git Repo

Symptom:

- `git status` fails at the workspace root

Fix:

- verify whether the workspace is a multi-repo aggregation directory
- inspect child repos separately before drawing conclusions about "recent changes"

### Failure: Registry Says Covered, But Search Still Misses

Symptom:

- a file matches include patterns but does not show up in search

Fix:

- rebuild the relevant index
- inspect the current manifest snapshot
- run a real query for the changed filename or symbol

### Failure: Manifest Structure Is Misread

Symptom:

- custom coverage scripts report impossible results

Fix:

- read the manifest schema before scripting
- confirm whether file entries are top-level or nested under a field like `files`
- sample 2-3 known paths first before running large comparisons

### Failure: Default Build Misses Ranking Enrichment

Symptom:

- rebuild succeeds but business-language routing quality drops

Fix:

- identify whether enrichment is outside the default chain
- add the enrichment step to the documented refresh workflow

## Archive Template

After every KB refresh, record:

```text
KB update summary
- Scope:
- Rebuild commands:
- Verification command:
- Document index size:
- Code index size:
- Changed repos checked:
- Recently changed files now searchable:
- Excluded-by-design areas:
- Remaining gaps:
```

## Minimal Success Criteria

A project KB is minimally healthy when all of these are true:

- source registry loads
- document index exists or is intentionally absent
- code index exists or is intentionally absent
- doctor or equivalent returns success
- at least one repo rule file is searchable
- at least one recent code change is searchable
- the refresh summary is archived

## Recommended Companion Files

This skill works best when the target project also has:

- `<kb-root>/README.md` for humans
- `<kb-root>/AGENTS.md` for agents
- a registry file such as `source_registry.yaml`
- a machine-readable verification command such as `doctor --json`

## Final Reminder

The winning pattern is not "better embeddings first."

The winning pattern is:

- explicit boundaries
- stable entrypoints
- short rebuild chain
- hard verification
- written maintenance rules

Build the KB like infrastructure, not like a demo.

*依据：真实工程 KB 交付踩坑总结——赢在「显式覆盖边界 + 文档/代码分索引 + 稳定 search/doctor 入口 + 短重建链 + 硬验证」，而非「更好的 embedding」。其中 Rule 2「Verification Before Claims」与本仓库 verify-before-claiming 的完成铁律同源；刷新场景见 project-kb-refresh。*
