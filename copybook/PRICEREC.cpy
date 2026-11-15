      *----------------------------------------------------------------
      * PRICEREC - priced order record (output of ORDPROC)
      *----------------------------------------------------------------
       01  PRICED-RECORD.
           05  PR-ORD-ID     PIC X(08).
           05  PR-PART-NO    PIC X(10).
           05  PR-COUNTRY    PIC X(02).
           05  PR-QTY        PIC 9(05).
           05  PR-GROSS      PIC 9(9)V99.
           05  PR-STATUS     PIC X(01).
      *----------------------------------------------------------------
      * record length = 8 + 10 + 2 + 5 + 11 + 1 = 37 bytes (fixed)
      * PR-STATUS: 'O' = ok, 'E' = unknown country (VAT defaulted 0)
      *----------------------------------------------------------------
