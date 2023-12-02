#!/usr/bin/env zsh

set -e

function buildAndRun {
	zig build
	./zig-out/bin/aoc-2023 "$@"
}

buildAndRun "$@"
