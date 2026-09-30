#!/bin/sh
# Full verification: scenarios + exhaustive checks, metamorphic properties, mutation score
# (every statement deleted in turn, plus semantic mutants), Rust port vs clingo.
set -e
cd "$(dirname "$0")"
python3 run.py
python3 props.py 200 1
python3 mutants.py

# Rust port cross-check (needs cargo)
(cd ../rust && cargo build --release -q) && python3 crosscheck.py --witness 5 --random 100
