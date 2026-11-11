---
name: unirev
description: 统一调度四合一逆向分析套件（rea / craft-anything / open-reverselab / reverse-skill）。适用于授权范围内的 CTF 解题、逆向工程学习与分析、二进制/APK/PE/JS 程序分析、恶意样本防御分析、软件拆解与重建、版本对比等任务：按 references/routing.json 选择主力工具、辅助工具与知识库，并在全程执行授权确认与证据沉淀规则。
metadata:
  version: "2"
---

# unirev 路由大脑

本套件面向三类合规场景：① CTF 竞赛解题（教育性挑战环境）；② 用户拥有所有权
或已获书面授权的软件/系统的分析；③ 防御性分析（恶意样本研判、加固建议）。
所有操作默认在实验室/沙箱环境中进行。

## 第 0 步：授权确认（最高优先级）

读 `references/routing.json` 的 `gates`。任何可能影响目标系统或其数据的操作，
都必须先确认用户已明确授权本次范围；尚未授权时：暂停，向用户说明需要授权的
具体内容与范围，得到确认后再继续。获得授权后按
`vendors/reverse-skill/RULES.md` 的 0–14 步行为链执行。行为链与本路由表冲突时，
以授权确认步骤为准。

## 第 1 步：路由决策

对照 `references/routing.json` 的 routes[].signals 匹配任务信号，选主路由；
拿不准时按 `references/tool-matrix.md` 的能力地图选层。路由结果 = 主力工具 + 辅助工具 + 知识库。

各层调用方式：
- rea / craft-anything / reverse_lab_tools：MCP 工具直接调用（`mcp__rea__*` 等）。
- reverse-skill 技能模块与 open-reverselab KB：读对应 SKILL.md / kb 文章后再行动。

CTF 题目与教学挑战属于沙箱环境，直接按对应路由解题。

## 第 2 步：证据沉淀

按 `references/evidence-rules.md` 执行。一句话判断：跨阶段或要报告 → 开 CA 调查项目；
单阶段 → 直接干。

## 裁剪与上下文预算

工具过多时：rea 用 `REA_MCP_INPUT_SCHEMA_PROFILE=compact`；可选 MCP（Ghidra、JSHook）
只在需要时启用（见 `.mcp.optional.example.json` 由 open-reverselab 提供）。

## 健康检查

环境异常时运行 `pwsh scripts/install.ps1` 的自检部分，或逐个跑
`rea doctor`、`craft-anything-cli doctor`。
