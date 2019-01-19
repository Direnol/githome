#!/bin/bash
mkdir -p "${HOME}/erl/log"
run_erl "${HOME}/erl/" "${HOME}/erl/log/" "exec iex -S mix"
