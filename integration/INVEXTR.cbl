      *================================================================
      * INVEXTR - build the invoicing interface file for the billing
      * system.
      *
      * Reads the priced orders and writes one fixed-format interface
      * record per successfully priced order (status 'O'). That output
      * file is the hand-off (integration seam) to the billing system.
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. INVEXTR.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRICED-FILE ASSIGN TO PRICEDDD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-STATUS.
           SELECT BILL-FILE ASSIGN TO BILLOUT
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  PRICED-FILE.
           COPY PRICEREC.
       FD  BILL-FILE.
      *    billing interface record (fixed layout)
       01  BILL-RECORD.
           05  BILL-DOC-TYPE  PIC X(03).
           05  BILL-ORD-ID    PIC X(08).
           05  BILL-COUNTRY   PIC X(02).
           05  BILL-AMOUNT    PIC 9(11)V99.

       WORKING-STORAGE SECTION.
       01  WS-STATUS          PIC X(02).
       01  WS-EOF             PIC X(01) VALUE 'N'.
       01  WS-WRITTEN         PIC 9(05) VALUE 0.
       01  WS-WRITTEN-D       PIC Z(4)9.

       PROCEDURE DIVISION.
       MAIN.
           OPEN INPUT  PRICED-FILE
           OPEN OUTPUT BILL-FILE
           PERFORM READ-PRICED

           PERFORM UNTIL WS-EOF = 'Y'
      *        only successfully priced orders go to billing
               IF PR-STATUS = 'O'
                   PERFORM WRITE-BILL
               END-IF
               PERFORM READ-PRICED
           END-PERFORM

           CLOSE PRICED-FILE
           CLOSE BILL-FILE
           MOVE WS-WRITTEN TO WS-WRITTEN-D
           DISPLAY 'invoice records: ' WS-WRITTEN-D
           GOBACK.

       READ-PRICED.
           READ PRICED-FILE
             AT END MOVE 'Y' TO WS-EOF
           END-READ.

      *----------------------------------------------------------------
      * Map one priced order into the billing interface layout.
      *----------------------------------------------------------------
       WRITE-BILL.
           MOVE 'INV'       TO BILL-DOC-TYPE
           MOVE PR-ORD-ID   TO BILL-ORD-ID
           MOVE PR-COUNTRY  TO BILL-COUNTRY
           MOVE PR-GROSS    TO BILL-AMOUNT
           WRITE BILL-RECORD
           ADD 1 TO WS-WRITTEN.
