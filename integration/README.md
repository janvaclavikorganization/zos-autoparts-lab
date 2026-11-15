# integration/

Downstream hand-offs — the seams where the priced orders flow out to other
systems.

- `INVEXTR.cbl` — build the **SAP** invoicing interface file (one record per
  successfully priced order).
- `SALESDB2.cbl` — load the day's sales into a **DB2** table via **embedded SQL**
  (`EXEC SQL`). Needs DB2 pre-compile + bind + runtime; does not build under
  plain GnuCOBOL.
- `SALES.sql` — the DB2 table DDL + an example BI query.
