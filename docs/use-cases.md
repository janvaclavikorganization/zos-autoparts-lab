# Use Cases

The lab models one coherent slice of an automotive **spare-parts distribution**
core system: keep the catalogue, price the orders, then hand the result to a
report and the billing system.

---

## UC-1 · Maintain the parts catalogue

| | |
|---|---|
| **Actor** | Parts data steward |
| **Trigger** | New or changed spare part |
| **Input** | Part records: part number, description, category, base price |
| **Outcome** | Parts master (VSAM KSDS) loaded, keyed by part number |

The parts master is the keyed reference every priced order looks up. Stored as a
VSAM KSDS — a non-relational, key-sequenced file native to z/OS — so a single
part is fetched directly by its key, not joined across tables.

---

## UC-2 · Price the daily orders

| | |
|---|---|
| **Actor** | Nightly batch scheduler |
| **Trigger** | End-of-day order file arrives |
| **Input** | Orders: order id, country, part number, quantity |
| **Flow** | For each order → look up the part in the master → line price = base price × quantity → add country VAT → write a priced record. Unknown parts are **skipped and counted**, not dropped silently. |
| **Output** | Priced orders file + a run summary (priced / skipped counts) |

The core batch — the bread-and-butter workload of a parts mainframe: read a file,
enrich it against a master, compute money, write a file. (`ORDPROC`, calling the
shared pricing rules in `PRICECAL`.)

---

## UC-3 · Report sales by country

| | |
|---|---|
| **Actor** | Regional sales / controlling |
| **Trigger** | After pricing completes |
| **Input** | Priced orders file (sorted by country) |
| **Flow** | Print a line per order, a subtotal when the country changes (control break), and a grand total |
| **Output** | Formatted country sales report |

A classic mainframe control-break report: ordered input, running subtotals at each
group boundary — the idiomatic way reporting is done in COBOL batch. (`ORDRPT`.)

---

## UC-4 · Produce the invoicing interface

| | |
|---|---|
| **Actor** | Billing / finance integration |
| **Trigger** | After pricing completes |
| **Input** | Priced orders file |
| **Flow** | For each successfully priced order, map the fields into the invoicing layout and write one interface record |
| **Output** | Fixed-format interface file handed off to the **billing system** |

The interface file is the seam between systems — the integration hand-off.
(`INVEXTR`.)
