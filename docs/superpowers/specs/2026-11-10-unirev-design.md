# unirev 四合一逆向工程套件 — 设计文档

日期：2026-11-10
状态：已获用户批准（架构方案 A）

## 1. 目标与范围

把四个上游项目整合为一个 Claude Code 插件（新仓库 `unirev`），提供统一的任务路由大脑：

| 上游 | 角色 | 许可 | 集成方式 |
|---|---|---|---|
| morluto/rea（rea-agents 6.8.0） | 深度分析引擎（native/managed/JS/Android/固件，230+ MCP 工具） | MIT | 外部依赖（npm） |
| storytold/craft-anything（v0.6.0） | 编排/重建引擎（Study→Build→Check 闭环、调查账本） | MIT OR Apache-2.0 | 外部依赖（release 二进制） |
| LING71671/open-reverselab | 知识库（180+ 篇）+ 自建 MCP（reverse_lab_tools 100+ 工具） | **GPL-3.0** | git submodule |
| zhaoxuya520/reverse-skill | 技能路由包（45+ 模块、R0–R45 路由、授权门） | MIT（CTF 子目录 GPLv3，保持子模块隔离） | git submodule |

**许可决定**：新仓库整体采用 **GPL-3.0**（用户已确认接受传染性）。
**同步策略**：依赖 + submodule（用户已确认），四个上游可各自更新。
**主要场景**：CTF 竞赛、APK/移动逆向、PE/Windows 逆向、Web/JS 逆向（用户已确认全选）。

## 2. 目录结构

```
unirev/                              # C:\Users\YPY\tools\unirev
├── .claude-plugin/plugin.json      # 插件清单 + mcpServers 注册
├── README.md
├── LICENSE                         # GPL-3.0
├── skills/
│   └── unirev/
│       ├── SKILL.md                # 统一路由大脑
│       └── references/
│           ├── routing.json        # 机器可读路由表
│           ├── tool-matrix.md      # 四仓库能力对照地图
│           └── evidence-rules.md   # 证据沉淀规则
├── vendors/
│   ├── open-reverselab/            # git submodule（GPL-3.0，含其 KB 与 MCP 代码）
│   └── reverse-skill/              # git submodule（MIT；其 GPLv3 子目录随上游保持原状）
└── scripts/
    ├── install.ps1 / install.sh
    ├── update.ps1 / update.sh
    └── route-test.ps1 / route-test.sh
```

## 3. 路由大脑设计

### 3.1 SKILL.md 职责

触发条件：逆向工程、CTF、二进制分析、APK 分析、JS 逆向、软件重建类任务。收到任务后按 routing.json 决策：**任务信号 → 主力工具 → 辅助工具 → 知识库**。

### 3.2 路由表（routing.json，初始版本）

| 任务信号 | 主力 | 辅助 | 知识库 |
|---|---|---|---|
| CTF web/密码/杂项 | reverse-skill CTF 子技能 | reverse_lab_tools（http_probe 等） | open-reverselab `kb/ctf-website` |
| 二进制 pwn/RE 题 | rea native 工具族（rizin/GDB/Frida） | reverse-skill pwn-chain | `kb/pe-reverse` |
| APK 拆解/脱壳/Hook | rea android 工具族（JADX/apktool/adb） | reverse-skill apk-reverse + mobile-reverse | `kb/apk-reverse` |
| PE/dotnet/反混淆 | rea native + managed 工具族 | reverse-skill dotnet-reverse | `kb/pe-reverse` |
| Web/JS 加密参数/Electron | rea javascript 工具族 | reverse-skill js-reverse；可选 JSHookLocal MCP | `kb/general` |
| 看懂并重建/版本对比 | craft-anything 闭环 | rea 作为分析提供器 | — |
| 跨阶段大任务（≥2 阶段或需报告） | craft-anything 调查账本承接 | 上述全部 | — |

新增场景只需改 routing.json，不改 SKILL.md 主体。

### 3.3 安全约束

继承 reverse-skill 的授权门：未经用户授权（consent 未 grant）禁止主动攻击行为；`work/<case>/scope.md` 未建立时禁止 ACT 类操作。提示注入防护沿用 reverse-skill 的 RULES.md。

## 4. MCP 注册与上下文预算

- `plugin.json` 的 mcpServers 注册三个服务器：`rea`（node + rea-agents）、`craft-anything`（CLI `mcp` 子命令）、`reverse_lab_tools`（Python/uv，指向 vendors/open-reverselab 内的 MCP 入口；确切启动命令在实施时以 open-reverselab 仓库自带的 `.mcp.json` 为准，不得自造）。
- rea 用 `REA_MCP_TOOL_FAMILIES` 支持按场景裁剪工具族；默认全开，SKILL.md 说明裁剪方法。
- 可选服务器（Ghidra MCP、JSHookLocal、IDA MCP 等）放 `.mcp.optional.example.json`，手动启用，不默认注册。
- 本机已全局注册 rea 与 craft-anything（`~/.claude.json`）；install 脚本检测到已有配置则跳过，避免重复。

## 5. 安装脚本 install.ps1 流程

1. 前置检查：git、Node ≥24、Python/uv、网络可达性。
2. `npm install -g rea-agents`（已装则校验版本 ≥ 6.8.0）。
3. craft-anything：检测 `tools/craft-anything-bin` 已有二进制则跳过；否则从 GitHub Releases 下载最新 v0.6.x Windows 版。
4. `git submodule update --init --recursive`。
5. reverse_lab_tools：`uv sync` 装依赖，运行 open-reverselab 自带的 `mcp_smoke_check`。
6. reverse-skill：运行其 `refresh-tool-index` 生成工具索引。
7. 健康检查：`rea doctor`、`craft-anything-cli doctor`，汇总输出体检报告。
8. 提示用户重启 Claude Code 会话使 MCP 注册生效。

`update.ps1`：`git submodule update --remote` + `npm update -g rea-agents` + 重新下载 CA 最新 release + 重跑健康检查。

## 6. 证据链约定（evidence-rules.md）

- 单阶段任务（一道 CTF 题、单函数反编译、单次 Hook）：直接用对应工具，不强制进 CA。
- 跨阶段任务（拆解→重建→比对）或需产出报告：路由器必须先开 craft-anything 调查项目（brief/plan/hypothesis/finding），rea 证据用 `export_evidence_bundle` 导入账本（`import_evidence_bundle`）。
- reverse_lab_tools 的产出（探测报告、YARA 结果）按 open-reverselab 的工件目录约定存放；跨项目环境快照用其 `~/.open-reverselab/env/env.md` 协议。

## 7. 测试与验收

1. **路由回归测试**（route-test.ps1）：≥20 条"任务描述 → 期望路由（主力/辅助/KB）"用例，覆盖四大场景 + 授权门拒绝路径。用例数据存 scripts/testdata/routes.json。
2. **MCP 冒烟测试**：三个服务器各发一次无害调用（rea `list_architectures`、CA `core_investigation_show`、reverse_lab_tools `kb_router`）。
3. **端到端演练**：安装完成后拿一个真实目标（用户提供）走一次完整流程作为验收。

## 8. 非目标（明确不做）

- 不复制/vendoring 任何上游代码进 unirev 本体（submodule 与外部依赖除外）。
- 不做统一的 GUI；不做 MCP 协议代理/聚合层（Claude Code 原生多服务器即可）。
- 不强制所有任务走 craft-anything 流程。
- 不修改上游 submodule 的内容（定制只发生在 unirev 层的路由/技能文件里）。
