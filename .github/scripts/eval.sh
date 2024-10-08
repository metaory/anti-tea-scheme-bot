#!/bin/bash

I=0
mapfile -t TARGETS < <(find /tmp/junk/* -mindepth 1 -type d)
mapfile -t EVALS < <(find evals/* -type f -name 'config.yml' | sed 's/.config.yml//')

function run_evals {
  local target="${1:?BAD_TARGET}"
  for evaluator in "${EVALS[@]}"; do
    echo "[E]> ${evaluator}"
    echo "[T]> ${target}"
    read -r -d '\n' enabled cmd < <(yq '.enabled, .command + " " + .arguments' <"${evaluator}/config.yml")
    if [ "$enabled" == false ]; then
      echo "evaluator is disabled. -- skipping.."
    else
      echo "running evaluator.."
      (
        cd "$evaluator" || return
        echo "${target}" | $cmd
      )
    fi
  done
}

for target in "${TARGETS[@]}"; do
  ((I++))
  echo -e "\n[${I}/${#TARGETS[@]}] -- ${target}"
  run_evals "$target"
done

# vim: ft=bash
