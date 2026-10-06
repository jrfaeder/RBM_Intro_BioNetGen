#!/usr/bin/env bash
# Regenerate the simulation data and network sizes plotted in the slides by
# running the rule-based models in ../../models with BioNetGen. Requires
# `bionetgen` (PyBioNetGen) on PATH.
# Output: data/stat_rbm<i>.dat (time courses) and data/network_sizes.dat.
set -euo pipefail
cd "$(dirname "$0")"
MODELS=../../models
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

models=(stat_rbm1_rules stat_rbm2_ligand_release stat_rbm3_socs_site
        stat_rbm4_receptor_dimer stat_rbm5_stat_dimer stat_rbm6_ser727)

echo "model rules species reactions" > data/network_sizes.dat
i=0
for m in "${models[@]}"; do
  i=$((i+1))
  bionetgen run -i "$MODELS/$m.bngl" -o "$TMP/$m" > "$TMP/$m.log" 2>&1 || { cat "$TMP/$m.log"; exit 1; }
  sed '1s/^#//' "$TMP/$m/$m.gdat" > "data/stat_rbm$i.dat"
  net="$TMP/$m/$m.net"
  nrules=$(grep -cE '^  [A-Za-z0-9_]+: ' "$MODELS/$m.bngl")
  nspec=$(sed -n '/^begin species/,/^end species/p' "$net" | grep -vc 'species')
  nrxn=$(sed -n '/^begin reactions/,/^end reactions/p' "$net" | grep -vc 'reactions')
  echo "$i $nrules $nspec $nrxn" >> data/network_sizes.dat
done
cat data/network_sizes.dat
