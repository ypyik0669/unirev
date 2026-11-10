#Requires -Version 7
$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
$report = @()
function Note($status, $msg) { $script:report += "[$status] $msg"; Write-Host "[$status] $msg" }

# 1) submodule
git -C $root submodule update --init --recursive 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0 -and (Test-Path "$root/vendors/open-reverselab/kb")) { Note 'OK' 'submodules present' }
else { Note 'FAIL' 'submodules missing; check network/git' }

# 2) rea-agents（≥6.8.0）：优先读 ~/.claude.json 中 rea 注册的 rea.mjs → package.json（nvm 多版本下 npm 全局未必可见），否则退回 npm 全局查询
$rea = ''
$claudeJsonProbe = "$env:USERPROFILE\.claude.json"
try {
  if (Test-Path $claudeJsonProbe) {
    $reaMjs = ((Get-Content $claudeJsonProbe -Raw | ConvertFrom-Json -AsHashtable).mcpServers.rea.args |
      Where-Object { $_ -like '*rea.mjs' } | Select-Object -First 1)
    if ($reaMjs) {
      # rea.mjs 可能在包根或 scripts/ 子目录，逐级上找 package.json
      $reaPkg = Join-Path (Split-Path -Parent $reaMjs) 'package.json'
      if (-not (Test-Path $reaPkg)) { $reaPkg = Join-Path (Split-Path -Parent (Split-Path -Parent $reaMjs)) 'package.json' }
      if (Test-Path $reaPkg) { $rea = (Get-Content $reaPkg -Raw | ConvertFrom-Json -AsHashtable).version }
    }
  }
} catch { }
if (-not $rea) {
  $rea = & node -e "try{console.log(JSON.parse(require('child_process').execSync('npm ls -g rea-agents --json --depth=0').toString()).dependencies['rea-agents'].version)}catch(e){console.log('')}" 2>$null
}
if ($rea) {
  $major = [version]$rea
  if ($major -ge [version]'6.8.0') { Note "OK" "rea-agents $rea installed" } else { Note 'WARN' "rea-agents $rea < 6.8.0; run: npm i -g rea-agents" }
} else {
  Note 'WARN' 'rea-agents not found; run: npm install -g rea-agents'
}

# 3) craft-anything-cli
$caCandidates = @("$env:USERPROFILE\tools\craft-anything-bin\craft-anything-cli.exe", (Get-Command craft-anything-cli -ErrorAction SilentlyContinue).Source)
$ca = $caCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if ($ca) { Note 'OK' "craft-anything-cli found: $ca" }
else { Note 'WARN' 'craft-anything-cli not found; download from https://github.com/storytold/craft-anything/releases' }

# 4) uv（reverse_lab_tools 需要）
$uv = Get-Command uv -ErrorAction SilentlyContinue
if ($uv) { Note 'OK' 'uv found' } else { Note 'WARN' 'uv not found; reverse_lab_tools MCP unavailable; install: https://docs.astral.sh/uv/' }

# 5) reverse_lab_tools 全局注册（无则注册，幂等）
$claudeJson = "$env:USERPROFILE\.claude.json"
if ($uv -and (Test-Path $claudeJson)) {
  $cfg = Get-Content $claudeJson -Raw | ConvertFrom-Json -AsHashtable
  if ($cfg.mcpServers -and $cfg.mcpServers.Contains('reverse_lab_tools')) {
    Note 'OK' 'reverse_lab_tools already registered'
  } else {
    $mcpDir = "$root/vendors/open-reverselab/tools/skills/mcp/ReverseLabToolsMCP"
    if (Test-Path "$mcpDir/reverse_lab_tools_mcp.py") {
      # PowerShell 不向原生命令透传裸 `--` 分隔符，故用 add-json 传完整定义；
      # 上游 requires-python 声明 >=3.10 但代码使用 tomllib（3.11+ 标准库），故显式钉 >=3.11
      $mcpJson = @{ type = 'stdio'; command = 'uv'; args = @('run', '--project', $mcpDir, '--python', '>=3.11', 'python', "$mcpDir/reverse_lab_tools_mcp.py") } | ConvertTo-Json -Compress
      & claude mcp add-json --scope user reverse_lab_tools $mcpJson
      if ($LASTEXITCODE -eq 0) { Note 'OK' 'reverse_lab_tools registered (restart Claude Code to load)' }
      else { Note 'FAIL' 'claude mcp add-json failed' }
    } else { Note 'FAIL' "MCP entry not found: $mcpDir/reverse_lab_tools_mcp.py" }
  }
}

# 6) 健康检查
if ($ca) { & $ca doctor 2>&1 | Select-Object -First 3 | ForEach-Object { Note 'INFO' "CA doctor: $_" } }

# 7) reverse-skill 工具索引
$rti = "$root/vendors/reverse-skill/scripts/refresh-tool-index.ps1"
if (Test-Path $rti) { pwsh -NoProfile -File $rti *>$null; if (Test-Path "$root/vendors/reverse-skill/skills/tool-index.md") { Note 'OK' 'reverse-skill tool index generated' } else { Note 'WARN' 'tool index script ran but output missing' } }
else { Note 'WARN' "refresh-tool-index not found at $rti" }

# 8) 路由回归测试
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'route-test.ps1')
if ($LASTEXITCODE -eq 0) { Note 'OK' 'route-test passed' } else { Note 'FAIL' 'route-test failed' }

Write-Host ''
Write-Host '=== unirev install report ==='
$report | ForEach-Object { Write-Host $_ }
