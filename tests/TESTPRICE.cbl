       IDENTIFICATION DIVISION.
       PROGRAM-ID. TESTPRICE.
      *================================================================
      * TESTPRICE - unit tests for the pricing logic (PRICECAL).
      *
      * Runs one scenario per case, checks the result, prints PASS/FAIL,
      * and exits non-zero if anything failed. No mainframe needed -
      * build & run locally with GnuCOBOL:
      *
      *   cobc -x -o build/testprice \
      *        tests/TESTPRICE.cbl order-pricing/PRICECAL.cbl
      *   ./build/testprice
      *================================================================
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-COUNTRY  PIC X(02).
       01  WS-QTY      PIC 9(05).
       01  WS-PRICE    PIC 9(7)V99.
       01  WS-GROSS    PIC 9(9)V99.
       01  WS-STATUS   PIC X(01).
       01  WS-FAILS    PIC 9(03) VALUE 0.

       PROCEDURE DIVISION.
       MAIN.
           DISPLAY '=== PRICECAL unit tests ==='

      *    1) happy path, CZ 21%: 2 x 24.50 = 49.00 -> 59.29
           MOVE 'CZ'    TO WS-COUNTRY
           MOVE 2       TO WS-QTY
           MOVE 24.50   TO WS-PRICE
           PERFORM CALL-PRICECAL
           PERFORM EXPECT-59-29-OK

      *    2) DE 19%: 2 x 24.50 = 49.00 -> 58.31
           MOVE 'DE'    TO WS-COUNTRY
           MOVE 2       TO WS-QTY
           MOVE 24.50   TO WS-PRICE
           PERFORM CALL-PRICECAL
           PERFORM EXPECT-58-31-OK

      *    3) AT 20%: 2 x 24.50 = 49.00 -> 58.80
           MOVE 'AT'    TO WS-COUNTRY
           MOVE 2       TO WS-QTY
           MOVE 24.50   TO WS-PRICE
           PERFORM CALL-PRICECAL
           PERFORM EXPECT-58-80-OK

      *    4) branch: unknown country -> status 'E', VAT 0
           MOVE 'XX'    TO WS-COUNTRY
           MOVE 2       TO WS-QTY
           MOVE 24.50   TO WS-PRICE
           PERFORM CALL-PRICECAL
           PERFORM EXPECT-ERROR

      *    5) edge: zero quantity -> gross 0, status 'O'
           MOVE 'CZ'    TO WS-COUNTRY
           MOVE 0       TO WS-QTY
           MOVE 24.50   TO WS-PRICE
           PERFORM CALL-PRICECAL
           PERFORM EXPECT-ZERO-OK

           DISPLAY '==========================='
           IF WS-FAILS = 0
               DISPLAY 'ALL TESTS PASSED'
               MOVE 0 TO RETURN-CODE
           ELSE
               DISPLAY WS-FAILS ' TEST(S) FAILED'
               MOVE 8 TO RETURN-CODE
           END-IF
           GOBACK.

       CALL-PRICECAL.
           CALL 'PRICECAL' USING WS-COUNTRY WS-QTY WS-PRICE
                                 WS-GROSS WS-STATUS.

       EXPECT-59-29-OK.
           IF WS-GROSS = 59.29 AND WS-STATUS = 'O'
               DISPLAY 'PASS  CZ 21% -> ' WS-GROSS
           ELSE
               DISPLAY 'FAIL  CZ expected 59.29/O got '
                       WS-GROSS '/' WS-STATUS
               ADD 1 TO WS-FAILS
           END-IF.

       EXPECT-58-31-OK.
           IF WS-GROSS = 58.31 AND WS-STATUS = 'O'
               DISPLAY 'PASS  DE 19% -> ' WS-GROSS
           ELSE
               DISPLAY 'FAIL  DE expected 58.31/O got '
                       WS-GROSS '/' WS-STATUS
               ADD 1 TO WS-FAILS
           END-IF.

       EXPECT-58-80-OK.
           IF WS-GROSS = 58.80 AND WS-STATUS = 'O'
               DISPLAY 'PASS  AT 20% -> ' WS-GROSS
           ELSE
               DISPLAY 'FAIL  AT expected 58.80/O got '
                       WS-GROSS '/' WS-STATUS
               ADD 1 TO WS-FAILS
           END-IF.

       EXPECT-ERROR.
           IF WS-STATUS = 'E'
               DISPLAY 'PASS  unknown country -> status E'
           ELSE
               DISPLAY 'FAIL  unknown country expected E got '
                       WS-STATUS
               ADD 1 TO WS-FAILS
           END-IF.

       EXPECT-ZERO-OK.
           IF WS-GROSS = 0 AND WS-STATUS = 'O'
               DISPLAY 'PASS  zero qty -> ' WS-GROSS
           ELSE
               DISPLAY 'FAIL  zero qty expected 0/O got '
                       WS-GROSS '/' WS-STATUS
               ADD 1 TO WS-FAILS
           END-IF.
