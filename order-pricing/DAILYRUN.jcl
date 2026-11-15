//DAILYORD JOB ,'DAILY PARTS ORDER FLOW',CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID
//*==================================================================
//* DAILY SPARE-PARTS ORDER FLOW  (see docs/pipeline.md for diagram)
//*
//*   PRICE -> priced file, then fan out to three consumers:
//*     2) REPORT   (ORDRPT, control-break) -> country sales report
//*     3) EXTRACT  (invoice interface)      -> SAP FI
//*     4) DB2 LOAD (embedded SQL)           -> DB2 sales table -> BI
//*
//* Built so far: PRICE (ORDPROC). Steps 2-4 are being added.
//* >>> replace ZXUSER with your HLQ (and DBXX with your DB2 subsystem)
//*==================================================================
//*
//* --- 1) PRICE: look up parts + VAT, write the priced file ---
//PRICE    EXEC PGM=ORDPROC
//STEPLIB  DD DSN=ZXUSER.AUTOPART.LOAD,DISP=SHR
//ORDERSDD DD DSN=ZXUSER.AUTOPART.ORDERS,DISP=SHR
//PARTSDD  DD DSN=ZXUSER.AUTOPART.PARTS,DISP=SHR
//PRICEDDD DD DSN=ZXUSER.AUTOPART.PRICED,DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(1,1)),DCB=(RECFM=FB,LRECL=40)
//SYSOUT   DD SYSOUT=*
//*
//* --- 2) REPORT: control-break country sales report ---
//REPORT   EXEC PGM=ORDRPT
//STEPLIB  DD DSN=ZXUSER.AUTOPART.LOAD,DISP=SHR
//PRICEDDD DD DSN=ZXUSER.AUTOPART.PRICED,DISP=SHR
//RPTOUT   DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//*
//* --- 3) EXTRACT: build the SAP invoicing interface file ---
//EXTRACT  EXEC PGM=INVEXTR
//STEPLIB  DD DSN=ZXUSER.AUTOPART.LOAD,DISP=SHR
//PRICEDDD DD DSN=ZXUSER.AUTOPART.PRICED,DISP=SHR
//SAPOUT   DD DSN=ZXUSER.AUTOPART.SAP.INVOICE,DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(1,1)),DCB=(RECFM=FB,LRECL=120)
//SYSOUT   DD SYSOUT=*
//*
//* --- 4) DB2 LOAD: insert the day's sales into a DB2 table ---
//*     a DB2 program is run through the TSO terminal monitor;
//*     DSN RUN loads the compiled plan.
//DB2LOAD  EXEC PGM=IKJEFT01
//STEPLIB  DD DSN=ZXUSER.AUTOPART.LOAD,DISP=SHR
//PRICEDDD DD DSN=ZXUSER.AUTOPART.PRICED,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  DSN SYSTEM(DBXX)
  RUN  PROGRAM(SALESDB2) PLAN(SALESDB2)
  END
/*
