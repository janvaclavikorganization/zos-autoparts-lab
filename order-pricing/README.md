# order-pricing/

Order pricing — the core of the flow.

- `PRICECAL.cbl` — pure pricing rules (country VAT + line total), no I/O, so they
  can be unit-tested on their own.
- `ORDPROC.cbl` — the batch: read orders, look up each part in the VSAM
  catalogue, call `PRICECAL`, write a priced record; unknown parts are flagged.
- `orders.dat` — sample daily orders (fixed 25-byte records).
- `DAILYRUN.jcl` — orchestrates the whole daily flow (price → report → SAP
  extract → DB2 load) as chained job steps.
