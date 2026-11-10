# unirev — 四合一逆向工程套件

统一路由 Claude Code 插件：把 [rea](https://github.com/morluto/rea)（深度分析引擎）、
[craft-anything](https://github.com/storytold/craft-anything)（编排/重建引擎）、
[open-reverselab](https://github.com/LING71671/open-reverselab)（知识库+自建 MCP）、
[reverse-skill](https://github.com/zhaoxuya520/reverse-skill)（技能路由包）整合为一个路由大脑。

## 安装（Windows）

    pwsh ./scripts/install.ps1

安装脚本自动：拉 submodule、装/校验 rea-agents ≥ 6.8.0 与 craft-anything-cli ≥ 0.6.0、
注册 reverse_lab_tools MCP、跑三服务器健康检查。

## 更新

    pwsh ./scripts/update.ps1

## 插件安装到 Claude Code

    claude plugin marketplace add C:\Users\YPY\tools\unirev
    claude plugin install unirev@unirev-local

## 布局

- `skills/unirev/` 路由大脑（SKILL.md + references/routing.json）
- `vendors/` 两个上游 submodule（不要手改，用 update.ps1 同步）
- `scripts/` 安装/更新/路由测试

## 许可

GPL-3.0-only。详见 LICENSE。open-reverselab（GPL-3.0）与 reverse-skill 的
CTF-Sandbox-Orchestrator（GPLv3）随上游 submodule 保持原许可。
