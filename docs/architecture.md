# Architecture

## Data flow

```mermaid
flowchart LR
    ORD[Daily orders<br/>flat file] --> PROC[ORDPROC<br/>pricing batch]
    PM[(Parts master<br/>VSAM KSDS)] --> PROC
    PROC --> PRICED[Priced orders<br/>flat file]
    PROC --> SUM[Run summary<br/>counts / totals / errors]
    PRICED --> RPT[ORDRPT<br/>country report]
    RPT --> OUT[Country sales<br/>report]
```

## Components

```mermaid
flowchart TB
    CPY[PARTREC<br/>copybook]
    PM[(PARTSMST<br/>VSAM KSDS)]
    PROC[ORDPROC<br/>price orders]
    RPT[ORDRPT<br/>country report]
    CPY -.shared layout.-> PM
    CPY -.shared layout.-> PROC
    PM --> PROC
    PROC --> RPT
```

## Pricing sequence (UC-2)

```mermaid
sequenceDiagram
    participant S as Order file
    participant P as ORDPROC
    participant V as Parts master (VSAM)
    participant O as Priced file
    loop every order record
        S->>P: read order (country, part, qty)
        P->>V: read part by key
        alt part found
            V-->>P: base price, category
            P->>P: line = base x qty, + country VAT
            P->>O: write priced order
        else part missing / bad data
            P->>O: flag as error (kept, not dropped)
        end
    end
    P->>P: write run summary (counts, totals)
```

## Design notes

- **Money as packed decimal** (`COMP-3`) — exact, no floating point.
- **Country VAT** resolved by a small decision table (country → rate); an unknown
  country is an explicit error path, never silently zero.
- **Errors are kept and flagged**, never dropped — a priced run is fully
  reconcilable against its input record count.
