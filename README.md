# zos-autoparts-lab

A compact, runnable **IBM z/OS mainframe** simulation project modelling one slice
of an automotive **spare-parts distribution** core system.

## What it does

A daily batch that prices incoming spare-parts orders against a parts catalogue,
then reports and hands the result off:

1. **Parts catalogue** — a keyed master file (VSAM KSDS): price, description, category.
2. **Order pricing** — read the day's orders, look up each part, compute line price + per-country VAT.
3. **Country report** — control-break subtotals per country + grand total.
4. **Invoicing interface** — a fixed-format hand-off file for the billing system.

See [docs/pipeline.md](docs/pipeline.md) for the flow,
[docs/use-cases.md](docs/use-cases.md) for the use cases, and
[docs/architecture.md](docs/architecture.md) for the internals.

## Run it locally

[GnuCOBOL](https://gnucobol.sourceforge.io/) compiles and runs the COBOL on a laptop:

```sh
brew install gnucobol     # once
make test                 # unit tests for the pricing logic
make run                  # whole pipeline: price -> report -> invoice extract
```

## Tech stack

**Mainframe technologies (the code)**
- **COBOL** — the application programs
- **JCL** — the z/OS job definitions
- **VSAM (KSDS)** — keyed file storage for the parts catalogue
- **IDCAMS** — VSAM DEFINE / REPRO (in the JCL)

**Built & run with**
- **VS Code + IBM Z Open Editor** — COBOL / JCL editing (syntax, column rulers; needs Java 21)
- **GnuCOBOL (`cobc`)** — compiles and runs the COBOL locally
- **Make** — `make test` (unit tests) and `make run` (full pipeline)

**Approach**
- Pricing logic separated from I/O (unit-testable)
- Documentation-first

## Structure

| Path | What |
|------|------|
| `copybook/` | Shared record layouts (PARTREC, ORDREC, PRICEREC) |
| `parts-vsam/` | Parts catalogue — VSAM define, load, reader (JCL + COBOL) |
| `order-pricing/` | Pricing rules (`PRICECAL`), batch (`ORDPROC`), orchestration (`DAILYRUN`) |
| `order-report/` | `ORDRPT` — control-break country report |
| `integration/` | `INVEXTR` — invoicing interface extract |
| `tests/` | Unit tests for the pricing logic |
| `scripts/` | Local run helper |
| `docs/` | Use cases, pipeline, architecture, setup |

## Status

Runs locally end-to-end with GnuCOBOL (`make run`): catalogue → pricing →
country report → invoicing interface. Pricing logic is unit-tested (`make test`).
The JCL is the z/OS job definitions (not executed locally).
