# zos-autoparts-lab

A small, self-contained **IBM z/OS mainframe** project modelling one slice of an
automotive **spare-parts distribution** core system — the kind of batch workload
that runs on real enterprise mainframes behind dealer networks and parts logistics.

Built as a hands-on learning lab for COBOL, JCL and VSAM on a real z/OS
environment, using a **modern, AI-assisted, VS Code–based** workflow instead of
the classic green-screen terminal.

## What it does

A daily batch that prices incoming spare-parts orders against a parts master
catalogue and produces a per-country sales report:

1. **Parts catalogue** — a keyed master file (VSAM KSDS): price, description, category.
2. **Order pricing** — read the day's orders, look up each part, compute line price + per-country VAT.
3. **Country report** — group priced orders by country / dealer with subtotals.

See [docs/use-cases.md](docs/use-cases.md) for the use cases and
[docs/architecture.md](docs/architecture.md) for the data flow and diagrams.

## Toolchain

- **z/OS** — IBM Z Xplore (free cloud z/OS environment)
- **Editor** — VS Code + IBM Z Open Editor (COBOL / JCL language support)
- **Connectivity** — Zowe Explorer (datasets, JCL job submit, job output)
- **Languages / storage** — COBOL, JCL, VSAM

Setup steps in [docs/setup.md](docs/setup.md).

## Structure

| Path | What |
|------|------|
| `copybook/` | Shared record layouts (copybooks) |
| `parts-vsam/` | Parts master — VSAM KSDS define, load, read |
| `order-pricing/` | `ORDPROC` — order pricing batch + JCL + sample data |
| `order-report/` | `ORDRPT` — control-break country report |
| `docs/` | Use cases, architecture diagrams, setup |

## Status

🚧 Scaffold — environment and design in place; programs being filled in.
