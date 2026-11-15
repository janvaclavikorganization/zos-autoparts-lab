      *================================================================
      * ORDPROC - price incoming spare-part orders.
      *
      * For each order: look the part up in the catalogue (VSAM, by
      * key), apply the shared pricing rules (PRICECAL), and write a
      * priced record. Same OPEN -> LOOP -> CLOSE shape as the reader.
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
      *    PARTS-FILE = VSAM catalogue; RANDOM = fetch one by key
           SELECT PARTS-FILE ASSIGN TO PARTSDD
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS PART-NO
               FILE STATUS IS WS-PRT-STATUS.
      *    PRICED-FILE = flat output file of priced orders
           SELECT PRICED-FILE ASSIGN TO PRICEDDD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-PRC-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  ORDERS-FILE.
           COPY ORDREC.
       FD  PARTS-FILE.
           COPY PARTREC.
       FD  PRICED-FILE.
           COPY PRICEREC.

       WORKING-STORAGE SECTION.
      *    status codes of the last file operation
       01  WS-ORD-STATUS  PIC X(02).
       01  WS-PRT-STATUS  PIC X(02).
       01  WS-PRC-STATUS  PIC X(02).
      *    end-of-file flag for the orders file
       01  WS-EOF         PIC X(01) VALUE 'N'.
      *    counters
       01  WS-PRICED      PIC 9(05) VALUE 0.
       01  WS-ERRORS      PIC 9(05) VALUE 0.
      *    outputs returned by PRICECAL
       01  WS-GROSS       PIC 9(9)V99.
       01  WS-PSTATUS     PIC X(01).

       PROCEDURE DIVISION.
       MAIN.
      *    orders in, catalogue to look up, priced orders out
           OPEN INPUT  ORDERS-FILE
           OPEN INPUT  PARTS-FILE
           OPEN OUTPUT PRICED-FILE

      *    WHILE loop over every order until end-of-file
           PERFORM UNTIL WS-EOF = 'Y'
               READ ORDERS-FILE
                 AT END
                   MOVE 'Y' TO WS-EOF
                 NOT AT END
                   PERFORM PRICE-ONE-ORDER
               END-READ
           END-PERFORM

           CLOSE ORDERS-FILE
           CLOSE PARTS-FILE
           CLOSE PRICED-FILE
           DISPLAY 'PRICED: ' WS-PRICED '  ERRORS: ' WS-ERRORS
           GOBACK.

      *----------------------------------------------------------------
      * Price one order: look the part up, call the rules, write it.
      *----------------------------------------------------------------
       PRICE-ONE-ORDER.
      *    put the order's part number into the catalogue key...
           MOVE ORD-PART-NO TO PART-NO
      *    ...and fetch that single part by key
           READ PARTS-FILE KEY IS PART-NO
             INVALID KEY
      *            part not in catalogue -> count it as an error
               ADD 1 TO WS-ERRORS
               DISPLAY ORD-ID ' ERR part ' ORD-PART-NO ' not found'
             NOT INVALID KEY
      *            found it -> apply the shared pricing rules...
               CALL 'PRICECAL' USING ORD-COUNTRY ORD-QTY
                                     PART-BASE-PRICE
                                     WS-GROSS WS-PSTATUS
      *            ...and write the priced record
               PERFORM WRITE-PRICED
               ADD 1 TO WS-PRICED
           END-READ.

      *----------------------------------------------------------------
      * Build and write one priced output record.
      *----------------------------------------------------------------
       WRITE-PRICED.
           MOVE ORD-ID      TO PR-ORD-ID
           MOVE ORD-PART-NO TO PR-PART-NO
           MOVE ORD-COUNTRY TO PR-COUNTRY
           MOVE ORD-QTY     TO PR-QTY
           MOVE WS-GROSS    TO PR-GROSS
           MOVE WS-PSTATUS  TO PR-STATUS
           WRITE PRICED-RECORD.
