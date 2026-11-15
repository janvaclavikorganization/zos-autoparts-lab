      *================================================================
      * SALESDB2 - load the day's priced orders into a DB2 table.
      *
      * Shows embedded SQL in COBOL: the `EXEC SQL ... END-EXEC` blocks
      * are turned into DB2 calls by the DB2 pre-compiler, then the
      * program is compiled, linked and BOUND into a DB2 plan.
      *
      * NOTE: needs the DB2 pre-compile + bind + a DB2 runtime; it does
      * not build under plain GnuCOBOL. Table DDL: integration/SALES.sql
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SALESDB2.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRICED-FILE ASSIGN TO PRICEDDD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  PRICED-FILE.
           COPY PRICEREC.

       WORKING-STORAGE SECTION.
       01  WS-STATUS          PIC X(02).
       01  WS-EOF             PIC X(01) VALUE 'N'.
       01  WS-INSERTED        PIC 9(05) VALUE 0.

      *    DB2 communication area (filled in by DB2 after each call)
           EXEC SQL INCLUDE SQLCA END-EXEC.

      *    host variables - the bridge between COBOL and SQL
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  HV-ORD-ID    PIC X(08).
       01  HV-PART-NO   PIC X(10).
       01  HV-COUNTRY   PIC X(02).
       01  HV-QTY       PIC S9(05) COMP.
       01  HV-GROSS     PIC S9(11)V99 COMP-3.
       01  HV-STATUS    PIC X(01).
           EXEC SQL END DECLARE SECTION END-EXEC.

       PROCEDURE DIVISION.
       MAIN.
           OPEN INPUT PRICED-FILE
           PERFORM READ-PRICED

           PERFORM UNTIL WS-EOF = 'Y'
               PERFORM INSERT-ROW
               PERFORM READ-PRICED
           END-PERFORM

      *    commit the whole batch at the end
           EXEC SQL COMMIT END-EXEC

           CLOSE PRICED-FILE
           DISPLAY 'DB2 ROWS INSERTED: ' WS-INSERTED
           GOBACK.

       READ-PRICED.
           READ PRICED-FILE
             AT END MOVE 'Y' TO WS-EOF
           END-READ.

      *----------------------------------------------------------------
      * Insert one priced order into the SALES table.
      *----------------------------------------------------------------
       INSERT-ROW.
           MOVE PR-ORD-ID  TO HV-ORD-ID
           MOVE PR-PART-NO TO HV-PART-NO
           MOVE PR-COUNTRY TO HV-COUNTRY
           MOVE PR-QTY     TO HV-QTY
           MOVE PR-GROSS   TO HV-GROSS
           MOVE PR-STATUS  TO HV-STATUS

           EXEC SQL
               INSERT INTO SALES
                   (ORD_ID, PART_NO, COUNTRY, QTY, GROSS, STATUS)
               VALUES
                   (:HV-ORD-ID, :HV-PART-NO, :HV-COUNTRY,
                    :HV-QTY, :HV-GROSS, :HV-STATUS)
           END-EXEC

      *    SQLCODE 0 = ok; anything else = problem
           IF SQLCODE = 0
               ADD 1 TO WS-INSERTED
           ELSE
               DISPLAY 'DB2 INSERT FAILED, SQLCODE=' SQLCODE
                       ' ORDER=' PR-ORD-ID
           END-IF.
