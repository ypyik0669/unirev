# unirev 证据沉淀规则

1. 单阶段任务（一道 CTF 题、单函数反编译、单次 Hook）：直接用对应工具，不强制进 craft-anything。
2. 跨 ≥2 阶段（拆解→重建→比对）或需产出报告：必须先 `core_investigation_show` 查看状态，
   用 `core_brief_write`/`core_plan_update` 建调查记忆，再开工。
3. rea 的证据用 `export_evidence_bundle` 导出，在 CA 侧 `import_evidence_bundle` 入账本；
   CA 结论回写用 `core_finding_record`（引用证据 id）。
4. open-reverselab 的产物按其工件目录约定存放（samples/exports/reports/）；
   跨项目环境快照走其 `~/.open-reverselab/env/env.md` 协议（7 天过期、敏感值脱敏）。
5. 任何结论必须区分 observation（有证据 id）与 inference（推理），未决问题用
   `core_unknown_add` 记录。
