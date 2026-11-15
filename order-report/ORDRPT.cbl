      *================================================================
      * ORDRPT - country sales report (control-break).
      *
      * Reads the priced orders (ASSUMED sorted by country) and prints:
      *   - a detail line per order,
      *   - a SUBTOTAL line whenever the country changes,
      *   - a GRAND TOTAL at the end.
      * "Control break" = act on the boundary where a key (country)
      * changes between one record and the next.
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ORDRPT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRICED-FILE ASSIGN TO PRICEDDD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-STATUS.
           SELECT REPORT-FILE ASSIGN TO RPTOUT
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  PRICED-FILE.
           COPY PRICEREC.
       FD  REPORT-FILE.
       01  REPORT-LINE        PIC X(72).

       WORKING-STORAGE SECTION.
       01  WS-STATUS          PIC X(02).
       01  WS-EOF             PIC X(01) VALUE 'N'.
      *    control-break bookkeeping
       01  WS-PREV-COUNTRY    PIC X(02) VALUE SPACES.
       01  WS-FIRST           PIC X(01) VALUE 'Y'.
       01  WS-CTRY-TOTAL      PIC 9(11)V99 VALUE 0.
       01  WS-GRAND-TOTAL     PIC 9(11)V99 VALUE 0.
      *    formatted lines
       01  WS-DETAIL.
           05  FILLER         PIC X(04) VALUE SPACES.
           05  WD-ORD-ID      PIC X(08).
           05  FILLER         PIC X(02) VALUE SPACES.
           05  WD-PART-NO     PIC X(10).
           05  FILLER         PIC X(02) VALUE SPACES.
           05  WD-COUNTRY     PIC X(02).
           05  FILLER         PIC X(02) VALUE SPACES.
           05  WD-GROSS       PIC Z,ZZZ,ZZ9.99.
       01  WS-SUBTOTAL.
           05  FILLER         PIC X(04) VALUE 'SUB '.
           05  WS-ST-COUNTRY  PIC X(02).
           05  FILLER         PIC X(02) VALUE SPACES.
           05  WS-ST-AMOUNT   PIC Z,ZZZ,ZZ9.99.
       01  WS-GRAND.
           05  FILLER         PIC X(12) VALUE 'GRAND TOTAL '.
           05  WS-GR-AMOUNT   PIC Z,ZZZ,ZZ9.99.

       PROCEDURE DIVISION.
       MAIN.
           OPEN INPUT  PRICED-FILE
           OPEN OUTPUT REPORT-FILE
           PERFORM READ-PRICED

           PERFORM UNTIL WS-EOF = 'Y'
      *        country changed -> close off the previous group
               IF PR-COUNTRY NOT = WS-PREV-COUNTRY
                   IF WS-FIRST = 'N'
                       PERFORM WRITE-SUBTOTAL
                   END-IF
                   MOVE PR-COUNTRY TO WS-PREV-COUNTRY
                   MOVE 'N' TO WS-FIRST
                   MOVE 0 TO WS-CTRY-TOTAL
               END-IF
      *        accumulate and print this order
               ADD PR-GROSS TO WS-CTRY-TOTAL
               ADD PR-GROSS TO WS-GRAND-TOTAL
               PERFORM WRITE-DETAIL
               PERFORM READ-PRICED
           END-PERFORM

      *    last group subtotal + grand total
           IF WS-FIRST = 'N'
               PERFORM WRITE-SUBTOTAL
           END-IF
           PERFORM WRITE-GRAND

           CLOSE PRICED-FILE
           CLOSE REPORT-FILE
           GOBACK.

       READ-PRICED.
           READ PRICED-FILE
             AT END MOVE 'Y' TO WS-EOF
           END-READ.

       WRITE-DETAIL.
           MOVE PR-ORD-ID  TO WD-ORD-ID
           MOVE PR-PART-NO TO WD-PART-NO
           MOVE PR-COUNTRY TO WD-COUNTRY
           MOVE PR-GROSS   TO WD-GROSS
           WRITE REPORT-LINE FROM WS-DETAIL.

       WRITE-SUBTOTAL.
           MOVE WS-PREV-COUNTRY TO WS-ST-COUNTRY
           MOVE WS-CTRY-TOTAL   TO WS-ST-AMOUNT
           WRITE REPORT-LINE FROM WS-SUBTOTAL.

       WRITE-GRAND.
           MOVE WS-GRAND-TOTAL TO WS-GR-AMOUNT
           WRITE REPORT-LINE FROM WS-GRAND.
