#Requires -Version 7
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$routing = Get-Content (Join-Path $root 'skills/unirev/references/routing.json') -Raw | ConvertFrom-Json
$cases = Get-Content (Join-Path $PSScriptRoot 'testdata/routes.json') -Raw | ConvertFrom-Json

$fail = 0
$routeIds = @{}; foreach ($r in $routing.routes) { $routeIds[$r.id] = $r }

# 1) 结构校验：每条 route 必须有 id/signals/primary/kb(或明确无 kb)
foreach ($r in $routing.routes) {
  if (-not $r.id -or -not $r.signals -or -not $r.primary) { Write-Host "FAIL: route missing id/signals/primary [$($r.id)]"; $fail++ }
}

# 2) gates 与证据规则必须存在且 source 文件真实存在
if (-not $routing.gates.consent) { Write-Host 'FAIL: gates.consent missing'; $fail++ }
if (-not (Test-Path (Join-Path $root $routing.gates.source))) { Write-Host "FAIL: gates.source not found: $($routing.gates.source)"; $fail++ }
if (-not $routing.evidence.crossPhase) { Write-Host 'FAIL: evidence.crossPhase missing'; $fail++ }

# 3) kb 路径必须真实存在于 vendors
foreach ($r in $routing.routes) { foreach ($k in $r.kb) {
  if (-not (Test-Path (Join-Path $root $k))) { Write-Host "FAIL: kb dir missing: $k (route $($r.id))"; $fail++ }
} }

# 4) 用例的 routeId 必须在路由表中注册；声明 kb 的用例路径必须存在；
#    非 R-GATE-REJECT 用例的 input 必须命中预期路由至少一个 signal（大小写不敏感）；
#    声明 gate 的用例要求 gates.consent 非空（授权门存在）
if ($cases.cases.Count -lt 20) { Write-Host "FAIL: expected >= 20 testdata cases, got $($cases.cases.Count)"; $fail++ }
if ($routing.routes.Count -lt 8) { Write-Host "FAIL: expected >= 8 routes, got $($routing.routes.Count)"; $fail++ }
foreach ($c in $cases.cases) {
  if ($c.expect.routeId -eq 'R-GATE-REJECT') { continue }  # 授权门拒绝路径不要求信号命中，仅查 gates
  if (-not $routeIds.ContainsKey($c.expect.routeId)) { Write-Host "FAIL: case routes to unknown id: $($c.expect.routeId) [$($c.input)]"; $fail++ }
  else {
    $matched = $false
    foreach ($s in @($routeIds[$c.expect.routeId].signals)) {
      if ($c.input.IndexOf($s, [StringComparison]::OrdinalIgnoreCase) -ge 0) { $matched = $true; break }
    }
    if (-not $matched) { Write-Host "FAIL: case input matches no signal of $($c.expect.routeId): $($c.input)"; $fail++ }
  }
  if ($c.expect.kb -and -not (Test-Path (Join-Path $root $c.expect.kb))) { Write-Host "FAIL: case kb missing: $($c.expect.kb) [$($c.input)]"; $fail++ }
  if ($c.expect.gate -and -not $routing.gates.consent) { Write-Host "FAIL: case expects gate but gates.consent missing/empty [$($c.input)]"; $fail++ }
}

$total = $cases.cases.Count
if ($fail -gt 0) { Write-Host "route-test: $fail FAILURES / $total cases"; exit 1 }
Write-Host "route-test: all $total cases OK, $($routing.routes.Count) routes registered"
