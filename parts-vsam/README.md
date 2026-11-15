# parts-vsam/

Parts master as a **VSAM KSDS** — key-sequenced, keyed by part number (UC-1).

Planned:
- JCL to DEFINE the KSDS cluster (IDCAMS).
- JCL + data to load the initial parts.
- A small COBOL reader (random + sequential) to prove key access.
