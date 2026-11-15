      *----------------------------------------------------------------
      * PARTREC - spare-part master record layout (copybook)
      *
      * COPY'd into every program that touches the parts master, so the
      * record shape lives in exactly one place (a shared struct / DTO).
      *----------------------------------------------------------------
       01  PART-RECORD.
      *        part number - first 10 bytes, used as the VSAM key
           05  PART-NO           PIC X(10).
      *        description, fixed 20 chars (space padded)
           05  PART-DESC         PIC X(20).
      *        category: BRK=brakes, FLT=filters, OIL=oils ...
           05  PART-CATEGORY     PIC X(03).
      *        base price: 7 integer + 2 decimal digits (implied '.')
      *        DISPLAY (zoned) so the load file is hand-typable; real
      *        money uses COMP-3 (packed), which we use when pricing.
           05  PART-BASE-PRICE   PIC 9(7)V99.
      *----------------------------------------------------------------
      * record length = 10 + 20 + 3 + 9 = 42 bytes (fixed)
      *----------------------------------------------------------------
