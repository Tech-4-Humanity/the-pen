import json, os, hashlib, time
from datetime import datetime
from typing import Dict, Any, List

class WorkerContract:
    def __init__(self, worker_id: str, version: str, owner: str):
        self.worker_id, self.version, self.owner = worker_id, version, owner
        self.run_id, self.checkpoint_hash, self.status = None, None, "INITIALISED"

    def validate_prerequisites(self, reqs: List[str]) -> bool: return True
    def self_test(self) -> bool: return True
    def execute(self, input_data: Any) -> Dict[str, Any]: raise NotImplementedError()

    def checkpoint(self, state: Dict[str, Any]) -> str:
        self.checkpoint_hash = hashlib.sha256(json.dumps(state, sort_keys=True).encode()).hexdigest()
        return self.checkpoint_hash

    def emit_receipt(self, output: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "receipt_id": f"rcpt-{hashlib.sha256(str(output).encode()).hexdigest()[:16]}",
            "worker_id": self.worker_id, "version": self.version, "run_id": self.run_id,
            "timestamp": datetime.utcnow().isoformat() + "Z", "status": self.status,
            "checkpoint_hash": self.checkpoint_hash, "owner": self.owner,
            "promotion_state": "PENDING_HUMAN_REVIEW"
        }

    def emit_telemetry(self, metrics: Dict[str, Any]) -> Dict[str, Any]:
        return {"event_id": f"evt-{hashlib.sha256(str(metrics).encode()).hexdigest()[:16]}", "worker_id": self.worker_id, "run_id": self.run_id, "timestamp": datetime.utcnow().isoformat() + "Z", "metrics": metrics}

    def update_registry(self, registry_path: str, state: str):
        os.makedirs(os.path.dirname(registry_path), exist_ok=True)
        with open(registry_path, 'w') as f: json.dump({"worker_id": self.worker_id, "state": state, "last_run": self.run_id, "last_verified": datetime.utcnow().isoformat() + "Z", "version": self.version}, f, indent=2)

    def run(self, input_data: Any, run_id: str, root: str, max_retries: int = 3) -> Dict[str, Any]:
        self.run_id, self.status = run_id, "RUNNING"
        if not self.validate_prerequisites([]) or not self.self_test():
            self.status = "FAILED"; return {"error": "Prerequisites failed"}
        last_error = None
        for attempt in range(1, max_retries + 1):
            try:
                output = self.execute(input_data)
                self.status = "SUCCESS"; break
            except Exception as e:
                last_error = str(e)
                self.status = "RETRYING"
                if attempt < max_retries: time.sleep(2 ** attempt)
                else: self.status = "FAILED"; return {"error": f"Failed: {last_error}"}
        self.checkpoint(output)
        receipt, telemetry = self.emit_receipt(output), self.emit_telemetry({"duration_ms": 0, "objects_created": len(output.get("objects", [])), "attempts": attempt})
        self.update_registry(os.path.join(root, "runtime", "registry", "worker_state.json"), "VERIFIED")
        return {"output": output, "receipt": receipt, "telemetry": telemetry}
