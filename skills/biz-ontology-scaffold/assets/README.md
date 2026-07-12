# __DOMAIN__-ontology — 业务知识库（人类入口）

架构与分期见 [SPEC.md](SPEC.md)；AI 使用规则见 [AGENTS.md](AGENTS.md)。

## 日常三条命令

```bash
python3 tools/kb.py search <词>     # 查任何东西
python3 tools/kb.py doctor          # 体检（退出码 0 = 健康）
./tools/refresh.sh                  # 手动触发一次全量刷新（sync+index+doctor+记录）
```

## 你怎么 review 更新

- 看 `CHANGELOG/<当月>.md`：每次刷新一条人话记录（哪些 repo 有新 commit、索引增减、体检结果、⚠️需人工关注项）。
- 建议节奏：每周扫一眼当月文件；看到 ⚠️ 再深入。

## 定时更新（确认后自行安装）

```
0 7,13,19 * * * cd __WORKSPACE__ && ./tools/refresh.sh >> .kb/cron.log 2>&1
```

## 加一个新代码仓库

在 `source_registry.json` 的 `repos` 里加 `{"name": "xxx", "git": "git@..."}` → `./tools/refresh.sh` → `kb.py search` 验证能命中它的文件（搜不到就不算接入）。
