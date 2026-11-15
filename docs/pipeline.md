# Daily spare-parts order processing — pipeline

Price the day's orders against the parts catalogue, then fan the result out to a
report and an invoicing interface.

```mermaid
flowchart TD
    ORD[Orders file] --> PRICE[PRICE · ORDPROC<br/>VSAM lookup + VAT]
    PARTS[(Parts · VSAM KSDS)] --> PRICE
    PRICE --> PRICED[Priced orders file]

    PRICED --> REPORT[REPORT · ORDRPT<br/>control-break subtotals] --> RPT([Country sales report])
    PRICED --> EXTRACT[EXTRACT · INVEXTR] --> BILL([Billing interface file])

    classDef built fill:#2d4a3e,stroke:#4caf93,color:#fff;
    classDef ext fill:#33384a,stroke:#6c8dad,color:#fff;
    class PRICE,REPORT,EXTRACT built;
    class RPT,BILL ext;
```

## Steps

| # | Step | Does | Output |
|---|------|------|--------|
| 1 | **PRICE** (`ORDPROC`) | look up each part in the VSAM catalogue; compute qty × price + country VAT | priced orders file |
| 2 | **REPORT** (`ORDRPT`) | control-break report: subtotals per country, grand total | country sales report |
| 3 | **EXTRACT** (`INVEXTR`) | map priced orders into the invoicing layout | billing interface file |

## Data flow, branching & integration

- **Data flow** — each step passes its output dataset to the next; `PRICE` fans
  one priced file out to two consumers.
- **Branching** — the priced file is read by two parallel steps (report, extract).
- **Integration** — the billing interface file is the seam to the downstream
  billing system.
- **Change impact** — a change in `PRICE` ripples through the priced file into
  both downstream outputs; tracing that ripple is the core analysis task.
