#!/usr/bin/env bash
#
# Run the whole pipeline locally with GnuCOBOL - no mainframe needed.
#   ./run-local.sh      (or: make run)
#
set -euo pipefail

BUILD=build
mkdir -p "$BUILD"
BAR="════════════════════════════════════════════════════════"
indent() { sed 's/^/      /'; }

# --- compile (quiet) ---
cobc -x -I copybook -o $BUILD/partload scripts/PARTLOAD.cbl
cobc -x -I copybook -o $BUILD/ordproc  order-pricing/ORDPROC.cbl \
                                       order-pricing/PRICECAL.cbl
cobc -x -I copybook -o $BUILD/ordrpt   order-report/ORDRPT.cbl
cobc -x -I copybook -o $BUILD/invextr  integration/INVEXTR.cbl

# Local data prep: z/OS datasets are fixed-length with no line breaks,
# so strip newlines; sort orders by country for the report control-break.
tr -d '\n' < parts-vsam/parts.dat > $BUILD/parts.in
sort -k1.9,1.10 order-pricing/orders.dat | tr -d '\n' > $BUILD/orders.in

echo "$BAR"
echo "  AUTOPARTS  ·  daily order pipeline"
echo "$BAR"
echo

echo "▌ 1 · LOAD CATALOGUE"
echo
PARTSIN=$BUILD/parts.in PARTSDD=$BUILD/parts ./$BUILD/partload | indent
echo

echo "▌ 2 · PRICE ORDERS"
echo
ORDERSDD=$BUILD/orders.in PARTSDD=$BUILD/parts PRICEDDD=$BUILD/priced.dat \
    ./$BUILD/ordproc | indent
echo
echo "      priced orders (raw fixed-width records):"
fold -w37 $BUILD/priced.dat | sed 's/^/        /'
echo
echo

echo "▌ 3 · COUNTRY SALES REPORT"
echo
PRICEDDD=$BUILD/priced.dat RPTOUT=$BUILD/report.txt ./$BUILD/ordrpt
fold -w72 $BUILD/report.txt | sed -e 's/ *$//' -e 's/^/        /'
echo
echo

echo "▌ 4 · BILLING INTERFACE EXTRACT"
echo
PRICEDDD=$BUILD/priced.dat SAPOUT=$BUILD/bill.dat ./$BUILD/invextr | indent
echo
echo "      billing interface file:"
fold -w26 $BUILD/bill.dat | sed 's/^/        /'
echo
echo

echo "$BAR"
echo "  done"
echo "$BAR"
