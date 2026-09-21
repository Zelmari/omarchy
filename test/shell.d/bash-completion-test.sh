#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

bin_dir=$(mktemp -d)
trap 'rm -rf "$bin_dir"' EXIT

for name in omarchy omarchy-restart-shell omarchy-restart-audio omarchy-theme-set zz-unique-cmd; do
  printf '#!/bin/bash\n' >"$bin_dir/$name"
  chmod +x "$bin_dir/$name"
done

source "$ROOT/default/bash/completions"

spec=$(complete -p -I)
[[ $spec == *"-F _omarchy_command_complete"* && $spec != *"-X"* ]] ||
  fail "initial-word completion offers typed omarchy binaries" "$spec"
pass "initial-word completion offers typed omarchy binaries"

complete_initial() {
  local PATH=$bin_dir
  COMP_WORDS=("$1")
  COMP_CWORD=0
  COMP_LINE=$1
  COMP_POINT=${#COMP_LINE}
  COMPREPLY=()
  _omarchy_command_complete
}

complete_initial "omarchy-restart-s"
(( ${#COMPREPLY[@]} == 1 )) && [[ ${COMPREPLY[0]} == "omarchy-restart-shell" ]] ||
  fail "omarchy-restart-shell completes from its prefix" "got: ${COMPREPLY[*]-}"
pass "omarchy-restart-shell completes from its prefix"

complete_initial "omarchy-r"
actual=$(printf '%s\n' "${COMPREPLY[@]}" | sort)
expected=$'omarchy-restart-audio\nomarchy-restart-shell'
[[ $actual == "$expected" ]] ||
  fail "a hyphenated prefix lists matching omarchy binaries" "expected:
$expected
actual:
$actual"
pass "a hyphenated prefix lists matching omarchy binaries"

complete_initial "oma"
(( ${#COMPREPLY[@]} == 1 )) && [[ ${COMPREPLY[0]} == "omarchy" ]] ||
  fail "a short prefix stays on the omarchy dispatcher" "got: ${COMPREPLY[*]-}"
pass "a short prefix stays on the omarchy dispatcher"

complete_initial "zz-unique"
(( ${#COMPREPLY[@]} == 1 )) && [[ ${COMPREPLY[0]} == "zz-unique-cmd" ]] ||
  fail "other commands still complete" "got: ${COMPREPLY[*]-}"
pass "other commands still complete"

complete_dispatcher() {
  local PATH=$bin_dir:/usr/bin
  COMP_WORDS=(omarchy restart sh)
  COMP_CWORD=2
  COMP_LINE="omarchy restart sh"
  COMP_POINT=${#COMP_LINE}
  COMPREPLY=()
  _omarchy_complete
}

complete_dispatcher
(( ${#COMPREPLY[@]} == 1 )) && [[ ${COMPREPLY[0]} == "shell" ]] ||
  fail "omarchy restart shell still completes" "got: ${COMPREPLY[*]-}"
pass "omarchy restart shell still completes"
