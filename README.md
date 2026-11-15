# zos-autoparts-lab

A compact, runnable **IBM z/OS mainframe** project modelling one slice of an
automotive **spare-parts distribution** core system — the kind of batch workload
that runs on real enterprise mainframes behind dealer networks and parts logistics.

Written with a **modern, AI-assisted, VS Code–based** workflow (instead of the
classic green-screen terminal), and runnable on a laptop with GnuCOBOL.

## What it does

A daily batch that prices incoming spare-parts orders against a parts catalogue,
then fans the result out to a report and two downstream systems:

1. **Parts catalogue** — a keyed master file (VSAM KSDS): price, description, category.
2. **Order pricing** — read the day's orders, look up each part, compute line price + per-country VAT.
3. **Country report** — control-break subtotals per country + grand total.
4. **Invoicing interface** — a fixed-format hand-off file for SAP.
5. **Sales summary** — loaded into a DB2 table via embedded SQL.

See [docs/pipeline.md](docs/pipeline.md) for the flow diagram,
[docs/use-cases.md](docs/use-cases.md) for the use cases, and
[docs/architecture.md](docs/architecture.md) for the internals.

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

## Tech stack

**Mainframe (target platform)**
- **IBM z/OS** — the mainframe operating system (modern successor to MVS)
- **COBOL** — the application language (Enterprise COBOL on z/OS)
- **JCL** — Job Control Language; runs and wires the batch jobs
- **VSAM (KSDS)** — keyed file storage for the parts catalogue
- **IDCAMS** — VSAM utility (DEFINE the cluster, REPRO to load it)
- **DFSORT / SORT** — sort utility used in the pipeline
- **DB2 + embedded SQL** — relational store for the sales summary *(built; needs a DB2 runtime)*
- **IMS** — hierarchical database *(conceptual contrast to VSAM)*

**Modern dev toolchain (macOS / Apple Silicon)**
- **VS Code** — editor
- **IBM Z Open Editor** — COBOL / JCL / PL-I language support
- **Zowe Explorer** — z/OS connectivity: datasets, submit JCL, read job output
- **IBM Z Xplore** — free cloud z/OS for integration runs
- **Java 21 (OpenJDK / Temurin)** — runtime for the Z Open Editor language server

**Local build & test (no mainframe needed)**
- **GnuCOBOL (`cobc`)** — compiles and runs the COBOL locally
- **Make** — `make test` (unit tests) and `make run` (full pipeline)
- **Scenario unit tests** — pricing logic tested per branch, PASS/FAIL, non-zero exit

**Downstream integration targets (illustrative)**
- **SAP FI** — invoicing interface file
- **BI / reporting** — daily sales summary (via DB2)

**Approach**
- AI-assisted, documentation-first development
- Pricing logic separated from I/O (unit-testable)
- Two-layer testing: unit (local GnuCOBOL) + integration (z/OS)

Setup details in [docs/setup.md](docs/setup.md).

## Structure

| Path | What |
|------|------|
| `copybook/` | Shared record layouts (PARTREC, ORDREC, PRICEREC) |
| `parts-vsam/` | Parts catalogue — VSAM define, load, reader |
| `order-pricing/` | Pricing rules (`PRICECAL`), batch (`ORDPROC`), orchestration (`DAILYRUN`) |
| `order-report/` | `ORDRPT` — control-break country report |
| `integration/` | SAP extract (`INVEXTR`), DB2 load (`SALESDB2`), table DDL |
| `tests/` | Unit tests for the pricing logic |
| `scripts/` | Local run helper |
| `docs/` | Use cases, pipeline, architecture, setup |

## Status

The pipeline is built and runs locally end-to-end (`make run`): catalogue →
pricing → country report → SAP interface. Pricing logic is unit-tested
(`make test`). The DB2 load is written (embedded SQL) and runs on a real z/OS
with DB2.
