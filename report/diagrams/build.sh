#!/usr/bin/env bash
# Biên dịch mọi sơ đồ TikZ: d*.tex (sơ đồ) và s*.tex (card cho slide) -> .pdf (cho paper.tex) và png/d*.png (cho slide). File tikzstyle.tex là style chung, không biên dịch riêng.
#   bash report/diagrams/build.sh
# Cần XeLaTeX (TeX Live / MiKTeX) hoặc tectonic; pdftoppm (poppler) để xuất PNG.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p png

for f in d*.tex s*.tex; do
  name="${f%.tex}"
  if command -v xelatex >/dev/null; then
    xelatex -interaction=nonstopmode -halt-on-error "$f" >/dev/null || { echo "LỖI: $f (xem $name.log)"; exit 1; }
  else
    tectonic -X compile "$f" >/dev/null
  fi
  pdftoppm -png -r 300 -singlefile "$name.pdf" "png/$name"
  echo "ok  $name.pdf  png/$name.png"
done
rm -f ./*.aux ./*.log
