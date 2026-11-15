       IDENTIFICATION DIVISION.
       PROGRAM-ID. PRICECAL.
      *================================================================
      * PRICECAL - pure pricing logic, no file I/O.
      *
      * Kept separate from the batch program (ORDPROC) so the rules can
      * be unit-tested on their own. Given a country, a quantity and a
      * base price, it returns the gross amount and a status:
      *     status 'O' = ok,  'E' = unknown country (rate defaulted 0).
      *================================================================
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-RATE   PIC 9V999   COMP-3.
       01  WS-NET    PIC 9(9)V99 COMP-3.
       01  WS-VAT    PIC 9(9)V99 COMP-3.

       LINKAGE SECTION.
      *    inputs
       01  LK-COUNTRY   PIC X(02).
       01  LK-QTY       PIC 9(05).
       01  LK-PRICE     PIC 9(7)V99.
      *    outputs
       01  LK-GROSS     PIC 9(9)V99.
       01  LK-STATUS    PIC X(01).

       PROCEDURE DIVISION USING LK-COUNTRY LK-QTY LK-PRICE
                                LK-GROSS LK-STATUS.
      *    pick the VAT rate from the country; unknown -> error
           MOVE 'O' TO LK-STATUS
           EVALUATE LK-COUNTRY
             WHEN 'CZ' MOVE 0.210 TO WS-RATE
             WHEN 'DE' MOVE 0.190 TO WS-RATE
             WHEN 'AT' MOVE 0.200 TO WS-RATE
             WHEN OTHER
               MOVE 0.000 TO WS-RATE
               MOVE 'E'   TO LK-STATUS
           END-EVALUATE

      *    net = qty * price ;  gross = net + VAT
           COMPUTE WS-NET          = LK-QTY * LK-PRICE
           COMPUTE WS-VAT  ROUNDED = WS-NET * WS-RATE
           COMPUTE LK-GROSS        = WS-NET + WS-VAT
           GOBACK.
