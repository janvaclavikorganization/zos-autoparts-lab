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
