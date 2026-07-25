#!/usr/bin/env python3
"""Baseline perspective aggregator for one-to-many organisational impact questions."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASELINE = ROOT / "registry" / "hakuna-matata" / "perspectives.json"


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: perspective.py <question.json>", file=sys.stderr)
        return 2
    question_path = Path(sys.argv[1])
    if not question_path.is_absolute():
        question_path = ROOT / question_path
    question = json.loads(question_path.read_text(encoding="utf-8"))
    baseline = json.loads(BASELINE.read_text(encoding="utf-8"))
    context = question.get("context", "default")
    override = baseline["weighting_rules"]["context_overrides"].get(context, {})

    views = []
    total = 0.0
    for executive in baseline["executive_views"]:
        weight = override.get(executive["id"], executive["default_weight"])
        total += weight
        views.append({
            "perspective_id": executive["id"],
            "name": executive["name"],
            "weight": weight,
            "focus": executive["focus"],
            "question": question["question"],
            "status": "baseline_not_yet_scored",
        })
    if total:
        for view in views:
            view["weight"] = round(view["weight"] / total, 6)

    result = {
        "classification": "PARTIAL",
        "reason": "baseline perspectives and weights produced; substantive scores require role or model responses",
        "question_id": question.get("question_id", "unassigned"),
        "question": question["question"],
        "context": context,
        "executive_views": views,
        "scale_layers": baseline["scale_layers"],
        "required_outputs": baseline["aggregation"]["outputs"],
        "next_valid_state": "collect_perspective_responses",
    }
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
