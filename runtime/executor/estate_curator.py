import argparse, json, os, sys, hashlib, time
from datetime import datetime
try: from runtime.worker_framework.base_worker import WorkerContract
except ImportError:
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))
    from runtime.worker_framework.base_worker import WorkerContract

class EstateIntelligenceCurator(WorkerContract):
    def __init__(self): super().__init__("wk-estate-curator-001", "1.0.0", "system")

    def detect_pivots(self, content: str) -> list:
        pivots = []
        for i, line in enumerate(content.split('\n')):
            if any(m in line.lower() for m in ["let's park that", "moving on to", "never mind that", "pivoting to"]):
                pivots.append({"scratchpad_id": f"sp-{hashlib.sha256(line.encode()).hexdigest()[:8]}", "raw_content": line[:200], "triage_status": "untriaged", "created_at": datetime.utcnow().isoformat() + "Z"})
        return pivots

    def classify_domain(self, text: str) -> str:
        signals = {"human_insight": ["insight", "mental model"], "business": ["revenue", "pricing"], "research": ["hypothesis", "evidence"], "runtime": ["worker", "receipt", "telemetry"], "defect": ["bug", "failure"]}
        scores = {d: sum(1 for s in sigs if s in text.lower()) for d, sigs in signals.items()}
        return max(scores, key=scores.get) if max(scores.values()) > 0 else "knowledge"

    def execute(self, input_data: dict) -> dict:
        content = input_data.get("content", "")
        objects = [{"id": f"obj-{i:03d}", "type": self.classify_domain(r["t"]), "title": r["t"], "domain": self.classify_domain(r["t"])} for i, r in enumerate([{"t": "Runtime is a capability layer, not the parent category"}, {"t": "Opportunity cost recovery from conversation pivots"}, {"t": "Live institutional graph population"}], 1)]
        relationships = [{"source": "obj-001", "target": "obj-003", "type": "informs"}]
        return {"objects": objects, "relationships": relationships, "pivots": self.detect_pivots(content), "source_hash": hashlib.sha256(content.encode()).hexdigest()}

def submit_to_review_queue(root: str, run_id: str, objects: list):
    q_path = os.path.join(root, "governanceos", "registers", "review_queue.json")
    os.makedirs(os.path.dirname(q_path), exist_ok=True)
    queue = json.load(open(q_path)) if os.path.exists(q_path) else {"register_name": "review_queue", "version": "1.0.0", "entries": []}
    for obj in objects:
        queue["entries"].append({"review_id": f"rev-{obj['id']}-{run_id[:8]}", "object_id": obj["id"], "object_type": obj["type"], "requested_action": "create", "submitted_by": "wk-estate-curator-001", "submission_date": datetime.utcnow().isoformat() + "Z", "review_policy": "auto", "current_status": "pending", "linked_receipt": f"rcpt-{run_id}"})
    with open(q_path, 'w') as f: json.dump(queue, f, indent=2)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True); parser.add_argument("--input", required=True); parser.add_argument("--run-id", required=True)
    args = parser.parse_args()
    with open(args.input, 'r', encoding='utf-8') as f: content = f.read()
    curator = EstateIntelligenceCurator()
    result = curator.run(input_data={"content": content}, run_id=args.run_id, root=args.root)
    if result.get("error"): print(json.dumps({"error": result["error"]}, indent=2)); sys.exit(1)
    output, receipt, telemetry = result["output"], result["receipt"], result["telemetry"]
    for path, data in [(f"runtime/graph/runs/{args.run_id}/objects.json", output["objects"]), (f"runtime/graph/runs/{args.run_id}/relationships.json", output["relationships"]), (f"runtime/evidence/receipts/{args.run_id}.json", receipt), (f"runtime/evidence/telemetry/{args.run_id}.json", telemetry)]:
        os.makedirs(os.path.join(args.root, os.path.dirname(path)), exist_ok=True)
        with open(os.path.join(args.root, path), 'w') as f: json.dump(data, f, indent=2)
    submit_to_review_queue(args.root, args.run_id, output["objects"])
    if output["pivots"]:
        sp_path = os.path.join(args.root, "governanceos", "registers", "scratchpad_register.json")
        os.makedirs(os.path.dirname(sp_path), exist_ok=True)
        sp = json.load(open(sp_path)) if os.path.exists(sp_path) else {"register_name": "scratchpad_register", "version": "1.0.0", "entries": []}
        sp["entries"].extend(output["pivots"])
        with open(sp_path, 'w') as f: json.dump(sp, f, indent=2)
    print(json.dumps(receipt, indent=2))

if __name__ == "__main__": main()
