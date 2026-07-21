#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
kb.py —— biz-ontology 的唯一查询/体检入口（零外部依赖，registry 驱动）。

  python3 tools/kb.py search <关键词> [--limit N]   # 跨 docs/repos/resources/kb 全文检索
  python3 tools/kb.py index                          # 重建 .kb/manifest.json（docs/code 分管道）
  python3 tools/kb.py doctor [--json]                # 体检；任何失败退出码非 0

硬约束：覆盖边界完全由 source_registry.json 决定——本文件不许硬编码任何源列表
（前车之鉴：registry 声明了、工具没读，spec 前提整个塌掉）。
"""
import json
import os
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REGISTRY = os.path.join(ROOT, "source_registry.json")
MANIFEST = os.path.join(ROOT, ".kb", "manifest.json")
TEXT_EXT = {".md", ".txt", ".json", ".yaml", ".yml", ".go", ".py", ".java", ".kt",
            ".ts", ".js", ".sql", ".sh", ".proto", ".thrift", ".toml", ".ini", ".conf"}
SKIP_DIRS = {".git", ".kb", "node_modules", "vendor", "target", "dist", "__pycache__"}


def load_registry():
    with open(REGISTRY, encoding="utf-8") as f:
        return json.load(f)


def iter_source_files(reg):
    """按 registry 遍历 (pipeline, 相对路径)。pipeline ∈ docs|code|resources|kb"""
    groups = [("docs", reg.get("document_sources", [])),
              ("code", reg.get("code_sources", [])),
              ("resources", reg.get("resource_sources", [])),
              ("kb", reg.get("kb_sources", []))]
    for pipeline, sources in groups:
        for src in sources:
            base = os.path.join(ROOT, src["path"])
            if not os.path.isdir(base):
                continue
            for dirpath, dirnames, filenames in os.walk(base):
                dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
                for fn in filenames:
                    if os.path.splitext(fn)[1].lower() in TEXT_EXT:
                        yield pipeline, os.path.relpath(os.path.join(dirpath, fn), ROOT)


GLOSSARY = os.path.join(ROOT, "kb", "ontology", "glossary.json")


def expand_terms(term):
    """业务词典扩展：用户的业务语言 → 代码/资源真实符号。词典缺失时静默退化为原词。"""
    terms, tl = [term], term.lower()
    try:
        with open(GLOSSARY, encoding="utf-8") as f:
            for e in json.load(f).get("terms", []):
                names = [e.get("term", "")] + e.get("aliases", []) + e.get("code_refs", [])
                names = [n for n in names if n and not n.startswith("TODO")]
                if any(tl in n.lower() or n.lower() in tl for n in names):
                    terms += names
    except (OSError, ValueError):
        pass
    seen, out = set(), []
    for t in terms:
        if t.lower() not in seen:
            seen.add(t.lower())
            out.append(t)
    return out


def cmd_search(term, limit=30):
    reg = load_registry()
    terms = expand_terms(term)
    if len(terms) > 1:
        print(f"（词典扩展：{' | '.join(terms)}）")
    lowers = [t.lower() for t in terms]
    hits = 0
    for _, rel in iter_source_files(reg):
        try:
            with open(os.path.join(ROOT, rel), encoding="utf-8", errors="ignore") as f:
                for i, line in enumerate(f, 1):
                    ll = line.lower()
                    if any(t in ll for t in lowers):
                        print(f"{rel}:{i}: {line.strip()[:160]}")
                        hits += 1
                        if hits >= limit:
                            print(f"\n(已达上限 {limit}，可 --limit 调大)")
                            return 0
                        break  # 每文件只报首个命中行，防刷屏
        except OSError:
            continue
    if hits:
        print(f"\n共 {hits} 个文件命中")
        return 0
    # 0 命中 → 模糊兜底：2 字滑窗词元重叠排序（自然语言问句场景；实测 Recall@3 12/13,
    # 与 Mem0+bge-small-zh 语义检索打平——见 docs/research-memory-systems-2026.md 基准）。
    # 只扫 docs/resources/kb 管道（知识文档），不扫 code（量大且问句场景不需要）。
    def _shingles(s):
        s = "".join(ch for ch in s.lower() if ch.isalnum() or "一" <= ch <= "鿿")
        return {s[i:i + 2] for i in range(len(s) - 1)}
    qs = _shingles(term)
    if qs:
        scored = []
        for pipeline, rel in iter_source_files(reg):
            if pipeline == "code":
                continue
            try:
                with open(os.path.join(ROOT, rel), encoding="utf-8", errors="ignore") as f:
                    txt = f.read()
                # 分块打分取最大：大文档答案在深处也能命中（真实库实测 Recall@3 14/14，唯一全对）
                best = 0
                for j in range(0, min(len(txt), 60000), 1500):
                    ov = len(qs & _shingles(txt[j:j + 1800]))
                    if ov > best:
                        best = ov
                if best:
                    scored.append((best, rel))
            except OSError:
                continue
        scored.sort(reverse=True)
        if scored:
            print(f"0 精确命中，模糊匹配（词元重叠）top{min(5, len(scored))}：")
            for ov, rel in scored[:5]:
                print(f"  ~ {rel}  (重叠度 {ov})")
            return 0
    print(f"0 命中 '{term}'（① 检查覆盖：source_registry.json；② 业务词请在 kb/ontology/glossary.json 补映射；③ 把本次未命中记入 kb/question_log.md）")
    return 1


def cmd_index():
    reg = load_registry()
    counts, files = {}, {}
    for pipeline, rel in iter_source_files(reg):
        counts[pipeline] = counts.get(pipeline, 0) + 1
        files.setdefault(pipeline, []).append(rel)
    os.makedirs(os.path.dirname(MANIFEST), exist_ok=True)
    with open(MANIFEST, "w", encoding="utf-8") as f:
        json.dump({"built_at": time.strftime("%Y-%m-%d %H:%M:%S %z"),
                   "counts": counts, "files": files}, f, ensure_ascii=False, indent=1)
    print("index 完成:", json.dumps(counts, ensure_ascii=False) or "{}（registry 尚无有效源）")
    return 0


def cmd_doctor(as_json=False):
    checks = []

    def add(name, ok, detail):
        checks.append({"check": name, "ok": bool(ok), "detail": detail})

    # 1. registry 可加载且有源
    try:
        reg = load_registry()
        n_src = sum(len(reg.get(k, [])) for k in
                    ("document_sources", "code_sources", "resource_sources", "kb_sources"))
        add("registry_loads", True, f"{n_src} 个已注册源")
        add("registry_nonempty", n_src > 0, "覆盖边界为空——先在 source_registry.json 注册源" if n_src == 0 else "OK")
    except Exception as e:
        add("registry_loads", False, str(e))
        reg, n_src = {}, 0

    # 2. repos：registry 里的每个 repo 已 clone 且是 git 仓库
    repos = reg.get("repos", [])
    missing = [r["name"] for r in repos
               if not os.path.isdir(os.path.join(ROOT, "repos", r["name"], ".git"))]
    add("repos_cloned", len(repos) > 0 and not missing,
        f"registry {len(repos)} 个 repo，未 clone: {missing or '无'}" if repos else "registry 尚未登记任何 repo")

    # 3. manifest 存在且 24h 内新鲜
    if os.path.isfile(MANIFEST):
        age_h = (time.time() - os.path.getmtime(MANIFEST)) / 3600
        with open(MANIFEST, encoding="utf-8") as f:
            m = json.load(f)
        total = sum(m.get("counts", {}).values())
        add("index_fresh", age_h < 24, f"{age_h:.1f}h 前构建，共 {total} 文件")
        add("index_nonempty", total > 0, m.get("counts", {}))
    else:
        add("index_fresh", False, "无 manifest——先跑 kb.py index")
        add("index_nonempty", False, "无 manifest")

    # 4. 关键文件在位
    for f_ in ("AGENTS.md", "kb/ontology/answer_contracts.json",
               "kb/ontology/glossary.json", "kb/question_log.md"):
        add(f"exists:{f_}", os.path.isfile(os.path.join(ROOT, f_)), "")

    ok_all = all(c["ok"] for c in checks)
    if as_json:
        print(json.dumps({"ok": ok_all, "checks": checks}, ensure_ascii=False, indent=1))
    else:
        for c in checks:
            print(f"  [{'✅' if c['ok'] else '❌'}] {c['check']}  {c['detail']}")
        print(f"\ndoctor: {'全部通过' if ok_all else '有失败项（见 ❌）'}")
    return 0 if ok_all else 1


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return 2
    cmd = args[0]
    if cmd == "search" and len(args) >= 2:
        limit = int(args[args.index("--limit") + 1]) if "--limit" in args else 30
        return cmd_search(args[1], limit)
    if cmd == "index":
        return cmd_index()
    if cmd == "doctor":
        return cmd_doctor("--json" in args)
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main())
