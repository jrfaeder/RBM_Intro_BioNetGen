#!/usr/bin/env bash
# Render worksheets (Markdown) to PDF:  ./build.sh [name.md ...]
# Uses pandoc for Markdown -> HTML and headless Chrome for HTML -> PDF.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
# Resolve arguments relative to the caller's directory, then work from Worksheets/.
files=()
for f in "$@"; do
  [[ -f "$f" ]] || { echo "No such file: $f" >&2; exit 1; }
  files+=("$(cd "$(dirname "$f")" && pwd)/$(basename "$f")")
done
cd "$here"
[[ ${#files[@]} -gt 0 ]] || files=(*.md keys/*.md)
for md in "${files[@]}"; do
  [[ -f "$md" ]] || continue
  dir=$(dirname "$md"); base=$(basename "$md" .md)
  html="$dir/$base.html"
  css=$(python3 -c "import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$here/worksheet.css" "$dir")
  pandoc "$md" -s --css="$css" --embed-resources --resource-path="$dir:." \
    --metadata title-meta="$base" -V pagetitle="$base" -o "$html"
  "$CHROME" --headless --disable-gpu --no-pdf-header-footer \
    --print-to-pdf="$dir/$base.pdf" "file://$(cd "$dir" && pwd)/$base.html" 2>/dev/null
  rm -f "$html"
  echo "wrote $dir/$base.pdf"
done
