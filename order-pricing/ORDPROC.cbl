      *================================================================
      * ORDPROC - price incoming spare-part orders.
      *
      * Same shape as the reader (OPEN -> LOOP -> CLOSE), but for each
      * order we do three extra things inside the loop:
      *   1) look up the part in the catalogue (read it by key),
      *   2) work out the price (qty x base price + country VAT),
      *   3) print the priced line (or an error if the part is unknown).
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ORDPROC.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    ORDERS-FILE = flat input file of orders, read in sequence
           SELECT ORDERS-FILE ASSIGN TO ORDERSDD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-ORD-STATUS.
      *    PARTS-FILE = the VSAM catalogue; RANDOM lets us fetch one
      *    part straight by its key (the part number)
           SELECT PARTS-FILE ASSIGN TO PARTSDD
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS PART-NO
               FILE STATUS IS WS-PRT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  ORDERS-FILE.
           COPY ORDREC.
       FD  PARTS-FILE.
           COPY PARTREC.

       WORKING-STORAGE SECTION.
      *    status codes of the last file operation
       01  WS-ORD-STATUS  PIC X(02).
       01  WS-PRT-STATUS  PIC X(02).
      *    end-of-file flag for the orders file
       01  WS-EOF         PIC X(01) VALUE 'N'.
      *    counters
       01  WS-PRICED      PIC 9(05) VALUE 0.
       01  WS-ERRORS      PIC 9(05) VALUE 0.
      *    money - packed decimal (COMP-3) for exact arithmetic
       01  WS-RATE        PIC 9V999    COMP-3.
       01  WS-NET         PIC 9(9)V99  COMP-3.
       01  WS-VAT         PIC 9(9)V99  COMP-3.
       01  WS-GROSS       PIC 9(9)V99  COMP-3.

       PROCEDURE DIVISION.
       MAIN.
      *    open the orders (to read) and the catalogue (to look up)
           OPEN INPUT ORDERS-FILE
           OPEN INPUT PARTS-FILE

      *    WHILE loop over every order until end-of-file
           PERFORM UNTIL WS-EOF = 'Y'
               READ ORDERS-FILE
                 AT END
                   MOVE 'Y' TO WS-EOF
                 NOT AT END
      *                hand this one order off to be priced
                   PERFORM PRICE-ONE-ORDER
               END-READ
           END-PERFORM

      *    done: close both files and print the run totals
           CLOSE ORDERS-FILE
           CLOSE PARTS-FILE
           DISPLAY 'PRICED: ' WS-PRICED '  ERRORS: ' WS-ERRORS
           GOBACK.

      *----------------------------------------------------------------
      * Price one order: look the part up, compute, print.
      *----------------------------------------------------------------
       PRICE-ONE-ORDER.
      *    put the order's part number into the catalogue key...
           MOVE ORD-PART-NO TO PART-NO
      *    ...and fetch that single part straight by key
           READ PARTS-FILE KEY IS PART-NO
             INVALID KEY
      *            part not in catalogue -> count it as an error
               ADD 1 TO WS-ERRORS
               DISPLAY ORD-ID ' ERR part ' ORD-PART-NO ' not found'
             NOT INVALID KEY
      *            found it -> pick the VAT rate, then do the maths
               PERFORM SET-VAT-RATE
               COMPUTE WS-NET   = ORD-QTY * PART-BASE-PRICE
               COMPUTE WS-VAT   = WS-NET * WS-RATE
               COMPUTE WS-GROSS = WS-NET + WS-VAT
               ADD 1 TO WS-PRICED
               DISPLAY ORD-ID ' ' ORD-PART-NO
                   ' QTY ' ORD-QTY ' GROSS ' WS-GROSS
           END-READ.

      *----------------------------------------------------------------
      * Country -> VAT rate (a small decision table).
      *----------------------------------------------------------------
       SET-VAT-RATE.
           EVALUATE ORD-COUNTRY
             WHEN 'CZ' MOVE 0.210 TO WS-RATE
             WHEN 'DE' MOVE 0.190 TO WS-RATE
             WHEN 'AT' MOVE 0.200 TO WS-RATE
             WHEN OTHER MOVE 0.000 TO WS-RATE
           END-EVALUATE.
