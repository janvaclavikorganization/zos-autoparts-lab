# order-pricing/

`ORDPROC` — the core pricing batch (UC-2).

Planned:
- `ORDPROC.cbl` — read orders, look up parts in VSAM, compute line price +
  country VAT, write priced file, flag errors.
- `RUNPROC.jcl` — compile / link + run step, DD wiring.
- `orders.sample` — sample daily order input.
