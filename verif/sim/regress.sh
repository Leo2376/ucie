#!/bin/bash
# regress.sh: run lint + all sim targets, check PASS markers.
set -u
cd "$(dirname "$0")"
pass=0; fail=0
run() { # $1=label $2=expected $3...=cmd
  local label="$1" exp="$2"; shift 2
  echo "=== $label ==="
  out=$("$@" 2>&1); rc=$?
  echo "$out" | tail -n 5
  if [ $rc -eq 0 ] && echo "$out" | grep -q "$exp"; then
    echo "REGRESS $label PASS"; pass=$((pass+1));
  else
    echo "REGRESS $label FAIL (rc=$rc exp=$exp)"; fail=$((fail+1));
  fi
}
run lint LINT_OK sh -c 'verilator --lint-only -f filelist.f --top-module ucie_top --timing && echo LINT_OK'
run sim SMOKE make -s sim
run flit FLIT make -s flit
run flit_path FLITPATH make -s flit_path
run flit_stress FLITSTRESS make -s flit_stress
run link_mgmt LINKMGMT make -s link_mgmt
run lane_pll LANEPLL make -s lane_pll
# link bring-up last (30M+ cycle budget)
run link LINKBRINGUP make -s link
echo "=== REGRESS DONE pass=$pass fail=$fail ==="
[ "$fail" -eq 0 ]
