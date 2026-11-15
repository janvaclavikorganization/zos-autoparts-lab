//DAILYORD JOB ,'DAILY PARTS ORDER FLOW',CLASS=A,MSGCLASS=H,NOTIFY=&SYSUID
//*==================================================================
//* DAILY SPARE-PARTS ORDER FLOW  (see docs/pipeline.md for diagram)
//*
//*   PRICE -> priced file, then fan out to two consumers:
//*     2) REPORT  (ORDRPT, control-break) -> country sales report
//*     3) EXTRACT (INVEXTR)               -> billing interface file
//*
//* >>> replace ZXUSER with your HLQ
//*==================================================================
//*
//* --- 1) PRICE: look up parts + VAT, write the priced file ---
//PRICE    EXEC PGM=ORDPROC
//STEPLIB  DD DSN=ZXUSER.AUTOPART.LOAD,DISP=SHR
//ORDERSDD DD DSN=ZXUSER.AUTOPART.ORDERS,DISP=SHR
//PARTSDD  DD DSN=ZXUSER.AUTOPART.PARTS,DISP=SHR
//PRICEDDD DD DSN=ZXUSER.AUTOPART.PRICED,DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(1,1)),DCB=(RECFM=FB,LRECL=37)
//SYSOUT   DD SYSOUT=*
//*
//* --- 2) REPORT: control-break country sales report ---
//REPORT   EXEC PGM=ORDRPT
//STEPLIB  DD DSN=ZXUSER.AUTOPART.LOAD,DISP=SHR
//PRICEDDD DD DSN=ZXUSER.AUTOPART.PRICED,DISP=SHR
//RPTOUT   DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//*
//* --- 3) EXTRACT: build the billing interface file ---
//EXTRACT  EXEC PGM=INVEXTR
//STEPLIB  DD DSN=ZXUSER.AUTOPART.LOAD,DISP=SHR
//PRICEDDD DD DSN=ZXUSER.AUTOPART.PRICED,DISP=SHR
//BILLOUT  DD DSN=ZXUSER.AUTOPART.BILLING,DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(1,1)),DCB=(RECFM=FB,LRECL=26)
//SYSOUT   DD SYSOUT=*
