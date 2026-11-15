-- DB2 table for the daily sales summary (loaded by SALESDB2).
-- Relational store (contrast to the VSAM operational files); BI /
-- reporting queries it with ordinary SQL.

CREATE TABLE SALES (
    ORD_ID   CHAR(8)       NOT NULL,
    PART_NO  CHAR(10)      NOT NULL,
    COUNTRY  CHAR(2)       NOT NULL,
    QTY      INTEGER       NOT NULL,
    GROSS    DECIMAL(13,2) NOT NULL,
    STATUS   CHAR(1)       NOT NULL,
    PRIMARY KEY (ORD_ID)
);

-- Example BI query: sales per country
--   SELECT COUNTRY, SUM(GROSS) AS TOTAL
--   FROM   SALES
--   WHERE  STATUS = 'O'
--   GROUP  BY COUNTRY
--   ORDER  BY TOTAL DESC;
