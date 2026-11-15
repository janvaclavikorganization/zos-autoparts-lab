      *================================================================
      * PARTRDR - read the parts catalogue and print every part.
      *
      * Shape of (almost) every batch program:
      *     OPEN the file  ->  LOOP reading it  ->  CLOSE it.
      * Everything else below is standard COBOL scaffolding.
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PARTRDR.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    Wire our internal name PARTS-FILE to the DD name PARTSDD
      *    (the JCL points PARTSDD at the real dataset).
      *    INDEXED    = it is a VSAM KSDS (keyed) file.
      *    SEQUENTIAL = we read it start-to-end, record by record.
           SELECT PARTS-FILE ASSIGN TO PARTSDD
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS PART-NO
               FILE STATUS IS WS-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  PARTS-FILE.
      *    The record layout comes from the shared copybook (reuse).
           COPY PARTREC.

       WORKING-STORAGE SECTION.
      *    result code of the last file operation
       01  WS-STATUS   PIC X(02).
      *    end-of-file flag: 'Y' once we run out of records
       01  WS-EOF      PIC X(01) VALUE 'N'.
      *    how many parts we have read so far
       01  WS-COUNT    PIC 9(03) VALUE 0.

       PROCEDURE DIVISION.
       MAIN.
      *    1) open the catalogue for reading
           OPEN INPUT PARTS-FILE

      *    2) WHILE loop over every record.
      *       PERFORM UNTIL = "keep looping while WS-EOF is still 'N'".
      *       WS-EOF flips to 'Y' when READ reaches the end (below),
      *       which ends the loop.
           PERFORM UNTIL WS-EOF = 'Y'

      *        read the next part record from the file
               READ PARTS-FILE
                 AT END
      *                no more records -> raise the flag, loop stops
                   MOVE 'Y' TO WS-EOF
                 NOT AT END
      *                got a record -> count it, then print one line
                   ADD 1 TO WS-COUNT
                   DISPLAY PART-NO ' ' PART-DESC ' ' PART-BASE-PRICE
               END-READ

           END-PERFORM

      *    3) finished -> close the file and print the total
           CLOSE PARTS-FILE
           DISPLAY 'TOTAL PARTS READ: ' WS-COUNT
           GOBACK.
