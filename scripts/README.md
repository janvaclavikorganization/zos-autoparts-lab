# scripts/

Helpers for the **local** GnuCOBOL run (not part of the z/OS code).

- `PARTLOAD.cbl` — loads `parts.dat` into an indexed file so `ORDPROC` can look
  parts up by key on a laptop. On z/OS this job is done by IDCAMS
  (`DEFPARTS` + `LOADPART`) instead.

The run itself is driven by [`run-local.sh`](../run-local.sh) (`make run`).
