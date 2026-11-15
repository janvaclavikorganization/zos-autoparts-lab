#!/usr/bin/env bash
#
# Run the whole pipeline locally with GnuCOBOL - no mainframe needed.
#   ./run-local.sh      (or: make run)
#
# The z/OS DB2 LOAD step is the only part that needs a real mainframe.
#
set -euo pipefail

BUILD=build
mkdir -p "$BUILD"

echo "== compile =="
cobc -x -I copybook -o $BUILD/partload scripts/PARTLOAD.cbl
cobc -x -I copybook -o $BUILD/ordproc  order-pricing/ORDPROC.cbl \
                                       order-pricing/PRICECAL.cbl
cobc -x -I copybook -o $BUILD/ordrpt   order-report/ORDRPT.cbl
cobc -x -I copybook -o $BUILD/invextr  integration/INVEXTR.cbl

# Local data prep: z/OS datasets are fixed-length with no line breaks,
# so strip newlines; sort orders by country for the report control-break.
tr -d '\n' < parts-vsam/parts.dat > $BUILD/parts.in
sort -k1.9,1.10 order-pricing/orders.dat | tr -d '\n' > $BUILD/orders.in

echo "== 1) load parts into an indexed file =="
PARTSIN=$BUILD/parts.in PARTSDD=$BUILD/parts ./$BUILD/partload

echo "== 2) price the orders =="
ORDERSDD=$BUILD/orders.in PARTSDD=$BUILD/parts PRICEDDD=$BUILD/priced.dat \
    ./$BUILD/ordproc
echo "--- priced orders ---"; fold -w37 $BUILD/priced.dat; echo

echo "== 3) country sales report (control-break) =="
PRICEDDD=$BUILD/priced.dat RPTOUT=$BUILD/report.txt ./$BUILD/ordrpt
fold -w72 $BUILD/report.txt

echo "== 4) SAP invoice extract =="
PRICEDDD=$BUILD/priced.dat SAPOUT=$BUILD/sap.dat ./$BUILD/invextr
echo "--- SAP interface file ---"; fold -w26 $BUILD/sap.dat; echo
