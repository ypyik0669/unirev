#!/bin/sh
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
node -e '
const fs=require("fs"),path=require("path");
const root=process.argv[1];
const routing=JSON.parse(fs.readFileSync(path.join(root,"skills/unirev/references/routing.json"),"utf8"));
const cases=JSON.parse(fs.readFileSync(path.join(root,"scripts/testdata/routes.json"),"utf8"));
let fail=0; const ids=new Set(routing.routes.map(r=>r.id));
for(const r of routing.routes){ if(!r.id||!r.signals||!r.primary){console.log("FAIL: route missing fields");fail++;} }
if(!routing.gates.consent){console.log("FAIL: gates.consent missing");fail++;}
if(!fs.existsSync(path.join(root,routing.gates.source))){console.log("FAIL: gates.source missing");fail++;}
if(!routing.evidence.crossPhase){console.log("FAIL: evidence.crossPhase missing");fail++;}
for(const r of routing.routes){ for(const k of (r.kb||[])){ if(!fs.existsSync(path.join(root,k))){console.log("FAIL: kb missing "+k+" ("+r.id+")");fail++;} } }
for(const c of cases.cases){ if(c.expect.routeId==="R-GATE-REJECT")continue;
  if(!ids.has(c.expect.routeId)){console.log("FAIL: unknown route "+c.expect.routeId);fail++;}
  if(c.expect.kb&&!fs.existsSync(path.join(root,c.expect.kb))){console.log("FAIL: case kb missing "+c.expect.kb);fail++;} }
console.log(fail?("route-test: "+fail+" FAILURES / "+cases.cases.length+" cases"):"route-test: all "+cases.cases.length+" cases OK, "+routing.routes.length+" routes registered");
process.exit(fail?1:0);
' "$ROOT" || fail=1
exit $fail
