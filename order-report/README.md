# order-report/

`ORDRPT.cbl` — country sales report with **control breaks**: a detail line per
order, a SUBTOTAL whenever the country changes, and a GRAND TOTAL at the end.

Expects the priced file **sorted by country** (the pipeline sorts it before this
step). Reads `PRICEREC`; writes report lines to the `RPTOUT` print file.
