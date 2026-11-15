# copybook/

Shared record layouts (copybooks) included across programs.

- `PARTREC.cpy` — parts master record: part number (key), description,
  category, base price. Fixed-length, 42 bytes. `COPY`'d by the VSAM loader
  and the pricing program so the layout lives in one place.
