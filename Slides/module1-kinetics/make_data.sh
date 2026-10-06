#!/usr/bin/env bash
# Regenerate the simulation data plotted in the slides by running the
# models in ../../models with BioNetGen. Requires `bionetgen` (PyBioNetGen)
# on PATH. Output: data/*.dat (whitespace-separated, header row, no '#').
set -euo pipefail
cd "$(dirname "$0")"
MODELS=../../models
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

run() {  # run <model.bngl> <outdir>
  bionetgen run -i "$1" -o "$2" > "$2.log" 2>&1 || { cat "$2.log"; exit 1; }
}
todat() {  # todat <gdat> <dat>: drop the leading '#' so pgfplots reads the header
  sed '1s/^#//' "$1" > "$2"
}

for m in stat_step1_binding stat_step2_recruit stat_step3_activate \
         stat_step4_release stat_step5_transcribe stat_step6_feedback; do
  run "$MODELS/$m.bngl" "$TMP/$m"
done
for m in stat_step1_binding stat_step2_recruit stat_step3_activate \
         stat_step4_release stat_step5_transcribe; do
  todat "$TMP/$m/$m.gdat" "data/$m.dat"
done
todat "$TMP/stat_step6_feedback/stat_step6_feedback_feedback.gdat"    data/stat_step6_feedback.dat
todat "$TMP/stat_step6_feedback/stat_step6_feedback_no_feedback.gdat" data/stat_step6_no_feedback.dat

# Ligand dose series for step 1
for L0 in 0.1 1 10; do
  sed "s/^  L0 .*/  L0 $L0/" "$MODELS/stat_step1_binding.bngl" > "$TMP/lr_L$L0.bngl"
  run "$TMP/lr_L$L0.bngl" "$TMP/lr_L$L0"
  todat "$TMP/lr_L$L0/lr_L$L0.gdat" "data/lr_dose_L$L0.dat"
done
echo "Wrote: $(ls data | tr '\n' ' ')"
