      *----------------------------------------------------------------
      * ORDREC - incoming spare-part order record (copybook)
      *----------------------------------------------------------------
       01  ORDER-RECORD.
      *        order id
           05  ORD-ID        PIC X(08).
      *        country code (drives the VAT rate): CZ / DE / AT ...
           05  ORD-COUNTRY   PIC X(02).
      *        which part was ordered (matches a key in the catalogue)
           05  ORD-PART-NO   PIC X(10).
      *        how many pieces
           05  ORD-QTY       PIC 9(05).
      *----------------------------------------------------------------
      * record length = 8 + 2 + 10 + 5 = 25 bytes (fixed)
      *----------------------------------------------------------------
