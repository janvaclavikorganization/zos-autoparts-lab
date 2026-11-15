      *================================================================
      * PARTLOAD - LOCAL-ONLY loader for the GnuCOBOL run harness.
      *
      * Reads parts.dat (sequential) and writes the parts as an INDEXED
      * file, so ORDPROC can look them up by key on a laptop. On z/OS
      * this is done by IDCAMS (DEFPARTS + LOADPART) instead.
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PARTLOAD.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT IN-FILE  ASSIGN TO PARTSIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-IN-ST.
           SELECT OUT-FILE ASSIGN TO PARTSDD
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS PART-NO
               FILE STATUS IS WS-OUT-ST.

       DATA DIVISION.
       FILE SECTION.
       FD  IN-FILE.
       01  IN-REC            PIC X(42).
       FD  OUT-FILE.
           COPY PARTREC.

       WORKING-STORAGE SECTION.
       01  WS-IN-ST          PIC X(02).
       01  WS-OUT-ST         PIC X(02).
       01  WS-EOF            PIC X(01) VALUE 'N'.
       01  WS-CNT            PIC 9(03) VALUE 0.

       PROCEDURE DIVISION.
       MAIN.
           OPEN INPUT  IN-FILE
           OPEN OUTPUT OUT-FILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ IN-FILE INTO PART-RECORD
                 AT END MOVE 'Y' TO WS-EOF
                 NOT AT END
                   WRITE PART-RECORD
                   ADD 1 TO WS-CNT
               END-READ
           END-PERFORM
           CLOSE IN-FILE
           CLOSE OUT-FILE
           DISPLAY 'PARTS LOADED: ' WS-CNT
           GOBACK.
