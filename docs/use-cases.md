# Use Cases

The lab models one coherent slice of an automotive **spare-parts distribution**
core system. Three use cases, end to end: keep the catalogue, price the orders,
report the result.

---

## UC-1 · Maintain the parts catalogue

| | |
|---|---|
| **Actor** | Parts data steward |
| **Trigger** | New or changed spare part |
| **Input** | Part records: part number, description, category, base price |
| **Outcome** | Parts master (VSAM KSDS) loaded / updated, keyed by part number |

The parts master is the keyed reference every priced order looks up. Stored as a
VSAM KSDS — a non-relational, key-sequenced file native to z/OS — so a single
part is fetched directly by its key, not joined across tables.

---

## UC-2 · Price the daily orders

| | |
|---|---|
| **Actor** | Nightly batch scheduler |
| **Trigger** | End-of-day order file arrives |
| **Input** | Orders: order id, country, dealer, part number, quantity |
| **Flow** | For each order → look up the part in the master → line price = base price × quantity → add country VAT → write priced record. Unknown parts / bad data are **flagged, not dropped**. |
| **Output** | Priced orders file + a run summary (counts, totals, errors) |

The core batch — the bread-and-butter workload of a parts mainframe: read a file,
enrich it against a master, compute money, write a file.

---

## UC-3 · Report sales by country

| | |
|---|---|
| **Actor** | Regional sales / controlling |
| **Trigger** | After pricing completes |
| **Input** | Priced orders file |
| **Flow** | Sort by country then dealer → print lines with subtotals per dealer and per country (control breaks) → grand total |
| **Output** | Formatted country sales report |

A classic mainframe control-break report: ordered input, running subtotals at each
group boundary — the idiomatic way reporting is done in COBOL batch.
