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

## Tech stack

**Mainframe (target platform)**
- **IBM z/OS** — the mainframe operating system (modern successor to MVS)
- **COBOL** — the application language (Enterprise COBOL on z/OS)
- **JCL** — Job Control Language; runs and wires the batch jobs
- **VSAM (KSDS)** — keyed file storage for the parts catalogue
- **IDCAMS** — VSAM utility (DEFINE the cluster, REPRO to load it)
- **DFSORT / SORT** — sort utility used in the pipeline
- **DB2 + embedded SQL** — relational store for the sales summary *(planned step)*
- **IMS** — hierarchical database *(covered conceptually in the cookbook)*

**Modern dev toolchain (macOS / Apple Silicon)**
- **VS Code** — editor
- **IBM Z Open Editor** — COBOL / JCL / PL-I language support
- **Zowe Explorer** — z/OS connectivity: datasets, submit JCL, read job output
- **IBM Z Xplore** — free cloud z/OS for integration runs
- **Java 21 (OpenJDK / Temurin)** — runtime for the Z Open Editor language server

**Local build & test (no mainframe needed)**
- **GnuCOBOL (`cobc`)** — compiles and runs COBOL locally on the Mac
- **Make** — `make test` build & test runner
- **Scenario unit tests** — pricing logic tested per branch, PASS/FAIL, non-zero exit

**Downstream integration targets (illustrative)**
- **SAP FI** — invoicing interface file
- **WMS** — warehouse pick list
- **BI / reporting** — daily sales summary (via DB2)

**Project & docs**
- **Git / GitHub** — version control
- **Mermaid** — architecture & flow diagrams
- **Markdown** — docs + a learning cookbook

**Approach**
- AI-assisted, documentation-first development
- Pricing logic separated from I/O (unit-testable)
- Two-layer testing: unit (local GnuCOBOL) + integration (z/OS)

Setup steps in [docs/setup.md](docs/setup.md).

## Structure

| Path | What |
|------|------|
| `copybook/` | Shared record layouts (copybooks) |
| `parts-vsam/` | Parts master — VSAM KSDS define, load, read |
| `order-pricing/` | `ORDPROC` — order pricing batch + JCL + sample data |
| `order-report/` | `ORDRPT` — control-break country report |
| `docs/` | Use cases, architecture diagrams, setup |

## Run it locally

No mainframe needed — [GnuCOBOL](https://gnucobol.sourceforge.io/) compiles and
runs the COBOL on a laptop:

```sh
brew install gnucobol     # once
make test                 # unit tests for the pricing logic
make run                  # whole pipeline: price -> report -> SAP extract
```

`make run` loads the catalogue, prices the sample orders, prints the
control-break country report and writes the SAP interface file. The DB2 load is
the only step that needs a real z/OS.

## Status

🚧 Work in progress — parts catalogue (VSAM), order pricing (COBOL) and the
pipeline design are in place; pricing logic is **unit-tested locally**
(`make test`). Report, invoicing extract and DB2 load are next.
