---
name: unirev
description: 统一路由逆向工程与安全分析任务的四合一套件。收到 CTF、二进制/APK/PE/JS 逆向、恶意样本分析、软件拆解重建、版本对比类任务时使用：判断路由到 rea（深度分析）、craft-anything（编排重建）、open-reverselab（知识库+工具）还是 reverse-skill（技能模块），并强制执行授权门与证据沉淀规则。
metadata:
  version: "1"
---

# unirev 路由大脑

## 第 0 步：授权门（最高优先级）

读 `references/routing.json` 的 `gates`。若任务含主动攻击性质（爆破、利用、绕过、
破坏性操作）而用户尚未授权：停止，向用户索要明确授权并说明范围；授权后按
`vendors/reverse-skill/RULES.md` 的 0–14 步行为链执行。行为链与本路由表冲突时，
以授权门为准。

## 第 1 步：路由决策

对照 `references/routing.json` 的 routes[].signals 匹配任务信号，选主路由；
拿不准时按 `references/tool-matrix.md` 的能力地图选层。路由结果 = 主力工具 + 辅助工具 + 知识库。

各层调用方式：
- rea / craft-anything / reverse_lab_tools：MCP 工具直接调用（`mcp__rea__*` 等）。
- reverse-skill 技能模块与 open-reverselab KB：读对应 SKILL.md / kb 文章后再行动。

## 第 2 步：证据沉淀

按 `references/evidence-rules.md` 执行。一句话判断：跨阶段或要报告 → 开 CA 调查项目；
单阶段 → 直接干。

## 裁剪与上下文预算

工具过多时：rea 用 `REA_MCP_INPUT_SCHEMA_PROFILE=compact`；可选 MCP（Ghidra、JSHook）
只在需要时启用（见 `.mcp.optional.example.json` 由 open-reverselab 提供）。

## 健康检查

环境异常时运行 `pwsh scripts/install.ps1` 的自检部分，或逐个跑
`rea doctor`、`craft-anything-cli doctor`。
