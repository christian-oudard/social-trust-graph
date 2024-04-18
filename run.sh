#! /bin/sh

pushd trust-network
rm -f output.dot
cargo run > ../output.dot
popd

python graph_layout.py
