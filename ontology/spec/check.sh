#!/bin/sh
# Full verification: scenarios + exhaustive checks, metamorphic properties, mutation score.
set -e
cd "$(dirname "$0")"
python3 run.py
python3 props.py 200 1
python3 mutants.py

# Rust port cross-check (needs cargo)
(cd ../rust && cargo build --release -q) && python3 crosscheck.py --random 100
