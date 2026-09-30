"""Minimal harness: one clean LLM call per trial via the headless Claude Code CLI.

Each call gets an explicit system prompt, no tools, and a user message on stdin, so the
only inputs are the ones the experiment sets. Results are appended as JSON lines.
"""
import json, subprocess, time
from concurrent.futures import ThreadPoolExecutor

def call(model, system, user, timeout=300):
    for attempt in range(3):
        p = subprocess.run(["claude", "-p", "--model", model, "--system-prompt", system,
                            "--tools", "", "--output-format", "json"],
                           input=user, capture_output=True, text=True, timeout=timeout)
        try:
            d = json.loads(p.stdout)
            if not d.get("is_error"):
                return {"text": d["result"], "cost": d.get("total_cost_usd", 0)}
        except json.JSONDecodeError:
            pass
        time.sleep(2 ** attempt)
    return {"text": None, "cost": 0, "error": (p.stderr or p.stdout)[-500:]}

def run(trials, out_path, workers=8):
    """trials: list of dicts with model, system, user and any factor labels."""
    def one(t):
        r = call(t["model"], t["system"], t["user"])
        return {**{k: v for k, v in t.items() if k not in ("system", "user")}, **r}
    with open(out_path, "a") as f, ThreadPoolExecutor(workers) as ex:
        for r in ex.map(one, trials):
            f.write(json.dumps(r) + "\n"); f.flush()
