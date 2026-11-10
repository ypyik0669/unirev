# unirev 四仓库能力对照地图

| 层 | 工具 | 定位 | 强项 | 调用入口 |
|---|---|---|---|---|
| 深度分析引擎 | rea | 单点强拆 | native 反编译/rizin/GDB/Frida、.NET/IL2CPP、Electron/JS 源码恢复、Android(JADX/apktool/adb)、固件/pcap/WASM | `mcp__rea__*`（约 230 工具，可 REA_MCP_TOOL_FAMILIES 裁剪） |
| 编排重建引擎 | craft-anything | 全流程闭环 | Study→Build→Check→Ready、调查账本(brief/plan/hypothesis/finding)、自动重建校验 | `mcp__craft-anything__*`（17 toolset） |
| 知识库+执行工具 | open-reverselab | 方法论+自建 MCP | 180+ 篇 KB(ctf-website/apk/pe/windows/general)、http_probe/Ghidra headless/YARA | `mcp__reverse_lab_tools__*` + 直接读 `vendors/open-reverselab/kb/` |
| 技能路由包 | reverse-skill | 广度技能模块 | 45+ 模块(apk/dotnet/js/pwn/malware/固件…)、授权门 RULES.md | 直接读 `vendors/reverse-skill/skills/<模块>/SKILL.md` |

去重原则：同一能力 rea 优先（工程化更强、证据带 confidence/coverage/limitations）；
open-reverselab 的工具在 rea 未覆盖时使用（如 http_probe、YARA、Ghidra headless）；
方法论问题先查 KB 再动手。
