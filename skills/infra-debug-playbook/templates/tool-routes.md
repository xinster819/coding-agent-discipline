# tool-routes —— 任务 → 已验证命令（先查这里，再自己摸）

> 条目格式：`## 任务`＋已验证命令块＋`实测：YYYY-MM-DD ｜ 场景一句话`。
> 只有**真跑通过**的才能写"实测"；文档抄来的标【待实测】。命令报错→复核→修正原条目+留勘误行。

## 查 TCE 服务的 pod 状态 / 内存 / 实例分布
```bash
export BYTEDCLI_CLOUD_SITE=i18n-tt   # 海外站；国内不设
bytedcli tce instance list --service-id <SERVICE_ID> --no-pagination -j
# 返回 data.pods[]：pod_name / status / idc / containers[].cpu_usage_pct / mem_usage_pct
```
实测：2026-07-12 ｜ 拉某服务全部 2870 pod 判 OOM（status 分布 + mem top）；service_id 可由 `bytedcli apm service preview` 先查到。

## 查 RDS 业务表数据
```bash
bytedcli rds db query ...   # ⚠️ 正确入口是 rds，不是 db / dms（那两个入口试过，错）
```
实测：2026-07-15 ｜ 查审核申诉表；曾只试 dms/db 就误判"查不到"（evals/cases/13 实录）。地域看 pitfalls #3。

## 查服务概览 / 指标（apm）
```bash
bytedcli apm --vregion <Region> service preview ...   # --vregion 紧跟 apm
bytedcli apm grafana search <prefix> -j               # grafana search 不吃 --vregion，靠 env 站点
```
实测：2026-07-12 ｜ 指标名**不要盲猜前缀**（restart/oom 等盲搜全空），先从平台/看板确认真实指标名，见 pitfalls #4。

## （待补）Argos / 日志检索
【待实测】踩通后按上面格式回写：入口命令 + 地域参数 + 输出结构一句话。

## （待补）BMQ 消费组 / 积压
【待实测】
