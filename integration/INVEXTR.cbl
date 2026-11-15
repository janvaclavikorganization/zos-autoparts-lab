      *================================================================
      * INVEXTR - build the invoicing interface file for SAP.
      *
      * Reads the priced orders and writes one fixed-format interface
      * record per successfully priced order (status 'O'). That output
      * file is the hand-off (integration seam) to the downstream
      * invoicing system.
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. INVEXTR.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRICED-FILE ASSIGN TO PRICEDDD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-STATUS.
           SELECT SAP-FILE ASSIGN TO SAPOUT
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  PRICED-FILE.
           COPY PRICEREC.
       FD  SAP-FILE.
      *    SAP invoicing interface record (fixed layout)
       01  SAP-RECORD.
           05  SAP-DOC-TYPE   PIC X(03).
           05  SAP-ORD-ID     PIC X(08).
           05  SAP-COUNTRY    PIC X(02).
           05  SAP-AMOUNT     PIC 9(11)V99.

       WORKING-STORAGE SECTION.
       01  WS-STATUS          PIC X(02).
       01  WS-EOF             PIC X(01) VALUE 'N'.
       01  WS-WRITTEN         PIC 9(05) VALUE 0.
       01  WS-WRITTEN-D       PIC Z(4)9.

       PROCEDURE DIVISION.
       MAIN.
           OPEN INPUT  PRICED-FILE
           OPEN OUTPUT SAP-FILE
           PERFORM READ-PRICED

           PERFORM UNTIL WS-EOF = 'Y'
      *        only successfully priced orders go to invoicing
               IF PR-STATUS = 'O'
                   PERFORM WRITE-SAP
               END-IF
               PERFORM READ-PRICED
           END-PERFORM

           CLOSE PRICED-FILE
           CLOSE SAP-FILE
           MOVE WS-WRITTEN TO WS-WRITTEN-D
           DISPLAY 'invoice records: ' WS-WRITTEN-D
           GOBACK.

       READ-PRICED.
           READ PRICED-FILE
             AT END MOVE 'Y' TO WS-EOF
           END-READ.

      *----------------------------------------------------------------
      * Map one priced order into the SAP interface layout.
      *----------------------------------------------------------------
       WRITE-SAP.
           MOVE 'INV'       TO SAP-DOC-TYPE
           MOVE PR-ORD-ID   TO SAP-ORD-ID
           MOVE PR-COUNTRY  TO SAP-COUNTRY
           MOVE PR-GROSS    TO SAP-AMOUNT
           WRITE SAP-RECORD
           ADD 1 TO WS-WRITTEN.
