#!/bin/sh
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
node -e '
const fs=require("fs"),path=require("path");
const root=process.argv[1];
const routing=JSON.parse(fs.readFileSync(path.join(root,"skills/unirev/references/routing.json"),"utf8"));
const cases=JSON.parse(fs.readFileSync(path.join(root,"scripts/testdata/routes.json"),"utf8"));
let fail=0; const ids=new Set(routing.routes.map(r=>r.id));
const gateOk=!!(routing.gates&&routing.gates.consent);
const evOk=!!(routing.evidence&&routing.evidence.crossPhase);
for(const r of routing.routes){ if(!r.id||!r.signals||!r.primary){console.log("FAIL: route missing fields ["+(r.id||"(no id)")+"]");fail++;} }
if(!gateOk){console.log("FAIL: gates.consent missing");fail++;}
if(routing.gates&&routing.gates.source&&!fs.existsSync(path.join(root,routing.gates.source))){console.log("FAIL: gates.source missing");fail++;}
if(!evOk){console.log("FAIL: evidence.crossPhase missing");fail++;}
for(const r of routing.routes){ for(const k of (r.kb||[])){ if(!fs.existsSync(path.join(root,k))){console.log("FAIL: kb missing "+k+" ("+r.id+")");fail++;} } }
if(cases.cases.length<20){console.log("FAIL: expected >= 20 testdata cases, got "+cases.cases.length);fail++;}
if(routing.routes.length<8){console.log("FAIL: expected >= 8 routes, got "+routing.routes.length);fail++;}
for(const c of cases.cases){ if(c.expect.routeId==="R-GATE-REJECT")continue;
  if(!ids.has(c.expect.routeId)){console.log("FAIL: unknown route "+c.expect.routeId+" ["+c.input+"]");fail++;continue;}
  const route=routing.routes.find(r=>r.id===c.expect.routeId);
  const sigs=(route&&route.signals)||[];
  const hit=sigs.some(s=>String(c.input).toLowerCase().includes(String(s).toLowerCase()));
  if(!hit){console.log("FAIL: case input matches no signal of "+c.expect.routeId+": "+c.input);fail++;}
  if(c.expect.kb&&!fs.existsSync(path.join(root,c.expect.kb))){console.log("FAIL: case kb missing "+c.expect.kb);fail++;}
  if(c.expect.gate&&!gateOk){console.log("FAIL: case expects gate but gates.consent missing/empty ["+c.input+"]");fail++;} }
console.log(fail?("route-test: "+fail+" FAILURES / "+cases.cases.length+" cases"):"route-test: all "+cases.cases.length+" cases OK, "+routing.routes.length+" routes registered");
process.exit(fail?1:0);
' "$ROOT" || fail=1
exit $fail
