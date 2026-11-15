       IDENTIFICATION DIVISION.
       PROGRAM-ID. PARTRDR.
      *================================================================
      * Read the parts KSDS sequentially and print each part.
      *================================================================
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    wire program file PARTS-FILE to DD name PARTSDD;
      *    tell COBOL it is an indexed (KSDS) file keyed on PART-NO
           SELECT PARTS-FILE ASSIGN TO PARTSDD
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS PART-NO
               FILE STATUS IS WS-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  PARTS-FILE.
      *    reuse the shared record layout (the struct)
           COPY PARTREC.
       WORKING-STORAGE SECTION.
      *    little helpers we need while the program runs
       01  WS-STATUS   PIC X(02).
       01  WS-EOF      PIC X(01) VALUE 'N'.
       01  WS-COUNT    PIC 9(03) VALUE 0.
       PROCEDURE DIVISION.
       MAIN.
           OPEN INPUT PARTS-FILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ PARTS-FILE
                 AT END
                   MOVE 'Y' TO WS-EOF
                 NOT AT END
                   ADD 1 TO WS-COUNT
                   DISPLAY PART-NO ' ' PART-DESC ' ' PART-BASE-PRICE
               END-READ
           END-PERFORM
           CLOSE PARTS-FILE
           DISPLAY 'TOTAL PARTS READ: ' WS-COUNT
           GOBACK.
