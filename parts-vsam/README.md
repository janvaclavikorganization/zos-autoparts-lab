# parts-vsam/

The parts catalogue as a **VSAM KSDS** — key-sequenced, keyed by part number.

- `DEFPARTS.jcl` — IDCAMS `DEFINE CLUSTER` to create the KSDS.
- `parts.dat` — sample parts (fixed 42-byte records).
- `LOADPART.jcl` — IDCAMS `REPRO` to load `parts.dat` into the KSDS.
- `PARTRDR.cbl` / `RUNRDR.jcl` — a small reader that prints the catalogue
  (the first COBOL program, shows the 4 divisions and keyed file I/O).
