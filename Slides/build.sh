#!/usr/bin/env bash
# Build every slide module and copy the PDFs to Slides/pdf/.
# Each module produces two PDFs:
#   pdf/<module>.pdf          presentation, with step-by-step builds
#   pdf/<module>-handout.pdf  handout, one page per slide with everything shown
#
#   ./build.sh                 build all modules
#   ./build.sh module2-rules   build only the named module(s)
#   ./build.sh --data ...      regenerate simulation data first (needs bionetgen)
#
# A module is any subfolder with a latexmkrc and a <folder>.tex file.
set -euo pipefail
cd "$(dirname "$0")"

data=0
if [[ "${1:-}" == "--data" ]]; then data=1; shift; fi

if [[ $# -gt 0 ]]; then
  modules=("$@")
else
  modules=()
  for rc in */latexmkrc; do modules+=("$(dirname "$rc")"); done
fi

mkdir -p pdf
for m in "${modules[@]}"; do
  m=${m%/}
  [[ -f "$m/$m.tex" ]] || { echo "No $m/$m.tex" >&2; exit 1; }
  echo "==> $m"
  if [[ $data -eq 1 && -x "$m/make_data.sh" ]]; then "$m/make_data.sh"; fi
  (cd "$m" && latexmk -interaction=nonstopmode -halt-on-error "$m.tex" > build.log 2>&1 \
     && latexmk -interaction=nonstopmode -halt-on-error -jobname="$m-handout" \
          -usepretex='\PassOptionsToClass{handout}{beamer}' "$m.tex" >> build.log 2>&1) \
    || { echo "Build failed; see $m/build.log" >&2; tail -20 "$m/build.log" >&2; exit 1; }
  cp "$m/build/$m.pdf" "pdf/$m.pdf"
  cp "$m/build/$m-handout.pdf" "pdf/$m-handout.pdf"
  echo "    pdf/$m.pdf"
  echo "    pdf/$m-handout.pdf"
done
