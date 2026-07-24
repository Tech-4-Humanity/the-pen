#!/usr/bin/env python3
import csv, json, re, hashlib
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "registry" / "communication_objects.csv"
def load_object(communication_id):
    with REGISTRY.open(encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row["communication_id"] == communication_id:
                return row
    raise KeyError(f"Unknown communication_id: {communication_id}")
def render_text(template, variables):
    unresolved=[]
    def repl(match):
        key=match.group(1)
        if key not in variables or variables[key] in (None,""):
            unresolved.append(key); return match.group(0)
        return str(variables[key])
    return re.sub(r"\{\{([A-Za-z0-9_]+)\}\}", repl, template), sorted(set(unresolved))
def render(request):
    obj=load_object(request["communication_id"]); variables=request.get("variables",{})
    subject,u1=render_text(obj["subject_template"],variables); body,u2=render_text(obj["body_template"],variables)
    required=[x for x in obj["required_variables"].split("|") if x]
    missing=sorted(set([x for x in required if not variables.get(x)] + u1 + u2))
    payload={"communication_id":obj["communication_id"],"version":obj["version"],
      "channel":request.get("channel",obj["channel"]),"subject":subject,"body":body,
      "unresolved_variables":missing,"valid":not missing}
    payload["receipt_hash"]=hashlib.sha256(json.dumps(payload,sort_keys=True).encode()).hexdigest()
    return payload
if __name__ == "__main__":
    import sys
    print(json.dumps(render(json.load(sys.stdin)),indent=2))
